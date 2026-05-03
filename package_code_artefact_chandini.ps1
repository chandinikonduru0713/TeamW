param(
    [string]$OutputZip = "team-chandini.zip",
    # Drop large yearly_ppr folder (merge script + README still explain how to rebuild) — use for GitHub web upload under 25 MB
    [switch]$ExcludeYearlyPpr
)

$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$stageName = "_staging_code_artefact"
$stage = Join-Path $repoRoot $stageName

if (Test-Path $stage) {
    Remove-Item $stage -Recurse -Force
}
New-Item -ItemType Directory -Path $stage | Out-Null

function Copy-ProjectTree {
    param(
        [string]$RelativePath,
        [string[]]$ExcludeDirs = @("__pycache__", ".venv"),
        [string[]]$ExcludeFiles = @("*.pyc")
    )
    $src = Join-Path $repoRoot $RelativePath
    $dst = Join-Path $stage $RelativePath
    if (-not (Test-Path $src)) {
        return
    }
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
    robocopy $src $dst /E /NFL /NDL /NJH /NS /NC /NP `
        /XD $ExcludeDirs `
        /XF $ExcludeFiles | Out-Null
    if ($LASTEXITCODE -ge 8) {
        throw "robocopy failed for $RelativePath (exit $LASTEXITCODE)"
    }
}

# Core code and data (no Overleaf, no venv, no __pycache__)
Copy-ProjectTree "dashboard"
Copy-ProjectTree "data"
Copy-ProjectTree "notebooks"

# Same PPR extract copied many times under data/raw — huge in zip; keep property_prices.csv only
$rawStage = Join-Path $stage "data\raw"
if (Test-Path $rawStage) {
    Get-ChildItem $rawStage -Filter "property_prices_raw*.csv" -File -ErrorAction SilentlyContinue | Remove-Item -Force
}
if ($ExcludeYearlyPpr) {
    $yp = Join-Path $stage "data\raw\yearly_ppr"
    if (Test-Path $yp) {
        Remove-Item $yp -Recurse -Force
        New-Item -ItemType Directory -Path $yp -Force | Out-Null
        @"
# Yearly PPR CSVs omitted in this archive to stay under GitHub's 25 MB web-upload limit.
# Download Dublin 2015–2025 from https://www.propertypriceregister.ie then run:
#   python scripts/merge_yearly_ppr.py
"@ | Set-Content -Path (Join-Path $yp ".gitkeep") -Encoding UTF8
    }
}
Copy-ProjectTree "sql"
Copy-ProjectTree "src"
Copy-ProjectTree "scripts"

# Docs: figures + text useful for markers; exclude internal/session-only files
$docsDst = Join-Path $stage "docs"
New-Item -ItemType Directory -Path $docsDst -Force | Out-Null
Copy-ProjectTree "docs\figures"
foreach ($f in @(
        "ieee_report_draft.md",
        "presentation_script.md",
        "submission_checklist.md",
        "work_breakdown"
    )) {
    $from = Join-Path $repoRoot (Join-Path "docs" $f)
    $to = Join-Path $docsDst $f
    if (Test-Path $from) {
        if (Test-Path $from -PathType Container) {
            robocopy $from $to /E /NFL /NDL /NJH /NS /NC /NP /XD __pycache__ | Out-Null
            if ($LASTEXITCODE -ge 8) { throw "robocopy failed for docs\$f" }
        } else {
            Copy-Item $from $to -Force
        }
    }
}

# Root configuration and run instructions only
foreach ($f in @(
        ".env.example",
        ".gitignore",
        "README.md",
        "requirements.txt",
        "run_all.ps1",
        "package_submission.ps1",
        "package_code_artefact_chandini.ps1"
    )) {
    $p = Join-Path $repoRoot $f
    if (Test-Path $p) {
        Copy-Item $p (Join-Path $stage $f) -Force
    }
}

# Remove optional tooling from staging if present (keeps artefact minimal)
$gen = Join-Path $stage "scripts\generate_team_presentation.py"
if (Test-Path $gen) {
    Remove-Item $gen -Force
}

# One-page pointer for the examiner
$readmeArtefact = @"
Code artefact (team-chandini.zip)
================================
This archive is scoped for the module Code Artefact submission only.

Included:
- Source code (src/, dashboard/, scripts/merge_yearly_ppr.py)
- Data (data/raw, data/processed as present in the workspace)
- Notebooks, SQL init, requirements, .env.example, run_all.ps1
- docs/figures (chart outputs), docs/work_breakdown (contribution drafts), report/presentation markdown drafts

Excluded on purpose:
- Overleaf/LaTeX package (overleaf_report_package/) — submit PDF report via Turnitin separately
- Python virtual environment (.venv)
- Local secrets (.env) — use .env.example only
- Generated __pycache__ / .pyc

Setup: copy .env.example to .env, install requirements, run run_all.ps1 (see README.md).
"@
Set-Content -Path (Join-Path $stage "CODE_ARTEFACT_README.txt") -Value $readmeArtefact -Encoding UTF8

$zipPath = Join-Path $repoRoot $OutputZip
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -Path (Join-Path $stage "*") -DestinationPath $zipPath -Force
Remove-Item $stage -Recurse -Force

Write-Host "Created code artefact: $zipPath" -ForegroundColor Green
