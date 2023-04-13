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
    This method tries to get an AccessToken from Azure.
      
    .PARAMETER TenantId
    TenantId in Azure. It is not required if the app is registered as a multiple-tenant app.

    .PARAMETER ClientId
    ClientId or AppId in Azure.

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
    This method tries to get an AccessToken from Azure.
      
    .PARAMETER TenantId
    TenantId in Azure. It is not required if the app is registered as a multiple-tenant app.

    .PARAMETER ClientId
    ClientId or AppId in Azure.

    .PARAMETER ClientSecret
    The secret of the registered app.

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

