{{ config(materialized='table') }}

with date_spine as (
    select (date '2023-01-01' + interval (n) day)::date as date_day
    from (select unnest(generate_series(0, 730)) as n) t
),

final as (
    select
        date_day,
        extract(year from date_day)::integer            as year,
        extract(quarter from date_day)::integer         as quarter,
        extract(month from date_day)::integer           as month,
        monthname(date_day)                             as month_name,
        extract(week from date_day)::integer            as week_of_year,
        extract(day from date_day)::integer             as day_of_month,
        dayofweek(date_day)                             as day_of_week,
        dayname(date_day)                               as day_name,
        dayofweek(date_day) in (0, 6)                  as is_weekend,
        'Q' || extract(quarter from date_day)::varchar
            || ' ' || extract(year from date_day)::varchar  as quarter_label,
        extract(year from date_day)::varchar
            || '-' || lpad(extract(month from date_day)::varchar, 2, '0')
                                                        as year_month
    from date_spine
)

select * from final
