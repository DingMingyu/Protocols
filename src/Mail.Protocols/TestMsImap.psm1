using module .\Constants.psm1
using module .\STcpClient.psm1
using module .\ImapClient.psm1
using module .\Tokens.psm1
using module .\Result.psm1

function Test-MsImap (
  [string]$Mailbox,
  [string]$TenantId = "",
  [string]$ClientId = "",
  [string]$ClientSecret = "",
  [string]$Pass = "",
  [Microsoft.Identity.Client.AzureCloudInstance]$AzureCloudInstance=[Microsoft.Identity.Client.AzureCloudInstance]::AzurePublic,
  [string]$LogPath = ""
) {
  <#
    .SYNOPSIS
    Test Microsot Exchange's IMAP service's connectivity.
    .DESCRIPTION
    This method tests Microsot Exchange's IMAP service's connectivity.
    
    .PARAMETER Mailbox
    Mailbox to connect.

    .PARAMETER TenantId
    TenantId in Azure. It is not required if the app is registered as a multiple-tenant app.

    .PARAMETER ClientId
    ClientId or AppId in Azure.

    .PARAMETER ClientSecret
    The secret of the registered app.

    .PARAMETER Pass
    The password for basic authentication.

    .PARAMETER AzureCloudInstance
    Azure instance name.

    .PARAMETER LogPath
    The log file path of the test. Default is "logs\IMAP_{0:yyyyMMdd}.log" -f (Get-Date)

    .INPUTS
    None. You cannot pipe objects to Test-MsImap.

    .OUTPUTS
    None. It will display the result in text.

    .EXAMPLE
    PS>Test-MsImap -Mailbox user@contoso.com -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret

    .EXAMPLE
    PS>Test-MsImap -Mailbox user@contoso.com -Pass Password1@#

    .EXAMPLE
    PS>Test-MsImap -Mailbox user@contoso.gov -TenantId $tenantId -ClientId $clientId -AzureCloudInstance AzureUsGovernment
  #>
  $constants = Get-Constants
  if ($AzureCloudInstance -eq [Microsoft.Identity.Client.AzureCloudInstance]::AzureGermany) {
    throw "AzureGermany has stopped service."
  }
  elseif ($AzureCloudInstance -eq [Microsoft.Identity.Client.AzureCloudInstance]::AzureChina) {
    $server = $constants.EndPoint_Outlook_CN
    if ($ClientSecret) {
      $scopes = @($constants.Scope_Outlook_IMAP_App_CN)
    }
    else {
      $scopes = @($constants.Scope_Outlook_IMAP_User_CN)
    }
  }
  elseif ($AzureCloudInstance -eq [Microsoft.Identity.Client.AzureCloudInstance]::AzurePublic) {
    $server = $constants.EndPoint_Outlook_WW
    if ($ClientSecret) {
      $scopes = @($constants.Scope_Outlook_IMAP_App_WW)
    }
    else {
      $scopes = @($constants.Scope_Outlook_IMAP_User_WW)
    }
  }
  elseif ($AzureCloudInstance -eq [Microsoft.Identity.Client.AzureCloudInstance]::AzureUsGovernment) {
    $server = $constants.EndPoint_Outlook_US
    if ($ClientSecret) {
      $scopes = @($constants.Scope_Outlook_IMAP_App_US)
    }
    else {
      $scopes = @($constants.Scope_Outlook_IMAP_User_US)
    }
  }
  else {
    throw "Unknown Azure Instance: {0}" -f $AzureCloudInstance
  }

  if (!$LogPath) {
    $LogPath = "logs\imap_{0:yyyyMMdd}.log" -f (Get-Date)
  }

  $logger = Get-Logger -FilePath $LogPath
  $client = Get-TcpClient -Server $server -Port $constants.Port_IMAP -Logger $logger
  $imap = Get-ImapClient -TcpClient $client

  $imap.Connect()
  
  if ($Pass) {
    # basic auth
    $result = $imap.Login($Mailbox, $Pass)
  }
  else{
    if ($ClientSecret) {
      if ($TenantId) {
        $token = Get-AccessTokenWithSecret -TenantId $TenantId -ClientId $ClientId -Scopes $scopes -ClientSecret $ClientSecret -AzureCloudInstance $AzureCloudInstance
      }
      else {
        $token = Get-AccessTokenWithSecret -ClientId $ClientId  -Scopes $scopes -ClientSecret $ClientSecret -AzureCloudInstance $AzureCloudInstance
      }
    }
    else {
      if ($TenantId) {
        $token = Get-AccessTokenInteractive -TenantId $TenantId -ClientId $ClientId -Scopes $scopes -AzureCloudInstance $AzureCloudInstance
      }
      else {
        $token = Get-AccessTokenInteractive -ClientId $ClientId -Scopes $scopes -AzureCloudInstance $AzureCloudInstance
      }
    }
    $result = $imap.O365Authenticate($token.AccessToken, $Mailbox)
  }
  if ($result.Success) {
    $result = $imap.ExecuteCommand('LIST "" *')
  }
  $imap.Close()
  if ($result.Success) {
    $msg = "IMAP connection is successful for mailbox '{0}' on server '{1}' and port {2}." -f $Mailbox, $server, $constants.Port_IMAP
  }
  else {
    $msg = "Something is wrong. Please review the log {0}." -f $LogPath
  }
  Write-Host $msg
}