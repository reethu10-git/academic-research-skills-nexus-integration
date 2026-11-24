# test_phase2_runner.ps1
$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
Set-Location $ProjectRoot

# Load .env
$envFile = Join-Path $ProjectRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -match '^\s*([^#=]+)\s*=\s*(.*)$' } | ForEach-Object {
        $varName = $matches[1].Trim()
        $varVal = $matches[2].Trim()
        if ($varVal -match '^["''](.*)["'']$') { $varVal = $matches[1] }
        if (-not [string]::IsNullOrWhiteSpace($varName) -and -not [string]::IsNullOrWhiteSpace($varVal)) {
            [Environment]::SetEnvironmentVariable($varName, $varVal, "Process")
        }
    }
}

$resultsDir = Join-Path $ProjectRoot "test-results\phase2"
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
}

$claudeExe = "$env:USERPROFILE\.local\bin\claude.exe"

function Execute-Phase2Test([string]$TestId, [string]$Category, [string]$Description, [string]$PromptText) {
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "RUNNING [$TestId]: $Category - $Description" -ForegroundColor Cyan
    Write-Host "==========================================================" -ForegroundColor Gray

    $outFile = Join-Path $resultsDir "$TestId.log"
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    
    $procInfo = New-Object System.Diagnostics.ProcessStartInfo
    $procInfo.FileName = $claudeExe
    $activeModel = if ($env:ANTHROPIC_MODEL) { $env:ANTHROPIC_MODEL } else { "claude-haiku-4-5" }
    $procInfo.Arguments = "-p `"$PromptText`" --model $activeModel --effort low --dangerously-skip-permissions"
    $procInfo.RedirectStandardInput = $true
    $procInfo.RedirectStandardOutput = $true
    $procInfo.RedirectStandardError = $true
    $procInfo.UseShellExecute = $false
    $procInfo.WorkingDirectory = $ProjectRoot

    $proc = [System.Diagnostics.Process]::Start($procInfo)
    $proc.StandardInput.Close()

    # Read asynchronously to prevent OS pipe deadlock
    $stdOutTask = $proc.StandardOutput.ReadToEndAsync()
    $stdErrTask = $proc.StandardError.ReadToEndAsync()
    
    $exited = $proc.WaitForExit(360000)
    if (-not $exited) {
        Write-Host "Process timed out after 360 seconds. Terminating..." -ForegroundColor Red
        try { $proc.Kill() } catch {}
    }
    $sw.Stop()

    $stdout = $stdOutTask.Result
    $stderr = $stdErrTask.Result
    $exitCode = if ($exited) { $proc.ExitCode } else { 124 }
    
    $combined = "TEST_ID: $TestId`nCATEGORY: $Category`nDESCRIPTION: $Description`nEXIT_CODE: $exitCode`nELAPSED_MS: $($sw.ElapsedMilliseconds)`n`nSTDOUT:`n$stdout`n`nSTDERR:`n$stderr"
    Set-Content -Path $outFile -Value $combined -Encoding UTF8

    Write-Host "Finished in $($sw.ElapsedMilliseconds) ms with Exit Code: $exitCode" -ForegroundColor $(if ($exitCode -eq 0) { "Green" } else { "Red" })
    if ($exitCode -ne 0) {
        Write-Host "STDERR: $stderr" -ForegroundColor Yellow
    }
    
    return [PSCustomObject]@{
        TestId = $TestId
        Category = $Category
        Description = $Description
        ExitCode = $exitCode
        ElapsedMs = $sw.ElapsedMilliseconds
        StdOut = $stdout
        StdErr = $stderr
    }
}

