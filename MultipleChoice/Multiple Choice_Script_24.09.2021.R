
  # clearing working evnrionement
  rm(list = ls())
  list.files()
  
  ##############################################################################
  # load data mc
  ##############################################################################
  
  library(rjson)
  setwd("C:/Users/luisa/OneDrive/Desktop/WORK/R.scripts_data organisation")

  data_mc <- fromJSON(file = 'MultipleChoice_Data.json') 
  data_mc <- data.frame(matrix(unlist(data_mc), nrow=length(data_mc), byrow=T))
 
  # RENAMING
  data_mc$id <- data_mc[,1]   
  data_mc$question <- data_mc[,2]
  data_mc$answer_options <- data_mc[,3]
  data_mc$correct_answer <- data_mc[,4]
  data_mc$alltags <- data_mc[,5]
  
  # dropping X-variables names
  data_mc = subset(data_mc, select = -c(X1,X2, X3, X4, X5)) 
  
  # INFORMATION JSON - question
  question_mc <- jsonlite::stream_in(textConnection(gsub("\\n", "", data_mc$question))) 

  ##############################################################################
  # item creation 
  ##############################################################################
  
  # category retrieval 
  
  #install.packages("stringr")
  library(stringr)
  
  # creating empty vector to save all categroies  
  cat.mc <- numeric()
  
  for (i in 1:nrow(data_mc)){
    cat.mc[i] <- word(data_mc$alltags[i], 1, sep = ",") 
  }
  
  cat.mc[6] <- "Manual"
  cat.mc[13] <- "Manual"
  cat.mc[17] <- "Manual"
  cat.mc[596] <- "Manual"
  cat.mc[591] <- "Manual"
  
  cat.mc
  # name retrieval 
  
  # creating empty vector to save all names 
  q.name.mc <- numeric() 
  
  for (i in 1:nrow(data_mc)) {
    if (grepl("Veronderstellingen", data_mc$alltags[i]) == TRUE ) {
      q.name.mc[i] = paste0("uva-assumptions-", data_mc$id[i], "-nl.Rmd") # instead of data_os$id[i] solely [i]
    } else if (grepl ("Beschrijvende statistiek", data_mc$alltags[i]) == TRUE ) {
      q.name.mc[i] = paste0("uva-descriptive statistics-", data_mc$id[i], "-nl.Rmd")
    } else if (grepl ("Distributies", data_mc$alltags[i]) == TRUE ) {
      q.name.mc[i] = paste0("uva-distributions-", data_mc$id[i], "-nl.Rmd")
    } else if (grepl ("Factoren Analyse", data_mc$alltags[i]) == TRUE ) {
      q.name.mc[i] = paste0("uva-factor_analysis-", data_mc$id[i], "-nl.Rmd")
    } else if (grepl ("Inferentiële statistiek", data_mc$alltags[i]) == TRUE ) {
      q.name.mc[i] = paste0("uva-inferential statistics-", data_mc$id[i], "-nl.Rmd")
    } else if (grepl ("Meetniveaus", data_mc$alltags[i]) == TRUE ) {
      q.name.mc[i] = paste0("uva-measurement level-", data_mc$id[i], "-nl.Rmd")
    } else if (grepl ("Kansrekening", data_mc$alltags[i]) == TRUE) {
      q.name.mc[i] = paste0("uva-probability-", data_mc$id[i], "-nl.Rmd")
    } else if (grepl ("Betrouwbaarheid", data_mc$alltags[i]) == TRUE ) {
      q.name.mc = paste0("uva-reliability-", data_mc$id[i], "-nl.Rmd")
    } else if (grepl ("variable type", data_mc$alltags[i]) == TRUE ) {
      q.name.mc[i] = paste0("uva-variable_type-", data_mc$id[i], ".Rmd") # "Varialbe_type/" == folder specification for general sorting other layout is needed maybe just possible with "variable_type/", "q.name" however this would be a variable but can be indexed if all names are stored in one object 
    } else {
      q.name.mc[i] = paste0("uva-manual-", data_mc$id[i], ".Rmd") # items with no matching label are saved under "manually" to sort them later 
      print(data_mc$id[i]) 
    } 
  }
  
  # replacing NAs
  # Dec
  
