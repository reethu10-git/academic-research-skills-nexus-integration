<#
.SYNOPSIS
    Launches Claude Code CLI configured with Nexus LiteLLM Gateway (Claude Haiku / Anthropic API).

.DESCRIPTION
    Loads .env file if present, sets up environment variables:
      - ANTHROPIC_BASE_URL: https://nexusapi.navigatelabs.ai
      - ANTHROPIC_MODEL: claude-haiku-4-5
      - CLAUDE_CODE_MAX_OUTPUT_TOKENS: 4096
      - ANTHROPIC_AUTH_TOKEN: Bearer token authentication
    Then launches Claude Code directly from the project root.
#>

[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$PassthruArgs
)

# 1. Resolve Project Root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
Set-Location $ProjectRoot

# 2. Automatically load .env from project root if it exists
$envFile = Join-Path $ProjectRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -match '^\s*([^#=]+)\s*=\s*(.*)$' } | ForEach-Object {
        $varName = $matches[1].Trim()
        $varVal = $matches[2].Trim()
        if ($varVal -match '^["''](.*)["'']$') {
            $varVal = $matches[1]
        }
        if (-not [string]::IsNullOrWhiteSpace($varName) -and -not [string]::IsNullOrWhiteSpace($varVal)) {
            [Environment]::SetEnvironmentVariable($varName, $varVal, "Process")
        }
    }
}

# 3. Apply defaults if not set in .env
if (-not $env:ANTHROPIC_BASE_URL) {
    $env:ANTHROPIC_BASE_URL = "https://nexusapi.navigatelabs.ai"
}
if (-not $env:ANTHROPIC_MODEL) {
    $env:ANTHROPIC_MODEL = "claude-haiku-4-5"
}
if (-not $env:CLAUDE_CODE_MAX_OUTPUT_TOKENS) {
    $env:CLAUDE_CODE_MAX_OUTPUT_TOKENS = "4096"
}

# 4. Check API key
if (-not $env:ANTHROPIC_AUTH_TOKEN -or [string]::IsNullOrWhiteSpace($env:ANTHROPIC_AUTH_TOKEN)) {
    if ($env:NEXUS_API_KEY -and -not [string]::IsNullOrWhiteSpace($env:NEXUS_API_KEY)) {
        $env:ANTHROPIC_AUTH_TOKEN = $env:NEXUS_API_KEY.Trim()
    } else {
        Write-Host "Nexus API Key required for Claude Code authentication." -ForegroundColor Cyan
        Write-Host "(Your Nexus Model Hub virtual key starts with 'sk-')" -ForegroundColor Gray
        
        $secureKey = Read-Host -Prompt "Enter Nexus API Key (typing hidden)" -AsSecureString
        if ($null -eq $secureKey -or $secureKey.Length -eq 0) {
            Write-Error "No API key entered. Operation cancelled."
            exit 1
        }
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
        try {
            $raw = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
            $env:ANTHROPIC_AUTH_TOKEN = $raw.Trim()
        } finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}

$env:ANTHROPIC_AUTH_TOKEN = $env:ANTHROPIC_AUTH_TOKEN.Trim()

if (-not $env:ANTHROPIC_AUTH_TOKEN.StartsWith("sk-")) {
    Write-Host ""
    Write-Host "[ERROR] Invalid Nexus API Key format!" -ForegroundColor Red
    Write-Host "Nexus uses LiteLLM virtual keys, which must begin with 'sk-'." -ForegroundColor Yellow
    exit 1
}

# 5. Resolve Claude Code CLI executable
$claudeCmd = Get-Command "claude" -ErrorAction SilentlyContinue
if ($claudeCmd) {
    $claudeExe = $claudeCmd.Source
} elseif (Test-Path "$env:USERPROFILE\.local\bin\claude.exe") {
    $claudeExe = "$env:USERPROFILE\.local\bin\claude.exe"
} else {
    Write-Error "Claude Code CLI ('claude') not found in PATH or ~/.local/bin."
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Green
Write-Host " Claude Code + Nexus LLMLite (Academic Research Skills)"   -ForegroundColor Green
Write-Host " Endpoint : $env:ANTHROPIC_BASE_URL"                      -ForegroundColor Gray
Write-Host " Model    : $env:ANTHROPIC_MODEL"                         -ForegroundColor Gray
Write-Host " Max Output: $env:CLAUDE_CODE_MAX_OUTPUT_TOKENS tokens"   -ForegroundColor Gray
Write-Host " Auth     : ANTHROPIC_AUTH_TOKEN (loaded from .env/memory)"-ForegroundColor Gray
Write-Host " Root     : $ProjectRoot"                                 -ForegroundColor Gray
Write-Host "==========================================================" -ForegroundColor Green

# 6. Execute Claude Code with arguments forwarded
$defaultArgs = @()
if (-not ($PassthruArgs -contains "--effort")) {
    $defaultArgs += @("--effort", "low")
}

try {
    if ($PassthruArgs -and $PassthruArgs.Count -gt 0) {
        & $claudeExe @defaultArgs @PassthruArgs
    } else {
        & $claudeExe @defaultArgs
    }
} catch {
    Write-Error "Error executing Claude Code: $($_.Exception.Message)"
    exit 1
}
