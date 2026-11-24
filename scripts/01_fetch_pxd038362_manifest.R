library(httr)
library(jsonlite)
library(tidyverse)

accession <- "PXD038362"
api_url <- paste0("https://www.ebi.ac.uk/pride/ws/archive/v3/projects/", accession, "/files/all")

message("Querying PRIDE Archive v3 API for ", accession, "...")
res <- GET(api_url)
stop_for_status(res)

files_raw <- fromJSON(content(res, as = "text", encoding = "UTF-8"), simplifyVector = FALSE)

manifest <- map_dfr(files_raw, function(f) {
  locs <- f$publicFileLocations
  ftp_url <- NA_character_
  if (length(locs) > 0) {
    urls <- map_chr(locs, ~ .x$value %||% NA_character_)
    ftp_hits <- urls[str_detect(urls, "^ftp://")]
    if (length(ftp_hits) > 0) ftp_url <- ftp_hits[1]
  }
  tibble(
    file_name = f$fileName %||% NA_character_,
    category  = f$fileCategory$value %||% NA_character_,
    size_mb   = round((f$fileSizeBytes %||% 0) / 1e6, 2),
    https_url = str_replace(ftp_url, "^ftp://", "https://")
  )
}) %>%
  arrange(category, size_mb)

write_csv(manifest, "results/tables/pxd038362_file_manifest.csv")

non_raw <- manifest %>% filter(category != "RAW")
print(non_raw, n = 50)

manifest <- read_csv("results/tables/pxd038362_file_manifest.csv", show_col_types = FALSE)
manifest %>% filter(category != "RAW") %>% pull(file_name)
manifest %>% filter(category != "RAW") %>% pull(https_url)
count(manifest, category)

system2("powershell", c("-NoProfile", "-Command", "\"[math]::Round((Get-PSDrive E).Free / 1GB, 2)\""))

manifest <- read_csv("results/tables/pxd038362_file_manifest.csv", show_col_types = FALSE)
pd_row <- manifest %>% filter(category != "RAW") %>% slice(1)

dest_pd <- file.path("data/raw", pd_row$file_name)
options(timeout = max(3600, getOption("timeout"))) # allow up to 60 min for an ~8.9 GB file
download.file(pd_row$https_url, destfile = dest_pd, mode = "wb")