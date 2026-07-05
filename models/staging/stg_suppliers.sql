with source as (
    select * from {{ ref('raw_suppliers') }}
),

renamed as (
    select
        supplier_id::integer      as supplier_id,
        supplier_name::varchar    as supplier_name,
        contact_email::varchar    as contact_email,
        city::varchar             as city,
        state::varchar            as state,
        country::varchar          as country,
        lead_time_days::integer   as lead_time_days,
        is_active::boolean        as is_active
    from source
)

select * from renamed
