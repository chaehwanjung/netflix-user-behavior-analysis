/* 정리 */
-- 각 테이블의 TRUE/FALSE 값으로 나오는 컬럼의 형식을 무엇으로 할 것인가? tinyint(1) or text
-- 비어있는 값을 모두 NULL로 할 것인가? 다른 값으로 채워야 하는 경우가 존재하는가?



/* NETFLIX 데이터베이스 생성 */
CREATE DATABASE NETFLIX;

/* NETFLIX 데이터베이스 사용 */
USE NETFLIX;

/* users 테이블 생성 및 데이터 로드 */
CREATE TABLE users (
	user_id text,
	email text,
	first_name text,
	last_name text,
	age int,
	gender text,
	country text,
	state_province text,
	city text,
	subscription_plan text,
	subscription_start_date date,
	is_active text,
	monthly_spend double,
	primary_device text,
	household_size int,
	created_at datetime
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- is_active를 tinyint(1) 말고 text로 넣는 게 맞나?

ALTER TABLE users
MODIFY age INT NULL,
MODIFY monthly_spend DOUBLE NULL;
-- NULL 허용하면 NULL로 들어갈 줄 알고 작성했던 쿼리

-- age, gender, monthly_spend, household_size 컬럼의 비어있는 값이 NULL로 들어가도록 SET 옵션 적용.
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE '/ABSOLUTE/PATH/TO/data/raw/users.csv' IGNORE
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n'
IGNORE 1 ROWS
(user_id, email, first_name, last_name, age, gender, country, state_province, city, subscription_plan, subscription_start_date, is_active, monthly_spend, primary_device, household_size, created_at)
SET
  age = NULLIF(age, ''),
  gender = NULLIF(gender, ''),
  monthly_spend = NULLIF(monthly_spend, ''),
  household_size = NULLIF(household_size, '');

SELECT  COUNT(*)
  FROM  users;
  
SELECT  *
  FROM  users
 LIMIT  10;
 
 /*
비어있는 값을 NULL로 넣기 위해 사용했던 쿼리

TRUNCATE TABLE users;

SELECT  *
  FROM  users
 WHERE  created_at is null
 LIMIT  10;
-- 각 컬럼에 빈 문자열이나 0으로 들어가는 게 있는지 확인해서(원래 NULL이어야 하는 것들) 있으면 NULL로 바꿔줌(NULL로 바꾸는 게 맞다면)
-- date 컬럼은 = '' 말고 is null로 조건 작성해서 확인해야 하는 듯?
*/
 

/* movies 테이블 생성 및 데이터 로드 */
CREATE TABLE movies (
	movie_id text,
    title text,
    content_type text,
    genre_primary text,
    genre_secondary text,
    release_year int,
    duration_minutes int,
    rating text,
    language text,
    country_of_origin text,
    imdb_rating double,
	production_budget int,
    box_office_revenue int,
    number_of_seasons int,
    number_of_episodes int,
    is_netflix_original text,
    added_to_platform date,
    content_warning text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- is_netflix_original, content_warning을 tinyint(1) 말고 text로 넣는 게 맞나?

-- 엑셀에서 자동필터로 컬럼마다 필드값없음 항목 확인함.. 더 효율적으로 하려면 따로 확인 안 하고 모든 컬럼에 대해 NULLIF 해야할까?
-- 비어있는 값 존재하는 컬럼: genre_secondary, imdb_rating, production_budget, box_office_revenue, number_of_seasons, number_of_episodes

LOAD DATA LOCAL INFILE '/ABSOLUTE/PATH/TO/data/raw/movies.csv' IGNORE
INTO TABLE movies
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS
(movie_id, title, content_type, genre_primary, genre_secondary, release_year, duration_minutes, rating, language, country_of_origin, imdb_rating, production_budget, box_office_revenue, number_of_seasons, number_of_episodes, is_netflix_original, added_to_platform, content_warning)
SET
  genre_secondary = NULLIF(genre_secondary, ''),
  imdb_rating = NULLIF(imdb_rating, ''),
  production_budget = NULLIF(production_budget, ''),
  box_office_revenue = NULLIF(box_office_revenue, ''),
  number_of_seasons = NULLIF(number_of_seasons, ''),
  number_of_episodes = NULLIF(number_of_episodes, '');

SELECT  COUNT(*)
  FROM  movies;
  
SELECT  *
  FROM  movies
 LIMIT  10;


/* watch_history 테이블 생성 및 데이터 로드 */
CREATE TABLE watch_history (
	session_id text,
    user_id	text,
    movie_id text,
	watch_date date,
	device_type	text,
    watch_duration_minutes double,
    progress_percentage double,
    action text,
	quality text,
	location_country text,
	is_download text,
	user_rating int
);
-- is_download를 tinyint(1) 말고 text로 넣는 게 맞나? 
    
-- 비어있는 값 존재하는 컬럼: watch_duration_minutes, progress_percentage, user_rating

LOAD DATA LOCAL INFILE '/ABSOLUTE/PATH/TO/data/raw/watch_history.csv' IGNORE
INTO TABLE watch_history
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS
   (session_id,
    user_id,
    movie_id,
	watch_date,
	device_type,
    watch_duration_minutes,
    progress_percentage,
    action,
	quality,
	location_country,
	is_download,
	user_rating)
SET
	watch_duration_minutes = NULLIF(watch_duration_minutes, ''),
    progress_percentage = NULLIF(progress_percentage, ''),
    user_rating = NULLIF(user_rating, '');
    
SELECT  COUNT(*)
  FROM  watch_history;
  
SELECT  *
  FROM  watch_history
 LIMIT  10;


/* recommendation_logs 테이블 생성 및 데이터 로드 */
CREATE TABLE recommendation_logs (
	recommendation_id text,
	user_id text,
	movie_id text,
	recommendation_date date,
	recommendation_type text,
	recommendation_score double,
	was_clicked text,
	position_in_list int,
	device_type text,
	time_of_day text,
	algorithm_version text
);
-- was_clicked를 tinyint(1) 말고 text로 넣는 게 맞나? 
    
-- 비어있는 값 존재하는 컬럼: recommendation_score, algorithm_version

LOAD DATA LOCAL INFILE '/ABSOLUTE/PATH/TO/data/raw/recommendation_logs.csv' IGNORE
INTO TABLE recommendation_logs
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS
   (recommendation_id,
	user_id,
	movie_id,
	recommendation_date,
	recommendation_type,
	recommendation_score,
	was_clicked,
	position_in_list,
	device_type,
	time_of_day,
	algorithm_version)
SET
	recommendation_score = NULLIF(recommendation_score, ''),
    algorithm_version = NULLIF(algorithm_version, '');
    
SELECT  COUNT(*)
  FROM  recommendation_logs;
  
SELECT  *
  FROM  recommendation_logs
 LIMIT  10;


/* search_logs 테이블 생성 및 데이터 로드 */
CREATE TABLE search_logs (
	search_id text,
	user_id text,
	search_query text,
	search_date date,
	results_returned int,
	clicked_result_position int,
    device_type text,
    search_duration_seconds double,
	had_typo text,
	used_filters text,
	location_country text
);
-- had_typo, used_filters를 tinyint(1) 말고 text로 넣는 게 맞나? 
    
-- 비어있는 값 존재하는 컬럼: clicked_result_position, search_duration_seconds

LOAD DATA LOCAL INFILE '/ABSOLUTE/PATH/TO/data/raw/search_logs.csv' IGNORE
INTO TABLE search_logs
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS
   (search_id,
	user_id,
	search_query,
	search_date,
	results_returned,
	clicked_result_position,
    device_type,
    search_duration_seconds,
	had_typo,
	used_filters,
	location_country)
SET
	clicked_result_position = NULLIF(clicked_result_position, ''),
    search_duration_seconds = NULLIF(search_duration_seconds, '');
    
SELECT  COUNT(*)
  FROM  search_logs;
  
SELECT  *
  FROM  search_logs
 LIMIT  10;


/* reviews 테이블 생성 및 데이터 로드 */
CREATE TABLE reviews (
	review_id text,
	user_id text,
	movie_id text,
	rating int,
	review_date date,
	device_type text,
	is_verified_watch text,
	helpful_votes int,
	total_votes int,
	review_text text,
	sentiment text,
	sentiment_score double
);
-- is_verified_watch를 tinyint(1) 말고 text로 넣는 게 맞나? 
    
-- 비어있는 값 존재하는 컬럼: helpful_votes, total_votes, review_text, sentiment_score

LOAD DATA LOCAL INFILE '/ABSOLUTE/PATH/TO/data/raw/reviews.csv' IGNORE
INTO TABLE reviews
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\n' STARTING BY ''
IGNORE 1 ROWS
   (review_id,
	user_id,
	movie_id,
	rating,
	review_date,
	device_type,
	is_verified_watch,
	helpful_votes,
	total_votes,
	review_text,
	sentiment,
	sentiment_score)
SET
	helpful_votes = NULLIF(helpful_votes, ''),
    total_votes = NULLIF(total_votes, ''),
    review_text = NULLIF(review_text, ''),
    sentiment_score = NULLIF(sentiment_score, '');
    
SELECT  COUNT(*)
  FROM  reviews;
  
SELECT  *
  FROM  reviews
 LIMIT  10;
 
 SET GLOBAL local_infile = 0;