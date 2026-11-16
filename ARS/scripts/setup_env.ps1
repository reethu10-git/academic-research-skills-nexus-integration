<#
.SYNOPSIS
    Saves Nexus API configuration and API key to .env, then runs Claude Code.
#>

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
$envPath = Join-Path $ProjectRoot ".env"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       CONFIGURE NEXUS API KEY IN .ENV FILE              " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$secureKey = Read-Host -Prompt "Enter your Nexus API Key (starts with sk-)" -AsSecureString
if ($null -eq $secureKey -or $secureKey.Length -eq 0) {
    Write-Error "No API key entered. Aborting."
    exit 1
}

$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
try {
    $apiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr).Trim()
} finally {
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}

if (-not $apiKey.StartsWith("sk-")) {
    Write-Host "[ERROR] Key must start with 'sk-'. Please copy your virtual key from Nexus AI Model Hub." -ForegroundColor Red
    exit 1
}

$envContent = @"
# Nexus AI Configuration for Claude Code
ANTHROPIC_BASE_URL=https://nexusapi.navigatelabs.ai
ANTHROPIC_MODEL=nova-micro
CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
ANTHROPIC_AUTH_TOKEN=$apiKey
"@

Set-Content -Path $envPath -Value $envContent -Encoding UTF8
Write-Host "Saved configuration to $envPath successfully (protected by .gitignore)." -ForegroundColor Green
Write-Host "Launching Claude Code now...`n" -ForegroundColor Cyan

# Launch Claude Code via launcher
& (Join-Path $ScriptDir "launch_nexus_claude.ps1")

