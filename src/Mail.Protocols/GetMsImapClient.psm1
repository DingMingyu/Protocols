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
  $logger = Get-Logger -FilePath $logPath

  $azureCloudInstance = $assistant.GetAzureCloudInstance()
  $server = Get-OutlookEndpoint -AzureCloudInstance $azureCloudInstance
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
      $scopes = @(Get-Scope -AppName "IMAP" -AccessType "AsUser" -AzureCloudInstance $azureCloudInstance)
      $token = Get-AccessTokenInteractive -TenantId $tenantId -ClientId $clientId -Scopes $scopes -AzureCloudInstance $azureCloudInstance
    }
    else { # as app
      $scopes = @(Get-Scope -AppName "IMAP" -AccessType "AsApp" -AzureCloudInstance $azureCloudInstance)
      $clientSecret = $assistant.GetClientSecret()
      $token = Get-AccessTokenWithSecret -TenantId $tenantId -ClientId $clientId -Scopes $scopes -ClientSecret $clientSecret -AzureCloudInstance $azureCloudInstance
    }
    $imap.Connect()
    $result = $imap.O365Authenticate($token.AccessToken, $mailbox)
  }
  else { # basic auth
    $loginUser = $assistant.GetLoginUser()
    $pass = $assistant.GetPassword()
    $imap.Connect()
    if ($loginUser) {
      $result = $imap.Login($loginUser, $mailbox, $pass)
    }
    else {
      $result = $imap.Login($mailbox, $pass)
    }    
  }
  if ($result.Success) {
    return $imap
  }
  throw $result
}
