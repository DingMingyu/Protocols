using module .\ImapClient.psm1
using module .\DummyTcpClient.psm1

Describe "ImapClient" -Tags "Unit" {
  It "update tag number on each call" {
    $client = [DummyTcpClient]::new()
    $imap = Get-ImapClient -TcpClient $client
    $tag = $imap.getTagText()
    $tag | Should be "0000"
    $response = "0001 OK"
    $client.responses.Add($response)
    $imap.ExecuteCommand("dummy")
    $tag = $imap.getTagText()
    $tag | Should be "0001"
  }
  It "connect socket when Connect is called" {
    $client = Get-DummyTcpClient
    $imap = Get-ImapClient -TcpClient $client
    $imap.Connect()
    $client.logs.Count | Should be 1
    $client.logs[0] | Should be "S connected"
  }
  It "close socket when Close is called" {
    $client = Get-DummyTcpClient
    $imap = Get-ImapClient -TcpClient $client
    $imap.Close()
    $client.logs.Count | Should be 1
    $client.logs[0] | Should be "S closed"
  }
  It "execute to send command to socket and wait for response" {
    $client = Get-DummyTcpClient
    $imap = Get-ImapClient -TcpClient $client
    $cmd = "do something"
    $response = "0001 OK"
    $client.responses.Add($response)
    $result = $imap.ExecuteCommand($cmd)
    $result.Success | Should be $true
    $result.Payload | Should be $response
    $result.ErrorMessage | Should be ""
    $client.requests.Count | Should be 1
    $client.requests[0] | Should be "0001 $cmd"
    $client.logs.Count | Should be 2
    $client.logs[0] | Should be "C 0001 $cmd"
    $client.logs[1] | Should be "S $response"
  }
  It "execute fail if the response is not OK" {
    $client = Get-DummyTcpClient
    $imap = Get-ImapClient -TcpClient $client
    $cmd = "do something"
    $response = "0001 No"
    $client.responses.Add($response)
    $result = $imap.ExecuteCommand($cmd)
    $result.Success | Should be $false
    $result.Payload | Should be $response
    $result.ErrorMessage | Should be 'IMAP should return "OK" for successful command handling.'
    $client.requests.Count | Should be 1
    $client.requests[0] | Should be "0001 $cmd"
    $client.logs.Count | Should be 2
    $client.logs[0] | Should be "C 0001 $cmd"
    $client.logs[1] | Should be "S $response"
  }
  It "save file by call append command" {
    $client = Get-DummyTcpClient
    $imap = Get-ImapClient -TcpClient $client
    $hint = "+ Ready for additional command text."
    $client.responses.Add($hint)
    $res = "0001 OK [APPENDUID 17 25] APPEND completed."
    $client.responses.Add($res)
    $msg = "A pseudo mail"
    $result = $imap.SaveEmail("drafts", $msg)
    $result.Success | Should be $true
    $result.Payload | Should be $res
    $result.ErrorMessage | Should be ""
    $client.requests.Count | Should be 2
    $cmd = "0001 APPEND drafts {" + $msg.Length + "}"
    $client.requests[0] | Should be $cmd
    $client.requests[1] | Should be $msg
    $client.logs.Count | Should be 4
    $client.logs[0] | Should be "C $cmd"
    $client.logs[1] | Should be "S $hint"
    $client.logs[2] | Should be "C $msg"
    $client.logs[3] | Should be "S $res"
  }
  It "fail to save file if return unexpected result" {
    $client = Get-DummyTcpClient
    $imap = Get-ImapClient -TcpClient $client
    $hint = "+ Not ready"
    $client.responses.Add($hint)
    $res = "0001 OK [APPENDUID 17 25] APPEND completed."
    $client.responses.Add($res)
    $msg = "A pseudo mail"
    $result = $imap.SaveEmail("drafts", $msg)
    $result.Success | Should be $false
    $result.Payload | Should be $hint
    $result.ErrorMessage | Should be 'IMAP should return "+ Ready for additional command text." for append command.'
    $client.requests.Count | Should be 1
    $cmd = "0001 APPEND drafts {" + $msg.Length + "}"
    $client.requests[0] | Should be $cmd
    $client.logs.Count | Should be 2
    $client.logs[0] | Should be "C $cmd"
    $client.logs[1] | Should be "S $hint"
  }
  It "O365Authenticate with token and upn" {
    $client = Get-DummyTcpClient
    $imap = Get-ImapClient -TcpClient $client
    $token = "pseudoToken"
    $upn = "user@contoso.com"
    $success = "0001 OK AUTHENTICATE completed."
    $client.responses.Add($success)
    $result = $imap.O365Authenticate($token, $upn)
    $result.Success | Should be $true
    $ot = Get-O365Token -AccessToken $token -Upn $upn
    $cmd = "0001 AUTHENTICATE XOAUTH2 $ot"
    $client.requests.Count | Should be 1
    $client.requests[0] | Should be $cmd
  }
  It "Login with user and pass" {
    $client = Get-DummyTcpClient
    $imap = Get-ImapClient -TcpClient $client
    $pass = "Password12#"
    $user = "user@contoso.com"
    $success = "0001 OK Login completed."
    $client.responses.Add($success)
    $result = $imap.Login($user, $pass)
    $result.Success | Should be $true
    $cmd = "0001 LOGIN $user $pass"
    $client.requests.Count | Should be 1
    $client.requests[0] | Should be $cmd
    $client.logs.Count | Should be 2
    $client.logs[0] | Should be "C 0001 LOGIN $user ****"
    $client.logs[1] | Should be "S $success"
  }
}