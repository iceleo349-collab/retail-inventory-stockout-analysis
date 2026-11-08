
SELECT
    MIN([Date]) AS First_Date,
    MAX([Date]) AS Last_Date,
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT [Date]) AS Distinct_Dates
FROM dbo.Sales_Data
WHERE [Store_ID] = 1
  AND [Category] = 'Groceries'
  AND [Product_ID] IN (5, 16);
