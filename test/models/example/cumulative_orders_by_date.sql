
select
  to_date(o.O_ORDERDATE) as day,
  sum(o.O_TOTALPRICE) OVER( partition BY NULL ORDER BY o.O_ORDERDATE ASC rows UNBOUNDED PRECEDING) "Cumulative Sum"
from "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."ORDERS" as o