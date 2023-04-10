Import-Module D:\Dev\PowerShell\Protocols\src\Mail.Protocols\Mail.Protocols.psd1
# Import-Module Mail.Protocols
Import-Module D:\Dev\PowerShell\Protocols\my\MyData.psm1

$data = Get-MyData

$scopes = @(Get-Scope -AppName "POP" -AccessType "AsApp")
$token = Get-AccessTokenWithSecret -TenantId $data.TenantId -ClientId $data.ClientId -ClientSecret $data.ClientSecret -Scopes $scopes

$mailbox = $data.Mailbox
$logFile = "d:\logs\pop_{0:yyyyMMdd}.log" -f (Get-Date)
$logger = Get-Logger -FilePath $logFile

$server = Get-OutlookEndpoint
$port = Get-Port -AppName "POP"
$client = Get-TcpClient -Server $server -Port $port -Logger $logger
$pop = Get-PopClient -TcpClient $client
$pop.Connect()
$pop.O365Authenticate($token.AccessToken, $mailbox)
$pop.ExecuteCommand('LIST')
$pop.Close()
