Import-Module D:\Dev\PowerShell\Protocols\src\Mail.Protocols\Mail.Protocols.psd1
# Import-Module Mail.Protocols

$pop = Get-MsPopClient
$pop.ExecuteCommand('LIST')
$pop.Close()
