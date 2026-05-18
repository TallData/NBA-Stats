library(RMySQL)

# Connect to a MySQL database running locally
db_name <- Sys.getenv("DB_NAME", "NBA")
db_user <- Sys.getenv("DB_USER")
db_password <- Sys.getenv("DB_PASSWORD")
db_host <- Sys.getenv("DB_HOST", "localhost")
db_port <- as.integer(Sys.getenv("DB_PORT", "3306"))

if (db_user == "" || db_password == "") {
  stop("Set DB_USER and DB_PASSWORD environment variables before running this script.")
}

con <- dbConnect(
  RMySQL::MySQL(),
  dbname = db_name,
  user = db_user,
  password = db_password,
  host = db_host,
  port = db_port
)


dbWriteTable(con, "player_key", player_key[-1,], row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "player_hist", player_hist, row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "player_hof", player_hof, row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "team_hist", team_hist, row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "team_playoffs", team_playoffs, row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "nba_abbrv", nba_abbrv, row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "player_awards", player_awards, row.names = TRUE, overwrite = TRUE)
dbWriteTable(con, "player_allstar", player_allstar, row.names = TRUE, overwrite = TRUE)
             
