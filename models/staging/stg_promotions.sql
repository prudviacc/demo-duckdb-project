with source as (
    select * from {{ ref('raw_promotions') }}
),

renamed as (
    select
        promotion_id::integer                  as promotion_id,
        promotion_name::varchar                as promotion_name,
        discount_type::varchar                 as discount_type,
        discount_value::decimal(8, 2)          as discount_value,
        start_date::date                       as start_date,
        end_date::date                         as end_date,
        applies_to_category_id::integer        as applies_to_category_id,
        min_order_amount::decimal(10, 2)       as min_order_amount,
        is_active::boolean                     as is_active
    from source
)

select * from renamed
