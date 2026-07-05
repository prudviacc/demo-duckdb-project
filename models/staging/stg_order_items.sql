with source as (
    select * from {{ ref('raw_order_items') }}
),

renamed as (
    select
        order_item_id::integer              as order_item_id,
        order_id::integer                   as order_id,
        product_id::integer                 as product_id,
        quantity::integer                   as quantity,
        unit_price_at_sale::decimal(10, 2)  as unit_price_at_sale,
        discount_amount::decimal(10, 2)     as discount_amount,
        line_total::decimal(10, 2)          as line_total
    from source
)

select * from renamed
