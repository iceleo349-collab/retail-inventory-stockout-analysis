
SELECT
    [Store_ID],
    [Region],
    [Product_ID],
    [Category],

    SUM(
        CASE
            WHEN [Inventory_Level] = 0 THEN 1
            ELSE 0
        END
    ) AS Stockout_Records,

    SUM(
        CASE
            WHEN [Inventory_Level] = 0 THEN [Demand]
            ELSE 0
        END
    ) AS Demand_During_Stockouts,

    AVG(CAST([Demand] AS DECIMAL(10,2)))
        AS Average_Demand,

    AVG(CAST([Inventory_Level] AS DECIMAL(10,2)))
        AS Average_Inventory,

    AVG(CAST([Units_Sold] AS DECIMAL(10,2)))
        AS Average_Units_Sold

FROM dbo.sales_data

WHERE
    [Category] = 'Groceries'

GROUP BY
    [Store_ID],
    [Region],
    [Product_ID],
    [Category]

HAVING
    SUM(
        CASE
            WHEN [Inventory_Level] = 0 THEN 1
            ELSE 0
        END
    ) > 0

ORDER BY
    Demand_During_Stockouts DESC;
