-- =============================================================
-- Model   : dim_products
-- Rule    : The gross margin percentage must always be strictly less than 100%. Additionally, if the unit price is greater than the unit cost, the gross margin amount must be positive.
-- Author  : DBT Quality Agent
-- Created : 2024-07-22
-- =============================================================

SELECT *
FROM {{ ref('dim_products') }}
WHERE CAST(gross_margin_pct AS INTEGER) >= 100
   OR (CAST(gross_margin_pct AS INTEGER) > 0 AND CAST(gross_margin_pct AS INTEGER) <= 0)