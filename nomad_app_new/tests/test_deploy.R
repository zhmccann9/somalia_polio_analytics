local({
  app_directory <- normalizePath(".", mustWork = TRUE)
  startup_test <- file.path(app_directory, "tests", "test_startup.R")
  original_repos <- getOption("repos")
  runtime_keys <- c("ANTHROPIC_API_KEY", "BASEMAP_API_KEY")
  odk_keys <- c("ODKC_URL", "ODKC_UN", "ODKC_PW", "ODKC_PID", "ODKC_FID_CAMPS", "ODKC_FID_OUTREACH")
  watched_keys <- c(runtime_keys, odk_keys)
  env_before <- unclass(Sys.getenv())
  restore_env <- function() {
    after <- unclass(Sys.getenv())
    added <- setdiff(names(after), names(env_before))
    if (length(added)) Sys.unsetenv(added)
    kept <- intersect(names(after), names(env_before))
    changed <- c(kept[after[kept] != env_before[kept]], setdiff(names(env_before), names(after)))
    if (length(changed)) do.call(Sys.setenv, as.list(env_before[changed]))
  }
  watched_values <- function() vapply(watched_keys, Sys.getenv, character(1), unset = NA)
  watched_before <- watched_values()

  test_directory <- normalizePath(tempfile("nomad_deploy_"), mustWork = FALSE)
  dir.create(test_directory)
  on.exit({
    setwd(app_directory)
    options(repos = original_repos)
    restore_env()
    unlink(test_directory, recursive = TRUE)
  }, add = TRUE)

  expected <- c(
    "app.R", "global.R",
    file.path("R", c(
      "_disable_autoload.R", "utils.R", "mod_insights.R", "mod_kpi.R",
      "mod_movement.R", "mod_zerodose.R", "mod_access.R", "mod_report.R"
    )),
    file.path("www", "styles.css"),
    file.path("data", "nomad_data.rds")
  )

  # Disposable app copy so the real .Renviron is never read or bundled.
  fake_app <- file.path(test_directory, "app")
  for (file in c(expected, "deploy.R")) {
    destination <- file.path(fake_app, file)
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    stopifnot(file.copy(file.path(app_directory, file), destination))
  }
  fake_app <- normalizePath(fake_app, mustWork = TRUE)
  fake_deploy <- file.path(fake_app, "deploy.R")
  fake_renviron <- file.path(fake_app, ".Renviron")
  fake_values <- c(ANTHROPIC_API_KEY = "fake-anthropic-key", BASEMAP_API_KEY = "fake-basemap-key")
  write_fake_renviron <- function(runtime_lines) {
    writeLines(c(
      "ODKC_URL=https://odk.example.invalid",
      "ODKC_UN=fake-user",
      "ODKC_PW=fake-password",
      "ODKC_PID=1",
      "ODKC_FID_CAMPS=fake-camps",
      "ODKC_FID_OUTREACH=fake-outreach",
      runtime_lines
    ), fake_renviron)
  }
  write_fake_renviron(sprintf('%s="%s"', names(fake_values), fake_values))

  bundle_directory <- file.path(test_directory, "bundle")
  captured <- new.env(parent = emptyenv())
  trace("deployApp", where = asNamespace("rsconnect"), print = FALSE,
        tracer = substitute({
          # Snapshot the temporary staging directory before deploy.R removes it.
          dir.create(bundle_directory)
          file.copy(list.files(appDir, all.files = TRUE, no.. = TRUE, full.names = TRUE),
                    bundle_directory, recursive = TRUE)
          assign("staged_files", rsconnect::listDeploymentFiles(appDir, appFiles = appFiles),
                 envir = captured)
          assign("args", list(
            appDir = appDir, appFiles = appFiles, appName = appName,
            account = account, server = server, recordDir = recordDir,
            dependencyResolution = dependencyResolution, forceUpdate = forceUpdate
          ), envir = captured)
          stop(structure(
            list(message = "Deployment intercepted before any network calls", call = NULL),
            class = c("deployment_intercepted", "error", "condition")
          ))
        }, list(captured = captured, bundle_directory = bundle_directory)))
  on.exit(untrace("deployApp", where = asNamespace("rsconnect")), add = TRUE)

  run_deploy <- function() {
    tryCatch({
      source(fake_deploy, local = new.env(parent = globalenv()))
      NULL
    }, deployment_intercepted = function(e) NULL, error = identity)
  }

  setwd(test_directory)
  deploy_error <- run_deploy()
  if (!is.null(deploy_error)) stop(deploy_error)
  args <- captured$args
  stopifnot(
    !is.null(args),
    identical(normalizePath(args$recordDir), fake_app),
    !identical(normalizePath(args$appDir, mustWork = FALSE), fake_app),
    !dir.exists(args$appDir),
    identical(normalizePath(getwd()), test_directory),
    identical(args$appName, "nomad_app_v2"),
    identical(args$account, "emro-polio-analytics"),
    identical(args$server, "shinyapps.io"),
    identical(args$dependencyResolution, "library"),
    isTRUE(args$forceUpdate),
    identical(watched_values(), watched_before)
  )

  files <- captured$staged_files
  stopifnot(
    setequal(args$appFiles, c(expected, ".Renviron")),
    setequal(files, c(expected, ".Renviron")),
    length(files) == length(expected) + 1L,
    !any(basename(files) %in% c(".RData", "odk_credentials.R", "environ_gen_somalia.R", "deploy.R")),
    !any(grepl("^(media|tests|rsconnect)/|[.]csv$|[.]xlsx$|data_pull[.]R$", files))
  )

  staged_renviron <- file.path(bundle_directory, ".Renviron")
  staged_lines <- readLines(staged_renviron)
  staged_bytes <- readBin(staged_renviron, "raw", file.size(staged_renviron))
  stopifnot(
    identical(staged_lines, sprintf("%s='%s'", names(fake_values), fake_values)),
    !any(grepl("ODKC|fake-password", staged_lines)),
    !any(staged_bytes == as.raw(13))
  )

  # Mimic the server: no keys in the session until global.R reads the bundle.
  Sys.unsetenv(watched_keys)
  setwd(bundle_directory)
  source(startup_test)
  stopifnot(
    identical(vapply(runtime_keys, Sys.getenv, character(1), unset = ""), fake_values),
    !any(nzchar(vapply(odk_keys, Sys.getenv, character(1), unset = "")))
  )
  restore_env()
  setwd(test_directory)

  archive <- file.path(test_directory, "runtime.tar.gz")
  local({
    setwd(bundle_directory)
    on.exit(setwd(test_directory), add = TRUE)
    utils::tar(archive, files = files, compression = "gzip", tar = "internal")
  })
  archive_files <- utils::untar(archive, list = TRUE, tar = "internal")
  stopifnot(setequal(archive_files, files))
  message(sprintf("Runtime payload: %d files, %.2f MiB compressed (before deployment metadata)",
                  length(files), file.info(archive)$size / 1024^2))

  # Missing runtime keys stop before deployment, even if the session lacks them too.
  write_fake_renviron(sprintf('ANTHROPIC_API_KEY="%s"', fake_values[["ANTHROPIC_API_KEY"]]))
  Sys.unsetenv(runtime_keys)
  captured$args <- NULL
  missing_key_error <- run_deploy()
  stopifnot(
    inherits(missing_key_error, "error"),
    grepl("Missing runtime keys: BASEMAP_API_KEY", conditionMessage(missing_key_error), fixed = TRUE),
    !grepl("fake-anthropic-key", conditionMessage(missing_key_error), fixed = TRUE),
    is.null(captured$args)
  )
  restore_env()

  write_fake_renviron(c(
    sprintf('ANTHROPIC_API_KEY="%s"', fake_values[["ANTHROPIC_API_KEY"]]),
    "BASEMAP_API_KEY=\"bad'key\""
  ))
  bad_key_error <- run_deploy()
  stopifnot(
    inherits(bad_key_error, "error"),
    grepl("could not be written", conditionMessage(bad_key_error), fixed = TRUE),
    is.null(captured$args)
  )

  write_fake_renviron(sprintf('%s="%s"', names(fake_values), fake_values))
  unlink(file.path(fake_app, "data", "nomad_data.rds"))
  missing_rds_error <- run_deploy()
  stopifnot(
    inherits(missing_rds_error, "error"),
    grepl("Missing deployment files", conditionMessage(missing_rds_error), fixed = TRUE),
    grepl("nomad_data.rds", conditionMessage(missing_rds_error), fixed = TRUE),
    is.null(captured$args),
    identical(watched_values(), watched_before)
  )
  message("PASS: runtime allowlist, minimal staged .Renviron (runtime keys only), deployment record dir, ",
          "staging cleanup, staged app startup with keys, archive contents and missing-key/RDS guards; ",
          "no upload attempted")
})
