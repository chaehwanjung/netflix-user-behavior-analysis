/* 결측치 확인 및 대체할 값 계산 */

-- monthly_spend 결측 비율
SELECT  COUNT(*) as user_cnt,
		SUM(CASE WHEN monthly_spend IS NULL THEN 1 ELSE 0 END) as monthly_spend_is_null,
        SUM(CASE WHEN monthly_spend IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100 as null_pct
FROM  (
		SELECT DISTINCT *
		FROM raw_users
) r;
-- 9.93%

-- monthly_spend 중앙값
WITH ranked AS (
    SELECT  monthly_spend,
            ROW_NUMBER() OVER (ORDER BY monthly_spend) AS rn,
            COUNT(*) OVER () AS total
      FROM  (
		SELECT DISTINCT *
		FROM raw_users
	) r
     WHERE  monthly_spend IS NOT NULL
)
SELECT  AVG(monthly_spend) AS median_spend
  FROM  ranked
 WHERE  rn IN (FLOOR((total + 1) / 2), FLOOR((total + 2) / 2));
-- 13.56


-- household_size 결측 비율
SELECT  COUNT(*) as user_cnt,
		SUM(CASE WHEN household_size IS NULL THEN 1 ELSE 0 END) as household_size_is_null,
        SUM(CASE WHEN household_size IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100 as null_pct
  FROM  (
		SELECT DISTINCT *
		FROM raw_users
) r;
-- 15%

-- household_size의 최빈값
SELECT household_size
  FROM (
		SELECT DISTINCT *
		FROM raw_users
) r
 WHERE household_size IS NOT NULL
 GROUP
    BY household_size
 ORDER
	BY COUNT(*) DESC
 LIMIT 1;
-- 2

-- 처음 전처리할 때 duration_minutes = 0 이어서 NULL 처리한 행
SELECT  *
  FROM  clean_movies
 WHERE  duration_minutes IS NULL;
-- content_type = 'Limited Series'

-- content_type이 Limited Series인 콘텐츠의 평균 duration_minutes
SELECT  content_type, AVG(duration_minutes) as avg_runtime
  FROM  (
		SELECT DISTINCT *
		FROM raw_movies
) r
 WHERE  content_type = 'Limited Series'
 GROUP  
	BY  content_type;


/* 이상치 확인 및 대체할 값 계산 */

-- monthly_spend 상한값
WITH ranked AS (
    SELECT  monthly_spend,
            NTILE(100) OVER (ORDER BY monthly_spend) AS tile
      FROM  (
		SELECT DISTINCT *
		FROM raw_users
	) r
)
SELECT  MAX(monthly_spend) AS upper_bound
  FROM  ranked
 WHERE  tile = 99;
-- 94.09

-- duration_minutes 300분 이상인 값 비율
SELECT  COUNT(*) as movie_cnt,
		SUM(CASE WHEN duration_minutes > 300 THEN 1 ELSE 0 END) as duration_minutes_outlier,
        SUM(CASE WHEN duration_minutes > 300 THEN 1 ELSE 0 END) / COUNT(*) * 100 as outlier_pct
  FROM  (
		SELECT DISTINCT *
		FROM raw_movies
) r;
-- 2.5%

-- watch_duration_minutes 상한값
WITH ranked AS (
    SELECT 
        watch_duration_minutes,
        NTILE(100) OVER (ORDER BY watch_duration_minutes) AS tile
    FROM (
		SELECT DISTINCT *
		FROM raw_watch_history
	) r
)
SELECT MAX(watch_duration_minutes) AS upper_bound
FROM ranked
WHERE tile = 99;
-- 316.1