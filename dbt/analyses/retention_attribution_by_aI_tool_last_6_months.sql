WITH max_event_date AS (
  SELECT toStartOfMonth(MAX(occurred_at)) AS last_month
  FROM fct_events
),

onboarding_events AS (
  SELECT
    f.user_id AS user_id,
    MIN(f.occurred_at) AS signup_time
  FROM fct_events f
  JOIN dim_events e ON f.event_id = e.event_id
  JOIN max_event_date m ON 1 = 1
  WHERE e.event_description = 'Finish onboarding'
    AND f.occurred_at >= date_add(MONTH, -6, m.last_month)
  GROUP BY f.user_id
),

first_tool_used AS (
  SELECT
    f.user_id AS user_id,
    f.tool_id AS tool_id,
    MIN(f.occurred_at) AS first_tool_time
  FROM fct_events f
  JOIN dim_events e ON f.event_id = e.event_id
  JOIN onboarding_events o ON f.user_id = o.user_id
  WHERE e.event_description = 'Used AI Tool'
    AND f.occurred_at BETWEEN o.signup_time AND date_add(DAY, 6, o.signup_time)
    AND f.tool_id IS NOT NULL
  GROUP BY f.user_id, f.tool_id
  QUALIFY ROW_NUMBER() OVER (PARTITION BY f.user_id ORDER BY MIN(f.occurred_at)) = 1
),

week1_events AS (
  SELECT DISTINCT f.user_id AS user_id
  FROM fct_events f
  JOIN onboarding_events o ON f.user_id = o.user_id
  WHERE f.occurred_at BETWEEN date_add(DAY, 7, o.signup_time)
                          AND date_add(DAY, 13, o.signup_time)
)

SELECT
  t.tool_id as tool_id,
  COUNT(DISTINCT t.user_id) AS users,
  COUNT(DISTINCT w.user_id) AS retained_users,
  round(COUNT(DISTINCT w.user_id) / COUNT(DISTINCT t.user_id), 3) AS retention_rate
FROM first_tool_used t
LEFT JOIN week1_events w ON t.user_id = w.user_id
GROUP BY t.tool_id
ORDER BY retention_rate DESC;