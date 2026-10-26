# R/utils.R
# Shared helpers and crosswalk tables

# ── District name crosswalk ────────────────────────────────────────────────────
# Left  = raw value as it may appear in ODK data
# Right = canonical name matching ArcGIS PHB 2026 shapefile
# Add / correct entries here after inspecting your actual data
DISTRICT_CROSSWALK <- c(
  # ── Baardhere / Bardera ──────────────────────────────────────────────────
  "Baardheer"          = "Baardhere",
  "baardheere"         = "Baardhere",
  "Baardheere"         = "Baardhere",
  "Baardheere "        = "Baardhere",
  "Baardhera"          = "Baardhere",
  "Baardhera "         = "Baardhere",
  "Baardhere "         = "Baardhere",
  "Baardhere garilley" = "Baardhere",
  "Bardheere"          = "Baardhere",
  "Bardheere "         = "Baardhere",
  "Bardhere"           = "Baardhere",
  "Bardhere "          = "Baardhere",
  "Bardera"            = "Baardhere",
  "BARDERA"            = "Baardhere",
  "bardera"            = "Baardhere",
  "bardera "           = "Baardhere",
  "Bardera "           = "Baardhere",
  "Bardera hospital"   = "Baardhere",
  "Bardere"            = "Baardhere",
  "Bardhale"           = "Baardhere",
  "Bardhale "          = "Baardhere",
  "Bardaale"           = "Baardhere",
  "Bardale"            = "Baardhere",
  "Bardale "           = "Baardhere",
  "Bardalle"           = "Baardhere",
  "Bardheera"          = "Baardhere",
  "Bardhera"           = "Baardhere",
  "Bardhera "          = "Baardhere",
  "Badheere"           = "Baardhere",
  "gedo_bardheere"     = "Baardhere",
  # ── Badhadhe ─────────────────────────────────────────────────────────────
  "Badhadhe"           = "Badhadhe",
  "Badhadhe "          = "Badhadhe",
  "BADHADHE"           = "Badhadhe",
  "Badhaadhe"          = "Badhadhe",
  "Badhaade"           = "Badhadhe",
  "Badhaadha"          = "Badhadhe",
  "BADHAADHE"          = "Badhadhe",
  "BADHADHE"           = "Badhadhe",
  # ── Belet-hawa ───────────────────────────────────────────────────────────
  "Belet-hawa"         = "Belet-hawa",
  "Belet-hawa "        = "Belet-hawa",
  "belet-hawa"         = "Belet-hawa",
  "BELET HAWA"         = "Belet-hawa",
  "Balat-hawa"         = "Belet-hawa",
  "Balat-hawa "        = "Belet-hawa",
  "Balathawa"          = "Belet-hawa",
  "balat-hawa "        = "Belet-hawa",
  "Balet-hawa"         = "Belet-hawa",
  "Balet xaw"          = "Belet-hawa",
  "Balet xawa"         = "Belet-hawa",
  "Balad hawa"         = "Belet-hawa",
  "Balad hawo "        = "Belet-hawa",
  "baladhawo"          = "Belet-hawa",
  "Baladxaawo"         = "Belet-hawa",
  "baladxawo"          = "Belet-hawa",
  "Baladxawo"          = "Belet-hawa",
  "Baladxawo "         = "Belet-hawa",
  "Bele-hawo"          = "Belet-hawa",
  "Bele xawa"          = "Belet-hawa",
  "Beled xawo"         = "Belet-hawa",
  "belet cawo"         = "Belet-hawa",
  "belet hawa"         = "Belet-hawa",
  "Belet-hawo"         = "Belet-hawa",
  "Belet-xawa"         = "Belet-hawa",
  "Belet -hawa"        = "Belet-hawa",
  "belet xawo"         = "Belet-hawa",
  "Belet xawa"         = "Belet-hawa",
  "Belet xawo"         = "Belet-hawa",
  "Belet_hawa"         = "Belet-hawa",
  "Belete xawo"        = "Belet-hawa",
  "belethawa"          = "Belet-hawa",
  "Belethawa"          = "Belet-hawa",
  "Belethawa "         = "Belet-hawa",
  "Beletxawa"          = "Belet-hawa",
  "beletxawa "         = "Belet-hawa",
  "Bled xawa"          = "Belet-hawa",
  "Bulaxawo"           = "Belet-hawa",
  "Beledxawa"          = "Belet-hawa",
  " Belet-hawa "       = "Belet-hawa",
  "Balat-hawa "        = "Belet-hawa",
  "BELET HAWA"         = "Belet-hawa",
  # ── Beledweyne ───────────────────────────────────────────────────────────
  "Beledweyne"         = "Beledweyne",
  "Beledweyne "        = "Beledweyne",
  "Beledweyn"          = "Beledweyne",
  "Beledweyn "         = "Beledweyne",
  "Baledweyn"          = "Beledweyne",
  "Beletweyn"          = "Beledweyne",
  "Beletweyn "         = "Beledweyne",
  "BELET WEYNE"        = "Beledweyne",
  "Beled Weyne"        = "Beledweyne",
  "Baladweyne"         = "Beledweyne",
  "Baladweyne "        = "Beledweyne",
  # ── Dolow ─────────────────────────────────────────────────────────────────
  "Dolow"              = "Dolow",
  "Dolow "             = "Dolow",
  "dolow"              = "Dolow",
  "DOLOW"              = "Dolow",
  "Dollow"             = "Dolow",
  "dollow"             = "Dolow",
  "Doolow"             = "Dolow",
  "DOLO"               = "Dolow",
  "Doloow"             = "Dolow",
  "Doloow "            = "Dolow",
  "Dolw"               = "Dolow",
  "DOLW"               = "Dolow",
  "Dalaw"              = "Dolow",
  "Dalaw "             = "Dolow",
  "Dalow"              = "Dolow",
  "Dalow "             = "Dolow",
  "Dlow"               = "Dolow",
  "DLOW"               = "Dolow",
  "Dlow "              = "Dolow",
  "Dolaw"              = "Dolow",
  "Dolaw "             = "Dolow",
  " Doloow "           = "Dolow",
  # ── Elwak ────────────────────────────────────────────────────────────────
  "Elwak"              = "Elwak",
  "Elwak "             = "Elwak",
  "ELWAK"              = "Elwak",
  "EL WAK"             = "Elwak",
  "Elwaq"              = "Elwak",
  "Elewak"             = "Elwak",
  "Elwaka"             = "Elwak",
  "Ceel waaq"          = "Elwak",
  "Celwaaq"            = "Elwak",
  "Celwaaq "           = "Elwak",
  "Celwaq"             = "Elwak",
  "Celwaq "            = "Elwak",
  "Celwa"              = "Elwak",
  # ── El Barde ──────────────────────────────────────────────────────────────
  "El Barde"           = "El Barde",
  "EL BARDE"           = "El Barde",
  "Elbarde"            = "El Barde",
  "Elbarde "           = "El Barde",
  "elbarde"            = "El Barde",
  "El-berde"           = "El Barde",
  "Ceelbarde"          = "El Barde",
  "Celbarde"           = "El Barde",
  "Celbarde "          = "El Barde",
  "El-barde"           = "El Barde",
  # ── Garbaharey ────────────────────────────────────────────────────────────
  "Garbaharey"         = "Garbaharey",
  "Garbaharey "        = "Garbaharey",
  "GARBAHAREY"         = "Garbaharey",
  "Gabaharey"          = "Garbaharey",
  "Garbaherey"         = "Garbaharey",
  "Garbahrey"          = "Garbaharey",
  "Garbareey"          = "Garbaharey",
  "Garbareey "         = "Garbaharey",
  "Karbareey"          = "Garbaharey",
  "Gaebaharey"         = "Garbaharey",
  # ── Luuq ──────────────────────────────────────────────────────────────────
  "Luuq"               = "Luuq",
  "Luuq "              = "Luuq",
  "LUUQ"               = "Luuq",
  "Luq"                = "Luuq",
  "Luup"               = "Luuq",
  "Luuuq"              = "Luuq",
  " Luuq "             = "Luuq",
  "Luuq District"      = "Luuq",
  "Galweyn luuq"       = "Luuq",
  # ── Baidoa ────────────────────────────────────────────────────────────────
  "Baidoa"             = "Baidoa",
  "Baidoa "            = "Baidoa",
  "BAIDOA"             = "Baidoa",
  "Baidoa Somalia"     = "Baidoa",
  "Baydhabo"           = "Baidoa",
  "Baydhabo "          = "Baidoa",
  # ── Burdhubo ──────────────────────────────────────────────────────────────
  "Burdhubo"           = "Burdhubo",
  "Burdhubo "          = "Burdhubo",
  "Buurdhuubo"         = "Burdhubo",
  "Buurdhuubo "        = "Burdhubo",
  # ── Aden Yabaal ───────────────────────────────────────────────────────────
  "Adan yabal"         = "Aden Yabaal",
  "Aden Yabaal"        = "Aden Yabaal",
  " Adan yabal"        = "Aden Yabaal",
  "Aden yabaal"        = "Aden Yabaal",
  # ── Afgooye ───────────────────────────────────────────────────────────────
  "Afgooye"            = "Afgooye",
  "Afgoye"             = "Afgooye",
  # ── Junk / unresolvable → NA ──────────────────────────────────────────────
  "N/A"                = NA_character_,
  "NA"                 = NA_character_,
  "N a"                = NA_character_,
  "Na"                 = NA_character_,
  "n"                  = NA_character_,
  "B"                  = NA_character_,
  "H"                  = NA_character_,
  "MA"                 = NA_character_,
  "Yg"                 = NA_character_,
  "Because"            = NA_character_,
  "Heheheh"            = NA_character_,
  "Hhh"                = NA_character_,
  "0623344554"         = NA_character_,
  "Elw-Gr-001"         = NA_character_,
  "BLW-"               = NA_character_,
  "Sinai"              = NA_character_,
  "Hiiraan"            = NA_character_,
  "Gedo"               = NA_character_,
  "Gedo "              = NA_character_,
  "Bay"                = NA_character_,
  "Bakol"              = NA_character_
)

