USE ECommerceDB;
GO

CREATE OR ALTER FUNCTION dbo.fn_GetTopSellingProducts
(
    @TopN INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (@TopN)
        p.ProductID,
        p.Name AS ProductName,
        SUM(oi.Quantity) AS TotalQuantitySold,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM dbo.Product AS p
    INNER JOIN dbo.OrderItems AS oi
        ON p.ProductID = oi.ProductID
    GROUP BY
        p.ProductID,
        p.Name
    ORDER BY
        SUM(oi.Quantity) DESC,
        SUM(oi.Quantity * oi.UnitPrice) DESC
);
GO


SELECT *
FROM dbo.fn_GetTopSellingProducts(5);


SELECT
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Product'
ORDER BY ORDINAL_POSITION;