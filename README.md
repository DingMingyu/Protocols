## Mail.Protocols
The project creates a PowerShell module that helps user communicate with a mail server with various protocols, e.g. IMAP(https://tools.ietf.org/html/rfc3501) server, POP3(https://tools.ietf.org/html/rfc1081).

## Getting Started
Run the below command to install the module.
  Install-Module -Name Mail.Protocols
Please go through the scripts under .\scr\examples and you'll know how to communicate with a mail server through IMAP or POP3.
To make the examples work, you need to create .\my\MyData.psm1 in your local project folder. The file cannot be not included in the source control because it contains user info, e.g. password. The content of the file is like:

class Data {  
  [string]$Mailbox = "user@contoso.com"  
  [string]$TenantId = "465fb7e5-427e-446d-9563-e2af34ebca03"  
  [string]$ClientId = "74ca23cd-ce6f-4f57-9f73-d2cde0cdbe6f"  
  [string]$ClientSecret = "HJkfdsadfsapIHOJIfdsaf"  
  [string]$Password = "Password1@#"  
}  
  
function Get-MyData() {  
  return [Data]::new()  
}  
  
## Test
  Invoke-Pester
