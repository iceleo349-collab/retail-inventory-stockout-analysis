select
	product_id,
	category,
	SUM(units_sold) as total_units_sold,
	AVG(inventory_level) as average_inventory,
	SUM(units_sold) / 
		count(distinct date) as avg_daily_sales,
	AVG(inventory_level) / nullif(SUM(units_sold) /
		COUNT(distinct date), 0) as estimated_days_of_inventory
from dbo.sales_data
group by
	product_id,
	category
order by
	estimated_days_of_inventory asc;