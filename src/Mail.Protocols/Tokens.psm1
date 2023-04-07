function Get-O365Token(
  [string]$AccessToken,
  [string]$Upn
) {
  <#
    .SYNOPSIS
    Get Tokne for O365 authentication.

    .DESCRIPTION
    This function build an O365 token with Azure AccessToken and the target user's UPN.
      
    .PARAMETER AccessToken
    AccessToken retrieved from Azure.

    .PARAMETER Upn
    User's UPN.

    .INPUTS
    None. You cannot pipe objects to Get-O365Token

    .OUTPUTS
    It returns an O365 authentication token.

    .EXAMPLE
    PS>Get-O365Token -AccessToken $AccessToken -Upn user@contoso.com
  #>
  [char]$ctrlA = 1
  $token = "user=" + $Upn + $ctrlA + "auth=Bearer " + $AccessToken + $ctrlA + $ctrlA
  $bytes = [System.Text.Encoding]::ASCII.GetBytes($token)
  $encodedToken = [Convert]::ToBase64String($bytes)
  return $encodedToken
}

function Get-AccessTokenInteractive(
  [string]$TenantId,
  [string]$ClientId,
  $Scopes,
  [Microsoft.Identity.Client.AzureCloudInstance]$AzureCloudInstance=[Microsoft.Identity.Client.AzureCloudInstance]::AzurePublic
) {
  <#
    .SYNOPSIS
    Get AccessToken interactively from Azure.

    .DESCRIPTION
    This method tryies to get an AccessToken from Azure.
      
    .PARAMETER TenantId
    TenantId in Azure.

    .PARAMETER ClientId
    ClientId or AppId in Azure. It is not required if it is registered as a multiple-tenant app.

    .PARAMETER Scopes
    An array of scopes for the required AccessToken.

    .PARAMETER AzureCloudInstance
    Azure instance name.

    .INPUTS
    None. You cannot pipe objects to Get-AccessTokenInteractive.

    .OUTPUTS
    It returns an AuthenticationResult.

    .EXAMPLE
    PS>Get-AccessTokenInteractive -TenantId $tenantId -ClientId $clientId -Scopes $scopes

    .EXAMPLE
    PS>Get-AccessTokenInteractive -TenantId $tenantId -ClientId $clientId -Scopes $scopes -AzureCloudInstance AzureUsGovernment
  #>
  if ($TenantId) {
    $token = Get-MsalToken -TenantId $TenantId -ClientId $ClientId -Scopes $Scopes -Interactive -AzureCloudInstance $AzureCloudInstance
  }
  else {
    $token = Get-MsalToken -ClientId $ClientId -Scopes $Scopes -Interactive -AzureCloudInstance $AzureCloudInstance
  }
  return $token
}

function Get-AccessTokenWithSecret(
  [string]$TenantId, 
  [string]$ClientId, 
  [string]$ClientSecret, 
  $Scopes, 
  [Microsoft.Identity.Client.AzureCloudInstance]$AzureCloudInstance=[Microsoft.Identity.Client.AzureCloudInstance]::AzurePublic
) {
  <#
    .SYNOPSIS
    Get AccessToken with App Secret from Azure.

    .DESCRIPTION
    This method tryies to get an AccessToken from Azure.
      
    .PARAMETER TenantId
    TenantId in Azure.

    .PARAMETER ClientId
    ClientId or AppId in Azure. It is not required if it is registered as a multiple-tenant app.

    .PARAMETER Scopes
    An array of scopes for the required AccessToken.

    .PARAMETER AzureCloudInstance
    Azure instance name.

    .INPUTS
    None. You cannot pipe objects to Get-AccessTokenWithSecret.

    .OUTPUTS
    It returns an AuthenticationResult.

    .EXAMPLE
    PS>Get-AccessTokenWithSecret -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret -Scopes $scopes

    .EXAMPLE
    PS>Get-AccessTokenWithSecret -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret -Scopes $scopes -AzureCloudInstance AzureUsGovernment
  #>
  $secret = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
  if ($TenantId) {
    $token = Get-MsalToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $secret -Scopes $Scopes -AzureCloudInstance $AzureCloudInstance
  }
  else {
    $token = Get-MsalToken -ClientId $ClientId -ClientSecret $secret -Scopes $Scopes -AzureCloudInstance $AzureCloudInstance
  }
  return $token
}

