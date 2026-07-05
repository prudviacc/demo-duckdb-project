-- Business rule: fct_daily_sales must only aggregate completed orders.
-- This test verifies that no cancelled or returned order items appear in the daily sales grain
-- by cross-checking order-level status against item-level presence in the daily sales model.
-- Returns order_item_ids where the parent order is not COMPLETED but the item appears in daily sales.

select
    oi.order_item_id,
    oi.order_id,
    oi.order_status,
    oi.order_date,
    oi.store_id,
    oi.category_id
from {{ ref('fct_order_items') }} oi
inner join {{ ref('fct_daily_sales') }} ds
    on oi.store_id     = ds.store_id
   and oi.order_date   = ds.sale_date
   and oi.category_id  = ds.category_id
where oi.is_completed = false
