# Retail Sales & Inventory — dbt + DuckDB

A production-quality dbt project modelling a multi-store retail business using DuckDB as the local execution engine. Designed to demonstrate an **AI agent use case** where the agent reads this repository and generates dbt test cases from natural language instructions.

## Project Overview

**Domain:** Multi-store Retail — Sales, Inventory, Customers, Promotions, Products

**Scale:** 9 seeds · 22 SQL models · 222 data tests · all passing

| Layer | Models | Materialization |
|---|---|---|
| Staging | 9 | View |
| Intermediate | 4 | View |
| Dimensions | 5 | Table |
| Facts | 4 | Table |

## Prerequisites

- **Python 3.8+**
- **pip**

## Setup

### 1. Create and activate a virtual environment

```powershell
# Windows (PowerShell)
python -m venv dbt-env
.\dbt-env\Scripts\Activate.ps1
```

```bash
# macOS / Linux
python -m venv dbt-env
source dbt-env/bin/activate
```

### 2. Install dependencies

```bash
pip install --upgrade pip
pip install dbt-duckdb
```

### 3. Verify

```bash
dbt --version   # expect dbt-core 1.8+
```

## Running the Project

Run all commands from the project root directory with the virtual environment active.

```bash
# 1. Drop and recreate seed tables (use --full-refresh on first run)
dbt seed --profiles-dir . --full-refresh

# 2. Build all 22 models
dbt run --profiles-dir .

# 3. Run all 222 tests
dbt test --profiles-dir .

# 4. Generate documentation
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
```

Expected results: `PASS=9` seeds, `PASS=22` models, `PASS=222` tests.

## Project Structure

```
demo_duckdb_project/
├── seeds/                          # Raw CSV source data (9 files)
│   ├── raw_categories.csv          # Product category hierarchy (12 rows)
│   ├── raw_suppliers.csv           # Supplier master (10 rows)
│   ├── raw_products.csv            # Product catalog / SKUs (20 rows)
│   ├── raw_stores.csv              # Store locations (10 rows)
│   ├── raw_customers.csv           # Customer accounts (20 rows)
│   ├── raw_promotions.csv          # Promotional campaigns (10 rows)
│   ├── raw_orders.csv              # Order headers (20 rows)
│   ├── raw_order_items.csv         # Order line items (40 rows)
│   └── raw_inventory.csv           # Store-level stock levels (20 rows)
│
├── models/
│   ├── staging/                    # 1:1 with seeds — type casting only
│   │   ├── stg_categories.sql
│   │   ├── stg_suppliers.sql
│   │   ├── stg_products.sql
│   │   ├── stg_stores.sql
│   │   ├── stg_customers.sql
│   │   ├── stg_promotions.sql
│   │   ├── stg_orders.sql
│   │   ├── stg_order_items.sql
│   │   ├── stg_inventory.sql
│   │   └── schema.yml
│   │
│   ├── intermediate/               # Joins, enrichment, business logic
│   │   ├── int_products_enriched.sql
│   │   ├── int_orders_enriched.sql
│   │   ├── int_order_items_enriched.sql
│   │   ├── int_inventory_status.sql
│   │   └── schema.yml
│   │
│   └── marts/
│       ├── dimensions/             # Materialized tables — master reference data
│       │   ├── dim_customers.sql
│       │   ├── dim_products.sql
│       │   ├── dim_stores.sql
│       │   ├── dim_promotions.sql
│       │   ├── dim_dates.sql       # Date spine (2023-01-01 to 2024-12-31)
│       │   └── schema.yml
│       │
│       └── facts/                  # Materialized tables — transactional metrics
│           ├── fct_orders.sql
│           ├── fct_order_items.sql
│           ├── fct_inventory_snapshot.sql
│           ├── fct_daily_sales.sql
│           └── schema.yml
│
├── tests/                          # Singular (custom SQL) tests
│   ├── assert_line_total_matches_quantity_times_price.sql
│   ├── assert_products_price_exceeds_cost.sql
│   ├── assert_inventory_available_qty_non_negative.sql
│   ├── assert_promotion_end_date_after_start_date.sql
│   └── assert_cancelled_orders_excluded_from_daily_sales.sql
│
├── profiles.yml                    # DuckDB connection config
├── dbt_project.yml                 # Project config and materialization settings
└── dev_data.duckdb                 # Local DuckDB file (auto-created by dbt seed)
```

## Model DAG

```
9 seeds (raw_*)
      │
9 staging views (stg_*)
      │
4 intermediate views (int_*)
      │
  ┌───┴────────────────────┐
  │                        │
5 dimension tables      4 fact tables
(dim_*)                 (fct_*)
```

## Model Details

### Staging Layer — `models/staging/`

Pure extraction layer. No business logic — only explicit type casting (`::integer`, `::decimal`, `::date`, `::boolean`) and column renaming for consistency.

### Intermediate Layer — `models/intermediate/`

| Model | Joins | Key derived columns |
|---|---|---|
| `int_products_enriched` | products + categories (self-join) + suppliers | `gross_margin_pct`, `price_tier` |
| `int_orders_enriched` | orders + customers + stores + promotions | `is_completed`, `is_cancelled`, `has_promotion`, date parts |
| `int_order_items_enriched` | order items + enriched orders + enriched products | `margin_per_unit`, `total_margin_amount`, `margin_pct` |
| `int_inventory_status` | inventory + products + stores | `quantity_available`, `stock_status`, `needs_reorder` |

