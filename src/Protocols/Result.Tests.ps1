using module .\Result.psm1

Describe "Result" -Tags "Unit" {
  It "get result object" {
    $payload = "This is a test"
    $result = Get-Result -Success $true -Payload $payload
    $result.Success | Should be $true
    $result.Payload | Should be $payload
    $result.ErrorMessage | Should be ""
  }
  It "can set error message" {
    $payload = "This is a test"
    $errorMessage = "Something went wrong."
    $result = Get-Result -Success $false -Payload $payload -ErrorMessage $errorMessage
    $result.Success | Should be $false
    $result.Payload | Should be $payload
    $result.ErrorMessage | Should be $errorMessage
  }
}