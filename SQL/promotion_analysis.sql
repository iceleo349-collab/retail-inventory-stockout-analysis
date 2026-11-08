
WITH PromotionAnalysis AS (
    SELECT
        [Store_ID],
        [Product_ID],
        [Category],
        [Promotion],
        COUNT(*) AS Total_Records,
        SUM(
            CASE WHEN [Inventory_Level] = 0
                 THEN 1 ELSE 0 END
        ) AS Stockout_Records,
        CAST(
            100.0 * SUM(
                CASE WHEN [Inventory_Level] = 0
                     THEN 1 ELSE 0 END
            ) / COUNT(*) AS DECIMAL(10, 2)
        ) AS Stockout_Rate_Percent,
        CAST(AVG(1.0 * [Demand]) AS DECIMAL(10, 2))
            AS Average_Demand,
        CAST(AVG(1.0 * [Inventory_Level]) AS DECIMAL(10, 2))
            AS Average_Inventory
    FROM dbo.Sales_Data
    WHERE [Category] = 'Groceries'
      AND [Store_ID] = 1
    GROUP BY
        [Store_ID],
        [Product_ID],
        [Category],
        [Promotion]
)
SELECT
    [Product_ID],
    [Category],
    MAX(CASE WHEN [Promotion] = 0
             THEN Total_Records END) AS No_Promo_Records,
    MAX(CASE WHEN [Promotion] = 0
             THEN Stockout_Rate_Percent END) AS No_Promo_Rate,
    MAX(CASE WHEN [Promotion] = 1
             THEN Total_Records END) AS Promo_Records,
    MAX(CASE WHEN [Promotion] = 1
             THEN Stockout_Rate_Percent END) AS Promo_Rate,
    CAST(
        MAX(CASE WHEN [Promotion] = 1
                 THEN Stockout_Rate_Percent END)
        -
        MAX(CASE WHEN [Promotion] = 0
                 THEN Stockout_Rate_Percent END)
        AS DECIMAL(10, 2)
    ) AS Rate_Change_Percentage_Points
FROM PromotionAnalysis
GROUP BY [Product_ID], [Category]
ORDER BY Rate_Change_Percentage_Points DESC;
