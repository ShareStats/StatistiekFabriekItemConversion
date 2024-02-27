library("stringr")

# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern     = ".Rmd", 
                             ignore.case = TRUE, 
                             recursive   = TRUE, 
                             path        = "SQRscripts",
                             full.names  = TRUE)

n = length(all.item.paths)

# Words to find
words = c("[:blank:]\\!\\[",           # 1
          "[:blank:]$",                # 2
          "\\?[a-q]",                  # 3 find questionmark in string
          "\\?\\?n",                   # 4
          "pati\\?nten",               # 5
          "ge\\?nteresseerd",          # 6
          "correlatieco\\?ffici\\?nt", # 7
          "richtingsco\\?ffici\\?nt",  # 8
          "be\\?nvloedt",              # 9
          "be\\?nvloed",               # 10
          "\\?meting",                 # 11
          "\\?voor \\? \\?na",         # 12
          "\\?voor",                   # 13
          "\\?na",                     # 14
          "\\?D",                      # 15
          "\\&\\#",                    # 16 Find HTML character encoding
          "&#8746;",                   # 17
          "^NA$",                        # 18
          "exextra\\[Type\\]\\:[:blank:]$", # 19
          "taxonomyError",                 # 20
          "^\\*[:blank:]\\*",                 # 21
          "\("                 # 22
          )

word = 22

find = words[word]
find

stringi::stri_detect(str = text, regex = find)

# Work in progress, using stringr to find [ 

file = paste0("error-",word,".txt")
# Turn of creating new file to continue appending after crash
writeLines(paste("regex:", find), file)

for (i in 1:n) {
  
  text <- readLines( all.item.paths[i] )
  
  # Search for something in text and return line number
  # Some useful key words: exsection Language Type Level
  
  # Only show file if changes need to be made
  if( sum(stringi::stri_detect(str = text, regex = find) ) > 0 ) {
  
    line.nr = stringi::stri_detect(str = text, regex = find)

    print(c(i, text[line.nr], all.item.paths[i]) )
    
    write(paste0(i, ' open "', all.item.paths[i], '"'), file, append = TRUE)

  }
  
}


