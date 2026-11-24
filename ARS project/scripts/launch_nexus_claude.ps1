<#
.SYNOPSIS
    Launches Claude Code CLI configured with Nexus LiteLLM Gateway (Nova Micro).

.DESCRIPTION
    Loads .env file if present, sets up environment variables:
      - ANTHROPIC_BASE_URL: https://nexusapi.navigatelabs.ai
      - ANTHROPIC_MODEL: nova-micro
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
    $env:ANTHROPIC_MODEL = "nova-micro"
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
            Write-Host "`n[ERROR] No API key entered." -ForegroundColor Red
            Write-Host "You can save your key permanently by running: powershell -File .\scripts\setup_env.ps1" -ForegroundColor Yellow
            exit 1
        }

        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
        try {
            $rawKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr).Trim()
        } finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }

        if (-not $rawKey.StartsWith("sk-")) {
            Write-Host "`n[ERROR] Invalid API Key format. Key must start with 'sk-'." -ForegroundColor Red
            exit 1
        }
        $env:ANTHROPIC_AUTH_TOKEN = $rawKey
    }
}

# 5. Resolve Claude Code CLI
$claudeCmd = Get-Command "claude" -ErrorAction SilentlyContinue
if ($claudeCmd) {
    $claudeExe = $claudeCmd.Source
} elseif (Test-Path "$env:USERPROFILE\.local\bin\claude.exe") {
    $claudeExe = "$env:USERPROFILE\.local\bin\claude.exe"
} elseif (Test-Path "$env:APPDATA\npm\claude.cmd") {
    $claudeExe = "$env:APPDATA\npm\claude.cmd"
} else {
    Write-Host "`n[ERROR] Claude Code executable ('claude') not found on system PATH." -ForegroundColor Red
    Write-Host "Please install Claude Code globally using npm:" -ForegroundColor Yellow
    Write-Host "    npm install -g @anthropic-ai/claude-code" -ForegroundColor White
    exit 1
}

# 6. Banner
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  ACADEMIC RESEARCH SKILLS (ARS) - NEXUS GATEWAY LAUNCHER " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  Base URL : $env:ANTHROPIC_BASE_URL" -ForegroundColor Gray
Write-Host "  Model    : $env:ANTHROPIC_MODEL" -ForegroundColor Gray
Write-Host "  Directory: $ProjectRoot" -ForegroundColor Gray
Write-Host "==========================================================`n" -ForegroundColor Green

# 7. Execute Claude Code CLI with passed arguments
& $claudeExe @PassthruArgs
