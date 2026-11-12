# Retail Inventory Stockout Analysis

A retail inventory analytics project using **SQL Server** and **Power BI** to investigate inventory availability, stockout patterns, promotional demand, and potential inventory-risk signals.

The goal is to turn transaction-level retail data into practical insights that could help inventory and operations teams identify products that may need closer monitoring.

## Project at a glance

| Item | Details |
|---|---|
| Project type | Retail operations / inventory analytics |
| Dataset | Kaggle — Retail Store Inventory and Demand Forecasting |
| Data period | January 1, 2022 – January 30, 2024 |
| Dataset size | Approximately 76,000 records |
| Database | Microsoft SQL Server |
| Analysis | SQL |
| Dashboard | Microsoft Power BI |
| Power BI connection | DirectQuery |

## Business problem

Retailers need to balance product availability against the cost of holding inventory. Too little inventory can contribute to stockouts and missed sales opportunities, while excessive inventory can tie up working capital.

This project explores the following business questions:

1. Which stores, product categories, and products have the highest observed stockout rates?
2. How do inventory levels and demand differ when promotions are active?
3. Are some products showing low inventory coverage or recurring stockout patterns?
4. Can a simple inventory threshold act as an early-warning signal?
5. What additional monitoring or analysis could help improve replenishment decisions?

## Tools and skills demonstrated

- **SQL Server:** data exploration, aggregation, joins, window functions, conditional logic, and inventory-risk calculations.
- **Power BI:** interactive reporting, KPI presentation, filtering, and trend analysis.
- **Business analysis:** translating operational questions into measurable metrics, interpreting patterns, and developing recommendations.
- **Data communication:** documenting assumptions, findings, and analytical limitations.

## Dataset

The project uses the [Retail Store Inventory and Demand Forecasting dataset on Kaggle](https://www.kaggle.com/dsv/11895299).

The dataset includes fields such as date, store, region, product, category, inventory level, units ordered, units sold, demand, price, discount, weather, promotion, competitor pricing, seasonality, and epidemic indicator.

The dataset is not included in this repository. Please obtain it from the original Kaggle source and review its current license and terms before reusing or redistributing it.

## Dashboard

The Power BI report is organized into three pages:

### 1. Inventory Overview
- Store-level stockout rates
- Promotion versus non-promotion comparisons
- Product-level inventory metrics
- Filters for exploring the data by relevant dimensions

### 2. Inventory Risk
- Products and records with lower inventory levels
- Store-level filtering
- Exploratory inventory-risk review using a 150-unit threshold

### 3. Trends
- Stockout counts over time
- Date-range filtering
- Trend exploration to help identify when stockouts occurred

### Dashboard screenshots

#### Inventory Overview
![Inventory Overview dashboard](Screenshots/Screenshot%20(4).png)

#### Inventory Risk
![Inventory Risk dashboard](Screenshots/Screenshot%20(5).png)

#### Trends
![Trends dashboard](Screenshots/Screenshot%20(6).png)

Dashboard screenshots are available in the [Screenshots folder](Screenshots/). The Power BI report is in the [PowerBI folder](PowerBI/).

## Selected findings

The following are exploratory findings from this dataset and should be interpreted in the context of its limitations.

### Promotions and demand
- Average demand was approximately **29.7% higher** on promotional records across the full dataset.
- Average units sold were approximately **26% higher** on promotional records.
- The observed stockout rate was approximately **0.49% without promotions** and **0.62% with promotions**.
- In the grocery category, the observed stockout rate was approximately **0.61% without promotions** and **0.83% with promotions**.

These results suggest that promotional periods coincide with higher demand and somewhat higher stockout rates in this dataset. They do **not** establish that promotions caused stockouts.

### Store and product risk
- Store 4 grocery records showed an observed stockout rate of approximately **0.84% without promotions** and **1.14% with promotions**.
- Store 4, Product 2 (Groceries) showed an observed stockout rate of approximately **0.98% without promotions** and **2.80% with promotions**.
- Store 1, Product 16 (Groceries) had two promotional stockout observations in the chronological test period examined.

These segments may be useful candidates for closer monitoring, but the small number of stockout events means the rates should not be treated as stable forecasts.

### Exploratory inventory alert threshold
A preliminary rule that flagged inventory below **150 units** identified both stockout events in the chronological test period examined. It also generated 25 false-positive alerts: 27 alerts in total, 2 true positives, and 0 false negatives.

That corresponds to 100% recall and approximately 7.4% precision in this small test sample. Because there were only two test-period stockouts and the threshold was exploratory, this is **not a validated forecasting model**. The high false-positive count also means the threshold would need refinement before operational use.

## Business recommendations

Based on the patterns observed, a retail operations team could:

1. **Review promotional replenishment plans.** Compare expected promotional demand with available inventory and replenishment lead times before campaigns begin.
2. **Prioritize high-risk product segments.** Investigate products and store/category combinations with comparatively higher observed stockout rates.
3. **Use alerts as review triggers, not automatic orders.** A low-inventory threshold can prompt a human review, but should be calibrated against lead times, demand variability, and service-level targets.
4. **Improve the data available for replenishment analysis.** Capture supplier lead times, reorder points, order dates, delivery dates, and inventory snapshots to support more reliable inventory planning.
5. **Monitor results over time.** Evaluate stockout rates and alert precision on a larger, later time period before adopting a rule operationally.

## Methodology and limitations

- A stockout is operationally defined in this analysis as a record where **Inventory Level = 0**.
- Demand observed during a stockout is **not confirmed lost sales**. The dataset does not establish how much demand went unfulfilled.
- Promotion comparisons are observational. Other factors may influence demand and stockouts, so the results do not demonstrate causation.
- The dataset appears to be synthetic; findings should not be interpreted as evidence about a real retailer.
- The meaning and timing of the inventory-level field, supplier lead times, and replenishment schedules are not fully established by the available data.
- A previous recorded row is not necessarily the previous calendar day. Time-based comparisons should account for gaps in dates.
- Product identifiers can appear across categories. Product-level analysis should retain both product and category where needed.
- The 150-unit alert threshold is exploratory, not a statistically validated reorder point or production-ready forecasting model.
- The test-period alert evaluation contains only two observed stockouts, so its performance metrics are highly sensitive to individual records.

## Repository structure

```text
retail-inventory-stockout-analysis/
├── README.md
├── Documentation/
├── PowerBI/
├── SQL/
└── Screenshots/
```

- **Documentation/** — supporting methodology and findings documents.
- **PowerBI/** — Power BI report file.
- **SQL/** — SQL scripts used for analysis.
- **Screenshots/** — dashboard screenshots.

## Reproducing the analysis

1. Download the dataset from the [Kaggle source](https://www.kaggle.com/dsv/11895299) and review its license and terms.
2. Install SQL Server and SQL Server Management Studio.
3. Import the dataset into SQL Server as `dbo.Sales_Data`, or adjust the scripts to match your table name and schema.
4. Run the relevant scripts in the [SQL folder](SQL/).
5. Open the Power BI report in the [PowerBI folder](PowerBI/).
6. Update the data source connection to point to your SQL Server instance and imported table.

**Power BI note:** The report uses DirectQuery. Reproducing the interactive report therefore requires access to a SQL Server instance containing the dataset and a correctly configured connection.

## Project objective

This project demonstrates how SQL-based analysis and Power BI reporting can be used together to investigate a practical retail operations problem, communicate findings, and identify where better data or further validation is needed.
