class Constants {
  $EndPoint_Outlook_WW = "outlook.office365.com"
  $EndPoint_Outlook_CN = "partner.outlook.cn"
  $EndPoint_Outlook_US = "outlook.office365.us"

  $Scope_Outlook_IMAP_User_WW = "https://outlook.office.com/IMAP.AccessAsUser.All"
  $Scope_Outlook_IMAP_App_WW = "https://outlook.office365.com/.default"
  $Scope_Outlook_POP_User_WW = "https://outlook.office365.com/POP.AccessAsUser.All"
  $Scope_Outlook_POP_App_WW = "https://outlook.office365.com/.default"

  $Scope_Outlook_IMAP_User_CN = "https://partner.outlook.cn/IMAP.AccessAsUser.All"
  $Scope_Outlook_IMAP_App_CN = "https://partner.outlook.cn/.default"
  $Scope_Outlook_POP_User_CN = "https://partner.outlook.cn/POP.AccessAsUser.All"
  $Scope_Outlook_POP_App_CN = "https://partner.outlook.cn/.default"

  $Scope_Outlook_IMAP_User_US = "https://outlook.office.us/IMAP.AccessAsUser.All"
  $Scope_Outlook_IMAP_App_US = "https://outlook.office365.us/.default"
  $Scope_Outlook_POP_User_US = "https://outlook.office365.us/POP.AccessAsUser.All"
  $Scope_Outlook_POP_App_US = "https://outlook.office365.us/.default"

  $Port_IMAP = 993
  $Port_POP = 995
}

function  Get-Constants {
  <#
    .SYNOPSIS
    Get pre-defined constants for the module.

    .DESCRIPTION
    Get pre-defined constants for the module.
      
    .PARAMETER AccessToken
    An object with various contant string values.

    .INPUTS
    None. You cannot pipe objects to Get-Constants

    .OUTPUTS
    An object with constants.

    .EXAMPLE
    PS>Get-Constants
  #>
  return [Constants]::new()
}
