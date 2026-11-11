SELECT * FROM user_activity_summary ORDER BY user_id LIMIT 10;

/*
사용자 행동 지표
시청: total_watch_cnt, total_watch_minutes, avg_watch_minutes, avg_watch_pct, last_watch_date
콘텐츠 소비: watch_genre_cnt, watch_original_ratio, avg_watch_runtime
추천 반응: recommendation_ctr
검색: total_search_cnt, search_ctr
참여: total_review_cnt, avg_review_rating

1. 전체 변수에 대한 스크리닝 (평균, 표준편차, max/min, 0 비율 등)
2. 변동이 큰 변수에 대해 분위별 평균 비교 (표준편차가 평균보다 크거나, 0 비율이 높거나, max가 평균 대비 극단적으로 큰 경우 등)
- 분위 자체가 잘 나뉘는지 확인
- 그 분위가 다른 행동도 갈라놓는지 확인
3. 분위가 잘 나뉜 경우
- 다른 행동도 갈라놓는다면 핵심 축 후보로 선정
- 다른 행동을 갈라놓지 않아도 축 후보로 선정
4. 축 후보 변수들 간의 상관관계 확인
- 상관 높으면 하나만 선택
- 상관 낮으면 둘다 축으로 사용 가능

세그먼트 후보 변수: total_watch_minutes, last_watch_date, watch_original_ratio, recommendation_ctr, total_search_cnt, search_ctr, total_review_cnt
- last_watch_date가 최근일수록 total_watch_minutes가 증가
- watch_original_ratio는 대부분 0.1~0.5 사이에 존재
- recommendation_ctr은 표준편차 > 평균
- total_search_cnt, total_review_cnt는 분위가 잘 나눠지지 않지만 의미 상 중요한 지표이기 때문에 상위 25% 사용자를 강조

행동 축 정의
- 소비 강도: total_watch_minutes
- 탐색 방식: recommendation_ctr, total_search_cnt
- 참여: total_review_cnt
- 최근성: last_watch_date
 
세그먼트 설계
- Binge: 시청량이 높은 사용자
- Explorer: 검색을 통해 능동적으로 콘텐츠를 찾는 사용자 / Algorithm Dependent: 추천 시스템에 의존하여 콘텐츠를 소비하는 사용자
- Engaged Critic: 활발히 리뷰를 남기는 사용자
- Dormant User: 일정 기간 이상 활동하지 않은 사용자
*/


/*total_watch_cnt*/
-- 기본 통계 보기
SELECT
    COUNT(*) AS user_cnt,
    AVG(total_watch_cnt) AS avg_watch,
    STDDEV(total_watch_cnt) AS std_watch,
    MIN(total_watch_cnt) AS min_watch,
    MAX(total_watch_cnt) AS max_watch,
    SUM(CASE WHEN total_watch_cnt = 0 THEN 1 ELSE 0 END)/COUNT(*) AS zero_ratio
FROM user_activity_summary;

/* total_watch_minutes */
-- 기본 통계 보기
SELECT
    COUNT(*) AS user_cnt,
    AVG(total_watch_minutes) AS avg_watch,
    STDDEV(total_watch_minutes) AS std_watch,
    MIN(total_watch_minutes) AS min_watch,
    MAX(total_watch_minutes) AS max_watch
FROM user_activity_summary;
-- min/max 차이가 매우 큼

-- 분위수 나눠보기
SELECT *
FROM (
    SELECT
        user_id,
        total_watch_minutes,
        NTILE(4) OVER (ORDER BY total_watch_minutes DESC) AS watch_quartile
    FROM user_activity_summary
) t;

-- 분위별 평균 비교
SELECT
    watch_quartile,
    COUNT(*) AS user_cnt,
    AVG(total_watch_minutes) AS avg_watch,
    AVG(recommendation_ctr) AS avg_reco_ctr,
    AVG(total_search_cnt) AS avg_search,
    AVG(total_review_cnt) AS avg_review
FROM (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY total_watch_minutes DESC) AS watch_quartile
    FROM user_activity_summary
) t
GROUP BY watch_quartile
ORDER BY watch_quartile;

