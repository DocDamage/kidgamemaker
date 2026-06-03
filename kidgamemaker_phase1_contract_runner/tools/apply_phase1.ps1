param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,

    [string]$TargetPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

if (!(Test-Path $SourcePath)) {
    throw "SourcePath does not exist: $SourcePath"
}

if (!(Test-Path (Join-Path $TargetPath ".git"))) {
    throw "TargetPath is not a git repo root: $TargetPath"
}

$exclude = @(".git", "kidgamemaker_phase1_contract_runner.patch")

Get-ChildItem -Path $SourcePath -Force | Where-Object { $exclude -notcontains $_.Name } | ForEach-Object {
    $destination = Join-Path $TargetPath $_.Name
    if (Test-Path $destination) {
        Remove-Item $destination -Recurse -Force
    }
    Copy-Item $_.FullName $destination -Recurse -Force
}

Write-Host "Phase 1 files copied into $TargetPath"
Write-Host "Next: git status; git add .; git commit -m 'Start contract-first KidGameMaker runner'; git push"
