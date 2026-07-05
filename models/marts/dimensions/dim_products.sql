{{ config(materialized='table') }}

with products as (
    select * from {{ ref('int_products_enriched') }}
),

final as (
    select
        product_id,
        sku,
        product_name,
        brand,
        category_id,
        category_name,
        parent_category_id,
        parent_category_name,
        department,
        supplier_id,
        supplier_name,
        supplier_country,
        lead_time_days,
        unit_cost,
        unit_price,
        weight_kg,
        gross_margin_amount,
        gross_margin_pct,
        price_tier,

        case
            when is_active then 'Active'
            else 'Discontinued'
        end                 as product_status

    from products
)

select * from final
