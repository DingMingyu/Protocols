using module .\Loggers.psm1

Describe "File Logger" -Tag "Unit" {
  BeforeAll {
    $logFile = Join-Path $env:USERPROFILE "log.txt"
    if (Test-Path -Path $logFile) {
      Remove-Item -Path $logFile
    }    
  }
  It "log a message" {
    $logger = [FileLogger]::new($logFile)
    $logger.Info("1")
    Test-Path -Path $logFile | Should Be $true
    Get-Content -Path $logFile | Should Be "1"
    $logger.Info("2")
    $content = Get-Content -Path $logFile
    $content.Length | Should Be 2
    (-join $content) | Should Be "12"
    $logger.Error("3")
    $content = Get-Content -Path $logFile
    $content.Length | Should Be 5
    $content[3] | Should Be "3"
    (-join $content) | Should Be "12***************************3***************************"
  }
  AfterAll {
    if (Test-Path -Path $logFile) {
      Remove-Item -Path $logFile
    }
  }
}

Describe "Composite Logger" -Tags "Unit" {
  It "has file logger if path is not null" {
    $logger = Get-Logger -FilePath "log.txt"
    $logger.loggers.Count | Should Be 2
    $logger.loggers[1].path | Should Be "log.txt"
  }
  It "has no file logger if path is null" {
    $logger = Get-Logger
    $logger.loggers.Count | Should Be 1
  }
}