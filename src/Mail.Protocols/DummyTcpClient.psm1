class DummyTcpClient {
  $requests = [System.Collections.Generic.List[string]]::new()
  $responses = [System.Collections.Generic.List[string]]::new()
  $logs = [System.Collections.Generic.List[string]]::new()

  [void]Connect() {
    $this.LogResponse("connected")
  }

  [void]Close() {
    $this.LogResponse("closed")
  }
 
  [void]SubmitRequest([string]$cmd) {
    $this.SubmitRequest($cmd, $cmd)
  }

  [void]SubmitRequest([string]$cmd, [string]$log) {
    $this.requests.Add($cmd)
    $this.LogRequest($log)
  }

  [string]ReadResponse([bool]$shouldLog) {
    $response = $this.responses[0]
    $this.responses.RemoveAt(0)
    if ($shouldLog) {
      $this.LogResponse($response)
    }
    return $response
  }
  [void]LogResponse([string]$text) {
    $this.logs.Add("S $text")
  }
  [void]LogRequest([string]$text) {
    $this.logs.Add("C $text")
  }
}

function  Get-DummyTcpClient {
  return [DummyTcpClient]::new()
}