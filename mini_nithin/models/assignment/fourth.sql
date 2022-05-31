{{ config(materialized='view') }}

select name,
    count(*) as popular_badges
from badges
group by name
order by count(*) desc
limit 10