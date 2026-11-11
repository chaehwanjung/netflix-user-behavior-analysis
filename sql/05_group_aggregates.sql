-- 1차 정제한 테이블 기준으로 그룹별 집계

/* users */
SELECT * FROM clean_users;

-- subscription_plan별 사용자 수
SELECT  subscription_plan, COUNT(user_id) as user_cnt
  FROM  clean_users
 GROUP
    BY  subscription_plan;
-- Basic	1966
-- Standard	3522
-- Premium	3507
-- PremiumPlus	1005

-- is_active별(0/1) 사용자 수
SELECT  is_active, COUNT(user_id) as user_cnt
  FROM  clean_users
 GROUP
    BY  is_active;
-- 1	8519
-- 0	1481

-- primary_device별 사용자 수
SELECT  primary_device, COUNT(user_id) as user_cnt
  FROM  clean_users
 GROUP
    BY  primary_device;
-- Laptop	1662
-- Desktop	1751
-- Gaming Console	1626
-- Tablet	1685
-- Mobile	1609
-- Smart TV	1667

-- household_size별 사용자 수
SELECT  household_size, COUNT(user_id) as user_cnt
  FROM  clean_users
 GROUP
    BY  household_size
 ORDER
    BY  household_size;
-- 1	1667
-- 2	4082
-- 3	1663
-- 4	1311
-- 5	677
-- 6	364
-- 7	166
-- 8	70


-- 사용자별 월 평균 지출액
SELECT  user_id, monthly_spend
  FROM  clean_users;

-- 사용자별 월 평균 지출액의 min, max
SELECT  MIN(monthly_spend), MAX(monthly_spend)
  FROM  clean_users;
-- 최소 0.11, 최대 94.09

-- monthly_spend 20단위 별 사용자 수
SELECT  CASE WHEN monthly_spend <= 20 THEN '0-20'
			 WHEN monthly_spend <= 40 THEN '20-40'
             WHEN monthly_spend <= 60 THEN '40-60'
			 WHEN monthly_spend <= 80 THEN '60-80'
			 WHEN monthly_spend <= 100 THEN '80-100'
		 END as monthly_spend,
		 COUNT(user_id) as user_cnt
  FROM  clean_users
 GROUP
    BY  1
 ORDER
    BY  1;
-- 0-20		7393
-- 20-40	2175
-- 40-60	290
-- 60-80	36
-- 80-100	106

/* watch_history + movies */
SELECT * FROM clean_movies;
SELECT * FROM clean_watch_history;

-- 사용자별 content_type (문자열 집계)
SELECT  w.user_id,
		GROUP_CONCAT(DISTINCT m.content_type) as content_type
  FROM  clean_watch_history w
 INNER
  JOIN  clean_movies m
	ON  m.movie_id = w.movie_id
 GROUP
    BY  user_id;

-- 시청 content_type 조합별 사용자 수
SELECT  content_type, COUNT(user_id) as user_cnt
  FROM  (
		SELECT  w.user_id,
				GROUP_CONCAT(DISTINCT m.content_type) as content_type
		  FROM  clean_watch_history w
		 INNER
		  JOIN  clean_movies m
			ON  m.movie_id = w.movie_id
		 GROUP
			BY  user_id
) AS c
 GROUP
    BY  content_type
 ORDER
    BY  content_type;
 
 
-- 사용자별 소비 장르 수
SELECT  w.user_id,
		COUNT(DISTINCT m.genre_primary) as genre_diversity_cnt
  FROM  clean_watch_history w
 INNER
  JOIN  clean_movies m
	ON  m.movie_id = w.movie_id
 GROUP
    BY  user_id;

-- 소비 장르 수별 사용자 수
SELECT  genre_diversity_cnt, COUNT(user_id) as user_cnt
  FROM  (
		SELECT  w.user_id,
				COUNT(DISTINCT m.genre_primary) as genre_diversity_cnt
		  FROM  clean_watch_history w
		 INNER
		  JOIN  clean_movies m
			ON  m.movie_id = w.movie_id
		 GROUP
			BY  user_id
) AS g
 GROUP
    BY  1
 ORDER
    BY  1;
