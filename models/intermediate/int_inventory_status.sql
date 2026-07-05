with inventory as (
    select * from {{ ref('stg_inventory') }}
),

products as (
    select * from {{ ref('int_products_enriched') }}
),

stores as (
    select * from {{ ref('stg_stores') }}
),

enriched as (
    select
        i.inventory_id,
        i.last_restocked_date,

        -- Store attributes
        i.store_id,
        s.store_name,
        s.region,
        s.store_type,

        -- Product attributes
        i.product_id,
        p.sku,
        p.product_name,
        p.brand,
        p.category_id,
        p.category_name,
        p.department,
        p.unit_cost,
        p.unit_price,

        -- Raw stock quantities
        i.quantity_on_hand,
        i.quantity_reserved,
        i.reorder_point,
        i.reorder_quantity,

        -- Derived availability
        i.quantity_on_hand - i.quantity_reserved                as quantity_available,

        -- Stock health status
        case
            when i.quantity_on_hand = 0               then 'OUT_OF_STOCK'
            when i.quantity_on_hand <= i.reorder_point then 'LOW_STOCK'
            else 'IN_STOCK'
        end                                                     as stock_status,

        -- Reorder trigger flag
        (i.quantity_on_hand <= i.reorder_point)                 as needs_reorder,

        -- Inventory value metrics
        round(i.quantity_on_hand * p.unit_cost, 2)              as inventory_cost_value,
        round(i.quantity_on_hand * p.unit_price, 2)             as inventory_retail_value

    from inventory i
    left join products p
        on i.product_id = p.product_id
    left join stores s
        on i.store_id = s.store_id
)

select * from enriched
