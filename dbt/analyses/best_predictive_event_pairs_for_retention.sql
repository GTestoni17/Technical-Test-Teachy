WITH signup_events AS (
  SELECT
    f.user_id AS user_id,
    MIN(f.occurred_at) AS signup_time
  FROM fct_events f
  JOIN dim_events e ON f.event_id = e.event_id
  WHERE e.event_description = 'Finish onboarding'
  GROUP BY f.user_id
),

day1_6_events AS (
  SELECT
    f.user_id AS user_id,
    d.event_description AS event_description,
    f.occurred_at AS occurred_at
  FROM fct_events f
  JOIN dim_events d ON f.event_id = d.event_id
  JOIN signup_events s ON f.user_id = s.user_id
  WHERE f.occurred_at BETWEEN date_add(DAY, 1, s.signup_time)
                          AND date_add(DAY, 6, s.signup_time)
),

event_pairs AS (
  SELECT
    a.user_id AS user_id,
    a.event_description AS event1,
    b.event_description AS event2
  FROM day1_6_events a
  JOIN day1_6_events b
    ON a.user_id = b.user_id AND a.event_description < b.event_description
),

retention_events AS (
  SELECT DISTINCT f.user_id AS user_id
  FROM fct_events f
  JOIN signup_events s ON f.user_id = s.user_id
  WHERE f.occurred_at BETWEEN date_add(DAY, 7, s.signup_time)
                          AND date_add(DAY, 13, s.signup_time)
),

paired_retention AS (
  SELECT
    ep.event1 AS event1,
    ep.event2 AS event2,
    COUNT(DISTINCT ep.user_id) AS users_with_pair,
    COUNT(DISTINCT r.user_id) AS retained,
    round(COUNT(DISTINCT r.user_id) / COUNT(DISTINCT ep.user_id), 3) AS retention_rate,
    round(COUNT(DISTINCT r.user_id) / COUNT(DISTINCT ep.user_id) * log(COUNT(DISTINCT ep.user_id)), 3) AS predictive_power_score
  FROM event_pairs ep
  LEFT JOIN retention_events r ON ep.user_id = r.user_id
  GROUP BY ep.event1, ep.event2
  HAVING users_with_pair >= 5
  ORDER BY predictive_power_score DESC
  LIMIT 100
)

SELECT
  concat(event1, ' + ', event2) AS event_pair,
  users_with_pair,
  retained,
  retention_rate,
  predictive_power_score
FROM paired_retention;