-- 1~16가지 장르 시청, 6~10가지 시청하는 사용자 많음


-- 사용자별 오리지널 콘텐츠 시청 비율
SELECT  w.user_id,
        SUM(m.is_netflix_original) / COUNT(*) as original_ratio
  FROM  clean_watch_history w
 INNER
  JOIN  clean_movies m
	ON  m.movie_id = w.movie_id
 GROUP
    BY  user_id;

-- 오리지널 콘텐츠 시청 비율 10%단위별 사용자 수
SELECT  CASE WHEN original_ratio = 0 THEN '0%'
			 WHEN original_ratio <= 10 THEN '0-10%'
             WHEN original_ratio <= 20 THEN '10-20%'
             WHEN original_ratio <= 30 THEN '20-30%'
             WHEN original_ratio <= 40 THEN '30-40%'
             WHEN original_ratio <= 50 THEN '40-50%'
             WHEN original_ratio <= 60 THEN '50-60%'
             WHEN original_ratio <= 70 THEN '60-70%'
             WHEN original_ratio <= 80 THEN '70-80%'
             WHEN original_ratio <= 90 THEN '80-90%'
			 ELSE '90-100%'
		 END as original_ratio,
         COUNT(user_id)
  FROM  (
		SELECT  w.user_id,
				SUM(m.is_netflix_original) / COUNT(*) * 100 as original_ratio
		  FROM  clean_watch_history w
		 INNER
	 	  JOIN  clean_movies m
			ON  m.movie_id = w.movie_id
	 	 GROUP
			BY  user_id
) AS o
 GROUP
    BY  1
 ORDER
    BY  1;
-- 0%		464
-- 0-10%	374
-- 10-20%	1919
-- 20-30%	2450
-- 30-40%	2399
-- 40-50%	1607
-- 50-60%	485
-- 60-70%	206
-- 70-80%	73
-- 80-90%	15
-- 90-100%	8
		

-- 사용자별 평균 시청 콘텐츠 길이
SELECT  w.user_id,
        AVG(m.duration_minutes) as avg_runtime
  FROM  clean_watch_history w
 INNER
  JOIN  clean_movies m
	ON  m.movie_id = w.movie_id
 GROUP
    BY  user_id;

-- 평균 시청 콘텐츠 길이 60분 단위별 사용자 수
SELECT  CASE WHEN avg_runtime <= 60 THEN '1시간 이하'
			 WHEN avg_runtime <= 120 THEN '1-2시간'
             WHEN avg_runtime <= 180 THEN '2-3시간'
             WHEN avg_runtime <= 240 THEN '3-4시간'
		 END as avg_runtime,
		 COUNT(user_id) as user_cnt
  FROM  (
		SELECT  w.user_id,
				AVG(m.duration_minutes) as avg_runtime
		  FROM  clean_watch_history w
		 INNER
		  JOIN  clean_movies m
		    ON  m.movie_id = w.movie_id
		 GROUP
			BY  user_id
) AS r
 GROUP
    BY  1
 ORDER
    BY  1;
-- 1시간 이하	363
-- 1-2시간	9279
-- 2-3시간	355
-- 3-4시간	3

/* watch_history */
SELECT * FROM clean_watch_history;

-- 사용자별 시청 세션 수
SELECT  user_id, COUNT(session_id) as session_cnt
  FROM  clean_watch_history
 GROUP
    BY  user_id;

-- 세션 수별 사용자 수
SELECT s.session_cnt, COUNT(s.user_id) as user_cnt
  FROM  (
		SELECT  user_id, COUNT(session_id) as session_cnt
		  FROM  clean_watch_history
		 GROUP
			BY  user_id
) AS s
 GROUP
    BY  s.session_cnt
 ORDER
    BY  1;
-- 세션 수는 2~23 까지 있고, 7~12 세션을 보는 사용자가 많음 (정규분포 형태)


