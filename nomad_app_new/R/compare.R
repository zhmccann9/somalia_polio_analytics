# Compare camp-survey records before and after group-code exclusions.
# Run from the app directory: source(file.path("R", "compare.R"))
# Uses saved camp CSVs; writes only data/enum_vs_group_comparison.csv.
# enum_camps and group_camps count records, not unique physical camps.
# group_unique_codes preserves the distinct-group count used by the dashboard.
# Population and zero-dose remain sums of the 0-11 + 12-59 month counts.

enum_vs_group <- local({
  app_dir <- Find(function(dir) file.exists(file.path(dir, "R", "data_pull.R")),
                  c(".", "..", "nomad_app_new"))
  if (is.null(app_dir)) {
    stop("Run compare.R from the nomad_app_new folder (current directory: ",
         getwd(), ").")
  }
  old_wd <- setwd(app_dir)
  on.exit(setwd(old_wd), add = TRUE)

  odk_camps_path <- file.path("data", "odk_camps_current.csv")
  output_path <- file.path("data", "enum_vs_group_comparison.csv")
  if (!file.exists(odk_camps_path)) {
    stop(odk_camps_path, " not found; run refresh_data.R first.")
  }

  # Reuse the pipeline's loading and cleaning expressions, without fetching
  # ODK data or executing its exports. Step names avoid fixed line numbers.
  pipeline <- as.list(parse(
    text = readLines(file.path("R", "data_pull.R"), encoding = "UTF-8", warn = FALSE),
    keep.source = FALSE
  ))
  targets <- vapply(pipeline, function(expr) {
    if (is.call(expr) && identical(expr[[1]], as.name("<-")) && is.name(expr[[2]])) {
      as.character(expr[[2]])
    } else {
      ""
    }
  }, character(1))
  find_step <- function(target, after = 0L) {
    hits <- which(targets == target & seq_along(targets) > after)
    if (length(hits) == 0) {
      stop("Could not find the `", target, "` step in data_pull.R.")
    }
    hits[1]
  }
  load_start <- find_step("historical_camps_path")
  load_end <- find_step("camps_raw", after = load_start)
  clean_start <- find_step("camps", after = load_end)
  clean_end <- find_step("camps", after = find_step("group_codes", after = clean_start))
  steps <- c(find_step("rename_flexible"), find_step("parse_survey_date"),
             load_start:load_end, clean_start:clean_end)

  env <- new.env(parent = globalenv())
  source(file.path("R", "utils.R"), local = env)
  env$camps_raw <- utils::read.csv(odk_camps_path, check.names = FALSE,
                                  colClasses = "character", na.strings = "")
  for (step in pipeline[steps]) eval(step, env)
  camps <- env$camps
  required <- c("year", "enum_district", "district", "group_code_status",
                "group_code", "pop_0to11", "pop_12to59", "zd_0to11", "zd_12to59")
  missing <- setdiff(required, names(camps))
  if (length(missing)) {
    stop("Camp cleaning did not produce required columns: ",
         paste(missing, collapse = ", "))
  }
  if (anyNA(camps$year) || anyNA(camps$group_code_status)) {
    stop("Cleaned camp records have missing years or group-code statuses.")
  }
  valid <- camps$group_code_status == "ok"
  if (any(is.na(camps$group_code[valid]) | !nzchar(trimws(camps$group_code[valid])))) {
    stop("Camp records marked 'ok' have missing group codes.")
  }
  if (any(!valid)) {
    warning(sum(!valid), " survey record(s) excluded from group_ values for ",
            "unusable group codes.", call. = FALSE)
  }

  # Keep unassigned districts so district totals reconcile with overall KPIs.
  district_label <- function(x) {
    x <- trimws(as.character(x))
    x[is.na(x) | x == ""] <- "(Missing district)"
    x
  }
  camps$enum_district <- district_label(camps$enum_district)
  camps$district <- district_label(camps$district)
  years <- c("All time", sort(unique(as.character(camps$year))))

  comparison <- dplyr::bind_rows(lapply(years, function(yr) {
    enum <- if (yr == "All time") camps else camps[camps$year %in% as.numeric(yr), ]
    group <- enum[enum$group_code_status == "ok", ]
    summarise_pair <- function(enum, group, district) {
      tibble::tibble(
        year = yr,
        district = district,
        enum_camps = nrow(enum),
        group_camps = nrow(group),
        group_unique_codes = dplyr::n_distinct(group$group_code),
        enum_pop = sum(enum$pop_0to11 + enum$pop_12to59, na.rm = TRUE),
        group_pop = sum(group$pop_0to11 + group$pop_12to59, na.rm = TRUE),
        enum_zd = sum(enum$zd_0to11 + enum$zd_12to59, na.rm = TRUE),
        group_zd = sum(group$zd_0to11 + group$zd_12to59, na.rm = TRUE)
      )
    }
    districts <- sort(unique(c(enum$enum_district, group$district)))
    dplyr::bind_rows(
      summarise_pair(enum, group, "All districts"),
      lapply(districts, function(district) {
        summarise_pair(
          enum[enum$enum_district == district, ],
          group[group$district == district, ],
          district
        )
      })
    )
  })) |>
    dplyr::transmute(
      year, district,
      enum_camps, group_camps,
      change_camps = group_camps - enum_camps,
      pct_change_camps = env$safe_pct(change_camps, enum_camps),
      group_unique_codes,
      enum_pop, group_pop,
      change_pop = group_pop - enum_pop,
      pct_change_pop = env$safe_pct(change_pop, enum_pop),
      enum_zd, group_zd,
      change_zd = group_zd - enum_zd,
      pct_change_zd = env$safe_pct(change_zd, enum_zd)
    )

  message("Camp-survey records: enum_ versus group_; change = group - enum.")
  message("Districts use enumerator versus group-code assignment; district changes ",
          "include reassignments as well as exclusions.")
  print(format(as.data.frame(comparison), big.mark = ","), row.names = FALSE)
  utils::write.csv(comparison, output_path, row.names = FALSE, na = "NA")
  message("Saved ", normalizePath(output_path))
  comparison
})
