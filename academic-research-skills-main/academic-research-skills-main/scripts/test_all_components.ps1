# test_all_components.ps1
param([string]$filter = "")

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

$resultsDir = Join-Path $ProjectRoot "test-results"
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
}

$claudeExe = "$env:USERPROFILE\.local\bin\claude.exe"

function Execute-Test([string]$TestId, [string]$Component, [string]$Description, [string]$PromptText) {
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "RUNNING [$TestId]: $Component - $Description" -ForegroundColor Cyan
    Write-Host "==========================================================" -ForegroundColor Gray

    $outFile = Join-Path $resultsDir "$TestId.log"
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    
    $procInfo = New-Object System.Diagnostics.ProcessStartInfo
    $procInfo.FileName = $claudeExe
    $procInfo.Arguments = "-p `"$PromptText`" --model gemini-3.1-flash-lite --effort low --dangerously-skip-permissions"
    $procInfo.RedirectStandardInput = $true
    $procInfo.RedirectStandardOutput = $true
    $procInfo.RedirectStandardError = $true
    $procInfo.UseShellExecute = $false
    $procInfo.WorkingDirectory = $ProjectRoot

    $proc = [System.Diagnostics.Process]::Start($procInfo)
    $proc.StandardInput.Close() # Send EOF immediately so no stdin delay

    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()
    $sw.Stop()

    $exitCode = $proc.ExitCode
    $combined = "STDOUT:`n$stdout`n`nSTDERR:`n$stderr`n`nEXIT_CODE: $exitCode`nELAPSED_MS: $($sw.ElapsedMilliseconds)"
    Set-Content -Path $outFile -Value $combined -Encoding UTF8

    Write-Host "Finished in $($sw.ElapsedMilliseconds) ms with Exit Code: $exitCode" -ForegroundColor $(if ($exitCode -eq 0) { "Green" } else { "Red" })
    if ($exitCode -ne 0) {
        Write-Host "STDERR: $stderr" -ForegroundColor Yellow
    }
    
    return [PSCustomObject]@{
        TestId = $TestId
        Component = $Component
        Description = $Description
        ExitCode = $exitCode
        ElapsedMs = $sw.ElapsedMilliseconds
        StdOut = $stdout
        StdErr = $stderr
    }
}

# Export function

