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
  $logger = Get-Logger -FilePath $logPath

  $azureCloudInstance = $assistant.GetAzureCloudInstance()
  $server = Get-OutlookEndpoint -AzureCloudInstance $azureCloudInstance
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
      $scopes = @(Get-Scope -AppName "POP" -AccessType "AsUser" -AzureCloudInstance $azureCloudInstance)
      $token = Get-AccessTokenInteractive -TenantId $tenantId -ClientId $clientId -Scopes $scopes -AzureCloudInstance $azureCloudInstance
    }
    else { # as app
      $scopes = @(Get-Scope -AppName "POP" -AccessType "AsApp" -AzureCloudInstance $azureCloudInstance)
      $clientSecret = $assistant.GetClientSecret()
      $token = Get-AccessTokenWithSecret -TenantId $tenantId -ClientId $clientId -Scopes $scopes -ClientSecret $clientSecret -AzureCloudInstance $azureCloudInstance
    }
    $pop.Connect()
    $result = $pop.O365Authenticate($token.AccessToken, $mailbox)
  }
  else { # basic auth
    $loginUser = $assistant.GetLoginUser()
    $pass = $assistant.GetPassword()
    $pop.Connect()
    if ($loginUser) {
      $result = $pop.Login($loginUser, $mailbox, $pass)  
    }
    else {
      $result = $pop.Login($mailbox, $pass)
    }    
  }
  if ($result.Success) {
    return $pop
  }
  throw $result
}
