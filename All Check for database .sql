USE ECommerceDB;
GO
-- 1.TABLES

SELECT
    ExpectedName AS ObjectName,
    'TABLE' AS ObjectType,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM sys.tables
            WHERE name = ExpectedName
        )
        THEN 'FOUND'
        ELSE 'MISSING'
    END AS Status
FROM (VALUES
    ('Category'),
    ('Coupon'),
    ('Customer'),
    ('OrderCancellationAudit'),
    ('OrderItems'),
    ('Orders'),
    ('OrderStatusAudit'),
    ('Payment'),
    ('PaymentAudit'),
    ('Product'),
    ('Shipment'),
    ('Supplier')
) AS T(ExpectedName)
ORDER BY ObjectName;


-- 2. VIEWS

SELECT
    ExpectedName AS ObjectName,
    'VIEW' AS ObjectType,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM sys.views
            WHERE name = ExpectedName
        )
        THEN 'FOUND'
        ELSE 'MISSING'
    END AS Status
FROM (VALUES
    ('vw_CustomerLifetimeValue'),
    ('vw_LowStockProducts'),
    ('vw_OrderSummary'),
    ('vw_PendingShipments'),
    ('vw_SalesByCategory')
) AS V(ExpectedName)
ORDER BY ObjectName;

 -- 3. FUNCTIONS

SELECT
    ExpectedName AS ObjectName,
    ExpectedType AS RequiredType,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM sys.objects
            WHERE name = ExpectedName
              AND type IN ('FN', 'TF', 'IF')
        )
        THEN 'FOUND'
        ELSE 'MISSING'
    END AS Status,
    (
        SELECT
            CASE o.type
                WHEN 'FN' THEN 'Scalar'
                WHEN 'TF' THEN 'Table-Valued'
                WHEN 'IF' THEN 'Inline Table-Valued'
            END
        FROM sys.objects o
        WHERE o.name = ExpectedName
          AND o.type IN ('FN', 'TF', 'IF')
    ) AS ActualType
FROM (VALUES
    ('fn_CheckStockAvailability', 'Scalar'),
    ('fn_GetCustomerTotalSpent', 'Scalar'),
    ('fn_GetOrderTotal', 'Scalar'),
    ('fn_GetCustomerOrders', 'Table-Valued'),
    ('fn_GetTopSellingProducts', 'Table-Valued')
) AS F(ExpectedName, ExpectedType)
ORDER BY ObjectName;

-- 4- PROCEDURES

SELECT
    ExpectedName AS ObjectName,
    'STORED PROCEDURE' AS ObjectType,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM sys.procedures
            WHERE name = ExpectedName
        )
        THEN 'FOUND'
        ELSE 'MISSING'
    END AS Status
FROM (VALUES
    ('sp_ApplyDiscountCoupon'),
    ('sp_CancelOrder'),
    ('sp_CreateOrder'),
    ('sp_ProcessPayment'),
    ('sp_UpdateOrderStatus')
) AS P(ExpectedName)
ORDER BY ObjectName;

-- 5- TRIGGERS + ACTIVE STATUS

SELECT
    ExpectedName AS TriggerName,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM sys.triggers
            WHERE name = ExpectedName
        )
        THEN 'FOUND'
        ELSE 'MISSING'
    END AS ExistenceStatus,
    (
        SELECT
            OBJECT_NAME(tr.parent_id)
        FROM sys.triggers tr
        WHERE tr.name = ExpectedName
    ) AS ParentTable,
    (
        SELECT
            CASE
                WHEN tr.is_disabled = 0 THEN 'ACTIVE'
                ELSE 'DISABLED'
            END
        FROM sys.triggers tr
        WHERE tr.name = ExpectedName
    ) AS TriggerStatus
FROM (VALUES
    ('trg_PreventNegativeStock'),
    ('trg_OrderCancellationAudit'),
    ('trg_OrderStatusAudit'),
    ('trg_PreventInvalidOrderStatus'),
    ('trg_PaymentAudit')
) AS TR(ExpectedName)
ORDER BY TriggerName;

 -- 6. INDEXES

SELECT
    ExpectedName AS IndexName,
    ExpectedTable AS TableName,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM sys.indexes i
            INNER JOIN sys.tables t
                ON i.object_id = t.object_id
            WHERE i.name = ExpectedName
              AND t.name = ExpectedTable
        )
        THEN 'FOUND'
        ELSE 'MISSING'
    END AS Status,
    (
        SELECT i.type_desc
        FROM sys.indexes i
        INNER JOIN sys.tables t
            ON i.object_id = t.object_id
        WHERE i.name = ExpectedName
          AND t.name = ExpectedTable
    ) AS IndexType,
    (
        SELECT i.filter_definition
        FROM sys.indexes i
        INNER JOIN sys.tables t
            ON i.object_id = t.object_id
        WHERE i.name = ExpectedName
          AND t.name = ExpectedTable
    ) AS FilterCondition
FROM (VALUES
    ('IX_Orders_CustomerID', 'Orders'),
    ('IX_OrderItems_ProductID', 'OrderItems'),
    ('IX_Products_CategoryID', 'Product'),
    ('IX_Orders_OrderDate_Status', 'Orders'),
    ('IX_Products_LowStock', 'Product')
) AS I(ExpectedName, ExpectedTable)
ORDER BY TableName, IndexName;

