select
    product_id,
    product_name,
    product_price
from {{ ref('raw_products') }}
