DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
select * from netflix;
--Q1.1. Count the Number of Movies AND TV Shows
select type,count(type) 
from netflix
group by type

--Q2.Find the most common rating for movies and TV shows 
select type,rating 
from
(select type,rating,count(*) as highcount,
RANK() OVER (partition by type order by count(*) desc) as ranking
from netflix
group by 1,2)
as t1
where ranking =1

--Q3.List all movies released in a specific year eg:2020
select type,title,release_year 
from netflix
where type='Movie' and release_year=2020

--Q4.Find the top 5 countries with the most content on netflix
select* 
from 
(select unnest(string_to_array(country,','))as country,count(*) as total
from netflix
group by country) as t1
where country is not null
order by total desc
limit 5;

--Q5.Identify the Longest Movie
select title,duration
from
(SELECT 
   title,duration
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC) as t1
where duration is not null;

--Q6. Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--Q7.Find all the movies/tv shows by director 'Rajiv Chilaka'
select * from 
(select type,title,unnest(string_to_array(director,',')) as name
from netflix) 
as t1 
where name='Rajiv Chilaka'; 

--Q8.List all the TV shows with more than 5 SEASONS 
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;	

--Q9.Count the number of Content Items in Each genre
select unnest(string_to_array(listed_in,',')) as genre,
count(*) as total_content
from netflix
group by 1

--Q10.Find each year and the average number of contents released in India on netflix
--year,india
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

--Q11.List all the movies that are documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

--Q12. Find All Content Without a Director
select * from netflix where director is null
--Q13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%' and release_year > extract (year from current_date) - 10 
--Q14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
select unnest(string_to_array(casts,',')) as actors,count(*) as totalcount
from netflix
where country='India'
group by actors
order by count(*) desc
limit 10;
--Q15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
select category,count(*) as content_count from
(SELECT
	CASE
		WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'bad'
		ELSE 'good'
	END AS category
FROM netflix)as categorized_content
group by category;