# q.name.mc[6] <- paste0("uva-probability-", data_mc$id[6], "-nl.Rmd")
# q.name.mc[13] <- paste0("uva-probability-", data_mc$id[13], "-nl.Rmd")
# q.name.mc[17] <- paste0("uva-probability-", data_mc$id[17], "-nl.Rmd")
# q.name.mc[596] <- paste0("uva-inferential statistics-", data_mc$id[596], "-nl.Rmd")
# q.name.mc[591] <- paste0("uva-inferential statistics-", data_mc$id[591], "-nl.Rmd")


  # Folder - file creation

  # setting working directory to "final"
  setwd("C:/Users/luisa/OneDrive/Desktop/WORK/Final") 
  
  # checking available folders in set working directory
  list.files()
  
  # creating data.frame() for category and file name 
  items.mc <- data.frame(cat = as.character(cat.mc), name = as.character(q.name.mc))
  
  ##############################################################################
  # loop for creating folders, files and .Rmd
  ##############################################################################

    n <- 20
  
  for (i in 1:n){ # nrow(data_mc)

    # select item info from row
    item.mc <- items.mc[i, ]
    
    # Go to correct taxonomy category and set working directory
    setwd(as.character(item.mc[1]))
    
    # Create folder based on item name in the taxonomy category folder
    dir.create(as.character(item.mc[2]))
    
    # Go into the newly created item name folder and set that to be the working directory
    setwd(as.character(item.mc[2]))
    
    # Save file in this folder
    # cat("Test", file = paste0(item[2],".Rmd"))
    
    header = "Question\n========\n\n"
    
    cat(header, file = q.name.mc[i]) # 1st element of Rmd 
    
    library(htm2txt)
    question.mc = paste(htm2txt(question_mc[i,3][1,2]), "\n\n")
    cat(question.mc, file = q.name.mc[i], append = TRUE) # 2nd element of Rmd 
    
    
    header1 = "Answerlist\n----------\n"
    cat(header1, file = q.name.mc[i], append = TRUE) 
    
    answer.mc <- data_mc$answer_options[i]
    answer.mc <- gsub("[\"","* ",  answer.mc, fixed = TRUE);
    answer.mc <- gsub("\"]", "\n", answer.mc, fixed = TRUE); 
    answer.mc <- gsub("\",\"", "\n* ", answer.mc, fixed = TRUE);
    
    answerlist.mc <- paste0(answer.mc, "\n")
    cat(answerlist.mc, file = q.name.mc[i], append = TRUE)
    
    header2 = "Solution\n========\n\n"
    cat(header2, file = q.name.mc[i], append = TRUE) # 3rd element of Rmd 
    
    solution.binary = data_mc$correct_answer[i]
    answerlist.mc = gsub("*", "", answerlist.mc, fixed = TRUE)
    answerlist.mc = as.data.frame(strsplit(answerlist.mc, split ="\n")) 
    
      if (solution.binary == "0") {
        solution.mc <- answerlist.mc[1,]
      } else if (solution.binary == "1") {
        solution.mc <- answerlist.mc[2,]
      } else if (solution.binary == "2") {
        solution.mc <- answerlist.mc[3,]    # i in code is missing: running variable 
      } else if (solution.binary == "3") {
        solution.mc <- answerlist.mc[4,]
      } else {
        solution.mc <- "ENTER MANUALLY"
      }
                          
    cat(paste("The correct answer is",solution.mc, "\n\n"), file = q.name.mc[i], append = TRUE) # 4th element of Rmd 
    
    header3 = "Meta-information\n================\n"
    cat(header3, file = q.name.mc[i], append = TRUE)
    
    ##################
    # meta information 
    ##################
    
    # name
    cat(paste("exname:", q.name.mc[i], "\n"), file = q.name.mc[i], append = TRUE)
    
    # type
    cat(paste("extype:", "schoice","\n"), file = q.name.mc[i], append = TRUE) 
    
    # exsolution 
    if (data_mc$correct_answer[i] == "0") { 
      cat(paste("exsolution:", "100","\n"), file = q.name.mc[i], append = TRUE)
    } else if (data_mc$correct_answer[i] == "1") { 
      cat(paste("exsolution:", "010","\n"), file = q.name.mc[i], append = TRUE)
    } else if (data_mc$correct_answer[i] == "2") {
      cat(paste("exsolution:", "001","\n"), file = q.name.mc[i], append = TRUE)
    } else if (data_mc$correct_answer[i] == "3") {
      cat(paste("exsolution:", "0001","\n"), file = q.name.mc[i], append = TRUE)
    } else {
      cat(paste("exsolution:", "no binary code","\n"), file = q.name.mc, append = TRUE)
    } 
    
    # section labels /tags- NEEDS TO BE ADDED IN ENGLISH
    cat(paste("exsection:", data_mc$alltags[i], "\n"), file = q.name.mc[i], append = TRUE)
    
    # exextra/types- NEEDS TO BE FILTERED
    types <- "Calculation, Case, Conceptual, Creating graphs, Data manipulation, Interpretating graph, Interpretating output, Performing analysis, Test choice"
    cat(paste("exextra[Type]:", types, "\n"), file = q.name.mc[i], append = TRUE) 
    
    # exextra/language
    cat(paste("exextra[Langauge]:", "Dutch", "\n"), file = q.name.mc[i], append = TRUE) 
    
    # exextra/level
    cat(paste("exextra[Level]:", "Statistical Literacy, Statistical Reasoning, Statistical Thinking", "\n"), file = q.name.mc[i], append = TRUE) 
    
    # Get out of the item folder, then get out of the category folder.
    setwd("../../")
    # setwd("C:/Users/luisa/OneDrive/Desktop/WORK/Final") 
  }
########################################
  ##################
  # problem_problem 
  ##################
 
# P: Sorting of items into folder 

data_mc$alltags[6]   # id == [1] "6"    # "Kansdefinities,Klassieke kansdefinitie"
data_mc$alltags[13]  # id == [1] "13"   # "Kansdefinities,Klassieke kansdefinitie"
data_mc$alltags[17]  # id == [1] "17"   # "Kansdefinities,Uitkomstenruimte (even waarschijnlijke uitkomsten)"
data_mc$alltags[596] # id == [1] "596"  # "Inferentiële statistiek,Toetstheorie,Anova,Oneway, F-verdeling,p-waarde"
data_mc$alltags[591] # id == [1  "591  "# "Gepaarde T toets,Toetsingsgrootheid (tgh)"

    
    ##################
    # IMAGE 
    ##################


```{r, echo = FALSE, results = "hide"}
include_supplement("UvA20101001-14-1.png", recursive = TRUE)
```
![](UvA20101001-14-1.png)
[Download](UvA20101001-14-1.png)

