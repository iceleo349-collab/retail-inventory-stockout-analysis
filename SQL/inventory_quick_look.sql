WITH InventoryHistory AS (
    SELECT
        [Date],
        [Promotion],
        [Inventory_Level],
        [Demand],
        [Units_Sold],
        [Units_Ordered],
        LAG([Inventory_Level]) OVER (
            PARTITION BY [Store_ID], [Product_ID], [Category]
            ORDER BY [Date]
        ) AS Previous_Inventory,
        LAG([Demand]) OVER (
            PARTITION BY [Store_ID], [Product_ID], [Category]
            ORDER BY [Date]
        ) AS Previous_Demand
    FROM dbo.Sales_Data
    WHERE [Store_ID] = 4
      AND [Product_ID] = 2
      AND [Category] = 'Groceries'
)
SELECT
    [Date],
    [Promotion],
    Previous_Inventory,
    Previous_Demand,
    [Demand],
    [Units_Sold],
    [Units_Ordered]
FROM InventoryHistory
WHERE [Inventory_Level] = 0
ORDER BY [Date];