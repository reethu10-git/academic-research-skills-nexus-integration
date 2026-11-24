$ErrorActionPreference = "Continue"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

$skills = @("deep-research", "academic-paper", "academic-paper-reviewer", "academic-pipeline", "sr-screener")

Write-Host "=== INSPECTING ORIGINAL SKILLS ==="
$skills | ForEach-Object {
    $s = $_
    $path = Join-Path $ProjectRoot $s
    $exists = Test-Path $path
    $skillMd = Test-Path (Join-Path $path "SKILL.md")
    $itemCount = if ($exists) { (Get-ChildItem -Path $path -Recurse | Measure-Object).Count } else { 0 }
    $dirs = if ($exists) { (Get-ChildItem -Path $path -Directory | Select-Object -ExpandProperty Name) -join ", " } else { "" }
    
    [PSCustomObject]@{
        Skill = $s
        PathExists = $exists
        HasSkillMd = $skillMd
        TotalItems = $itemCount
        SubDirs = $dirs
    }
} | Format-Table -AutoSize

Write-Host "`n=== INSPECTING .claude/skills ENTRIES ==="
$claudeSkillsDir = Join-Path $ProjectRoot ".claude\skills"
Get-ChildItem -Path $claudeSkillsDir | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        Length = $_.Length
        Attributes = $_.Attributes
        Content = (Get-Content $_.FullName -Raw).Trim()
    }
} | Format-Table -AutoSize
