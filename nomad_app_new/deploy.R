library(shiny)

options(repos = c(
  ropensci = "https://ropensci.r-universe.dev",
  CRAN = "https://cloud.r-project.org"
))
library(rsconnect)

local({
  source_files <- Filter(Negate(is.null), lapply(sys.frames(), function(frame) frame$ofile))
  if (length(source_files)) {
    script_file <- tail(source_files, 1)[[1]]
  } else {
    script_args <- grep("^--file=", commandArgs(), value = TRUE)
    if (length(script_args) != 1L) {
      stop("Run deploy.R with source() or Rscript so its app directory can be located.")
    }
    script_file <- sub("^--file=", "", script_args)
  }
  app_dir <- normalizePath(dirname(script_file), mustWork = TRUE)

  # Only ship files needed to run the pre-built dashboard, never local inputs.
  app_files <- c(
    "app.R", "global.R",
    file.path("R", c(
      "_disable_autoload.R", "utils.R", "mod_insights.R", "mod_kpi.R",
      "mod_movement.R", "mod_zerodose.R", "mod_access.R", "mod_report.R"
    )),
    file.path("www", "styles.css"),
    file.path("data", "nomad_data.rds")
  )
  missing <- app_files[!file.exists(file.path(app_dir, app_files))]
  if (length(missing)) {
    stop("Missing deployment files: ", paste(missing, collapse = ", "),
         ". If nomad_data.rds is missing, run refresh_data.R from the app directory first.")
  }

  # shinyapps.io has no envVars support, so the app reads these from a bundled .Renviron.
  # ODK credentials are only needed for local refreshes and are never staged.
  runtime_env_vars <- c("ANTHROPIC_API_KEY", "BASEMAP_API_KEY")

  # Reads an env file without leaving its variables in the current R session.
  read_env_file <- function(path, vars) {
    before <- unclass(Sys.getenv())
    on.exit({
      after <- unclass(Sys.getenv())
      added <- setdiff(names(after), names(before))
      if (length(added)) Sys.unsetenv(added)
      kept <- intersect(names(after), names(before))
      changed <- kept[after[kept] != before[kept]]
      if (length(changed)) do.call(Sys.setenv, as.list(before[changed]))
    }, add = TRUE)
    if (file.exists(path)) readRenviron(path)
    vapply(vars, Sys.getenv, character(1), unset = "")
  }

  local_renviron <- file.path(app_dir, ".Renviron")
  runtime_values <- read_env_file(local_renviron, runtime_env_vars)
  missing_keys <- runtime_env_vars[!nzchar(runtime_values)]
  if (length(missing_keys)) {
    stop("Missing runtime keys: ", paste(missing_keys, collapse = ", "),
         ". Add them to ", local_renviron, " before deploying.")
  }

  staging_dir <- tempfile("nomad_app_v2_bundle_")
  dir.create(staging_dir)
  on.exit(unlink(staging_dir, recursive = TRUE, force = TRUE), add = TRUE)
  for (file in app_files) {
    destination <- file.path(staging_dir, file)
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    if (!file.copy(file.path(app_dir, file), destination)) stop("Could not stage ", file)
  }

  staged_renviron <- file.path(staging_dir, ".Renviron")
  renviron_con <- file(staged_renviron, open = "wb")
  writeLines(sprintf("%s='%s'", runtime_env_vars, runtime_values), renviron_con, sep = "\n", useBytes = TRUE)
  close(renviron_con)
  if (!identical(read_env_file(staged_renviron, runtime_env_vars), runtime_values)) {
    stop("Runtime keys could not be written to the deployment .Renviron unchanged; ",
         "check them for quotes or line breaks.")
  }
  deploy_files <- c(app_files, ".Renviron")

  payload_mb <- sum(file.info(file.path(staging_dir, deploy_files))$size) / 1024^2
  message(sprintf("Deploying %d runtime files (%.2f MiB before packaging) from %s",
                  length(deploy_files), payload_mb, app_dir))
  message("Bundled .Renviron contains only: ", paste(runtime_env_vars, collapse = ", "),
          ". ODK credentials, .RData, raw surveys and reports are excluded.")

  rsconnect::deployApp(
    appDir      = staging_dir,
    appFiles    = deploy_files,
    appName     = "nomad_app_v2",
    account     = "emro-polio-analytics",
    server      = "shinyapps.io",
    recordDir   = app_dir,
    dependencyResolution = "library",
    forceUpdate = TRUE
  )
})
