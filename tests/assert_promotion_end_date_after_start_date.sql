-- Business rule: every promotion must have an end_date that is strictly after its start_date.
-- A promotion where end_date <= start_date is either misconfigured or entered with swapped dates.
-- Returns promotions where the date range is invalid.

select
    promotion_id,
    promotion_name,
    start_date,
    end_date,
    promotion_duration_days
from {{ ref('dim_promotions') }}
where end_date <= start_date
