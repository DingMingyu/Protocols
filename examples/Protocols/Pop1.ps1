Import-Module D:\Dev\PowerShell\Protocols\src\Protocols\Mail.Protocols.psd1
Import-Module D:\Dev\PowerShell\Protocols\my\MyData.psm1

$constants = Get-Constants
$data = Get-MyData

$scopes = @($constants.Scope_Outlook_POP_App_WW)
$token = Get-AccessTokenWithSecret -TenantId $data.TenantId -ClientId $data.ClientId -ClientSecret $data.ClientSecret -Scopes $scopes

$mailbox = $data.Mailbox
$logFile = "d:\logs\pop_{0:yyyyMMdd}.log" -f (Get-Date)
$logger = Get-Logger -FilePath $logFile
$client = Get-TcpClient -Server $constants.EndPoint_Outlook_WW -Port $constants.Port_POP -Logger $logger
$pop = Get-PopClient -TcpClient $client
$pop.Connect()
$pop.O365Authenticate($token.AccessToken, $mailbox)
$pop.ExecuteCommand('LIST')
$pop.Close()
