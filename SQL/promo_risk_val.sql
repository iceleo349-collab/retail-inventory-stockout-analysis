
WITH ProductHistory AS (
    SELECT
        [Date],
        [Promotion],
        [Demand],
        [Units_Sold],
        [Inventory_Level]
    FROM dbo.Sales_Data
    WHERE [Store_ID] = 1
      AND [Category] = 'Groceries'
      AND [Product_ID] = 16
)
SELECT
    CASE
        WHEN [Date] < '2023-09-01' THEN 'Training'
        ELSE 'Testing'
    END AS Data_Period,
    [Promotion],
    COUNT(*) AS Total_Records,
    CAST(AVG(1.0 * [Demand]) AS DECIMAL(10, 2))
        AS Average_Demand,
    CAST(AVG(1.0 * [Units_Sold]) AS DECIMAL(10, 2))
        AS Average_Units_Sold,
    CAST(AVG(1.0 * [Inventory_Level]) AS DECIMAL(10, 2))
        AS Average_Inventory,
    SUM(CASE WHEN [Inventory_Level] = 0
             THEN 1 ELSE 0 END) AS Stockout_Records,
    CAST(
        100.0 * SUM(CASE WHEN [Inventory_Level] = 0
                         THEN 1 ELSE 0 END) / COUNT(*)
        AS DECIMAL(10, 2)
    ) AS Stockout_Rate_Percent
FROM ProductHistory
GROUP BY
    CASE
        WHEN [Date] < '2023-09-01' THEN 'Training'
        ELSE 'Testing'
    END,
    [Promotion]
ORDER BY Data_Period, [Promotion];