-- 사용자별 최근 시청일
SELECT  user_id, MAX(watch_date) as last_watch_date
  FROM  clean_watch_history
 GROUP
    BY  user_id;

-- 사용자별 최근 시청 월
SELECT  user_id, DATE_FORMAT(MAX(watch_date), '%Y-%m') as last_watch_month
  FROM  clean_watch_history
 GROUP
    BY  user_id;

-- 최근 시청 월별 사용자 수
SELECT  last_watch_month, COUNT(user_id) as user_cnt
  FROM  (
		SELECT  user_id, DATE_FORMAT(MAX(watch_date), '%Y-%m') as last_watch_month
		  FROM  clean_watch_history
		 GROUP
		    BY  user_id
) AS m
 GROUP
	BY  last_watch_month
 ORDER
    BY  1;

-- 최근 시청 분기별 사용자 수 (최근 시청 월을 3개월 단위로 나누어 보기)
SELECT  CASE WHEN q.last_watch_month IN ('2024-04','2024-05','2024-06') THEN '2024-2Q'
			 WHEN q.last_watch_month IN ('2024-07','2024-08','2024-09') THEN '2024-3Q'
             WHEN q.last_watch_month IN ('2024-10','2024-11','2024-12') THEN '2024-4Q'
             WHEN q.last_watch_month IN ('2025-01','2025-02','2025-03') THEN '2025-1Q'
             WHEN q.last_watch_month IN ('2025-04','2025-05','2025-06') THEN '2025-2Q'
             WHEN q.last_watch_month IN ('2025-07','2025-08','2025-09') THEN '2025-3Q'
             WHEN q.last_watch_month IN ('2025-10','2025-11','2025-12') THEN '2025-4Q' END AS last_watch_quarter,
         SUM(user_cnt) as user_sum   
  FROM  (
		SELECT  last_watch_month, COUNT(user_id) as user_cnt
		  FROM  (
				SELECT  user_id, DATE_FORMAT(MAX(watch_date), '%Y-%m') as last_watch_month
				  FROM  clean_watch_history
				 GROUP
					BY  user_id
		) AS m
		 GROUP
			BY  last_watch_month
		 ORDER
			BY  1
) AS q
 GROUP
    BY  last_watch_quarter;
-- 2024-2Q	6
-- 2024-3Q	23
-- 2024-4Q	42
-- 2025-1Q	184
-- 2025-2Q	585
-- 2025-3Q	1963
-- 2025-4Q	7197


-- 사용자별 총 시청 시간
SELECT  user_id, SUM(watch_duration_minutes) as watch_minutes_sum
  FROM  clean_watch_history
 GROUP
    BY  user_id;

-- 사용자별 총 시청 시간의 min, max
SELECT  MIN(watch_minutes_sum), MAX(watch_minutes_sum)
  FROM  (
		SELECT  user_id, SUM(watch_duration_minutes) as watch_minutes_sum
		  FROM  clean_watch_history
		 GROUP
			BY  user_id
) AS w;
-- 최소 5.5, 최대 1885.0

-- 총 시청 시간 5시간 단위별 사용자 수
SELECT  CASE WHEN watch_minutes_sum <= 300 THEN '00-05시간'
             WHEN watch_minutes_sum <= 600 THEN '05-10시간'
             WHEN watch_minutes_sum <= 900 THEN '10-15시간'
             WHEN watch_minutes_sum <= 1200 THEN '15-20시간'
             WHEN watch_minutes_sum <= 1800 THEN '20-25시간'
             WHEN watch_minutes_sum <= 2400 THEN '25-30시간'
             ELSE '30시간 이상'
		 END AS watch_minutes_sum,
		 COUNT(user_id) as user_cnt
  FROM  (
	    SELECT  user_id, SUM(watch_duration_minutes) as watch_minutes_sum
		  FROM  clean_watch_history
	     GROUP
		    BY  user_id
) w
 GROUP
    BY  1
 ORDER
    BY  1;


