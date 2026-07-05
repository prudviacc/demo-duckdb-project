with source as (
    select * from {{ ref('raw_inventory') }}
),

renamed as (
    select
        inventory_id::integer           as inventory_id,
        store_id::integer               as store_id,
        product_id::integer             as product_id,
        quantity_on_hand::integer       as quantity_on_hand,
        quantity_reserved::integer      as quantity_reserved,
        reorder_point::integer          as reorder_point,
        reorder_quantity::integer       as reorder_quantity,
        last_restocked_date::date       as last_restocked_date
    from source
)

select * from renamed
