# Attempt table: knitting file 

library(rjson)
setwd("C:/Users/luisa/OneDrive/Desktop/WORK/R.scripts_data organisation")

data_os <- fromJSON(file = 'OpenString_Data.json')
data_os <- data.frame(matrix(unlist(data_os), nrow=length(data_os), byrow=TRUE)) 

# RENAMING 
data_os$id <- data_os[,1] 
data_os$question <- data_os[,2]
data_os$correct_answer <- data_os[,3] 
data_os$alltags <- data_os[,4]  

# dropping X-variables names 
data_os = subset(data_os, select = -c(X1,X2, X3, X4)) 

# INFORMATION JSON - question
question_os <- jsonlite::stream_in(textConnection(gsub("\\n", "", data_os$question))) 

# Table creation 

 
for (i in 1:nrow(question_os)){
  
  q <- question_os$question[i,2]
  
  q <- gsub("<table>|<tbody>|<tr>","", q, fixed = TRUE);
  q <- gsub("</table>","\n\n", q, fixed = TRUE);
  q <- gsub("</tbody>", "", q, fixed = TRUE);
  q <- gsub("</td>", "|" , q, fixed = TRUE);
  q <- gsub("<td>", "", q, fixed = TRUE);
  q <- gsub("</tr>", "|\n", q, fixed = TRUE);
  q <- gsub("&euro;", "Euro", q, fixed = TRUE);
  q <- gsub("euro&#39;s", "Euro", q, fixed = TRUE);
  question_os$question[i,2] <- q
}


##############################################################################
# item creation 
##############################################################################

# category retrieval 

#install.packages("stringr")
library(stringr)

# creating empty vector to save all categroies  
cat <- numeric()

for (i in 1:nrow(data_os)){
  cat[i] <- word(data_os$alltags[i], 1, sep = ",") 
}
cat

# name retrieval 

# creating empty vector to save all names 
q.name <- numeric() 

for (i in 1:nrow(data_os)) {
  if (grepl("Veronderstellingen", data_os$alltags[i]) == TRUE ) {
    q.name[i] = paste0("uva-assumptions-", data_os$id[i], "-nl.Rmd") # instead of data_os$id[i] solely [i]
  } else if (grepl ("Beschrijvende statistiek", data_os$alltags[i]) == TRUE ) {
    q.name[i] = paste0("uva-descriptive statistics-", data_os$id[i], "-nl.Rmd")
  } else if (grepl ("Distributies", data_os$alltags[i]) == TRUE ) {
    q.name[i] = paste0("uva-distributions-", data_os$id[i], "-nl.Rmd")
  } else if (grepl ("Factoren Analyse", data_os$alltags[i]) == TRUE ) {
    q.name[i] = paste0("uva-factor_analysis-", data_os$id[i], "-nl.Rmd")
  } else if (grepl ("Inferentiële statistiek", data_os$alltags[i]) == TRUE ) {
    q.name[i] = paste0("uva-inferential statistics-", data_os$id[i], "-nl.Rmd")
  } else if (grepl ("Meetniveaus", data_os$alltags[i]) == TRUE ) {
    q.name[i] = paste0("uva-measurement level-", data_os$id[i], "-nl.Rmd")
  } else if (grepl ("Kansrekening", data_os$alltags[i]) == TRUE) {
    q.name[i] = paste0("uva-probability-", data_os$id[i], "-nl.Rmd")
  } else if (grepl ("Betrouwbaarheid", data_os$alltags[i]) == TRUE ) {
    q.name = paste0("uva-reliability-", data_os$id[i], "-nl.Rmd")
  } else if (grepl ("variable type", data_os$alltags[i]) == TRUE ) {
    q.name[i] = paste0("uva-variable_type-", data_os$id[i], ".Rmd") # "Varialbe_type/" == folder specification for general sorting other layour is needed maybe just possible with "variable_type/", "q.name" however this would be a variable but can be indexed if all names are stored in one object 
  } else {
    print(data_os$id[i]) 
  } 
}
q.name

# Folder - file creation

# setting working directory to "final"
setwd("C:/Users/luisa/OneDrive/Desktop/WORK/Final") 

# checking available folders in set working directory
list.files()

# creating data.frame() for category and file name 
items <- data.frame(cat = as.character(cat), name = as.character(q.name))

##############################################################################
# loop for creating folders, files and .Rmd
##############################################################################

# i = 1
library("htm2txt")

for(i in 1:nrow(data_os)) {
  
  # select item info from row
  item <- items[i, ]
  
  # Go to correct taxonomy category and set working directory
  setwd(as.character(item[1]))
  
  # Create folder based on item name in the taxonomy category folder
  dir.create(as.character(item[2]))
  
  # Go into the newly created item name folder and set that to be the working directory
  setwd(as.character(item[2]))
  
  # Save file in this folder
  # cat("Test", file = paste0(item[2],".Rmd"))
  
  header = "Question\n========\n\n"
  
  cat(header, file = q.name[i]) # 1st element of Rmd 
  
  question.os = paste(htm2txt(question_os[i,3][1,2]), "\n\n")
  cat(question.os, file = q.name[i], append = TRUE) # 2nd element of Rmd 
  
  header2 = "Solution\n========\n\n"
  cat(header2, file = q.name[i], append = TRUE) # 3rd element of Rmd 
  
  solution = paste("The correct answer is", data_os$correct_answer[i], "\n\n") 
  cat(solution, file = q.name[i], append = TRUE) # 4th element of Rmd 
  
  header3 = "Meta-information\n================\n"
  cat(header3, file = q.name[i], append = TRUE)
  
  ##################
  # meta information 
  ##################
  
  # name 
  cat(paste("exname:", q.name[i], "\n"), file = q.name[i], append = TRUE)
  
  # type
  cat(paste("extype:", "num","\n"), file = q.name[i], append = TRUE) 
  
  # solution

  cat(paste0("exsolution:","The correct answer is ", data_os$correct_answer[i], ".", "\n"), file = q.name[i], append = TRUE) # delete any text
  
  # section labels /tags- NEEDS TO BE ADDED IN ENGLISH
  cat(paste("exsection:", data_os$alltags[i], "\n"), file = q.name[i], append = TRUE)
  
  # exextra/types- NEEDS TO BE FILTERED
  types <- "Calculation, Case, Conceptual, Creating graphs, Data manipulation, Interpretating graph, Interpretating output, Performing analysis, Test choice"
  cat(paste("exextra[Type]:", types, "\n"), file = q.name[i], append = TRUE) 
  
  # exextra/language
  cat(paste("exextra[Langauge]:", "Dutch", "\n"), file = q.name[i], append = TRUE) 
  
  # exextra/level
  cat(paste("exextra[Level]:", "Statistical Literacy", "\n"), file = q.name[i], append = TRUE) 
  
  # Get out of the item folder, then get out of the category folder.
  setwd("../../")
}