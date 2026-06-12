# GitHub Actions - dbt CI/CD Pipeline Guide

This document explains the automated GitHub Actions workflows that validate and test your dbt project.

## Overview

Two workflows are configured to ensure code quality and project integrity:

1. **dbt PR Validation** (`dbt-pr-validation.yml`) - Runs on pull requests
2. **dbt CI/CD Pipeline** (`dbt-ci.yml`) - Runs on pushes to main branch

## Workflow 1: dbt PR Validation

**Triggers**: Pull requests to `main` branch (when dbt files change)

**Purpose**: Validate changes before merging

### What It Does:

```
1. Parse dbt project (syntax & schema validation)
2. Load seed data (dbt seed)
3. Build all models (dbt run)
4. Run data quality tests (dbt test)
5. Generate documentation (dbt docs generate)
6. Post results as PR comment
7. Upload artifacts for review
```

### PR Comment Example:

When you open a PR, the workflow automatically comments with:
```
## dbt Validation Results

✅ Seed: Data loaded successfully
✅ Run: All models executed
ℹ️ Test: Quality checks completed (review in artifacts)

### Next Steps
- Review test results in the `dbt-artifacts` artifact
- Check for any data quality issues that need attention
- Merge when ready!
```

### Artifacts Available:

- **dbt-artifacts**: Contains `target/` directory with:
  - `run_results.json` - Model execution results
  - `test_results.json` - Test results
  - Compiled SQL files
  - All dbt artifacts

- **dbt-manifest**: The manifest.json for reference

## Workflow 2: dbt CI/CD Pipeline

**Triggers**: 
- Pushes to `main` branch (after PR merge)
- Manual workflow dispatch

**Purpose**: Validate production code after merge

### What It Does:

```
1. Checkout code
2. Set up Python environment
3. Install dbt-duckdb
4. Run dbt seed (load data)
5. Run dbt run (execute models)
6. Run dbt test (validate data quality)
7. Generate documentation
8. Upload artifacts
9. Create job summary
```

### Execution Flow:

```
├── dbt seed
│   └── Loads seeds/raw_products.csv
├── dbt run
│   └── Executes all models in dependency order
│       ├── stg_products
│       ├── int_products_cleaned
│       ├── dim_products
│       └── fct_products_summary
└── dbt test
    └── Runs all tests
        ├── Schema tests (unique, not_null)
        └── Singular tests (assert_product_price_is_non_negative)
```

### GitHub Actions Tab View:

Navigate to **Actions** tab in your GitHub repository to:
- View workflow execution history
- Check logs for each step
- Download artifacts
- Rerun workflows

## Test Handling

### Expected Test Behavior:

Our project includes a **data quality test** that intentionally catches issues:

```sql
-- assert_product_price_is_non_negative.sql
-- Tests for negative product prices
SELECT * FROM stg_products WHERE product_price < 0
```

**Expected Result**: This test **FAILS** because our seed data includes:
- Product ID 5: "Defective Item" with price -10.00

**This is intentional!** It demonstrates:
- ✅ Tests are working correctly
- ✅ Data quality issues are being caught
- ✅ System properly identifies bad data

### If Test Fails:

The workflow will:
1. Continue executing (not blocked)
2. Upload artifacts with detailed failure info
3. Show in GitHub Actions results
4. You can review the `run_results.json` to understand failures

## Monitoring & Debugging

### View Workflow Results:

1. Go to **Actions** tab in GitHub
2. Click on the workflow run
3. View logs for each step
4. Check artifacts section

### Download Artifacts:

After workflow completes:
1. Go to workflow run page
2. Scroll to **Artifacts** section
3. Download `dbt-artifacts` zip file
4. Extract and review:
   - `target/run_results.json` - Model run results
   - `target/test_results.json` - Test execution details

### Example Artifact Structure:

```
dbt-artifacts/
├── compiled/
│   └── demo_duckdb_project/
│       ├── models/
│       ├── tests/
│       └── ...
├── run/
│   └── demo_duckdb_project/
│       ├── models/
│       └── tests/
├── manifest.json
├── run_results.json
└── test_results.json
```

## Common Scenarios

### Scenario 1: PR with Model Changes

1. Create branch and modify a model
2. Push to GitHub
3. Create Pull Request
4. Workflow automatically runs:
   - ✅ Validates syntax
   - ✅ Tests dependencies
   - ✅ Comments with results
5. Review results in PR comment
6. Merge when satisfied

### Scenario 2: Data Quality Issue

1. Seed data has unexpected value
2. PR validation workflow runs
3. Test catches the issue
4. Workflow continues (doesn't fail)
5. Check artifacts for details
6. Fix data or adjust test
7. Commit and push

### Scenario 3: Model Dependency Error

1. Change model breaks upstream models
2. `dbt run` step will fail
3. Workflow shows error logs
4. Review compile errors in artifacts
5. Fix and re-push

## Customization

### Modify Workflows:

Edit workflow files in:
```
.github/workflows/
├── dbt-ci.yml              # Main CI pipeline
└── dbt-pr-validation.yml   # PR validation
```

### Common Customizations:

**Change Python version:**
```yaml
python-version: '3.10'  # Change from 3.11
```

**Add Slack notifications:**
```yaml
- name: Send Slack notification
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
```

**Run only specific models:**
```yaml
dbt run --select path:models/marts  # Only mart models
```

**Run only changed models:**
```yaml
dbt run --select state:modified+
```

## Best Practices

1. **Always use PR workflow** - Never push directly to main
2. **Review test results** - Check artifacts before merging
3. **Fix data issues** - Don't ignore failing tests
4. **Meaningful commits** - Write clear commit messages
5. **Document changes** - Update model YML files with descriptions

## Troubleshooting

### Workflow fails with "Permission denied"

- Re-authenticate with workflow scope
- Run: `gh auth refresh -h github.com -s repo,gist,workflow`

### Tests fail unexpectedly

- Download `dbt-artifacts`
- Check `test_results.json` for details
- Review test query in `compiled/` directory

### Seed data not loading

- Verify `seeds/raw_products.csv` format
- Check dbt seed logs in artifacts
- Ensure CSV is valid and properly formatted

### Models not executing

- Check model syntax in workflow logs
- Verify `ref()` and `source()` macros are correct
- Download artifacts and review compiled SQL

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [dbt Documentation](https://docs.getdbt.com)
- [DuckDB Documentation](https://duckdb.org/docs)
- [dbt DuckDB Adapter](https://github.com/dbt-labs/dbt-duckdb)

## Example Commands for Local Testing

Test your workflows locally before pushing:

```bash
# Run locally in project directory
cd demo_duckdb_project

# Seed data
dbt seed --profiles-dir .

# Run models
dbt run --profiles-dir .

# Test
dbt test --profiles-dir .

# Generate docs
dbt docs generate --profiles-dir .
```

Compare local results with GitHub Actions results to ensure consistency.
