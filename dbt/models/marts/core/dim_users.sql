with unique_users as (
    select distinct user_id, user_email from {{ ref('events') }}
)

select
    user_id,
    user_email
from unique_users
