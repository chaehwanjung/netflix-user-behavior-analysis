SELECT  *
  FROM  user_behavior_segment s
  LEFT
  JOIN  user_activity_summary u
    ON  s.user_id = u.user_id
 ORDER
    BY  1
 LIMIT  20;
 

-- 사용자 속성 비교
SELECT
    segment,
    COUNT(*) AS user_cnt,
    AVG(DATEDIFF(CURDATE(), created_at)) AS avg_days_since_created_at,
    AVG(household_size) AS avg_household_size,
    AVG(monthly_spend) AS avg_monthly_spend
FROM user_behavior_segment s
LEFT JOIN user_activity_summary u
    ON s.user_id = u.user_id
GROUP BY segment
ORDER BY user_cnt DESC;


-- age 비교
SELECT
    s.segment,
    u.age,
    COUNT(*) AS user_cnt,
    COUNT(*) * 1.0 / SUM(COUNT(*)) OVER(PARTITION BY s.segment) AS ratio_within_segment
FROM user_behavior_segment s
LEFT JOIN user_activity_summary u
    ON s.user_id = u.user_id
GROUP BY s.segment, u.age
ORDER BY s.segment, u.age;
/*
Algorithm Dependent	09세 이하	10		0.01107
Algorithm Dependent	10대		59		0.06534
Algorithm Dependent	20대		189		0.20930
Algorithm Dependent	30대		254		0.28128
Algorithm Dependent	40대		199		0.22038
Algorithm Dependent	50대		87		0.09635
Algorithm Dependent	60대		6		0.00664
Algorithm Dependent	70세 이상	2		0.00221
Algorithm Dependent	Unknown	97		0.10742
Binge				09세 이하	64		0.01577
Binge				10대		304		0.07491
Binge				20대		812		0.20010
Binge				30대		1141	0.28117
Binge				40대		809		0.19936
Binge				50대		342		0.08428
Binge				60대		66		0.01626
Binge				70세 이상	15		0.00370
Binge				Unknown	505		0.12445
Dormant User		09세 이하	21		0.01227
Dormant User		10대		138		0.08061
Dormant User		20대		302		0.17640
Dormant User		30대		475		0.27745
Dormant User		40대		359		0.20970
Dormant User		50대		160		0.09346
Dormant User		60대		35		0.02044
Dormant User		70세 이상	5		0.00292
Dormant User		Unknown	217		0.12675
Engaged Critic		09세 이하	30		0.01469
Engaged Critic		10대		146		0.07150
Engaged Critic		20대		420		0.20568
Engaged Critic		30대		570		0.27914
Engaged Critic		40대		413		0.20225
Engaged Critic		50대		180		0.08815
Engaged Critic		60대		31		0.01518
Engaged Critic		70세 이상	2		0.00098
Engaged Critic		Unknown	250		0.12243
Explorer			09세 이하	17		0.01323
Explorer			10대		89		0.06926
Explorer			20대		283		0.22023
Explorer			30대		333		0.25914
Explorer			40대		278		0.21634
Explorer			50대		105		0.08171
Explorer			60대		20		0.01556
Explorer			70세 이상	3		0.00233
Explorer			Unknown	157		0.12218
*/


-- gender 비교
SELECT
    s.segment,
    u.gender,
    COUNT(*) AS user_cnt,
    COUNT(*) * 1.0 / SUM(COUNT(*)) OVER(PARTITION BY s.segment) AS ratio_within_segment
FROM user_behavior_segment s
LEFT JOIN user_activity_summary u
    ON s.user_id = u.user_id
