# retrieve path to all rmarkdown files
all.item.paths <- list.files(pattern     = ".Rmd", 
                             ignore.case = TRUE, 
                             recursive   = TRUE, 
                             path        = "almost_def_all_items",
                             full.names  = TRUE)

n = length(all.item.paths)

# Words to replace
findReplace = rbind(c("co\\?ffici\\?nten", "coëfficiënten"), # 1: Correct ë representation in text
                    c("u00eb", "ë"),                         # 2: with \ R searches for ë and not \u00eb
                    c("\\ë", "ë"),                           # 3: excape \
                    c("\\\\ë", "ë"),                         # 4: found some with double \\
                    c("[:blank:]\\!\\[", "!["),              # 5: Delete whitespace before " !["
                    c("[:blank:]$", ""),                     # 6: Delete blank at end of line
                    c("\\?\\?n","één"),                      # 7: ??n -> één
                    c("pati\\?nten", "patiénten"),           # 8
                    c("ge\\?nteresseerd","geïnteresseerd"),  # 9
                    c("correlatieco\\?ffici\\?nt","correlatiecoëfficiënt"), # 10
                    c("richtingsco\\?ffici\\?nt","richtingscoëfficiënt"),   # 11
                    c("be\\?nvloedt", "beïnvloedt"),         # 12
                    c("be\\?nvloed", "beïnvloed"),           # 13
                    c("\\?meting", "meting"),                # 14
                    c("\\?voor \\? \\?na", "voor - na"),     # 15
                    c("\\?voor", "voor"),                    # 16
                    c("\\?na", "na"),                        # 17
                    c("\\?D", "D"),                          # 18
  #                  c("&#8746;", "$\cup$"),                  # 19
                    c("", "")
                  )

word = 18

find    = findReplace[word, 1]
replace = findReplace[word, 2]

for (i in 1:n) {
  
  text <- readLines( all.item.paths[i] )
  
  # Search for something in text and return line number
  # Some usefull key words: exsection Language Type Level
  

  
  # Only write file if changes need to be made
  if( sum(stringi::stri_detect(str = text, regex = find) ) > 0 ) {
  
    # find -> replace
    # text <- gsub(find, replace, text) 
    text <- stringi::stri_replace(str = text, regex = find, replacement = replace)
    # line.nr = grep(replace, text)  
  
    print(text[line.nr])
    writeLines(text, all.item.paths[i])
  }
  
}