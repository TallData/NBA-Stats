library(dplyr)
library(tidyr)
library(readr)

parse_made_attempted <- function(value) {
  pieces <- strsplit(ifelse(is.na(value), "", value), "-", fixed = TRUE)
  made <- suppressWarnings(as.numeric(vapply(pieces, function(x) x[[1]], character(1))))
  attempted <- suppressWarnings(as.numeric(vapply(pieces, function(x) if (length(x) >= 2) x[[2]] else NA_character_, character(1))))
  data.frame(made = made, attempted = attempted)
}

safe_divide <- function(numerator, denominator) {
  ifelse(is.na(denominator) | denominator == 0, NA_real_, numerator / denominator)
}

season_z <- function(value) {
  value_sd <- sd(value, na.rm = TRUE)
  if (is.na(value_sd) || value_sd == 0) return(rep(0, length(value)))
  (value - mean(value, na.rm = TRUE)) / value_sd
}

start_season <- as.integer(Sys.getenv("NBA_START_SEASON", "2013"))
end_season <- as.integer(Sys.getenv("NBA_END_SEASON", hoopR::most_recent_nba_season()))
seasons <- seq.int(start_season, end_season)

message("Loading modern NBA seasons: ", start_season, "-", end_season)
player_long <- hoopR::load_nba_player_stats(seasons)
team_long <- hoopR::load_nba_team_stats(seasons)

player_identity <- player_long %>%
  distinct(season, athlete_id, team_id, athlete_display_name, athlete_position_abbreviation, team_display_name)

player_averages <- player_long %>%
  filter(category == "averages", stat_label %in% c("GP", "MIN", "PTS", "REB", "AST", "STL", "BLK", "TO")) %>%
  select(season, athlete_id, team_id, stat_label, value) %>%
  distinct() %>%
  pivot_wider(names_from = stat_label, values_from = value, names_prefix = "avg_")

player_totals <- player_long %>%
  filter(category == "totals", stat_label %in% c("PTS", "REB", "AST", "STL", "BLK", "TO")) %>%
  select(season, athlete_id, team_id, stat_label, value) %>%
  distinct() %>%
  pivot_wider(names_from = stat_label, values_from = value, names_prefix = "total_")

player_shooting <- player_long %>%
  filter(category == "totals", stat_label %in% c("FG", "FT")) %>%
  select(season, athlete_id, team_id, stat_label, display_value) %>%
  distinct() %>%
  pivot_wider(names_from = stat_label, values_from = display_value)

fg <- parse_made_attempted(player_shooting$FG)
ft <- parse_made_attempted(player_shooting$FT)
player_shooting <- player_shooting %>%
  mutate(
    fg_made = fg$made,
    fg_attempted = fg$attempted,
    ft_made = ft$made,
    ft_attempted = ft$attempted
  ) %>%
  select(-FG, -FT)

team_identity <- team_long %>%
  distinct(season, team_id, team_abbreviation, team_display_name)

team_totals <- team_long %>%
  filter(category == "totals", stat_label %in% c("PTS", "AST", "TO", "FGA")) %>%
  select(season, team_id, stat_label, value) %>%
  distinct() %>%
  pivot_wider(names_from = stat_label, values_from = value, names_prefix = "team_")

east_teams <- c("ATL", "BOS", "BKN", "CHA", "CHI", "CLE", "DET", "IND", "MIA", "MIL", "NY", "NYK", "ORL", "PHI", "TOR", "WAS")

modern_player_seasons <- player_identity %>%
  left_join(player_averages, by = c("season", "athlete_id", "team_id")) %>%
  left_join(player_totals, by = c("season", "athlete_id", "team_id")) %>%
  left_join(player_shooting, by = c("season", "athlete_id", "team_id")) %>%
  left_join(team_identity, by = c("season", "team_id"), suffix = c("_player", "")) %>%
  left_join(team_totals, by = c("season", "team_id")) %>%
  transmute(
    playerID = paste0("espn_", athlete_id),
    year = season,
    tmID = team_abbreviation,
    player_name = athlete_display_name,
    position = athlete_position_abbreviation,
    team_name = team_display_name,
    conference = ifelse(team_abbreviation %in% east_teams, "EC", "WC"),
    GP = avg_GP,
    minutes = avg_MIN * avg_GP,
    points = total_PTS,
    rebounds = total_REB,
    assists = total_AST,
    steals = total_STL,
    blocks = total_BLK,
    turnovers = total_TO,
    fgAttempted = fg_attempted,
    fgMade = fg_made,
    ftAttempted = ft_attempted,
    ftMade = ft_made,
    team_points = team_PTS,
    team_fga = team_FGA,
    team_assists = team_AST,
    team_turnovers = team_TO,
    all_star = "Recognition unavailable",
    hall_of_fame = "Not Hall of Fame",
    source_dataset = "hoopR / ESPN",
    era = paste0(floor(year / 10) * 10, "s"),
    minutes_per_game = avg_MIN,
    points_per_game = avg_PTS,
    rebounds_per_game = avg_REB,
    assists_per_game = avg_AST,
    steals_per_game = avg_STL,
    blocks_per_game = avg_BLK,
    turnovers_per_game = avg_TO,
    field_goal_attempts_per_game = safe_divide(fgAttempted, GP),
    points_per_48 = safe_divide(points, minutes) * 48,
    true_shooting = safe_divide(points, 2 * (fgAttempted + 0.44 * ftAttempted)),
    assist_turnover = safe_divide(assists, turnovers),
    team_point_share = safe_divide(points, team_points),
    team_assist_share = safe_divide(assists, team_assists),
    team_shot_share = safe_divide(fgAttempted, team_fga),
    team_production_share = rowMeans(cbind(team_point_share, team_assist_share, team_shot_share), na.rm = TRUE),
    simple_efficiency = safe_divide(
      points + rebounds + assists + steals + blocks - (fgAttempted - fgMade) -
        (ftAttempted - ftMade) - turnovers,
      GP
    )
  ) %>%
  group_by(year) %>%
  mutate(
    tall_data_efficiency_score = 50 + 10 * (
      0.30 * season_z(points_per_game) +
        0.18 * season_z(assists_per_game) +
        0.18 * season_z(rebounds_per_game) +
        0.12 * season_z(minutes_per_game) +
        0.15 * season_z(team_production_share) +
        0.12 * season_z(true_shooting) -
        0.14 * season_z(turnovers_per_game) -
        0.10 * season_z(field_goal_attempts_per_game)
    )
  ) %>%
  ungroup() %>%
  filter(!is.na(year), !is.na(GP), GP > 0)

output_dir <- file.path("data", "processed")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_path <- file.path(output_dir, "modern_player_seasons.csv")
write_csv(modern_player_seasons, output_path, na = "")

coverage <- modern_player_seasons %>%
  count(year, name = "player_team_seasons") %>%
  arrange(year)
write_csv(coverage, file.path(output_dir, "modern_season_coverage.csv"))

message("Wrote ", nrow(modern_player_seasons), " player-team seasons to ", output_path)
