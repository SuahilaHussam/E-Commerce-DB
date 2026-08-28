USE ECommerceDB;
GO

-- =============================================
-- 1. vw_OrderSummary
-- =============================================
CREATE VIEW vw_OrderSummary
AS
SELECT
    o.OrderID,
    c.CustomerID,
    c.Name AS CustomerName,
    o.OrderDate,
    o.Status,
    COUNT(oi.ProductID) AS ItemCount,
    SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
FROM Orders o
INNER JOIN Customer c
    ON o.CustomerID = c.CustomerID
LEFT JOIN OrderItems oi
    ON o.OrderID = oi.OrderID
GROUP BY
    o.OrderID,
    c.CustomerID,
    c.Name,
    o.OrderDate,
    o.Status;
GO


-- =============================================
-- 2. vw_LowStockProducts
-- =============================================
CREATE VIEW vw_LowStockProducts
AS
SELECT
    p.ProductID,
    p.Name AS ProductName,
    p.StockQuantity,
    p.Price,
    s.SupplierID,
    s.Name AS SupplierName,
    s.ContactEmail
FROM Product p
INNER JOIN Supplier s
    ON p.SupplierID = s.SupplierID
WHERE p.StockQuantity < 10;
GO


-- =============================================
-- 3. vw_SalesByCategory
-- =============================================
CREATE VIEW vw_SalesByCategory
AS
SELECT
    c.CategoryID,
    c.CategoryName,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue,
    SUM(oi.Quantity) AS UnitsSold,
    AVG(oi.UnitPrice) AS AveragePrice
FROM Category c
INNER JOIN Product p
    ON c.CategoryID = p.CategoryID
INNER JOIN OrderItems oi
    ON p.ProductID = oi.ProductID
INNER JOIN Orders o
    ON oi.OrderID = o.OrderID
WHERE o.Status <> 'Cancelled'
GROUP BY
    c.CategoryID,
    c.CategoryName;
GO


-- =============================================
-- 4. vw_CustomerLifetimeValue
-- =============================================
CREATE VIEW vw_CustomerLifetimeValue
AS
SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    c.Email,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    COALESCE(SUM(oi.Quantity * oi.UnitPrice), 0) AS LifetimeRevenue
FROM Customer c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
LEFT JOIN OrderItems oi
    ON o.OrderID = oi.OrderID
WHERE o.Status IS NULL
   OR o.Status <> 'Cancelled'
GROUP BY
    c.CustomerID,
    c.Name,
    c.Email;
GO


-- =============================================
-- 5. vw_PendingShipments
-- =============================================
CREATE VIEW vw_PendingShipments
AS
SELECT
    o.OrderID,
    c.CustomerID,
    c.Name AS CustomerName,
    o.OrderDate,
    o.Status,
    s.ShipmentID,
    s.ShippedDate,
    s.Carrier
FROM Orders o
INNER JOIN Customer c
    ON o.CustomerID = c.CustomerID
LEFT JOIN Shipment s
    ON o.OrderID = s.OrderID
WHERE o.Status = 'Processing'
  AND s.ShipmentID IS NULL;
GO



SELECT * FROM vw_OrderSummary;
SELECT * FROM vw_LowStockProducts;
SELECT * FROM vw_SalesByCategory;
SELECT * FROM vw_CustomerLifetimeValue;
SELECT * FROM vw_PendingShipments;