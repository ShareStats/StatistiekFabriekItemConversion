library("DBI")

# Check if mariaDB service is not locally running and start service
if ( identical( grep("none", system("brew services | grep mariadb", intern = TRUE) ), integer(0) ) ) {
  
  # Start mariadb service
  system("brew services start mariadb")
  
}

# Set connection
con <- dbConnect(RMariaDB::MariaDB(), 
                 dbname = "statistiekfabriek", 
                 host   = "localhost")