### Dimension Layer — `models/marts/dimensions/`

| Model | Grain | Notable attributes |
|---|---|---|
| `dim_customers` | One row per customer | `segment`, `customer_tenure_segment`, `customer_status` |
| `dim_products` | One row per SKU | `price_tier`, `gross_margin_pct`, `product_status`, `department` |
| `dim_stores` | One row per store | `region`, `store_type`, `store_size_bucket`, `store_status` |
| `dim_promotions` | One row per promotion | `discount_type`, `promotion_duration_days`, `promotion_status` |
| `dim_dates` | One row per calendar day | `is_weekend`, `quarter_label`, `year_month` |

### Fact Layer — `models/marts/facts/`

| Model | Grain | Key metrics |
|---|---|---|
| `fct_orders` | One row per order | `order_net_total`, `order_margin_pct`, `item_count`, `total_units_sold` |
| `fct_order_items` | One row per order line item | `line_total`, `margin_per_unit`, `margin_pct` |
| `fct_inventory_snapshot` | One row per store-product | `quantity_available`, `stock_status`, `inventory_cost_value` |
| `fct_daily_sales` | One row per (date, store, category) — **completed orders only** | `gross_revenue`, `net_revenue`, `total_margin`, `avg_order_value` |

## Data Quality Tests

### Schema tests (222 total — defined in `schema.yml` files)

- `unique` + `not_null` on all primary keys
- `accepted_values` on 8 enum columns: `order_status`, `payment_method`, `segment`, `store_type`, `price_tier`, `stock_status`, `discount_type`, `promotion_status`
- `relationships` tests on 6 foreign key pairs: order_items → orders, order_items → products, orders → customers, orders → stores, inventory → products, inventory → stores

### Singular tests (5 — defined in `tests/`)

| Test file | Business rule |
|---|---|
| `assert_line_total_matches_quantity_times_price.sql` | `line_total = quantity * unit_price_at_sale - discount_amount` (±$0.01) |
| `assert_products_price_exceeds_cost.sql` | Active products must have `unit_price > unit_cost` |
| `assert_inventory_available_qty_non_negative.sql` | `quantity_on_hand - quantity_reserved >= 0` |
| `assert_promotion_end_date_after_start_date.sql` | `end_date > start_date` for all promotions |
| `assert_cancelled_orders_excluded_from_daily_sales.sql` | `fct_daily_sales` contains only COMPLETED orders |

## Querying Results

### DuckDB CLI

```sql
-- Connect
duckdb dev_data.duckdb

-- Sales summary by region
SELECT store_region, SUM(net_revenue) AS total_revenue, SUM(total_margin) AS total_margin
FROM main.fct_daily_sales
GROUP BY store_region ORDER BY total_revenue DESC;

-- Low-stock products needing reorder
SELECT store_name, product_name, quantity_on_hand, reorder_point, stock_status
FROM main.fct_inventory_snapshot
WHERE needs_reorder = true ORDER BY quantity_on_hand;

-- Top customers by order value
SELECT customer_full_name, customer_segment, COUNT(*) AS orders, SUM(order_net_total) AS lifetime_value
FROM main.fct_orders
WHERE is_completed = true
GROUP BY customer_full_name, customer_segment ORDER BY lifetime_value DESC;
```

### Python

```python
import duckdb

con = duckdb.connect('./dev_data.duckdb')

# Daily sales summary
df = con.execute('SELECT * FROM main.fct_daily_sales ORDER BY sale_date').df()
print(df.head())

# Inventory snapshot
inv = con.execute('SELECT * FROM main.fct_inventory_snapshot WHERE needs_reorder = true').df()
print(inv)
```

## AI Agent Demo

This project is structured so that an AI agent can read the SQL models and `schema.yml` files and generate accurate dbt test cases from natural language instructions such as:

- *"Add a test that verifies every order item belongs to an order that exists"*
- *"Test that gross margin percentage is always between 0 and 100 for active products"*
- *"Ensure daily sales only includes completed orders"*

The `schema.yml` files contain column descriptions with explicit business rules, value ranges, arithmetic formulas, and enum lists — all the context needed for automated test generation.

## Troubleshooting

**`Error: columns do not match`** — Run `dbt seed --full-refresh` to drop and recreate seed tables.

**`Cannot find dbt command`** — Activate the virtual environment first: `.\dbt-env\Scripts\Activate.ps1` (Windows) or `source dbt-env/bin/activate` (Mac/Linux).

**`Credentials in profile invalid`** — Ensure `profiles.yml` is in the project root and run `dbt` with `--profiles-dir .`.

**Models not updating** — Run `dbt clean` then re-run `dbt seed --full-refresh && dbt run`.

## Resources

- [dbt Documentation](https://docs.getdbt.com/docs/introduction)
- [dbt DuckDB Adapter](https://github.com/dbt-labs/dbt-duckdb)
- [DuckDB Documentation](https://duckdb.org/docs/)
