# verify_skills_installation.ps1
$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
Set-Location $ProjectRoot

$skills = @("deep-research", "academic-paper", "academic-paper-reviewer", "academic-pipeline", "sr-screener")
$claudeSkillsDir = Join-Path $ProjectRoot ".claude\skills"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "TASK 5: ARS SKILL REGISTRATION LOCAL VERIFICATION" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Gray

$results = [System.Collections.Generic.List[PSObject]]::new()

foreach ($s in $skills) {
    $origDir = Join-Path $ProjectRoot $s
    $installedDir = Join-Path $claudeSkillsDir $s
    
    $origExists = Test-Path $origDir -PathType Container
    $installedExists = Test-Path $installedDir -PathType Container
    
    $origSkillMd = Join-Path $origDir "SKILL.md"
    $installedSkillMd = Join-Path $installedDir "SKILL.md"
    
    $origHasSkillMd = Test-Path $origSkillMd -PathType Leaf
    $installedHasSkillMd = Test-Path $installedSkillMd -PathType Leaf
    
    $origItemCount = if ($origExists) { (Get-ChildItem -Path $origDir -Recurse | Where-Object { $_.FullName -notmatch '__pycache__' -and $_.Extension -ne '.pyc' } | Measure-Object).Count } else { 0 }
    $installedItemCount = if ($installedExists) { (Get-ChildItem -Path $installedDir -Recurse | Where-Object { $_.FullName -notmatch '__pycache__' -and $_.Extension -ne '.pyc' } | Measure-Object).Count } else { 0 }
    
    # Validate YAML Frontmatter
    $fmValid = $false
    $fmName = ""
    if ($installedHasSkillMd) {
        $lines = Get-Content $installedSkillMd
        if ($lines.Count -gt 2 -and $lines[0].Trim() -eq "---") {
            for ($i = 1; $i -lt [Math]::Min($lines.Count, 30); $i++) {
                if ($lines[$i] -match '^name:\s*(\S+)') {
                    $fmName = $matches[1].Trim()
                }
                if ($lines[$i].Trim() -eq "---") {
                    if (-not [string]::IsNullOrEmpty($fmName)) {
                        $fmValid = $true
                    }
                    break
                }
            }
        }
    }
    
    # Subdirectories check
    $installedSubDirs = if ($installedExists) {
        (Get-ChildItem -Path $installedDir -Directory | Select-Object -ExpandProperty Name) -join ", "
    } else { "" }

    $status = if ($installedExists -and $installedHasSkillMd -and $fmValid -and ($installedItemCount -eq $origItemCount)) {
        "VERIFIED"
    } else {
        "MISMATCH"
    }

    $results.Add([PSCustomObject]@{
        SkillName = $s
        OriginalItems = $origItemCount
        InstalledItems = $installedItemCount
        HasSkillMd = $installedHasSkillMd
        YAMLName = $fmName
        FrontmatterValid = $fmValid
        SubDirectories = $installedSubDirs
        Status = $status
    })
}

$results | Format-Table SkillName, InstalledItems, HasSkillMd, FrontmatterValid, Status -AutoSize

Write-Host "Subdirectories per installed skill:" -ForegroundColor Cyan
$results | ForEach-Object {
    Write-Host " - $($_.SkillName): $($_.SubDirectories)" -ForegroundColor Gray
}

# Check CLAUDE.md length
$claudeMdFile = Join-Path $ProjectRoot ".claude\CLAUDE.md"
if (Test-Path $claudeMdFile) {
    $cContent = Get-Content $claudeMdFile -Raw
    Write-Host "`nCLAUDE.md length check:" -ForegroundColor Cyan
    Write-Host " Characters: $($cContent.Length) (Limit: 40,000 chars)" -ForegroundColor $(if ($cContent.Length -le 40000) { "Green" } else { "Red" })
    Write-Host " Status    : $(if ($cContent.Length -le 40000) { 'PASSED (Below limit)' } else { 'FAILED (Over limit)' })" -ForegroundColor $(if ($cContent.Length -le 40000) { "Green" } else { "Red" })
}

