library("DBI")

con <- dbConnect(RMariaDB::MariaDB(), 
                 dbname = "statistiekfabriek", 
                 host   = "localhost")

