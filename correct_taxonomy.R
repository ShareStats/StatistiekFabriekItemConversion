# Script to extract taxonomy path in statistiekfabriek items

# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern = ".Rmd", ignore.case = TRUE, recursive = TRUE)

library(stringr)


n = length(all.item.paths)

taxonomy.conversion.table = data.frame(matrix(NA,n, 5))

names(taxonomy.conversion.table) = c("name", "path", "exsection_line", "exsection", "lastWord")

for (i in 1:n) {
  
  # print(all.item.paths[i])
  
  text <- readLines( all.item.paths[i] )
  
  # Search for something in text and return line number
  # Some usefull key words: exsection Language Type Level
  line.nr = grep("exsection", text)
  
  # print(text[line.nr])
  
  taxonomy.conversion.table$path[i]           = all.item.paths[i]
  taxonomy.conversion.table$exsection_line[i] = line.nr
  taxonomy.conversion.table$exsection[i]      = text[line.nr]

}

# taxonomy.conversion.table$lastWord = word(str_replace(taxonomy.conversion.table$exsection, ",", " "), -1)

unique.initial.taxonomy = unique(taxonomy.conversion.table$exsection)

taxonomy.lookup.table = data.frame(oldTax = unique(taxonomy.conversion.table$exsection), newTax = "exsection: ")

# Write unique taxonomies paths to file

# write.csv2(file = "2taxonomyLookupTable.csv", taxonomy.lookup.table, row.names = FALSE)

# Manually add new taxonomie path to file
# Read newly created taxonomy conversion table

taxonomy.conversion <- read.csv2("taxonomyLookupTable.csv")

# Rewrite taxonomy paths

for (i in 440:440) {
  
  # print(all.item.paths[i])
  
  text <- readLines( all.item.paths[i] )
  
  # Search for something in text and return line number
  # Some usefull key words: exsection Language Type Level
  line.nr = grep("exsection", text)
  
  # Lookup new taxonomy path

    # correct ?  to \xeb conversion  
    string <- gsub("(\xeb)|(\xdf)|(\xe9)","?", text[line.nr])
  
  newTax <- taxonomy.conversion[which( taxonomy.conversion == string ), "newTax"]
  
  # replace old taxonomy with new one in specific line in text
  
  text[line.nr] <- newTax
  
  writeLines(text, all.item.paths[i] )
  
  # Check if new path has been writen
  ifelse( readLines( all.item.paths[i])[grep("exsection", readLines( all.item.paths[i]))] == newTax,
          print(paste("1 - ", all.item.paths[i])), 
          print(paste("0 - ", all.item.paths[i])) 
        )
  
}
