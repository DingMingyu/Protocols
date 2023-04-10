using module .\TestMsPop.psm1
using module .\CommandHelper.psm1

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
  $logPath = GetLogPath
  $azureCloudInstance = GetAzureCloudInstance
  $mailbox = GetMailbox
  $authType = GetAuthType
  if ($authType -eq 1) { # OAuth
    $flowType = GetFlowType
    $tenantId = GetTenantId
    $clientId = GetClientId
    if ($flowType -eq 1) { # as user
      return Test-MsPop -Mailbox $mailbox -TenantId $tenantId -ClientId $clientId -AzureCloudInstance $azureCloudInstance -LogPath $logPath
    }
    else { # as app
      $clientSecret = GetClientSecret
      return Test-MsPop -Mailbox $mailbox -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret -AzureCloudInstance $azureCloudInstance -LogPath $logPath
    }
  }
  else { # basic auth
    $pass = GetPass
    Test-MsPop -Mailbox $mailbox -Pass $pass -AzureCloudInstance $azureCloudInstance -LogPath $logPath
  }
}
