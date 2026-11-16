# run_verification_suite.ps1
# Automates comprehensive verification of Claude Code + Nexus API on Academic Research Skills (ARS)

$ErrorActionPreference = "Continue"

# Resolve Project Root
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

Write-Output "=== 1. CONFIGURATION CHECK ==="
Write-Output "Base URL: $env:ANTHROPIC_BASE_URL"
Write-Output "Model: $env:ANTHROPIC_MODEL"
Write-Output "Max Tokens: $env:CLAUDE_CODE_MAX_OUTPUT_TOKENS"
if ($env:ANTHROPIC_AUTH_TOKEN -and $env:ANTHROPIC_AUTH_TOKEN.StartsWith("sk-")) {
    Write-Output "Auth Token: Present (Valid sk- prefix, length: $($env:ANTHROPIC_AUTH_TOKEN.Length))"
} else {
    Write-Output "Auth Token: INVALID or MISSING"
}

# Resolve Claude Code
$claudeCmd = Get-Command "claude" -ErrorAction SilentlyContinue
if ($claudeCmd) {
    $claudeExe = $claudeCmd.Source
} elseif (Test-Path "$env:USERPROFILE\.local\bin\claude.exe") {
    $claudeExe = "$env:USERPROFILE\.local\bin\claude.exe"
} else {
    Write-Error "claude.exe not found"
    exit 1
}
Write-Output "Claude Executable: $claudeExe"

function Run-ClaudePrompt([string]$promptName, [string]$promptText) {
    Write-Output "`n========================================================"
    Write-Output "TEST: $promptName"
    Write-Output "========================================================"
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        # Using empty input pipe to avoid stdin timeout
        $output = "" | & $claudeExe -p $promptText --model gemini-3.1-flash-lite --effort low --dangerously-skip-permissions 2>&1
        $sw.Stop()
        Write-Output "Elapsed: $($sw.ElapsedMilliseconds) ms"
        Write-Output "Output:"
        $output | ForEach-Object { Write-Output "  $_" }
        return $output
    } catch {
        $sw.Stop()
        Write-Output "Error: $($_.Exception.Message)"
        return $null
    }
}

# Run tests
Write-Output "`n=== STARTING SUITE EXECUTION ==="

