library(dplyr)

safe_divide <- function(numerator, denominator) {
  ifelse(is.na(denominator) | denominator == 0, NA_real_, numerator / denominator)
}

season_z <- function(value) {
  value_sd <- sd(value, na.rm = TRUE)

  if (is.na(value_sd) || value_sd == 0) {
    return(rep(0, length(value)))
  }

  (value - mean(value, na.rm = TRUE)) / value_sd
}

data_dir <- file.path("data", "Stats_Extended_Before_2013")
output_dir <- "outputs"

dir.create(output_dir, showWarnings = FALSE)

players <- read.csv(file.path(data_dir, "basketball_players.csv"))
player_key <- read.csv(file.path(data_dir, "basketball_master.csv"))
teams <- read.csv(file.path(data_dir, "basketball_teams.csv"))
all_stars <- read.csv(file.path(data_dir, "basketball_player_allstar.csv"))

all_star_flags <- all_stars %>%
  transmute(
    playerID = player_id,
    year = season_id,
    all_star = ifelse(games_played > 0, "All-Star", "Not All-Star")
  ) %>%
  distinct(playerID, year, .keep_all = TRUE)

player_seasons <- players %>%
  left_join(
    player_key %>%
      transmute(
        playerID = bioID,
        player_name = trimws(paste(useFirst, lastName)),
        position = pos
      ),
    by = "playerID"
  ) %>%
  left_join(
    teams %>%
      transmute(
        year,
        tmID,
        team_points = o_pts,
        team_fga = o_fga,
        team_assists = o_asts
      ),
    by = c("year", "tmID")
  ) %>%
  left_join(all_star_flags, by = c("playerID", "year")) %>%
  mutate(
    player_name = ifelse(player_name == "" | is.na(player_name), playerID, player_name),
    all_star = ifelse(is.na(all_star), "Not All-Star", all_star),
    all_star_flag = all_star == "All-Star",
    minutes_per_game = safe_divide(minutes, GP),
    points_per_game = safe_divide(points, GP),
    rebounds_per_game = safe_divide(rebounds, GP),
    assists_per_game = safe_divide(assists, GP),
    turnovers_per_game = safe_divide(turnovers, GP),
    field_goal_attempts_per_game = safe_divide(fgAttempted, GP),
    true_shooting = safe_divide(points, 2 * (fgAttempted + 0.44 * ftAttempted)),
    team_point_share = safe_divide(points, team_points),
    team_assist_share = safe_divide(assists, team_assists),
    team_shot_share = safe_divide(fgAttempted, team_fga),
    team_production_share = rowMeans(
      cbind(team_point_share, team_assist_share, team_shot_share),
      na.rm = TRUE
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

model_features <- c(
  "tall_data_efficiency_score",
  "points_per_game",
  "rebounds_per_game",
  "assists_per_game",
  "turnovers_per_game",
  "field_goal_attempts_per_game",
  "minutes_per_game",
  "team_production_share",
  "true_shooting"
)

model_data <- player_seasons %>%
  filter(if_all(all_of(model_features), ~ !is.na(.x)))

set.seed(42)
train_rows <- sample(seq_len(nrow(model_data)), size = floor(0.7 * nrow(model_data)))
train_data <- model_data[train_rows, ]
test_data <- model_data[-train_rows, ]

logistic_model <- glm(
  all_star_flag ~ tall_data_efficiency_score + points_per_game + rebounds_per_game +
    assists_per_game + turnovers_per_game + field_goal_attempts_per_game +
    minutes_per_game + team_production_share + true_shooting,
  data = train_data,
  family = binomial()
)

predictions <- test_data %>%
  mutate(
    logistic_probability = predict(logistic_model, newdata = test_data, type = "response"),
    logistic_prediction = logistic_probability >= 0.5
  )

logistic_confusion <- as.data.frame(
  table(
    Actual = predictions$all_star_flag,
    Predicted = predictions$logistic_prediction
  )
)

write.csv(logistic_confusion, file.path(output_dir, "logistic_confusion_matrix.csv"), row.names = FALSE)

if (requireNamespace("randomForest", quietly = TRUE)) {
  random_forest_model <- randomForest::randomForest(
    as.factor(all_star_flag) ~ tall_data_efficiency_score + points_per_game + rebounds_per_game +
      assists_per_game + turnovers_per_game + field_goal_attempts_per_game +
      minutes_per_game + team_production_share + true_shooting,
    data = train_data,
    ntree = 300
  )

  predictions$random_forest_probability <- predict(
    random_forest_model,
    newdata = test_data,
    type = "prob"
  )[, "TRUE"]
  predictions$random_forest_prediction <- predictions$random_forest_probability >= 0.5

  random_forest_confusion <- as.data.frame(
    table(
      Actual = predictions$all_star_flag,
      Predicted = predictions$random_forest_prediction
    )
  )

  write.csv(
    random_forest_confusion,
    file.path(output_dir, "random_forest_confusion_matrix.csv"),
    row.names = FALSE
  )
} else {
  predictions$random_forest_probability <- NA_real_
  predictions$random_forest_prediction <- NA
}

should_have_been_all_stars <- predictions %>%
  filter(!all_star_flag) %>%
  arrange(desc(logistic_probability)) %>%
  transmute(
    year,
    player_name,
    tmID,
    GP,
    points_per_game,
    rebounds_per_game,
    assists_per_game,
    tall_data_efficiency_score,
    logistic_probability,
    random_forest_probability
  ) %>%
  head(50)

top_prediction_misses <- predictions %>%
  mutate(
    miss_type = case_when(
      all_star_flag & logistic_probability < 0.5 ~ "Actual All-Star ranked too low",
      !all_star_flag & logistic_probability >= 0.5 ~ "Non-All-Star ranked high",
      TRUE ~ "Correct side of threshold"
    ),
    miss_gap = abs(logistic_probability - 0.5)
  ) %>%
  filter(miss_type != "Correct side of threshold") %>%
  arrange(desc(miss_gap)) %>%
  transmute(
    year,
    player_name,
    tmID,
    all_star,
    miss_type,
    points_per_game,
    tall_data_efficiency_score,
    logistic_probability
  ) %>%
  head(50)

write.csv(
  should_have_been_all_stars,
  file.path(output_dir, "should_have_been_all_stars.csv"),
  row.names = FALSE
)

write.csv(
  top_prediction_misses,
  file.path(output_dir, "top_prediction_misses.csv"),
  row.names = FALSE
)

message("Wrote All-Star model outputs to ", normalizePath(output_dir))
