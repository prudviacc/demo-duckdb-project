with source as (
    select * from {{ ref('raw_stores') }}
),

renamed as (
    select
        store_id::integer        as store_id,
        store_name::varchar      as store_name,
        city::varchar            as city,
        state::varchar           as state,
        country::varchar         as country,
        region::varchar          as region,
        store_type::varchar      as store_type,
        open_date::date          as open_date,
        is_active::boolean       as is_active,
        sq_footage::integer      as sq_footage
    from source
)

select * from renamed
