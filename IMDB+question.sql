USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT 
      table_name, 
      table_rows AS total_number_of_rows
FROM 
      INFORMATION_SCHEMA.TABLES
WHERE 
      TABLE_SCHEMA = 'imdb';



-- Q2. Which columns in the movie table have null values?
-- Type your code below:

WITH movie_nulls as
(
SElECT 
      CASE WHEN title IS NULL THEN 1 ELSE 0 END as title_null_count,
      CASE WHEN year IS NULL THEN 1 ELSE 0 END as year_null_count,
      CASE WHEN date_published IS NULL THEN 1 ELSE 0 END as date_published_null_count,
      CASE WHEN duration IS NULL THEN 1 ELSE 0 END as duration_null_count,
      CASE WHEN country IS NULL THEN 1 ELSE 0 END as country_null_count,
      CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END as worldwide_gross_income_null_count,
      CASE WHEN languages IS NULL THEN 1 ELSE 0 END as languages_null_count,
      CASE WHEN production_company IS NULL THEN 1 ELSE 0 END as production_company_null_count
FROM
    movie      
)
SELECT 
      SUM(title_null_count) AS title,
      SUM(year_null_count) AS year,
      SUM(date_published_null_count) AS date_published,
      SUM(duration_null_count) AS duration,
      SUM(country_null_count) AS country,
      SUM(worldwide_gross_income_null_count) AS worldwide_gross_income,
      SUM(languages_null_count) AS languages,
      SUM(production_company_null_count) AS production_company
FROM 
    movie_nulls;     
    
    /* 
    1. We donot have any nulls in title,year,date_published,duration
    2. We have 20 nulls in country, 3724 nulls in worldwide_gross_income,194 in languages and 528 in production company 
    */
      

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Getting number of movies by year
SELECT
      year AS Year,
      COUNT(id) AS number_of_movies
FROM
	  movie
GROUP BY year;   

-- Getting number of movies by month by extracting month number from date_published column 
SELECT
      MONTH(date_published) AS month_num,
      COUNT(id) AS number_of_movies
FROM
	  movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published);      

/*    Insights:     
1. Highest number of movies were released in the year 2017 and lowest in 2019.
2. Highest number of movies were released in the month of March across all years and lowest being in December.
3. Movie count is on the higher side in Jan,Mar,Sep and Oct months and lowest in Jul and Dec months
*/




/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

-- Query to select number of movies where countries India and USA are involved in production.
-- To ensure no data loss due to case sensitivity, country has been converted to UPPER case in the query.
SELECT 
      CASE WHEN UPPER(country) LIKE '%INDIA%' THEN 'India'
		   WHEN UPPER(country) LIKE '%USA%' THEN 'USA'
	  END AS Country,
      count(id) AS number_of_movies
FROM   
      movie
WHERE
      year= '2019'
AND   (UPPER(country) LIKE '%INDIA%' OR UPPER(country) LIKE '%USA%')
GROUP BY (CASE WHEN UPPER(country) LIKE '%INDIA%' THEN 'India'
		       WHEN UPPER(country) LIKE '%USA%' THEN 'USA'
	      END);      

/*
 1. India has produced 309 movies in the year 2019
 2. USA has produced 750
 3. Together both the countries have produced 1059 movies.
*/


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT
      DISTINCT genre AS Genre
FROM  
     genre
ORDER BY genre;     


/*
  RVSP movies have produced movies across 13 types of genre
*/  



/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT
	 g.genre AS Genre,
     COUNT(m.id) AS number_of_movies
FROM 
     genre g
     INNER JOIN movie m
     ON g.movie_id=m.id
GROUP BY g.genre
ORDER BY COUNT(m.id) DESC;     

/* Insight:
      Highest number of movies produce3d belonged to genre 'Drama'
*/  


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH genre_count AS
(
SELECT
     movie_id,
     COUNT(genre) AS number_of_genre
FROM
     genre
GROUP BY movie_id
HAVING COUNT(genre)=1     
)
SELECT COUNT(movie_id) AS no_of_movies_one_genre
FROM 
      genre_count;      
      
/* Insight:
  3289 movies are having only one Genre
*/  


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


SELECT
      g.genre,
      ROUND(AVG(duration),2) AS avg_duration
