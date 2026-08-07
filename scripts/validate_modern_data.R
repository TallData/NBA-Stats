library(dplyr)
library(readr)

path <- file.path("data", "processed", "modern_player_seasons.csv")
if (!file.exists(path)) stop("Modern player-season dataset is missing: ", path)

data <- read_csv(path, show_col_types = FALSE)
required <- c("playerID", "year", "tmID", "player_name", "GP", "points_per_game", "tall_data_efficiency_score", "source_dataset")
missing_fields <- setdiff(required, names(data))
if (length(missing_fields) > 0) stop("Missing required fields: ", paste(missing_fields, collapse = ", "))
if (nrow(data) == 0) stop("Modern player-season dataset has no rows")
if (any(is.na(data$playerID) | is.na(data$year) | is.na(data$tmID))) stop("Stable key contains missing values")

duplicates <- data %>% count(playerID, year, tmID) %>% filter(n > 1)
if (nrow(duplicates) > 0) stop("Duplicate player-team-season keys found")

coverage <- sort(unique(data$year))
if (length(coverage) < 2) stop("Expected at least two modern seasons")
if (max(coverage) < 2025) stop("Modern dataset does not reach the 2025 season")

message("Validated ", nrow(data), " rows across seasons ", min(coverage), "-", max(coverage))
