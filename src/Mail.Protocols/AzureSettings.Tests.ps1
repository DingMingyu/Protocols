using module .\AzureSettings.psm1

Describe "Get-OutlookEndpoint" -Tags "Unit" {
  It "return azure public endpoint" {
    Get-OutlookEndpoint -AzureCloudInstance "AzurePublic" | Should be "outlook.office365.com"
  }
  It "return azure China endpoint" {
    Get-OutlookEndpoint -AzureCloudInstance "AzureChina" | Should be "partner.outlook.cn"
  }
  It "return azure Us Gov endpoint" {
    Get-OutlookEndpoint -AzureCloudInstance "AzureUsGovernment" | Should be "outlook.office365.us"
  }
  It "return null for invalid input" {
    Get-OutlookEndpoint -AzureCloudInstance "None" | Should be $null
  }
}

Describe "Get-Port" -Tags "Unit" {
  It "return 993 for IMAP" {
    Get-Port -AppName "IMAP" | Should be 993
  }
  It "return 995 for POP" {
    Get-Port -AppName "POP" | Should be 995
  }
}

Describe "Get-Scope" -Tags "Unit" {
  It "return scope for azure public IMAP as user" {
    Get-Scope -AzureCloudInstance "AzurePublic" -AccessType "AsUser" -AppName "IMAP" | Should be "https://outlook.office365.com/IMAP.AccessAsUser.All"
  }
  It "return scope for azure public POP as user" {
    Get-Scope -AzureCloudInstance "AzurePublic" -AccessType "AsUser" -AppName "POP" | Should be "https://outlook.office365.com/POP.AccessAsUser.All"
  }
  It "return scope for azure public IMAP as app" {
    Get-Scope -AzureCloudInstance "AzurePublic" -AccessType "AsApp" -AppName "IMAP" | Should be "https://outlook.office365.com/.default"
  }
  It "return scope for azure public POP as app" {
    Get-Scope -AzureCloudInstance "AzurePublic" -AccessType "AsApp" -AppName "POP" | Should be "https://outlook.office365.com/.default"
  }
  It "return scope for azure US gov IMAP as user" {
    Get-Scope -AzureCloudInstance "AzureUsGovernment" -AccessType "AsUser" -AppName "IMAP" | Should be "https://outlook.office365.us/IMAP.AccessAsUser.All"
  }
  It "return scope for azure US gov POP as user" {
    Get-Scope -AzureCloudInstance "AzureUsGovernment" -AccessType "AsUser" -AppName "POP" | Should be "https://outlook.office365.us/POP.AccessAsUser.All"
  }
  It "return scope for azure US gov IMAP as user" {
    Get-Scope -AzureCloudInstance "AzureUsGovernment" -AccessType "AsApp" -AppName "IMAP" | Should be "https://outlook.office365.us/.default"
  }
  It "return scope for azure US gov POP as user" {
    Get-Scope -AzureCloudInstance "AzureUsGovernment" -AccessType "AsApp" -AppName "POP" | Should be "https://outlook.office365.us/.default"
  }
  It "return scope for azure China IMAP as user" {
    Get-Scope -AzureCloudInstance "AzureChina" -AccessType "AsUser" -AppName "IMAP" | Should be "https://partner.outlook.cn/IMAP.AccessAsUser.All"
  }
  It "return scope for azure China POP as user" {
    Get-Scope -AzureCloudInstance "AzureChina" -AccessType "AsUser" -AppName "POP" | Should be "https://partner.outlook.cn/POP.AccessAsUser.All"
  }
  It "return scope for azure public IMAP as app" {
    Get-Scope -AzureCloudInstance "AzureChina" -AccessType "AsApp" -AppName "IMAP" | Should be "https://partner.outlook.cn/.default"
  }
  It "return scope for azure public POP as app" {
    Get-Scope -AzureCloudInstance "AzureChina" -AccessType "AsApp" -AppName "POP" | Should be "https://partner.outlook.cn/.default"
  }
  It "return null for invalid input" {
    Get-Scope -AzureCloudInstance "None" -AccessType "AsUser" -AppName "IMAP" | Should be $null
  }
}