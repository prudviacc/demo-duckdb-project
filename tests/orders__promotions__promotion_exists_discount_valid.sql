-- =============================================================
-- Model   : orders
-- Joins   : promotions
-- Rule    : Orders that reference a promotion must have a corresponding record in the promotions table and the discount amount must not exceed the order subtotal.
-- Author  : DBT Quality Agent
-- Created : 2026-07-12
-- =============================================================

SELECT
    o.*
FROM {{ ref('orders') }} o
LEFT JOIN {{ ref('promotions') }} p
    ON o.promotion_id = p.promotion_id
WHERE
    o.promotion_id IS NOT NULL
    AND (
        -- Referential integrity violation: no matching promotion record found
        p.promotion_id IS NULL
        -- Discount amount exceeds order subtotal
        OR ABS(o.discount_amount - o.subtotal) > 0.01
            AND o.discount_amount > o.subtotal
    )