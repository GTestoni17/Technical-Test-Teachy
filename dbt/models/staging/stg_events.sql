select
    event,
    toDateTime(time) as occurred_at,
    distinct_id as user_id,
    user_email,
    toolId as tool_id
from {{ source('airbyte_internal', 'events_parsed') }}
