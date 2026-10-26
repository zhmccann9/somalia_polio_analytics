# Nomadic Mapping — Polio Analytics (Shiny)

## Setup

### 1. Install dependencies
```r
install.packages(c(
  "shiny", "leaflet", "plotly", "DT",
  "dplyr", "tidyr", "lubridate", "sf",
  "httr", "jsonlite", "stringr", "purrr",
  "ruODK", "tibble", "rsconnect", "readxl", "openxlsx"
))
```

### 2. Add credentials
Edit `.Renviron` and fill in:
```
ODKC_UN=your_username
ODKC_PW=your_password
```
The URL and project/form IDs are pre-filled.

### 3. Verify field names (first run only)
The ODK forms use group-prefixed field names. Run this once to confirm paths:
```r
readRenviron(".Renviron")
source("R/utils.R")
source("R/data_pull.R")   # get_schema() is defined in here
get_schema(Sys.getenv("ODKC_FID_CAMPS"))
get_schema(Sys.getenv("ODKC_FID_OUTREACH"))
```
Compare output against the `rename_flexible()` patterns in `data_pull.R` and
adjust the regex strings if field names differ.

### 4. Pull data
```r
source("refresh_data.R")
```
This writes `data/nomad_data.rds`.

All outreach metrics use the same survey-date source windows:

- `data/kobo_vaccination_data.xlsx`: through its last session date (25 May 2026).
- Live ODK Central: all survey dates after the Kobo cutoff (currently
  26 May 2026 onward), fetched on every refresh and combined with Kobo in memory.

Every successful ODK outreach fetch overwrites `data/outreach_ODK.csv` with
the complete fresh download, before filtering or combining with Kobo. This
CSV is an output snapshot only; it is never read as a data source and need
not exist before a refresh. Its headers follow the parsed ruODK field names.
If the ODK fetch or CSV export fails, the refresh stops rather than using an
old snapshot.

The Kobo cutoff is recalculated from its workbook on each refresh. Missing survey dates
are excluded with a warning; duplicate or missing selected submission IDs stop
the refresh. Camp data retains its separate 31 July 2026 historical cutoff.

The refresh also creates `data/data_source_audit.xlsx`, with source date rules,
source/year summaries, metric definitions and record-level camp/outreach
provenance. The audit excludes names and phone numbers.

The **Zero-Dose Rate by District** table uses camp enumeration, not outreach:
each age-group rate is `round(100 * sum(zero_dose) / sum(population), 1)` for
the selected district/year, ignoring missing counts in each sum. Nonpositive
denominators return `NA`. Camps counts survey records, not distinct camps.
Status uses the rounded 0-11 month rate: Critical >=80%, High >=60%, Moderate
>=30%, otherwise Low. Population and zero-dose KPI totals are estimates from
camp enumeration, not headcounts.

Run the focused source/Excel checks from the app directory:

```r
source("tests/test_outreach_sources.R")
```

### 5. Run locally
```r
shiny::runApp()
```

### 6. Deploy to shinyapps.io
```r
rsconnect::setAccountInfo(name="<account>", token="<token>", secret="<secret>")
source("deploy.R")
```
Use `deploy.R` rather than an unrestricted `deployApp()` call. It resolves
the app directory from the script's location, so sourcing its absolute path
also works from another working directory. It deploys only the entry point,
global setup, runtime R modules, stylesheet and pre-built `data/nomad_data.rds`.
Missing runtime files stop deployment before upload.

The local `.Renviron`, `.RData`, raw surveys, audit/comparison outputs, media,
tests and refresh scripts are **not** deployed. Refresh locally and redeploy
when you want updated data.

AI insights need `ANTHROPIC_API_KEY` and the basemaps use `BASEMAP_API_KEY`.
shinyapps.io does not support `deployApp(envVars = ...)`, so `deploy.R` stages
the runtime files in a temporary folder and writes a minimal `.Renviron` there.
That file contains **only** those two keys, which are read from the local
`.Renviron` (or the current R session). `global.R` loads it on the server.
ODK credentials are never bundled. Deployment stops before upload if either
key is missing. The temporary folder is deleted afterwards, and the existing
deployment record in `rsconnect/` is still used.

A connection reset while uploading to `shinyapps-upload.s3.amazonaws.com`
is an upload/transport failure, not an R build error. Retry the smaller bundle
with `deploy.R`. If it still resets, check the network/proxy with your IT team
or try another approved connection. Do not disable TLS verification.

Validate packaging, the runtime-keys-only `.Renviron` and staged startup
without uploading (from the app directory; uses fake keys):

```r
source(file.path("tests", "test_deploy.R"))
```

## File structure
```
nomad_app/
├── app.R                 UI + server
├── global.R              Package loading + data load
├── refresh_data.R        One-liner to re-pull ODK data
├── .Renviron             Credentials (never commit)
├── R/
│   ├── data_pull.R       ODK fetch → spatial join → aggregation
│   ├── utils.R           Crosswalk + shared helpers
│   ├── mod_kpi.R         KPI cards module
│   ├── mod_movement.R    Movement patterns tab
│   ├── mod_zerodose.R    Zero dose & vaccination tab
│   ├── mod_access.R      Access & challenges tab
│   └── mod_report.R      Field teams report tab
├── data/
│   └── nomad_data.rds    Pre-built data (generated by refresh_data.R)
└── www/
    └── styles.css        App styling
```

## Updating the district crosswalk
Open `R/utils.R` and add entries to `DISTRICT_CROSSWALK`. Left side = raw ODK
value, right side = canonical ArcGIS PHB 2026 district name. Re-run
`refresh_data.R` after changes.
