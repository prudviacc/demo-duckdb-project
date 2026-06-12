# Demo DuckDB dbt Project

A lightweight dbt project demonstrating a complete data warehouse structure using DuckDB as the local execution engine.

## Project Overview

This project includes:
- **Staging Models**: Raw data validation and basic transformations
- **Intermediate Models**: Data cleaning, categorization, and quality flags
- **Dimension Models**: Enriched master tables for dimensions
- **Fact Models**: Aggregated metrics and analytics tables
- **Data Quality Tests**: Singular and schema-based tests to catch invalid data

## Prerequisites

- **Python 3.8+** installed on your machine
- **pip** (Python package manager)
- Basic familiarity with dbt concepts

## Setup Instructions

### 1. Create and Activate Virtual Environment

```bash
# Create virtual environment
python -m venv dbt-env

# Activate virtual environment
# On Windows (PowerShell):
.\dbt-env\Scripts\Activate.ps1

# On Windows (Command Prompt):
dbt-env\Scripts\activate.bat

# On macOS/Linux:
source dbt-env/bin/activate
```

### 2. Install Dependencies

```bash
# Upgrade pip
pip install --upgrade pip

# Install dbt-duckdb (includes dbt-core and DuckDB)
pip install dbt-duckdb
```

### 3. Verify Installation

```bash
dbt --version
```

You should see output like: `dbt version 1.8+`

## Running the Project

Navigate to the project directory and follow these steps:

### Step 1: Load Seed Data

```bash
dbt seed --profiles-dir .
```

This loads the sample CSV data from `seeds/raw_products.csv` into the DuckDB database.

**Expected output**: `1 of 1 OK loaded seed file main.raw_products [INSERT 5 in X.XXs]`

### Step 2: Run Models

```bash
dbt run --profiles-dir .
```

This executes all SQL models in the following order:
1. `stg_products` - Staging model (basic transformation)
2. `int_products_cleaned` - Intermediate model (adds categorization and flags)
3. `dim_products` - Dimension model (enriched product table)
4. `fct_products_summary` - Fact model (aggregated metrics)

**Expected output**: `Finished running 1 table model, 5 view models in X seconds`

### Step 3: Run Tests

```bash
dbt test --profiles-dir .
```

This executes all data quality tests including:
- Uniqueness and not-null tests on key columns
- Custom singular test for negative prices (will intentionally fail)

**Expected output**: 
- 9 tests PASSED ✓
- 2 tests FAILED (including our data quality test catching the -$10.00 product)

## Project Structure

```
demo_duckdb_project/
├── seeds/
│   └── raw_products.csv          # Raw product data (5 sample rows)
├── models/
│   ├── stg_products.sql          # Staging: pulls from seed
│   ├── int_products_cleaned.sql  # Intermediate: adds price tiers & flags
│   ├── dim_products.sql          # Dimension: enriched product table
│   ├── fct_products_summary.sql  # Fact: aggregated metrics
│   └── schema.yml                # Model documentation and tests
├── tests/
│   └── assert_product_price_is_non_negative.sql  # Custom test for data quality
├── profiles.yml                  # DuckDB connection configuration
├── dbt_project.yml              # Project configuration
└── dev_data.duckdb              # Local DuckDB database file (created after dbt seed)
```

## Models Overview

### Staging Layer (`stg_products`)
- **Purpose**: Extract raw data from seeds
- **Columns**: product_id, product_name, product_price
- **Data Quality**: Direct pass-through from raw data

### Intermediate Layer (`int_products_cleaned`)
- **Purpose**: Data cleaning and business logic
- **Columns**: 
  - `price_tier`: Categorizes products (Budget, Standard, Premium, Invalid, Free)
  - `has_data_quality_issue`: Flag for records with issues (e.g., negative prices)
- **Logic**: Identifies problematic records before they reach downstream models

### Dimension Layer (`dim_products`)
- **Purpose**: Master product table for analytics
- **Columns**: 
  - `product_status`: Active or Flagged (based on quality issues)
  - `loaded_at`: Timestamp when record was processed
- **Use**: Primary dimension table for fact tables and reports

### Fact Layer (`fct_products_summary`)
- **Purpose**: Aggregated metrics across the catalog
- **Columns**:
  - `total_products`: Count of all products
  - `distinct_price_tiers`: Number of unique price categories
  - `products_with_issues`: Count of flagged products
  - `avg_product_price`: Average price across catalog
  - `min_product_price` / `max_product_price`: Price range
- **Use**: Reporting and KPI calculations

## Querying Results

### Using DuckDB CLI

```bash
# Connect to the database
duckdb dev_data.duckdb

# Query a model
SELECT * FROM main.dim_products ORDER BY product_id;

# Query the fact table
SELECT * FROM main.fct_products_summary;
```

### Using Python

```python
import duckdb

con = duckdb.connect('./dev_data.duckdb')

# Query models
results = con.execute('SELECT * FROM main.dim_products').fetchall()
for row in results:
    print(row)
```

## Data Quality Tests

The project includes two types of tests:

### Schema Tests (Automated)
Defined in `models/schema.yml`:
- `unique` tests on product_id columns
- `not_null` tests on primary keys

### Singular Tests (Custom)
Custom SQL queries in `tests/`:
- `assert_product_price_is_non_negative.sql` - Catches records with negative prices
  - This test will FAIL intentionally (by design) because the seed data includes a -$10.00 product
  - This demonstrates how dbt identifies data quality issues

## Troubleshooting

### Error: "Credentials in profile invalid"
- Ensure `profiles.yml` is in the project root directory
- Verify the `path` and `database` fields match (e.g., `path: ./dev_data.duckdb` → `database: dev_data`)

### Error: "Cannot find dbt command"
- Verify virtual environment is activated: `dbt-env\Scripts\Activate.ps1` (Windows) or `source dbt-env/bin/activate` (Mac/Linux)
- Verify dbt-duckdb is installed: `pip list | grep dbt`

### Models not updating
- Run `dbt clean` to remove previous artifacts
- Re-run `dbt seed` and `dbt run`

## Next Steps

- Explore the SQL models in the `models/` directory
- Modify the price tier logic in `int_products_cleaned.sql`
- Add new models that aggregate by price_tier
- Create additional singular tests for other data quality rules
- Read the [dbt documentation](https://docs.getdbt.com/docs/introduction) for advanced features

## Resources

- [dbt Documentation](https://docs.getdbt.com/docs/introduction)
- [dbt DuckDB Adapter](https://github.com/dbt-labs/dbt-duckdb)
- [DuckDB Documentation](https://duckdb.org/docs/)
- [dbt Community](https://community.getdbt.com/)
