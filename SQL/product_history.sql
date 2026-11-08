
WITH ProductHistory AS (
    SELECT
        [Date],
        [Store_ID],
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
      AND [Product_ID] IN (5, 16)
)
SELECT
    [Product_ID],
    [Promotion],
    CASE
        WHEN Previous_Inventory IS NULL THEN 'No Previous Record'
        WHEN Previous_Inventory < 100 THEN 'Under 100'
        WHEN Previous_Inventory < 200 THEN '100-199'
        WHEN Previous_Inventory < 300 THEN '200-299'
        WHEN Previous_Inventory < 400 THEN '300-399'
        ELSE '400+'
    END AS Previous_Inventory_Band,
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN [Inventory_Level] = 0
             THEN 1 ELSE 0 END) AS Current_Stockout_Records,
    CAST(
        100.0 * SUM(CASE WHEN [Inventory_Level] = 0
                         THEN 1 ELSE 0 END) / COUNT(*)
        AS DECIMAL(10, 2)
    ) AS Current_Stockout_Rate
FROM ProductHistory
GROUP BY
    [Product_ID],
    [Promotion],
    CASE
        WHEN Previous_Inventory IS NULL THEN 'No Previous Record'
        WHEN Previous_Inventory < 100 THEN 'Under 100'
        WHEN Previous_Inventory < 200 THEN '100-199'
        WHEN Previous_Inventory < 300 THEN '200-299'
        WHEN Previous_Inventory < 400 THEN '300-399'
        ELSE '400+'
    END
ORDER BY
    [Product_ID],
    [Promotion],
    Previous_Inventory_Band;
