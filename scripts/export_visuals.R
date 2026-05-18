library(ggplot2)

previous_wd <- getwd()
setwd("app")
source("app.R", local = FALSE)
setwd(previous_wd)

chart_dir <- file.path("outputs", "charts")
dir.create(chart_dir, recursive = TRUE, showWarnings = FALSE)

visual_data <- player_seasons %>%
  filter(
    GP >= 20,
    is.na(minutes_per_game) | minutes_per_game >= 10
  )

similar_player <- c("Michael Jordan", "LeBron James", "Kareem Abdul-Jabbar")
similar_player <- similar_player[similar_player %in% visual_data$player_name][1]

if (is.na(similar_player)) {
  similar_player <- visual_data$player_name[which.max(visual_data$tall_data_efficiency_score)]
}

charts <- list(
  top_20_efficiency_seasons = plot_top_efficiency_seasons(visual_data),
  efficiency_by_era = plot_efficiency_by_era(visual_data),
  all_star_vs_non_all_star_clusters = plot_all_star_clusters(visual_data),
  team_production_share = plot_team_production_share(visual_data),
  similar_player_map = plot_similar_player_map(visual_data, similar_player)
)

for (chart_name in names(charts)) {
  ggsave(
    filename = file.path(chart_dir, paste0(chart_name, ".png")),
    plot = charts[[chart_name]],
    width = 12,
    height = 8,
    dpi = 160
  )
}

message("Wrote shareable chart PNGs to ", normalizePath(chart_dir))
