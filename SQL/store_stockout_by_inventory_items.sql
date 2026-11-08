
SELECT
    [Store_ID],
    [Region],
    [Product_ID],
    [Category],

    COUNT(*) AS Total_Records,

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
        ) AS DECIMAL(10,4)
    ) / COUNT(*) * 100 AS Stockout_Rate_Percent,

    AVG(CAST([Demand] AS DECIMAL(10,2)))
        AS Average_Demand,

    AVG(CAST([Inventory_Level] AS DECIMAL(10,2)))
        AS Average_Inventory

FROM dbo.sales_data

GROUP BY
    [Store_ID],
    [Region],
    [Product_ID],
    [Category]

HAVING
    SUM(
        CASE
            WHEN [inventory_level] = 0 THEN 1
            ELSE 0
        END
    ) > 0

ORDER BY
    Stockout_Rate_Percent DESC,
    Stockout_Records DESC;
