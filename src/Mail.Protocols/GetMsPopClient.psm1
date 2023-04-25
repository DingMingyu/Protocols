using module .\AzureSettings.psm1
using module .\Analyzers.psm1
using module .\STcpClient.psm1
using module .\PopClient.psm1
using module .\Tokens.psm1
using module .\Result.psm1
using module .\Loggers.psm1
using module .\UserInputAssistant.psm1

function Get-MsPopClient () {
  <#
    .SYNOPSIS
    Get an PopClient with a wziard that is connected to Microsot Exchange's POP service.
    .DESCRIPTION
    This method guide user to get an PopClient that is connected to Microsot Exchange's POP service.
    
    .INPUTS
    None. You cannot pipe objects to Get-MsPopClient.

    .OUTPUTS
    PopClient object as returned by Get-PopClient.

    .EXAMPLE
    PS>$pop = Get-MsPopClient
  #>
  $assistant = Get-UserInputAssistant
  $logPath = $assistant.GetLogPath()
  $logger = Get-Logger -FilePath $LogPath

  $azureCloudInstance = $assistant.GetAzureCloudInstance()
  $server = Get-OutlookEndpoint -AzureCloudInstance $AzureCloudInstance
  $port = Get-Port -AppName "POP"
  $client = Get-TcpClient -Server $server -Port $port -Logger $logger
  $pop = Get-PopClient -TcpClient $client

  $mailbox = $assistant.GetMailbox()
  $authType = $assistant.GetAuthType()
  if ($authType -eq 1) { # OAuth
    $flowType = $assistant.GetFlowType()
    $tenantId = $assistant.GetTenantId()
    $clientId = $assistant.GetClientId()
    if ($flowType -eq 1) { # as user
      $scopes = @(Get-Scope -AppName "POP" -AccessType "AsUser" -AzureCloudInstance $AzureCloudInstance)
      $token = Get-AccessTokenInteractive -TenantId $TenantId -ClientId $ClientId -Scopes $scopes -AzureCloudInstance $AzureCloudInstance
    }
    else { # as app
      $scopes = @(Get-Scope -AppName "POP" -AccessType "AsApp" -AzureCloudInstance $AzureCloudInstance)
      $clientSecret = $assistant.GetClientSecret()
      $token = Get-AccessTokenWithSecret -TenantId $TenantId -ClientId $ClientId -Scopes $scopes -ClientSecret $ClientSecret -AzureCloudInstance $AzureCloudInstance
    }
    $pop.Connect()
    $result = $pop.O365Authenticate($token.AccessToken, $Mailbox)
  }
  else { # basic auth
    $pass = GetPass
    $pop.Connect()
    $result = $pop.Login($Mailbox, $Pass)
  }
  if ($result.Success) {
    return $pop
  }
  throw $result
}