GROUP BY s.segment, u.gender
ORDER BY s.segment, u.gender;
/*
Algorithm Dependent	Male	336		0.37209
Algorithm Dependent	Female	377		0.41750
Algorithm Dependent	Other	55		0.06091
Algorithm Dependent	Unknown	135		0.14950
Binge				Male	1696	0.41794
Binge				Female	1704	0.41991
Binge				Other	157		0.03869
Binge				Unknown	501		0.12346
Dormant User		Male	727		0.42465
Dormant User		Female	718		0.41939
Dormant User		Other	73		0.04264
Dormant User		Unknown	194		0.11332
Engaged Critic		Male	810		0.39667
Engaged Critic		Female	868		0.42507
Engaged Critic		Other	106		0.05191
Engaged Critic		Unknown	258		0.12635
Explorer			Male	527		0.41012
Explorer			Female	536		0.41712
Explorer			Other	54		0.04202
Explorer			Unknown	168		0.13074
*/

-- primary_device 비교
SELECT
    s.segment,
    u.primary_device,
    COUNT(*) AS user_cnt,
    COUNT(*) * 1.0 / SUM(COUNT(*)) OVER(PARTITION BY s.segment) AS ratio_within_segment
FROM user_behavior_segment s
LEFT JOIN user_activity_summary u
    ON s.user_id = u.user_id
GROUP BY s.segment, u.primary_device
ORDER BY s.segment, u.primary_device;
/*
Algorithm Dependent	Tablet			156	0.17276
Algorithm Dependent	Laptop			132	0.14618
Algorithm Dependent	Smart TV		168	0.18605
Algorithm Dependent	Mobile			136	0.15061
Algorithm Dependent	Desktop			159	0.17608
Algorithm Dependent	Gaming Console	152	0.16833
Binge				Tablet			658	0.16215
Binge				Laptop			689	0.16979
Binge				Smart TV		704	0.17348
Binge				Mobile			628	0.15476
Binge				Desktop			705	0.17373
Binge				Gaming Console	674	0.16609
Dormant User		Tablet			314	0.18341
Dormant User		Laptop			275	0.16063
Dormant User		Smart TV		261	0.15245
Dormant User		Mobile			277	0.16180
Dormant User		Desktop			321	0.18750
Dormant User		Gaming Console	264	0.15421
Engaged Critic		Tablet			359	0.17581
Engaged Critic		Laptop			338	0.16552
Engaged Critic		Smart TV		336	0.16454
Engaged Critic		Mobile			357	0.17483
Engaged Critic		Desktop			334	0.16357
Engaged Critic		Gaming Console	318	0.15573
Explorer			Tablet			198	0.15409
Explorer			Laptop			228	0.17743
Explorer			Smart TV		198	0.15409
Explorer			Mobile			211	0.16420
Explorer			Desktop			232	0.18054
Explorer			Gaming Console	218	0.16965
*/


-- subscription_plan 비교
SELECT
    s.segment,
    u.subscription_plan,
    COUNT(*) AS user_cnt,
    COUNT(*) * 1.0 / SUM(COUNT(*)) OVER(PARTITION BY s.segment) AS ratio_within_segment
FROM user_behavior_segment s
LEFT JOIN user_activity_summary u
    ON s.user_id = u.user_id
GROUP BY s.segment, u.subscription_plan
ORDER BY s.segment, u.subscription_plan;
/*
Algorithm Dependent	Basic		166		0.18383
Algorithm Dependent	Standard	328		0.36323
Algorithm Dependent	Premium		319		0.35327
Algorithm Dependent	PremiumPlus	90		0.09967
Binge				Basic		822		0.20256
Binge				Standard	1443	0.35559
Binge				Premium		1400	0.34500
Binge				PremiumPlus	393		0.09685
Dormant User		Basic		325		0.18984
Dormant User		Standard	596		0.34813
Dormant User		Premium		626		0.36565
Dormant User		PremiumPlus	165		0.09638
Engaged Critic		Basic		391		0.19148
Engaged Critic		Standard	703		0.34427
Engaged Critic		Premium		723		0.35406
Engaged Critic		PremiumPlus	225		0.11019
Explorer			Basic		262		0.20389
Explorer			Standard	452		0.35175
Explorer			Premium		439		0.34163
Explorer			PremiumPlus	132		0.10272
*/


