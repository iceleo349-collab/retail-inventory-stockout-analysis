SELECT
    product_id,
    category,

    SUM(units_sold) AS total_units_sold,

    AVG(CAST(inventory_level AS DECIMAL(10,2))) AS average_inventory,

    CAST(SUM(units_sold) AS DECIMAL(10,2))
        / COUNT(DISTINCT date) AS avg_daily_sales,

    AVG(CAST(inventory_level AS DECIMAL(10,2)))
        /
        NULLIF(
            CAST(SUM(units_sold) AS DECIMAL(10,2))
            / COUNT(DISTINCT date),
            0
        ) AS estimated_days_of_inventory

FROM dbo.sales_data

GROUP BY
    product_id,
    category

ORDER BY
    estimated_days_of_inventory ASC;