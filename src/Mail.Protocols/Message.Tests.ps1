using module .\Message.psm1

Describe "Message Class" -Tag "Unit" {
  It "uses the current time" {
    $msg = Get-Message -From "C" -Text "A test message"
    $now = [datetime]::Now
    (($msg.timeStamp - $now).TotalSeconds -lt 1) | Should Be $true
  }
  
  It "convert to string" {
    $now = [datetime]::Now
    $msg = Get-Message -From "C" -Text "A test message"
    $msg.timeStamp = $now
    $str = "{0} {1} {2}" -f $now.ToString("O"), $msg.from, $msg.text
    $msg.ToString() | Should Be $str
  }
}