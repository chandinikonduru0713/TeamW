param(
    [string]$TeamName = "TeamX"
)

$ErrorActionPreference = "Stop"

$zipName = "$TeamName.zip"
$items = @(
    "dashboard",
    "data",
    "docs",
    "notebooks",
    "sql",
    "src",
    "scripts",
    ".env.example",
    ".gitignore",
    "README.md",
    "requirements.txt",
    "run_all.ps1",
    "package_submission.ps1"
)

if (Test-Path $zipName) {
    Remove-Item $zipName -Force
}

Compress-Archive -Path $items -DestinationPath $zipName

Write-Host "Created submission archive: $zipName" -ForegroundColor Green
