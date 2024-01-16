library("DBI")

con <- dbConnect(RMariaDB::MariaDB(), 
                 dbname = "statistiekfabriek", 
                 host   = "localhost")

dbListTables(con)

query = "select id, question from items limit 10"

res <- dbSendQuery(con, query)
dbFetch(res)
dbClearResult(res)

dbDisconnect(con)