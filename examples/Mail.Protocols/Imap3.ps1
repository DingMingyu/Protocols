Import-Module D:\Dev\PowerShell\Protocols\src\Mail.Protocols\Mail.Protocols.psd1
# Import-Module Mail.Protocols

$imap = Get-MsImapClient
$imap.ExecuteCommand('LIST "" *')
$imap.Close()
