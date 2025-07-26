create database Netflix;
use netflix;
-- 15 Business Problems & Solutions.

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);




SELECT * FROM netflix;
-- 1. Count the number of Movies vs TV Shows
select type, count(*) as number
from netflix 
group by 1;

-- 2. Find the most common rating for movies and TV shows

SELECT
    type,
    rating
FROM (
    SELECT
        type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranks
    FROM netflix
    GROUP BY type, rating
) AS rankings
WHERE ranks = 1;
 


-- 3. List all movies released in a specific year (e.g., 2020)
select * from netflix
where release_year = 2020 and type ="Movie";

-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
  country_name AS new_country,
  COUNT(n.show_id) AS total_content
FROM 
  netflix n,
  JSON_TABLE(
    CONCAT('["', REPLACE(n.country, ',', '","'), '"]'),
    '$[*]' COLUMNS (country_name VARCHAR(100) PATH '$')
  ) AS countries
WHERE country_name IS NOT NULL and country != ''
GROUP BY country_name
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT 
  type,title, duration,
  CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS duration_minutes
FROM 
	netflix
WHERE 
  type = 'Movie'
  AND duration LIKE '%min'
ORDER BY 
  duration_minutes DESC
LIMIT 5;

-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE date_added >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
order by date_added desc;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netflix
where director like '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons
SELECT 
  type,title, duration,
  CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS seasons
FROM 
	netflix
WHERE 
  type = 'TV Show'
  AND duration LIKE '%Season%'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5
ORDER BY 
  seasons DESC;
  
  
-- 9. Count the number of content items in each genre
SELECT genre, COUNT(*) AS total_content
FROM (
  SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1)) AS genre
  FROM netflix
  JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
  ) AS n
  ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= n.n - 1
) AS genre_split
GROUP BY genre
ORDER BY total_content DESC;

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
select country, release_year,COUNT(show_id) AS total_release,
 ROUND(
        COUNT(show_id) * 100.0 / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India'),
        1
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE  listed_in like '%documentaries%';


-- 12. Find all content without a director
SELECT * FROM netflix
WHERE  director is NUll or director ="";


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE 
    type = 'Movie'
    AND casts LIKE '%Salman Khan%'
    AND release_year >= YEAR(CURDATE()) - 10;
    
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
WITH RECURSIVE actor_split AS (
    SELECT 
        TRIM(SUBSTRING_INDEX(casts, ',', 1)) AS actor,
        TRIM(SUBSTRING(casts, LENGTH(SUBSTRING_INDEX(casts, ',', 1)) + 2)) AS rest
    FROM netflix
    WHERE country = 'India' AND casts IS NOT NULL

    UNION ALL

    SELECT 
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS actor,
        TRIM(SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2))
    FROM actor_split
    WHERE rest IS NOT NULL AND rest != ''
)
SELECT 
    actor,
    COUNT(*) AS appearances
FROM actor_split
WHERE actor IS NOT NULL AND actor != ''
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;



-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
