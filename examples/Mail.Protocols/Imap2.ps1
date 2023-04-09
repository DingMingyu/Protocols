Import-Module D:\Dev\PowerShell\Protocols\src\Mail.Protocols\Mail.Protocols.psd1
# Import-Module Mail.Protocols
Import-Module D:\Dev\PowerShell\Protocols\my\MyData.psm1

$data = Get-MyData
$logFile = "d:\logs\imap_{0:yyyyMMdd}.log" -f (Get-Date)

Test-MsImap -Mailbox $data.Mailbox -LogPath $logFile -TenantId $data.TenantId -ClientId $data.ClientId -ClientSecret $data.ClientSecret
