with source as (
    select * from {{ ref('raw_customers') }}
),

renamed as (
    select
        customer_id::integer          as customer_id,
        first_name::varchar           as first_name,
        last_name::varchar            as last_name,
        email::varchar                as email,
        phone::varchar                as phone,
        city::varchar                 as city,
        state::varchar                as state,
        country::varchar              as country,
        segment::varchar              as segment,
        registration_date::date       as registration_date,
        is_active::boolean            as is_active
    from source
)

select * from renamed
