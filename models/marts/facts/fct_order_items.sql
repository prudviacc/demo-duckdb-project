{{ config(materialized='table') }}

with enriched as (
    select * from {{ ref('int_order_items_enriched') }}
),

final as (
    select
        order_item_id,
        order_id,
        product_id,

        -- Date keys
        order_date,
        order_year,
        order_month,
        order_quarter,

        -- Order context
        order_status,
        is_completed,
        is_cancelled,
        is_returned,
        payment_method,
        has_promotion,
        promotion_id,

        -- Customer keys
        customer_id,
        customer_segment,
        customer_city,
        customer_state,

        -- Store keys
        store_id,
        store_name,
        store_region,
        store_type,

        -- Product context
        sku,
        product_name,
        brand,
        category_id,
        category_name,
        parent_category_name,
        department,
        price_tier,
        unit_cost,

        -- Line item financials
        quantity,
        unit_price_at_sale,
        discount_amount,
        line_total,

        -- Margin metrics
        margin_per_unit,
        total_margin_amount,
        margin_pct

    from enriched
)

select * from final