normalise_district <- function(x) {
  x_trimmed <- trimws(as.character(x))
  mapped <- dplyr::case_when(
    tolower(x_trimmed) == "test" ~ NA_character_,
    x_trimmed %in% names(DISTRICT_CROSSWALK) ~ unname(DISTRICT_CROSSWALK[x_trimmed]),
    TRUE ~ x_trimmed
  )
  # Title-case fallback for ALL CAPS or all lowercase (length > 2)
  needs_case <- !is.na(mapped) &
    (mapped == toupper(mapped) | mapped == tolower(mapped)) &
    nchar(mapped) > 2
  mapped[needs_case] <- tools::toTitleCase(tolower(mapped[needs_case]))
  as.character(mapped)
}

# ── Group code normalisation ──────────────────────────────────────────────────
# Group codes are free text meant to read DISTRICT-CLAN-SUBCLAN-NNN, but are
# entered with mixed separators, abbreviations and Somali spelling variants
# (e.g. "LQ-MR-HW-001", "Luuq-Marehan-Horarsame-001"). Codes are tokenised,
# abbreviations are matched exactly and names are matched with a Somali
# phonetic key plus edit distance. Unrecognised names are clustered the same
# way. The trailing number is dropped, so a group is DISTRICT-CLAN-SUBCLAN.

