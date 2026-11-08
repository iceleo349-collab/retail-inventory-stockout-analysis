SELECT
    [Store_ID],
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
        AS DECIMAL(10, 2)
    ) AS Stockout_Rate_Percent,

    CAST(AVG(1.0 * [Demand]) AS DECIMAL(10, 2))
        AS Average_Demand,

    CAST(AVG(1.0 * [Inventory_Level]) AS DECIMAL(10, 2))
        AS Average_Inventory,

    SUM(CASE
        WHEN [Inventory_Level] = 0 THEN [Demand]
        ELSE 0
    END) AS Demand_During_Stockouts

FROM dbo.Sales_Data
WHERE [Category] = 'Groceries'
GROUP BY
    [Store_ID],
    [Promotion]
ORDER BY
    [Store_ID],
    [Promotion];