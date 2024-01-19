# install.packages("rjson")
library("rjson")
library("dplyr")

source("SQRscripts/DBconnect.R")

dbListTables(con)

query = "select id, 
                question,
                answer_options,
                correct_answer,
                round(rating,2) as beta, 
                round(rating/max(rating),2) as difficultyPercentage
         from   items 
         limit  985, 1"

res <- dbSendQuery(con, query)
itemResrults <- dbFetch(res)

jsonItem <- fromJSON(itemResrults$question)

item.id       = itemResrults$id
item.type     = jsonItem$type
item.question = jsonItem$question$content[[1]]
item.answer   = itemResrults$correct_answer

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
if ( stringr::str_count("[bB]ereken", item.question) > 0 ) {
  
  type = append(type, "Calculation", length(type))
  
}

# Queried questions for use of the word spss, 
# all indicate output interpertation questions
if ( stringr::str_count("spss|SPSS", item.question) > 0 ) {
  
  type = append(type, "Interpreting output", length(type))
  
}

# combine multiple type tags
type = stringr::str_c(type, collapse = ", ")

#### Create variables only for MultipleChoice item types

if(item.type == "MultipleChoice") {
  
  item.answer.options = fromJSON(itemResrults$answer_options)
  # Create binary solution string
  # item.answer starts at 0, hense +1 for use in R
  exsolution = paste0(as.numeric(1:length(item.answer.options) == as.numeric(item.answer)+1), collapse = "" )
  
}


dbClearResult(res)

dbDisconnect(con)




# 'select JSON_EXTRACT(question, "$.question.content[0]") as question
#  from   items 
#  limit  5;'

# Check all item types

# 'select distinct JSON_EXTRACT(question, "$.type") as type  from   items;'

  # +------------------+
  # | type             |
  # +------------------+
  # | "MultipleChoice" |
  # | "OpenString"     |
  # +------------------+

# show columns from items;

  # +-----------------------------+---------------------+------+-----+---------+----------------+
  # | Field                       | Type                | Null | Key | Default | Extra          |
  # +-----------------------------+---------------------+------+-----+---------+----------------+
  # | id                          | int(10) unsigned    | NO   | PRI | NULL    | auto_increment |
  # | mirror_item_id              | int(10) unsigned    | NO   | MUL | NULL    |                |
  # | item_number                 | int(10) unsigned    | YES  |     | NULL    |                |
  # | item_answer_type_id         | int(10) unsigned    | YES  | MUL | NULL    |                |
  # | item_question_type_id       | int(10) unsigned    | YES  | MUL | NULL    |                |
  # | question                    | text                | NO   |     | NULL    |                |
  # | answer_options              | text                | YES  |     | NULL    |                |
  # | correct_answer              | text                | NO   |     | NULL    |                |
  # | maximum_response_in_seconds | int(10) unsigned    | NO   |     | NULL    |                |
  # | rating                      | double              | NO   |     | 0       |                |
  # | domain_id                   | int(10) unsigned    | NO   | MUL | NULL    |                |
  # | user_id                     | int(10) unsigned    | NO   | MUL | NULL    |                |
  # | predecessor_id              | int(10) unsigned    | YES  | MUL | NULL    |                |
  # | start_rating                | double              | NO   |     | 0       |                |
  # | modified_count              | int(10) unsigned    | NO   |     | 0       |                |
  # | version                     | int(10) unsigned    | NO   |     | 0       |                |
  # | status                      | tinyint(2) unsigned | NO   |     | 2       |                |
  # | modified                    | timestamp           | YES  | MUL | NULL    |                |
  # | rating_uncertainty          | double              | NO   |     | 0       |                |
  # | validator                   | varchar(255)        | YES  |     | NULL    |                |
  # | created                     | timestamp           | YES  |     | NULL    |                |
  # +-----------------------------+---------------------+------+-----+---------+----------------+