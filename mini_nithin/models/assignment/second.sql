{{ config(materialized='view') }}

select body,
    owner_user_id
from posts,
    users as u
where POST_TYPE_ID = 1
    AND owner_user_id = u.id
    AND display_name = 'alexandrul'