FROM
    genre g
    INNER JOIN movie m
    ON g.movie_id=m.id
GROUP BY g.genre;
        



/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

-- Count the number of movies group by genre
-- RANK the movie count with genre having hightest movies ranked as 1
SELECT
      g.genre,
      COUNT(g.movie_id) AS movie_count,
      RANK() OVER (ORDER BY COUNT(g.movie_id) DESC) As genre_rank
FROM
    genre g
GROUP BY g.genre;    
    
/* Insight:
      Thriller movies are ranked 3 among the number of movies produced across years
*/      




/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

-- Using Aggregate functions MIN and MAX to solve the query

SELECT
      MIN(avg_rating) AS min_avg_rating,
      MAX(avg_rating) AS max_avg_rating,
      MIN(total_votes) AS min_total_votes,
      MAX(total_votes) AS max_total_votes,
      MIN(median_rating) AS min_median_rating,
      MAX(median_rating) AS max_median_rating
FROM
    ratings;

    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

SELECT
     m.title,
     r.avg_rating,
     DENSE_RANK() OVER (ORDER BY r.avg_rating DESC) as movie_rank
FROM
    movie m
    INNER JOIN ratings r
    ON m.id=r.movie_id;




/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT 
      median_rating,
      COUNT(movie_id) AS movie_count
FROM 
   ratings 
GROUP BY median_rating
ORDER BY COUNT(movie_id) desc;   
   


/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

WITH production_company_rating AS
(
SELECT 
     m.production_company,
     r.avg_rating,
     COUNT(id) AS movie_count
FROM 
    movie m
    INNER JOIN ratings r
    ON m.id=r.movie_id
WHERE m.production_company IS NOT NULL    
GROUP BY m.production_company, r.avg_rating
HAVING r.avg_rating>8
)
SELECT
     production_company,
     SUM(movie_count) as movie_count,
     DENSE_RANK() OVER(ORDER BY SUM(movie_count) DESC) AS prod_company_rank
FROM     
    production_company_rating
GROUP BY production_company;    



-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT
     g.genre,
     COUNT(g.movie_id) AS movie_count
FROM
   genre g
   INNER JOIN movie m 
   ON g.movie_id=m.id
   INNER JOIN ratings r
   ON g.movie_id=r.movie_id
WHERE 
    m.year='2017'
AND MONTH(m.date_published)=3
AND UPPER(m.country) LIKE '%USA%'
AND r.total_votes>1000
GROUP BY g.genre
ORDER BY COUNT(g.movie_id) DESC;



-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:


SELECT
     m.title,
     r.avg_rating,
     g.genre
FROM
   genre g
   INNER JOIN movie m 
   ON g.movie_id=m.id
   INNER JOIN ratings r
   ON g.movie_id=r.movie_id
WHERE
   m.title like 'The%'
HAVING avg_rating >8  
ORDER BY avg_rating DESC;






-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT
	  r.median_rating,
      COUNT(m.id) as movie_count
FROM 
    movie m
    INNER JOIN ratings r
    ON m.id=r.movie_id
WHERE 
    m.date_published between '2018-04-01' and '2019-04-01'
AND r.median_rating=8
GROUP BY r.median_rating; 


-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

WITH German_Italian AS
(
SELECT 
      SUM(CASE WHEN A.country='Germany' THEN A.total_votes 
               ELSE 0 
		  END) AS German_movie_votes,
      SUM(CASE WHEN A.country='Italy' THEN A.total_votes 
               ELSE 0 
		  END) AS Italian_movie_votes
FROM          
(
SELECT
      CASE WHEN UPPER(m.country) LIKE '%GERMANY%' THEN 'Germany'
           WHEN UPPER(m.country) LIKE '%ITALY%' THEN 'Italy'
      END AS country,
      SUM(r.total_votes) AS total_votes
FROM 
    movie m
    INNER JOIN ratings r
    ON m.id=r.movie_id
WHERE
     (UPPER(m.country) LIKE '%GERMANY%' OR UPPER(m.country) like '%ITALY%')
GROUP BY m.country) A
)
SELECT
      CASE WHEN German_movie_votes > Italian_movie_votes THEN 'Yes'
           ELSE 'No'
      END AS 'German_>_Italian'
