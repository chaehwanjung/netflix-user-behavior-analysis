select count(*) from user_behavior_segment;
-- 10000
select count(*) from user_activity_summary;
-- 10000

select *
from user_activity_summary
order by user_id
limit 10;

select count(*)
from user_activity_summary
where recommendation_ctr is null;
-- recommendation_logs, search_logs, reviews 테이블에 존재하지 않는 사용자에 대해서는 user_activity_summary의 관련 컬럼에서 NULL값 존재
-- recommendation_ctr, total_search_cnt, search_ctr, total_review_cnt, avg_review_rating

select *
from user_behavior_segment
order by user_id
limit 10;


select  u.user_id,

		s.segment,
        s.consumption_score,
        s.discovery_score,
        s.engagement_score,
        s.recency_score,

		u.age,
		u.gender,
		u.country,
		u.subscription_plan,
		u.is_active,
		u.monthly_spend,
		u.primary_device,
		u.household_size,
		u.created_at,
		u.total_watch_cnt,
		u.total_watch_minutes,
		u.avg_watch_minutes,
		u.avg_watch_pct,
		u.last_watch_date,
		u.watch_genre_cnt,
		u.watch_original_ratio,
		u.avg_watch_runtime,
		u.recommendation_ctr,
		u.total_search_cnt,
		u.search_ctr,
		u.total_review_cnt,
		u.avg_review_rating
        
from user_activity_summary u
join user_behavior_segment s on u.user_id = s.user_id
order by u.user_id;
