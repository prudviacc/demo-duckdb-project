-- =============================================================
-- Model   : products
-- Rule    : The price tier label must match the actual unit price, such that products are labeled 'Budget', 'Standard', or 'Premium' according to the correct price range boundaries.
-- Author  : DBT Quality Agent
-- Created : 2026-07-13
-- =============================================================

SELECT *
FROM {{ ref('products') }}
WHERE
    (price_tier = 'Budget'   AND NOT (unit_price < 50))
    OR (price_tier = 'Standard' AND NOT (unit_price >= 50 AND unit_price < 200))
    OR (price_tier = 'Premium'  AND NOT (unit_price >= 200))
    OR (price_tier NOT IN ('Budget', 'Standard', 'Premium'))