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

It also prints the KPI header values (Camps enumerated, Estimated population,
Estimated zero-dose children, Children vaccinated (outreach), Outreach
sessions) for each year filter and saves them to
`data/kpi_headers_by_year.csv`, so the dashboard header can be checked against
the pull. Camps enumerated counts distinct group codes, so a group surveyed in
more than one year is counted once in All time, and All time can be less than
the sum of the years.

The **Zero-Dose Rate by District** table uses camp enumeration, not outreach:
each age-group rate is `round(100 * sum(zero_dose) / sum(population), 1)` for
the selected district/year, ignoring missing counts in each sum. Nonpositive
denominators return `NA`. The Groups/Camps count is the number of distinct
normalised group codes (see below), not survey records.
Status uses the rounded 0-11 month rate: Critical >=80%, High >=60%, Moderate
>=30%, otherwise Low. Population and zero-dose KPI totals are estimates from
camp enumeration, not headcounts.

#### Group codes
Camp records are pooled by group code instead of enumerator district. Raw codes
(`community_level-group-group_code`) are free text such as `LQ-MR-HW-001`,
`Luuq-Marehan-Horarsame-001` or `Belet-hawa, MR, Rer Ahmed, 002`.
`normalise_group_codes()` in `R/utils.R` converts them to
`DISTRICT-CLAN-SUBCLAN` (e.g. `LQ-MR-HOWRARSAME`):

- Codes are split into words; the trailing number is dropped, so every visit
  to the same group is pooled and summed.
- District, clan and sub-clan words are matched against the dictionaries in
  `utils.R` (`GROUP_CODE_DISTRICT_ALIASES`, `GROUP_CODE_CLAN_ALIASES`,
  `GROUP_CODE_SUBCLANS`, `GROUP_CODE_SUBCLAN_ABBREVIATIONS`): exact
  abbreviation first, then a Somali phonetic key (x=h, q=k, c dropped, doubled
  letters collapsed), then edit distance within 30% of the word length.
  Unrecognised words are clustered the same way across all codes.
- The code's district is used for district tables; when the code names no
  district the enumerator district is used.
- Codes that are only a number, blank, or have no clan/sub-clan (e.g.
  `Belet xawa 000`, `Others`) are excluded and listed with their reason in
  `data/group_code_exclusions.csv`.

Every refresh writes `data/group_code_crosswalk.csv` (raw spelling →
normalised code). Review it and add spellings to the dictionaries when a
group is split or merged incorrectly.

An older `data/nomad_data.rds` can still be opened: the app keeps its saved
district-based results and district-only map labels, and displays a refresh
warning. The district table retains its old **Camps** (survey records) label;
these results have not yet applied group pooling or group-code exclusions.
Run `source("refresh_data.R")` from the app directory, then restart the app
to load the new group-code data. Updating the code alone does not rebuild the RDS.

Run the focused source, group-code and Shiny module checks from the app directory:

```r
source("tests/test_outreach_sources.R")
source("tests/test_group_codes.R")
source("tests/test_zerodose.R")
```

### 5. Run locally
```r
shiny::runApp()
```

### 6. Deploy to shinyapps.io
```r
rsconnect::setAccountInfo(name="<account>", token="<token>", secret="<secret>")
rsconnect::deployApp(
  appFiles = c("app.R", "global.R", "R/", "www/", "data/nomad_data.rds")
)
```
The `.Renviron` and raw ODK credentials are **not** deployed — only the
pre-built RDS. Refresh locally and redeploy when you want updated data.

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
