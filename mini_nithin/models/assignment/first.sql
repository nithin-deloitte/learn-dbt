{{ config(materialized='view') }}

select id,
    display_name,
    reputation
from "MINI_ASSIGNMENT"."DBT"."USERS"
order by reputation desc
limit 10