-- 사용자별 평균 시청 시간
SELECT  user_id, AVG(watch_duration_minutes) as watch_minutes_avg
  FROM  clean_watch_history
 GROUP
    BY  user_id;

-- 사용자별 평균 시청 시간의 min, max
SELECT  MIN(watch_minutes_avg), MAX(watch_minutes_avg)
  FROM  (
		SELECT  user_id, AVG(watch_duration_minutes) as watch_minutes_avg
		  FROM  clean_watch_history
		 GROUP
			BY  user_id
) AS w;
-- 최소 2.75, 최대 188

-- 평균 시청 시간 1시간 단위별 사용자 수
SELECT  CASE WHEN watch_minutes_avg <= 60 THEN '00-01시간'
			 WHEN watch_minutes_avg <= 120 THEN '01-02시간'
             WHEN watch_minutes_avg <= 180 THEN '02-03시간'
             WHEN watch_minutes_avg <= 240 THEN '03-04시간'
		 END AS watch_minutes_avg,
		 COUNT(user_id) as user_cnt
  FROM  (
	    SELECT  user_id, AVG(watch_duration_minutes) as watch_minutes_avg
		  FROM  clean_watch_history
	     GROUP
		    BY  user_id
) w
 GROUP
    BY  1
 ORDER
    BY  1;
-- 00-01시간	5088
-- 01-02시간	4874
-- 02-03시간	37
-- 03-04시간	1

-- 사용자별 평균 완료율
SELECT  user_id, AVG(progress_percentage) as progress_percentage_avg
  FROM  clean_watch_history
 GROUP
    BY  user_id;

-- 사용자별 평균 완료율의 min, max
SELECT  MIN(progress_percentage_avg), MAX(progress_percentage_avg)
  FROM  (
		SELECT  user_id, AVG(progress_percentage) as progress_percentage_avg
		  FROM  clean_watch_history
		 GROUP
			BY  user_id
) AS w;
-- 최소 1.95000, 최대 90.82000

-- 평균 완료율 20% 단위별 사용자 수
SELECT  CASE WHEN progress_percentage_avg <= 20 THEN '0-20%'
			 WHEN progress_percentage_avg <= 40 THEN '20-40%'
             WHEN progress_percentage_avg <= 60 THEN '40-60%'
             WHEN progress_percentage_avg <= 80 THEN '60-80%'
             ELSE '80% 초과'
		 END AS progress_percentage_avg,
		 COUNT(user_id) as user_cnt
  FROM  (
	    SELECT  user_id, AVG(progress_percentage) as progress_percentage_avg
		  FROM  clean_watch_history
	     GROUP
		    BY  user_id
) w
 GROUP
    BY  1
 ORDER
    BY  1;
-- 0-20%	9
-- 20-40%	1382
-- 40-60%	7241
-- 60-80%	1352
-- 80% 초과	16


-- device_type별 사용자 수(중복 제거)
SELECT  device_type, COUNT(DISTINCT user_id) as user_cnt
  FROM  clean_watch_history
 GROUP
    BY  device_type;
-- Tablet	8665
-- Laptop	8602
-- Smart TV	8624
-- Mobile	8654
-- Desktop	8656

-- action별 사용자 수(중복 제거)
SELECT  action, COUNT(DISTINCT user_id) as user_cnt
  FROM  clean_watch_history
 GROUP
    BY  action;
-- started	  9217
-- paused	  9185
-- stopped    9167
-- completed  9191

-- is_download별 사용자 수(중복 제거)
SELECT  is_download, COUNT(DISTINCT user_id) as user_cnt
  FROM  clean_watch_history
 GROUP
    BY  is_download;
-- 0	9998
-- 1	8652


/* recommendation_logs */
SELECT * FROM clean_recommendation_logs;

-- 사용자별 추천 노출 수
SELECT  user_id, COUNT(recommendation_id) as recm_cnt
  FROM  clean_recommendation_logs
 GROUP
    BY  user_id;

