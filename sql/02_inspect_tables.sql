/* 정리 */
-- 각 @테이블의 @_id 컬럼에 대해 중복 처리 필요. 어떤 방식으로 처리할 것인가?
	-- users.user_id, movies.movie_id, watch_history.session_id, recommendation_logs.recommendation_id, search_logs.search_id, reviews.review_id

-- 각 테이블의 NULL값이 50% 이상인 컬럼들에 대해 결측값 처리가 필요한가? NULL이 의미상으로는 정상으로 보임.
	-- movies: genre_secondary, production_budget_missing, box_office_revenue, number_of_seasons, number_of_episodes
	-- watch_history: user_rating
    -- search_logs: clicked_result_position

-- user 테이블 관련
	-- age: 사용자 나이						-- 최소값 -7, 최대값 109로 불가능한 숫자 포함. age < 0인 행이 19개 있음.
	-- subscription_start_date: 구독 시작일	-- created_at 보다 빠른 경우가 있는데 이게 어떻게 가능한가? 구독을 하려면 계정을 먼저 생성해야 하는 것 아닌가?
    -- monthly_spend: 월 평균 지출 금액			-- 최소값 0.11, 최대값 997.8인데 평균값은 약 22.14 -> 지나치게 큰 값이 소수 존재.

-- movies 테이블에 duration_minutes = 0 인 행이 하나 있음.
-- duration_minutes를 1시간 단위로 잘라본 것 -> 대부분 0~3시간.
-- 0~1시간	350
-- 1~2시간	517
-- 2~3시간	146
-- 3~4시간	2
-- 5~6시간	4
-- 6~7시간	6
-- 7~8시간	4
-- 8~9시간	7
-- 9시간 이상	4

-- watch_history 테이블의 watch_duration_minutes 최소값 0.2, 최대값 799.3인데 평균값 약 65.6 -> 지나치게 큰 값이 소수 존재

-- users 테이블의 subscription_start_date의 기간은	2022-08-02 ~ 2025-08-01
-- users 테이블의 created_at의 기간은 				2022-08-03 08:42:45 ~ 2025-08-02 14:44:19
-- movies 테이블의 added_to_platform의 기간은		2020-08-02 ~ 2025-08-01
-- 나머지 테이블의 date 컬럼의 기간은 					2024-01-01 ~ 2025-12-31 로 동일

-- users 테이블의 primary_device는										Tablet, Laptop, Smart TV, Mobile, Desktop, Gaming Console
-- watch_history 테이블의 device_type은 								Tablet, Laptop, Smart TV, Mobile, Desktop
-- recommendation_logs, search_logs, reviews 테이블의 device_type은 	Tablet, Laptop, Smart TV, Mobile

-- 사용자가 총 10000명이고 watch_history 테이블에도 사용자가 10000명이 있으니 -> 모든 사용자는 1회 이상 시청을 했고, 총 105000건의 시청 기록에 나눠져 있음.
-- 영화가 총 1000편이고 watch_history 테이블에도 영화가 1000편이 있으니 -> 모든 영화는 1회 이상 시청되었고, 총 105000건의 시청 기록에 나눠져 있음.
-- 사용자는 총 10000명이고 recommendation_logs 테이블에는 사용자가 9921명 있음.
-- 영화가 총 1000편이고 recommendation_logs 테이블에도 영화가 1000편이 있으니 -> 모든 영화는 1회 이상 추천됨.
-- 사용자는 총 10000명이고 search_logs 테이블에는 사용자가 9186명 있음.
-- 사용자는 총 10000명이고 reviews 테이블에는 사용자가 7761명 있음.
-- 영화가 총 1000편이고 reviews 테이블에도 영화가 1000편이 있으니 -> 모든 영화에 대해 1회 이상 후기가 작성됨.




/* 테이블 확인 */