GROUP_CODE_DISTRICTS <- c(
  BAI = "Baidoa",     BDD = "Badhadhe",   BLW = "Belet-hawa", BR  = "Baardhere",
  DLW = "Dolow",      ELW = "Elwak",      ELB = "El Barde",   GBH = "Garbaharey",
  LQ  = "Luuq",       BW  = "Beledweyne", AY  = "Aden Yabaal", AFG = "Afgooye",
  BDB = "Burdhubo"
)

.gc_alias_table <- function(aliases) {
  data.frame(
    code  = rep(names(aliases), lengths(aliases)),
    alias = unlist(aliases, use.names = FALSE),
    stringsAsFactors = FALSE
  )
}

GROUP_CODE_DISTRICT_ALIASES <- .gc_alias_table(list(
  BAI = c("BAI", "BAY", "BAIDOA", "BAYDHABO"),
  BDD = c("BDD", "BADHADHE", "BADHAADHE"),
  BLW = c("BLW", "BHL", "BLH", "BL", "BELETHAWA", "BELEDHAWO", "BALADHAWO",
          "BALADHAWA", "BULAXAWO"),
  BR  = c("BR", "BRD", "BARDERA", "BARDHERE", "BAARDHEERE"),
  DLW = c("DLW", "DL", "DLD", "DLO", "DOL", "DWL", "WLD", "WDL", "DOW", "DOLOW"),
  ELW = c("ELW", "EWL", "ELWAK", "CEELWAAQ"),
  ELB = c("ELB", "ALB", "ABL", "ELBARDE", "CEELBARDE"),
  GBH = c("GBH", "GHB", "GBHB", "CBH", "GBR", "GRBHY", "GARBAHAREY"),
  LQ  = c("LQ", "LUQ", "LUU", "LUG", "LUUQ"),
  BW  = c("BW", "BELEDWEYNE"),
  AY  = c("ADENYABAAL"),
  AFG = c("AFGOOYE"),
  BDB = c("BURDHUBO")
))

