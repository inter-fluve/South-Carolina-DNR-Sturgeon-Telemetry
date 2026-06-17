library(dplyr)
library(readr)
library(purrr)
library(readxl)
library(stringr)
library(janitor)

# ============================================================
# === PATHS ==================================================
# ============================================================

santee_folder <- "I:/Shared drives/IFI/Projects_Active/SanteeCooper_FERC_19-04-09/IFI_TASKS/Task_Y_SturgUseofLock/SCDNR-Data-Analysis-Tasks/Santee River Detections_05_22_2026"

metadata_folder <- "I:/Shared drives/IFI/Projects_Active/SanteeCooper_FERC_19-04-09/IFI_TASKS/Task_Y_SturgUseofLock/SCDNR-Data-Analysis-Tasks/Tags_06_12_2026/"

output_path <- "I:/Shared drives/IFI/Projects_Active/SanteeCooper_FERC_19-04-09/IFI_TASKS/Task_Y_SturgUseofLock/SCDNR-Data-Analysis-Tasks/Santee River Detections_05_22_2026/Santee_River_Sturgeon_Detections_Combined.csv"


# ============================================================
# === READ ALL METADATA FILES ================================
# ============================================================

meta_files <- list.files(
  metadata_folder,
  pattern = "\\.xlsx$",
  full.names = TRUE,
  ignore.case = TRUE
)

# Remove Excel temp files (~$)
meta_files <- meta_files[!grepl("~\\$", basename(meta_files))]

meta_files

# Read + clean each metadata file
meta_list <- lapply(meta_files, function(f) {
  read_excel(f) %>%
    mutate(source_file = basename(f)) %>%
    clean_names()
})

# Align metadata columns
all_meta_cols <- unique(unlist(lapply(meta_list, names)))

meta_aligned <- lapply(meta_list, function(df) {
  missing <- setdiff(all_meta_cols, names(df))
  if (length(missing) > 0) df[missing] <- NA
  df <- df[all_meta_cols]
  df
})

# Final combined metadata
metadata_all <- bind_rows(meta_aligned)

message("✨ Combined metadata rows: ", nrow(metadata_all))


# ============================================================
# === READ SANTEE DETECTION FILES ============================
# ============================================================

csv_files <- list.files(
  santee_folder,
  pattern = "^SC.*\\.csv$",
  full.names = TRUE
)

csv_files


# ============================================================
# === REPAIR FUNCTION FOR MISALIGNED LAT/LONG ================
# ============================================================

repair_latlong <- function(df) {
  needed <- c("Latitude", "Longitude", "Transmitter Type")
  if (!all(needed %in% names(df))) return(df)
  
  bad_rows <- which(
    is.na(df$Latitude) &
      suppressWarnings(as.numeric(df$Longitude)) >= 32 &
      suppressWarnings(as.numeric(df$Longitude)) <= 34
  )
  
  if (length(bad_rows) > 0) {
    message("Fixing ", length(bad_rows), " misaligned rows in ", df$source_file[1])
    df$Latitude[bad_rows]  <- suppressWarnings(as.numeric(df$Longitude[bad_rows]))
    df$Longitude[bad_rows] <- suppressWarnings(as.numeric(df$`Transmitter Type`[bad_rows]))
  }
  
  df
}


# ============================================================
# === READ ALL CSVs AS CHARACTER =============================
# ============================================================

raw_list <- lapply(csv_files, function(f) {
  read_csv(f, col_types = cols(.default = "c")) %>%
    mutate(source_file = basename(f))
})


# ============================================================
# === PRE-FLIGHT VALIDATION ==================================
# ============================================================

validation_results <- raw_list %>%
  map_df(~{
    df <- .
    tibble(
      source_file = unique(df$source_file),
      numeric_transmitter = any(grepl("^-?[0-9.]+$", df$`Transmitter Type`), na.rm = TRUE),
      bad_lat = any(as.numeric(df$Latitude) > 40 | as.numeric(df$Latitude) < 20, na.rm = TRUE),
      bad_long = any(as.numeric(df$Longitude) > -70 | as.numeric(df$Longitude) < -90, na.rm = TRUE)
    )
  })

print("=== PRE-FLIGHT VALIDATION RESULTS ===")
print(validation_results)


# ============================================================
# === ALIGN DETECTION COLUMN NAMES ===========================
# ============================================================

all_cols <- unique(unlist(lapply(raw_list, names)))

aligned_list <- lapply(raw_list, function(df) {
  missing <- setdiff(all_cols, names(df))
  if (length(missing) > 0) df[missing] <- NA
  df <- df[all_cols]
  df
})

aligned_list <- lapply(aligned_list, repair_latlong)


# ============================================================
# === BIND ALL DETECTIONS ====================================
# ============================================================

all_data <- bind_rows(aligned_list)


# ============================================================
# === CONVERT NUMERIC COLUMNS ================================
# ============================================================

numeric_candidates <- c("Latitude", "Longitude", "Depth", "TagID", "Freq")

for (col in numeric_candidates) {
  if (col %in% names(all_data)) {
    all_data[[col]] <- suppressWarnings(as.numeric(all_data[[col]]))
  }
}


# ============================================================
# === CLEAN NAMES BEFORE JOIN ================================
# ============================================================

all_data <- all_data %>% clean_names()
metadata_all <- metadata_all %>% clean_names()


# ============================================================
# === JOIN DETECTIONS WITH COMBINED METADATA =================
# ============================================================

sturgeon_detections <- all_data %>%
  inner_join(metadata_all, by = c("transmitter" = "tag_id_code_standard")) %>%
  mutate(
    common_name = str_to_title(common_name),
    longitude = ifelse(longitude > 0, -abs(longitude), longitude),
    latitude = ifelse(latitude < 20 | latitude > 40, NA, latitude)
  )


# ============================================================
# === WRITE OUTPUT ===========================================
# ============================================================

write.csv(sturgeon_detections, output_path, row.names = FALSE)

message("✨ Santee River sturgeon detections saved to:")
message(output_path)
