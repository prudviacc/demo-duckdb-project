with products as (
    select * from {{ ref('stg_products') }}
),

categories as (
    select * from {{ ref('stg_categories') }}
),

suppliers as (
    select * from {{ ref('stg_suppliers') }}
),

enriched as (
    select
        p.product_id,
        p.sku,
        p.product_name,
        p.brand,
        p.unit_cost,
        p.unit_price,
        p.weight_kg,
        p.is_active,

        -- Category attributes
        p.category_id,
        c.category_name,
        c.parent_category_id,
        pc.category_name                                            as parent_category_name,
        c.department,

        -- Supplier attributes
        p.supplier_id,
        s.supplier_name,
        s.city                                                      as supplier_city,
        s.country                                                   as supplier_country,
        s.lead_time_days,
        s.is_active                                                 as supplier_is_active,

        -- Derived margin metrics
        round(p.unit_price - p.unit_cost, 2)                        as gross_margin_amount,
        round(
            (p.unit_price - p.unit_cost) / nullif(p.unit_price, 0) * 100,
            2
        )                                                           as gross_margin_pct,

        -- Price tier segmentation
        case
            when p.unit_price < 25    then 'Budget'
            when p.unit_price < 100   then 'Value'
            when p.unit_price < 500   then 'Standard'
            when p.unit_price < 2000  then 'Premium'
            else 'Luxury'
        end                                                         as price_tier

    from products p
    left join categories c
        on p.category_id = c.category_id
    left join categories pc
        on c.parent_category_id = pc.category_id
    left join suppliers s
        on p.supplier_id = s.supplier_id
)

select * from enriched
