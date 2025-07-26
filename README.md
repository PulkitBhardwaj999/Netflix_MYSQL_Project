# Netflix_MYSQL_Project

# Netflix Movies and TV Shows Data Analysis using SQL
<img width="2226" height="678" alt="image" src="https://github.com/user-attachments/assets/9e0c7ab1-0e18-460f-8720-67eb1888c402" />

This project aims to provide a comprehensive SQL-based analysis of Netflix's catalog of movies and TV shows. Using structured queries, we address a series of business problems, extract valuable insights, and present key findings that can inform content strategy and decision-making.

---

## Objectives

- Analyze the distribution of content types (Movies vs TV Shows)
- Identify the most common content ratings
- List and explore content by release years, countries, and durations
- Categorize content using specific criteria and keywords

---

## Dataset

- **Source:** Kaggle Netflix Movies and TV Shows Dataset ([Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download))
- **Schema:**
show_id VARCHAR(5)
type VARCHAR(10)
title VARCHAR(250)
director VARCHAR(550)
casts VARCHAR(1050)
country VARCHAR(550)
date_added VARCHAR(55)
release_year INT
rating VARCHAR(15)
duration VARCHAR(15)
listed_in VARCHAR(250)
description VARCHAR(550)


---

## Business Problems and SQL Solution Queries

### 1. Number of Movies vs TV Shows

SELECT type, COUNT(*) AS number
FROM netflix
GROUP BY type;

_Objective: Distribution of content types._

---

### 2. Most Common Rating for Movies and TV Shows

SELECT type, rating
FROM (
SELECT type, rating, COUNT() AS rating_count,
RANK() OVER (PARTITION BY type ORDER BY COUNT() DESC) AS ranks
FROM netflix
GROUP BY type, rating
) AS rankings
WHERE ranks = 1;

_Objective: Most frequent rating per content type._

---

### 3. List All Movies Released in a Specific Year (e.g., 2020)

SELECT *
FROM netflix
WHERE release_year = 2020 AND type = 'Movie';

_Objective: Movies released in a certain year._

---

### 4. Top 5 Countries with Most Content

SELECT
country_name AS country,
COUNT(n.show_id) AS total_content
FROM
netflix n,
JSON_TABLE(
CONCAT('["', REPLACE(n.country, ',', '","'), '"]'),
'$[*]' COLUMNS (country_name VARCHAR(100) PATH '$')
) AS countries
WHERE country_name IS NOT NULL AND country != ''
GROUP BY country_name
ORDER BY total_content DESC
LIMIT 5;

_Objective: Countries with the largest number of Netflix entries._

---

### 5. Identify the Longest Movie

SELECT type, title, duration,
CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS duration_minutes
FROM netflix
WHERE type = 'Movie'
AND duration LIKE '%min'
ORDER BY duration_minutes DESC
LIMIT 5;

_Objective: Movie(s) with the longest duration._

---

### 6. Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE date_added >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
ORDER BY date_added DESC;

_Objective: Recent additions to Netflix._

---

### 7. Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

_Objective: Works directed by Rajiv Chilaka._

---

### 8. TV Shows with More Than 5 Seasons

SELECT type, title, duration,
CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS seasons
FROM netflix
WHERE type = 'TV Show'
AND duration LIKE '%Season%'
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5
ORDER BY seasons DESC;

_Objective: TV shows with high season counts._

---

### 9. Count of Content in Each Genre

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

_Objective: Genre-level content counts._

---

### 10. Average Content Release Yearly in India (Top 5 Years)
SELECT country, release_year, COUNT(show_id) AS total_release,
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


_Objective: Busiest years for Indian content._

---

### 11. Movies That Are Documentaries
SELECT *
FROM netflix
WHERE listed_in LIKE '%documentaries%';


_Objective: List all documentary movies._

---

### 12. Content Without a Director

SELECT *
FROM netflix
WHERE director IS NULL OR director = '';

_Objective: Content entries missing directorial assignment._

---

### 13. Movies with Salman Khan in the Last 10 Years
SELECT *
FROM netflix
WHERE
type = 'Movie' AND
casts LIKE '%Salman Khan%' AND
release_year >= YEAR(CURDATE()) - 10;
_Objective: Salman Khan's recent movies._

---


### 14. Top 10 Actors in Indian Movies

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

_Objective: Most frequent actors in Indian productions._

---

### 15. Categorize Content Based on 'Kill' and 'Violence'

SELECT category, COUNT(*) AS content_count
FROM (
SELECT
CASE
WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
ELSE 'Good'
END AS category
FROM netflix
) AS categorized_content
GROUP BY category;

_Objective: Content flagged as "Bad" or "Good" by keywords in descriptions._

---

## Key Findings & Conclusion

- **Content Distribution:** Balanced ranges of movies and TV shows, spanning diverse genres and ratings.
- **Regional Insights:** Top contributing countries and content years for India reveal key markets and trends.
- **Quality Measures:** Most common ratings, longest movies, and frequent actors help profile major content clusters.
- **Content Categorization:** Keyword analysis allows classification for parental guidance and content policies.

---

## Author
Pulkit Bhardwaj





