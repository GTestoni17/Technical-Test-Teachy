WITH signup_events AS (
  SELECT
    f.user_id AS user_id,
    MIN(occurred_at) AS signup_time
  FROM fct_events f
  JOIN dim_events e ON f.event_id = e.event_id
  WHERE e.event_description = 'Finish onboarding'
    AND toStartOfMonth(f.occurred_at) = toDate('2023-04-01')
  GROUP BY f.user_id
),

step1 AS (
  SELECT
    f.user_id AS user_id,
    f.occurred_at AS used_tool_time
  FROM fct_events f
  JOIN dim_events e ON f.event_id = e.event_id
  JOIN signup_events s ON f.user_id = s.user_id
  WHERE e.event_description = 'Used AI Tool'
    AND f.occurred_at > s.signup_time
    AND f.occurred_at <= date_add(DAY, 15, s.signup_time)
),

step2 AS (
  SELECT
    f.user_id AS user_id,
    MIN(f.occurred_at) AS created_lesson_time
  FROM fct_events f
  JOIN dim_events e ON f.event_id = e.event_id
  JOIN step1 s1 ON f.user_id = s1.user_id
  WHERE e.event_description = 'Create Lesson'
    AND f.occurred_at > s1.used_tool_time
    AND f.occurred_at <= date_add(DAY, 15, s1.used_tool_time)
  GROUP BY f.user_id
)

SELECT 'Finish onboarding' AS step, COUNT(DISTINCT s.user_id) AS users FROM signup_events s
UNION ALL
SELECT 'Used AI Tool', COUNT(DISTINCT s1.user_id) FROM step1 s1
UNION ALL
SELECT 'Create Lesson', COUNT(DISTINCT s2.user_id) FROM step2 s2