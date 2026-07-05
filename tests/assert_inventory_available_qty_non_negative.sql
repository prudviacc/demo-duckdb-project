-- Business rule: quantity_available (on_hand - reserved) must never be negative.
-- A negative value means more units are reserved than physically exist, which indicates
-- a reservation or receiving data quality issue.
-- Returns inventory records where quantity_available < 0.

select
    inventory_id,
    store_id,
    store_name,
    product_id,
    product_name,
    quantity_on_hand,
    quantity_reserved,
    quantity_available
from {{ ref('fct_inventory_snapshot') }}
where quantity_available < 0