/* users */
SELECT * FROM users LIMIT 10;
-- user_id
-- email
-- first_name
-- last_name
-- age: -7 ~ 109
-- gender: Male, Female, Other, Prefer not to say, NULL
-- country: USA, Canada
-- state_province
-- city
-- subscription_plan: 구독 요금제 Basic, Standard, Premium, Premium+
-- subscription_start_date: 구독 시작일 2022-08-02 ~ 2025-08-01		-- created_at 보다 빠른 경우가 있는데 이게 어떻게 가능한가? 구독을 하려면 계정을 먼저 생성해야 하는 것 아닌가?
-- is_active: 현재 구독 여부											-- 구독 여부와는 다른 것인가? ex. 구독을 지속하고 있지만 일정 기간 이상 사용을 안 하면 비활성 (-> 그렇다면 이탈했다고 볼 수는 없고 이탈 위험이라고 보면 되나?)
-- monthly_spend: 월 평균 지출 금액 0.11 ~ 997.8, 평균값은 약 22.14
-- primary_device: 주 사용 디바이스 Laptop, Desktop, Gaming Console, Tablet, Mobile, Smart TV
-- household_size: 가구원 수 1 ~ 8
-- created_at: 계정 생성일 2022-08-03 08:42:45 ~ 2025-08-02 14:44:19

-- gender 항목 확인
SELECT	DISTINCT gender
  FROM	users;

-- country 항목 확인
SELECT	DISTINCT country
  FROM	users;
  
-- subscription_plan 항목 확인
SELECT	DISTINCT subscription_plan
  FROM	users;
  
-- primary_device 항목 확인
SELECT	DISTINCT primary_device
  FROM	users;
  
-- age의 min, max 확인
SELECT	MIN(age), MAX(age)
  FROM	users;

-- age < 0 인 행 수 확인
SELECT	COUNT(*)
  FROM	users
 WHERE  age < 0;
-- 19
  
-- subscription_start_date의 min, max 확인
SELECT	MIN(subscription_start_date), MAX(subscription_start_date)
  FROM	users;
  
-- monthly_spend의 min, max 확인
SELECT	MIN(monthly_spend), MAX(monthly_spend), AVG(monthly_spend)
  FROM	users;

SELECT	COUNT(*)
  FROM	users
 WHERE  monthly_spend > 50;
  
-- household_size의 min, max 확인
SELECT	MIN(household_size), MAX(household_size)
  FROM	users;
  
-- created_at의 min, max 확인
SELECT	MIN(created_at), MAX(created_at)
  FROM	users;

-- subscription_start_date < created_at인 사용자 수 확인
SELECT  COUNT(DISTINCT user_id)
  FROM  users
 WHERE  subscription_start_date < created_at;

-- user_id 중복 여부 확인
SELECT	COUNT(*) as cnt
		,COUNT(user_id) as user_cnt_not_distinct
		,COUNT(DISTINCT user_id) as user_cnt
  FROM  users;
-- cnt 10300
-- user_cnt_not_distinct 10300
-- user_cnt 10000
-- 사용자는 10000명이고 중복이 있음

SELECT	user_id, COUNT(*)
  FROM	users
 GROUP
   BY   user_id
HAVING  COUNT(*) >= 2;
-- 결과: 중복된 user_id 목록 + 각 user_id의 등장 횟수

-- 예시 데이터 확인
SELECT	*
  FROM	users
 WHERE  user_id = 'user_00028';

SELECT COUNT(*)
FROM (
	SELECT	user_id, COUNT(*)
	  FROM	users
	 GROUP
        BY  user_id
	HAVING  COUNT(*) >= 2
) AS user_duplicate;
-- 중복된 사용자는 295명. 그 중 대부분 2회 등장(1회 중복), 5명은 3번 등장.
-- 중복 처리 필요!

-- NULL이 있는 컬럼에 대해 결측값 개수 확인
SELECT	COUNT(*) AS total_rows,
		COUNT(*) - COUNT(age) AS age_missing,
		COUNT(*) - COUNT(gender) AS gender_missing,
		COUNT(*) - COUNT(monthly_spend) AS monthly_spend_missing,
		COUNT(*) - COUNT(household_size) AS household_size_missing
  FROM  users;

-- 결측값 비율 확인  
SELECT	(COUNT(*) - COUNT(age)) / COUNT(*) * 100 AS age_missing_pct,
		(COUNT(*) - COUNT(gender)) / COUNT(*) * 100 AS gender_missing_pct,
		(COUNT(*) - COUNT(monthly_spend)) / COUNT(*) * 100 AS monthly_spend_missing_pct,
		(COUNT(*) - COUNT(household_size)) / COUNT(*) * 100 AS household_size_missing_pct
  FROM  users;
-- 11.9612
-- 8.0000
-- 9.8738
-- 15.0000

