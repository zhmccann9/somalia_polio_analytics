library(shiny)

options(repos = c(
  ropensci = "https://ropensci.r-universe.dev",
  CRAN = "https://cloud.r-project.org"
))
library(rsconnect)

# Run from the nomad_app_new folder.
rsconnect::deployApp(
  appDir      = ".",
  # Only the files the app needs (~0.5 MB). .Renviron supplies the API keys.
  appFiles    = c(
    "app.R", "global.R", ".Renviron",
    "R/_disable_autoload.R", "R/utils.R", "R/mod_insights.R", "R/mod_kpi.R",
    "R/mod_movement.R", "R/mod_zerodose.R", "R/mod_access.R", "R/mod_report.R",
    "www/styles.css", "data/nomad_data.rds"
  ),
  appName     = "nomad_app_v2",
  account     = "emro-polio-analytics",
  dependencyResolution = "library",
  forceUpdate = TRUE
)
