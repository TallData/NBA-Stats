# Changelog

## 0.1.0 - NBA Legacy Lab Foundation

This release transforms the original exploratory NBA stats repo into **NBA Legacy Lab**, a story-driven R/Shiny analytics product for exploring historical player value, comparing eras, and predicting All-Star-level production.

### Added

- Shiny app experience in `app/app.R` with leaderboard, value map, recognition gap, visual stories, All-Star predictor, and player detail views
- TallData Efficiency Score, a branded era-normalized metric for comparing player seasons
- Predictive modeling workflow for All-Star selection using logistic regression and optional random forest
- Exported model outputs, including confusion matrix, prediction misses, and "Who should have been an All-Star?" candidates
- Five shareable chart exports: top efficiency seasons, efficiency by era, All-Star clusters, team production share, and similar player map
- MIT license, issue templates, roadmap issue list, screenshot gallery, and demo asset
- `requirements.R` for reproducible package setup

### Changed

- Reorganized the repo into `app/`, `data/`, `scripts/`, `notebooks/`, and `outputs/`
- Reframed the README around the product hook: identifying player value before official league recognition
- Moved exploratory scripts into `notebooks/` and production-facing scripts into `scripts/`
- Updated database credentials handling to use environment variables instead of hardcoded secrets

### Generated Outputs

- `outputs/charts/top_20_efficiency_seasons.png`
- `outputs/charts/efficiency_by_era.png`
- `outputs/charts/all_star_vs_non_all_star_clusters.png`
- `outputs/charts/team_production_share.png`
- `outputs/charts/similar_player_map.png`
- `outputs/logistic_confusion_matrix.csv`
- `outputs/should_have_been_all_stars.csv`
- `outputs/top_prediction_misses.csv`
