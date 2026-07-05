{{ config(materialized='table') }}

with customers as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        customer_id,
        first_name,
        last_name,
        first_name || ' ' || last_name                         as full_name,
        email,
        phone,
        city,
        state,
        country,
        segment,
        registration_date,
        extract(year from registration_date)::integer           as registration_year,

        -- Tenure segment relative to today
        case
            when current_date - registration_date <= 90  then 'New'
            when current_date - registration_date <= 365 then 'Recent'
            else 'Established'
        end                                                     as customer_tenure_segment,

        case
            when is_active then 'Active'
            else 'Inactive'
        end                                                     as customer_status

    from customers
)

select * from final
