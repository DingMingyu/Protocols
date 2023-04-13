using module .\UserInputAssistant.psm1

Describe "UserInputAssistant" -Tags "Unit" {
  It "Get-UserInputAssistant return the object of type [UserInputAssistant]" {
    $obj = Get-UserInputAssistant
    $obj.GetAzureCloudInstance.GetType().Name | Should be "PSMethod"
    $obj.GetAuthType.GetType().Name | Should be "PSMethod"
    $obj.GetMailbox.GetType().Name | Should be "PSMethod"
    $obj.GetPassword.GetType().Name | Should be "PSMethod"
    $obj.GetLogPath.GetType().Name | Should be "PSMethod"
    $obj.GetFlowType.GetType().Name | Should be "PSMethod"
    $obj.GetTenantId.GetType().Name | Should be "PSMethod"
    $obj.GetClientId.GetType().Name | Should be "PSMethod"
    $obj.GetClientSecret.GetType().Name | Should be "PSMethod"
  }
}
