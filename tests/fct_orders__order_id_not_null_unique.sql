-- =============================================================
-- Model   : fct_orders
-- Rule    : order_id must never be null and must be unique across all rows in fct_orders
-- Author  : DBT Quality Agent
-- Created : 2026-07-12
-- =============================================================

SELECT
    order_id,
    COUNT(*) AS row_count
FROM {{ ref('fct_orders') }}
GROUP BY order_id
HAVING
    order_id IS NULL
    OR COUNT(*) > 1