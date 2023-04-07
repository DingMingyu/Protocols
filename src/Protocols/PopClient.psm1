using module .\STcpClient.psm1
using module .\Tokens.psm1
using module .\Result.psm1

class PopClient {

  $client #[STcpClient]

  PopClient($client) {
    $this.client = $client
  }
  
  [void]Connect() {
    $this.client.Connect()
  }

  [void]Close() {
    $this.client.Close()
  }

  [System.Object]ExecuteCommand([string]$cmd) {
    $this.client.SubmitRequest($cmd, $this.redact($cmd))
    $sb = [System.Text.StringBuilder]::new()
    $line = $this.client.ReadResponse($true)
    $sb.Append($line)
    $success = $line.StartsWith("+")
    if ($success) {
      $parts = $cmd.Split(" ")
      $c1 = $parts[0].ToUpper()
      $hasMore = ($c1 -eq "RETR") `
        -or ($c1 -eq "TOP") `
        -or ($c1 -eq "CAPA") `
        -or (($c1 -eq "LIST") -and ($parts.Length -eq 1)) `
        -or (($c1 -eq "UIDL") -and ($parts.Length -eq 1))

      if ($hasMore) {
        do {
          $line = $this.client.ReadResponse($true)
          $sb.AppendLine()
          $sb.Append($line)
        }
        while($line -ne ".")        
      }
    }
    $errorMessage = ""
    if (!$success) {
      $errorMessage = 'POP should return "+" for successful command handling.'
    }
    return Get-Result -Success $success -Payload $sb.ToString() -ErrorMessage $errorMessage
  }
  
  [System.Object]Login([string]$user, [string]$pass) {
    if ($this.ExecuteCommand("USER $user")) {
      return $this.ExecuteCommand("PASS $pass")
    }
    return $false
  }

  [System.Object]O365Authenticate([string]$accessToken, [string]$upn) {
    $token = Get-O365Token -AccessToken $accessToken -Upn $upn
    return $this.xOauth2Authenticate($token)
  }

  [System.Object]xOauth2Authenticate([string]$oAuthToken) {
    if ($this.ExecuteCommand("AUTH XOAUTH2")) {
      return $this.ExecuteCommand($oAuthToken)
    }
    return $false
  }

  [string]redact([string]$text) {
    if ($text.ToUpper().StartsWith("PASS ")) {
      return "PASS ****"
    }
    return $text
  }
}

function  Get-PopClient($TcpClient) {
  <#
    .SYNOPSIS
    Get a PopClient for POP3 connection.

    .DESCRIPTION
    This method returns a Pop Client object which can be used to read/write data through a POP3 connection.
      
    .PARAMETER TcpClient
    The underlying TcpClient that is returned by Get-TcpClient command.

    .INPUTS
    None. You cannot pipe objects to Get-PopClient

    .OUTPUTS
    PopClient object.

    .EXAMPLE
    PS>$tcpClient = Get-TcpClient -Server outlook.office365.com -Port 993 -Logger $logger
    PS>$popClient = Get-PopClient -TcpClient $tcpClient
  #>
  return [PopClient]::new($TcpClient)
}