Import-Module MSAL.PS

function Get-OutlookEndpoint (
  [Microsoft.Identity.Client.AzureCloudInstance]$AzureCloudInstance = [Microsoft.Identity.Client.AzureCloudInstance]::AzurePublic
) {
  switch ($AzureCloudInstance) {
    "AzureChina" {
      return "partner.outlook.cn"
    }
    "AzureUsGovernment" {
      return "outlook.office365.us"
    }
    "AzurePublic" {
      return "outlook.office365.com"
    }
  }
}

Add-Type -TypeDefinition @"
  public enum AccessType
  {
    AsUser,
    AsApp
  }
  public enum AppName
  {
    IMAP,
    POP   
  }
"@

function  Get-Port ([AppName]$AppName) {
  switch ($AppName) {
    "IMAP" { return 993 }
    "POP" { return 995 }
  }  
}

function Get-Scope (
  [AppName]$AppName,
  [AccessType]$AccessType,
  [Microsoft.Identity.Client.AzureCloudInstance]$AzureCloudInstance = [Microsoft.Identity.Client.AzureCloudInstance]::AzurePublic
) {
  $endpoint = Get-OutlookEndpoint -AzureCloudInstance $AzureCloudInstance
  switch ($AccessType) {
    "AsApp" { return "https://$endpoint/.default" }
    "AsUser" {
      switch ($AppName) {
        "IMAP" { return "https://$endpoint/IMAP.AccessAsUser.All" }
        "POP" { return "https://$endpoint/POP.AccessAsUser.All" }
      }
    }
  }
}