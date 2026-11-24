library(httr)
library(stringr)
library(tidyverse)

# Follow DOI redirect to the live article page, with PMC9677917 as fallback
resp <- GET("https://doi.org/10.1186/s40478-022-01472-y")
if (http_error(resp)) {
  resp <- GET("https://pmc.ncbi.nlm.nih.gov/articles/PMC9677917/")
}
stop_for_status(resp)
message("Fetched from: ", resp$url)

html_txt <- content(resp, as = "text", encoding = "UTF-8")

# Extract supplementary media / additional file links
esm_urls <- unique(str_extract_all(
  html_txt,
  "https?://[^\"'\\s<>]*(?:static-content\\.springer\\.com/esm|MediaObjects|pmc/articles/PMC9677917/bin)[^\"'\\s<>]*"
)[[1]])

print(esm_urls)


if (!requireNamespace("readxl", quietly = TRUE)) {
  renv::install("readxl", prompt = FALSE)
  renv::snapshot(prompt = FALSE)
}
library(readxl)

xlsx_urls <- esm_urls[20:23]
options(timeout = max(600, getOption("timeout")))

for (u in xlsx_urls) {
  fname <- basename(u)
  dest_f <- file.path("data/raw/westfall_2022_supp", fname)
  if (!file.exists(dest_f)) {
    message("Downloading: ", fname)
    download.file(u, destfile = dest_f, mode = "wb")
  }
}

xlsx_files <- list.files("data/raw/westfall_2022_supp", pattern = "\\.xlsx$", full.names = TRUE)

# Audit sheet names first
sheet_summary <- map_dfr(xlsx_files, function(f) {
  tibble(file = basename(f), sheets = excel_sheets(f))
})
print(sheet_summary, n = 100)

# Search every sheet in every Excel workbook for WARS / WARS1
wars_hits <- map_dfr(xlsx_files, function(f) {
  shs <- excel_sheets(f)
  map_dfr(shs, function(s) {
    df <- suppressMessages(read_excel(f, sheet = s)) %>%
      mutate(across(everything(), as.character))
    m <- df %>%
      filter(if_any(everything(), ~ str_detect(replace_na(.x, ""), regex("^WARS1?$", ignore_case = TRUE))))
    if (nrow(m) == 0) return(tibble())
    m %>% mutate(file = basename(f), sheet = s, .before = 1)
  })
})

print(wars_hits, n = 50, width = Inf)
write_csv(wars_hits, "results/tables/westfall2022_wars_xlsx_hits.csv")

library(readxl)
library(tidyverse)

# 1. Inspect MOESM13 (RE vs FCD) exact headers and WARS row
m13 <- read_excel("data/raw/westfall_2022_supp/40478_2022_1472_MOESM13_ESM.xlsx", sheet = 1)
print(names(m13))
print(m13 %>% filter(if_any(everything(), ~ str_detect(replace_na(as.character(.x), ""), "^WARS1?$"))), width = Inf)

# 2. Inspect top 5 rows of MOESM14 (Supplementary Table 3) to see cluster column layout
m14_raw <- read_excel("data/raw/westfall_2022_supp/40478_2022_1472_MOESM14_ESM.xlsx", sheet = 1, col_names = FALSE)
print(m14_raw[1:5, ], width = Inf)

# Find which row/column contains WARS in m14_raw
idx <- which(as.matrix(m14_raw) == "WARS", arr.ind = TRUE)
print(idx)
if (nrow(idx) > 0) {
  for (r in seq_len(nrow(idx))) {
    rr <- idx[r, 1]
    cc <- idx[r, 2]
    cat("\n--- Hit at row", rr, "col", cc, "---\n")
    print(m14_raw[max(1, rr - 2):min(nrow(m14_raw), rr + 2), max(1, cc - 1):min(ncol(m14_raw), cc + 4)])
  }
}

m13 <- readxl::read_excel("data/raw/westfall_2022_supp/40478_2022_1472_MOESM13_ESM.xlsx", sheet = 1)
print(names(m13))
print(m13 %>% dplyr::filter(dplyr::if_any(dplyr::everything(), ~ stringr::str_detect(tidyr::replace_na(as.character(.x), ""), "^WARS1?$"))), width = Inf)
print(readxl::read_excel("data/raw/westfall_2022_supp/40478_2022_1472_MOESM13_ESM.xlsx", sheet = 1, col_names = FALSE)[1:5, ], width = Inf)