use EcommerceCustomerAnalytics;
select 
     Invoice,StockCode,Description,Quantity,
     COALESCE(
     TRY_CONVERT(datetime2,InvoiceDate,120),
     TRY_CONVERT(datetime2,InvoiceDate,105)
     )AS InvoiceDate,

     TRY_CONVERT(decimal(10,2),Price) AS Price,
     Customer_ID,Country,'2009-2010' AS SourceSheet

INTO dbo.RetailCombined
FROM dbo.[year 2009-2010]

UNION ALL

select 
     Invoice,StockCode,Description,Quantity,
     COALESCE(
     TRY_CONVERT(datetime2,InvoiceDate,120),
     TRY_CONVERT(datetime2,InvoiceDate,105)
     )AS InvoiceDate,

     TRY_CONVERT(decimal(10,2),Price) AS Price,
     Customer_ID,Country,'2010-2011' AS SourceSheet
FROM dbo.[year 2010-2011];

-- CONFIRM THE CONVERSION CLEANLY
SELECT COUNT(*) AS Total_Rows FROM dbo.RetailCombined;
SELECT COUNT(*) AS Failed_Dates FROM dbo.RetailCombined WHERE InvoiceDate IS NULL;
SELECT COUNT(*) AS Failed_Prices FROM dbo.RetailCombined WHERE Price IS NULL;

--CHECK Missing Customer ID
SELECT COUNT(*) AS Missing_CustomerID
FROM dbo.RetailCombined WHERE Customer_ID IS NULL;

--Check Negative OR Zero Quantity
SELECT Count(*) AS Negative_Qty
FROM dbo.RetailCombined WHERE Quantity <=0;

--Check Missing Description
SELECT COUNT(*) AS Missing_Description
FROM dbo.RetailCombined WHERE Description IS NULL;

--Check Exact Duplicate Rows
SELECT Invoice,StockCode,Description,Quantity,InvoiceDate,Price,Customer_ID,Country,
COUNT(*) AS ExactDuplicate
FROM dbo.RetailCombined 
Group BY Invoice,StockCode,Description,Quantity,InvoiceDate,Price,Customer_ID,Country HAVING COUNT(*)>1;

--Duplicate And Produce the Final Cleaned Table

With Deduped AS(
SELECT *, ROW_NUMBER() OVER(
PARTITION BY Invoice,StockCode,Description,Quantity,InvoiceDate,Price,Customer_ID,Country ORDER BY(SELECT NULL)
)AS RowNum
FROM dbo.RetailCombined
)
SELECT Invoice,StockCode,Description,Quantity,InvoiceDate,Price,Customer_ID,Country,SourceSheet
INTO dbo.RetailCleaned
FROM Deduped
WHERE RowNum=1;

SELECT *FROM dbo.RetailCleaned;