-- 추천 노출 수별 사용자 수
SELECT r.recm_cnt, COUNT(r.user_id) as user_cnt
  FROM  (
		SELECT  user_id, COUNT(recommendation_id) as recm_cnt
		  FROM  clean_recommendation_logs
		 GROUP
			BY  user_id
) AS r
 GROUP
    BY  1
 ORDER
    BY  1;
-- 한 사용자 당 1~17회 추천이 이루어졌고, 3~7회 받은 사용자 많음


-- 사용자별 추천 클릭률 (클릭 수 / 노출 수)
SELECT  user_id, SUM(was_clicked) / COUNT(recommendation_id) as recm_click_pct
  FROM  clean_recommendation_logs
 GROUP
    BY  user_id;

-- 사용자별 추천 클릭률의 min, max
SELECT  MIN(recm_click_pct), MAX(recm_click_pct)
  FROM  (
		SELECT  user_id, SUM(was_clicked) / COUNT(recommendation_id) as recm_click_pct
		  FROM  clean_recommendation_logs
		 GROUP
			BY  user_id
) AS r;
-- 최소 0, 최대 1

-- 추천 클릭률 10% 단위별 사용자 수
SELECT  CASE WHEN recm_click_pct <= 10 THEN '0-10%'
			 WHEN recm_click_pct <= 20 THEN '10-20%'
             WHEN recm_click_pct <= 30 THEN '20-30%'
             WHEN recm_click_pct <= 40 THEN '30-40%'
             WHEN recm_click_pct <= 50 THEN '40-50%'
             WHEN recm_click_pct <= 60 THEN '50-60%'
             WHEN recm_click_pct <= 70 THEN '60-70%'
             WHEN recm_click_pct <= 80 THEN '70-80%'
             WHEN recm_click_pct <= 90 THEN '80-90%'
             WHEN recm_click_pct <= 100 THEN '90-100%'
		 END AS recm_click_pct,
		 COUNT(user_id) as user_cnt
  FROM  (
	    SELECT  user_id, SUM(was_clicked) / COUNT(recommendation_id) * 100 as recm_click_pct
		  FROM  clean_recommendation_logs
	     GROUP
		    BY  user_id
) r
 GROUP
    BY  1
 ORDER
    BY  1;
-- 0-10%	4726
-- 10-20%	2166
-- 20-30%	1181
-- 30-40%	1078
-- 40-50%	513
-- 50-60%	58
-- 60-70%	87
-- 70-80%	26
-- 80-90%	3
-- 90-100%	83


/* search_logs */
SELECT * FROM clean_search_logs;

-- 사용자별 검색 횟수
SELECT  user_id, COUNT(search_id) as search_cnt
  FROM  clean_search_logs
 GROUP
    BY  user_id;

-- 검색 횟수별 사용자 수
SELECT s.search_cnt, COUNT(s.user_id) as user_cnt
  FROM  (
		SELECT  user_id, COUNT(search_id) as search_cnt
		  FROM  clean_search_logs
		 GROUP
			BY  user_id
) AS s
 GROUP
    BY  1
 ORDER
    BY  1;
-- 1	2108
-- 2	2545
-- 3	2102
-- 4	1293
-- 5	687
-- 6	315
-- 7	95
-- 8	35
-- 9	6


-- 사용자별 평균 검색 소요 시간
SELECT  user_id, COUNT(search_duration_seconds) as search_sec
  FROM  clean_search_logs
 GROUP
    BY  user_id;

-- 평균 검색 소요 시간 초단위별 사용자 수
SELECT s.search_sec, COUNT(s.user_id) as user_cnt
  FROM  (
		SELECT  user_id, COUNT(search_duration_seconds) as search_sec
		  FROM  clean_search_logs
		 GROUP
		    BY  user_id
) AS s
 GROUP
    BY  1
 ORDER
    BY  1;
-- 1	2108
-- 2	2545
-- 3	2102
-- 4	1293
-- 5	687
-- 6	315
-- 7	95
-- 8	35
-- 9	6


