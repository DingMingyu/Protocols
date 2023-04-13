using module .\Analyzers.psm1
using module .\AzureSettings.psm1
using module .\STcpClient.psm1
using module .\PopClient.psm1
using module .\Tokens.psm1
using module .\Result.psm1
using module .\Loggers.psm1

function Test-MsPop (
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
    Test Microsot Exchange's POP service's connectivity.
    .DESCRIPTION
    This method tests Microsot Exchange's POP service's connectivity.
    
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
    The log file path of the test. Default is "logs\POP_{0:yyyyMMdd}.log" -f (Get-Date)

    .INPUTS
    None. You cannot pipe objects to Test-MsPop.

    .OUTPUTS
    None. It will display the result in text.

    .EXAMPLE
    PS>Test-MsPop -Mailbox user@contoso.com -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret

    .EXAMPLE
    PS>Test-MsPop -Mailbox user@contoso.com -Pass Password1@#

    .EXAMPLE
    PS>Test-MsPop -Mailbox user@contoso.gov -TenantId $tenantId -ClientId $clientId -AzureCloudInstance AzureUsGovernment
  #>
  $server = Get-OutlookEndpoint -AzureCloudInstance $AzureCloudInstance
  $port = Get-Port -AppName "POP"

  if ($ClientSecret) {
    $scopes = @(Get-Scope -AppName "POP" -AccessType "AsApp" -AzureCloudInstance $AzureCloudInstance)
  }
  else {
    $scopes = @(Get-Scope -AppName "POP" -AccessType "AsUser" -AzureCloudInstance $AzureCloudInstance)
  }

  if (!$LogPath) {
    $LogPath = "logs\imap_{0:yyyyMMdd}.log" -f (Get-Date)
  }

  $logger = Get-Logger -FilePath $LogPath
  $client = Get-TcpClient -Server $server -Port $port -Logger $logger
  $pop = Get-PopClient -TcpClient $client

  $pop.Connect()

  if ($Pass) {
    # basic auth
    $result = $pop.Login($Mailbox, $Pass)
  }
  else {
    if ($ClientSecret) { # App flow
      $token = Get-AccessTokenWithSecret -TenantId $TenantId -ClientId $ClientId -Scopes $scopes -ClientSecret $ClientSecret -AzureCloudInstance $AzureCloudInstance
      $accessType = "AsApp"
    }
    else { # User delegation flow
      $token = Get-AccessTokenInteractive -TenantId $TenantId -ClientId $ClientId -Scopes $scopes -AzureCloudInstance $AzureCloudInstance
      $accessType = "AsUser"
    }
    $result = $pop.O365Authenticate($token.AccessToken, $Mailbox)
    if (!$result.Success) {
      $aud = Get-Aud -AzureCloudInstance $AzureCloudInstance
      $scp = Get-Scp -AppName "POP" -AccessType $accessType
      $analyzer = Get-Analyzer -Name "AccessTokenAnalyzer"
      if ($analyzer) {
        $analyses = $analyzer.Analyze($Mailbox, $token.AccessToken, $scp, $aud)
        $analyses | ForEach-Object { $logger.Info($_) }
      }
    }
  }
  if ($result.Success) {
    $result = $pop.ExecuteCommand('LIST')
  }
  $pop.Close()
  if ($result.Success) {
    $msg = "POP connection is successful for mailbox '{0}' on server '{1}' and port {2}." -f $Mailbox, $server, $port
    Write-Host $msg
  }
  else {
    $msg = "Something is wrong. Please review the log {0}." -f $LogPath
    Write-Warning $msg
  }
}