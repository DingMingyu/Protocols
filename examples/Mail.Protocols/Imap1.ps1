Import-Module D:\Dev\PowerShell\Protocols\src\Mail.Protocols\Mail.Protocols.psd1
Import-Module D:\Dev\PowerShell\Protocols\my\MyData.psm1

$constants = Get-Constants
$data = Get-MyData
$scopes = @($constants.Scope_Outlook_IMAP_App_WW)
$token = Get-AccessTokenWithSecret -TenantId $data.TenantId -ClientId $data.ClientId -ClientSecret $data.ClientSecret -Scopes $scopes

$mailbox = $data.Mailbox
$logFile = "d:\logs\imap_{0:yyyyMMdd}.log" -f (Get-Date)
$logger = Get-Logger -FilePath $logFile
$client = Get-TcpClient -Server $constants.EndPoint_Outlook_WW -Port $constants.Port_IMAP -Logger $logger
$imap = Get-ImapClient -TcpClient $client
$imap.Connect()
$imap.O365Authenticate($token.AccessToken, $mailbox)
$imap.ExecuteCommand('LIST "" *')
# save a draft email
$imap.ExecuteCommand('SELECT "Drafts"')
$msg = "From: $mailbox`r`nTo: $mailbox`r`nSubject: test`r`n`r`nthis is a test message, please ignore`r`n"
$imap.SaveEmail("Drafts", $msg)

$imap.ExecuteCommand('SELECT "INBOX"')
# download an email
$imap.ExecuteCommand("FETCH 1 (RFC822.HEADER BODY.PEEK[1])")
# set the email as read.
$imap.ExecuteCommand("STORE 1 +flags \Seen")
$imap.Close()
