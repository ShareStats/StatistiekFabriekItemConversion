# install.packages("rjson")
library("rjson")
library("dplyr")
library("rmarkdown")
library("XML")

source("SQRscripts/DBconnect.R")

dbListTables(con)

item.row = 1900

query = "select id, 
                question,
                answer_options,
                correct_answer,
                round(rating,3) as beta,
                m.ranked / 1939  as difficultyPercentage
         from   items, ( select count(rating) as ranked 
                         from   items
                         where  rating <= (select rating from items where id = %s) ) as m
         where  id = %s"

query = sprintf(query, item.row, item.row)
res <- dbSendQuery(con, query)
itemResrults <- dbFetch(res)

dbClearResult(res)

jsonItem <- fromJSON(itemResrults$question)

item.id       = itemResrults$id
item.type     = jsonItem$type
item.question = jsonItem$question$content[[1]]
item.answer   = itemResrults$correct_answer
item.beta     = itemResrults$beta

item.difficultyPercentage = itemResrults$difficultyPercentage

# Retrieve nl taxonomy

query = "select items_tags.tag_id,
                tags.description,
                parent_id
         from   items_tags,
                tags
         where  items_tags.item_id = %s
         and    items_tags.tag_id = tags.id"

query = sprintf(query, item.id)

res     <- dbSendQuery(con, query)
tag.ids <- dbFetch(res)

dbClearResult(res)

# Select only taxonomy tags which have tag id < 156
taxonomy <- tag.ids[which(tag.ids$tag_id<151), "description"]
exsection.nl = paste(taxonomy, collapse = ",")

# load lookup table for NL > EN taxonomy
nl.en.lookup <- read.csv2(file = "SQRscripts/taxonomyLookupTable.csv", header = TRUE)
# get rid of exsection text
nl.en.lookup$oldTax <- gsub("exsection: ", "", nl.en.lookup$oldTax)
nl.en.lookup$newTax <- gsub("exsection: ", "", nl.en.lookup$newTax)
# trim trailing white spaces
nl.en.lookup$oldTax <- gsub(" $","", nl.en.lookup$oldTax)

# Check if there is a match, replace exsection.nl with exsection.en
if (!identical(which(nl.en.lookup$oldTax == exsection.nl), integer(0) ) ) {
  
  # Add EN taxonomy to exsection
  exsection <- nl.en.lookup[which(nl.en.lookup$oldTax == exsection.nl), "newTax"]

} else {
  
  # Add error message set exsection.nl
  exsection <- paste("taxonomyError", exsection.nl)
  
  # Indicate error on item
  print(paste("error on item:", item.id))
  
}

# Create file / path / item name

exname.university = "uva-"
exname.taxonomy   = stringr::str_extract(exsection, "[a-zA-Z ]+$")      # select last taxonomy level
exname.taxonomy   = stringr::str_replace_all(exname.taxonomy, " ", "-") # replace whitespace with underscore
exname.taxonomy   = stringr::str_to_lower(exname.taxonomy)              # convert to small caps
exname.number     = item.id
exname.langguage  = "-nl"
exname.suffix     = ".Rmd"

# item name
exname = paste0(exname.university,
                exname.taxonomy,
                "-",
                exname.number,    
                exname.langguage )

# file name
file.name = paste0(exname.university,
                   exname.taxonomy,
                   "-",
                   exname.number,    
                   exname.langguage, 
                   exname.suffix )

# folder name
folder.name = exname

#### Retrieve item tags

# Parent ids for classification range from 154 to 156
level.nl = na.omit(tag.ids[between(tag.ids$parent_id, 154, 156), "description"])[1]

# 3 levels have been applied: "Kennisitem", "Vaardigheidsitem", "Gemengd item (kennis & vaardigheid)"

# Set type to vector for there can be multiple type values
type = vector()

# Applying type conceptual to all knowledge items
if (level.nl == "Kennisitem") { type = append(type, "Conceptual", length(type)) }
if (level.nl == "Gemengd item (kennis & vaardigheid)") { type = append(type, "Conceptual", length(type)) }

# Application "Vaardigheidsitem" could be on multiple topics.
# For example: the ability to interpret results or perform an analysis
# Will try to assume based on queston

# Assume that if the question contains the word bereken
# with or without capital B, the question type is calculation
if ( stringr::str_detect(item.question, "[bB]ereken") ) {
  
  type = append(type, "Calculation", length(type))
  
}

# Queried questions for use of the word spss, 
# all indicate output interpretation questions
if ( stringr::str_detect(item.question, "spss|SPSS") ) {
  
  type = append(type, "Interpreting output", length(type))
  
}

#### Create variables only for MultipleChoice item types

if(item.type == "MultipleChoice") {
  
  item.answer.options = fromJSON(itemResrults$answer_options)
  numeric.answer <- as.numeric(item.answer.options)
  # Create binary solution string
  # item.answer starts at 0, hense +1 for use in R
  exsolution = paste0(as.numeric(1:length(item.answer.options) == as.numeric(item.answer)+1), collapse = "" )
  
  extype = "schoice"

  # Add html list element
  item.answer.options <- paste0("<li>" ,item.answer.options, "</li>")  
  
  # Add unordered list element
  item.answer.options <- c("<ul>", item.answer.options, "</ul>")
    
  # Save answer options as html
  html.answer <- htmlParse(item.answer.options, asText=TRUE)
  
  answer.md <- paste("*", readHTMLList(html.answer)[[1]] )
  
  # If only numaric answer options classify as type calculation
  if ( is.numeric(numeric.answer) ) {
    
    type = append(type, "Calculation", length(type))
    
  }
  
}

