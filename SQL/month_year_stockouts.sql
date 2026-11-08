SELECT
    [Store_ID],
    [Region],
    [Product_ID],
    YEAR([Date]) AS Sales_Year,
    MONTH([Date]) AS Sales_Month,
    [Promotion],

    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN [Inventory_Level] = 0 THEN 1
            ELSE 0
        END
    ) AS Stockout_Records,

    CAST(
        100.0 * SUM(
            CASE
                WHEN [Inventory_Level] = 0 THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)
        AS DECIMAL(10, 2)
    ) AS Stockout_Rate_Percent,

    AVG(CAST([Demand] AS DECIMAL(18, 2)))
        AS Average_Demand,

    AVG(CAST([Inventory_Level] AS DECIMAL(18, 2)))
        AS Average_Inventory

FROM dbo.Sales_Data
WHERE [Category] = 'Groceries'
  AND (
       ([Store_ID] = 4 AND [Product_ID] = 2)
    OR ([Store_ID] = 2 AND [Product_ID] = 11)
    OR ([Store_ID] = 5 AND [Product_ID] = 9)
    OR ([Store_ID] = 3 AND [Product_ID] = 15)
  )
GROUP BY
    [Store_ID],
    [Region],
    [Product_ID],
    YEAR([Date]),
    MONTH([Date]),
    [Promotion]
ORDER BY
    [Store_ID],
    [Product_ID],
    Sales_Year,
    Sales_Month,
    [Promotion];