-- 상위 20% vs 하위 20% 비교
SELECT *
FROM (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY total_watch_minutes DESC) AS watch_quintile
    FROM user_activity_summary
) t;

SELECT
    watch_quintile,
    AVG(total_watch_minutes),
    AVG(recommendation_ctr),
    AVG(total_search_cnt),
    AVG(total_review_cnt)
FROM (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY total_watch_minutes DESC) AS watch_quintile
    FROM user_activity_summary
) t
WHERE watch_quintile IN (1,5)
GROUP BY watch_quintile;

/*avg_watch_minutes*/
-- 기본 통계 보기
SELECT
    COUNT(*) AS user_cnt,
    AVG(avg_watch_minutes) AS avg_watch,
    STDDEV(avg_watch_minutes) AS std_watch,
    MIN(avg_watch_minutes) AS min_watch,
    MAX(avg_watch_minutes) AS max_watch
FROM user_activity_summary;

-- 분위별 평균 비교
SELECT
    watch_quartile,
    COUNT(*) AS user_cnt,
    AVG(avg_watch_minutes) AS avg_watch,
    AVG(recommendation_ctr) AS avg_reco_ctr,
    AVG(total_search_cnt) AS avg_search,
    AVG(total_review_cnt) AS avg_review
FROM (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY avg_watch_minutes DESC) AS watch_quartile
    FROM user_activity_summary
) t
GROUP BY watch_quartile
ORDER BY watch_quartile;
-- avg_watch_minutes보다 total_watch_minutes가 분위를 더 잘 나눔

/*avg_watch_pc*/
-- 기본 통계 보기
SELECT
    COUNT(*) AS user_cnt,
    AVG(avg_watch_pct) AS avg_watch,
    STDDEV(avg_watch_pct) AS std_watch,
    MIN(avg_watch_pct) AS min_watch,
    MAX(avg_watch_pct) AS max_watch
FROM user_activity_summary;

/*last_watch_date*/
-- 최근성 계산
SELECT
    user_id,
    last_watch_date,
    DATEDIFF(CURDATE(), last_watch_date) AS days_since_last_watch
FROM user_activity_summary;

-- 변동 확인
SELECT
    AVG(DATEDIFF(CURDATE(), last_watch_date)) AS avg_days_since,
    STDDEV(DATEDIFF(CURDATE(), last_watch_date)) AS std_days_since,
    MIN(DATEDIFF(CURDATE(), last_watch_date)) AS min_days_since,
    MAX(DATEDIFF(CURDATE(), last_watch_date)) AS max_days_since
FROM user_activity_summary;

-- 분위별 평균 비교
SELECT
    watch_quartile,
    COUNT(*) AS user_cnt,
    AVG(days_since_last_watch) AS avg_days,
    AVG(total_watch_minutes) AS avg_watch,
    AVG(recommendation_ctr) AS avg_reco_ctr,
    AVG(total_search_cnt) AS avg_search,
    AVG(total_review_cnt) AS avg_review
FROM (
    SELECT
        *,
        DATEDIFF(CURDATE(), last_watch_date) AS days_since_last_watch,
        NTILE(4) OVER (ORDER BY DATEDIFF(CURDATE(), last_watch_date)) AS watch_quartile
    FROM user_activity_summary
) t
GROUP BY watch_quartile
ORDER BY watch_quartile;
-- last_watch_date가 최근일수록 total_watch_minutes가 증가하는 추세를 보임
-- 56.0756	678.82152
-- 80.4572	637.64980
-- 118.7388	616.80836
-- 223.9556	534.23324

/* watch_genre_cnt */
-- 기본 통계 보기
SELECT
    COUNT(*) AS user_cnt,
    AVG(watch_genre_cnt) AS avg_watch,
    STDDEV(watch_genre_cnt) AS std_watch,
    MIN(watch_genre_cnt) AS min_watch,
    MAX(watch_genre_cnt) AS max_watch
FROM user_activity_summary;

