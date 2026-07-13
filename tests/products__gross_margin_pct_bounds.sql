-- =============================================================
-- Model   : products
-- Rule    : Find all active products where the gross margin percentage is less than 0 or greater than or equal to 100.
-- Author  : DBT Quality Agent
-- Created : 2026-07-13
-- =============================================================

SELECT *
FROM {{ ref('products') }}
WHERE is_active = TRUE
  AND (
      (gross_margin_percentage < 0)
      OR (gross_margin_percentage >= 100)
  )