{{ config(materialized='table') }}

with promotions as (
    select * from {{ ref('stg_promotions') }}
),

final as (
    select
        promotion_id,
        promotion_name,
        discount_type,
        discount_value,
        start_date,
        end_date,
        applies_to_category_id,
        min_order_amount,

        -- Duration in days
        datediff('day', start_date, end_date)       as promotion_duration_days,

        -- Lifecycle status relative to today
        case
            when not is_active                      then 'Expired'
            when current_date < start_date          then 'Upcoming'
            when current_date between start_date
                 and end_date                       then 'Active'
            else 'Expired'
        end                                         as promotion_status

    from promotions
)

select * from final
