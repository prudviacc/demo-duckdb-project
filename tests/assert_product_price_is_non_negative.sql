-- Test to catch negative product prices
select
    product_id,
    product_name,
    product_price
from {{ ref('stg_products') }}
where product_price < 0
