<#
.SYNOPSIS
    Root launcher shortcut for Academic Research Skills with Nexus AI.
#>
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$PassthruArgs
)

$targetScript = Join-Path $PSScriptRoot "scripts\launch_nexus_claude.ps1"
if (Test-Path $targetScript) {
    & $targetScript @PassthruArgs
} else {
    Write-Error "Launcher script not found at $targetScript"
}

