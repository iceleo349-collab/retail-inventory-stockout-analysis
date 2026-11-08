WITH ProductPromotion AS (
    SELECT
        [Product_ID],
        [Promotion],
        COUNT(*) AS Total_Records,
        SUM(CASE WHEN [Inventory_Level] = 0
                 THEN 1 ELSE 0 END) AS Stockout_Records,
        AVG(1.0 * [Demand]) AS Average_Demand,
        AVG(1.0 * [Inventory_Level]) AS Average_Inventory
    FROM dbo.Sales_Data
    WHERE [Store_ID] = 4
      AND [Category] = 'Groceries'
    GROUP BY [Product_ID], [Promotion]
),
Comparison AS (
    SELECT
        [Product_ID],
        MAX(CASE WHEN [Promotion] = 0
                 THEN 100.0 * Stockout_Records
                      / NULLIF(Total_Records, 0) END)
            AS No_Promo_Rate,
        MAX(CASE WHEN [Promotion] = 1
                 THEN 100.0 * Stockout_Records
                      / NULLIF(Total_Records, 0) END)
            AS Promo_Rate,
        MAX(CASE WHEN [Promotion] = 1
                 THEN Average_Demand END) AS Promo_Demand,
        MAX(CASE WHEN [Promotion] = 1
                 THEN Average_Inventory END) AS Promo_Inventory
    FROM ProductPromotion
    GROUP BY [Product_ID]
)
SELECT
    [Product_ID],
    CAST(No_Promo_Rate AS DECIMAL(10,2)) AS No_Promo_Rate,
    CAST(Promo_Rate AS DECIMAL(10,2)) AS Promo_Rate,
    CAST(Promo_Rate - No_Promo_Rate
         AS DECIMAL(10,2)) AS Rate_Change_Points,
    CAST(Promo_Demand AS DECIMAL(10,2)) AS Promo_Demand,
    CAST(Promo_Inventory AS DECIMAL(10,2)) AS Promo_Inventory,
    CASE
        WHEN Promo_Rate >= 1.5
             AND Promo_Rate > No_Promo_Rate
            THEN 'High Priority'
        WHEN Promo_Rate > No_Promo_Rate
            THEN 'Review'
        ELSE 'Monitor'
    END AS Suggested_Action
FROM Comparison
ORDER BY Rate_Change_Points DESC;