// I'm seeing items that are MultipleChoice that have strings for correct answers 
// and not the requered numerical indicator for the correct answer option number
// for example item 82

select id,
       correct_answer,
       JSON_EXTRACT(question, "$.type") as type,
       status
from   items
where  CHAR_LENGTH(correct_answer) > 1
and    JSON_EXTRACT(question, "$.type") = 'MultipleChoice';

// search for item

select JSON_EXTRACT(question, "$.question.content[0]") as question,
       answer_options,
       correct_answer
from   items
where  id = 1700;

// correct item, list number starts at 0
// the items below had the correct answer from the list as literal string.
// corrected by assigning the correct nr for the correct answer option

UPDATE items SET correct_answer = 2 WHERE id = 82;
UPDATE items SET correct_answer = 2 WHERE id = 150;
UPDATE items SET correct_answer = 0 WHERE id = 153;
UPDATE items SET correct_answer = 1 WHERE id = 172;
UPDATE items SET correct_answer = 0 WHERE id = 916;
UPDATE items SET correct_answer = 3 WHERE id = 996;
UPDATE items SET correct_answer = 0 WHERE id = 1313;
UPDATE items SET correct_answer = 4 WHERE id = 1352;

// All left over items are also literal strings but contain the integer number
// of the float answer option.

select id,
       answer_options,
       correct_answer,
       JSON_EXTRACT(question, "$.type") as type
from   items
where  CHAR_LENGTH(correct_answer) > 1
and    JSON_EXTRACT(question, "$.type") = 'MultipleChoice';

// correct in one go

UPDATE items SET correct_answer = 1 WHERE id = 1700;
UPDATE items SET correct_answer = 0 WHERE id = 1702;
UPDATE items SET correct_answer = 2 WHERE id = 1720;
UPDATE items SET correct_answer = 1 WHERE id = 1735;
UPDATE items SET correct_answer = 1 WHERE id = 1742;
UPDATE items SET correct_answer = 1 WHERE id = 1744;
UPDATE items SET correct_answer = 1 WHERE id = 1745;
UPDATE items SET correct_answer = 1 WHERE id = 1750;
UPDATE items SET correct_answer = 1 WHERE id = 1751;
UPDATE items SET correct_answer = 1 WHERE id = 1752;
UPDATE items SET correct_answer = 2 WHERE id = 1753;
UPDATE items SET correct_answer = 0 WHERE id = 1754;
UPDATE items SET correct_answer = 1 WHERE id = 1755;
UPDATE items SET correct_answer = 2 WHERE id = 1756;
UPDATE items SET correct_answer = 2 WHERE id = 1757;
UPDATE items SET correct_answer = 2 WHERE id = 1758;
UPDATE items SET correct_answer = 0 WHERE id = 1759;
UPDATE items SET correct_answer = 1 WHERE id = 1760;
UPDATE items SET correct_answer = 0 WHERE id = 1762;
UPDATE items SET correct_answer = 3 WHERE id = 1764;
UPDATE items SET correct_answer = 1 WHERE id = 1765;
UPDATE items SET correct_answer = 1 WHERE id = 1767;
UPDATE items SET correct_answer = 1 WHERE id = 1768;
UPDATE items SET correct_answer = 1 WHERE id = 1769;
UPDATE items SET correct_answer = 2 WHERE id = 1770;
UPDATE items SET correct_answer = 2 WHERE id = 1771;
UPDATE items SET correct_answer = 1 WHERE id = 1772;
UPDATE items SET correct_answer = 1 WHERE id = 1773;
UPDATE items SET correct_answer = 1 WHERE id = 1774;
UPDATE items SET correct_answer = 3 WHERE id = 1775;
UPDATE items SET correct_answer = 1 WHERE id = 1776;
UPDATE items SET correct_answer = 1 WHERE id = 1777;
UPDATE items SET correct_answer = 1 WHERE id = 1778;
UPDATE items SET correct_answer = 3 WHERE id = 1779;
UPDATE items SET correct_answer = 3 WHERE id = 1780;
UPDATE items SET correct_answer = 0 WHERE id = 1781;
UPDATE items SET correct_answer = 2 WHERE id = 1782;
UPDATE items SET correct_answer = 1 WHERE id = 1783;
UPDATE items SET correct_answer = 3 WHERE id = 1784;
UPDATE items SET correct_answer = 2 WHERE id = 1785;
UPDATE items SET correct_answer = 1 WHERE id = 1786;
UPDATE items SET correct_answer = 2 WHERE id = 1787;
UPDATE items SET correct_answer = 1 WHERE id = 1788;
UPDATE items SET correct_answer = 0 WHERE id = 1789;
UPDATE items SET correct_answer = 1 WHERE id = 1790;
UPDATE items SET correct_answer = 1 WHERE id = 1791;
UPDATE items SET correct_answer = 0 WHERE id = 1792;
UPDATE items SET correct_answer = 1 WHERE id = 1793;
UPDATE items SET correct_answer = 2 WHERE id = 1794;
UPDATE items SET correct_answer = 0 WHERE id = 1795;
UPDATE items SET correct_answer = 0 WHERE id = 1797;
UPDATE items SET correct_answer = 1 WHERE id = 1799;

// Checked, no more MultipleChoice items with incorrect answer