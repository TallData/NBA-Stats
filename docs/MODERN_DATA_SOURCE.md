# Modern NBA Data Source

NBA Legacy Lab uses the `hoopR` loader functions for modern player and team season statistics.

## Source and coverage

- Loader: `hoopR::load_nba_player_stats()` and `hoopR::load_nba_team_stats()`
- Upstream source identified by hoopR: ESPN NBA season statistics
- Default coverage: 2013 through the most recent season available to hoopR
- Grain: one player-team-season row
- Refresh command: `Rscript scripts/refresh_modern_data.R`

The pipeline pins a tested hoopR source commit in the Docker image so loader behavior does not change without a code review.

## Output files

- `data/processed/modern_player_seasons.csv`
- `data/processed/modern_season_coverage.csv`

These are generated artifacts and are created during the Docker build. Raw upstream files remain managed by the hoopR data release repository.

## Identity rules

- Modern player key: `espn_<athlete_id>`
- Team key: ESPN team abbreviation
- Stable row key: `playerID + year + tmID`
- Players who change teams may have more than one row in a season

## Recognition fields

The modern ESPN season-stat files do not include a complete All-Star or Hall of Fame history. Modern rows therefore use `Recognition unavailable` for All-Star status and are excluded from All-Star model training. Hall of Fame status remains `Not Hall of Fame` unless a separate verified recognition source is added.

## Usage

Review the upstream provider's terms before using the generated data outside this non-commercial analytics and portfolio project. The app should identify ESPN and hoopR as the modern data source.
