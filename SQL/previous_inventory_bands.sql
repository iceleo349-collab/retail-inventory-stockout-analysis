WITH InventoryHistory AS (
    SELECT
        [Date],
        [Store_ID],
        [Product_ID],
        [Category],
        [Promotion],
        [Inventory_Level],
        [Demand],
        LAG([Inventory_Level]) OVER (
            PARTITION BY [Store_ID], [Product_ID], [Category]
            ORDER BY [Date]
        ) AS Previous_Inventory
    FROM dbo.Sales_Data
    WHERE [Store_ID] = 4
      AND [Product_ID] = 2
      AND [Category] = 'Groceries'
)
SELECT
    CASE
        WHEN Previous_Inventory IS NULL THEN 'No previous record'
        WHEN Previous_Inventory < 100 THEN 'Under 100'
        WHEN Previous_Inventory < 200 THEN '100-199'
        ELSE '200+'
    END AS Previous_Inventory_Band,
    [Promotion],
    COUNT(*) AS Total_Records,
    SUM(CASE
        WHEN [Inventory_Level] = 0 THEN 1
        ELSE 0
    END) AS Stockout_Records,
    CAST(
        100.0 * SUM(CASE
            WHEN [Inventory_Level] = 0 THEN 1
            ELSE 0
        END) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Stockout_Rate_Percent
FROM InventoryHistory
GROUP BY
    CASE
        WHEN Previous_Inventory IS NULL THEN 'No previous record'
        WHEN Previous_Inventory < 100 THEN 'Under 100'
        WHEN Previous_Inventory < 200 THEN '100-199'
        ELSE '200+'
    END,
    [Promotion]
ORDER BY
    Previous_Inventory_Band,
    [Promotion];