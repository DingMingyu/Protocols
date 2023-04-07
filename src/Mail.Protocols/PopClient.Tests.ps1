using module .\PopClient.psm1
using module .\DummyTcpClient.psm1

Describe "PopClient" -Tags "Unit" {
  It "connect socket when Connect is called" {
    $client = Get-DummyTcpClient
    $pop = Get-PopClient -TcpClient $client
    $pop.Connect()
    $client.logs.Count | Should be 1
    $client.logs[0] | Should be "S connected"
  }
  It "close socket when Close is called" {
    $client = Get-DummyTcpClient
    $pop = Get-PopClient -TcpClient $client
    $pop.Close()
    $client.logs.Count | Should be 1
    $client.logs[0] | Should be "S closed"
  }
  It "execute to send command to socket and wait for response" {
    $client = Get-DummyTcpClient
    $pop = Get-PopClient -TcpClient $client
    $cmd = "do something"
    $response = "+OK"
    $client.responses.Add($response)
    $result = $pop.ExecuteCommand($cmd)
    $result.Success | Should be $true
    $result.Payload | Should be $response
    $result.ErrorMessage | Should be ""
    $client.requests.Count | Should be 1
    $client.requests[0] | Should be $cmd
    $client.logs.Count | Should be 2
    $client.logs[0] | Should be "C $cmd"
    $client.logs[1] | Should be "S $response"
  }
  It "execute fail if the response is not OK" {
    $client = Get-DummyTcpClient
    $pop = Get-PopClient -TcpClient $client
    $cmd = "do something"
    $response = "-ERR"
    $client.responses.Add($response)
    $result = $pop.ExecuteCommand($cmd)
    $result.Success | Should be $false
    $result.Payload | Should be $response
    $result.ErrorMessage | Should be 'POP should return "+" for successful command handling.'
    $client.requests.Count | Should be 1
    $client.requests[0] | Should be $cmd
    $client.logs.Count | Should be 2
    $client.logs[0] | Should be "C $cmd"
    $client.logs[1] | Should be "S $response"
  }
  It "O365Authenticate with token and upn" {
    $client = Get-DummyTcpClient
    $pop = Get-PopClient -TcpClient $client
    $token = "pseudoToken"
    $upn = "user@contoso.com"
    $client.responses.Add("+")
	  $success = "+OK User successfully authenticated."
	  $client.responses.Add($success)
    $result = $pop.O365Authenticate($token, $upn)
    $result.Success | Should be $true
    $ot = Get-O365Token -AccessToken $token -Upn $upn
    $client.requests.Count | Should be 2
    $client.requests[0] | Should be "AUTH XOAUTH2"
	  $client.requests[1] | Should be $ot
  }
  It "Login with user and pass" {
    $client = Get-DummyTcpClient
    $pop = Get-PopClient -TcpClient $client
    $pass = "Password12#"
    $user = "user@contoso.com"
    $client.responses.Add("+")
	  $success = "+OK User login successfully."
	  $client.responses.Add($success)
    $result = $pop.Login($user, $pass)
    $result.Success | Should be $true
    $client.requests.Count | Should be 2
    $client.requests[0] | Should be "USER $user"
    $client.requests[1] | Should be "PASS $pass"
    $client.logs.Count | Should be 4
    $client.logs[0] | Should be "C USER $user"
    $client.logs[1] | Should be "S +"
    $client.logs[2] | Should be "C PASS ****"
    $client.logs[3] | Should be "S $success"
  }
}