GROUP_CODE_CLAN_ALIASES <- .gc_alias_table(list(
  MR  = c("MR", "MRR", "MAR", "RM", "MAREHAN", "MAREXAAN", "MARIXAN", "MERHAN"),
  RW  = c("RW", "RX", "RAX", "RHW", "RHWN", "RWH", "RWN", "RWYN", "RA",
          "RAHWEYN", "RAXAWEYN", "RAHAWEEN", "RAHAWAYN", "RARAXWEN", "RAHWEY"),
  OG  = c("OG", "OGADEN", "OGAADEN"),
  GR  = c("GR", "GARRE", "GARRA"),
  HW  = c("HW", "HAWIYE"),
  MJ  = c("MJ", "MAJEERTEEN"),
  JW  = c("JW", "JAREERWEYN", "JARERWEYNE"),
  DIR = c("DIR", "DIIR", "DIRR"),
  DRD = c("DAROOD", "DAAROOD"),
  SKH = c("SHKH", "SHKHL", "SHEEKHAL", "SHIIQAL", "SHEIKHAL")
))

.gc_seed <- function(clan, name, ...) {
  data.frame(clan = clan, name = name, variant = c(name, ...),
             stringsAsFactors = FALSE)
}

GROUP_CODE_SUBCLANS <- rbind(
  .gc_seed("MR", "HOWRARSAME", "HORARSAME", "HAWRARSAME", "HORARSAMO", "HORRASE"),
  .gc_seed("MR", "FAQIYAQUB", "FAQAYAQUB", "FIQIYAQUB", "FAYAQUB", "FAQAYUB"),
  .gc_seed("MR", "REER AHMED", "AHMED", "AHMAD", "AXMED", "AXMAD", "AMED", "AXMD", "AHMD"),
  .gc_seed("MR", "REER HASSAN", "HASSAN", "XASAN", "HSSAN", "XASN", "HASSA"),
  .gc_seed("MR", "REER DIINI", "DIINI", "DINII", "DIIN", "DININ"),
  .gc_seed("MR", "ALI HUSSEIN", "CALI XUSEEN"),
  .gc_seed("MR", "CELI", "CEELI"),
  .gc_seed("MR", "CALI DHEERE", "ALI DHEERE", "CELI DHEERE", "C DH"),
  .gc_seed("MR", "ELDEERE", "ELDHEERE"),
  .gc_seed("MR", "INA NUUR", "IN NUUR", "LNA NUUR"),
  .gc_seed("MR", "REER GARAD", "GARAD", "GARAAD"),
  .gc_seed("MR", "REER OSMAN", "OSMAN", "OSMAAN", "CUSMAN", "CISMAN"),
  .gc_seed("MR", "REER YABAR", "YABAR"),
  .gc_seed("MR", "REER SIYAAD", "SIYAAD", "SIYAD"),
  .gc_seed("MR", "SIYAAD HUSSEIN", "SIYAT HUSSEIN"),
  .gc_seed("MR", "TALXE", "TALHE", "TALEXE"),
  .gc_seed("MR", "URMIDIG", "URMIDII", "ORMIDIG"),
  .gc_seed("MR", "HAWAR YAQUB", "HOWAR YAQUB"),
  .gc_seed("MR", "WAGARDHAC"),
  .gc_seed("MR", "WAQMAASHE"),
  .gc_seed("MR", "SOWNFURO", "SONFURE"),
  .gc_seed("MR", "GUMURWAAQ", "KUMURWAAQ"),
  .gc_seed("MR", "IBRAAHIM", "LBRAAHIM"),
  .gc_seed("MR", "HABAR CIISE"),
  .gc_seed("MR", "AFGADHUUD"),
  .gc_seed("MR", "BAH AWSGUUL", "BAH AWASGUUL"),
  .gc_seed("RW", "JIROON"),
  .gc_seed("RW", "LEYSAN", "LAYSAAN", "LEESAN"),
  .gc_seed("RW", "GASAR GUDHE", "GASAR GUTHEE", "GARAS GUTHEE", "GASARGUDE", "GARASGUDE"),
  .gc_seed("RW", "MACALIN WEYNE"),
  .gc_seed("RW", "GELEDLE"),
  .gc_seed("RW", "SHIRMOOGE", "SHARMOOGE", "SHARMOOGA", "SHARMOGE", "SHIR MOGE"),
  .gc_seed(NA_character_, "UJEEJEN", "UJEJEEN", "U JEEJEEN"),
  .gc_seed("GR", "TUUF"),
  .gc_seed("GR", "KURANYOW", "QURANYOW", "QURAANYOW", "KURANYOWA"),
  .gc_seed("GR", "SABDHAWE"),
  .gc_seed("HW", "HAWADLE"),
  .gc_seed("HW", "JIJEELE", "JIJELE"),
  .gc_seed("HW", "GAALJECEL", "GALJECEL", "GAAL JECEL"),
  .gc_seed("HW", "AJUURAAN", "AJURAAN"),
  .gc_seed("HW", "ALI MADAXWEYNE"),
  .gc_seed("DIR", "FUGU MUXUMED", "FUGU MUHUMED"),
  .gc_seed("JW", "GAWAWEYN", "GAWAWEYNE", "GABAWEEN", "GABAAWEYN", "GAWAWEN"),
  .gc_seed("DRD", "DHULBAHANTE", "DHUL BAHANTE"),
  .gc_seed("SKH", "AW GUDUB"),
  .gc_seed("SKH", "AW HASSAN")
)

