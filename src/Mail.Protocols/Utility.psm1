class Utility {
  [bool]IsValidEmail([string]$text) { 
    return [system.Text.RegularExpressions.Regex]::IsMatch($text, "^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$")
  }

  [object]ParseAccessToken([string]$accessToken) {
    $encodedJson = $accessToken.Split(".")[1]
    $n = $encodedJson.Length % 4
    if ($n -eq 0) {
      $length = $encodedJson.Length
    }
    else {
      $length = $encodedJson.Length + 4 - $n
    }
    $encodedJson = $encodedJson.PadRight($length, "=")
    $token = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($encodedJson)) | ConvertFrom-Json
    return $token
  }

  [string]BuildO365Token([string]$accessToken, [string]$upn) {
    [char]$ctrlA = 1
    $token = "user=" + $upn + $ctrlA + "auth=Bearer " + $accessToken + $ctrlA + $ctrlA
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($token)
    $encodedToken = [Convert]::ToBase64String($bytes)
    return $encodedToken
  }
}

function  Get-Utility() {
  return [Utility]::new()
}
