
WITH ProductHistory AS (
    SELECT
        [Date],
        [Product_ID],
        [Promotion],
        [Inventory_Level],
        [Demand],
        LAG([Inventory_Level]) OVER (
            PARTITION BY [Store_ID], [Product_ID]
            ORDER BY [Date]
        ) AS Previous_Inventory,
        LAG([Demand]) OVER (
            PARTITION BY [Store_ID], [Product_ID]
            ORDER BY [Date]
        ) AS Previous_Demand
    FROM dbo.Sales_Data
    WHERE [Store_ID] = 1
      AND [Category] = 'Groceries'
      AND [Product_ID] = 16
)
SELECT
    [Date],
    [Promotion],
    Previous_Inventory,
    Previous_Demand,
    [Inventory_Level] AS Current_Inventory,
    [Demand] AS Current_Demand
FROM ProductHistory
WHERE [Date] >= '2023-09-01'
  AND [Date] <= '2024-01-30'
  AND [Promotion] = 1
  AND [Inventory_Level] = 0
ORDER BY [Date];
