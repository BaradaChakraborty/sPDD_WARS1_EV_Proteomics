# 1. Install pdftools into renv if not already installed
if (!requireNamespace("pdftools", quietly = TRUE)) {
  renv::install("pdftools")
  renv::snapshot()
}

library(pdftools)
library(tidyverse)

# 2. Download the official Nature Supplementary PDF into data/raw/
pdf_url  <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs41380-023-02251-4/MediaObjects/41380_2023_2251_MOESM1_ESM.pdf"
dest_pdf <- "data/raw/41380_2023_2251_MOESM1_ESM.pdf"

if (!file.exists(dest_pdf)) {
  options(timeout = max(600, getOption("timeout")))
  download.file(pdf_url, destfile = dest_pdf, mode = "wb")
}

# 3. Read all pages as text
pages <- pdf_text(dest_pdf)
message("Total pages in Supplementary PDF: ", length(pages))

# 4. Locate Supplementary Table 11
t11_pages <- which(str_detect(pages, regex("Supplementary\\s*Table\\s*11|Table\\s*S?11", ignore_case = TRUE)))
message("Pages mentioning Table 11: ", paste(t11_pages, collapse = ", "))

# 5. Search every line across the entire PDF for Wars1/Wars (P32921) and controls Rps3 (P62908) & Apex1 (P28352)
targets_regex <- "(?i)(^|[^a-z0-9])(wars1?|p32921|sywc|tryptophan[a-z]*|rps3|p62908|apex1|p28352)([^a-z0-9]|$)"

pdf_hits <- imap_dfr(pages, function(txt, pg) {
  lines <- str_split(txt, "\\r?\\n")[[1]]
  matched <- lines[str_detect(lines, targets_regex)]
  if (length(matched) == 0) return(tibble())
  tibble(page = pg, line_text = str_squish(matched))
})

print(pdf_hits, n = 100, width = Inf)
write_csv(pdf_hits, "results/tables/supp_pdf_target_hits.csv")

library(httr)
library(stringr)

# 1. Find exact page of Row 10 (WARS1 E0CXX4) and print the full page with headers
wars_page <- pdf_hits$page[10]
cat("========== FULL PAGE", wars_page, "(WARS1 & Rps3 TABLE) ==========\n")
cat(pages[wars_page])

# 2. Check the titles/headers of pages 48 and 50 (first 15 lines of each)
for (pg in c(48, 50)) {
  cat("\n========== PAGE", pg, "HEADER PREVIEW ==========\n")
  cat(paste(head(str_split(pages[pg], "\\r?\\n")[[1]], 15), collapse = "\n"), "\n")
}

# 3. Map the 39-aa E0CXX4 sequence onto canonical mouse Wars1 (P32921, 481 aa)
get_seq <- function(acc) {
  txt <- content(GET(paste0("https://rest.uniprot.org/uniprotkb/", acc, ".fasta")), as = "text", encoding = "UTF-8")
  paste(str_split(txt, "\\r?\\n")[[1]][-1], collapse = "")
}
seq_e0cxx4 <- get_seq("E0CXX4")
seq_p32921 <- get_seq("P32921")
cat("\nE0CXX4 length:", nchar(seq_e0cxx4), "| sequence:", seq_e0cxx4, "\n")
print(str_locate(seq_p32921, fixed(seq_e0cxx4)))

cat("E0CXX4 (39 aa): ", seq_e0cxx4, "\n")
cat("P32921 (1-47):  ", substr(seq_p32921, 1, 47), "\n")

writeLines(pages[wars_page], "results/tables/wars1_table_page.txt")
cat(paste(head(str_split(pages[wars_page], "\\r?\\n")[[1]], 35), collapse = "\n"))