
WITH PromotionAnalysis AS (
    SELECT
        [Store_ID],
        [Region],
        [Category],

        SUM(CASE WHEN [Promotion] = 0 THEN 1 ELSE 0 END)
            AS No_Promo_Records,

        SUM(CASE
            WHEN [Promotion] = 0
             AND [Inventory_Level] = 0 THEN 1
            ELSE 0
        END) AS No_Promo_Stockouts,

        SUM(CASE WHEN [Promotion] = 1 THEN 1 ELSE 0 END)
            AS Promo_Records,

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
),
Rates AS (
    SELECT
        *,
        100.0 * No_Promo_Stockouts
            / NULLIF(No_Promo_Records, 0)
            AS No_Promo_Rate,

        100.0 * Promo_Stockouts
            / NULLIF(Promo_Records, 0)
            AS Promo_Rate
    FROM PromotionAnalysis
)
SELECT
    [Store_ID],
    [Region],
    [Category],
    No_Promo_Rate,
    Promo_Rate,

    CASE
        WHEN Promo_Rate >= 1.0
          OR No_Promo_Rate >= 0.75
            THEN 'High Priority'

        WHEN Promo_Rate >= 0.5
          OR No_Promo_Rate >= 0.4
            THEN 'Medium Priority'

        ELSE 'Lower Priority'
    END AS Inventory_Action_Priority

FROM Rates

ORDER BY
    CASE
        WHEN Promo_Rate >= 1.0
          OR No_Promo_Rate >= 0.75 THEN 1
        WHEN Promo_Rate >= 0.5
          OR No_Promo_Rate >= 0.4 THEN 2
        ELSE 3
    END,
    Promo_Rate DESC;