/* watch_original_ratio */
-- 기본 통계 보기
SELECT
    COUNT(*) AS user_cnt,
    AVG(watch_original_ratio) AS avg_watch,
    STDDEV(watch_original_ratio) AS std_watch,
    MIN(watch_original_ratio) AS min_watch,
    MAX(watch_original_ratio) AS max_watch,
    SUM(CASE WHEN watch_original_ratio = 0 THEN 1 ELSE 0 END)/COUNT(*) AS zero_ratio
FROM user_activity_summary;

-- 분위별 평균 비교
SELECT
    watch_quartile,
    COUNT(*) AS user_cnt,
    AVG(watch_original_ratio) AS avg_original,
    AVG(total_watch_minutes) AS avg_watch,
    AVG(recommendation_ctr) AS avg_reco_ctr,
    AVG(total_search_cnt) AS avg_search,
    AVG(total_review_cnt) AS avg_review
FROM (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY watch_original_ratio DESC) AS watch_quartile
    FROM user_activity_summary
) t
GROUP BY watch_quartile
ORDER BY watch_quartile;
-- 대부분 0.1~0.5 사이에 존재
-- 0.50707932
-- 0.34988600
-- 0.24993608
-- 0.11642044

/* avg_watch_runtime */
-- 기본 통계 보기
SELECT
    COUNT(*) AS user_cnt,
    AVG(avg_watch_runtime) AS avg_watch,
    STDDEV(avg_watch_runtime) AS std_watch,
    MIN(avg_watch_runtime) AS min_watch,
    MAX(avg_watch_runtime) AS max_watch
FROM user_activity_summary;

/* recommendation_ctr */
-- 기본 통계 보기
SELECT
    COUNT(*) AS user_cnt,
    AVG(recommendation_ctr) AS avg_reco,
    STDDEV(recommendation_ctr) AS std_reco,
    MIN(recommendation_ctr) AS min_reco,
    MAX(recommendation_ctr) AS max_reco
FROM user_activity_summary;
-- avg_reco 0.15089645 < std_reco 0.18220904036628235

-- 분위별 평균 비교
SELECT
    reco_quartile,
    COUNT(*) AS user_cnt,
    AVG(recommendation_ctr) AS avg_reco,
    AVG(total_watch_minutes) AS avg_watch,
    AVG(total_search_cnt) AS avg_search,
    AVG(total_review_cnt) AS avg_review
FROM (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY recommendation_ctr DESC) AS reco_quartile
    FROM user_activity_summary
) t
GROUP BY reco_quartile
ORDER BY reco_quartile;

/* total_search_cnt */
-- 기본 통계 보기
SELECT
    COUNT(*) AS user_cnt,
    AVG(total_search_cnt) AS avg_search,
    STDDEV(total_search_cnt) AS std_search,
    MIN(total_search_cnt) AS min_search,
    MAX(total_search_cnt) AS max_search,
    SUM(CASE WHEN total_search_cnt IS NULL THEN 1 ELSE 0 END)/COUNT(*) AS zero_ratio
FROM user_activity_summary;
-- min 1 max 9 avg 2.7215 zero_ratio 0.0814

-- 분위별 평균 비교
SELECT
    search_quartile,
    COUNT(*) AS user_cnt,
    AVG(total_search_cnt) AS avg_search,
    AVG(total_watch_minutes) AS avg_watch,
    AVG(recommendation_ctr) AS avg_reco,
    AVG(total_review_cnt) AS avg_review
FROM (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY total_search_cnt DESC) AS search_quartile
    FROM user_activity_summary
) t
GROUP BY search_quartile
ORDER BY search_quartile;
-- 분위가 잘 나눠지지 x
-- 4.6812
-- 2.8132
-- 1.8312
-- 1.0000

/* search_ctr */
-- 기본 통계 보기
SELECT
    COUNT(*) AS user_cnt,
    AVG(search_ctr) AS avg_search,
    STDDEV(search_ctr) AS std_search,
    MIN(search_ctr) AS min_search,
    MAX(search_ctr) AS max_search
FROM user_activity_summary;
-- 평균과 표준편차가 비슷

