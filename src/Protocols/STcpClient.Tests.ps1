using module .\STcpClient.psm1

class DummyLogger{
  [string]$log
  [void]Info($msg) {
    if ($msg) {
      $this.log = $msg.ToString()
    }
    else{
      $this.log = [string]::Empty
    }
  }
}
Describe "TcpClient" -Tags "Unit" {
  It "receive imap message from Microsot 993 port" {
    $logger = [DummyLogger]::new()
    $server = "outlook.office365.com"
    $port = 993
    $client = Get-TcpClient -Server $server -Port $port -Logger $logger
    $client.Connect()
    $logger.log.Contains(" S * OK The Microsoft Exchange IMAP4 service is ready.") | Should be $true
  }
}
