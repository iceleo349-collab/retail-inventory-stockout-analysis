
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
        [Product_ID],
        [Promotion],
        Previous_Inventory,
        CASE WHEN [Inventory_Level] = 0
             THEN 1 ELSE 0 END AS Stockout_Flag
    FROM ProductHistory
    WHERE [Date] >= '2023-09-01'
      AND [Date] <= '2024-01-30'
      AND Previous_Inventory IS NOT NULL
)
SELECT
    [Product_ID],
    [Promotion],
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN Previous_Inventory < 150
             THEN 1 ELSE 0 END) AS Alert_Records,
    SUM(CASE WHEN Previous_Inventory < 150
              AND Stockout_Flag = 1
             THEN 1 ELSE 0 END) AS True_Positives,
    SUM(CASE WHEN Previous_Inventory < 150
              AND Stockout_Flag = 0
             THEN 1 ELSE 0 END) AS False_Positives,
    SUM(CASE WHEN Previous_Inventory >= 150
              AND Stockout_Flag = 1
             THEN 1 ELSE 0 END) AS False_Negatives
FROM TestData
GROUP BY [Product_ID], [Promotion]
ORDER BY [Product_ID], [Promotion];
