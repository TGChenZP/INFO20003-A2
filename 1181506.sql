-- __/\\\\\\\\\\\__/\\\\\_____/\\\__/\\\\\\\\\\\\\\\_____/\\\\\_________/\\\\\\\\\_________/\\\\\\\________/\\\\\\\________/\\\\\\\________/\\\\\\\\\\________________/\\\\\\\\\_______/\\\\\\\\\_____        
--  _\/////\\\///__\/\\\\\\___\/\\\_\/\\\///////////____/\\\///\\\_____/\\\///////\\\_____/\\\/////\\\____/\\\/////\\\____/\\\/////\\\____/\\\///////\\\_____________/\\\\\\\\\\\\\___/\\\///////\\\___       
--   _____\/\\\_____\/\\\/\\\__\/\\\_\/\\\_____________/\\\/__\///\\\__\///______\//\\\___/\\\____\//\\\__/\\\____\//\\\__/\\\____\//\\\__\///______/\\\_____________/\\\/////////\\\_\///______\//\\\__      
--    _____\/\\\_____\/\\\//\\\_\/\\\_\/\\\\\\\\\\\____/\\\______\//\\\___________/\\\/___\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\_________/\\\//_____________\/\\\_______\/\\\___________/\\\/___     
--     _____\/\\\_____\/\\\\//\\\\/\\\_\/\\\///////____\/\\\_______\/\\\________/\\\//_____\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\________\////\\\____________\/\\\\\\\\\\\\\\\________/\\\//_____    
--      _____\/\\\_____\/\\\_\//\\\/\\\_\/\\\___________\//\\\______/\\\______/\\\//________\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\___________\//\\\___________\/\\\/////////\\\_____/\\\//________   
--       _____\/\\\_____\/\\\__\//\\\\\\_\/\\\____________\///\\\__/\\\______/\\\/___________\//\\\____/\\\__\//\\\____/\\\__\//\\\____/\\\___/\\\______/\\\____________\/\\\_______\/\\\___/\\\/___________  
--        __/\\\\\\\\\\\_\/\\\___\//\\\\\_\/\\\______________\///\\\\\/______/\\\\\\\\\\\\\\\__\///\\\\\\\/____\///\\\\\\\/____\///\\\\\\\/___\///\\\\\\\\\/_____________\/\\\_______\/\\\__/\\\\\\\\\\\\\\\_ 
--         _\///////////__\///_____\/////__\///_________________\/////_______\///////////////_____\///////________\///////________\///////_______\/////////_______________\///________\///__\///////////////__

-- Your Name: Lang (Ron) Chen
-- Your Student Number: 1181506
-- By submitting, you declare that this work was completed entirely by yourself.

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1

SELECT DISTINCT s.first_name AS 'first name', s.last_name AS 'last name' 
FROM role AS r INNER JOIN profile AS p ON r.id = p.role_id INNER JOIN staff AS s ON p.staff_id = s.id 
WHERE r.role_name = 'team Lead';

-- END Q1
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2

SELECT DISTINCT s.last_name AS 'last name', s.first_name AS 'first name', t.team_name AS 'team name' 
FROM staff AS s INNER JOIN profile AS p ON s.id = p.staff_id INNER JOIN team AS t ON p.team_id = t.id inner join team AS pt ON pt.id = t.parent_id
WHERE pt.team_name = 'Victoria'
ORDER BY s.last_name ASC;

-- Comment: Chose to use DISTINCT for neatness - ED forum said will accept both

-- END Q2
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3

SELECT DISTINCT s.first_name AS 'first name', s.last_name AS 'last name' 
FROM staff AS s INNER JOIN profile AS p ON s.id = p.staff_id INNER JOIN team AS t ON p.team_id = t.id 
WHERE t.team_name = 'Errinundra' AND p.profile_ref NOT IN
(SELECT profile_ref FROM profile AS p
WHERE DATE(p.valid_until) <= '2021-04-13' OR DATE(p.valid_from) >= '2021-05-13'); 

-- END Q3
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q4

SELECT s.first_name AS 'first name', s.last_name AS 'last name'
FROM staff AS s INNER JOIN profile AS p ON s.id = p.staff_id INNER JOIN role AS r ON r.id = p.role_id INNER JOIN team AS t ON p.team_id = t.id 
WHERE r.role_name = 'agent' AND s.id IN
(SELECT s.id 
FROM profile AS p INNER JOIN team as t ON t.id = p.team_id INNER JOIN staff AS s ON s.id = p.staff_id 
WHERE (DATE('2021-05-23') BETWEEN DATE(p.valid_from) AND DATE(p.valid_until)) GROUP BY s.id HAVING COUNT(t.id) = 1)
AND s.id IN 
(SELECT s.id 
FROM profile AS p INNER JOIN team as t ON t.id = p.team_id INNER JOIN staff AS s ON s.id = p.staff_id 
WHERE (DATE('2021-05-23') BETWEEN DATE(p.valid_from) AND DATE(p.valid_until)) AND t.team_name = 'Werrikimbe');

-- END Q4
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q5

