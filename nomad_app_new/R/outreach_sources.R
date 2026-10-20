write_odk_outreach_csv <- function(data, path = file.path("data", "outreach_ODK.csv")) {
  list_columns <- names(data)[vapply(data, is.list, logical(1))]
  for (field in list_columns) {
    data[[field]] <- vapply(data[[field]], function(value) {
      as.character(jsonlite::toJSON(value, auto_unbox = TRUE, null = "null", na = "null"))
    }, character(1))
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(data, path, row.names = FALSE, na = "")
  invisible(path)
}

read_outreach_sources <- function(live_odk, parse_date) {
  kobo_path <- file.path("data", "kobo_vaccination_data.xlsx")
  kobo <- readxl::read_excel(kobo_path, guess_max = Inf)

  field <- function(data, name, required = TRUE) {
    if (name %in% names(data)) return(data[[name]])
    if (required) stop("Missing outreach field: ", name)
    rep(NA, nrow(data))
  }
  numeric_field <- function(data, name, required = TRUE) {
    suppressWarnings(as.numeric(as.character(field(data, name, required))))
  }

  kobo_records <- tibble::tibble(
    id = paste0("kobo_", as.character(field(kobo, "_id"))),
    source_row = seq_len(nrow(kobo)),
    source = "kobo", source_file = kobo_path,
    a_district = as.character(field(kobo, "District")),
    out_date = parse_date(field(kobo, "today")),
    system_submission_date = lubridate::as_datetime(field(kobo, "_submission_time", FALSE)),
    zd_vaccinated = numeric_field(kobo, "Total number of children vaccinated during the outreach session?"),
    male_children_vaccinated = numeric_field(kobo, "Total number of Male children vaccinated during this outreach session?"),
    female_children_vaccinated = numeric_field(kobo, "Total number of Female children vaccinated during this outreach session?"),
    zd_ri = numeric_field(kobo, "Number of children with zero dose routine immunization (excluding Polio) found in the settlement"),
    zd_polio = numeric_field(kobo, "Number of children with zero polio doses found in the settlement"),
    out_lat = numeric_field(kobo, "_Geo-reference of the settlement outreach_latitude", FALSE),
    out_lon = numeric_field(kobo, "_Geo-reference of the settlement outreach_longitude", FALSE)
  )
  if (!any(!is.na(kobo_records$out_date))) {
    stop("Kobo must contain valid outreach survey dates")
  }
  kobo_cutoff <- max(kobo_records$out_date, na.rm = TRUE)

  live_odk <- live_odk |>
    dplyr::mutate(
      id = as.character(id), source = "odk_live",
      source_file = "ODK Central outreach form",
      source_row = dplyr::row_number(), out_date = parse_date(out_date)
    )
  missing_dates <- c(
    kobo = sum(is.na(kobo_records$out_date)),
    odk_live = sum(is.na(live_odk$out_date))
  )
  if (any(missing_dates > 0)) warning(
    "Outreach rows excluded for missing survey dates: ",
    paste(names(missing_dates), missing_dates, sep = "=", collapse = ", "),
    call. = FALSE
  )
  selected <- dplyr::bind_rows(
    dplyr::filter(kobo_records, !is.na(out_date)),
    dplyr::filter(live_odk, !is.na(out_date), out_date > kobo_cutoff)
  )
  if (any(is.na(selected$id) | trimws(selected$id) == "") || anyDuplicated(selected$id)) {
    stop("Selected outreach records have missing or duplicate submission IDs")
  }
  list(records = selected, kobo_records = kobo_records,
      kobo_cutoff = kobo_cutoff)
}

write_source_audit <- function(camps, outreach, path = "data/data_source_audit.xlsx",
                               camp_cutoff = as.Date("2026-07-31")) {
  camp_records <- camps |>
    dplyr::transmute(
      dataset = "Camp enumeration", submission_id = as.character(id),
      source = data_source,
      source_file = dplyr::if_else(
        data_source == "historical",
        "data/ODK_Data_2024_2025_2026_cleanUp_18Aug26(Survey Data_Clean).csv",
        "ODK Central camp form"
      ),
      survey_date = sub_date, district, year
    )
  outreach_records <- outreach |>
    dplyr::transmute(
      dataset = "Outreach", submission_id = as.character(id), source, source_file,
      source_row, survey_date = out_date, district = out_district, year,
      vaccinated = zd_vaccinated, male_children_vaccinated, female_children_vaccinated,
      zd_ri, zd_polio, lat = out_lat, lon = out_lon
    )
  records <- dplyr::bind_rows(camp_records, outreach_records)
  summary <- records |>
    dplyr::group_by(dataset, source, source_file, year) |>
    dplyr::summarise(
      records = dplyr::n(), first_survey = min(survey_date), last_survey = max(survey_date),
      vaccinated = sum(vaccinated, na.rm = TRUE), .groups = "drop"
    )
  kobo_cutoff <- max(outreach$out_date[outreach$source == "kobo"])
  source_rules <- tibble::tibble(
    dataset = c("Camp enumeration", "Camp enumeration", rep("Outreach", 2)),
    source = c("historical", "odk", "kobo", "odk_live"),
    source_file = c(
      "data/ODK_Data_2024_2025_2026_cleanUp_18Aug26(Survey Data_Clean).csv",
      "ODK Central camp form", "data/kobo_vaccination_data.xlsx",
      "ODK Central outreach form"
    ),
    first_included_date = c(as.Date(NA), camp_cutoff + 1, as.Date(NA),
                            kobo_cutoff + 1),
    last_included_date = c(camp_cutoff, as.Date(NA), kobo_cutoff, as.Date(NA)),
    selected_records = vapply(c("historical", "odk", "kobo", "odk_live"),
                              function(value) sum(records$source == value), integer(1)),
    pulled_at = Sys.time()
  )
  metric_sources <- tibble::tribble(
    ~dashboard_output, ~record_dataset, ~calculation,
    "Zero-dose rate table", "Camp enumeration", "100 * sum(zero-dose age-group count) / sum(age-group population); rounded to 1 decimal; NA if denominator <= 0",
    "Zero-dose status", "Camp enumeration", "Uses rounded 0-11 rate: Critical >=80; High >=60; Moderate >=30; otherwise Low.",
    "Camps enumerated", "Camp enumeration", "Number of survey records, not distinct camp codes",
    "Population / zero-dose KPI", "Camp enumeration", "Estimates based on the sum of reported 0-11 and 12-59 month counts; not headcounts",
    "Movement / access", "Camp enumeration", "Camp survey responses",
    "Vaccinated / sessions KPI", "Outreach", "Sum reported total vaccinated / number of selected sessions",
    "Monthly / district vaccination trends", "Outreach", "Sum reported total vaccinated by session date and district",
    "Outreach map / RI vs polio", "Outreach", "Selected session GPS / reported zero-dose RI and polio counts",
    "District coverage gap", "Both", "max(camp zero-dose 0-11 count - total outreach vaccinated, 0); coverage = 100 * vaccinated / camp zero-dose 0-11 count"
  )
  openxlsx::write.xlsx(
    list(Source_rules = source_rules, Source_summary = summary, Metric_sources = metric_sources,
         Camp_records = camp_records, Outreach_records = outreach_records),
    file = path, overwrite = TRUE, asTable = TRUE
  )
  invisible(summary)
}