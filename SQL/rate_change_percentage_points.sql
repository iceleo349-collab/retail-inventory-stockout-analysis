
WITH PromotionAnalysis AS (
    SELECT
        [Store_ID],
        [Region],
        [Category],

        SUM(CASE
            WHEN [Promotion] = 0 THEN 1
            ELSE 0
        END) AS No_Promo_Records,

        SUM(CASE
            WHEN [Promotion] = 0
             AND [Inventory_Level] = 0 THEN 1
            ELSE 0
        END) AS No_Promo_Stockouts,

        SUM(CASE
            WHEN [Promotion] = 1 THEN 1
            ELSE 0
        END) AS Promo_Records,

        SUM(CASE
            WHEN [Promotion] = 1
             AND [Inventory_Level] = 0 THEN 1
            ELSE 0
        END) AS Promo_Stockouts

    FROM dbo.Sales_Data

    GROUP BY
        [Store_ID],
        [Region],
        [Category]
)

SELECT
    [Store_ID],
    [Region],
    [Category],

    No_Promo_Records,
    No_Promo_Stockouts,

    CAST(No_Promo_Stockouts AS DECIMAL(10,4))
        / NULLIF(No_Promo_Records, 0) * 100
        AS No_Promo_Rate_Percent,

    Promo_Records,
    Promo_Stockouts,

    CAST(Promo_Stockouts AS DECIMAL(10,4))
        / NULLIF(Promo_Records, 0) * 100
        AS Promo_Rate_Percent,

    (
        CAST(Promo_Stockouts AS DECIMAL(10,4))
            / NULLIF(Promo_Records, 0) * 100)
    -
    (
        CAST(No_Promo_Stockouts AS DECIMAL(10,4))
            / NULLIF(No_Promo_Records, 0) * 100) 
            AS Rate_Change_Percentage_Points

FROM PromotionAnalysis

WHERE
    No_Promo_Records > 0
    AND Promo_Records > 0

ORDER BY
    Rate_Change_Percentage_Points DESC;
