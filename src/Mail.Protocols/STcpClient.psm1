using module .\Message.psm1

class STcpClient {
  [string]$server
  [int]$port
  [System.IO.StreamReader]$reader
  [System.IO.StreamWriter]$writer
  [System.Net.Sockets.TcpClient]$client
  [System.Security.Authentication.SslProtocols]$sslProtocol
  $logger # logger with Info and Error function

  STcpClient([string]$server, [int]$port, $logger, [System.Security.Authentication.SslProtocols]$sslProtocol) {
    $this.server = $server
    $this.port = $port
    $this.logger = $logger
    $this.sslProtocol = $sslProtocol
  }
  
  [void]Close() {
    if ($this.client) {
      $this.client.Close()
      $msg = Get-Message -From "C" -Text "Connection is closed."
      $this.LogInfo($msg)
    }
  }
  
  [void]Connect() {
    $this.client = New-Object System.Net.Sockets.TcpClient($this.server, $this.port)
    $this.client.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::KeepAlive, $true)
    $strm = $this.client.GetStream()
    [System.Net.Security.RemoteCertificateValidationCallback]$c={return $true}
    $strm = New-Object System.Net.Security.SslStream($strm, $false, $c)
    $strm.AuthenticateAsClient($this.server, $null, $this.sslProtocol, $false)
    $this.reader = New-Object System.IO.StreamReader($strm, [System.Text.Encoding]::ASCII)
    $this.writer = New-Object System.IO.StreamWriter($strm, [System.Text.Encoding]::ASCII)
    $this.writer.NewLine = "`r`n"
    $this.writer.AutoFlush = $true
    $this.ReadResponse($true)
  }
  
  [void]SubmitRequest([string]$cmd) {
    $this.SubmitRequest($cmd, $cmd)
  }
  
  [void]SubmitRequest([string]$cmd, [string]$log) {
    $this.writer.WriteLine($cmd)
    $this.LogRequest($log)
  }
  
  [string]ReadResponse([bool]$shouldLog) {
    $text = $this.reader.ReadLine()
    if ($shouldLog) {
      $this.LogResponse($text)
    }
    return $text
  }
  
  [void]LogRequest([string]$text) {
    $msg = Get-Message -From "C" -Text $text
    $this.LogInfo($msg)
  }
  
  [void]LogResponse([string]$text) {
    $msg = Get-Message -From "S" -Text $text
    $this.LogInfo($msg)
  }
  
  [void]LogInfo($msg) {
    if ($this.logger -and $this.logger.Info) {
      $this.logger.Info($msg)
    }
  }
  
  [void]LogError($msg) {
    if ($this.logger -and $this.logger.Error) {
      $this.logger.Error($msg)
    }
    else {
      $this.LogInfo($msg)
    }
  }
}
function Get-TcpClient (
  [string]$Server,
  [int]$Port,
  $Logger, # logger with Info and Error function
  [System.Security.Authentication.SslProtocols]$SslProtocol = [System.Security.Authentication.SslProtocols]::Tls12
) {
  <#
    .SYNOPSIS
    Get a TcpClient for TCP connection.

    .DESCRIPTION
    This method returns a Tcp Client object which can be used to read/write data through a TCP connection.
      
    .PARAMETER Server
    Server DNS or IP to connect. 

    .PARAMETER Port
    Port for the TCP connection.

    .PARAMETER Logger
    A logger object (retreived from Get-Logger).

    .PARAMETER SslProtocol
    TLS level of the connection. TLS12 is the default.

    .INPUTS
    None. You cannot pipe objects to Get-TcpClient

    .OUTPUTS
    TcpClient object.

    .EXAMPLE
    PS>Get-TcpClient -Server outlook.office365.com -Port 993 -Logger $logger

    .EXAMPLE
    PS>Get-TcpClient -Server outlook.office365.com -Port 993 -Logger $logger -SslProtocol Tls11
  #>
  return [STcpClient]::new(
    $Server,
    $Port,
    $Logger,
    $SslProtocol
  )
}
