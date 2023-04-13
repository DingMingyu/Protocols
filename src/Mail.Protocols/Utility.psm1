Function IsValidEmail { 
  Param ([string] $In) 
  # Returns true if In is in valid e-mail format. 
  [system.Text.RegularExpressions.Regex]::IsMatch($In, "^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$")
}

function ParseAccessToken ($AccessToken) {
  $encodedJson = $AccessToken.Split(".")[1]
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

function BuildO365Token(
  [string]$AccessToken,
  [string]$Upn
) {
  [char]$ctrlA = 1
  $token = "user=" + $Upn + $ctrlA + "auth=Bearer " + $AccessToken + $ctrlA + $ctrlA
  $bytes = [System.Text.Encoding]::ASCII.GetBytes($token)
  $encodedToken = [Convert]::ToBase64String($bytes)
  return $encodedToken
}
