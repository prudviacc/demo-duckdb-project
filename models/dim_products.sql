-- Dimension model: enriched product dimension
select
    product_id,
    product_name,
    product_price,
    price_tier,
    has_data_quality_issue,
    case
        when has_data_quality_issue = 1 then 'Flagged'
        else 'Active'
    end as product_status,
    current_timestamp as loaded_at
from {{ ref('int_products_cleaned') }}
order by product_id
