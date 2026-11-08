SELECT
    [Store_ID],
    [Region],

    COUNT(*) AS Total_Records,

    SUM([Units_Sold]) AS Total_Units_Sold,

    AVG(CAST([Units_Sold] AS DECIMAL(10,2)))
        AS Average_Units_Sold,

    AVG(CAST([Demand] AS DECIMAL(10,2)))
        AS Average_Demand,

    AVG(CAST([Inventory_Level] AS DECIMAL(10,2)))
        AS Average_Inventory,

    SUM(
        CASE
            WHEN [Inventory_Level] = 0 THEN 1
            ELSE 0
        END
    ) AS Stockout_Records,

    CAST(
        SUM(
            CASE
                WHEN [Inventory_Level] = 0 THEN 1
                ELSE 0
            END
        ) AS DECIMAL(10,2)
    ) / COUNT(*) * 100 AS Stockout_Rate_Percent

FROM dbo.sales_data

GROUP BY
    [Store_ID],
    [Region]

ORDER BY
    Stockout_Rate_Percent DESC;