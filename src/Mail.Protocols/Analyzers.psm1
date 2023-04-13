using module .\Utility.psm1

class AccessTokenAnalyzer {
  [System.Collections.Generic.List[string]]Analyze (
    [string]$Upn,
    [string]$AccessToken,
    [string]$Scope,
    [string]$Audience
  ) {
    $results = [System.Collections.Generic.List[string]]::new()
    
    $token = ParseAccessToken -AccessToken $AccessToken
    if ($token.aud -ne $Audience) {
      $msg = "The AccessToken is issued for audience {0}, not {1} as expected." -f $token.aud, $Audience
      $results.Add($msg)
      return $results
    }
    if ($token.roles) { # As App
      if (!$token.roles.Contains($Scope)) {
        $msg = "The AccessToken's roles are '{0}', which doesn't have the required scope '{1}'." -f ($token.roles -join ","), $Scope 
        $results.Add($msg)
      }
      $msg = "The AccessToken's oid is {0} and appId is {1}. Please make sure you have a service principal in Exchange with the same Ids, " -f $token.oid, $token.appid
      $msg += "and the service principal has been granted access to the target mailbox {0}, as described on " -f  $Upn
      $msg += "https://learn.microsoft.com/en-us/exchange/client-developer/legacy-protocols/how-to-authenticate-an-imap-pop-smtp-application-by-using-oauth."
      $results.Add($msg)
    }
    elseif ($token.scp) { # As User
      if (!$token.scp.Split(" ").Contains($Scope)) {
        $msg = "The AccessToken's scp is '{0}', which doesn't have the required scope '{1}'." -f $token.scp, $Scope
        $results.Add($msg)
      }
      if ($token.upn -ne $Upn) {
        $msg = "The AccessToken is issued for {0}, while the target mailbox is {1}. Please make sure the user has permission to access it." -f $token.upn, $Upn
        $results.Add($msg)
      }
    }
    else {
      $results.Add("It is not a valid AccessToken. A valid AccessToken must have either a roles or scp claim.")
    }
    return $results
  }
}

function  Get-Analyzer([string]$Name){
 switch ($Name) {
  "AccessTokenAnalyzer" {
    return [AccessTokenAnalyzer]::new()
  }
 } 
}
