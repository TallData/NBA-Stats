library(shiny)
library(dplyr)
library(ggplot2)

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

plot_top_efficiency_seasons <- function(data) {
  top_seasons <- data %>%
    filter(!is.na(tall_data_efficiency_score)) %>%
    arrange(desc(tall_data_efficiency_score)) %>%
    head(20) %>%
    mutate(season_label = paste(player_name, year, sep = ", "))

  ggplot(top_seasons, aes(x = reorder(season_label, tall_data_efficiency_score), y = tall_data_efficiency_score, fill = all_star)) +
    geom_col(width = 0.72) +
    coord_flip() +
    labs(
      x = NULL,
      y = "TallData Efficiency Score",
      fill = "Selection",
      title = "Top 20 TallData Efficiency Seasons"
    ) +
    theme_minimal(base_size = 13)
}

plot_efficiency_by_era <- function(data) {
  ggplot(
    data %>% filter(!is.na(tall_data_efficiency_score), !is.na(era)),
    aes(x = era, y = tall_data_efficiency_score)
  ) +
    geom_boxplot(fill = "#d8e7f3", color = "#264653", outlier.alpha = 0.15) +
    stat_summary(fun = median, geom = "point", color = "#d1495b", size = 2.5) +
    labs(
      x = "Era",
      y = "TallData Efficiency Score",
      title = "Efficiency by Era"
    ) +
    theme_minimal(base_size = 13)
}

plot_all_star_clusters <- function(data) {
  cluster_data <- data %>%
    filter(if_all(all_of(model_features), ~ !is.na(.x)))

  req(nrow(cluster_data) > 2)

  cluster_projection <- prcomp(cluster_data[, model_features], center = TRUE, scale. = TRUE)
  cluster_data$pc1 <- cluster_projection$x[, 1]
  cluster_data$pc2 <- cluster_projection$x[, 2]

  ggplot(cluster_data, aes(x = pc1, y = pc2, color = all_star)) +
    geom_point(alpha = 0.58, size = 2) +
    labs(
      x = "Player profile axis 1",
      y = "Player profile axis 2",
      color = "Selection",
      title = "All-Star vs Non-All-Star Player Clusters"
    ) +
    theme_minimal(base_size = 13)
}

plot_team_production_share <- function(data) {
  ggplot(
    data %>% filter(!is.na(team_production_share), !is.na(tall_data_efficiency_score)),
    aes(x = team_production_share, y = tall_data_efficiency_score, color = all_star)
  ) +
    geom_point(alpha = 0.58, size = 2) +
    geom_smooth(method = "lm", se = FALSE, color = "#222222", linewidth = 0.7) +
    scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
    labs(
      x = "Share of team production",
      y = "TallData Efficiency Score",
      color = "Selection",
      title = "Team Production Share vs Player Value"
    ) +
    theme_minimal(base_size = 13)
}

plot_similar_player_map <- function(data, selected_player) {
  map_data <- data %>%
    filter(if_all(all_of(model_features), ~ !is.na(.x)))

  req(nrow(map_data) > 2)

  similar_projection <- prcomp(map_data[, model_features], center = TRUE, scale. = TRUE)
  map_data$pc1 <- similar_projection$x[, 1]
  map_data$pc2 <- similar_projection$x[, 2]
  map_data$is_selected <- map_data$player_name == selected_player

  selected_points <- map_data %>% filter(is_selected)
  if (nrow(selected_points) > 0) {
    selected_center <- colMeans(selected_points[, c("pc1", "pc2")])
    map_data$distance_to_selected <- sqrt(
      (map_data$pc1 - selected_center[["pc1"]])^2 +
        (map_data$pc2 - selected_center[["pc2"]])^2
    )
  } else {
    map_data$distance_to_selected <- NA_real_
  }

  similar_labels <- map_data %>%
    filter(!is_selected, !is.na(distance_to_selected)) %>%
    arrange(distance_to_selected) %>%
    head(8)

  ggplot(map_data, aes(x = pc1, y = pc2)) +
    geom_point(aes(color = all_star), alpha = 0.4, size = 2) +
    geom_point(
      data = selected_points,
      color = "#111111",
      fill = "#ffcc33",
      shape = 21,
      size = 4,
      stroke = 1.2
    ) +
    geom_text(
      data = similar_labels,
      aes(label = paste(player_name, year, sep = "\n")),
      size = 3,
      check_overlap = TRUE,
      vjust = -0.8
    ) +
    labs(
      x = "Similarity axis 1",
      y = "Similarity axis 2",
      color = "Selection",
      title = "Similar Player Map"
    ) +
    theme_minimal(base_size = 13)
}

