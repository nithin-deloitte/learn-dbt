{{ config(materialized='view') }}

select
    u.id, u.display_name, u.reputation
from users as u, posts as p
where u.REPUTATION >= 75000
order by u.reputation desc