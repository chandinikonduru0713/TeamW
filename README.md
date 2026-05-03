# Dublin Housing Affordability Analysis (2015-2025)

MSc Group Project for **Analytics Programming & Data Visualisation** at National College of Ireland.

## Research Question
Is housing in Dublin becoming unaffordable relative to income over time (2015-2025), and how does affordability vary across areas?

## Objectives
- Build a full ETL pipeline across **structured + semi-structured** data.
- Store raw data in **MongoDB** and processed output in **PostgreSQL**.
- Compute reproducible affordability metrics and area-level comparisons.
- Produce static and interactive visualisations with interpretable insights.

## Datasets (Non-Kaggle)
1. **Property Price Register (CSV)** - transaction-level property sales data.
2. **CSO Income API (JSON-stat)** - annual income indicators.
3. **CSO Population API (JSON-stat, optional extension)** - annual population context.

Each dataset supports at least 1,000 records over the full extracted range.

## Tech Stack
- Python: `pandas`, `numpy`, `requests`, `matplotlib`, `seaborn`, `plotly`, `streamlit`
- Databases: MongoDB (`pymongo`), PostgreSQL (`SQLAlchemy`, `psycopg2`)
- Runtime config: `python-dotenv`

## Repository Structure
```text
.
├── data/
│   ├── raw/
│   └── processed/
├── dashboard/
│   └── app.py
├── docs/
│   ├── ieee_report_draft.md
│   ├── presentation_script.md
│   ├── figures/
│   └── work_breakdown/
├── notebooks/
├── sql/
│   └── postgres_init.sql
├── src/
│   ├── extract.py
│   ├── transform.py
│   ├── load.py
│   ├── main.py
│   └── analyze.py
├── .env.example
└── requirements.txt
```

## Environment Setup
1. Create a Python virtual environment.
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Create `.env` from `.env.example`.
4. Update values if needed:
   ```env
   MONGO_URI=mongodb+srv://projectdb:YOUR_PASSWORD@cluster0.wzefzgx.mongodb.net/dublin_housing_project?retryWrites=true&w=majority
   MONGO_DB=dublin_housing_project
   POSTGRES_URI=postgresql+psycopg2://postgres:postgres@localhost:5432/dublin_housing
   PROPERTY_CSV_PATH=data/raw/property_prices.csv
   CSO_INCOME_API_URL=https://ws.cso.ie/public/api.restful/PxStat.Data.Cube_API.ReadDataset/SIA14/JSON-stat/2.0/en
   CSO_POPULATION_API_URL=https://ws.cso.ie/public/api.restful/PxStat.Data.Cube_API.ReadDataset/F1015/JSON-stat/2.0/en
   ```

## Data Preparation
1. Download Property Price Register CSV from the official Irish source.
2. Save CSV as `data/raw/property_prices.csv`.

   **One year per download (Dublin 2015–2025):** save each official CSV into `data/raw/yearly_ppr/`, then merge:

   ```bash
   python scripts/merge_yearly_ppr.py
   ```

   See `docs/SESSION_RESUME.md` if you are continuing after a lost chat.

3. Ensure PostgreSQL database exists:
   - Run `sql/postgres_init.sql` or create database manually.

## Run Pipeline (Step-by-Step)
1. **Extract + Transform + Load**
   ```bash
   python src/main.py
   ```
   This will:
   - Load property CSV
   - Fetch CSO income and population APIs
   - Store raw documents in MongoDB
   - Clean and aggregate data (Dublin, 2015-2025)
   - Compute affordability index
   - Save processed output to PostgreSQL + CSV files

2. **Generate analysis figures**
   ```bash
   python src/analyze.py
   ```
   Output charts are saved to `docs/figures/`.

3. **Launch interactive dashboard**
   ```bash
   streamlit run dashboard/app.py
   ```

## Database Outputs
### MongoDB (Raw Zone)
- `property_prices_raw`
- `cso_income_raw`
- `cso_income_parsed_raw`
- `cso_population_raw`
- `cso_population_parsed_raw`

### PostgreSQL (Processed Zone)
- `dublin_affordability_yearly`
- `dublin_affordability_area`
- `project_insights`

## Core Metrics
- `affordability_index = avg_price_eur / income_eur`
- Year-over-year change in price, income, and affordability
- Area-level average property price and transaction count

## Submission Artefacts
- IEEE report draft: `docs/ieee_report_draft.md`
- Presentation plan and script: `docs/presentation_script.md`
- Individual contribution files: `docs/work_breakdown/`

Final Moodle naming:
- Report: `TeamX.pdf`
- Code archive: `TeamX.zip`
- Video: `TeamX.mp4`
- Individual contribution: `x12345678.pdf` (one per member)
