source("R/utils.R")

expect_codes <- function(raw, expected, fallback = NA_character_) {
  result <- normalise_group_codes(raw, fallback)
  ok <- identical(result$group_code, expected)
  if (!ok) {
    print(data.frame(raw = raw, expected = expected, actual = result$group_code))
    stop("group code normalisation mismatch", call. = FALSE)
  }
  invisible(result)
}

# Abbreviations, full names, separators and trailing numbers pool together
expect_codes(
  c("LQ-MR-HW-001", "Luuq-Marehan-Horarsame-001", "LQ- MR- HRSM -002", "Luuq_marexaan_howrarsame 003"),
  rep("LQ-MR-HOWRARSAME", 4)
)
expect_codes(
  c("DLW MR Rer Ahmed001", "DLW_MR_Rer_Amed_002", "DLW MR Ree Axmd001", "Dolow-marehan-reer axmed-004"),
  rep("DLW-MR-REER AHMED", 4)
)
expect_codes(
  c("Belet-hawa, MR, Rer dinin, 001", "BLW-MR-RD-002"),
  rep("BLW-MR-REER DIINI", 2)
)
expect_codes(c("Elwak-Gr-Tuuf-001", "ELW-GR-TUUF 002"), rep("ELW-GR-TUUF", 2))
expect_codes(c("Br-mr-Rerxasn001", "BDD-MR-rer hssan-002"), c("BR-MR-REER HASSAN", "BDD-MR-REER HASSAN"))

# Clan-like near misses do not override known sub-clans or other words
expect_codes("DLW gabaaweyn 002", "DLW-JW-GAWAWEYN")
expect_codes("GBh-marehan -Rersiyaad -003 warcilaan", "GBH-MR-REER SIYAAD-WARCILAAN")

# Short abbreviations are not merged through the phonetic key (MQ != MK)
expect_codes("BDD-OG-MQ-MK-000", "BDD-OG-MK-MQ")

# Codes without a district use the enumerator district
result <- expect_codes(c("Marexaan-reer garad-001", "El-mr-tlx002"),
                       c("BR-MR-REER GARAD", "ELW-MR-TALXE"),
                       fallback = c("Bardera", "Elwak"))
stopifnot(identical(result$group_district, c("Baardhere", "Elwak")),
          identical(result$group_district_source, c("enumerator", "enumerator")))
stopifnot(identical(normalise_group_codes("LQ-MR-HW-001", "Dolow")$group_district, "Luuq"))

# Number-only, blank and unidentifiable codes are flagged and excluded
excluded <- normalise_group_codes(c("001", "OO2", " ", NA, "Belet xawa 000", "Others", "Dlw_"))
stopifnot(
  all(is.na(excluded$group_code)),
  identical(excluded$group_code_status,
            c("numeric_only", "numeric_only", "blank", "blank",
              "no_group_identity", "no_group_identity", "no_group_identity"))
)

cat("Group code tests passed\n")
