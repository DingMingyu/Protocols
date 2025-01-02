using module .\UserInputAssistant.psm1

Describe "UserInputAssistant" -Tags "Unit" {
  It "Get-UserInputAssistant return the object of type [UserInputAssistant]" {
    $obj = Get-UserInputAssistant
    $obj.GetAzureCloudInstance.GetType().Name | Should be "PSMethod``1"
    $obj.GetAuthType.GetType().Name | Should be "PSMethod``1"
    $obj.GetMailbox.GetType().Name | Should be "PSMethod``1"
    $obj.GetPassword.GetType().Name | Should be "PSMethod``1"
    $obj.GetLoginUser.GetType().Name | Should be "PSMethod``1"
    $obj.GetLogPath.GetType().Name | Should be "PSMethod``1"
    $obj.GetFlowType.GetType().Name | Should be "PSMethod``1"
    $obj.GetTenantId.GetType().Name | Should be "PSMethod``1"
    $obj.GetClientId.GetType().Name | Should be "PSMethod``1"
    $obj.GetClientSecret.GetType().Name | Should be "PSMethod``1"
  }
}
