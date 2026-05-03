$ErrorActionPreference = "Stop"

Write-Host "Starting Dublin Housing Affordability full run..." -ForegroundColor Cyan

if (!(Test-Path ".\.env")) {
    Write-Host "Missing .env file. Copy .env.example to .env and update values first." -ForegroundColor Red
    exit 1
}

if (!(Test-Path ".\data\raw\property_prices.csv")) {
    Write-Host "Missing data/raw/property_prices.csv. Add Property Price Register CSV first." -ForegroundColor Red
    exit 1
}

Write-Host "Running ETL pipeline..." -ForegroundColor Yellow
$pythonExe = ".\.venv\Scripts\python.exe"
if (!(Test-Path $pythonExe)) {
    Write-Host "Missing virtual environment python at $pythonExe" -ForegroundColor Red
    exit 1
}

& $pythonExe .\src\main.py
if ($LASTEXITCODE -ne 0) {
    Write-Host "ETL failed. Stop here and fix error above." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Generating analysis figures..." -ForegroundColor Yellow
& $pythonExe .\src\analyze.py
if ($LASTEXITCODE -ne 0) {
    Write-Host "Analysis figure generation failed." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Done. Launch dashboard with:" -ForegroundColor Green
Write-Host "streamlit run dashboard/app.py" -ForegroundColor Green