#### Create variables only for open questions item types

if(item.type == "OpenString") {
  
  # Assign item numeric correct answer
  exsolution = as.numeric(item.answer)
  
  extype = "num"
  
  type = append(type, "Calculation", length(type))
  
}

# combine multiple type tags. If no tags specified, than type sting is empty
type = stringr::str_c(unique(type), collapse = ", ")

##### Clean up question stem and answer options

# Clean up all html in question
html.question <- htmlParse(item.question, asText=TRUE)

# Create temp file
temp.html = "temp.html"
temp.md  = "temp.md"

# Temporary save HTML
saveXML(html.question, temp.html)

# Convert temp HTML to markdown
pandoc_convert(temp.html, to = "markdown", output = temp.md)

# read md document back in
question.md <- readLines(temp.md)

# Get rid of incorrect backslashes prefix on onderscores
question.md <- stringr::str_replace_all(question.md, "\\\\_", "_")

# replace \[ and \] by $ as markdown latex indicator
question.md <- stringr::str_replace_all(question.md, "\\\\\\\\\\\\\\[|\\\\\\\\\\\\\\]", "$")

# remove \\ line break charectars
question.md <- stringr::str_replace_all(question.md, "\\\\\\\\", "\\\\")

# If two new lines starting with * are preceded and followed by a white line, than make it into a list
question.md[stringr::str_detect(question.md, "^\\*|$^")] = stringr::str_replace(question.md[stringr::str_detect(question.md, "^\\*|$^")], "(^\\*)", "* *")

# Remove temp files
file.remove(list.files(pattern = "temp"))

#### Create folder structure if needed

# extract first taxonomy level
taxonomyFirstNode <- stringr::str_split_1(exsection, "/")[1]
subdir = "SQRscripts/"
path = paste0(subdir, taxonomyFirstNode)

if ( !file.exists(path) ) {
  
  # Create directory
  dir.create(path)
  
}

# Create item folder
dir.create(paste0(path, "/", folder.name))

#### Save image file if item has image

query = "select a.item_id as item_id,
                b.name as name,
                b.data as data,
                b.mime_type as mime,
                b.data_length as dataLength
         from   items_item_files as a,
                item_files as b
         where  a.item_file_id = b.id
         and    a.item_id = %s"
query = sprintf(query, item.row)

# query = "show columns from item_files"

imageResult <- dbSendQuery(con, query)
imageResult <- dbFetch(imageResult)

dbClearResult(res)

# Set image to TRUE of FALSE based on the query result
image = !is.na(imageResult[1,1])

# If there is an image
if (image) {

  # Determine image file extention
  image.file.extention = stringr::str_split_1(string = imageResult$mime, pattern = "/")[2]
  
  # Set image file name
  image.file.name = paste0(exname,image.indication = "-graph01.",image.file.extention)
  
  # File save path name
  image.file.save = paste0(path, "/", folder.name, "/", image.file.name)
  
  imageHEX <- imageResult$data
  
  # Save blob as image file
  f = file ( image.file.save, "wb")
  writeBin(as.raw(unlist(imageHEX)), f) # Running one time produces blank images
  writeBin(as.raw(unlist(imageHEX)), f) # Second time produces correct result. No idea why!
  
  # Set include text
  image.include = '```{r, echo = FALSE, results = "hide"}
include_supplement("%s", recursive = TRUE)
```'
  
  # Check in final file if new lines are working
  image.include = sprintf(image.include, image.file.name)
  
  # Set markdown image include string
  image.md = "![](%s)"
  image.md = sprintf(image.md, image.file.name)

}

#### Start creating markdown file

sink(paste0(path,"/",folder.name,"/",file.name))
if(image) { cat(image.include) 
            cat("\n\n") }
cat("Question\n========\n\n")
cat(question.md, sep = "\n")
cat("\n\n")
if(image) { cat(image.md)
            cat("\n\n") }
if(item.type == "MultipleChoice") { cat("Answerlist\n----------\n\n")
                                    cat(answer.md, sep = "\n")
                                    cat("\n") }
cat("Solution\n========\n\n")
cat("Het correcte antwoord is: ")
if (item.type == "MultipleChoice") { cat("\n\n")
                                     cat(answer.md[as.numeric(item.answer)+1]) 
                                   } else { cat(exsolution) }
cat("\n\n")
cat("Meta-information\n================\n")
cat("exname: ") 
cat(exname)
cat("\n")
cat("extype: ") 
cat(extype)
cat("\n")
cat("exsolution: ") 
cat(exsolution)
cat("\n")
cat("exsection: ") 
cat(exsection)
cat("\n")
cat("exextra[Type]: ") 
cat(type)
cat("\n")
cat("exextra[IRT-Difficulty]: ") 
cat(item.beta)
cat("\n")
cat("exextra[p-value]: ") 
cat(1-item.difficultyPercentage)
cat("\n")
sink()

# Terminate database connection
dbDisconnect(con)
