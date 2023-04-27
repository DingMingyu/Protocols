using module .\Utility.psm1

class AccessTokenAnalyzer {
  $utility
  AccessTokenAnalyzer() {
    $this.utility = Get-Utility
  }
  [System.Collections.Generic.List[string]]Analyze (
    [string]$upn,
    [string]$accessToken,
    [string]$scope,
    [string]$audience
  ) {
    $results = [System.Collections.Generic.List[string]]::new()
    
    $token = $this.utility.ParseAccessToken($accessToken)
    if ($token.aud -ne $audience) {
      $msg = "The AccessToken is issued for audience {0}, not {1} as expected." -f $token.aud, $audience
      $results.Add($msg)
      return $results
    }
    if ($token.roles) { # As App
      if (!$token.roles.Contains($scope)) {
        $msg = "The AccessToken's roles are '{0}', which doesn't have the required scope '{1}'." -f ($token.roles -join ","), $scope 
        $results.Add($msg)
      }
      $msg = "The AccessToken's oid is {0} and appId is {1}. Please make sure you have a service principal in Exchange with the same Ids, " -f $token.oid, $token.appid
      $msg += "and the service principal has been granted access to the target mailbox {0}, as described on " -f  $upn
      $msg += "https://learn.microsoft.com/en-us/exchange/client-developer/legacy-protocols/how-to-authenticate-an-imap-pop-smtp-application-by-using-oauth."
      $results.Add($msg)
    }
    elseif ($token.scp) { # As User
      if (!$token.scp.Split(" ").Contains($scope)) {
        $msg = "The AccessToken's scp is '{0}', which doesn't have the required scope '{1}'." -f $token.scp, $scope
        $results.Add($msg)
      }
      if ($token.upn -ne $upn) {
        $msg = "The AccessToken is issued for {0}, while the target mailbox is {1}. Please make sure the user has permission to access it." -f $token.upn, $upn
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