-- 검색 후 클릭 여부별 사용자 수(중복 제거)
-- clicked_result_postion의 NULL 여부
SELECT  CASE WHEN clicked_result_position IS NOT NULL THEN 1 ELSE 0 END as search_clicked,
		COUNT(DISTINCT user_id) as user_cnt
  FROM  clean_search_logs
 GROUP
    BY 1;
-- 0(클릭 안 한 사람)	7168
-- 1(클릭 한 사람)		7072

-- 사용자별 검색 후 클릭 경험 횟수 합계
SELECT  s.user_id, SUM(search_clicked) as search_clicked
  FROM  (
		SELECT  CASE WHEN clicked_result_position IS NOT NULL THEN 1 ELSE 0 END as search_clicked,
				user_id
		  FROM  clean_search_logs
) AS s
 GROUP
    BY  s.user_id;

-- 검색 후 클릭 경험 횟수별 사용자 수
SELECT  c.search_clicked_sum, COUNT(user_id) as user_cnt
  FROM  (
		SELECT  s.user_id, SUM(search_clicked) as search_clicked_sum
		  FROM  (
				SELECT  CASE WHEN clicked_result_position IS NOT NULL THEN 1 ELSE 0 END as search_clicked,
						user_id
				  FROM  clean_search_logs
		) AS s
		 GROUP
			BY  s.user_id
) AS c
 GROUP  
    BY  c.search_clicked_sum
 ORDER
    BY  1;
-- 0	2114   
-- 1	3687
-- 2	2103
-- 3	909
-- 4	280
-- 5	73
-- 6	17
-- 7	2
-- 8	1

-- 사용자별 검색 후 클릭률
SELECT  user_id,
		SUM(clicked_result_position IS NOT NULL) / COUNT(*) AS search_ctr
  FROM  clean_search_logs
 GROUP
    BY  user_id;

-- 검색 후 클릭율 10%단위별 사용자 수
SELECT  CASE WHEN search_ctr = 0 THEN '0%'
			 WHEN search_ctr <= 10 THEN '0-10%'
             WHEN search_ctr <= 20 THEN '10-20%'
             WHEN search_ctr <= 30 THEN '20-30%'
             WHEN search_ctr <= 40 THEN '30-40%'
             WHEN search_ctr <= 50 THEN '40-50%'
             WHEN search_ctr <= 60 THEN '50-60%'
             WHEN search_ctr <= 70 THEN '60-70%'
             WHEN search_ctr <= 80 THEN '70-80%'
             WHEN search_ctr <= 90 THEN '80-90%'
			 ELSE '90-100%'
		 END as search_ctr,
         COUNT(user_id)
  FROM  (
		SELECT  user_id,
				SUM(clicked_result_position IS NOT NULL) / COUNT(*) * 100 AS search_ctr
		  FROM  clean_search_logs
		 GROUP
			BY  user_id
) AS s
 GROUP
    BY  1
 ORDER
	BY  1;
-- 0%		2114
-- 10-20%	158
-- 20-30%	357
-- 30-40%	1148
-- 40-50%	1888
-- 50-60%	236
-- 60-70%	804
-- 70-80%	426
-- 80-90%	37
-- 90-100%	2018
    

-- 검색 시 필터 사용 여부별 사용자 수(중복 제거)
SELECT  used_filters, COUNT(DISTINCT user_id) as user_cnt
  FROM  clean_search_logs
 GROUP
    BY  used_filters;
-- 0	8425
-- 1	4698

-- 사용자별 검색 시 필터 사용 경험 횟수
SELECT  user_id, SUM(used_filters) as used_filter_sum
  FROM  clean_search_logs
 GROUP
    BY  user_id;

-- 검색 시 필터 사용 경험 횟수별 사용자 수
SELECT used_filter_sum, COUNT(user_id)
  FROM  (
		SELECT  user_id, SUM(used_filters) as used_filter_sum
		  FROM  clean_search_logs
		 GROUP
			BY  user_id
) AS f
 GROUP
	BY used_filter_sum;
