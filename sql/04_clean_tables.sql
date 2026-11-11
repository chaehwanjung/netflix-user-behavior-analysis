/*
--------------정리----------------
1. 기존 테이블 이름 raw_ 로 변경
2. clean 테이블 생성 (데이터 형식 정리)
3. raw → clean INSERT (데이터 전처리) -> 이상치(극단값)은 IQR 방식 아닌 99퍼센타일 분위수 대체 방식 사용
*/



USE netflix;

/* 기존 테이블 이름을 raw_ 로 변경 */

ALTER TABLE users RENAME TO raw_users;
ALTER TABLE movies RENAME TO raw_movies;
ALTER TABLE watch_history RENAME TO raw_watch_history;
ALTER TABLE recommendation_logs RENAME TO raw_recommendation_logs;
ALTER TABLE search_logs RENAME TO raw_search_logs;
ALTER TABLE reviews RENAME TO raw_reviews;

/* clean_users 테이블 생성 */

CREATE TABLE clean_users (
	user_id VARCHAR(10) PRIMARY KEY,
	email VARCHAR(100),
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	age ENUM('09세 이하', '10대', '20대', '30대', '40대', '50대', '60대', '70세 이상', 'Unknown') NOT NULL,
	gender ENUM('Male', 'Female', 'Other', 'Unknown') NOT NULL,
	country ENUM('USA','Canada') NOT NULL,
	state_province VARCHAR(100),
	city VARCHAR(100),
	subscription_plan ENUM('Basic', 'Standard', 'Premium', 'PremiumPlus') NOT NULL,
	is_active BOOLEAN NOT NULL,
	monthly_spend DECIMAL(10,2),
	primary_device ENUM('Tablet', 'Laptop', 'Smart TV', 'Mobile', 'Desktop', 'Gaming Console') NOT NULL,
	household_size INT,
	created_at DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Premium+ -> PremiumPlus
SET sql_safe_updates = 0;

UPDATE  raw_users
   SET  subscription_plan = 'PremiumPlus'
 WHERE  subscription_plan = 'Premium+';
 
SET sql_safe_updates = 1;

SELECT * FROM raw_users LIMIT 10;

/* raw_users -> clean_users 데이터 로드 및 전처리 */
-- age: 컬럼 범주형화
-- gender: NULL, 'Prefer not to say'-> 'Unknown'
-- household_size: NULL -> 최빈값
-- subscription_start_date: 컬럼 삭제
-- monthly_spend: NULL -> 중앙값 / 이상치 -> 상한값

INSERT INTO clean_users (
    user_id,
    email,
    first_name,
    last_name,
    age,
    gender,
    country,
    state_province,
    city,
    subscription_plan,
    is_active,
    monthly_spend,
    primary_device,
    household_size,
    created_at
)
SELECT  r.user_id,
		r.email,
		r.first_name,
		r.last_name,
		CASE WHEN r.age <= 0 OR r.age > 100 OR r.age IS NULL THEN 'Unknown'
			 WHEN r.age >= 1 AND r.age < 10 THEN '09세 이하'
             WHEN r.age >= 10 AND r.age < 20 THEN '10대'
             WHEN r.age >= 20 AND r.age < 30 THEN '20대'
             WHEN r.age >= 30 AND r.age < 40 THEN '30대'
             WHEN r.age >= 40 AND r.age < 50 THEN '40대'
             WHEN r.age >= 50 AND r.age < 60 THEN '50대'
             WHEN r.age >= 60 AND r.age < 70 THEN '60대'
             ELSE '70세 이상'
        END AS age,
        CASE WHEN r.gender IS NULL OR r.gender = 'Prefer not to say' THEN 'Unknown' ELSE r.gender END AS gender,
		r.country,
		r.state_province,
		r.city,
		r.subscription_plan,
		CASE WHEN r.is_active = 'True' THEN 1 WHEN r.is_active = 'False' THEN 0 ELSE NULL END AS is_active,
		CASE WHEN r.monthly_spend IS NULL THEN 13.56 ELSE r.monthly_spend END AS monthly_spend,
		r.primary_device,
		CASE WHEN r.household_size IS NULL THEN 2 ELSE r.household_size END AS household_size,
		r.created_at
  FROM  (
		SELECT DISTINCT *
		FROM raw_users
) r;

-- monthly_spend: 이상치를 상한값으로 대체
SET sql_safe_updates = 0;

UPDATE clean_users
SET monthly_spend = 94.09
WHERE monthly_spend > 94.09;

SET sql_safe_updates = 1;

SELECT  COUNT(*)
  FROM  clean_users;
-- 10000
  
SELECT  *
  FROM  clean_users
 LIMIT  10;


/* clean_movies 테이블 생성 */

CREATE TABLE clean_movies (
	movie_id VARCHAR(10) PRIMARY KEY,
    title VARCHAR(200),
    content_type ENUM('Stand-up Comedy', 'Movie', 'Documentary', 'TV Series', 'Limited Series') NOT NULL,
    genre_primary VARCHAR(50),
    genre_secondary VARCHAR(50),
    release_year INT,
    duration_minutes INT,
    rating ENUM('G','PG','PG-13','R','NC-17', 'TV-Y','TV-Y7','TV-G','TV-PG','TV-14','TV-MA') NOT NULL,
    language VARCHAR(50),
    country_of_origin VARCHAR(100),
    imdb_rating DECIMAL(3,1),
	production_budget BIGINT,
    box_office_revenue BIGINT,
    number_of_seasons INT,
    number_of_episodes INT,
    is_netflix_original BOOLEAN NOT NULL,
    added_to_platform DATE,
    content_warning BOOLEAN NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/* raw_movies -> clean_movies 데이터 로드 및 전처리 */
-- duration_minutes: 이상치 -> 300분 / 오류값(duration_minutes = 0) -> 해당 콘텐츠 타입의 평균값

INSERT INTO clean_movies (
	movie_id,
    title,
    content_type,
    genre_primary, 
    genre_secondary, 
    release_year, 
    duration_minutes,
    rating,
    language,
    country_of_origin,
    imdb_rating, 
    production_budget, 
    box_office_revenue, 
    number_of_seasons, 
    number_of_episodes, 
    is_netflix_original, 
    added_to_platform, 
    content_warning
)
SELECT  r.movie_id,
		r.title,
		r.content_type,
		r.genre_primary, 
		r.genre_secondary, 
		r.release_year, 
		r.duration_minutes,
		r.rating,
		r.language,
		r.country_of_origin,
		r.imdb_rating, 
		r.production_budget, 
		r.box_office_revenue, 
		r.number_of_seasons, 
		r.number_of_episodes, 
		CASE
    WHEN UPPER(TRIM(REPLACE(REPLACE(r.is_netflix_original, '\r',''), '\n',''))) = 'TRUE'  THEN 1
    WHEN UPPER(TRIM(REPLACE(REPLACE(r.is_netflix_original, '\r',''), '\n',''))) = 'FALSE' THEN 0
    ELSE 0
  END AS is_netflix_original,
		r.added_to_platform, 
		CASE
    WHEN UPPER(TRIM(REPLACE(REPLACE(r.content_warning, '\r',''), '\n',''))) = 'TRUE'  THEN 1
    WHEN UPPER(TRIM(REPLACE(REPLACE(r.content_warning, '\r',''), '\n',''))) = 'FALSE' THEN 0
    ELSE 0
  END AS content_warning
  FROM  (
		SELECT DISTINCT *
        FROM raw_movies
) r;

-- duration_minutes: 이상치를 300분으로 대체
SET sql_safe_updates = 0;

UPDATE clean_movies
SET duration_minutes = 300
WHERE duration_minutes > 300;

SET sql_safe_updates = 1;

-- duration_minutes = 0 -> content_type이 Limited Series인 콘텐츠의 평균 duration_minutes로 대체
SET sql_safe_updates = 0;

UPDATE clean_movies
SET duration_minutes = 58
WHERE duration_minutes = 0;

SET sql_safe_updates = 1;

SELECT  COUNT(*)
  FROM  clean_movies;
-- 1000
  
SELECT  *
  FROM  clean_movies
 LIMIT  10;


/* clean_watch_history 테이블 생성 */

CREATE TABLE clean_watch_history (
	session_id VARCHAR(20) PRIMARY KEY,
    user_id	VARCHAR(10) NOT NULL,
    movie_id VARCHAR(10) NOT NULL,
	watch_date DATE,
	device_type	ENUM('Tablet', 'Laptop', 'Smart TV', 'Mobile', 'Desktop') NOT NULL,
    watch_duration_minutes DECIMAL(4,1),
    progress_percentage DECIMAL(4,1),
    action ENUM('completed', 'started', 'stopped', 'paused') NOT NULL,
	quality ENUM('HD', 'SD', '4K', 'Ultra HD') NOT NULL,
	location_country ENUM('USA','Canada') NOT NULL,
	is_download BOOLEAN NOT NULL,
	user_rating INT,
    FOREIGN KEY (user_id) REFERENCES clean_users(user_id),
	FOREIGN KEY (movie_id) REFERENCES clean_movies(movie_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/* raw_watch_history -> clean_watch_history 데이터 로드 및 전처리 */
-- watch_duration_minutes: NULL -> 중앙값 / 이상치 -> 상한값
-- progress_percentage: NULL -> 평균

INSERT INTO clean_watch_history (
	session_id,
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
	user_rating
)
SELECT  r.session_id,
		r.user_id,
		r.movie_id,
		r.watch_date,
		r.device_type,
        CASE WHEN r.watch_duration_minutes IS NULL THEN 51.2 ELSE r.watch_duration_minutes END AS watch_duration_minutes,
        CASE WHEN r.progress_percentage IS NULL THEN 50 ELSE r.progress_percentage END AS progress_percentage,
		r.action,
		r.quality,
		r.location_country,
		CASE WHEN r.is_download = 'True' THEN 1 WHEN r.is_download = 'False' THEN 0 ELSE NULL END AS is_download,
		user_rating
  FROM  (
		SELECT DISTINCT *
        FROM raw_watch_history
) r;

-- watch_duration_minutes: 이상치를 상한값으로 대체
SET sql_safe_updates = 0;

UPDATE clean_watch_history
SET watch_duration_minutes = 316.1
WHERE watch_duration_minutes > 316.1;

SET sql_safe_updates = 1;

SELECT  COUNT(*)
  FROM  clean_watch_history;
-- 100000
  
SELECT  *
  FROM  clean_watch_history
 LIMIT  10;
 
 
/* clean_recommendation_logs 테이블 생성 */

 CREATE TABLE clean_recommendation_logs (
	recommendation_id VARCHAR(10) PRIMARY KEY,
    user_id	VARCHAR(10) NOT NULL,
    movie_id VARCHAR(10) NOT NULL,
	recommendation_date DATE,
	recommendation_type ENUM('new_releases', 'genre_based', 'personalized', 'trending', 'similar_users') NOT NULL,
	recommendation_score DECIMAL(4,3),
	was_clicked BOOLEAN NOT NULL,
	position_in_list INT,
	device_type ENUM('Tablet', 'Laptop', 'Smart TV', 'Mobile') NOT NULL,
	time_of_day ENUM('morning', 'afternoon', 'evening', 'night') NOT NULL,
	algorithm_version ENUM('v1.2', 'v1.3', 'v1.4', 'v2.0', 'Unknown') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES clean_users(user_id),
	FOREIGN KEY (movie_id) REFERENCES clean_movies(movie_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*raw_recommendation_logs -> clean_recommendation_logs 데이터 로드 및 전처리*/
-- algorithm_version: NULL -> 'Unknown’

INSERT INTO clean_recommendation_logs (
	recommendation_id,
	user_id,
	movie_id,
	recommendation_date,
	recommendation_type,
	recommendation_score,
	was_clicked,
	position_in_list,
	device_type,
	time_of_day,
	algorithm_version
)
SELECT  r.recommendation_id,
		r.user_id,
		r.movie_id,
		r.recommendation_date,
		r.recommendation_type,
		r.recommendation_score,
        CASE WHEN r.was_clicked = 'True' THEN 1 WHEN r.was_clicked = 'False' THEN 0 ELSE NULL END AS was_clicked,
		r.position_in_list,
		r.device_type,
		r.time_of_day,
		CASE WHEN r.algorithm_version IS NULL THEN 'Unknown' ELSE r.algorithm_version END AS algorithm_version
  FROM  (
		SELECT DISTINCT *
        FROM raw_recommendation_logs
) r;

SELECT  COUNT(*)
  FROM  clean_recommendation_logs;
-- 50000
  
SELECT  *
  FROM  clean_recommendation_logs
 LIMIT  10;


/* clean_search_logs 테이블 생성 */

CREATE TABLE clean_search_logs (
	search_id VARCHAR(20) PRIMARY KEY,
    user_id	VARCHAR(10) NOT NULL,
	search_query VARCHAR(200),
	search_date DATE,
	results_returned INT,
	clicked_result_position INT,
    device_type ENUM('Tablet', 'Laptop', 'Smart TV', 'Mobile') NOT NULL,
    search_duration_seconds DECIMAL(4,1),
	had_typo BOOLEAN NOT NULL,
	used_filters BOOLEAN NOT NULL,
	location_country ENUM('USA','Canada') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES clean_users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*raw_search_logs -> clean_search_logs 데이터 로드 및 전처리*/
-- search_duration_seconds: NULL -> 중앙값 / 이상치 -> 상한값

INSERT INTO clean_search_logs (
	search_id,
	user_id,
	search_query,
	search_date,
	results_returned,
	clicked_result_position,
    device_type,
    search_duration_seconds,
	had_typo,
	used_filters,
	location_country
)
SELECT  r.search_id,
		r.user_id,
		r.search_query,
		r.search_date,
		r.results_returned,
		r.clicked_result_position,
		r.device_type,
        CASE WHEN r.search_duration_seconds IS NULL THEN 16.8 ELSE r.search_duration_seconds END AS search_duration_seconds,
		CASE WHEN r.had_typo = 'True' THEN 1 WHEN r.had_typo = 'False' THEN 0 ELSE NULL END AS had_typo,
		CASE WHEN r.used_filters = 'True' THEN 1 WHEN r.used_filters = 'False' THEN 0 ELSE NULL END AS used_filters,
		r.location_country
  FROM  (
		SELECT DISTINCT *
        FROM raw_search_logs
) r;

-- search_duration_seconds: 이상치를 상한값으로 대체
SET sql_safe_updates = 0;

UPDATE clean_search_logs
SET search_duration_seconds = 66.6
WHERE search_duration_seconds > 66.6;

SET sql_safe_updates = 1;

SELECT  COUNT(*)
  FROM  clean_search_logs;
-- 25000
  
SELECT  *
  FROM  clean_search_logs
 LIMIT  10;


/* clean_reviews 테이블 생성*/
-- sentiment_score: NULL -> 감성 범주별 평균
-- total_votes: NULL -> 0
-- helpful_votes: NULL -> 0

CREATE TABLE clean_reviews (
	review_id VARCHAR(20) PRIMARY KEY,
    user_id	VARCHAR(10) NOT NULL,
    movie_id VARCHAR(10) NOT NULL,
	rating INT,
	review_date DATE,
	device_type ENUM('Tablet', 'Laptop', 'Smart TV', 'Mobile') NOT NULL,
	is_verified_watch BOOLEAN NOT NULL,
	helpful_votes INT,
	total_votes INT,
	review_text VARCHAR(200),
	sentiment ENUM('positive', 'neutral', 'negative') NOT NULL,
	sentiment_score DECIMAL(4,3),
    FOREIGN KEY (user_id) REFERENCES clean_users(user_id),
	FOREIGN KEY (movie_id) REFERENCES clean_movies(movie_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*raw_reviews -> clean_reviews 데이터 로드 및 전처리*/

INSERT INTO clean_reviews (
	review_id,
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
	sentiment_score
)
SELECT  r.review_id,
		r.user_id,
		r.movie_id,
		r.rating,
		r.review_date,
		r.device_type,
        CASE WHEN r.is_verified_watch = 'True' THEN 1 WHEN r.is_verified_watch = 'False' THEN 0 ELSE NULL END AS is_verified_watch,
		CASE WHEN r.helpful_votes IS NULL THEN 0 ELSE r.helpful_votes END AS helpful_votes,
        CASE WHEN r.total_votes IS NULL THEN 0 ELSE r.total_votes END AS total_votes,
		r.review_text,
		r.sentiment,
        CASE WHEN r.sentiment_score IS NULL AND sentiment = 'positive' THEN 0.8
			 WHEN r.sentiment_score IS NULL AND sentiment = 'neutral' THEN 0.501
			 WHEN r.sentiment_score IS NULL AND sentiment = 'negative' THEN 0.194
			 ELSE r.sentiment_score END AS sentiment_score
  FROM  (
		SELECT DISTINCT *
        FROM raw_reviews
) r;
  
SELECT  COUNT(*)
  FROM  clean_reviews;
-- 15000
  
SELECT  *
  FROM  clean_reviews
 LIMIT  10;