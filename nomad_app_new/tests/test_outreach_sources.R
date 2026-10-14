source("R/outreach_sources.R")
source("R/utils.R")
pipeline <- parse("R/data_pull.R")
date_parser <- Filter(function(expr) {
  is.call(expr) && identical(expr[[1]], as.name("<-")) &&
    identical(expr[[2]], as.name("parse_survey_date"))
}, as.list(pipeline))
eval(date_parser[[1]])

live <- tibble::tibble(
  id = c("kobo_overlap", "first_odk", "previous_csv_date", "new_live"),
  out_date = as.Date(c("2026-05-25", "2026-05-26", "2026-10-13", "2026-10-14")),
  zd_vaccinated = c(999, 5, 9, 10), a_district = "Baidoa",
  male_children_vaccinated = 3, female_children_vaccinated = 2,
  system_submission_date = as.POSIXct("2026-10-14", tz = "UTC"),
  zd_ri = 4, zd_polio = 6, out_lat = 3.1, out_lon = 43.6
)
without_csv <- function() {
  original_directory <- getwd()
  test_directory <- tempfile("outreach_sources_")
  dir.create(file.path(test_directory, "data"), recursive = TRUE)
  file.copy("data/kobo_vaccination_data.xlsx", file.path(test_directory, "data"))
  on.exit({
    setwd(original_directory)
    unlink(test_directory, recursive = TRUE)
  })
  setwd(test_directory)
  stopifnot(!file.exists("data/outreach_ODK.csv"))
  result <- read_outreach_sources(live, parse_survey_date)
  download <- live
  download$nested <- rep(list(list(value = "example")), nrow(download))
  write_odk_outreach_csv(download)
  snapshot <- utils::read.csv("data/outreach_ODK.csv")
  stopifnot(nrow(snapshot) == nrow(live), identical(snapshot$id, live$id),
            all(snapshot$nested == '{"value":"example"}'))
  write_odk_outreach_csv(download[1, ])
  stopifnot(nrow(utils::read.csv("data/outreach_ODK.csv")) == 1,
            identical(read_outreach_sources(live, parse_survey_date)$records, result$records))
  result
}
result <- without_csv()
records <- result$records
selected_live <- records[records$source == "odk_live", ]
stopifnot(
  result$kobo_cutoff == as.Date("2026-05-25"),
  sum(records$source == "kobo") == 743,
  nrow(selected_live) == 3,
  sum(selected_live$zd_vaccinated, na.rm = TRUE) == 24,
  min(selected_live$out_date) == result$kobo_cutoff + 1,
  !"kobo_overlap" %in% records$id,
  "previous_csv_date" %in% records$id,
  "new_live" %in% records$id,
  !anyDuplicated(records$id),
  all(selected_live$out_date > result$kobo_cutoff),
  safe_pct(66, 100) == 66,
  is.na(safe_pct(0, 0))
)

outreach <- records |>
  dplyr::mutate(out_district = normalise_district(a_district),
                year = lubridate::year(out_date))
camps <- tibble::tibble(
  id = "historical_1", data_source = "historical",
  sub_date = as.Date("2026-07-31"), district = "Baidoa", year = 2026L
)
audit_path <- tempfile(fileext = ".xlsx")
write_source_audit(camps, outreach, audit_path)
audit <- readxl::read_excel(audit_path, sheet = "Outreach_records")
stopifnot(nrow(audit) == nrow(outreach),
          sum(audit$vaccinated[audit$source == "odk_live"], na.rm = TRUE) == 24)
rules <- readxl::read_excel(audit_path, sheet = "Source_rules")
stopifnot(!"odk_csv" %in% rules$source,
          rules$selected_records[rules$source == "odk_live"] == 3)
unlink(audit_path)
message("PASS: no CSV dependency, fresh snapshot overwrite, live ODK selection and Excel round-trip")