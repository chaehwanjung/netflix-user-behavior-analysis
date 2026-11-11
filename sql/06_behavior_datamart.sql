/* 그룹별 집계 결과를 바탕으로 사용자 행동 지표 설계 -> 사용자 행동 summary 테이블들 생성 */

-- 시청: 시청 세션 수, 총 시청 시간, 평균 시청 시간, 평균 시청 완료율, 최근 시청일
-- watch_history -> user_watch_summary
CREATE TABLE user_watch_summary AS
SELECT  user_id,
		COUNT(session_id) as total_watch_cnt,
        SUM(watch_duration_minutes) as total_watch_minutes,
        AVG(watch_duration_minutes) as avg_watch_minutes,
        AVG(progress_percentage) as avg_watch_pct,
        MAX(watch_date) as last_watch_date
  FROM  clean_watch_history
 GROUP
    BY  user_id;
    
SELECT  COUNT(*)
  FROM  user_watch_summary;
-- 10000
  
SELECT  *
  FROM  user_watch_summary
 LIMIT  10;
 

-- 콘텐츠 소비: 소비 장르 수, 오리지널 콘텐츠 시청 비율, 평균 시청 콘텐츠 길이
-- watch_history + movies -> user_watch_movie_summary
CREATE TABLE user_watch_movie_summary AS
SELECT  w.user_id,
		COUNT(DISTINCT m.genre_primary) AS watch_genre_cnt,
        SUM(m.is_netflix_original) / COUNT(*) AS watch_original_ratio,
        AVG(m.duration_minutes) AS avg_watch_runtime
  FROM  clean_watch_history w
 INNER
  JOIN  clean_movies m
	ON  m.movie_id = w.movie_id
 GROUP
    BY  user_id;
    
SELECT  COUNT(*)
  FROM  user_watch_movie_summary;
-- 10000
  
SELECT  *
  FROM  user_watch_movie_summary
 LIMIT  10;


-- 추천 반응: 추천 콘텐츠 클릭률
-- recommendatioin_logs -> user_recommendation_summary
CREATE TABLE user_recommendation_summary AS
SELECT  user_id,
		SUM(was_clicked) / COUNT(*) AS recommendation_ctr
  FROM  clean_recommendation_logs
 GROUP
    BY  user_id;

SELECT  COUNT(*)
  FROM  user_recommendation_summary;
-- 9921
  
SELECT  *
  FROM  user_recommendation_summary
 LIMIT  10;


-- 검색: 검색 횟수, 검색 후 클릭률
-- search_logs -> user_search_summary
CREATE TABLE user_search_summary AS
SELECT  user_id,
		COUNT(search_id) AS total_search_cnt,
		SUM(clicked_result_position IS NOT NULL) / COUNT(*) AS search_ctr
  FROM  clean_search_logs
 GROUP
    BY  user_id;
    
SELECT  COUNT(*)
  FROM  user_search_summary;
-- 9186

SELECT  *
  FROM  user_search_summary
 LIMIT  10;
 

-- 참여: 리뷰 작성 횟수, 평균 리뷰 평점
-- reviews -> user_review_summary
CREATE TABLE user_review_summary AS
SELECT  user_id,
		COUNT(review_id) AS total_review_cnt,
		AVG(rating) AS avg_review_rating
  FROM  clean_reviews
 GROUP
    BY  user_id;

SELECT  COUNT(*)
  FROM  user_review_summary;
-- 7761
  
SELECT  *
  FROM  user_review_summary
 LIMIT  10;
 

/* clean_users에 사용자 행동 summary 테이블을 통합해 사용자 행동 통합 데이터마드(DM) 생성 */
CREATE TABLE user_activity_summary AS
SELECT  u.user_id,
		u.age,
		u.gender,
		u.country,
		u.subscription_plan,
		u.is_active,
		u.monthly_spend,
		u.primary_device,
		u.household_size,
		u.created_at,

		w.total_watch_cnt,
		w.total_watch_minutes,
		w.avg_watch_minutes,
		w.avg_watch_pct,
		w.last_watch_date,
    
		wm.watch_genre_cnt,
		wm.watch_original_ratio,
		wm.avg_watch_runtime,

		r.recommendation_ctr,
    
		s.total_search_cnt,
		s.search_ctr,

		rv.total_review_cnt,
		rv.avg_review_rating

  FROM  clean_users u
  LEFT JOIN user_watch_summary w ON u.user_id = w.user_id
  LEFT JOIN user_watch_movie_summary wm ON u.user_id = wm.user_id
  LEFT JOIN user_search_summary s ON u.user_id = s.user_id
  LEFT JOIN user_recommendation_summary r ON u.user_id = r.user_id
  LEFT JOIN user_review_summary rv ON u.user_id = rv.user_id;
  
SELECT  COUNT(*)
  FROM  user_activity_summary;
-- 10000
  
SELECT  *
  FROM  user_activity_summary
 LIMIT  10;