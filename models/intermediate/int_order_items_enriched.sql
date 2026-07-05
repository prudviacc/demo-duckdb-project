with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select * from {{ ref('int_orders_enriched') }}
),

products as (
    select * from {{ ref('int_products_enriched') }}
),

enriched as (
    select
        -- Line item identifiers
        oi.order_item_id,
        oi.order_id,
        oi.product_id,

        -- Order context
        o.order_date,
        o.order_year,
        o.order_month,
        o.order_quarter,
        o.order_day_of_week,
        o.order_status,
        o.is_completed,
        o.is_cancelled,
        o.is_returned,
        o.payment_method,
        o.has_promotion,
        o.promotion_id,

        -- Customer context
        o.customer_id,
        o.customer_full_name,
        o.customer_segment,
        o.customer_city,
        o.customer_state,

        -- Store context
        o.store_id,
        o.store_name,
        o.store_region,
        o.store_type,

        -- Product context
        p.sku,
        p.product_name,
        p.brand,
        p.category_id,
        p.category_name,
        p.parent_category_name,
        p.department,
        p.price_tier,
        p.unit_cost,

        -- Line item financials
        oi.quantity,
        oi.unit_price_at_sale,
        oi.discount_amount,
        oi.line_total,

        -- Derived margin metrics per line
        round(oi.unit_price_at_sale - p.unit_cost, 2)                          as margin_per_unit,
        round((oi.unit_price_at_sale - p.unit_cost) * oi.quantity, 2)          as total_margin_amount,
        round(
            (oi.unit_price_at_sale - p.unit_cost) / nullif(oi.unit_price_at_sale, 0) * 100,
            2
        )                                                                       as margin_pct

    from order_items oi
    left join orders o
        on oi.order_id = o.order_id
    left join products p
        on oi.product_id = p.product_id
)

select * from enriched
