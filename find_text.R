library("stringr")

# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern     = ".Rmd", 
                             ignore.case = TRUE, 
                             recursive   = TRUE, 
                             path        = "almost_def_all_items",
                             full.names  = TRUE)

n = length(all.item.paths)

# Words to find
words = c("\!\[")

word = 1

find = words[word]

# Work in progress, using stringr to find [ 


for (i in 1:n) {
  
  text <- readLines( all.item.paths[i] )
  
  # Search for something in text and return line number
  # Some usefull key words: exsection Language Type Level
  

  
  # Only write file if changes need to be made
  if( !identical(grep(find, text), integer(0) ) ) {
  
    line.nr = grep(replace, text)  
  
    print(text[line.nr])
st
  }
  
}

stringi::stri_detect(str = text, regex = find)