# Short codes used in place of sub-clan names. Marehan codes are only expanded
# when the clan is Marehan because e.g. "HW" also means Hawiye.
GROUP_CODE_SUBCLAN_ABBREVIATIONS <- list(
  MR = c(
    HW = "HOWRARSAME", HWR = "HOWRARSAME", HRS = "HOWRARSAME", HRSM = "HOWRARSAME",
    HRSME = "HOWRARSAME", HWRS = "HOWRARSAME", HRM = "HOWRARSAME", HSM = "HOWRARSAME",
    HRE = "HOWRARSAME", HRR = "HOWRARSAME",
    RH = "REER HASSAN", RHS = "REER HASSAN", RHSN = "REER HASSAN", RHN = "REER HASSAN",
    HSN = "REER HASSAN", CHSN = "REER HASSAN", XSN = "REER HASSAN",
    RA = "REER AHMED", RG = "REER GARAD", RGRD = "REER GARAD",
    RD = "REER DIINI", RDN = "REER DIINI",
    UR = "URMIDIG", UM = "URMIDIG", TLX = "TALXE", TLXE = "TALXE", TX = "TALXE",
    FQ = "FAQIYAQUB", FQB = "FAQIYAQUB", FQY = "FAQIYAQUB", WG = "WAGARDHAC",
    WM = "WAQMAASHE", WQ = "WAQMAASHE", WQM = "WAQMAASHE",
    CLDH = "CALI DHEERE", CDH = "CALI DHEERE"
  ),
  ALL = c(GJ = "GAALJECEL", JJ = "JIJEELE", JJL = "JIJEELE", AJ = "AJUURAAN",
          GWN = "GAWAWEYN", LSN = "LEYSAN")
)

# Tokens that carry no group identity: region names, "Reer" (= family of),
# placeholder answers
GROUP_CODE_NOISE <- c("GEDO", "GD", "SOMALIA", "DISTRICT", "HEALTH", "FACILITY",
                      "HOSPITAL", "OTHERS", "OTHER", "TEST", "NON", "NONE", "NA",
                      "HHH", "UEUEU", "GDHHD")
