with source as (
    select * from {{ ref('raw_orders') }}
),

renamed as (
    select
        order_id::integer          as order_id,
        customer_id::integer       as customer_id,
        store_id::integer          as store_id,
        promotion_id::integer      as promotion_id,
        order_date::date           as order_date,
        order_status::varchar      as order_status,
        payment_method::varchar    as payment_method,
        shipping_city::varchar     as shipping_city,
        shipping_state::varchar    as shipping_state
    from source
)

select * from renamed