data_dir <- file.path("..", "data", "Stats_Extended_Before_2013")

players <- read.csv(file.path(data_dir, "basketball_players.csv"))
player_key <- read.csv(file.path(data_dir, "basketball_master.csv"))
teams <- read.csv(file.path(data_dir, "basketball_teams.csv"))
all_stars <- read.csv(file.path(data_dir, "basketball_player_allstar.csv"))
hall_of_fame <- read.csv(file.path(data_dir, "basketball_hof.csv"))

all_star_flags <- all_stars %>%
  transmute(
    playerID = player_id,
    year = season_id,
    all_star = ifelse(games_played > 0, "All-Star", "Not All-Star")
  ) %>%
  distinct(playerID, year, .keep_all = TRUE)

hall_of_fame_flags <- hall_of_fame %>%
  filter(category == "Player", !is.na(hofID), hofID != "") %>%
  transmute(playerID = hofID, hall_of_fame = "Hall of Fame") %>%
  distinct(playerID, .keep_all = TRUE)

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
        team_name = name,
        conference = confID,
        team_points = o_pts,
        team_fga = o_fga,
        team_assists = o_asts,
        team_turnovers = o_to,
        team_wins = won,
        team_losses = lost
      ),
    by = c("year", "tmID")
  ) %>%
  left_join(all_star_flags, by = c("playerID", "year")) %>%
  left_join(hall_of_fame_flags, by = "playerID") %>%
  mutate(
    player_name = ifelse(player_name == "" | is.na(player_name), playerID, player_name),
    era = paste0(floor(year / 10) * 10, "s"),
    all_star = ifelse(is.na(all_star), "Not All-Star", all_star),
    hall_of_fame = ifelse(is.na(hall_of_fame), "Not Hall of Fame", hall_of_fame),
    minutes_per_game = safe_divide(minutes, GP),
    points_per_game = safe_divide(points, GP),
    rebounds_per_game = safe_divide(rebounds, GP),
    assists_per_game = safe_divide(assists, GP),
    steals_per_game = safe_divide(steals, GP),
    blocks_per_game = safe_divide(blocks, GP),
    turnovers_per_game = safe_divide(turnovers, GP),
    field_goal_attempts_per_game = safe_divide(fgAttempted, GP),
    points_per_48 = safe_divide(points, minutes) * 48,
    true_shooting = safe_divide(points, 2 * (fgAttempted + 0.44 * ftAttempted)),
    assist_turnover = safe_divide(assists, turnovers),
    team_point_share = safe_divide(points, team_points),
    team_assist_share = safe_divide(assists, team_assists),
    team_shot_share = safe_divide(fgAttempted, team_fga),
    team_production_share = rowMeans(
      cbind(team_point_share, team_assist_share, team_shot_share),
      na.rm = TRUE
    ),
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

available_years <- sort(unique(player_seasons$year))

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
  mutate(
    all_star_flag = all_star == "All-Star",
    data_split_key = paste(playerID, year, tmID, sep = "_")
  ) %>%
  filter(if_all(all_of(model_features), ~ !is.na(.x)))

set.seed(42)
train_rows <- sample(seq_len(nrow(model_data)), size = floor(0.7 * nrow(model_data)))
train_data <- model_data[train_rows, ]
test_data <- model_data[-train_rows, ]

all_star_logistic_model <- glm(
  all_star_flag ~ tall_data_efficiency_score + points_per_game + rebounds_per_game +
    assists_per_game + turnovers_per_game + field_goal_attempts_per_game +
    minutes_per_game + team_production_share + true_shooting,
  data = train_data,
  family = binomial()
)

test_predictions <- test_data %>%
  mutate(
    logistic_probability = predict(all_star_logistic_model, newdata = test_data, type = "response"),
    logistic_prediction = ifelse(logistic_probability >= 0.5, "Predicted All-Star", "Predicted Non-All-Star"),
    actual_outcome = ifelse(all_star_flag, "Actual All-Star", "Actual Non-All-Star")
  )

random_forest_available <- requireNamespace("randomForest", quietly = TRUE)

if (random_forest_available) {
  all_star_random_forest <- randomForest::randomForest(
    as.factor(all_star_flag) ~ tall_data_efficiency_score + points_per_game + rebounds_per_game +
      assists_per_game + turnovers_per_game + field_goal_attempts_per_game +
      minutes_per_game + team_production_share + true_shooting,
    data = train_data,
    ntree = 300
  )

  rf_probabilities <- predict(all_star_random_forest, newdata = test_data, type = "prob")[, "TRUE"]

  test_predictions <- test_predictions %>%
    mutate(
      random_forest_probability = rf_probabilities,
      random_forest_prediction = ifelse(
        random_forest_probability >= 0.5,
        "Predicted All-Star",
        "Predicted Non-All-Star"
      )
    )
} else {
  test_predictions <- test_predictions %>%
    mutate(
      random_forest_probability = NA_real_,
      random_forest_prediction = "Install randomForest"
    )
}

ui <- fluidPage(
  titlePanel("NBA Legacy Lab"),
  tags$p(
    "Explore historical NBA player value, compare eras, and predict All-Star-level production."
  ),
  tags$p(
    "Core question: can the data identify valuable players before the league officially recognizes them?"
  ),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "year_range",
        "Season range",
        min = min(available_years),
        max = max(available_years),
        value = c(max(min(available_years), 1990), max(available_years)),
        sep = ""
      ),
      selectInput(
        "conference",
        "Conference",
        choices = c("All", sort(na.omit(unique(player_seasons$conference)))),
        selected = "All"
      ),
      numericInput("min_games", "Minimum games played", value = 20, min = 1, max = 82),
      numericInput("min_minutes", "Minimum minutes per game", value = 10, min = 0, max = 48),
      selectInput(
        "metric",
        "Leaderboard metric",
        choices = c(
          "TallData Efficiency Score" = "tall_data_efficiency_score",
          "Simple efficiency" = "simple_efficiency",
          "Points per game" = "points_per_game",
          "Points per 48" = "points_per_48",
          "True shooting" = "true_shooting",
          "Assist / turnover" = "assist_turnover",
          "Team point share" = "team_point_share"
        ),
        selected = "tall_data_efficiency_score"
      ),
      selectInput("player", "Highlight player", choices = NULL),
      width = 3
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Leaderboard",
          h3("Top value seasons"),
          tableOutput("leaderboard")
        ),
        tabPanel(
          "Value Map",
          h3("Scoring vs. TallData Efficiency Score"),
          plotOutput("efficiency_plot", height = 520)
        ),
        tabPanel(
          "Recognition Gap",
          h3("TallData score by recognition outcome"),
          plotOutput("all_star_plot", height = 360),
          plotOutput("hall_of_fame_plot", height = 360)
        ),
        tabPanel(
          "Visual Stories",
          h3("Top 20 efficiency seasons"),
          plotOutput("top_efficiency_seasons_plot", height = 620),
          h3("Efficiency by era"),
          plotOutput("efficiency_by_era_plot", height = 420),
          h3("All-Star vs non-All-Star player clusters"),
          plotOutput("all_star_clusters_plot", height = 520),
          h3("Team production share"),
          plotOutput("team_production_share_plot", height = 520),
          h3("Similar player map"),
          plotOutput("similar_player_map_plot", height = 520)
        ),
        tabPanel(
          "All-Star Predictor",
          h3("Model performance"),
          tags$p("The model learns from recognized All-Star seasons, then flags players whose production looked similar even when they were not selected."),
          tableOutput("model_summary"),
          h3("Logistic regression confusion matrix"),
          tableOutput("logistic_confusion"),
          h3("Random forest confusion matrix"),
          tableOutput("random_forest_confusion"),
          h3("Who should have been an All-Star?"),
          tags$p("High-probability non-selections are the most shareable recognition-gap candidates."),
          tableOutput("should_have_been_all_stars"),
          h3("Top prediction misses"),
          tableOutput("top_prediction_misses")
        ),
        tabPanel(
          "Player Detail",
          h3(textOutput("player_heading")),
          tableOutput("player_summary"),
          plotOutput("player_trend", height = 420)
        )
      ),
      width = 9
    )
  )
)

