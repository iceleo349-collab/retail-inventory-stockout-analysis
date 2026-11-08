
WITH ProductHistory AS (
    SELECT
        [Date],
        [Store_ID],
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
        CASE
            WHEN Previous_Inventory IS NULL THEN 'Unknown'
            WHEN Previous_Inventory < 200 THEN 'Alert'
            ELSE 'No Alert'
        END AS Alert_Status,
        CASE
            WHEN [Inventory_Level] = 0 THEN 1
            ELSE 0
        END AS Is_Stockout
    FROM ProductHistory
    WHERE [Date] >= '2023-09-01'
      AND [Date] <= '2024-01-30'
)
SELECT
    [Product_ID],
    [Promotion],
    Alert_Status,
    COUNT(*) AS Total_Records,
    SUM(Is_Stockout) AS Stockout_Records,
    CAST(
        100.0 * SUM(Is_Stockout) / COUNT(*)
        AS DECIMAL(10, 2)
    ) AS Stockout_Rate_Percent
FROM TestData
GROUP BY
    [Product_ID],
    [Promotion],
    Alert_Status
ORDER BY
    [Product_ID],
    [Promotion],
    Alert_Status;
