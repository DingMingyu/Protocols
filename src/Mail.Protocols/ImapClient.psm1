using module .\STcpClient.psm1
using module .\Tokens.psm1
using module .\Result.psm1
using module .\Utility.psm1

class ImapClient {
  [int]$tag = 0
  $client #[STcpClient]
  $utility #[Utility]

  ImapClient($client) {
    $this.client = $client
    $this.utility = Get-Utility
  }

  [void]Connect() {
    $this.client.Connect()
  }

  [void]Close() {
    $this.client.Close()
  }

  [System.Object]ExecuteCommand([string]$cmd) {
    return $this.ExecuteCommand($cmd, $true)
  }

  [System.Object]ExecuteCommand([string]$cmd, [bool]$shouldLog) {
    $this.tag++
    $cmdText = [string]::Format("{0} {1}", $this.getTagText(), $cmd)
    return $this.executeInternal($cmdText, $shouldLog)
  }

  [System.Object]SaveEmail([string]$folder, [string]$content) {
    $this.tag++
    $cmdText = $this.getTagText() + " APPEND $folder {" + $content.Length + "}"
    $this.client.SubmitRequest($cmdText)
    $line = $this.client.ReadResponse($true)
    if ($line -and $line.StartsWith("+ Ready for additional command text.")) {
      return $this.executeInternal($content, $true)
    }
    return Get-Result -Success $false -Payload $line -ErrorMessage 'IMAP should return "+ Ready for additional command text." for append command.'
  }

  [System.Object]O365Authenticate([string]$accessToken, [string]$upn) {
    $token = $this.utility.BuildO365Token($accessToken, $upn)
    return $this.xOauth2Authenticate($token)
  }

  [System.Object]Login([string]$user, [string]$pass) {
    return $this.ExecuteCommand("login $user $pass")
  }

  [System.Object]Login([string]$user, [string]$targetMailbox, [string]$pass) {
    return $this.ExecuteCommand("login $user\$targetMailbox $pass")
  }

  [System.Object]executeInternal($cmd, [bool]$shouldLog) {
    $this.client.SubmitRequest($cmd, $this.redact($cmd))
    $tagText = $this.getTagText()
    $sb = [System.Text.StringBuilder]::new()
    $first = $true
    do {
      if ($first) {
        $first = $false
      }
      else {
        $sb.AppendLine()
      }        
      $line = $this.client.ReadResponse($shouldLog)
      $sb.Append($line)
    }
    while(!$line.StartsWith($tagText + " "))
    $parts = $line.Split(" ")
    $success = $parts.Length -gt 1 -and $parts[1] -eq "OK"
    $errorMessage = ""
    if (!$success) {
      $errorMessage = 'IMAP should return "OK" for successful command handling.'
    }
    return Get-Result -Success $success -Payload $sb.ToString() -ErrorMessage $errorMessage
  }

  [System.Object]xOauth2Authenticate([string]$oAuthToken) {
    $cmd = "AUTHENTICATE XOAUTH2 $oAuthToken"
	  return $this.ExecuteCommand($cmd)
  }

  [string]redact([string]$text) {
    $parts = $text.Split(" ")
    if ($parts.Length -ge 4 -and $parts[1] -eq "login")
    {
      $parts[3] = "****"
      return [string]::Join(" ", $parts[0..3])
    }
    return $text
  }

  [string]getTagText() {
    return $this.tag.ToString("D4")
  }
}

function Get-ImapClient($TcpClient) {
  <#
    .SYNOPSIS
    Get a ImapClient for IMAP connection.

    .DESCRIPTION
    This method returns a Imap Client object which can be used to read/write data through a IMAP connection.
      
    .PARAMETER TcpClient
    The underlying TcpClient that is returned by Get-TcpClient command.

    .INPUTS
    None. You cannot pipe objects to Get-ImapClient

    .OUTPUTS
    ImapClient object.

    .EXAMPLE
    PS>$tcpClient = Get-TcpClient -Server outlook.office365.com -Port 993 -Logger $logger
    PS>$imapClient = Get-ImapClient -TcpClient $tcpClient
  #>
  return [ImapClient]::new($TcpClient)
}