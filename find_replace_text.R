# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern     = ".Rmd", 
                             ignore.case = TRUE, 
                             recursive   = TRUE, 
                             path        = "almost_def_all_items",
                             full.names  = TRUE)

n = length(all.item.paths)

# Words to replace
findReplace = rbind(c("co\\?ffici\\?nten", "coëfficiënten"),
                    c("u00eb", "ë"), # with \ R searches for ë and not \u00eb
                    c("\\ë", "ë"),   # excape \
                    c("\\\\ë", "ë")  # found some with double \\
                  )

word = 4

find    = findReplace[word, 1]
replace = findReplace[word, 2]

for (i in 1:n) {
  
  text <- readLines( all.item.paths[i] )
  
  # Search for something in text and return line number
  # Some usefull key words: exsection Language Type Level
  

  
  # Only write file if changes need to be made
  if( !identical(grep(find, text), integer(0) ) ) {
  
    # find -> replace
    text <- gsub(find, replace, text)
    line.nr = grep(replace, text)  
  
    print(text[line.nr])
    writeLines(text, all.item.paths[i])
  }
  
}