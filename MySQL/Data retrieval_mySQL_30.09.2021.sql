-- Creating table with required information 

USE statistiekfabriek_com_app; -- select database 

CREATE TABLE basic_info_1 (
SELECT items.id, items.question, -- referring to transaltion table 
	group_concat(tags.name) as alltags
FROM items_tags, items, tags
WHERE items.id = items_tags.item_id 
AND items_tags.tag_id = tags.id
AND  tags.id < 151 -- selecting only relevent tag.id (below 151) 
GROUP BY  items_tags.item_id);

CREATE TABLE basic_info_2 ( 
SELECT items.id, items.question, items.answer_options, items.correct_answer , item_files.data, item_files.name, items_item_files.item_file_id
FROM items
LEFT JOIN items_item_files
ON items.id  = items_item_files.item_id
LEFT JOIN item_files 
ON item_files.id = items_item_files.item_file_id); 

CREATE TABLE basic_info_complete_4r (
SELECT basic_info_1.id, basic_info_1.question, basic_info_2.answer_options, basic_info_2.correct_answer, basic_info_1.alltags, basic_info_2.data, basic_info_2.name, basic_info_2.item_file_id 
FROM basic_info_1
LEFT JOIN basic_info_2
ON basic_info_1.id = basic_info_2.id);

-- Splitting retrieved data set into OpenString and MultipleChoice questions
-- MultipleChoice question

SELECT id, question, answer_options, correct_answer, alltags -- select all relevant columns
FROM statistiekfabriek_com_app.basic_info_complete_4r -- referring to previously created table containing all information 
WHERE question LIKE '%MultipleChoice%'; -- filtering all questions containing "MutlipleChoice" in the column "question"

-- OpenString questoin (same procedure as for MultipleChoice question) 
SELECT *
FROM statistiekfabriek_com_app.basic_info_complete_4r
WHERE question LIKE '%OpenString%';

-- Additional infomration 

-- The data was exported as JSON file via the quick export tool after running the query 
-- The image data (BLOB) was sperately downloaded and saved