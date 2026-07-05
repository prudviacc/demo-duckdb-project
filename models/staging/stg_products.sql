with source as (
    select * from {{ ref('raw_products') }}
),

renamed as (
    select
        product_id::integer           as product_id,
        sku::varchar                  as sku,
        product_name::varchar         as product_name,
        category_id::integer          as category_id,
        supplier_id::integer          as supplier_id,
        brand::varchar                as brand,
        unit_cost::decimal(10, 2)     as unit_cost,
        unit_price::decimal(10, 2)    as unit_price,
        weight_kg::decimal(6, 3)      as weight_kg,
        is_active::boolean            as is_active
    from source
)

select * from renamed
