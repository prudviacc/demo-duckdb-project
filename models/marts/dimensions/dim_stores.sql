{{ config(materialized='table') }}

with stores as (
    select * from {{ ref('stg_stores') }}
),

final as (
    select
        store_id,
        store_name,
        city,
        state,
        country,
        region,
        store_type,
        open_date,
        extract(year from open_date)::integer       as open_year,
        sq_footage,

        case
            when sq_footage < 5000  then 'Small'
            when sq_footage < 15000 then 'Medium'
            else 'Large'
        end                                         as store_size_bucket,

        case
            when is_active then 'Open'
            else 'Closed'
        end                                         as store_status

    from stores
)

select * from final
