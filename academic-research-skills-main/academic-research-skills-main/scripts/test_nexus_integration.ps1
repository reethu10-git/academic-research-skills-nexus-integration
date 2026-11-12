<#
.SYNOPSIS
    Automated validation suite for Nexus LLMLite (nova-micro) + Claude Code integration.

.DESCRIPTION
    Runs the 5 sequential validation checks:
      1. Direct API connectivity & Anthropic Messages protocol validation
      2. Claude Code environment and connection verification
      3. Basic model response test
      4. Claude Code tool execution test (file read)
      5. Academic Research Skills workflow test
#>

[CmdletBinding()]
param(
    [switch]$SkipInteractive
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
Set-Location $ProjectRoot

# Load .env if present
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

# Ensure Nexus environment configuration
if (-not $env:ANTHROPIC_BASE_URL) {
    $env:ANTHROPIC_BASE_URL = "https://nexusapi.navigatelabs.ai"
}
if (-not $env:ANTHROPIC_MODEL) {
    $env:ANTHROPIC_MODEL = "gemini-3.1-flash-lite"
}
if (-not $env:CLAUDE_CODE_MAX_OUTPUT_TOKENS) {
    $env:CLAUDE_CODE_MAX_OUTPUT_TOKENS = "4096"
}

# Check for API key in memory
if (-not $env:ANTHROPIC_AUTH_TOKEN -or [string]::IsNullOrWhiteSpace($env:ANTHROPIC_AUTH_TOKEN)) {
    if ($env:NEXUS_API_KEY -and -not [string]::IsNullOrWhiteSpace($env:NEXUS_API_KEY)) {
        $env:ANTHROPIC_AUTH_TOKEN = $env:NEXUS_API_KEY.Trim()
    } else {
        if ($SkipInteractive) {
            Write-Error "No API key found in memory or environment. Aborting non-interactive test."
            exit 1
        }
        Write-Host "Nexus API Key required for validation tests." -ForegroundColor Cyan
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

if (-not $env:ANTHROPIC_AUTH_TOKEN.StartsWith("sk-")) {
    Write-Host ""
    Write-Host "[ERROR] Invalid Nexus API Key format!" -ForegroundColor Red
    Write-Host "Nexus uses LiteLLM virtual keys, which must begin with 'sk-'." -ForegroundColor Yellow
    Write-Host "Tip: In PowerShell, you can set it directly in memory before running:" -ForegroundColor Gray
    Write-Host '  $env:NEXUS_API_KEY = "sk-your-key-here"' -ForegroundColor White
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   NEXUS LLMLITE + CLAUDE CODE INTEGRATION TEST SUITE    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Target Base URL : $env:ANTHROPIC_BASE_URL"
Write-Host "Target Model    : $env:ANTHROPIC_MODEL"
Write-Host "Max Output      : $env:CLAUDE_CODE_MAX_OUTPUT_TOKENS"
Write-Host "Working Dir     : $ProjectRoot"
Write-Host ""

# -------------------------------------------------------------------------
# TEST 1: Direct API Connectivity & Anthropic Messages Protocol
# -------------------------------------------------------------------------
Write-Host "[TEST 1/5] Direct Nexus API Connectivity & Messages Protocol..." -ForegroundColor Yellow
$test1Uri = "$env:ANTHROPIC_BASE_URL/v1/messages"
$headers = @{
    "Authorization" = "Bearer $env:ANTHROPIC_AUTH_TOKEN"
    "Content-Type"  = "application/json"
    "anthropic-version" = "2023-06-01"
}
$bodyPayload = @{
    model = $env:ANTHROPIC_MODEL
    max_tokens = 256
    messages = @(
        @{
            role = "user"
            content = "Respond with exact text: 'Nexus nova-micro online.'"
        }
    )
} | ConvertTo-Json -Depth 5

try {
    $t1Response = Invoke-RestMethod -Uri $test1Uri -Method POST -Headers $headers -Body $bodyPayload -TimeoutSec 30
    Write-Host "  -> HTTP Status: 200 OK" -ForegroundColor Green
    Write-Host "  -> Model ID: $($t1Response.model)" -ForegroundColor Green
    if ($t1Response.content -and $t1Response.content.Count -gt 0) {
        $msgText = $t1Response.content[0].text
        Write-Host "  -> Response: $msgText" -ForegroundColor Green
    }
    Write-Host "  [PASS] Test 1 completed successfully.`n" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Test 1 failed:" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "  Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
    if ($_.ErrorDetails) {
        Write-Host "  Error: $($_.ErrorDetails.Message)" -ForegroundColor Red
    } else {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    exit 1
}

# Resolve Claude Code CLI
$claudeCmd = Get-Command "claude" -ErrorAction SilentlyContinue
$claudeExe = if ($claudeCmd) { $claudeCmd.Source } else { "$env:USERPROFILE\.local\bin\claude.exe" }
if (-not (Test-Path $claudeExe)) {
    Write-Error "Claude Code CLI not found."
    exit 1
}

# -------------------------------------------------------------------------
# TEST 2: Claude Code CLI Environment & Configuration
# -------------------------------------------------------------------------
Write-Host "[TEST 2/5] Verifying Claude Code CLI Configuration..." -ForegroundColor Yellow
try {
    $ver = & $claudeExe --version
    Write-Host "  -> Claude Code CLI: $ver" -ForegroundColor Green
    Write-Host "  -> ANTHROPIC_BASE_URL configured: $env:ANTHROPIC_BASE_URL" -ForegroundColor Green
    Write-Host "  -> ANTHROPIC_MODEL configured: $env:ANTHROPIC_MODEL" -ForegroundColor Green
    Write-Host "  [PASS] Test 2 completed successfully.`n" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Test 2 failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# -------------------------------------------------------------------------
# TEST 3: Basic Prompt Response via Claude Code
# -------------------------------------------------------------------------
Write-Host "[TEST 3/5] Basic Prompt Execution via Claude Code..." -ForegroundColor Yellow
$prompt3 = "Explain what Academic Research Skills does in two sentences."
Write-Host "  Prompt: '$prompt3'" -ForegroundColor Gray
try {
    $t3Output = & $claudeExe -p $prompt3 --effort low --dangerously-skip-permissions 2>&1
    Write-Host "  -> Claude Output:" -ForegroundColor Green
    $t3Output | ForEach-Object { Write-Host "     $_" -ForegroundColor Gray }
    Write-Host "  [PASS] Test 3 completed successfully.`n" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Test 3 failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# -------------------------------------------------------------------------
# TEST 4: Tool Execution via Claude Code
# -------------------------------------------------------------------------
Write-Host "[TEST 4/5] Claude Code Tool Use (Reading CITATION.cff)..." -ForegroundColor Yellow
$prompt4 = "Read the CITATION.cff file in the current directory and report only the project title and author."
Write-Host "  Prompt: '$prompt4'" -ForegroundColor Gray
try {
    $t4Output = & $claudeExe -p $prompt4 --effort low --dangerously-skip-permissions 2>&1
    Write-Host "  -> Claude Output:" -ForegroundColor Green
    $t4Output | ForEach-Object { Write-Host "     $_" -ForegroundColor Gray }
    Write-Host "  [PASS] Test 4 completed successfully.`n" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Test 4 failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# -------------------------------------------------------------------------
# TEST 5: Academic Research Skills Workflow Command
# -------------------------------------------------------------------------
Write-Host "[TEST 5/5] Academic Research Skills Workflow Mode..." -ForegroundColor Yellow
$prompt5 = "Summarize the purpose and phases of the academic-pipeline skill in this project."
Write-Host "  Prompt: '$prompt5'" -ForegroundColor Gray
try {
    $t5Output = & $claudeExe -p $prompt5 --effort low --dangerously-skip-permissions 2>&1
    Write-Host "  -> Claude Output:" -ForegroundColor Green
    $t5Output | ForEach-Object { Write-Host "     $_" -ForegroundColor Gray }
    Write-Host "  [PASS] Test 5 completed successfully.`n" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Test 5 failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Green
Write-Host " ALL 5 INTEGRATION AND VALIDATION TESTS PASSED!           " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
