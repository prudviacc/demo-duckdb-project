-- Business rule: active products must not be priced at or below their supplier cost.
-- Selling below cost indicates a pricing error or data quality issue.
-- Returns active products where unit_price <= unit_cost.

select
    product_id,
    sku,
    product_name,
    unit_cost,
    unit_price,
    gross_margin_pct
from {{ ref('dim_products') }}
where product_status = 'Active'
  and unit_price <= unit_cost
