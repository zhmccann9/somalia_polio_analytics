local({
  trace("install.packages", where = asNamespace("utils"),
        tracer = quote(stop("Unexpected package installation during startup")), print = FALSE)
  on.exit(untrace("install.packages", where = asNamespace("utils")), add = TRUE)
  trace("odata_submission_get", where = asNamespace("ruODK"),
        tracer = quote(stop("Unexpected ODK fetch during startup")), print = FALSE)
  on.exit(untrace("odata_submission_get", where = asNamespace("ruODK")), add = TRUE)

  app <- shiny::shinyAppDir(".")
  stopifnot(inherits(app, "shiny.appobj"))
  files <- rsconnect::listDeploymentFiles(".")
  stopifnot(all(c("R/_disable_autoload.R", "global.R", "data/nomad_data.rds") %in% files))
  message("PASS: Shiny entry-point startup and deployment files; no ODK fetch or installation")
})