/* movies */
SELECT * FROM movies LIMIT 10;
-- movie_id
-- title
-- content_type: Stand-up Comedy, Movie, Documentary, TV Series, Limited Series
-- genre_primary: History, Sci-Fi, Drama, Sport, Documentary 등 20가지
-- genre_secondary
-- release_year: 개봉 연도
-- duration_minutes: 영화 길이 0 ~ 586
-- rating: 시청 등급
-- language
-- country_of_origin
-- imdb_rating: imdb에서 제공하는 영화 평점 0.5 ~ 10
-- production_budget
-- box_office_revenue
-- number_of_seasons
-- number_of_episodes
-- is_netflix_original
-- added_to_platform: 2020-08-02 ~ 2025-08-01
-- content_warning: 시청 주의 요소

-- content_type 항목 확인
SELECT	DISTINCT content_type
  FROM	movies;

-- genre_primary 항목 및 개수 확인
SELECT	DISTINCT genre_primary
  FROM	movies;

SELECT	COUNT(DISTINCT genre_primary)
  FROM	movies;
  
-- duration_minutes의 min, max 확인
SELECT	MIN(duration_minutes), MAX(duration_minutes)
  FROM	movies;

-- duration_minutes = 0 인 행 확인
SELECT	*
  FROM	movies
 WHERE  duration_minutes = 0;
 
-- duration_minutes 한 시간 단위로 확인 
SELECT  CASE WHEN duration_minutes < 60 THEN '0~1시간'
			 WHEN duration_minutes < 120 THEN '1~2시간'
			 WHEN duration_minutes < 180 THEN '2~3시간'
			 WHEN duration_minutes < 240 THEN '3~4시간'
			 WHEN duration_minutes < 300 THEN '4~5시간'
             WHEN duration_minutes < 360 THEN '5~6시간'
             WHEN duration_minutes < 420 THEN '6~7시간'
             WHEN duration_minutes < 480 THEN '7~8시간'
             WHEN duration_minutes < 540 THEN '8~9시간'
			 ELSE '9시간 이상'
		END AS duration_hour,
		COUNT(*) AS cnt
  FROM  movies
 GROUP
    BY  duration_hour
 ORDER 
    BY  1;
-- 0~1시간	350
-- 1~2시간	517
-- 2~3시간	146
-- 3~4시간	2
-- 5~6시간	4
-- 6~7시간	6
-- 7~8시간	4
-- 8~9시간	7
-- 9시간 이상	4

-- imdb_rating의 min, max 확인
SELECT	MIN(imdb_rating), MAX(imdb_rating)
  FROM	movies;
  
-- added_to_platform의 min, max 확인
SELECT	MIN(added_to_platform), MAX(added_to_platform)
  FROM	movies;
  
-- movie_id 중복 여부 확인
SELECT	COUNT(*) as cnt
		,COUNT(movie_id) as movie_cnt_not_distinct
		,COUNT(DISTINCT movie_id) as movie_cnt
  FROM  movies;
-- cnt 1040
-- movie_cnt_not_distinct 1040
-- movie_cnt 1000
-- 영화는 1000편이고 중복이 있음

SELECT	movie_id, COUNT(*)
  FROM	movies
 GROUP
   BY   movie_id
HAVING  COUNT(*) >= 2;
-- 결과: 중복된 movie_id 목록 + 각 movie_id의 등장 횟수

-- 예시 데이터 확인
SELECT	*
  FROM	movies
 WHERE  movie_id = 'movie_0034';
 
SELECT COUNT(*)
FROM (
	SELECT	movie_id, COUNT(*)
	  FROM	movies
	 GROUP
        BY  movie_id
	HAVING  COUNT(*) >= 2
) AS movie_duplicate;
-- 중복된 영화는 40편. 모두 2회 등장(1회 중복).
-- 중복 처리 필요!

-- NULL이 많이 보이는 컬럼에 대해 결측값 개수 확인
SELECT	COUNT(*) AS total_rows,
		COUNT(*) - COUNT(genre_secondary) AS genre_secondary_missing,
		COUNT(*) - COUNT(production_budget) AS production_budget_missing,
		COUNT(*) - COUNT(box_office_revenue) AS box_office_revenue_missing,
		COUNT(*) - COUNT(number_of_seasons) AS number_of_seasons_missing,
		COUNT(*) - COUNT(number_of_episodes) AS number_of_episodes_missing
  FROM  movies;

