WITH signup_events AS (
    SELECT
        f.user_id,
        toStartOfWeek(f.occurred_at, 1) AS cohort_week_start,
        f.occurred_at AS signup_date
    FROM fct_events f
    JOIN dim_events e ON f.event_id = e.event_id
    WHERE e.event_description = 'Finish onboarding'
),

retention_window_events AS (
    SELECT
	  f.user_id
	FROM fct_events f
	LEFT JOIN signup_events s ON f.user_id = s.user_id
	WHERE f.occurred_at BETWEEN date_add(DAY, 7, s.signup_date)
	                       AND date_add(DAY, 13, s.signup_date)
	
),

cohorts AS (
    SELECT
        s.cohort_week_start,
        COUNT(DISTINCT s.user_id) AS total_users,
        COUNT(DISTINCT r.user_id) AS retained_users
    FROM signup_events s
    LEFT JOIN retention_window_events r ON s.user_id = r.user_id
    GROUP BY s.cohort_week_start
)

SELECT
    cohort_week_start,
    total_users,
    retained_users,
    round(retained_users / total_users, 3) AS retention_rate
FROM cohorts
ORDER BY cohort_week_start