SELECT t.team_name AS 'team name', MONTH(sr.response_time) AS 'month', AVG(sr.agent_quality) AS 'averageAQ'
FROM profile AS p INNER JOIN team AS t on t.id = p.team_id INNER JOIN survey_response AS sr ON p.profile_ref = sr.profile_ref 
GROUP BY t.team_name, MONTH(sr.response_time) 
ORDER BY averageAQ DESC;

-- END Q5
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q6

SELECT MONTH(sr.response_time) AS 'month', ROUND(100*SUM(CASE WHEN sr.promoter_score >= 9 THEN 1 ELSE 0 END)/COUNT(*) - 100*SUM(CASE WHEN sr.promoter_score <= 6 THEN 1 ELSE 0 END)/COUNT(*)) AS 'NPS'
FROM survey_response AS sr
WHERE sr.promoter_score IS NOT NULL
GROUP BY MONTH(sr.response_time)
ORDER BY month;

-- END Q6
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q7

SELECT 100*SUM(CASE WHEN sr.first_call_resolution IS NOT NULL THEN 1 ELSE 0 END)/COUNT(*) AS 'Tatjana\'s enhanced participation'
FROM staff AS s INNER JOIN profile AS p ON s.id = p.staff_id INNER JOIN call_record AS cr ON cr.profile_ref = p.profile_ref 
LEFT JOIN survey_response AS sr ON sr.id = cr.survey_response_id
WHERE MONTH(cr.call_time) = 6 AND YEAR(cr.call_time) = '2021' AND s.first_name = 'Tatjana' AND s.last_name = 'Pryor';

-- END Q7
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q8

SELECT s.first_name as 'first name', s.last_name as 'last name', SUM(CASE WHEN sr.first_call_resolution = '2' THEN 1 ELSE 0 END) AS 'FCR count'
FROM staff AS s INNER JOIN profile AS p ON p.staff_id = s.id INNER JOIN survey_response AS sr ON p.profile_ref = sr.profile_ref
WHERE DATE('2021-06-01') <= DATE(sr.response_time) AND DATE('2021-06-17') >= DATE(sr.response_time)
GROUP BY s.id
HAVING SUM(CASE WHEN sr.first_call_resolution = '2' THEN 1 ELSE 0 END) = 
(SELECT SUM(CASE WHEN sr.first_call_resolution = '2' THEN 1 ELSE 0 END) AS 'min FCR count' 
FROM staff AS s INNER JOIN profile AS p ON p.staff_id = s.id INNER JOIN survey_response AS sr ON p.profile_ref = sr.profile_ref
WHERE DATE('2021-06-01') <= DATE(sr.response_time) AND DATE('2021-06-17') >= DATE(sr.response_time) AND sr.first_call_resolution = 2
GROUP BY s.id
ORDER BY SUM(CASE WHEN sr.first_call_resolution = '2' THEN 1 ELSE 0 END) LIMIT 1);

-- END Q8
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q9

SELECT * FROM 
((SELECT AVG(sr.agent_quality) AS 'average AQ when a team leader was involved'
FROM profile AS p INNER JOIN call_record AS cr ON p.profile_ref = cr.profile_ref INNER JOIN survey_response AS sr ON cr.survey_response_id = sr.id INNER JOIN role AS r ON r.id = p.role_id 
WHERE cr.call_ref IN
(SELECT cr.call_ref FROM call_record AS cr INNER JOIN profile AS p ON cr.profile_ref= p.profile_ref INNER JOIN role AS r ON r.id = p.role_id
WHERE r.role_name = 'team Lead' AND cr.call_leg > 1)) t1, 
(SELECT AVG(sr.agent_quality) AS 'overall average AQ'
FROM profile AS p INNER JOIN call_record AS cr ON p.profile_ref = cr.profile_ref INNER JOIN survey_response AS sr ON cr.survey_response_id = sr.id INNER JOIN role AS r ON r.id = p.role_id
WHERE sr.agent_quality IS NOT NULL) t2);

-- END Q9
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q10

SELECT s.first_name AS 'staff first name', s.last_name AS 'staff last name'
FROM staff AS s INNER JOIN profile AS p ON s.id = p.staff_id INNER JOIN team AS t ON t.id = p.team_id
WHERE s.id IN 
(SELECT s.id 
FROM staff AS s INNER JOIN profile AS p ON s.id = p.staff_id INNER JOIN team AS t ON t.id = p.team_id 
GROUP BY s.id HAVING COUNT(DISTINCT p.team_id) = 
(SELECT COUNT(DISTINCT id) - (SELECT COUNT(DISTINCT t.id) FROM 
staff AS s INNER JOIN profile AS p ON s.id = p.staff_id INNER JOIN team AS t ON t.id = p.team_id
WHERE s.id = '2') FROM team AS t WHERE has_staff = '1'))
AND t.id NOT IN
(SELECT t.id from staff AS s INNER JOIN profile AS p ON s.id = p.staff_id INNER JOIN team AS t ON t.id = p.team_id
WHERE s.id = '2');

-- END Q10
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- END OF ASSIGNMENT Do not write below this line