<#
.SYNOPSIS
    Diagnoses Nexus API model availability and endpoint compatibility.
#>

param(
    [string]$ApiKey = $env:NEXUS_API_KEY
)

if (-not $ApiKey) {
    if ($env:ANTHROPIC_AUTH_TOKEN) {
        $ApiKey = $env:ANTHROPIC_AUTH_TOKEN
    } else {
        $secureKey = Read-Host -Prompt "Enter Nexus API Key (typing hidden)" -AsSecureString
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
        try {
            $ApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        } finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}

$ApiKey = $ApiKey.Trim()
$headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type"  = "application/json"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "             NEXUS API ENDPOINT DIAGNOSTICS               " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Check Available Models
Write-Host "`n[1] Checking Available Models on Nexus via GET /v1/models..." -ForegroundColor Yellow
try {
    $modelsResp = Invoke-RestMethod -Uri "https://nexusapi.navigatelabs.ai/v1/models" -Headers $headers -Method GET
    Write-Host "  -> Available Models in your account:" -ForegroundColor Green
    $modelsResp.data | ForEach-Object {
        Write-Host "     - $($_.id)" -ForegroundColor White
    }
} catch {
    Write-Host "  -> GET /v1/models failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host "     $($_.ErrorDetails.Message)" -ForegroundColor Red }
}

# 2. Test OpenAI-compatible Chat Completions
$testModel = if ($env:ANTHROPIC_MODEL) { $env:ANTHROPIC_MODEL } else { "nova-micro" }
Write-Host "`n[2] Testing POST /v1/chat/completions with model '$testModel'..." -ForegroundColor Yellow
$chatBody = @{
    model = $testModel
    messages = @(@{ role = "user"; content = "hi" })
    max_tokens = 50
} | ConvertTo-Json

try {
    $chatResp = Invoke-RestMethod -Uri "https://nexusapi.navigatelabs.ai/v1/chat/completions" -Headers $headers -Method POST -Body $chatBody
    Write-Host "  -> Chat Completions Response: SUCCESS" -ForegroundColor Green
    Write-Host "  -> Model output: $($chatResp.choices[0].message.content)" -ForegroundColor Green
} catch {
    Write-Host "  -> Chat Completions failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host "     $($_.ErrorDetails.Message)" -ForegroundColor Red }
}

# 3. Test Anthropic-compatible Messages API
Write-Host "`n[3] Testing POST /v1/messages with model '$testModel'..." -ForegroundColor Yellow
$msgBody = @{
    model = $testModel
    max_tokens = 50
    messages = @(@{ role = "user"; content = "hi" })
} | ConvertTo-Json

$msgHeaders = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type"  = "application/json"
    "anthropic-version" = "2023-06-01"
}

try {
    $msgResp = Invoke-RestMethod -Uri "https://nexusapi.navigatelabs.ai/v1/messages" -Headers $msgHeaders -Method POST -Body $msgBody
    Write-Host "  -> Messages API Response: SUCCESS" -ForegroundColor Green
    Write-Host "  -> Model output: $($msgResp.content[0].text)" -ForegroundColor Green
} catch {
    Write-Host "  -> Messages API failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { Write-Host "     $($_.ErrorDetails.Message)" -ForegroundColor Red }
}

Write-Host "`n==========================================================" -ForegroundColor Cyan