server <- function(input, output, session) {
  filtered_data <- reactive({
    data <- player_seasons %>%
      filter(
        year >= input$year_range[1],
        year <= input$year_range[2],
        GP >= input$min_games,
        is.na(minutes_per_game) | minutes_per_game >= input$min_minutes
      )

    if (input$conference != "All") {
      data <- data %>% filter(conference == input$conference)
    }

    data
  })

  observe({
    choices <- filtered_data() %>%
      arrange(player_name) %>%
      distinct(player_name) %>%
      pull(player_name)

    selected <- if (length(choices) > 0) choices[1] else character(0)
    updateSelectInput(session, "player", choices = choices, selected = selected)
  })

  output$leaderboard <- renderTable({
    req(input$metric)

    filtered_data() %>%
      filter(!is.na(.data[[input$metric]])) %>%
      arrange(desc(.data[[input$metric]])) %>%
      transmute(
        Season = year,
        Player = player_name,
        Team = tmID,
        Conference = conference,
        `All-Star` = all_star,
        `Hall of Fame` = hall_of_fame,
        GP = GP,
        MPG = round(minutes_per_game, 1),
        PPG = round(points_per_game, 1),
        RPG = round(rebounds_per_game, 1),
        APG = round(assists_per_game, 1),
        `TallData Score` = round(tall_data_efficiency_score, 1),
        Efficiency = round(simple_efficiency, 2),
        `True Shooting` = round(true_shooting, 3),
        `Team Point Share` = round(team_point_share, 3)
      ) %>%
      head(25)
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  output$efficiency_plot <- renderPlot({
    data <- filtered_data() %>%
      filter(!is.na(points_per_game), !is.na(tall_data_efficiency_score))

    req(nrow(data) > 0)

    ggplot(data, aes(x = points_per_game, y = tall_data_efficiency_score, color = all_star)) +
      geom_point(alpha = 0.65, size = 2) +
      geom_point(
        data = data %>% filter(player_name == input$player),
        color = "#111111",
        fill = "#ffcc33",
        shape = 21,
        size = 4,
        stroke = 1.2
      ) +
      labs(
        x = "Points per game",
        y = "TallData Efficiency Score",
        color = "Selection",
        caption = "TallData Efficiency Score blends season-normalized scoring, assists, rebounds, minutes, shooting efficiency, ball security, shot volume, and team production share."
      ) +
      theme_minimal(base_size = 13)
  })

  output$all_star_plot <- renderPlot({
    data <- filtered_data() %>%
      filter(!is.na(tall_data_efficiency_score))

    req(nrow(data) > 0)

    ggplot(data, aes(x = all_star, y = tall_data_efficiency_score, fill = all_star)) +
      geom_boxplot(alpha = 0.75, outlier.alpha = 0.25) +
      labs(
        x = NULL,
        y = "TallData Efficiency Score",
        fill = "Selection"
      ) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "none")
  })

  output$hall_of_fame_plot <- renderPlot({
    data <- filtered_data() %>%
      filter(!is.na(tall_data_efficiency_score))

    req(nrow(data) > 0)

    ggplot(data, aes(x = hall_of_fame, y = tall_data_efficiency_score, fill = hall_of_fame)) +
      geom_boxplot(alpha = 0.75, outlier.alpha = 0.25) +
      labs(
        x = NULL,
        y = "TallData Efficiency Score",
        fill = "Hall of Fame"
      ) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "none")
  })

  output$top_efficiency_seasons_plot <- renderPlot({
    data <- filtered_data()
    req(nrow(data) > 0)
    plot_top_efficiency_seasons(data)
  })

  output$efficiency_by_era_plot <- renderPlot({
    data <- filtered_data()
    req(nrow(data) > 0)
    plot_efficiency_by_era(data)
  })

  output$all_star_clusters_plot <- renderPlot({
    data <- filtered_data()
    req(nrow(data) > 2)
    plot_all_star_clusters(data)
  })

  output$team_production_share_plot <- renderPlot({
    data <- filtered_data()
    req(nrow(data) > 0)
    plot_team_production_share(data)
  })

  output$similar_player_map_plot <- renderPlot({
    data <- filtered_data()
    req(nrow(data) > 2, input$player)
    plot_similar_player_map(data, input$player)
  })

  output$model_summary <- renderTable({
    data.frame(
      Model = c("Logistic regression", "Random forest"),
      Status = c(
        "Trained on 70% of eligible player seasons; evaluated on 30%",
        ifelse(
          random_forest_available,
          "Trained on the same split with 300 trees",
          "Install randomForest by running source('requirements.R')"
        )
      ),
      `Test Rows` = c(nrow(test_predictions), nrow(test_predictions)),
      check.names = FALSE
    )
  }, bordered = TRUE, spacing = "s")

  output$logistic_confusion <- renderTable({
    table(
      Actual = test_predictions$actual_outcome,
      Predicted = test_predictions$logistic_prediction
    )
  }, bordered = TRUE, spacing = "s")

  output$random_forest_confusion <- renderTable({
    if (!random_forest_available) {
      return(data.frame(Message = "Run source('requirements.R') to install randomForest."))
    }

    table(
      Actual = test_predictions$actual_outcome,
      Predicted = test_predictions$random_forest_prediction
    )
  }, bordered = TRUE, spacing = "s")

  output$should_have_been_all_stars <- renderTable({
    test_predictions %>%
      filter(all_star == "Not All-Star") %>%
      arrange(desc(logistic_probability)) %>%
      transmute(
        Season = year,
        Player = player_name,
        Team = tmID,
        GP = GP,
        PPG = round(points_per_game, 1),
        RPG = round(rebounds_per_game, 1),
        APG = round(assists_per_game, 1),
        `TallData Score` = round(tall_data_efficiency_score, 1),
        `Logistic All-Star Probability` = round(logistic_probability, 3),
        `Random Forest Probability` = ifelse(
          is.na(random_forest_probability),
          NA,
          round(random_forest_probability, 3)
        )
      ) %>%
      head(20)
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  output$top_prediction_misses <- renderTable({
    test_predictions %>%
      mutate(
        miss_type = case_when(
          all_star_flag & logistic_probability < 0.5 ~ "Actual All-Star ranked too low",
          !all_star_flag & logistic_probability >= 0.5 ~ "Non-All-Star ranked high",
          TRUE ~ "Correct side of threshold"
        )
      ) %>%
      filter(miss_type != "Correct side of threshold") %>%
      mutate(miss_gap = abs(logistic_probability - 0.5)) %>%
      arrange(desc(miss_gap)) %>%
      transmute(
        Season = year,
        Player = player_name,
        Team = tmID,
        Actual = all_star,
        Miss = miss_type,
        PPG = round(points_per_game, 1),
        `TallData Score` = round(tall_data_efficiency_score, 1),
        `Logistic Probability` = round(logistic_probability, 3)
      ) %>%
      head(20)
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  selected_player_data <- reactive({
    req(input$player)

    player_seasons %>%
      filter(player_name == input$player) %>%
      arrange(year)
  })

  output$player_heading <- renderText({
    req(input$player)
    input$player
  })

  output$player_summary <- renderTable({
    selected_player_data() %>%
      summarise(
        Seasons = n_distinct(year),
        Teams = n_distinct(tmID),
        `Career GP` = sum(GP, na.rm = TRUE),
        `Career Points` = sum(points, na.rm = TRUE),
        `Best PPG` = round(max(points_per_game, na.rm = TRUE), 1),
        `Best TallData Score` = round(max(tall_data_efficiency_score, na.rm = TRUE), 1),
        `Best Efficiency` = round(max(simple_efficiency, na.rm = TRUE), 2),
        `All-Star Seasons` = sum(all_star == "All-Star", na.rm = TRUE),
        `Hall of Fame` = ifelse(any(hall_of_fame == "Hall of Fame"), "Hall of Fame", "Not Hall of Fame")
      )
  }, bordered = TRUE, spacing = "s")

  output$player_trend <- renderPlot({
    data <- selected_player_data() %>%
      filter(!is.na(tall_data_efficiency_score))

    req(nrow(data) > 0)

    ggplot(data, aes(x = year, y = tall_data_efficiency_score)) +
      geom_line(color = "#1f77b4", linewidth = 1) +
      geom_point(aes(size = points_per_game, fill = all_star), shape = 21, color = "#111111") +
      labs(
        x = "Season",
        y = "TallData Efficiency Score",
        size = "PPG",
        fill = "Selection"
      ) +
      theme_minimal(base_size = 13)
  })
}

shinyApp(ui, server)
