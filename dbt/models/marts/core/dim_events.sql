with unique_events as (
    select distinct event_id, event_description from {{ ref('events') }}
)

select
    event_id,
    event_description
from unique_events
