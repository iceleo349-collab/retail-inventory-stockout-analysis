WITH InventoryBands AS (
    SELECT
        [Inventory_Level],
        [Promotion],
        [Demand],
        CASE
            WHEN [Inventory_Level] < 100 THEN 'Under 100'
            WHEN [Inventory_Level] < 200 THEN '100-199'
            WHEN [Inventory_Level] < 300 THEN '200-299'
            WHEN [Inventory_Level] < 400 THEN '300-399'
            ELSE '400+'
        END AS Inventory_Band
    FROM dbo.Sales_Data
    WHERE [Store_ID] = 4
      AND [Product_ID] = 2
      AND [Category] = 'Groceries'
)
SELECT
    Inventory_Band,
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
    ) AS Stockout_Rate_Percent,
    CAST(AVG(1.0 * [Demand]) AS DECIMAL(10,2))
        AS Average_Demand
FROM InventoryBands
GROUP BY
    Inventory_Band,
    [Promotion]
ORDER BY
    [Promotion],
    CASE Inventory_Band
        WHEN 'Under 100' THEN 1
        WHEN '100-199' THEN 2
        WHEN '200-299' THEN 3
        WHEN '300-399' THEN 4
        WHEN '400+' THEN 5
    END;