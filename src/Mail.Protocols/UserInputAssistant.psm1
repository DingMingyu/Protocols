Import-Module MSAL.PS

class UserInputAssistant {
  [Microsoft.Identity.Client.AzureCloudInstance]GetAzureCloudInstance() {
    while ($true) {
      $choice = Read-Host -Prompt 'Please input the Azure Cloud Instance of interest. (1. AzurePublic, 2. AzureChina, 3. AzureUsGovernment.)'
      if ($choice -eq 1) {
        return [Microsoft.Identity.Client.AzureCloudInstance]::AzurePublic
      }
      elseif ($choice -eq 2) {
        return [Microsoft.Identity.Client.AzureCloudInstance]::AzureChina
      }
      elseif ($choice -eq 3) {
        return [Microsoft.Identity.Client.AzureCloudInstance]::AzureUsGovernment
      }
    }
    return $null
  }
  
  [int]GetAuthType() {
    while ($true) {
      $authType = Read-Host -Prompt 'Please input the authentication type. (1. OAuth, 2. Basic Auth **has deprecated in most tenants**.)'
      if ($authType -in @(1,2)) {
        return $authType
      }      
    }
    return 0  
  }
  
  [string]GetMailbox() {
    while ($true) {
      $mailbox = Read-Host -Prompt 'Please input the mailbox to connect.'
      if ($mailbox) {
        return $mailbox
      }      
    }
    return ""
  }
  
  [string]GetPassword() {
    while ($true) {
      $password = Read-Host -Prompt 'Please input the password for basic authentication.' -AsSecureString
      if ($password) {
        return [System.Net.NetworkCredential]::new("", $password).Password
      }      
    }
    return ""
  }

  [string]GetLogPath() {
    $defaultPath = "logs\imap_{0:yyyyMMdd}.log" -f (Get-Date)
    return Read-Host -Prompt "Please input log file path. If empty, it will be set as: $defaultPath."
  }
  
  [int]GetFlowType() {
    while ($true) {
      $flowType = Read-Host -Prompt 'Do you want to access the mailbox as user delegation (login window will prompt for authentication) or as app (a secret will be needed for authenticaiton)? (1. User delegation, 2. App.)'
      if ($flowType -in @(1,2)) {
        return $flowType
      }      
    }
    return 0
  }

  [string]GetTenantId() {
    return Read-Host -Prompt "Please input your tenant Id. Input empty string if your app is registered as a multiple-tenant app."
  }

  [string]GetClientId() {
    while ($true) {
      $clientId = Read-Host -Prompt "Please input your client Id (aka application id)."
      if ($clientId) {
        return $clientId
      }    
    }
    return ""
  }

  [string]GetClientSecret() {
    while ($true) {
      $secret = Read-Host -Prompt 'Please input the secret of the registered app.' -AsSecureString
      if ($secret) {
        return [System.Net.NetworkCredential]::new("", $secret).Password
      }      
    }
    return ""
  }
}
  
function  Get-UserInputAssistant {
  return [UserInputAssistant]::new()  
}
