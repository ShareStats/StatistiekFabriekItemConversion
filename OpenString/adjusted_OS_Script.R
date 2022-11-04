##############################################################################
# load data os
##############################################################################

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

##############################################################################
# tax labels
##############################################################################

setwd("C:/Users/luisa/OneDrive/Desktop/WORK")
taxonomy <- read.csv2("tax.csv", sep = ",", header = TRUE)

#setwd("C:/Users/luisa/OneDrive/Desktop/WORK/Final/Kansrekening/OS/uva-probability-128-nl.Rmd")
#"uva-probability-128-nl"

# replacement with right string
correct.tax <- numeric()
for (i in 1:nrow(data_os)){
  correct.tax[i] <- taxonomy$Correct.String.OS[i]
}

data_os <- cbind(data_os, correct.tax) # binding naming labels for files on the dataset
data_os$correct.tax

# split string: last item to create name 
names <- numeric()
for (i in 1:nrow(data_os)){
  names[i] <- sub(".*/", "", data_os$correct.tax[[i]])
}
names

library(stringr)

for (i in 1:nrow(data_os)){
  names[i] <- str_replace_all(string=names[i], pattern=" ", repl="-")
}
names


library(quanteda) # package required to lower all letters 

q.name.os.folder <- numeric() 

for (i in 1:nrow(data_os)){
  q.name.os.folder[i] = paste0("uva-", names[i], "-", data_os$id[i]) # instead of data_os$id[i] solely [i]
  q.name.os.folder[i] = tolower(q.name.os.folder[i])
}
q.name.os.folder 

q.name.os.file <- numeric()

for (i in 1:nrow(data_os)){
  q.name.os.file[i] = paste0(q.name.os.folder[i],"-nl", ".Rmd") # instead of data_os$id[i] solely [i]
}

q.name.os.file 

library(stringr)
# replacing all "," with "," for the exsolution (meta data) to enable processing in testvision 

for (i in 1:nrow(data_os)){
  data_os$correct_answer[i] <- str_replace_all(string=data_os$correct_answer[i], pattern=",", repl=".")
}
data_os$correct_answer 

# Folder - file creation

# setting working directory to "final"
setwd("C:/Users/luisa/OneDrive/Desktop/WORK/Final") 

# checking available folders in set working directory
list.files()

##############################################################################
# item creation 
##############################################################################

# category retrieval 

#install.packages("stringr")
library(stringr)

# creating empty vector to save all categories  
cat <- numeric()

for (i in 1:nrow(data_os)){
  cat[i] <- word(data_os$alltags[i], 1, sep = ",") 
}
cat

# creating data.frame() for category and file name 
items <- data.frame(cat = as.character(cat), name = as.character(q.name.os.file))

##############################################################################
# loop for creating folders, files and .Rmd
##############################################################################

#i = 1
library("htm2txt")

for(i in 1:nrow(data_os)) {
  
  # select item info from row
  item <- items[i, ]
  
  # Go to correct taxonomy category and set working directory
  setwd(as.character(item[1]))
  
  # Create folder based on item name in the taxonomy category folder
  dir.create(as.character(q.name.os.folder[i])) # orginal: dir.create(as.character(item[2]))
  
  # Go into the newly created item name folder and set that to be the working directory
  setwd(as.character(q.name.os.folder[i])) # origninal: item[2]
  
  # Save file in this folder
  # cat("Test", file = paste0(item[2],".Rmd"))
  
  header = "Question\n========\n\n"
  
  cat(header, file = q.name.os.file[i]) # 1st element of Rmd 
  
  question.os = paste(htm2txt(question_os[i,3][1,2]), "\n\n")
  cat(question.os, file = q.name.os.file[i], append = TRUE) # 2nd element of Rmd 
  
  header2 = "Solution\n========\n\n"
  cat(header2, file = q.name.os.file[i], append = TRUE) # 3rd element of Rmd 
  
  solution = paste0("The correct answer is ", data_os$correct_answer[i], ".", "\n\n") 
  cat(solution, file = q.name.os.file[i], append = TRUE) # 4th element of Rmd 
  
  header3 = "Meta-information\n================\n"
  cat(header3, file = q.name.os.file[i], append = TRUE)
  
  ##################
  # meta information 
  ##################
  
  
  # name
  cat(paste("exname:", q.name.os.folder[i], "\n"), file = q.name.os.file[i], append = TRUE)
  
  # type
  cat(paste("extype:", "num","\n"), file = q.name.os.file[i], append = TRUE) 
  
  # solution
  cat(paste("exsolution:", data_os$correct_answer[i], "\n"), file = q.name.os.file[i], append = TRUE) 
  
  # section labels /tags- NEEDS TO BE ADDED IN ENGLISH
  cat(paste("exsection:", data_os$correct.tax[i], "\n"), file = q.name.os.file[i], append = TRUE)
  
  # exextra/types- NEEDS TO BE FILTERED
  types <- "Calculation"
  #, Case, Conceptual, Creating graphs, Data manipulation, Interpretating graph, Interpretating output, Performing analysis, Test choice
  
  cat(paste("exextra[Type]:", types, "\n"), file = q.name.os.file[i], append = TRUE) 
  
  # exextra/language
  cat(paste("exextra[Language]:", "Dutch", "\n"), file = q.name.os.file[i], append = TRUE) 
  
  # exextra/level
  cat(paste("exextra[Level]:", "Statistical Literacy", "\n"), file = q.name.os.file[i], append = TRUE) 
  
  # Get out of the item folder, then get out of the category folder.
  setwd("../../")
}


# to check item 
# example 688

library(exams)
exams2html(file = "uva-union-688-nl.Rmd")
