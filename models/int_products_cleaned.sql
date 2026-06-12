-- Intermediate model: cleaned and validated products
select
    product_id,
    product_name,
    product_price,
    case
        when product_price < 0 then 'Invalid'
        when product_price = 0 then 'Free'
        when product_price < 100 then 'Budget'
        when product_price < 500 then 'Standard'
        else 'Premium'
    end as price_tier,
    case
        when product_price < 0 then 1
        else 0
    end as has_data_quality_issue
from {{ ref('stg_products') }}