FROM
    German_Italian      


-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

WITH name_nulls as
(
SElECT 
      CASE WHEN name IS NULL THEN 1 ELSE 0 END as name_null_count,
      CASE WHEN height IS NULL THEN 1 ELSE 0 END as height_null_count,
      CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END as date_of_birth_null_count,
      CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END as known_for_movies_null_count
FROM
    names     
)
SELECT 
      SUM(name_null_count) AS name_nulls,
      SUM(height_null_count) AS height_nulls,
      SUM(date_of_birth_null_count) AS date_of_birth_nulls,
      SUM(known_for_movies_null_count) AS known_for_movies_nulls
FROM 
    name_nulls;     
    

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


WITH genre_rank AS
(
SELECT
      g.genre,
      COUNT(g.movie_id) AS movie_count,
      RANK() OVER(ORDER BY COUNT(g.movie_id) DESC) AS genre_rank
FROM 
    genre g
    INNER JOIN ratings r
    ON g.movie_id=r.movie_id
WHERE r.avg_rating>8
GROUP BY g.genre    
),
director_hits_count AS
(
SELECT
      g.genre,
      n.name,
      COUNT(g.movie_id) AS movie_count
FROM 
    genre g
    INNER JOIN ratings r
    ON g.movie_id=r.movie_id
    INNER JOIN director_mapping d
    ON g.movie_id=d.movie_id
    INNER JOIN names n
    ON d.name_id=n.id
WHERE r.avg_rating>8
GROUP BY g.genre,n.name
)
SELECT 
     a.director_name,
     a.movie_count
FROM(     
SELECT
     dc.name AS director_name,
     SUM(dc.movie_count) AS movie_count,
     RANK() OVER(ORDER BY SUM(dc.movie_count) DESC) AS rnk
FROM
   genre_rank gr
   INNER JOIN director_hits_count dc
   ON gr.genre=dc.genre
WHERE gr.genre_rank <=3
GROUP BY dc.name) A
WHERE A.rnk<=3;

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH actor_hits AS
(
SELECT
     nm.name,
     COUNT(rt.movie_id) AS movie_count,
     RANK() OVER(ORDER BY COUNT(rt.movie_id) DESC) AS rnk
FROM
	names nm
    INNER JOIN role_mapping rm
    ON nm.id=rm.name_id
    AND rm.category='actor'
    INNER JOIN ratings rt
    ON rm.movie_id=rt.movie_id
WHERE rt.median_rating>=8
GROUP BY nm.name    
)
SELECT 
     name,
     movie_count
FROM 
    actor_hits
WHERE 
     rnk<3;    


/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH top_production_company AS
(
SELECT
     m.production_company,
     SUM(r.total_votes) as vote_count,
     RANK() OVER(ORDER BY SUM(r.total_votes) DESC) as rnk
FROM
    movie m
    INNER JOIN 
    ratings r
ON  m.id=r.movie_id
GROUP BY m.production_company
)
SELECT   
     production_company,
     vote_count,
     rnk AS prod_comp_rank
FROM 
    top_production_company
WHERE
    rnk<=3;


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


   
WITH actor_avg_rating AS
(
SELECT
     n.name AS actor_name,
     r.total_votes AS total_votes,
     (r.avg_rating) * (r.total_votes) AS total_votes_rating,
     COUNT(r.movie_id) AS movie_count
FROM 
    names n
    INNER JOIN 
    role_mapping rm
ON  n.id=rm.name_id
AND rm.category='actor'
    INNER JOIN
    ratings r
ON  rm.movie_id=r.movie_id  
    INNER JOIN
    movie m
ON  rm.movie_id=m.id
WHERE m.country like '%India%'  
GROUP BY n.name,r.total_votes,r.avg_rating
)
SELECT
     actor_name,
     SUM(total_votes) AS total_votes,
	 SUM(movie_count)  AS movie_count,
     ROUND(SUM(total_votes_rating) /SUM(total_votes) ,2) AS actor_avg_rating,
     DENSE_RANK() OVER(ORDER BY (SUM(total_votes_rating) /SUM(total_votes)) DESC,SUM(total_votes) DESC ) AS actor_rank
