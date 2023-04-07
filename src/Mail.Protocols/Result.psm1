class Result {
  [bool]$Success
  [string]$Payload
  [string]$ErrorMessage
  Result([bool]$success, [string]$payload, [string]$errorMessage) {
    $this.Success = $success
    $this.Payload = $payload
    $this.ErrorMessage = $errorMessage
  }
}

function  Get-Result(
  [bool]$Success,
  [string]$Payload,
  [string]$ErrorMessage = ""
) {
  <#
    .SYNOPSIS
    Result of IMAP or POP operation.

    .DESCRIPTION
    This function returns a result object.
      
    .PARAMETER Success
    Indicating if the operation is successful.

    .PARAMETER Payload
    The content of the result of the operation.
    
    .PARAMETER ErrorMessage
    Error message of the operation, if any.

    .INPUTS
    None. You cannot pipe objects to Get-Result

    .OUTPUTS
    It returns a result object.

    .EXAMPLE
    PS>$result = Get-Result -Success $true -Payload "The operation is successful."
    
    .EXAMPLE
    PS>$result = Get-Result -Success $false -Payload "Work in process..." -ErrorMessage "Something is wrong."
  #>
  return [Result]::new($Success, $Payload, $ErrorMessage)    
}