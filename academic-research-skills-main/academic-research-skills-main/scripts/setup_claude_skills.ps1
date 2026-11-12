# setup_claude_skills.ps1
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
Set-Location $ProjectRoot

$claudeSkillsDir = Join-Path $ProjectRoot ".claude\skills"
if (-not (Test-Path $claudeSkillsDir)) {
    New-Item -ItemType Directory -Path $claudeSkillsDir -Force | Out-Null
}

$skillNames = @(
    "deep-research",
    "academic-paper",
    "academic-paper-reviewer",
    "academic-pipeline",
    "sr-screener"
)

Write-Host "=== 1. VERIFYING AND REMOVING MALFORMED SKILL ENTRIES ===" -ForegroundColor Cyan
foreach ($name in $skillNames) {
    $targetPath = Join-Path $claudeSkillsDir $name
    if (Test-Path $targetPath -PathType Leaf) {
        $content = (Get-Content $targetPath -Raw).Trim()
        Write-Host "Found file entry: $name -> '$content'"
        if ($content -match "^\.\./") {
            Remove-Item -Path $targetPath -Force
            Write-Host "Removed malformed text link: $name" -ForegroundColor Yellow
        } else {
            Write-Error "File $targetPath does not look like a text link pointer: $content"
        }
    } elseif (Test-Path $targetPath -PathType Container) {
        Write-Host "Directory already exists: $name" -ForegroundColor Gray
    }
}

Write-Host "`n=== 2. COPYING FULL SKILL DIRECTORIES TO .claude/skills/ ===" -ForegroundColor Cyan
foreach ($name in $skillNames) {
    $sourceDir = Join-Path $ProjectRoot $name
    $destDir = Join-Path $claudeSkillsDir $name
    
    if (-not (Test-Path $sourceDir -PathType Container)) {
        Write-Error "Source directory not found: $sourceDir"
    }

    Write-Host "Copying $sourceDir -> $destDir ..."
    Copy-Item -Path $sourceDir -Destination $destDir -Recurse -Force
    
    # Check copy result
    $destSkillMd = Join-Path $destDir "SKILL.md"
    if (Test-Path $destSkillMd) {
        $itemCount = (Get-ChildItem -Path $destDir -Recurse | Measure-Object).Count
        Write-Host "  Success: $name copied ($itemCount items, SKILL.md verified)" -ForegroundColor Green
    } else {
        Write-Error "SKILL.md missing in copied destination: $destDir"
    }
}

Write-Host "`n=== 3. VALIDATING YAML FRONTMATTER OF COPIED SKILLS ===" -ForegroundColor Cyan
foreach ($name in $skillNames) {
    $skillMd = Join-Path $claudeSkillsDir "$name\SKILL.md"
    $lines = Get-Content $skillMd
    
    if ($lines[0].Trim() -ne "---") {
        Write-Error "Invalid frontmatter: $skillMd does not start with ---"
    }
    
    $endFm = -1
    for ($i = 1; $i -lt [Math]::Min($lines.Count, 50); $i++) {
        if ($lines[$i].Trim() -eq "---") {
            $endFm = $i
            break
        }
    }
    
    if ($endFm -eq -1) {
        Write-Error "Invalid frontmatter: closing --- not found in first 50 lines of $skillMd"
    }
    
    $fmLines = $lines[1..($endFm - 1)]
    $hasName = $fmLines | Where-Object { $_ -match '^name:\s*(\S+)' }
    $hasDesc = $fmLines | Where-Object { $_ -match '^description:' }
    
    Write-Host "[$name] Frontmatter validated ($($endFm + 1) lines). Name line: '$hasName'" -ForegroundColor Green
}

Write-Host "`n=== SKILL REGISTRATION COMPLETE ===" -ForegroundColor Green