FROM
    actor_avg_rating
GROUP BY     
	actor_name
HAVING SUM(movie_count)>=5;



-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT
     A.*
FROM     
(WITH actress_avg_rating AS
(
SELECT
     n.name AS actress_name,
     r.total_votes AS total_votes,
     (r.avg_rating) * (r.total_votes) AS total_votes_rating,
     COUNT(r.movie_id) AS movie_count
FROM 
    names n
    INNER JOIN 
    role_mapping rm
ON  n.id=rm.name_id
AND rm.category='actress'
    INNER JOIN
    ratings r
ON  rm.movie_id=r.movie_id  
    INNER JOIN
    movie m
ON  rm.movie_id=m.id
WHERE m.country like '%India%'  
AND m.languages like'%Hindi%'
GROUP BY n.name,r.total_votes,r.avg_rating
)
SELECT
     actress_name,
     SUM(total_votes) AS total_votes,
	 SUM(movie_count)  AS movie_count,
     ROUND(SUM(total_votes_rating) /SUM(total_votes) ,2) AS actor_avg_rating,
     DENSE_RANK() OVER(ORDER BY (SUM(total_votes_rating) /SUM(total_votes)) DESC,SUM(total_votes) DESC ) AS actress_rank
FROM
    actress_avg_rating
GROUP BY     
	actress_name
HAVING SUM(movie_count)>=3) A 
WHERE A.actress_rank<=5;



/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

WITH movie_category AS
(
SELECT
     g.movie_id,
     CASE WHEN r.avg_rating > 8 THEN 'Superhit movies'
          WHEN r.avg_rating >7 AND r.avg_rating <=8 THEN 'Hit movies'
          WHEN r.avg_rating >=5 AND r.avg_rating <=7 THEN 'One-time-watch movies'
          WHEN r.avg_rating <5 THEN 'Flop movies'
     END AS movie_hit_category
FROM
    genre g
    INNER JOIN
    ratings r
ON  g.movie_id=r.movie_id 
WHERE g.genre='Thriller'   
)
SELECT 
      movie_hit_category,
      COUNT(movie_id) AS movie_count
FROM       
    movie_category
GROUP BY movie_hit_category;  


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

WITH genre_duration_summary AS
(
SELECT 
      g.genre,
      ROUND(AVG(m.duration),2) AS avg_duration
FROM
     genre g
     INNER JOIN
     movie m
ON   g.movie_id=m.id
GROUP BY g.genre
)
SELECT *,
       SUM(avg_duration) OVER w AS  running_total_duration,
       ROUND(AVG(avg_duration)OVER w ,2) AS moving_avg_duration
FROM
     genre_duration_summary     
WINDOW w AS (ORDER BY genre ROWS UNBOUNDED PRECEDING)
ORDER BY genre;   



-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
SELECT
     A.*
FROM
(     
WITH genre_rank AS
(
SELECT
      g.genre,
      COUNT(g.movie_id) AS movie_count,
      RANK() OVER(ORDER BY COUNT(g.movie_id) DESC) AS genre_rank
FROM 
    genre g
    INNER JOIN ratings r
ON  g.movie_id=r.movie_id
GROUP BY g.genre    
),
movie_gross_income_summary AS
(
SELECT 
     g.genre,
     m.year,
     m.title AS movie_name,
     SUM(CAST(COALESCE(substring_index(m.worlwide_gross_income,'$',-1),'0') AS DECIMAL)) AS worldwide_gross_income
FROM
     genre g 
     INNER JOIN
     movie m 
ON   g.movie_id=m.id
GROUP BY 
        g.genre,m.year,m.title
)
SELECT
      gr.genre,
      mi.year,
      mi.movie_name,
      CONCAT('$','',mi.worldwide_gross_income) AS worldwide_gross_income,
      RANK() OVER(PARTITION BY mi.year ORDER BY mi.worldwide_gross_income DESC) AS movie_rank
FROM 
      genre_rank gr
      INNER JOIN
      movie_gross_income_summary mi
ON    gr.genre=mi.genre  
WHERE gr.genre_rank<=3) A 
WHERE A.movie_rank<=5;




