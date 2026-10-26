# R/compare.R
# ─────────────────────────────────────────────────────────────────────────────
# Compares camp KPIs built from enumerated camp records (the method used before
# group codes) with the current group-code KPIs, overall and by year.
#
#   enum_*        every camp survey record counts as a camp; population and
#                 zero-dose are summed over all records
#   group_*       dashboard KPIs: camps are distinct normalised group codes and
#                 records with unusable codes (data/group_code_exclusions.csv)
#                 are dropped
#   change_*      group_* minus enum_*
#   pct_change_*  change_* as a percentage of enum_*
#
# pop = 0-11 + 12-59 month population; zd = 0-11 + 12-59 month zero-dose.
# Uses the camp data saved by the last refresh (data/odk_camps_current.csv and
# the historical camp CSV) and replays the camp steps of R/data_pull.R, so it
# needs no ODK connection and leaves the refresh outputs untouched.
#
# Run from the nomad_app_new folder:  source("R/compare.R")
# Writes data/enum_vs_group_comparison.csv
# ─────────────────────────────────────────────────────────────────────────────

enum_vs_group <- local({
  app_dir <- Find(function(dir) file.exists(file.path(dir, "R", "data_pull.R")),
                  c(".", "..", "nomad_app_new"))
  if (is.null(app_dir)) {
    stop("Run R/compare.R from the nomad_app_new folder (current directory: ",
         getwd(), ").")
  }
  old_wd <- setwd(app_dir)
  on.exit(setwd(old_wd), add = TRUE)

  odk_camps_path <- "data/odk_camps_current.csv"
  output_path    <- "data/enum_vs_group_comparison.csv"
  if (!file.exists(odk_camps_path)) {
    stop(odk_camps_path, " not found; run source(\"refresh_data.R\") first.")
  }

  # Find the camp loading and cleaning steps by what they assign, not by line
  pipeline <- as.list(parse(
    text = readLines("R/data_pull.R", encoding = "UTF-8", warn = FALSE),
    keep.source = FALSE
  ))
  targets <- vapply(pipeline, function(expr) {
    if (is.call(expr) && identical(expr[[1]], as.name("<-")) && is.name(expr[[2]])) {
      as.character(expr[[2]])
    } else {
      ""
    }
  }, character(1))
  find_step <- function(target, after = 0L, pattern = NULL) {
    hits <- which(targets == target & seq_along(targets) > after)
    if (!is.null(pattern)) {
      hits <- Filter(function(i) {
        grepl(pattern, paste(deparse(pipeline[[i]]), collapse = " "), fixed = TRUE)
      }, hits)
    }
    if (length(hits) == 0) stop("Could not find the `", target, "` step in R/data_pull.R")
    hits[1]
  }
  load_start  <- find_step("historical_camps_path")
  load_end    <- find_step("camps_raw", after = load_start)
  clean_start <- find_step("camps", after = load_end)
  clean_end   <- find_step("camps", after = clean_start,
                           pattern = 'group_code_status == "ok"') - 1L
  steps <- c(which(targets %in% c("rename_flexible", "parse_survey_date")),
             load_start:load_end, clean_start:clean_end)

  env <- new.env(parent = globalenv())
  source("R/utils.R", local = env)
  # Keep the crosswalk and exclusion CSVs from the last refresh untouched
  env$write_csv_safely <- function(...) invisible(FALSE)
  env$camps_raw <- utils::read.csv(odk_camps_path, check.names = FALSE,
                                   colClasses = "character", na.strings = "")
  for (step in pipeline[steps]) eval(step, env)
  camps <- env$camps

  years <- c("All time", sort(unique(as.character(camps$year))))
  comparison <- dplyr::bind_rows(lapply(years, function(yr) {
    enum  <- if (yr == "All time") camps else camps[camps$year %in% as.numeric(yr), ]
    group <- enum[enum$group_code_status %in% "ok", ]
    tibble::tibble(
      year        = yr,
      enum_camps  = nrow(enum),
      group_camps = dplyr::n_distinct(group$group_code),
      enum_pop    = sum(enum$pop_0to11 + enum$pop_12to59, na.rm = TRUE),
      group_pop   = sum(group$pop_0to11 + group$pop_12to59, na.rm = TRUE),
      enum_zd     = sum(enum$zd_0to11 + enum$zd_12to59, na.rm = TRUE),
      group_zd    = sum(group$zd_0to11 + group$zd_12to59, na.rm = TRUE)
    )
  })) |>
    dplyr::transmute(
      year,
      enum_camps, group_camps,
      change_camps     = group_camps - enum_camps,
      pct_change_camps = env$safe_pct(change_camps, enum_camps),
      enum_pop, group_pop,
      change_pop       = group_pop - enum_pop,
      pct_change_pop   = env$safe_pct(change_pop, enum_pop),
      enum_zd, group_zd,
      change_zd        = group_zd - enum_zd,
      pct_change_zd    = env$safe_pct(change_zd, enum_zd)
    )

  message("Enumerated-camp (enum_) vs group-code (group_) KPIs; change = group - enum")
  print(format(as.data.frame(comparison), big.mark = ","), row.names = FALSE)
  utils::write.csv(comparison, output_path, row.names = FALSE)
  message("Saved ", normalizePath(output_path))
  comparison
})