-- 결측값 비율 확인  
SELECT	(COUNT(*) - COUNT(genre_secondary)) / COUNT(*) * 100 AS genre_secondary_missing_pct,
		(COUNT(*) - COUNT(production_budget)) / COUNT(*) * 100 AS production_budget_missing_pct,
		(COUNT(*) - COUNT(box_office_revenue)) / COUNT(*) * 100 AS box_office_revenue_missing_pct,
		(COUNT(*) - COUNT(number_of_seasons)) / COUNT(*) * 100 AS number_of_seasons_missing_pct,
		(COUNT(*) - COUNT(number_of_episodes)) / COUNT(*) * 100 AS number_of_episodes_missing_pct
  FROM  movies;


/* watch_history */
SELECT * FROM watch_history LIMIT 10;
-- session_id
-- user_id
-- movie_id
-- watch_date: 2024-01-01 ~ 2025-12-31
-- device_type: Tablet, Laptop, Desktop, Smart TV, Mobile
-- watch_duration_minutes: 시청 시간 0.2 ~ 799.3, 평균값 약 65.6
-- progress_percentage: 시청 진행률
-- action: 시청 상태 completed, started, stopped, paused			-- stopped -> 세션 종료 / paused -> 세션 유지 ?
-- quality: 화질 HD, SD, 4K, Ultra HD
-- location_country: USA, Canada
-- is_download
-- user_rating: 사용자 평점 1 ~ 5
 
-- device_type 항목 확인
SELECT	DISTINCT device_type
  FROM	watch_history;

-- action 항목 확인
SELECT	DISTINCT action
  FROM	watch_history;
  
-- quality 항목 확인
SELECT	DISTINCT quality
  FROM	watch_history;

-- location_country 항목 확인
SELECT	DISTINCT location_country
  FROM	watch_history;

-- watch_date의 min, max 확인
SELECT	MIN(watch_date), MAX(watch_date)
  FROM	watch_history;
  
-- watch_duration_minutes의 min, max, avg 확인
SELECT	MIN(watch_duration_minutes), MAX(watch_duration_minutes), AVG(watch_duration_minutes)
  FROM	watch_history;

-- user_rating의 min, max 확인
SELECT	MIN(user_rating), MAX(user_rating)
  FROM	watch_history;

-- session_id 중복 여부 확인
SELECT	COUNT(*) as cnt
		,COUNT(session_id) as session_cnt_not_distinct
		,COUNT(DISTINCT session_id) as session_cnt
  FROM  watch_history;
-- cnt 105000
-- session_cnt_not_distinct 105000
-- session_cnt 100000
-- 세션은 100000개고 중복이 있음

SELECT	session_id, COUNT(*)
  FROM	watch_history
 GROUP
   BY   session_id
HAVING  COUNT(*) >= 2;
-- 결과: 중복된 session_id 목록 + 각 session_id의 등장 횟수

-- 예시 데이터 확인
SELECT	*
  FROM	watch_history
 WHERE  session_id = 'session_000004';
 
SELECT COUNT(*)
FROM (
	SELECT	session_id, COUNT(*)
	  FROM	watch_history
	 GROUP
        BY  session_id
	HAVING  COUNT(*) >= 2
) AS session_duplicate;
-- 중복된 세션은 4858개. 그 중 대부분은 2회 등장(1회 중복).
-- 중복 처리 필요!

-- user_id 확인
SELECT	COUNT(*) as cnt
		,COUNT(user_id) as user_cnt_not_distinct
		,COUNT(DISTINCT user_id) as user_cnt
  FROM  watch_history;
-- cnt 105000
-- user_cnt_not_distinct 105000
-- user_cnt 10000
-- 사용자가 총 10000명이고 watch_history 테이블에도 사용자가 10000명이 있으니 -> 모든 사용자는 1회 이상 시청을 했고, 총 105000건의 시청 기록에 나눠져 있음.

-- movie_id 확인
SELECT	COUNT(*) as cnt
		,COUNT(movie_id) as movie_cnt_not_distinct
		,COUNT(DISTINCT movie_id) as movie_cnt
  FROM  watch_history;
-- cnt 105000
-- movie_cnt_not_distinct 105000
-- movie_cnt 1000
-- 영화가 총 1000편이고 watch_history 테이블에도 영화가 1000편이 있으니 -> 모든 영화는 1회 이상 시청되었고, 총 105000건의 시청 기록에 나눠져 있음.