-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT A.* 
FROM
(
WITH multi_lingual_hits AS
(
SELECT
     m.production_company,
     POSITION(',' IN m.languages) AS position,
     m.id
FROM 
     movie m
     INNER JOIN
     ratings r
ON   m.id=r.movie_id
WHERE 
     r.median_rating >=8
AND  m.production_company IS NOT NULL     
)  
SELECT
     production_company,
     COUNT(id) AS movie_count,
     RANK() OVER(ORDER BY COUNT(id) DESC) AS prod_comp_rank
FROM      
     multi_lingual_hits
WHERE 
     position>0
GROUP BY production_company ) A
WHERE
     A.prod_comp_rank<=2;



-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT 
      A.actress_name,
      A.total_votes,
      A.movie_count,
      A.actress_avg_rating,
      A.actress_rank
FROM      
(
WITH actress_avg_rating AS
(
SELECT
     n.name AS actress_name,
     r.total_votes AS total_votes,
     (r.avg_rating) * (r.total_votes) AS total_votes_rating,
     COUNT(r.movie_id) AS movie_count
FROM 
    names n
    INNER JOIN 
    role_mapping rm
ON  n.id=rm.name_id
AND rm.category='actress'
    INNER JOIN
    ratings r
ON  rm.movie_id=r.movie_id  
    INNER JOIN
    genre g
ON  rm.movie_id=g.movie_id
WHERE r.avg_rating>8
AND  g.genre='Drama'
GROUP BY n.name,r.total_votes,r.avg_rating
)
SELECT
     actress_name,
     SUM(total_votes) AS total_votes,
	 SUM(movie_count)  AS movie_count,
     ROUND(SUM(total_votes_rating) /SUM(total_votes) ,2) AS actress_avg_rating,
     ROW_NUMBER() OVER(ORDER BY SUM(movie_count) DESC,SUM(total_votes_rating) /SUM(total_votes) DESC) AS actress_rank
FROM
    actress_avg_rating
GROUP BY     
	actress_name) A
WHERE A.actress_rank<=3;


/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

SELECT
     A.director_id,
     A.director_name,
     A.number_of_movies,
     AVG(A.inter_movie_days) AS avg_inter_movie_days,
     AVG(A.avg_rating) AS avg_rating,
     SUM(A.total_votes) AS total_votes,
     MIN(A.avg_rating) AS min_rating,
     MAX(A.avg_rating) AS max_rating,
     SUM(A.duration) AS total_duration
FROM

(WITH top_9_directors AS
(
SELECT
      d.name_id AS director_id,
      n.name AS director_name,
      COUNT(d.movie_id) AS number_of_movies,
      ROW_NUMBER() OVER (ORDER BY COUNT(d.movie_id) DESC) AS director_rank
FROM
     director_mapping d
     INNER JOIN
     names n
ON   d.name_id=n.id
GROUP BY d.name_id,n.name
),
director_details AS(
SELECT
      d.name_id AS director_id,
      n.name AS director_name,
      d.movie_id,
      m.date_published,
      r.avg_rating,
      r.total_votes,
      m.duration
FROM
     director_mapping d
     INNER JOIN
     names n
ON   d.name_id=n.id
     INNER JOIN
     movie m
ON   d.movie_id=m.id
     INNER JOIN
     ratings r
ON   d.movie_id=r.movie_id
)
SELECT
     t9.director_id,
     t9.director_name,
     t9.number_of_movies,
     CASE WHEN LAG(dt.date_published,1) OVER (PARTITION BY t9.director_id ORDER BY dt.date_published,t9.director_id) IS NULL THEN 0
          ELSE DATEDIFF(DT.DATE_PUBLISHED,LAG(dt.date_published,1) OVER (PARTITION BY t9.director_id ORDER BY dt.date_published,t9.director_id))
     END  AS inter_movie_days,
     dt.avg_rating,
     dt.total_votes,
     dt.duration
FROM
    top_9_directors t9
    INNER JOIN
    director_details dt
ON  t9.director_id=dt.director_id
WHERE t9.director_rank<=9   
ORDER BY t9.director_id,number_of_movies desc) A
GROUP BY 
       A.director_id,
       A.director_name,
       A.number_of_movies
ORDER BY  A.number_of_movies DESC;





