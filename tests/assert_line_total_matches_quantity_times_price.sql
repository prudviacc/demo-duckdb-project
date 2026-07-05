-- Business rule: line_total must equal (quantity * unit_price_at_sale) - discount_amount.
-- Tolerance of $0.01 is allowed for floating-point rounding.
-- Returns rows where the stored line_total does not match the expected calculation.

select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price_at_sale,
    discount_amount,
    line_total,
    round(quantity * unit_price_at_sale - discount_amount, 2) as expected_line_total
from {{ ref('fct_order_items') }}
where abs(line_total - (quantity * unit_price_at_sale - discount_amount)) > 0.01
