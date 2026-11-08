WITH InventoryHistory AS (
    SELECT
        [Date],
        [Store_ID],
        [Product_ID],
        [Category],
        [Promotion],
        [Inventory_Level],
        [Demand],
        [Units_Sold],
        [Units_Ordered],

        LAG([Date]) OVER (
            PARTITION BY [Store_ID], [Product_ID], [Category]
            ORDER BY [Date]
        ) AS Previous_Date,

        LAG([Inventory_Level]) OVER (
            PARTITION BY [Store_ID], [Product_ID], [Category]
            ORDER BY [Date]
        ) AS Previous_Inventory,

        LAG([Demand]) OVER (
            PARTITION BY [Store_ID], [Product_ID], [Category]
            ORDER BY [Date]
        ) AS Previous_Demand,

        LAG([Units_Ordered]) OVER (
            PARTITION BY [Store_ID], [Product_ID], [Category]
            ORDER BY [Date]
        ) AS Previous_Units_Ordered,

        LAG([Promotion]) OVER (
            PARTITION BY [Store_ID], [Product_ID], [Category]
            ORDER BY [Date]
        ) AS Previous_Promotion

    FROM dbo.Sales_Data
    WHERE [Store_ID] = 4
      AND [Product_ID] = 2
      AND [Category] = 'Groceries'
)
SELECT *
FROM InventoryHistory
WHERE [Inventory_Level] = 0
ORDER BY [Date];