GROUP_CODE_REER <- c("REER", "RER", "REE", "RE", "REH", "R")

# Somali phonetic key: x = h, q = k, c (ayn) is often dropped, doubled
# letters are spelling variants (aa/a, uu/u)
.gc_key <- function(x) {
  x <- gsub("[^A-Z]", "", toupper(x))
  x <- chartr("XQ", "HK", x)
  x <- gsub("C", "", x, fixed = TRUE)
  gsub("([A-Z])\\1+", "\\1", x, perl = TRUE)
}

.gc_subclan_key <- function(x) {
  key <- .gc_key(x)
  key <- sub("^(RER|RE)(?=[A-Z]{3,})", "", key, perl = TRUE)
  sub("^MAREHAN(?=[A-Z]{3,})", "", key, perl = TRUE)
}

# Exact raw match, then exact key match (keys >= 3 letters), then fuzzy key
# match: edit distance <= 30% of the longer key, only for keys >= 5 letters
.gc_match <- function(x, aliases, values, key = .gc_key, min_len = 5, ratio = 0.3) {
  out <- values[match(toupper(x), toupper(aliases))]
  x_keys <- key(x)
  alias_keys <- key(aliases)
  by_key <- is.na(out) & nchar(x_keys) >= 3
  out[by_key] <- values[match(x_keys[by_key], alias_keys)]
  todo <- which(is.na(out) & nchar(x_keys) >= min_len)
  long <- nchar(alias_keys) >= min_len
  if (length(todo) && any(long)) {
    dist <- utils::adist(x_keys[todo], alias_keys[long])
    allowed <- floor(ratio * outer(nchar(x_keys[todo]), nchar(alias_keys[long]), pmax))
    dist[dist > allowed] <- NA
    dist[outer(substr(x_keys[todo], 1, 1), substr(alias_keys[long], 1, 1), "!=")] <- NA
    best <- apply(dist, 1, function(row) {
      if (all(is.na(row))) NA_integer_ else which.min(row)
    })
    out[todo] <- values[long][best]
  }
  out
}

.gc_tokens <- function(x) {
  x <- toupper(x)
  x <- gsub("R\\s*/\\s*W[AE]YN", " RAHWEYN ", x)
  x <- gsub("O{2,}(?=[0-9])", "0", x, perl = TRUE)  # "OO1" typed for "001"
  x <- gsub("[^A-Z0-9]+", " ", x)
  x <- gsub("([A-Z])([0-9])", "\\1 \\2", x)
  x <- gsub("([0-9])([A-Z])", "\\1 \\2", x)
  lapply(strsplit(trimws(x), " +"), function(tokens) {
    tokens[nzchar(tokens) & !grepl("^[0-9O]*[0-9][0-9O]*$|^O{2,}$", tokens)]
  })
}

.gc_parse <- function(tokens, lookup) {
  n <- length(tokens)
  used <- logical(n)
  district <- NA_character_
  for (i in seq_len(n)) {
    found <- lookup$district[[tokens[i]]]
    if (!is.na(found)) {
      district <- found
      used[i] <- TRUE
      break
    }
    if (i < n && nchar(tokens[i]) + nchar(tokens[i + 1]) >= 7) {
      found <- .gc_match(paste0(tokens[i], tokens[i + 1]),
                         GROUP_CODE_DISTRICT_ALIASES$alias,
                         GROUP_CODE_DISTRICT_ALIASES$code)
      if (!is.na(found)) {
        district <- found
        used[c(i, i + 1)] <- TRUE
        break
      }
    }
  }
  used <- used | !is.na(lookup$district[tokens])
  # "EL" alone could be Elwak or El Barde; leave it to the enumerator district
  if (is.na(district) && n > 0 && tokens[1] == "EL") used[1] <- TRUE

  clans <- lookup$clan[tokens]
  first_clan <- which(!used & !is.na(clans))[1]
  clan <- if (is.na(first_clan)) NA_character_ else unname(clans[first_clan])
  if (!is.na(clan)) used <- used | (!is.na(clans) & clans == clan)

  rest <- tokens[!used & !tokens %in% c(GROUP_CODE_NOISE, GROUP_CODE_REER)]
  abbreviations <- c(
    if (identical(clan, "MR")) GROUP_CODE_SUBCLAN_ABBREVIATIONS$MR,
    GROUP_CODE_SUBCLAN_ABBREVIATIONS$ALL
  )
  units <- character()
  known <- logical()
  i <- 1
  while (i <= length(rest)) {
    if (i < length(rest)) {
      pair <- .gc_match(paste(rest[i], rest[i + 1]), GROUP_CODE_SUBCLANS$variant,
                        GROUP_CODE_SUBCLANS$name, key = .gc_subclan_key)
      if (!is.na(pair)) {
        units <- c(units, pair)
        known <- c(known, TRUE)
        i <- i + 2
        next
      }
    }
    token <- rest[i]
    unit <- if (token %in% names(abbreviations)) unname(abbreviations[token])
            else unname(lookup$subclan[token])
    if (is.na(unit) && !is.na(clans[[token]])) unit <- unname(clans[[token]])
    units <- c(units, if (is.na(unit)) token else unit)
    known <- c(known, !is.na(unit))
    i <- i + 1
  }
  if (is.na(clan) && any(known)) {
    seed_clans <- lookup$seed_clan[units[known]]
    clan <- seed_clans[!is.na(seed_clans)][1]
  }
  list(district = district, clan = unname(clan), units = units, known = known)
}

