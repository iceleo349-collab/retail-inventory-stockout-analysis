
WITH ProductHistory AS (
    SELECT
        [Date],
        [Product_ID],
        [Promotion],
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
        CASE
            WHEN Previous_Inventory < 200 THEN 1
            ELSE 0
        END AS Alert_Flag,
        CASE
            WHEN [Inventory_Level] = 0 THEN 1
            ELSE 0
        END AS Stockout_Flag
    FROM ProductHistory
    WHERE [Date] >= '2023-09-01'
      AND [Date] <= '2024-01-30'
      AND Previous_Inventory IS NOT NULL
)
SELECT
    SUM(CASE WHEN Alert_Flag = 1 AND Stockout_Flag = 1
             THEN 1 ELSE 0 END) AS True_Positives,
    SUM(CASE WHEN Alert_Flag = 1 AND Stockout_Flag = 0
             THEN 1 ELSE 0 END) AS False_Positives,
    SUM(CASE WHEN Alert_Flag = 0 AND Stockout_Flag = 1
             THEN 1 ELSE 0 END) AS False_Negatives,
    SUM(CASE WHEN Alert_Flag = 0 AND Stockout_Flag = 0
             THEN 1 ELSE 0 END) AS True_Negatives,
    CAST(
        100.0 * SUM(CASE WHEN Alert_Flag = 1 AND Stockout_Flag = 1
                         THEN 1 ELSE 0 END)
        / NULLIF(SUM(Alert_Flag), 0)
        AS DECIMAL(10, 2)
    ) AS Alert_Precision_Percent,
    CAST(
        100.0 * SUM(CASE WHEN Alert_Flag = 1 AND Stockout_Flag = 1
                         THEN 1 ELSE 0 END)
        / NULLIF(SUM(Stockout_Flag), 0)
        AS DECIMAL(10, 2)
    ) AS Stockout_Recall_Percent
FROM TestData;
