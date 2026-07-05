{{ config(materialized='table') }}

with inventory as (
    select * from {{ ref('int_inventory_status') }}
),

final as (
    select
        inventory_id,
        last_restocked_date,
        current_date                    as snapshot_date,

        -- Store keys
        store_id,
        store_name,
        region,
        store_type,

        -- Product keys
        product_id,
        sku,
        product_name,
        brand,
        category_id,
        category_name,
        department,
        unit_cost,
        unit_price,

        -- Stock quantities
        quantity_on_hand,
        quantity_reserved,
        quantity_available,
        reorder_point,
        reorder_quantity,

        -- Stock status
        stock_status,
        needs_reorder,

        -- Inventory value
        inventory_cost_value,
        inventory_retail_value

    from inventory
)

select * from final
