with source as (
    select * from {{ ref('raw_categories') }}
),

renamed as (
    select
        category_id::integer         as category_id,
        category_name::varchar       as category_name,
        parent_category_id::integer  as parent_category_id,
        department::varchar          as department
    from source
)

select * from renamed
