with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

stores as (
    select * from {{ ref('stg_stores') }}
),

promotions as (
    select * from {{ ref('stg_promotions') }}
),

enriched as (
    select
        o.order_id,
        o.order_date,
        o.order_status,
        o.payment_method,
        o.shipping_city,
        o.shipping_state,

        -- Date dimensions derived from order_date
        extract(year from o.order_date)::integer        as order_year,
        extract(month from o.order_date)::integer       as order_month,
        extract(quarter from o.order_date)::integer     as order_quarter,
        dayofweek(o.order_date)                         as order_day_of_week,

        -- Status flags for easy filtering in downstream models
        (o.order_status = 'COMPLETED')                  as is_completed,
        (o.order_status = 'CANCELLED')                  as is_cancelled,
        (o.order_status = 'RETURNED')                   as is_returned,
        (o.order_status = 'PENDING')                    as is_pending,

        -- Customer attributes
        o.customer_id,
        c.first_name || ' ' || c.last_name              as customer_full_name,
        c.segment                                       as customer_segment,
        c.city                                          as customer_city,
        c.state                                         as customer_state,

        -- Store attributes
        o.store_id,
        s.store_name,
        s.region                                        as store_region,
        s.store_type,
        s.city                                          as store_city,
        s.state                                         as store_state,

        -- Promotion attributes
        o.promotion_id,
        (o.promotion_id is not null)                    as has_promotion,
        pr.promotion_name,
        pr.discount_type,
        pr.discount_value

    from orders o
    left join customers c
        on o.customer_id = c.customer_id
    left join stores s
        on o.store_id = s.store_id
    left join promotions pr
        on o.promotion_id = pr.promotion_id
)

select * from enriched