# Cluster spellings with no dictionary entry; each cluster takes the spelling
# seen on the most records
.gc_cluster_units <- function(units, weights) {
  totals <- tapply(weights, units, sum)
  totals <- totals[order(-totals, names(totals))]
  spellings <- names(totals)
  keys <- .gc_subclan_key(spellings)
  dist <- utils::adist(keys)
  long <- nchar(keys) >= 5
  representative <- spellings
  centroids <- integer()
  for (i in seq_along(spellings)) {
    same <- centroids[nchar(keys[i]) >= 3 & keys[centroids] == keys[i]]
    if (!length(same) && long[i]) {
      close <- centroids[long[centroids] &
        substr(keys[centroids], 1, 1) == substr(keys[i], 1, 1) &
        dist[i, centroids] <= floor(0.3 * pmax(nchar(keys[i]), nchar(keys[centroids])))]
      same <- close[order(dist[i, close])]
    }
    if (length(same)) representative[i] <- spellings[same[1]]
    else centroids <- c(centroids, i)
  }
  stats::setNames(representative, spellings)
}

group_district_code <- function(district) {
  district <- normalise_district(district)
  district[!is.na(district) & !nzchar(trimws(district))] <- NA_character_
  code <- names(GROUP_CODE_DISTRICTS)[match(district, GROUP_CODE_DISTRICTS)]
  unmatched <- is.na(code) & !is.na(district)
  code[unmatched] <- .gc_match(gsub("[^A-Za-z]", "", district[unmatched]),
                               GROUP_CODE_DISTRICT_ALIASES$alias,
                               GROUP_CODE_DISTRICT_ALIASES$code)
  fallback <- toupper(substr(gsub("[^A-Za-z]", "", district), 1, 3))
  use_fallback <- is.na(code) & !is.na(district) & nzchar(fallback)
  code[use_fallback] <- fallback[use_fallback]
  code
}

