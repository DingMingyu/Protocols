Import-Module MSAL.PS

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

function Get-OutlookEndpoint (
  [Microsoft.Identity.Client.AzureCloudInstance]$AzureCloudInstance = [Microsoft.Identity.Client.AzureCloudInstance]::AzurePublic
) {
  <#
    .SYNOPSIS
    Get the endpoint for Outlook in various Azure cloud instances.

    .DESCRIPTION
    This method returns the endpoint for Outlook in various Azure cloud instances.
      
    .PARAMETER AzureCloudInstance
    Azure instance name.

    .INPUTS
    None. You cannot pipe objects to Get-OutlookEndpoint.

    .OUTPUTS
    It returns an string of the endpoint for Outlook in various Azure cloud instances.

    .EXAMPLE
    PS>Get-OutlookEndpoint -AzureCloudInstance AzurePublic
  #>
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

function  Get-Port ([AppName]$AppName) {
  <#
    .SYNOPSIS
    Get the port for various apps.

    .DESCRIPTION
    This method returns the port for various apps.
      
    .PARAMETER AppName
    Applicaiton of the access token. E.g. IMAP, POP.

    .INPUTS
    None. You cannot pipe objects to Get-Port.

    .OUTPUTS
    It returns the port number.

    .EXAMPLE
    PS>Get-Port -AppName IMAP
  #>
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
  <#
    .SYNOPSIS
    Get the scope for requesting an access token.

    .DESCRIPTION
    This method returns the scope for requesting an access token.
      
    .PARAMETER AppName
    Applicaiton of the access token. E.g. IMAP, POP.

    .PARAMETER AccessType
    As user or as an app.

    .PARAMETER AzureCloudInstance
    Azure instance name.

    .INPUTS
    None. You cannot pipe objects to Get-Scope.

    .OUTPUTS
    It returns an string of the required scope.

    .EXAMPLE
    PS>Get-Scope -AppName IMAP -AccessType "AsApp"

    .EXAMPLE
    PS>Get-Scope -AppName POP -AccessType "AsApp" -AzureCloudInstance AzureUsGovernment
  #>
  $endpoint = Get-OutlookEndpoint -AzureCloudInstance $AzureCloudInstance
  if (!$endpoint) {
    return $null
  }
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

function Get-Scp (
  [AppName]$AppName,
  [AccessType]$AccessType
) {
  <#
    .SYNOPSIS
    Get the scope that should be included in the returned access token.

    .DESCRIPTION
    This method returns the scope that should be included in the returned access token.
      
    .PARAMETER AppName
    Applicaiton of the access token. E.g. IMAP, POP.

    .PARAMETER AccessType
    As user or as an app.

    .INPUTS
    None. You cannot pipe objects to Get-Scp.

    .OUTPUTS
    It returns an string of the required scope.

    .EXAMPLE
    PS>Get-Scp -AppName IMAP -AccessType "AsApp"
  #>
  switch ($AccessType) {
    "AsApp" { 
      switch ($AppName) {
        "IMAP" { return "IMAP.AccessAsApp" }
        "POP" { return "POP.AccessAsApp" }
      }
    }
    "AsUser" {
      switch ($AppName) {
        "IMAP" { return "IMAP.AccessAsUser.All" }
        "POP" { return "POP.AccessAsUser.All" }
      }
    }
  }
}

function Get-Aud (
  [Microsoft.Identity.Client.AzureCloudInstance]$AzureCloudInstance = [Microsoft.Identity.Client.AzureCloudInstance]::AzurePublic
) {
  <#
    .SYNOPSIS
    Get the Audience for requesting an access token.

    .DESCRIPTION
    This method returns the Audience for requesting an access token.
      
    .PARAMETER AzureCloudInstance
    Azure instance name.

    .INPUTS
    None. You cannot pipe objects to Get-Aud.

    .OUTPUTS
    It returns an string of the Audience.

    .EXAMPLE
    PS>Get-Aud -AzureCloudInstance AzurePublic
  #>
  $endpoint = Get-OutlookEndpoint -AzureCloudInstance $AzureCloudInstance
  if ($endpoint) {
    return "https://$endpoint"   
  }
  return $null
}
