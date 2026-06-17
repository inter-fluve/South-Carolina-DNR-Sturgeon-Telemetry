library(dplyr)
library(readr)
library(stringr)
library(ggplot2)
library(janitor)
library(lubridate)

# ============================================================
# === PATHS TO CLEANED FILES =================================
# ============================================================

santee_clean <- "I:/Shared drives/IFI/Projects_Active/SanteeCooper_FERC_19-04-09/IFI_TASKS/Task_Y_SturgUseofLock/SCDNR-Data-Analysis-Tasks/Santee River Detections_05_22_2026/Santee_River_Sturgeon_Detections_Combined.csv"

lakes_clean <- "I:/Shared drives/IFI/Projects_Active/SanteeCooper_FERC_19-04-09/IFI_TASKS/Task_Y_SturgUseofLock/SCDNR-Data-Analysis-Tasks/Lake Detections_06_12_2026/Lakes_Sturgeon_Detections_Combined.csv"

cooper_clean <- "I:/Shared drives/IFI/Projects_Active/SanteeCooper_FERC_19-04-09/IFI_TASKS/Task_Y_SturgUseofLock/SCDNR-Data-Analysis-Tasks/Cooper River Detections_06_15_2026/Cooper_River_Sturgeon_Detections_Combined.csv"


# ============================================================
# === READ ALL CLEANED DETECTION FILES =======================
# ============================================================

DF_santee <- read_csv(santee_clean, show_col_types = FALSE) %>% clean_names()
DF_lakes  <- read_csv(lakes_clean, show_col_types = FALSE) %>% clean_names()
DF_cooper <- read_csv(cooper_clean, show_col_types = FALSE) %>% clean_names()


# ============================================================
# === COLLAPSE DUPLICATE LAT/LONG COLUMNS ====================
# ============================================================

collapse_latlong <- function(df) {
  if ("longitude_2" %in% names(df)) {
    df$longitude <- coalesce(as.numeric(df$longitude), as.numeric(df$longitude_2))
    df$longitude_2 <- NULL
  }
  if ("latitude_2" %in% names(df)) {
    df$latitude <- coalesce(as.numeric(df$latitude), as.numeric(df$latitude_2))
    df$latitude_2 <- NULL
  }
  df
}

DF_santee <- collapse_latlong(DF_santee)
DF_lakes  <- collapse_latlong(DF_lakes)
DF_cooper <- collapse_latlong(DF_cooper)


# ============================================================
# === STANDARDIZE DATETIME COLUMNS ===========================
# ============================================================

datetime_cols <- c(
  "date_and_time_utc",
  "release_date_time",
  "capture_date_time"
)

standardize_datetime <- function(df, cols) {
  for (col in cols) {
    if (col %in% names(df)) {
      df[[col]] <- ymd_hms(df[[col]], quiet = TRUE)
    }
  }
  df
}

DF_santee <- standardize_datetime(DF_santee, datetime_cols)
DF_lakes  <- standardize_datetime(DF_lakes,  datetime_cols)
DF_cooper <- standardize_datetime(DF_cooper, datetime_cols)


# ============================================================
# === ALIGN COLUMNS ACROSS ALL THREE DATASETS ================
# ============================================================

all_cols <- union(names(DF_santee), names(DF_lakes))
all_cols <- union(all_cols, names(DF_cooper))

add_missing_cols <- function(df, all_cols) {
  missing <- setdiff(all_cols, names(df))
  if (length(missing) > 0) df[missing] <- NA
  df <- df[all_cols]
  df
}

DF_santee <- add_missing_cols(DF_santee, all_cols)
DF_lakes  <- add_missing_cols(DF_lakes,  all_cols)
DF_cooper <- add_missing_cols(DF_cooper, all_cols)


# ============================================================
# === ADD RIVER IDENTIFIER ===================================
# ============================================================

DF_santee$river <- "Santee"
DF_lakes$river  <- "Lakes"
DF_cooper$river <- "Cooper"


# ============================================================
# === COMBINE ALL DETECTIONS INTO ONE MASTER DF ==============
# ============================================================

DF <- bind_rows(DF_santee, DF_lakes, DF_cooper)

message("✨ Total combined detections: ", nrow(DF))


# ============================================================
# === QUICK VISUALIZATION ====================================
# ============================================================

DF %>% 
  ggplot(aes(x = as.Date(date_and_time_utc), y = transmitter, color = river)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~common_name) +
  theme_bw() +
  xlab("Date") + 
  ylab("Transmitter ID") +
  ggtitle("Sturgeon Detections Across All Systems")


# ============================================================
# === RECEIVER-LEVEL SUMMARY (ALL RIVERS) ====================
# ============================================================

receiver_detections <- DF %>%
  group_by(river, station_name) %>%
  summarise(
    detections = n(),
    lat = mean(latitude, na.rm = TRUE),
    lon = mean(longitude, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  select(lat, lon, river, station_name, detections, everything()) %>%
  mutate(
    lon = ifelse(lon > 0, -abs(lon), lon),
    lat = ifelse(lat < 20 | lat > 40, NA, lat)
  )