# Returns one row per input code:
#   group_code         DISTRICT-CLAN-SUBCLAN, NA when excluded
#   group_code_status  ok | blank | numeric_only | no_group_identity
#   group_district     district named in the code, else fallback_district
normalise_group_codes <- function(x, fallback_district = NA_character_) {
  raw <- trimws(as.character(x))
  fallback_district <- normalise_district(rep_len(as.character(fallback_district), length(raw)))
  alnum <- gsub("[^A-Z0-9]", "", toupper(raw))
  status <- ifelse(
    is.na(alnum) | !nzchar(alnum), "blank",
    ifelse(grepl("^[0-9O]+$", alnum) & grepl("[0-9]", alnum), "numeric_only", "ok")
  )

  codes <- unique(raw[status == "ok"])
  tokens <- .gc_tokens(codes)
  vocabulary <- unique(unlist(tokens))
  subclan_lookup <- .gc_match(vocabulary, GROUP_CODE_SUBCLANS$variant,
                              GROUP_CODE_SUBCLANS$name, key = .gc_subclan_key)
  clan_lookup <- .gc_match(vocabulary, GROUP_CODE_CLAN_ALIASES$alias,
                           GROUP_CODE_CLAN_ALIASES$code, min_len = Inf)
  clan_fuzzy <- .gc_match(vocabulary, GROUP_CODE_CLAN_ALIASES$alias, GROUP_CODE_CLAN_ALIASES$code)
  # A known sub-clan name beats a near-miss clan name (GABAWEEN vs RAHAWEEN)
  use_fuzzy <- is.na(clan_lookup) & is.na(subclan_lookup)
  clan_lookup[use_fuzzy] <- clan_fuzzy[use_fuzzy]
  # "Rer..." means "family of" and starts a sub-clan, never a clan
  clan_lookup[grepl("^REE?R[A-Z]{3,}", vocabulary)] <- NA_character_
  lookup <- list(
    district = stats::setNames(.gc_match(vocabulary, GROUP_CODE_DISTRICT_ALIASES$alias,
                                         GROUP_CODE_DISTRICT_ALIASES$code), vocabulary),
    clan = stats::setNames(clan_lookup, vocabulary),
    subclan = stats::setNames(subclan_lookup, vocabulary),
    seed_clan = stats::setNames(GROUP_CODE_SUBCLANS$clan, GROUP_CODE_SUBCLANS$name)
  )
  parsed <- lapply(tokens, .gc_parse, lookup = lookup)

  code_weights <- table(raw[status == "ok"])[codes]
  unknown <- unlist(lapply(parsed, function(p) p$units[!p$known]))
  unknown_weights <- unlist(Map(function(p, w) rep(w, sum(!p$known)),
                                parsed, as.integer(code_weights)))
  clusters <- if (length(unknown)) .gc_cluster_units(unknown, unknown_weights) else character()

  code_district <- vapply(parsed, function(p) p$district, character(1))
  code_clan <- vapply(parsed, function(p) p$clan, character(1))
  code_subclan <- vapply(parsed, function(p) {
    units <- p$units
    units[!p$known] <- clusters[units[!p$known]]
    paste(sort(unique(units)), collapse = "-")
  }, character(1))
  identifiable <- !is.na(code_clan) |
    vapply(parsed, function(p) any(nchar(p$units) >= 2), logical(1))

  idx <- match(raw, codes)
  district_code <- code_district[idx]
  district_source <- ifelse(is.na(district_code), "enumerator", "code")
  district_code[is.na(district_code)] <- group_district_code(fallback_district)[is.na(district_code)]
  district_code[is.na(district_code)] <- "UNK"
  status[status == "ok" & !identifiable[idx]] <- "no_group_identity"

  parts <- cbind(district_code, code_clan[idx], code_subclan[idx])
  group_code <- apply(parts, 1, function(p) paste(p[!is.na(p) & nzchar(p)], collapse = "-"))
  group_code[status != "ok"] <- NA_character_
  group_district <- unname(GROUP_CODE_DISTRICTS[district_code])
  from_enumerator <- district_source == "enumerator" & is.na(group_district)
  group_district[from_enumerator] <- fallback_district[from_enumerator]
  group_district[!is.na(group_district) & !nzchar(trimws(group_district))] <- NA_character_

  data.frame(
    group_code_raw = raw,
    group_code = group_code,
    group_code_status = status,
    group_district = group_district,
    group_district_source = ifelse(status == "ok", district_source, NA_character_),
    stringsAsFactors = FALSE
  )
}

month_to_season <- function(m) {
  dplyr::case_when(
    m %in% c(10, 11)      ~ "Deyr",
    m %in% c(3, 4, 5, 6) ~ "Guul",
    m %in% c(12, 1, 2)   ~ "Jilaal",
    m %in% c(7, 8, 9)    ~ "Xaaga",
    TRUE                  ~ NA_character_
  )
}

COL_TEAL   <- "#0d9488"
COL_RED    <- "#dc2626"
COL_ORANGE <- "#d97706"
COL_BLUE   <- "#2563eb"
COL_GREEN  <- "#059669"
COL_MUTED  <- "#718096"

safe_pct <- function(num, den, digits = 1) {
  ifelse(den > 0, round(100 * num / den, digits), NA_real_)
}