class Message {
  [string]$from
  [string]$text
  [datetime]$timeStamp = [datetime]::Now
  Message([string]$from, [string]$text) {
    $this.from = $from
    $this.text = $text
  }
  [string]ToString() {
    return "{0} {1} {2}" -f $this.timeStamp.ToString("O"), $this.from, $this.text
  }
}

function Get-Message(
  [string]$From, 
  [string]$Text
) {
  <#
    .SYNOPSIS
    Message object for logging.

    .DESCRIPTION
    This function returns a message object for logging.
      
    .PARAMETER From
    From where the message is sent.

    .PARAMETER Text
    The content of the message.
    
    .INPUTS
    None. You cannot pipe objects to Message

    .OUTPUTS
    It returns a Message object.

    .EXAMPLE
    PS>$msg = Get-Message -From "C" -Payload "The command Open File is sent to server."
    
    .EXAMPLE
    PS>$msg = Get-Message -From "S" -Payload "Server responds the operation is successful."
  #>
  return [Message]::new($From, $Text)
}