-- 0	4488
-- 1	3375
-- 2	1045
-- 3	231
-- 4	41
-- 5	5
-- 6	1


/* reviews */
SELECT * FROM clean_reviews;

-- 사용자별 리뷰 작성 횟수
SELECT  user_id, COUNT(review_id) as review_cnt
  FROM  clean_reviews
 GROUP
    BY  user_id;

-- 리뷰 작성 횟수별 사용자 수
SELECT  r.review_cnt, COUNT(user_id) as user_cnt
  FROM  (
		SELECT  user_id, COUNT(review_id) as review_cnt
		  FROM  clean_reviews
		 GROUP
			BY  user_id
) r
 GROUP
    BY  r.review_cnt
 ORDER
    BY  1;
-- 1	3302
-- 2	2588
-- 3	1206
-- 4	477
-- 5	145
-- 6	31
-- 7	11
-- 8	1

-- 사용자별 리뷰 작성 횟수 (시청한 사실이 확인된 사용자에 한해 계산)
-- is_verified_watch = 1
SELECT  user_id, COUNT(review_id) as review_cnt
  FROM  clean_reviews
 WHERE  is_verified_watch = 1
 GROUP
    BY  user_id;

-- 리뷰 작성 횟수별 사용자 수 (시청한 사실이 확인된 사용자에 한해 계산)
SELECT  r.review_cnt, COUNT(user_id) as user_cnt
  FROM  (
		SELECT  user_id, COUNT(review_id) as review_cnt
		  FROM  clean_reviews
		 WHERE  is_verified_watch = 1
		 GROUP
			BY  user_id
) r
 GROUP
    BY  r.review_cnt
 ORDER
    BY  1;
-- 1	3557
-- 2	2244
-- 3	848
-- 4	264
-- 5	71
-- 6	9
-- 7	4
-- 8	1


-- 사용자별 평균 리뷰 평점
SELECT  user_id, AVG(rating) as rating_avg
  FROM  clean_reviews
 GROUP
    BY  user_id;

-- 리뷰 평점별 사용자 수
SELECT  CASE WHEN rating_avg <= 1 THEN '0-1'
			 WHEN rating_avg <= 2 THEN '1-2'
			 WHEN rating_avg <= 3 THEN '2-3'
			 WHEN rating_avg <= 4 THEN '3-4'
			 ELSE '4-5'
		 END as rating_avg,
         COUNT(user_id)
  FROM  (
		SELECT  user_id, AVG(rating) as rating_avg
	  	  FROM  clean_reviews
		 GROUP
			BY  user_id
) AS r
 GROUP
    BY  1
 ORDER
    BY  1;
-- 0-1	175
-- 1-2	475
-- 2-3	1784
-- 3-4	3435
-- 4-5	1892


-- 사용자별 평균 리뷰 감성 점수
-- 0에 가까울수록 negative, 1에 가까울수록 positive
SELECT  user_id, AVG(sentiment_score) as sentiment_score_avg
  FROM  clean_reviews
 GROUP
    BY  user_id;

-- 사용자별 평균 리뷰 감성 점수 (소수점 1자리까지)
SELECT  user_id, ROUND(AVG(sentiment_score), 1) as sentiment_score_avg
  FROM  clean_reviews
 GROUP
    BY  user_id;

-- 평균 감성 점수별 사용자 수
SELECT  s.sentiment_score_avg, COUNT(user_id) as user_cnt
  FROM  (
		SELECT  user_id, ROUND(AVG(sentiment_score), 1) as sentiment_score_avg
		  FROM  clean_reviews
		 GROUP
			BY  user_id
) s
 GROUP
    BY  s.sentiment_score_avg
 ORDER
    BY  1;
-- 0.0	65
-- 0.1	134
-- 0.2	194
-- 0.3	261
-- 0.4	606
-- 0.5	1100
-- 0.6	1400
-- 0.7	1590
-- 0.8	1408
-- 0.9	763
-- 1.0	240