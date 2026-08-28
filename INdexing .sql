SELECT
    i.name,
    i.type_desc
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('dbo.Orders')
  AND i.name = 'IX_Orders_CustomerID';

  SELECT *
FROM dbo.Orders
WHERE CustomerID = 5
OPTION (RECOMPILE);