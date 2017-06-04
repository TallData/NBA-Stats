library("RMySQL", lib.loc="~/R/win-library/3.1")

# Connect to a MySQL database running locally
con <- dbConnect(RMySQL::MySQL(), dbname = "NBA", user = "root", password = "kgjr0928")


dbWriteTable(con, "player_key", player_key[-1,], row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "player_hist", player_hist, row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "player_hof", player_hof, row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "team_hist", team_hist, row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "team_playoffs", team_playoffs, row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "nba_abbrv", nba_abbrv, row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "player_awards", player_awards, row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "player_allstar", player_allstar, row.names = TRUE, overwrite = TRUE)
             