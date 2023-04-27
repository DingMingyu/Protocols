using module .\TestMsPop.psm1
using module .\UserInputAssistant.psm1

function Test-MsPopConnection () {
  <#
    .SYNOPSIS
    Test Microsot Exchange's POP service's connectivity with a wizard.
    .DESCRIPTION
    This method guide user to test Microsot Exchange's POP service's connectivity.
    
    .INPUTS
    None. You cannot pipe objects to Test-MsPopConnection.

    .OUTPUTS
    None. It will display the result in text.

    .EXAMPLE
    PS>Test-MsPopConnection
  #>
  $assistant = Get-UserInputAssistant
  $logPath = $assistant.GetLogPath()
  $azureCloudInstance = $assistant.GetAzureCloudInstance()
  $mailbox = $assistant.GetMailbox()
  $authType = $assistant.GetAuthType()
  if ($authType -eq 1) { # OAuth
    $flowType = $assistant.GetFlowType()
    $tenantId = $assistant.GetTenantId()
    $clientId = $assistant.GetClientId()
    if ($flowType -eq 1) { # as user
      return Test-MsPop -Mailbox $mailbox -TenantId $tenantId -ClientId $clientId -AzureCloudInstance $azureCloudInstance -LogPath $logPath
    }
    else { # as app
      $clientSecret = $assistant.GetClientSecret()
      return Test-MsPop -Mailbox $mailbox -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret -AzureCloudInstance $azureCloudInstance -LogPath $logPath
    }
  }
  else { # basic auth
    $loginUser = $assistant.GetLoginUser()
    $pass = $assistant.GetPassword()
    Test-MsPop -Mailbox $mailbox -Pass $pass -LoginUser $loginUser -AzureCloudInstance $azureCloudInstance -LogPath $logPath
  }
}
