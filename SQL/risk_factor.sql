SELECT
    product_id,
    category,

    SUM(units_sold) AS total_units_sold,

    AVG(CAST(inventory_level AS DECIMAL(10,2))) 
        AS average_inventory,

    SUM(
        CASE
            WHEN inventory_level = 0 THEN 1
            ELSE 0
        END
    ) AS stockout_days,

    CAST(
        SUM(
            CASE
                WHEN inventory_level = 0 THEN 1
                ELSE 0
            END
        ) AS DECIMAL(10,2)
    ) / COUNT(*) * 100
        AS stockout_rate,

    SUM(
        CASE
            WHEN inventory_level = 0
            THEN demand
            ELSE 0
        END
    ) AS estimated_lost_demand,

    CASE
        WHEN
            (
                CAST(
                    SUM(
                        CASE
                            WHEN inventory_level = 0 THEN 1
                            ELSE 0
                        END
                    ) AS DECIMAL(10,2)
                ) / COUNT(*) * 100
            ) >= 1
            OR
            SUM(
                CASE
                    WHEN inventory_level = 0
                    THEN demand
                    ELSE 0
                END
            ) >= 2000
        THEN 'High Risk'

        WHEN
            (
                CAST(
                    SUM(
                        CASE
                            WHEN inventory_level = 0 THEN 1
                            ELSE 0
                        END
                    ) AS DECIMAL(10,2)
                ) / COUNT(*) * 100
            ) >= 0.5
            OR
            SUM(
                CASE
                    WHEN inventory_level = 0
                    THEN demand
                    ELSE 0
                END
            ) >= 1000
        THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS inventory_risk

FROM dbo.sales_data

GROUP BY
    product_id,
    category

ORDER BY
    estimated_lost_demand DESC;