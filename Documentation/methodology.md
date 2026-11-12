# Methodology

## Purpose and scope

This document describes the SQL analysis in this repository and the definitions used to interpret its results. The work is exploratory: it summarizes recorded inventory, demand, sales, and promotion patterns, then examines simple inventory warning rules. It does not establish causal effects or a production replenishment policy.

The analysis runs against the SQL Server table `dbo.Sales_Data`. The repository contains a collection of focused SQL scripts rather than one end-to-end pipeline. Queries often filter to a particular store, category, or product; check each script's `WHERE` clause before comparing its results with another script.

## Data source and structure

The project uses the synthetic [Retail Store Inventory and Demand Forecasting dataset on Kaggle](https://www.kaggle.com/dsv/11895299). As described in the project README and dataset context, it contains about 76,000 records, 16 columns, and dates from **2022-01-01 through 2024-01-30**. The dataset itself is not stored in this repository. Review Kaggle's current license and terms before reuse.

Fields referenced in the SQL and project description include:

- Identifiers and dimensions: `Date`, `Store_ID`, `Region`, `Product_ID`, `Category`
- Inventory and sales measures: `Inventory_Level`, `Units_Ordered`, `Units_Sold`, `Demand`
- Context fields: `Price`, `Discount`, `Weather`, `Promotion`, `Seasonality`, `Epidemic`, and competitor pricing

The exact imported SQL Server data types and full source schema are not defined in this repository. Use the source file and import configuration to confirm them in a reproduction. Product IDs can recur in different categories, so product comparisons should preserve category; many queries also group by store.

## Preparation and validation

The checked-in SQL does not define a general cleaning pipeline. It queries the imported table directly. Do not assume that records were deduplicated, missing values imputed, invalid values corrected, or outliers removed.

Some scripts perform focused checks or summaries, such as inspecting a selected product's chronological history, checking date coverage for an analysis subset, or reporting record counts and averages. Those are exploratory query checks, not proof that all rows or fields passed comprehensive quality rules. The scripts do not establish a unique row key or resolve ties when multiple records share the same date within a window partition.

Before interpreting results on a newly imported copy, confirm the table and column names, date range, row count, nulls, duplicate grain, numeric ranges, and category/product combinations. These are reproduction checks to perform; they are not cleaning steps claimed to have been performed for the published analysis.

## Definitions and calculations

### Recorded stockout

A record is flagged as a stockout when:

`Stockout_Flag = 1 when Inventory_Level = 0; otherwise 0`

This is a zero-inventory observation under the dataset's recorded field. It is not evidence by itself that a customer wanted to buy an item and could not, nor does it confirm a lost sale.

### Stockout count and rate

For a selected group of rows (for example, a store, product and category, or promotion status):

- **Stockout records** = count of rows where `Inventory_Level = 0`
- **Total records** = count of rows in the group
- **Stockout rate (%)** = stockout records / total records × 100

The denominator is records, not distinct calendar days unless a query explicitly uses distinct dates. Scripts that group by product and category may aggregate across stores; others filter to one store. Always use the query's actual grouping and filters to identify the population represented.

### Demand, units sold, and inventory summaries

The queries calculate arithmetic averages of `Demand`, `Units_Sold`, or `Inventory_Level` for the rows in each group. Some queries also sum units sold. `Demand` recorded on zero-inventory rows is sometimes summed as **demand during stockout records**:

`Demand_During_Stockouts = SUM(Demand where Inventory_Level = 0)`

This is a descriptive sum of the dataset's demand field on those records. It is **not measured lost demand or lost sales**: the data and SQL do not establish that all recorded demand went unfulfilled.

### Promotion comparisons

Several queries calculate stockout rates, average demand, or average inventory separately for `Promotion = 0` and `Promotion = 1`. Where both rates are available, the rate difference in percentage points is:

`Promotion stockout rate (%) − non-promotion stockout rate (%)`

This is an unadjusted observational comparison. It does not control for other conditions and does not show that promotions caused changes in demand, inventory, or stockouts.

### Previous recorded inventory and alert checks

Window-function queries use `LAG(Inventory_Level)` over rows ordered by `Date`, usually partitioned by store and product (and in some scripts category). This retrieves the previous **recorded row** in that partition. It does not guarantee the previous calendar day's inventory. Date gaps, multiple rows on a date, and the unknown underlying record grain limit temporal interpretation.

Some scripts compare the current record's stockout flag with the previous recorded inventory. Candidate warning rules flag a row when that previous inventory is below a chosen unit threshold. The repository explores different cutoffs, including 100, 150, and 200 units, in different scripts and subsets. These are exploratory thresholds, not validated reorder points. The README describes a 150-unit test with two observed stockouts; results are sensitive to the selected products, date window, threshold, and row handling. Do not treat results from different script versions or populations as interchangeable.

Where a validation query reports them:

- **True positive**: alert and a stockout on the evaluated current record
- **False positive**: alert and no stockout on the evaluated current record
- **False negative**: no alert and a stockout on the evaluated current record
- **Precision (%)** = true positives / (true positives + false positives) × 100
- **Recall (%)** = true positives / (true positives + false negatives) × 100

The date-split scripts use dates before **2023-09-01** as the earlier period and dates from **2023-09-01 through 2024-01-30** as the later period. Some scripts omit rows without a previous inventory value; inspect the specific file for its exact filter. The validation set is small, and not every script implements the same threshold or output.

### Estimated days of inventory

A small group of scripts calculates:

`Estimated days of inventory = average Inventory_Level / (sum Units_Sold / count of distinct Date)`

A zero average-sales denominator is handled with `NULLIF` in some versions. This ratio is an exploratory coverage proxy. It assumes that average recorded inventory and average daily units sold are meaningfully comparable; the SQL does not incorporate lead times, future demand, safety stock, or replenishment timing. Labels such as “potential overstock” or risk priorities are rule-based classifications from specific scripts, not validated operational decisions.

## Analytical workflow represented in the SQL folder

The scripts support these broad stages:

1. Summarize inventory, demand, units sold, and zero-inventory records at selected store, product, category, date, or promotion levels.
2. Compare stockout rates and descriptive averages across promotion groups and inspect selected grocery product histories.
3. Explore inventory bands, previous-record inventory, and estimated days of inventory as possible monitoring signals.
4. Test simple thresholds on selected products and a later date period, reporting confusion counts and, in some scripts, precision and recall.
5. Produce rule-based risk or action labels using cutoffs embedded in individual queries.

There is no single canonical run order or shared model definition. Filenames may represent iterations of the analysis. To reproduce a particular README finding, use the corresponding query version and confirm its filters and threshold rather than inferring them from a filename.

## Assumptions and limitations

- **Synthetic data:** results describe this dataset, not a verified retailer's operations.
- **Inventory meaning:** the timing and semantics of `Inventory_Level` (for example, start-of-day, end-of-day, or an intraday snapshot) are not established.
- **Replenishment:** supplier lead times, order placement and receipt times, and replenishment schedules are unknown. No reorder point can be validated without them.
- **Stockout interpretation:** zero recorded inventory does not confirm lost sales; demand during those records is not a measured quantity of unfulfilled demand.
- **Time sequence:** `LAG` compares the prior row in its ordered partition, not necessarily yesterday. The SQL does not consistently specify a tie-breaker for multiple records with the same date.
- **Product identifiers:** IDs may repeat across categories; preserve category and relevant store context when interpreting product results.
- **Promotion interpretation:** comparisons are observational and may reflect other differences between records.
- **Small evaluation samples and exploratory cutoffs:** alert metrics can change materially with a few rows. Thresholds are not calibrated service-level policies or production forecasts.
- **Coverage ratio:** estimated days of inventory is a simple ratio, not a forecast, and does not account for demand variation or supply constraints.

## Reproduction

1. Obtain the dataset from the [Kaggle source](https://www.kaggle.com/dsv/11895299) and review its current license and terms.
2. Import it into SQL Server as `dbo.Sales_Data`, or update the table and column references to match your schema.
3. Confirm the imported columns, types, date range, row count, nulls, duplicate date/product/store combinations, and the grain of the rows. The SQL assumes the named columns exist.
4. Open SQL Server Management Studio and run the relevant script or scripts in the [SQL folder](../SQL/). They are independent analyses, so select files based on the question and read their filters before execution.
5. To use the Power BI report, open the file in [PowerBI](../PowerBI/) and configure its DirectQuery connection to the SQL Server instance containing the table.

The repository includes a short [SQL folder note](../SQL/README) and the project overview in [README.md](../README.md).
