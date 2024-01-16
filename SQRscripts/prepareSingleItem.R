# install.packages("rjson")
library("rjson")

source("SQRscripts/DBconnect.R")

dbListTables(con)

query = "select id, 
                question,
                answer_options,
                correct_answer
         from   items 
         limit  1"

res <- dbSendQuery(con, query)
itemResrults <- dbFetch(res)

jsonItem <- fromJSON(itemResrults$question)

item.id       = itemResrults$id
item.type     = jsonItem$type
item.question = jsonItem$question$content[[1]]
item.answer   = itemResrults$correct_answer

exname.university = "uva-"
exname.taxonomy   = ""
exname.number     = item.id
exname.langguage  = "-nl"
exname.suffix     = ".Rmd"

exname = paste0(exname.university,
                exname.taxonomy,  
                exname.number,    
                exname.langguage, 
                exname.suffix   )

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