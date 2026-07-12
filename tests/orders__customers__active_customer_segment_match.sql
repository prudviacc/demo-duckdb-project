-- =============================================================
-- Model   : orders
-- Joins   : customers
-- Rule    : Every order must reference a valid active customer, and the customer segment recorded in the order must match the segment in the customer dimension table.
-- Author  : DBT Quality Agent
-- Created : 2026-07-12
-- =============================================================

SELECT
    o.order_id,
    o.customer_id,
    o.customer_segment AS order_customer_segment,
    c.customer_segment AS dim_customer_segment,
    c.is_active
FROM {{ ref('orders') }} o
LEFT JOIN {{ ref('customers') }} c
    ON o.customer_id = c.customer_id
WHERE
    -- Customer does not exist in the customer dimension
    c.customer_id IS NULL
    -- Customer exists but is not active
    OR c.is_active = FALSE
    OR c.is_active = 0
    -- Customer segment in order does not match the customer dimension
    OR (
        c.customer_id IS NOT NULL
        AND o.customer_segment <> c.customer_segment
    )