Import-Module D:\Dev\PowerShell\Protocols\src\Mail.Protocols\Mail.Protocols.psd1
# Import-Module Mail.Protocols
Import-Module D:\Dev\PowerShell\Protocols\my\MyData.psm1

$data = Get-MyData
$scopes = @(Get-Scope -AppName IMAP -AccessType AsApp)
$token = Get-AccessTokenWithSecret -TenantId $data.TenantId -ClientId $data.ClientId -ClientSecret $data.ClientSecret -Scopes $scopes

$mailbox = $data.Mailbox
$logFile = "d:\logs\imap_{0:yyyyMMdd}.log" -f (Get-Date)
$logger = Get-Logger -FilePath $logFile
$server = Get-OutlookEndpoint
$port = Get-Port -AppName IMAP

$client = Get-TcpClient -Server $server -Port $port -Logger $logger
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