-- 분위별 평균 비교
SELECT
    search_quartile,
    COUNT(*) AS user_cnt,
    AVG(search_ctr) AS avg_search,
    AVG(total_watch_minutes) AS avg_watch,
    AVG(recommendation_ctr) AS avg_reco,
    AVG(total_review_cnt) AS avg_review
FROM (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY search_ctr DESC) AS search_quartile
    FROM user_activity_summary
) t
GROUP BY search_quartile
ORDER BY search_quartile;

/* total_review_cnt */
-- 기본 통계 보기
SELECT
    COUNT(*) AS user_cnt,
    AVG(total_review_cnt) AS avg_review,
    STDDEV(total_review_cnt) AS std_review,
    MIN(total_review_cnt) AS min_review,
    MAX(total_review_cnt) AS max_review,
    SUM(CASE WHEN total_review_cnt IS NULL THEN 1 ELSE 0 END)/COUNT(*) AS zero_ratio
FROM user_activity_summary;
-- avg 1.9327 min 1 max 8 zero_ratio 0.2239

-- 분위별 평균 비교
SELECT
    review_quartile,
    COUNT(*) AS user_cnt,
    AVG(total_review_cnt) AS avg_review,
    AVG(total_watch_minutes) AS avg_watch,
    AVG(recommendation_ctr) AS avg_reco,
    AVG(search_ctr) AS avg_search
FROM (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY total_review_cnt DESC) AS review_quartile
    FROM user_activity_summary
) t
GROUP BY review_quartile
ORDER BY review_quartile;
-- 분위가 잘 나눠지지 x
-- 3.1120
-- 1.7836
-- 1.0000
-- 1.0000
-- 리뷰 작성 같은 참여형 지표 특성 상 0이나 1에 쏠리는 경우가 많음
-- Q1 상위 사용자(3회 이상 작성) vs 나머지(1회 이하) 정도로만 의미 있음

-- 참여 여부 기준
SELECT 
    user_id,
    total_review_cnt,
    CASE 
        WHEN total_review_cnt IS NULL THEN 'No Review'
        ELSE 'Reviewed'
    END AS review_group,
    total_watch_minutes,
    total_search_cnt
FROM user_activity_summary;

/* avg_review_rating */
-- 기본 통계 보기
SELECT
    COUNT(*) AS user_cnt,
    AVG(avg_review_rating) AS avg_review,
    STDDEV(avg_review_rating) AS std_review,
    MIN(avg_review_rating) AS min_review,
    MAX(avg_review_rating) AS max_review,
    SUM(CASE WHEN avg_review_rating IS NULL THEN 1 ELSE 0 END)/COUNT(*) AS zero_ratio
FROM user_activity_summary;


-- 세그먼트 후보 변수: total_watch_minutes, last_watch_date, watch_original_ratio, recommendation_ctr, total_search_cnt, search_ctr, total_review_cnt
	-- last_watch_date가 최근일수록 total_watch_minutes가 증가
    -- watch_original_ratio는 대부분 0.1~0.5 사이에 존재
	-- recommendation_ctr은 표준편차 > 평균
	-- total_search_cnt, total_review_cnt는 분위가 잘 나눠지지 않지만 의미 상 중요한 지표이기 때문에 상위 25% 사용자를 강조


-- 시청 행동에 속하는 두 변수 간 상관관계 확인
SELECT 
    (AVG(total_watch_minutes * last_watch_date)
     - AVG(total_watch_minutes) * AVG(last_watch_date))
    /
    (STDDEV_POP(total_watch_minutes) * STDDEV_POP(last_watch_date)) 
    AS corr_watch
FROM user_activity_summary;
-- 0.15513327112473016

-- 검색 행동에 속하는 두 변수 간 상관관계 확인
SELECT 
    (AVG(total_search_cnt * search_ctr)
     - AVG(total_search_cnt) * AVG(search_ctr))
    /
    (STDDEV_POP(total_search_cnt) * STDDEV_POP(search_ctr)) 
    AS corr_search
FROM user_activity_summary;
-- -0.008560184387692306