-- NULL이 많이 보이는 컬럼에 대해 결측값 개수 확인
SELECT	COUNT(*) AS total_rows,
		COUNT(*) - COUNT(user_rating) AS user_rating_missing
  FROM  watch_history; 

-- 결측값 비율 확인  
SELECT	(COUNT(*) - COUNT(user_rating)) / COUNT(*) * 100 AS user_rating_missing_pct
  FROM  watch_history;
-- 79.9076


/* recommendation_logs */
SELECT * FROM recommendation_logs LIMIT 10;
-- recommendation_id
-- user_id
-- movie_id
-- recommendation_date: 2024-01-01 ~ 2025-12-31							-- cf. watch_history 테이블의 watch_date와 동일
-- recommendation_type: new_releases, genre_based, personalized, trending, similar_users
-- recommendation_score: 추천 적합도 점수 0.1 ~ 1
-- was_clicked: 추천 콘텐츠 클릭 여부
-- position_in_list: 추천 목록 내 해당 콘텐츠 위치 1 ~ 20
-- device_type: 추천을 표시받은 기기 Tablet, Mobile, Smart TV, Laptop		-- cf. watch_history 테이블의 device_type은 Tablet, Laptop, Desktop, Smart TV, Mobile
-- time_of_day: 추천이 표시된 시간대 morning, afternoon, evening, night
-- algorithm_version: 추천을 생성한 알고리즘의 버전 v1.4, v1.2, v1.3, v2.0

-- recommendation_type 항목 확인
SELECT	DISTINCT recommendation_type
  FROM	recommendation_logs;
  
-- position_in_list 항목 확인
SELECT	DISTINCT position_in_list
  FROM	recommendation_logs
 ORDER
	BY  1;
  
-- device_type 항목 확인
SELECT	DISTINCT device_type
  FROM	recommendation_logs;
  
-- time_of_day 항목 확인
SELECT	DISTINCT time_of_day
  FROM	recommendation_logs;
  
-- algorithm_version 항목 확인
SELECT	DISTINCT algorithm_version
  FROM	recommendation_logs;

-- recommendation_date의 min, max 확인
SELECT	MIN(recommendation_date), MAX(recommendation_date)
  FROM	recommendation_logs;

-- recommendation_score의 min, max 확인
SELECT	MIN(recommendation_score), MAX(recommendation_score)
  FROM	recommendation_logs;

-- recommendation_id 중복 여부 확인
SELECT	COUNT(*) as cnt
		,COUNT(recommendation_id) as recommendation_cnt_not_distinct
		,COUNT(DISTINCT recommendation_id) as recommendation_cnt
  FROM  recommendation_logs;
-- cnt 52000
-- recommendation_cnt_not_distinct 52000
-- recommendation_cnt 50000
-- 추천 기록은 50000건이고 중복이 있음

SELECT	recommendation_id, COUNT(*)
  FROM	recommendation_logs
 GROUP
   BY   recommendation_id
HAVING  COUNT(*) >= 2;
-- 결과: 중복된 recommendation_id 목록 + 각 recommendation_id의 등장 횟수

-- 예시 데이터 확인
SELECT	*
  FROM	recommendation_logs
 WHERE  recommendation_id = 'rec_000070';
 
SELECT COUNT(*)
FROM (
	SELECT	recommendation_id, COUNT(*)
	  FROM	recommendation_logs
	 GROUP
        BY  recommendation_id
	HAVING  COUNT(*) >= 2
) AS recommendation_duplicate;
-- 중복된 추천 기록은 1964건. 그 중 대부분은 2회 등장(1회 중복).
-- 중복 처리 필요!

-- user_id 확인
SELECT	COUNT(*) as cnt
		,COUNT(user_id) as user_cnt_not_distinct
		,COUNT(DISTINCT user_id) as user_cnt
  FROM  recommendation_logs;
-- cnt 52000
-- user_cnt_not_distinct 52000
-- user_cnt 9921
-- 사용자는 총 10000명이고 recommendation_logs 테이블에는 사용자가 9921명 있음.

-- movie_id 확인
SELECT	COUNT(*) as cnt
		,COUNT(movie_id) as movie_cnt_not_distinct
		,COUNT(DISTINCT movie_id) as movie_cnt
  FROM  recommendation_logs;
