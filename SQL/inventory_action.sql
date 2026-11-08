SELECT
    product_id,
    category,

    SUM(units_sold) AS total_units_sold,

    AVG(CAST(inventory_level AS DECIMAL(10,2)))
        AS average_inventory,

    CAST(SUM(units_sold) AS DECIMAL(10,2))
        / COUNT(DISTINCT date)
        AS avg_daily_sales,

    AVG(CAST(inventory_level AS DECIMAL(10,2)))
        /
        NULLIF(
            CAST(SUM(units_sold) AS DECIMAL(10,2))
            / COUNT(DISTINCT date),
            0
        )
        AS days_of_inventory,

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
    ) AS demand_during_stockouts,

    CASE
        WHEN
            SUM(
                CASE WHEN inventory_level = 0
                    THEN demand
                    ELSE 0
                    
                END
            ) >= 2000
            OR
            (
                CAST(
                    SUM(
                        CASE
                            WHEN inventory_level = 0
                            THEN 1
                            ELSE 0
                        END
                    ) AS DECIMAL(10,2)
                ) / COUNT(*) * 100
            ) >= 1
        THEN 'High Stockout Risk'

        WHEN
            SUM(
                CASE
                    WHEN inventory_level = 0
                    THEN demand
                    ELSE 0
                END
            ) >= 1000
            OR
            (
                CAST(
                    SUM(
                        CASE
                            WHEN inventory_level = 0
                            THEN 1
                            ELSE 0
                        END
                    ) AS DECIMAL(10,2)
                ) / COUNT(*) * 100
            ) >= 0.5
        THEN 'Medium Stockout Risk'

        WHEN
            AVG(CAST(inventory_level AS DECIMAL(10,2)))
            /
            NULLIF(
                CAST(SUM(units_sold) AS DECIMAL(10,2))
                / COUNT(DISTINCT date),
                0
            ) >= 4
        THEN 'Potential Overstock'

        ELSE 'Healthy'
    END AS inventory_action

FROM dbo.sales_data

GROUP BY
    product_id,
    category

ORDER BY
    CASE
        WHEN
            SUM(
                CASE
                    WHEN inventory_level = 0
                    THEN demand
                    ELSE 0
                END
            ) >= 2000
            OR
            (
                CAST(
                    SUM(
                        CASE
                            WHEN inventory_level = 0
                            THEN 1
                            ELSE 0
                        END
                    ) AS DECIMAL(10,2)
                ) / COUNT(*) * 100
            ) >= 1
        THEN 1

        WHEN
            SUM(
                CASE
                    WHEN inventory_level = 0
                    THEN demand
                    ELSE 0
                END
            ) >= 1000
            OR
            (
                CAST(
                    SUM(
                        CASE
                            WHEN inventory_level = 0
                            THEN 1
                            ELSE 0
                        END
                    ) AS DECIMAL(10,2)
                ) / COUNT(*) * 100
            ) >= 0.5
        THEN 2

        WHEN
            AVG(CAST(inventory_level AS DECIMAL(10,2)))
            /
            NULLIF(
                CAST(SUM(units_sold) AS DECIMAL(10,2))
                / COUNT(DISTINCT date),
                0
            ) >= 4
        THEN 3

        ELSE 4
    END,
    demand_during_stockouts DESC;