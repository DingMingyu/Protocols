class ConsoleLogger {
  [void]Info($msg) {
    Write-Host $msg
  }
  [void]Error($msg) {
    Write-Error $msg
  }
}

class FileLogger {
  [string]$path
  FileLogger([string]$path) {
    $this.path = $path
    $folder = Split-Path -Path $path
    if ($folder -and !(Test-Path -Path $folder)) {
      $null = New-Item -ItemType Directory -Path $folder
    }
  }
  [void]Info($msg) {
    Add-Content -Path $this.path -Value $msg
  }
  [void]Error($msg) {
    Add-Content -Path $this.path -Value "***************************"
    $this.Info($msg)
    Add-Content -Path $this.path -Value "***************************"
  }
}

class CompositeLogger {
  $loggers = [System.Collections.ArrayList]::new()

  [void]AddLogger($logger) {
    $this.loggers.Add($logger)
  }

  [void]Info($msg) {
    foreach ($logger in $this.loggers) {
      $logger.Info($msg)
    }
  }
  [void]Error($msg) {
    foreach ($logger in $this.loggers) {
      $logger.Error($msg)
    }
  }
}
function Get-Logger([string]$FilePath = $null) {
  <#
    .SYNOPSIS
    Get Logger object.

    .DESCRIPTION
    This function returns a logger object.
      
    .PARAMETER FilePath
    File path for file log. If it is empty, the logger object doesn't write log to file.

    .INPUTS
    None. You cannot pipe objects to Get-Logger

    .OUTPUTS
    It returns an logger object.

    .EXAMPLE
    PS>Get-Logger
    
    .EXAMPLE
    PS>$logFile = "c:\logs\pop_{0:yyyyMMdd}.log" -f (Get-Date)
    PS>$logger = Get-Logger -FilePath $logFile
  #>
  $logger = [CompositeLogger]::new()
  $logger.AddLogger([ConsoleLogger]::new())
  if ($FilePath) {
    $logger.AddLogger([FileLogger]::new($FilePath))
  }
  return $logger  
}
