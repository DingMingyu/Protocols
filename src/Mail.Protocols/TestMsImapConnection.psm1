using module .\TestMsImap.psm1
using module .\UserInputAssistant.psm1

function Test-MsImapConnection () {
  <#
    .SYNOPSIS
    Test Microsot Exchange's IMAP service's connectivity with a wizard.
    .DESCRIPTION
    This method guide user to test Microsot Exchange's IMAP service's connectivity.
    
    .INPUTS
    None. You cannot pipe objects to Test-MsImapConnection.

    .OUTPUTS
    None. It will display the result in text.

    .EXAMPLE
    PS>Test-MsImapConnection
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
      return Test-MsImap -Mailbox $mailbox -TenantId $tenantId -ClientId $clientId -AzureCloudInstance $azureCloudInstance -LogPath $logPath
    }
    else { # as app
      $clientSecret = $assistant.GetClientSecret()
      return Test-MsImap -Mailbox $mailbox -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret -AzureCloudInstance $azureCloudInstance -LogPath $logPath
    }
  }
  else { # basic auth
    $pass = GetPass
    Test-MsImap -Mailbox $mailbox -Pass $pass -AzureCloudInstance $azureCloudInstance -LogPath $logPath
  }
}
