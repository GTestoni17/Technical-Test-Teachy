select
    unique_id,
    event_id,
    user_id,
    tool_id,
    occurred_at
from {{ ref('events') }}
