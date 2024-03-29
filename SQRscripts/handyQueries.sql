/* Handy queries to dig through the itembank

   Get the total taxonomy tree structure */

SELECT CONCAT( REPEAT( ' ', (COUNT(parent.name) - 1) ), node.name) AS name
FROM tags AS node,
tags AS parent
WHERE node.lft BETWEEN parent.lft AND parent.rght
GROUP BY node.name
ORDER BY node.lft;

/* Get only the taxonomy structure and ids for a specific category */

SELECT node.name, parent.id
FROM tags AS node,
tags AS parent
WHERE node.lft BETWEEN parent.lft AND parent.rght
AND parent.name = 'K/V/G classificatie'
ORDER BY node.lft;

/* search for specific text in question stem */

select JSON_EXTRACT(question, "$.question.content[0]") as question
from   items
where  question REGEXP '[[:<:]]download[[:>:]]';

/* look at question for specific item */

select JSON_EXTRACT(question, "$.question.content[0]") as question,
       answer_options,
       correct_answer
from   items
where  id = 82;

/* See all columns in item table */

show columns from items;

/* look at answers for closed and open questions */

select id,
       correct_answer,
       JSON_EXTRACT(question, "$.type") as type,
       status
from   items;

/* I'm seeing items that are MultipleChoice that have strings for correct answers 
   and not the requered numerical indicator for the correct answer option number
   for example item 82 */

select id,
       correct_answer,
       JSON_EXTRACT(question, "$.type") as type,
       status
from   items
where  CHAR_LENGTH(correct_answer) > 1
and    JSON_EXTRACT(question, "$.type") = 'MultipleChoice';



/* Take a look at the open questions */

select id,
       /* JSON_EXTRACT(question, "$.question.content[0]") as question, */
       correct_answer,
       JSON_EXTRACT(question, "$.type") as type
from   items
where  JSON_EXTRACT(question, "$.type") = 'OpenString';

/* look at question for specific item */

select JSON_EXTRACT(question, "$.question.content[0]") as question,
       answer_options,
       correct_answer
from   items
where  id = 82;

/* To Do replace , with . and fraction e.g. 3/4 with decimal value and % with decimal value in correct_answer */

select id,
       correct_answer,
       JSON_EXTRACT(question, "$.type") as type
from   items
where  JSON_EXTRACT(question, "$.type") = 'OpenString'
and    correct_answer REGEXP '\\%|,|\\/';

select id,
       JSON_EXTRACT(question, "$.question.content[0]") as question
from   items
where  JSON_EXTRACT(question, "$.question.content[0]") REGEXP 'table';

/* look at media types */

select JSON_EXTRACT(question, "$.question.mediaType") as mediaType
from   items;


select  item_file_source_id, 
        name,
from    item_files;

select item_id, 
       item_file_id 
from   items_item_files;

/* connect image file name to item id. */

select a.item_id as item_id,
       b.name as name,
       /* b.data as data, */
       b.mime_type as mime,
       b.data_length as dataLength
from   items_item_files as a,
       item_files as b
where  a.item_file_id = b.id
and    a.item_id = 8;

/* Determine percentile for specific item*/

select id, 
                round(rating,3) as beta,
                m.ranked / 1948 as difficultyPercentage
         from   items, ( select count(rating) as ranked 
                         from   items
                         where  rating <= (select rating from items where id = 1000) ) as m
         where  id = 1000;