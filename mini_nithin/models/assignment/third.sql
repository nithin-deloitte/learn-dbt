{{ config(materialized='view') }}

select body,
    u.display_name
from posts,
    users as u
where POST_TYPE_ID = 1
    AND owner_user_id = u.id
    AND u.display_name LIKE '%nau%'