-- 콘텐츠 소비 패턴 비교
SELECT
    s.segment,
    AVG(u.watch_genre_cnt) AS avg_watch_genre,
    AVG(u.watch_original_ratio) AS avg_original_ratio,
    AVG(u.avg_watch_runtime) AS avg_watch_runtime
FROM user_behavior_segment s
LEFT JOIN user_activity_summary u
    ON s.user_id = u.user_id
GROUP BY s.segment
ORDER BY avg_watch_genre DESC;
-- avg_watch_genre에서 차이 존재
-- Binge				9.1390
-- Explorer				7.4327
-- Engaged Critic		6.9726
-- Algorithm Dependent	6.8439
-- Dormant User			6.4819


-- 시청 행동 비교
SELECT
    segment,
    COUNT(*) AS user_cnt,
    AVG(total_watch_cnt) AS avg_watch_cnt,
    AVG(total_watch_minutes) AS avg_total_watch,
    AVG(avg_watch_minutes) AS avg_avg_watch,
    AVG(avg_watch_pct) AS avg_watch_pct,
    AVG(DATEDIFF(CURDATE(), last_watch_date)) AS avg_days_since_last_watch
FROM user_behavior_segment s
LEFT JOIN user_activity_summary u
    ON s.user_id = u.user_id
GROUP BY segment
ORDER BY user_cnt DESC;
-- Binge를 제외하고, Explorer의 시청 세션 수와 총 시청 시간의 평균값이 큰 편
-- Dormant User를 제외하고, Algorithm Dependent의 avg_days_since_last_watch가 큰 편


-- 검색 행동 비교
SELECT
    s.segment,
    AVG(u.total_search_cnt) AS avg_search_cnt,
    AVG(u.search_ctr) AS avg_search_ctr
FROM user_behavior_segment s
LEFT JOIN user_activity_summary u
    ON s.user_id = u.user_id
GROUP BY s.segment
ORDER BY avg_search_cnt DESC;
-- Explorer				3.8379	0.47516773
-- Engaged Critic		2.8763	0.48767935
-- Dormant User			2.6751	0.47538929
-- Binge				2.5634	0.50194832
-- Algorithm Dependent	1.1717	0.50432900
-- Algorithm Dependent의 평균 검색 수는 낮지만, 검색 후 클릭률에서는 다른 세그먼트와 비슷함 (간소하게 높음)


-- 참여 행동 비교
SELECT
    s.segment,
    COUNT(*) AS user_cnt,
    AVG(u.total_review_cnt) AS avg_review_cnt,
    AVG(u.avg_review_rating) AS avg_review_rating,
    SUM(CASE WHEN u.total_review_cnt > 0 THEN 1 ELSE 0 END) / COUNT(*) AS review_participation_ratio
FROM user_behavior_segment s
LEFT JOIN user_activity_summary u
    ON s.user_id = u.user_id
GROUP BY s.segment
ORDER BY avg_review_cnt DESC;
-- Engaged Critic		2.6841
-- Algorithm Dependent	2.0856
-- Binge				1.7255
-- Explorer				1.5339
-- Dormant User			1.3166
-- Engaged Critic 제외하고 리뷰 많이 작성하는 순서가 왜 저렇게 형성?


-- 활성(이탈x) 비율 비교
SELECT
    segment,
    COUNT(*) AS user_cnt,
    AVG(is_active) AS active_ratio
FROM user_behavior_segment s
LEFT JOIN user_activity_summary u
    ON s.user_id = u.user_id
GROUP BY segment
ORDER BY active_ratio DESC;
-- Explorer				1285	0.8802
-- Dormant User			1712	0.8604
-- Algorithm Dependent	903		0.8505
-- Binge				4058	0.8475
-- Engaged Critic		2042	0.8364
-- Dormant User의 활성 비율이 다른 세그먼트와 차이x -> 구독은 유지하지만 사용을 안 하는 사용자도 상당히 존재?