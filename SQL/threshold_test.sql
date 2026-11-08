
WITH ProductHistory AS (
    SELECT
        [Date],
        [Product_ID],
        [Inventory_Level],
        LAG([Inventory_Level]) OVER (
            PARTITION BY [Store_ID], [Product_ID]
            ORDER BY [Date]
        ) AS Previous_Inventory
    FROM dbo.Sales_Data
    WHERE [Store_ID] = 1
      AND [Category] = 'Groceries'
      AND [Product_ID] IN (5, 16)
),
TestData AS (
    SELECT
        Previous_Inventory,
        CASE WHEN [Inventory_Level] = 0
             THEN 1 ELSE 0 END AS Stockout_Flag
    FROM ProductHistory
    WHERE [Date] >= '2023-09-01'
      AND [Date] <= '2024-01-30'
      AND Previous_Inventory IS NOT NULL
),
Thresholds AS (
    SELECT 100 AS Threshold_Units
    UNION ALL SELECT 150
    UNION ALL SELECT 200
)
SELECT
    t.Threshold_Units,
    SUM(CASE WHEN d.Previous_Inventory < t.Threshold_Units
             AND d.Stockout_Flag = 1 THEN 1 ELSE 0 END)
        AS True_Positives,
    SUM(CASE WHEN d.Previous_Inventory < t.Threshold_Units
             AND d.Stockout_Flag = 0 THEN 1 ELSE 0 END)
        AS False_Positives,
    SUM(CASE WHEN d.Previous_Inventory >= t.Threshold_Units
             AND d.Stockout_Flag = 1 THEN 1 ELSE 0 END)
        AS False_Negatives,
    CAST(
        100.0 * SUM(CASE
            WHEN d.Previous_Inventory < t.Threshold_Units
             AND d.Stockout_Flag = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE
            WHEN d.Previous_Inventory < t.Threshold_Units
             AND d.Stockout_Flag = 1 THEN 1 ELSE 0 END)
          + SUM(CASE
            WHEN d.Previous_Inventory < t.Threshold_Units
             AND d.Stockout_Flag = 0 THEN 1 ELSE 0 END), 0)
        AS DECIMAL(10, 2)
    ) AS Precision_Percent,
    CAST(
        100.0 * SUM(CASE
            WHEN d.Previous_Inventory < t.Threshold_Units
             AND d.Stockout_Flag = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(d.Stockout_Flag), 0)
        AS DECIMAL(10, 2)
    ) AS Recall_Percent
FROM Thresholds t
CROSS JOIN TestData d
GROUP BY t.Threshold_Units
ORDER BY t.Threshold_Units;