-- 클릭률에 관한 두 변수 간 상관관계 확인
SELECT 
    (AVG(recommendation_ctr * search_ctr)
     - AVG(recommendation_ctr) * AVG(search_ctr))
    /
    (STDDEV_POP(recommendation_ctr) * STDDEV_POP(search_ctr)) 
    AS corr_ctr
FROM user_activity_summary;
-- -0.0008334277608293012


/* Version 1 */
-- 행동 축 정의
	-- Engagemet(얼마나 적극적으로 플랫폼 사용하는지): total_watch_minutes, total_review_cnt, total_search_cnt
	-- Discovery(추천 기반 vs 능동 탐색): recommendation_ctr, search_ctr
	-- Content Preference(오리지널 vs 외부 콘텐츠): watch_original_ratio
    -- Recency(최근성): last_watch_date

-- CREATE TABLE user_behavior_segment AS
-- NTILE 기반 분위수 정규화
WITH normalized_scores AS (
    SELECT
        user_id,
        -- Engagement
        NTILE(4) OVER (ORDER BY total_watch_minutes) AS watch_q,
        NTILE(4) OVER (ORDER BY total_review_cnt) AS review_q,
        NTILE(4) OVER (ORDER BY total_search_cnt) AS search_q,
        
        -- Discovery
        NTILE(4) OVER (ORDER BY recommendation_ctr) AS rec_ctr_q,
        NTILE(4) OVER (ORDER BY search_ctr) AS search_ctr_q,
        
        -- Content Preference
        NTILE(4) OVER (ORDER BY watch_original_ratio) AS content_q,
        
        -- Recency
        NTILE(4) OVER (ORDER BY last_watch_date) AS recency_q
        -- ASC: 최근일수록 낮은 점수
    FROM user_activity_summary
),
-- 행동 축별 점수 계산 (모두 0~1로 스케일링)
behavior_scores AS (
    SELECT
        user_id,
        -- Engagement Index
        ((watch_q / 4.0 + CASE WHEN search_q = 4 THEN 1 ELSE 0 END + CASE WHEN review_q = 4 THEN 1 ELSE 0 END) / 3.0) AS engagement_score,
        
        -- Discovery Index
        ((CAST(search_ctr_q AS SIGNED) - CAST(rec_ctr_q AS SIGNED) + 3.0) / 6.0) AS discovery_score,	-- 음수 대비 보정
        
        -- Content Preference Index
        (content_q / 4.0 * 0.5) AS content_score,	-- watch_original_ratio(0~1)가 대부분 0.1~0.5 사이에 존재
        
        -- Recency Index
        (recency_q / 4.0) AS recency_score
    FROM normalized_scores
),
-- Dominant 행동 기준 세그먼트 부여
dominant_behavior AS (
    SELECT
        user_id,
        engagement_score,
        discovery_score,
        content_score,
        recency_score,
        CASE
			WHEN GREATEST(engagement_score, discovery_score, content_score, recency_score) < 0.3
				THEN 'General Viewer'
            WHEN engagement_score = GREATEST(engagement_score, discovery_score, content_score, recency_score)
                THEN 'High Engagement'
            WHEN discovery_score = GREATEST(engagement_score, discovery_score, content_score, recency_score)
                THEN 'Explorer'
            WHEN content_score = GREATEST(engagement_score, discovery_score, content_score, recency_score)
                THEN 'Content Loyalist'
            WHEN recency_score = GREATEST(engagement_score, discovery_score, content_score, recency_score)
                THEN 'Dormant User'
        END AS segment
    FROM behavior_scores
)
SELECT segment,
       COUNT(*) AS user_cnt,
       COUNT(*) * 1.0 / SUM(COUNT(*)) OVER() AS ratio
FROM dominant_behavior
GROUP BY segment
ORDER BY 2 DESC;
-- 세그먼트 비율 확인
-- Dormant User		4530	0.45300
-- Explorer	3		3350	0.33590
-- High Engagement	1558	0.15580
-- Content Loyalist	398		0.03980
-- General Viewer	164		0.01640


