select
    {{ dbt_utils.generate_surrogate_key(['event']) }} as event_id,
    {{ dbt_utils.generate_surrogate_key(['event_id', 'user_id']) }} as unique_id,
    event as event_description,
    user_id,
    user_email,
    occurred_at,
    tool_id
from {{ ref('stg_events') }}
