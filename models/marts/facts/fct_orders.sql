{{ config(materialized='table') }}

with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

order_items_agg as (
    select
        order_id,
        count(*)                                            as item_count,
        sum(quantity)                                       as total_units_sold,
        sum(line_total + discount_amount)                   as order_subtotal,
        sum(discount_amount)                                as total_discount_amount,
        sum(line_total)                                     as order_net_total,
        sum(total_margin_amount)                            as order_margin_amount
    from {{ ref('int_order_items_enriched') }}
    group by order_id
),

final as (
    select
        o.order_id,
        o.order_date,
        o.order_year,
        o.order_month,
        o.order_quarter,
        o.order_day_of_week,
        o.order_status,
        o.payment_method,
        o.shipping_city,
        o.shipping_state,
        o.is_completed,
        o.is_cancelled,
        o.is_returned,
        o.is_pending,

        -- Customer keys
        o.customer_id,
        o.customer_full_name,
        o.customer_segment,

        -- Store keys
        o.store_id,
        o.store_name,
        o.store_region,
        o.store_type,

        -- Promotion keys
        o.promotion_id,
        o.has_promotion,
        o.promotion_name,

        -- Aggregated order metrics
        agg.item_count,
        agg.total_units_sold,
        agg.order_subtotal,
        agg.total_discount_amount,
        agg.order_net_total,
        agg.order_margin_amount,
        round(
            agg.order_margin_amount / nullif(agg.order_net_total, 0) * 100,
            2
        )                                                   as order_margin_pct

    from orders o
    left join order_items_agg agg
        on o.order_id = agg.order_id
)

select * from final
