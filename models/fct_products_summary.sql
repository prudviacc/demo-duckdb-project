-- Fact model: product summary with metrics
select
    count(*) as total_products,
    count(distinct price_tier) as distinct_price_tiers,
    sum(case when has_data_quality_issue = 1 then 1 else 0 end) as products_with_issues,
    round(avg(product_price), 2) as avg_product_price,
    min(product_price) as min_product_price,
    max(product_price) as max_product_price
from {{ ref('int_products_cleaned') }}