/* Version 2 */
-- 행동 축 정의
	-- 소비 강도: total_watch_minutes
    -- 탐색 방식: recommendation_ctr, total_search_cnt
    -- 참여: total_review_cnt
    -- 최근성: last_watch_date
 
 -- 세그먼트 설계
	-- Binge: 시청량이 높은 사용자
	-- Explorer: 검색을 통해 능동적으로 콘텐츠를 찾는 사용자 / Algorithm Dependent: 추천 시스템에 의존하여 콘텐츠를 소비하는 사용자
	-- Engaged Critic: 활발히 리뷰를 남기는 사용자
	-- Dormant User: 일정 기간 이상 활동하지 않은 사용자

CREATE TABLE user_behavior_segment    
WITH normalized_scores AS (
    SELECT
        user_id,
        -- Consumption Intensity
        NTILE(4) OVER (ORDER BY total_watch_minutes) AS watch_q,
        
        -- Discovery Mode
        NTILE(4) OVER (ORDER BY recommendation_ctr) AS rec_q,
        NTILE(4) OVER (ORDER BY total_search_cnt) AS search_q,
        
        -- Engagement Level
		NTILE(4) OVER (ORDER BY total_review_cnt) AS review_q, 
        
        -- Recency Level
        (5 - NTILE(4) OVER (ORDER BY last_watch_date)) AS recency_q
    FROM user_activity_summary
),
behavior_scores AS (
    SELECT
        user_id,
        --  Consumption Intensity
        (watch_q / 4.0) AS consumption_score,

        -- Discovery Mode
        ((CAST(search_q AS SIGNED) - CAST(rec_q AS SIGNED) + 3.0) / 6.0)  AS discovery_score,

        -- Engagement Level
        (review_q / 4.0) AS engagement_score,

        -- Recency Level
        (recency_q / 4.0) AS recency_score
    FROM normalized_scores
),
dominant_behavior AS (
    SELECT
		user_id,
		consumption_score,
        discovery_score,
        engagement_score,
        recency_score,
        CASE
            WHEN consumption_score = GREATEST(consumption_score, discovery_score, engagement_score, recency_score)
                THEN 'Binge'
            WHEN discovery_score = GREATEST(consumption_score, discovery_score, engagement_score, recency_score)
                THEN 'Explorer'
			WHEN discovery_score < 0.25
				THEN 'Algorithm Dependent'
            WHEN engagement_score = GREATEST(consumption_score, discovery_score, engagement_score, recency_score)
                THEN 'Engaged Critic'
            WHEN recency_score = GREATEST(consumption_score, discovery_score, engagement_score, recency_score)
                THEN 'Dormant User'
        END AS segment
    FROM behavior_scores
)
SELECT *
FROM dominant_behavior;

SELECT * FROM user_behavior_segment LIMIT 10;

SELECT COUNT(*) FROM user_behavior_segment;
-- 10000

SELECT segment,
       COUNT(*) AS user_cnt,
       COUNT(*) * 1.0 / SUM(COUNT(*)) OVER() AS ratio
FROM user_behavior_segment
GROUP BY segment
ORDER BY 2 DESC;
-- 세그먼트별 비율 확인
-- Binge				4058	0.4058
-- Explorer				1285	0.1285
-- Algorithm Dependent	903		0.0903
-- Engaged Critic		2042	0.2042
-- Dormant User			1712	0.1712

-- 주요 행동 지표 비교
SELECT
    segment,
    COUNT(*) AS user_cnt,
    AVG(total_watch_minutes) AS avg_watch_minutes,
    AVG(total_review_cnt) AS avg_review_cnt,
    AVG(recommendation_ctr) AS avg_rec_ctr,
    AVG(total_search_cnt) AS avg_search_cnt,
    AVG(DATEDIFF(CURDATE(), last_watch_date)) AS avg_days_since_last_watch
FROM user_behavior_segment s
LEFT JOIN user_activity_summary u
    ON s.user_id = u.user_id
GROUP BY segment
ORDER BY user_cnt DESC;
-- 세그먼트 설계 의도 검증