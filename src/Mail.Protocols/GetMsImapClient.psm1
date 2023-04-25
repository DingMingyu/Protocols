using module .\AzureSettings.psm1
using module .\Analyzers.psm1
using module .\STcpClient.psm1
using module .\ImapClient.psm1
using module .\Tokens.psm1
using module .\Result.psm1
using module .\Loggers.psm1
using module .\UserInputAssistant.psm1

function Get-MsImapClient () {
  <#
    .SYNOPSIS
    Get an ImapClient with a wziard that is connected to Microsot Exchange's IMAP service.
    .DESCRIPTION
    This method guide user to get an ImapClient that is connected to Microsot Exchange's IMAP service.
    
    .INPUTS
    None. You cannot pipe objects to Get-MsImapClient.

    .OUTPUTS
    ImapClient object as returned by Get-ImapClient.

    .EXAMPLE
    PS>$imap = Get-MsImapClient
  #>
  $assistant = Get-UserInputAssistant
  $logPath = $assistant.GetLogPath()
  $logger = Get-Logger -FilePath $LogPath

  $azureCloudInstance = $assistant.GetAzureCloudInstance()
  $server = Get-OutlookEndpoint -AzureCloudInstance $AzureCloudInstance
  $port = Get-Port -AppName "IMAP"
  $client = Get-TcpClient -Server $server -Port $port -Logger $logger
  $imap = Get-ImapClient -TcpClient $client

  $mailbox = $assistant.GetMailbox()
  $authType = $assistant.GetAuthType()
  if ($authType -eq 1) { # OAuth
    $flowType = $assistant.GetFlowType()
    $tenantId = $assistant.GetTenantId()
    $clientId = $assistant.GetClientId()
    if ($flowType -eq 1) { # as user
      $scopes = @(Get-Scope -AppName "IMAP" -AccessType "AsUser" -AzureCloudInstance $AzureCloudInstance)
      $token = Get-AccessTokenInteractive -TenantId $TenantId -ClientId $ClientId -Scopes $scopes -AzureCloudInstance $AzureCloudInstance
    }
    else { # as app
      $scopes = @(Get-Scope -AppName "IMAP" -AccessType "AsApp" -AzureCloudInstance $AzureCloudInstance)
      $clientSecret = $assistant.GetClientSecret()
      $token = Get-AccessTokenWithSecret -TenantId $TenantId -ClientId $ClientId -Scopes $scopes -ClientSecret $ClientSecret -AzureCloudInstance $AzureCloudInstance
    }
    $imap.Connect()
    $result = $imap.O365Authenticate($token.AccessToken, $Mailbox)
  }
  else { # basic auth
    $pass = GetPass
    $imap.Connect()
    $result = $imap.Login($Mailbox, $Pass)
  }
  if ($result.Success) {
    return $imap
  }
  throw $result
}
