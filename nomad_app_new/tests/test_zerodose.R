library(shiny)
source("R/mod_zerodose.R")

legacy_data <- list(
  camp_gps = data.frame(
    district = c("Luuq", "Dolow"), year = c(2025L, 2026L),
    lat = c(3.8, 4.1), lon = c(42.5, 42.1),
    zd_0to11 = c(2, 3), zd_12to59 = c(4, 5)
  ),
  out_gps = data.frame(
    district = "Luuq", year = 2025L, lat = 3.8, lon = 42.5,
    vaccinated = 7, month_label = "Jan 2025"
  ),
  zd_by_dist = list(all = data.frame(
    district = "Luuq", camps = 2L, z011 = 2, z1259 = 4,
    rate011 = 20, rate1259 = 40
  )),
  zd_ri_pol = list(all = data.frame(district = "Luuq", ri = 2, pol = 1)),
  out_monthly = data.frame(
    year = 2025L, month_label = "Jan 2025", sessions = 1L, vaccinated = 7
  ),
  dist_monthly = data.frame(
    year = 2025L, month_label = "Jan 2025", out_district = "Luuq", vaccinated = 7
  )
)

group_data <- legacy_data
group_data$camp_gps$group_code <- c("LQ-MR-HOWRARSAME", "DLW-MR-REER AHMED")
group_data$zd_by_group <- list(all = data.frame(
  group_code = "LQ-MR-HOWRARSAME", district = "Luuq", visits = 2L,
  z011 = 2, z1259 = 4, rate011 = 20, rate1259 = 40
))
group_data$group_code_exclusions <- data.frame(sub_date = as.Date("2025-01-01"))

check_zerodose <- function(data, grouped) {
  captured <- new.env(parent = emptyenv())
  captured$messages <- list()
  captured$notifications <- list()
  mock <- shiny::MockShinySession$new()
  on.exit(mock$close())
  mock$sendCustomMessage <- function(type, message) {
    if (identical(type, "leaflet-calls")) {
      captured$messages[[length(captured$messages) + 1L]] <- message
    }
  }
  mock$sendNotification <- function(type, message) {
    captured$notifications[[length(captured$notifications) + 1L]] <-
      list(type = type, message = message)
  }

  marker_calls <- function(group) {
    calls <- unlist(lapply(captured$messages, function(message) message$calls), recursive = FALSE)
    Filter(function(call) {
      identical(call$method, "addCircleMarkers") && identical(call$args[[5]], group)
    }, calls)
  }
  labels <- function(group) {
    calls <- marker_calls(group)
    stopifnot(length(calls) == 1L)
    unlist(calls[[1]]$args[[11]], use.names = FALSE)
  }

  shiny::testServer(
    zerodose_server,
    args = list(data = data, year_filter = function() "all"),
    session = mock,
    expr = {
      session$setInputs(gap_yr = "all", gap_mo = "all")
      stopifnot(!session$isClosed())
      expected <- c("Luuq | ZD: 6", "Dolow | ZD: 8")
      if (grouped) expected <- paste0(data$camp_gps$group_code, " | ", expected)
      stopifnot(identical(labels("zd_pts"), expected),
                length(labels("out_pts")) == 1L)

      rates <- output$zd_rate_table_ui$html
      groups <- output$zd_group_table_ui$html
      if (grouped) {
        stopifnot(grepl(">Groups<", rates, fixed = TRUE),
                  grepl("LQ-MR-HOWRARSAME", groups, fixed = TRUE),
                  length(captured$notifications) == 0L,
                  grepl("1 record(s) excluded", output$group_excluded_label$html, fixed = TRUE))
      } else {
        stopifnot(grepl(">Camps<", rates, fixed = TRUE),
                  grepl("refresh_data.R", groups, fixed = TRUE),
                  length(captured$notifications) == 1L,
                  identical(captured$notifications[[1]]$message$type, "warning"),
                  grepl("refresh_data.R", captured$notifications[[1]]$message$html, fixed = TRUE))
      }

      captured$messages <- list()
      session$setInputs(gap_yr = "2025", gap_mo = "Jan 2025")
      stopifnot(!session$isClosed(),
                identical(labels("zd_pts"), expected[1]),
                length(labels("out_pts")) == 1L)

      captured$messages <- list()
      session$setInputs(gap_mo = "Feb 2025")
      stopifnot(identical(labels("zd_pts"), expected[1]),
                length(marker_calls("out_pts")) == 0L)

      captured$messages <- list()
      session$setInputs(gap_yr = "2024")
      stopifnot(!session$isClosed(),
                length(marker_calls("zd_pts")) == 0L,
                length(marker_calls("out_pts")) == 0L)
    }
  )
}

check_zerodose(legacy_data, grouped = FALSE)
check_zerodose(group_data, grouped = TRUE)

cat("Zero-dose module tests passed: legacy cache, group codes and map filters\n")
