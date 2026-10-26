local({
  original_directory <- getwd()
  test_directory <- tempfile("camp_comparison_")
  dir.create(file.path(test_directory, "R"), recursive = TRUE)
  dir.create(file.path(test_directory, "data"))
  on.exit({
    setwd(original_directory)
    unlink(test_directory, recursive = TRUE)
  }, add = TRUE)
  stopifnot(all(file.copy(
    file.path("R", c("compare.R", "data_pull.R", "utils.R")),
    file.path(test_directory, "R")
  )))

  historical <- data.frame(
    id = paste0("h", 1:8),
    group_profile_today_date = c("2024-01-01", "2025-01-01", "2025-01-02",
                                 "2026-07-31", "2025-03-01", "2026-08-01",
                                 NA, "2026-04-01"),
    group_profile_enumerator_district = c("Luuq", "Luuq", "Baidoa", "Luuq",
                                          "", "Luuq", "Luuq", "Test"),
    community_level_group_group_code = c(
      "LQ-MR-HW-001", "LQ-MR-HW-002", "001", "DLW-MR-RA-001",
      "MR-HW-003", "LQ-MR-HW-001", "LQ-MR-HW-001", "ELW-GR-TUUF-001"
    ),
    polio_camp_pop_0to11_months = c(3, 6, 2, 10, NA, 1000, 1000, 1),
    polio_camp_pop_12to59_months = c(7, 14, 3, 20, 9, 1000, 1000, 1),
    polio_camp_pop_0to11_months_zero_dose = c(1, 2, 1, 2, NA, 1000, 1000, 0),
    polio_camp_pop_12to59_months_zero_dose = c(1, 2, 0, 3, 1, 1000, 1000, 1)
  )
  other_fields <- c(
    "community_level_camp_next_adm3", "community_level_camp_previous_adm3",
    "community_level_camp_last_exit_date", "community_level_camp_first_month",
    "community_level_camp_last_month", "camp_hf_ri_num",
    "community_level_camp_settlement", "community_level_camp_settlement_name",
    "community_level_gps", "polio_camp_tot_pop",
    "polio_camp_previous_service_challenges",
    "transport_type_transport_infrastructure", "transport_type_migratory_route",
    "transport_name_migratory_route"
  )
  for (field in other_fields) historical[[field]] <- ""
  odk <- historical[c(4, 1, 3), ]
  odk$id <- paste0("o", 1:3)
  odk$group_profile_today_date <- c("2026-07-31", "2026-08-01", "2027-01-01")
  odk$community_level_group_group_code <- c("DLW-MR-RA-001", "LQ-MR-HW-003", "")
  odk$polio_camp_pop_0to11_months <- c(9000, 4, 1)
  odk$polio_camp_pop_12to59_months <- c(9000, 6, 3)
  odk$polio_camp_pop_0to11_months_zero_dose <- c(9000, 0, 0)
  odk$polio_camp_pop_12to59_months_zero_dose <- c(9000, 2, 1)
  names(historical) <- gsub("_", "-", names(historical), fixed = TRUE)
  utils::write.csv(historical, file.path(test_directory, "data",
    "ODK_Data_2024_2025_2026_cleanUp_18Aug26(Survey Data_Clean).csv"),
    row.names = FALSE, na = "")
  utils::write.csv(odk, file.path(test_directory, "data", "odk_camps_current.csv"),
                    row.names = FALSE, na = "")
  setwd(test_directory)
  protected_files <- list.files("data", full.names = TRUE)
  before <- tools::md5sum(protected_files)
  result_env <- new.env(parent = globalenv())
  warnings <- character()
  withCallingHandlers(
    source(file.path("R", "compare.R"), local = result_env),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      if (grepl("survey record(s) excluded", conditionMessage(w), fixed = TRUE)) {
        invokeRestart("muffleWarning")
      }
    }
  )
  result <- result_env$enum_vs_group
  csv <- utils::read.csv(file.path("data", "enum_vs_group_comparison.csv"))
  expected_columns <- c(
    "year", "district", "enum_camps", "group_camps", "change_camps",
    "pct_change_camps", "group_unique_codes", "enum_pop", "group_pop",
    "change_pop", "pct_change_pop", "enum_zd", "group_zd", "change_zd", "pct_change_zd"
  )
  stopifnot(
    identical(getwd(), normalizePath(test_directory, winslash = "/")),
    identical(names(csv), expected_columns),
    isTRUE(all.equal(csv, as.data.frame(result))),
    identical(before, tools::md5sum(protected_files)),
    identical(sort(list.files("data")), sort(c(basename(protected_files),
                                               "enum_vs_group_comparison.csv"))),
    any(grepl("2 survey record(s) excluded", warnings, fixed = TRUE)),
    !anyDuplicated(result[c("year", "district")])
  )
  get_row <- function(year, district = "All districts") {
    row <- result[result$year == year & result$district == district, ]
    stopifnot(nrow(row) == 1)
    row
  }
  total <- get_row("All time")
  stopifnot(
    total$enum_camps == 8, total$group_camps == 6, total$group_unique_codes == 4,
    total$change_camps == -2, total$pct_change_camps == -25,
    total$enum_pop == 81, total$group_pop == 72,
    total$enum_zd == 16, total$group_zd == 14,
    get_row("2024")$enum_camps == 1, get_row("2024")$group_camps == 1,
    get_row("2025")$enum_camps == 3, get_row("2025")$group_camps == 2,
    get_row("2026")$enum_camps == 3, get_row("2026")$group_camps == 3,
    get_row("2027")$enum_camps == 1, get_row("2027")$group_camps == 0,
    get_row("2027")$group_unique_codes == 0,
    get_row("2027")$pct_change_camps == -100,
    get_row("All time", "Luuq")$enum_camps == 4,
    get_row("All time", "Luuq")$group_camps == 3,
    get_row("All time", "Luuq")$change_pop == -30,
    get_row("2026", "Dolow")$enum_camps == 0,
    get_row("2026", "Dolow")$group_camps == 1,
    is.na(get_row("2026", "Dolow")$pct_change_camps),
    is.na(get_row("2026", "Dolow")$pct_change_pop),
    get_row("2025", "Baidoa")$group_camps == 0,
    get_row("2025", "Baidoa")$pct_change_camps == -100,
    get_row("All time", "(Missing district)")$enum_camps == 2,
    get_row("All time", "(Missing district)")$group_camps == 1,
    get_row("2025", "(Missing district)")$enum_pop == 0,
    get_row("2025", "(Missing district)")$group_pop == 0
  )
  additive <- c("enum_camps", "group_camps", "enum_pop", "group_pop",
                "enum_zd", "group_zd", "change_camps", "change_pop", "change_zd")
  for (yr in unique(result$year)) {
    districts <- result[result$year == yr & result$district != "All districts", ]
    stopifnot(all(colSums(districts[additive]) == unlist(get_row(yr)[additive])))
  }
  annual <- result[result$year != "All time" & result$district == "All districts", ]
  stopifnot(all(colSums(annual[additive]) == unlist(total[additive])))
  message("PASS: comparable survey counts, distinct groups, year/district changes, ",
          "source cutoffs, missing counts/districts and read-only inputs")
})