-- cnt 52000
-- movie_cnt_not_distinct 52000
-- movie_cnt 1000
-- 영화가 총 1000편이고 recommendation_logs 테이블에도 영화가 1000편이 있으니 -> 모든 영화는 1회 이상 추천됨.


/* search_logs */
SELECT * FROM search_logs LIMIT 10;
-- search_id
-- user_id
-- search_query: 검색어
-- search_date: 2024-01-01 ~ 2025-12-31					-- cf. watch_history 테이블의 watch_date와 동일, recommendation_logs 테이블의 recommendatioin_date와 동일
-- results_returned: 검색 결과 수 0 ~ 100
-- clicked_result_position: 클릭한 결과의 위치 1 ~ 10
-- device_type: Tablet, Mobile, Laptop, Smart TV		-- cf. watch_history 테이블의 device_type은 Tablet, Laptop, Desktop, Smart TV, Mobile / recommendation_logs 테이블의 device_type과는 동일
-- search_duration_seconds: 검색 소요 시간 0.2 ~ 126.8
-- had_typo: 오타 여부
-- used_filters: 필터 사용 여부
-- location_country: 검색 수행한 국가 Canada, USA

-- device_type 항목 확인
SELECT	DISTINCT device_type
  FROM	search_logs;

-- location_country 항목 확인
SELECT	DISTINCT location_country
  FROM	search_logs;
  
-- search_date의 min, max 확인
SELECT	MIN(search_date), MAX(search_date)
  FROM	search_logs;

-- results_returned의 min, max 확인
SELECT	MIN(results_returned), MAX(results_returned)
  FROM	search_logs;
  
-- clicked_result_position의 min, max 확인
SELECT	MIN(clicked_result_position), MAX(clicked_result_position)
  FROM	search_logs;
  
-- search_duration_seconds의 min, max 확인
SELECT	MIN(search_duration_seconds), MAX(search_duration_seconds)
  FROM	search_logs;
  
-- search_id 중복 여부 확인
SELECT	COUNT(*) as cnt
		,COUNT(search_id) as search_cnt_not_distinct
		,COUNT(DISTINCT search_id) as search_cnt
  FROM  search_logs;
-- cnt 26500
-- search_cnt_not_distinct 26500
-- search_cnt 25000
-- 검색 기록은 25000건이고 중복이 있음

SELECT	search_id, COUNT(*)
  FROM	search_logs
 GROUP
   BY   search_id
HAVING  COUNT(*) >= 2;
-- 결과: 중복된 search_id 목록 + 각 search_id의 등장 횟수

-- 예시 데이터 확인
SELECT	*
  FROM	search_logs
 WHERE  search_id = 'search_000009';
 
SELECT COUNT(*)
FROM (
	SELECT	search_id, COUNT(*)
	  FROM	search_logs
	 GROUP
        BY  search_id
	HAVING  COUNT(*) >= 2
) AS search_duplicate;
-- 중복된 검색 기록은 1458건. 그 중 대부분은 2회 등장(1회 중복).
-- 중복 처리 필요!

-- user_id 확인
SELECT	COUNT(*) as cnt
		,COUNT(user_id) as user_cnt_not_distinct
		,COUNT(DISTINCT user_id) as user_cnt
  FROM  search_logs;
-- cnt 26500
-- user_cnt_not_distinct 26500
-- user_cnt 9186
-- 사용자는 총 10000명이고 search_logs 테이블에는 사용자가 9186명 있음.

-- NULL이 많이 보이는 컬럼에 대해 결측값 개수 확인
SELECT	COUNT(*) AS total_rows,
		COUNT(*) - COUNT(clicked_result_position) AS clicked_result_position_missing,
        COUNT(*) - COUNT(search_duration_seconds) AS search_duration_seconds_missing
  FROM  search_logs; 
-- total_rows 26500
-- clicked_result_position_missing 13549
-- search_duration_seconds 1277

-- 결측값 비율 확인  
SELECT	(COUNT(*) - COUNT(clicked_result_position)) / COUNT(*) * 100 AS clicked_result_position_missing_pct,
		(COUNT(*) - COUNT(search_duration_seconds)) / COUNT(*) * 100 AS search_duration_seconds_missing_pct
  FROM  search_logs;
-- 51.1283
-- 4.8189

