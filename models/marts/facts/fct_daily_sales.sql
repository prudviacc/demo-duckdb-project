{{ config(materialized='table') }}

-- Grain: one row per (sale_date, store_id, category_id)
-- Includes ONLY completed orders. Cancelled and returned orders are excluded.

with completed_items as (
    select *
    from {{ ref('int_order_items_enriched') }}
    where is_completed = true
),

final as (
    select
        order_date                                      as sale_date,
        store_id,
        store_name,
        store_region,
        store_type,
        category_id,
        category_name,
        parent_category_name,
        department,

        count(distinct order_id)                        as order_count,
        count(order_item_id)                            as line_item_count,
        sum(quantity)                                   as units_sold,
        round(sum(line_total + discount_amount), 2)     as gross_revenue,
        round(sum(discount_amount), 2)                  as total_discounts,
        round(sum(line_total), 2)                       as net_revenue,
        round(sum(total_margin_amount), 2)              as total_margin,
        round(avg(unit_price_at_sale), 2)               as avg_unit_price,
        round(sum(line_total) / nullif(count(distinct order_id), 0), 2)
                                                        as avg_order_value

    from completed_items
    group by
        order_date,
        store_id,
        store_name,
        store_region,
        store_type,
        category_id,
        category_name,
        parent_category_name,
        department
)

select * from final
