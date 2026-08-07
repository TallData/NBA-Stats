# NBA Legacy Lab Data Dictionary

This dictionary covers the fields used by the Shiny app and All-Star modeling workflow. The source files live under `data/Stats_Extended_Before_2013/`.

## Source tables

### `basketball_players.csv`

One row represents a player-team-season record.

| Field | Meaning | Use |
|---|---|---|
| `playerID` | Historical player identifier | Joins player statistics to names, All-Star records, and Hall of Fame records |
| `year` | Season year used by the source dataset | Season filters, era grouping, and model split keys |
| `tmID` | Historical team identifier | Joins player records to team context |
| `GP` | Games played | Eligibility filters and per-game metrics |
| `minutes` | Total minutes | Minutes per game and points per 48 minutes |
| `points` | Total points | Scoring and team-share metrics |
| `rebounds` | Total rebounds | Rebounds per game and efficiency metrics |
| `assists` | Total assists | Assists per game and team-share metrics |
| `steals` | Total steals | Simple efficiency |
| `blocks` | Total blocks | Simple efficiency |
| `turnovers` | Total turnovers | Turnover rate and efficiency penalties |
| `fgAttempted` | Field goals attempted | Shooting volume, true shooting, and team shot share |
| `fgMade` | Field goals made | Simple efficiency |
| `ftAttempted` | Free throws attempted | True shooting |
| `ftMade` | Free throws made | Simple efficiency |

### `basketball_master.csv`

One row represents a player identity record.

| Field | Meaning | Use |
|---|---|---|
| `bioID` | Player identifier | Joins to `basketball_players.playerID` |
| `useFirst` | Display first name | Builds the player name shown in the app |
| `lastName` | Display last name | Builds the player name shown in the app |
| `pos` | Listed position | Available player profile context |

### `basketball_teams.csv`

One row represents a team-season record.

| Field | Meaning | Use |
|---|---|---|
| `year` | Season year | Joins to player seasons |
| `tmID` | Team identifier | Joins to player seasons |
| `name` | Team name | Display context |
| `confID` | Conference identifier | App filter |
| `o_pts` | Team points | Player share of team points |
| `o_fga` | Team field goal attempts | Player share of team shots |
| `o_asts` | Team assists | Player share of team assists |
| `o_to` | Team turnovers | Team context |
| `won` | Team wins | Team context |
| `lost` | Team losses | Team context |

### `basketball_player_allstar.csv`

| Field | Meaning | Use |
|---|---|---|
| `player_id` | Player identifier | Joins to player seasons |
| `season_id` | Season year | Joins to player seasons |
| `games_played` | All-Star game appearances in the record | Values above zero create the `All-Star` label |

### `basketball_hof.csv`

| Field | Meaning | Use |
|---|---|---|
| `hofID` | Historical person identifier | Joins to player seasons |
| `category` | Hall of Fame category | Only `Player` records are used |

## Derived fields

| Field | Calculation or rule |
|---|---|
| `player_name` | Trimmed `useFirst + lastName`; falls back to `playerID` |
| `era` | Decade derived from `year`, such as `1990s` |
| `all_star` | `All-Star` when a matching All-Star record has games played; otherwise `Not All-Star` |
| `hall_of_fame` | `Hall of Fame` when a matching player-category record exists |
| `minutes_per_game` | `minutes / GP` |
| `points_per_game` | `points / GP` |
| `rebounds_per_game` | `rebounds / GP` |
| `assists_per_game` | `assists / GP` |
| `turnovers_per_game` | `turnovers / GP` |
| `field_goal_attempts_per_game` | `fgAttempted / GP` |
| `points_per_48` | `points / minutes * 48` |
| `true_shooting` | `points / (2 * (fgAttempted + 0.44 * ftAttempted))` |
| `assist_turnover` | `assists / turnovers` |
| `team_point_share` | `points / team points` |
| `team_assist_share` | `assists / team assists` |
| `team_shot_share` | `fgAttempted / team field goal attempts` |
| `team_production_share` | Row mean of point, assist, and shot shares |
| `simple_efficiency` | Per-game sum of positive box score events minus missed shots, missed free throws, and turnovers |
| `tall_data_efficiency_score` | Season-normalized weighted score centered near 50; combines scoring, assists, rebounds, minutes, team share, true shooting, turnovers, and shot volume |

## TallData Efficiency Score weights

The app calculates a z-score for each input within the same season, then applies these weights:

| Input | Weight |
|---|---:|
| Points per game | 0.30 |
| Assists per game | 0.18 |
| Rebounds per game | 0.18 |
| Minutes per game | 0.12 |
| Team production share | 0.15 |
| True shooting | 0.12 |
| Turnovers per game | -0.14 |
| Field goal attempts per game | -0.10 |

The weighted value is transformed as `50 + 10 * weighted_z_score`. It is a custom project metric, not the NBA's official Player Efficiency Rating.

## Modeling fields

The logistic regression and optional random forest use:

- TallData Efficiency Score
- Points, rebounds, assists, turnovers, field goal attempts, and minutes per game
- Team production share
- True shooting

The target is whether the player-season appears as an All-Star. The current workflow uses a seeded 70/30 row-level train/test split.

## Known limits

- The main historical app dataset ends before the modern NBA seasons included in the separate Excel files.
- Team changes can produce more than one player-team row in a season.
- Historical identifiers and team naming can vary across source tables.
- All-Star status reflects the source record and may need manual validation for edge cases.
- Hall of Fame status is a current career outcome, not the status known during that season.
- TallData Efficiency Score depends on the available box score fields and should not be treated as a complete measure of defense or player impact.