/* reviews */
SELECT * FROM reviews LIMIT 10;
-- review_id
-- user_id
-- movie_id
-- rating: 사용자 평점 1 ~ 5										-- cf. watch_history 테이블의 user_rating
-- review_date: 2024-01-01 ~ 2025-12-31 						-- cf. watch_history.watch_date, recommendation_logs.recommendatioin_date, search_logs.search_date와 동일
-- device_type: 리뷰 작성한 기기 Mobile, Tablet, Smart TV, Laptop	-- cf. watch_history.device_type은 Tablet, Laptop, Desktop, Smart TV, Mobile / recommendation_logs.device_type, search_logs.device_type과는 동일
-- is_verified_watch: 사용자가 실제로 시청했는지 여부
-- helpful_votes: 다른 사용자가 해당 리뷰를 '도움됨'으로 표시한 수 1 ~ 13
-- total_votes: 다른 사용자가 리뷰에 대해 평가한 총 투표 수 1 ~ 16
-- review_text
-- sentiment: 리뷰 내용의 감성 분류 positive, neutral, negative
-- sentiment_score: 감성 점수 0.001 ~ 1

-- device_type 항목 확인
SELECT	DISTINCT device_type
  FROM	reviews;
  
-- sentiment 항목 확인
SELECT	DISTINCT sentiment
  FROM	reviews;

-- rating의 min, max 확인
SELECT	MIN(rating), MAX(rating)
  FROM	reviews;
  
-- review_date의 min, max 확인
SELECT	MIN(review_date), MAX(review_date)
  FROM	reviews;
  
-- helpful_votes의 min, max 확인
SELECT	MIN(helpful_votes), MAX(helpful_votes)
  FROM	reviews;
  
-- total_votes의 min, max 확인
SELECT	MIN(total_votes), MAX(total_votes)
  FROM	reviews;
  
-- sentiment_score의 min, max 확인
SELECT	MIN(sentiment_score), MAX(sentiment_score)
  FROM	reviews;

-- review_id 중복 여부 확인
SELECT	COUNT(*) as cnt
		,COUNT(review_id) as review_cnt_not_distinct
		,COUNT(DISTINCT review_id) as review_cnt
  FROM  reviews;
-- cnt 15450
-- review_cnt_not_distinct 15450
-- review_cnt 15000
-- 후기는 15000건이고 중복이 있음

SELECT	review_id, COUNT(*)
  FROM	reviews
 GROUP
   BY   review_id
HAVING  COUNT(*) >= 2;
-- 결과: 중복된 review_id 목록 + 각 review_id의 등장 횟수

-- 예시 데이터 확인
SELECT	*
  FROM	reviews
 WHERE  review_id = 'review_000016';
 
SELECT COUNT(*)
FROM (
	SELECT	review_id, COUNT(*)
	  FROM	reviews
	 GROUP
        BY  review_id
	HAVING  COUNT(*) >= 2
) AS review_duplicate;
-- 중복된 후기는 447건. 그 중 대부분은 2회 등장(1회 중복).
-- 중복 처리 필요!

-- user_id 확인
SELECT	COUNT(*) as cnt
		,COUNT(user_id) as user_cnt_not_distinct
		,COUNT(DISTINCT user_id) as user_cnt
  FROM  reviews;
-- cnt 15450
-- user_cnt_not_distinct 15450
-- user_cnt 7761
-- 사용자는 총 10000명이고 reviews 테이블에는 사용자가 7761명 있음.

-- movie_id 확인
SELECT	COUNT(*) as cnt
		,COUNT(movie_id) as movie_cnt_not_distinct
		,COUNT(DISTINCT movie_id) as movie_cnt
  FROM  reviews;
-- cnt 15450
-- movie_cnt_not_distinct 15450
-- movie_cnt 1000
-- 영화가 총 1000편이고 reviews 테이블에도 영화가 1000편이 있으니 -> 모든 영화에 대해 1회 이상 후기가 작성됨.

-- NULL이 있는 컬럼에 대해 결측값 개수 확인
SELECT	COUNT(*) AS total_rows,
		COUNT(*) - COUNT(sentiment_score) AS sentiment_score_missing
  FROM  reviews; 
-- total_rows 15450
-- sentiment_score_missing 1214

-- 결측값 비율 확인  
SELECT	(COUNT(*) - COUNT(sentiment_score)) / COUNT(*) * 100 AS sentiment_score_missing_pct
  FROM  reviews;
-- 7.8576