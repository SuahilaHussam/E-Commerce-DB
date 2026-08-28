

USE ECommerceDB;
GO

SELECT
    ExpectedTrigger AS TriggerName,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM sys.triggers
            WHERE name = ExpectedTrigger
        )
        THEN 'DONE'
        ELSE 'MISSING'
    END AS Status
FROM (VALUES
    ('trg_OrderStatusAudit'),
    ('trg_PreventNegativeStock'),
    ('trg_PaymentAudit'),
    ('trg_PreventInvalidOrderStatus'),
    ('trg_OrderCancellationAudit')
) AS ExpectedTriggers(ExpectedTrigger);





SELECT
    tr.name AS TriggerName,
    OBJECT_NAME(tr.parent_id) AS TableName,
    CASE
        WHEN tr.is_disabled = 0 THEN 'ACTIVE'
        ELSE 'DISABLED'
    END AS Status
FROM sys.triggers tr
WHERE tr.name IN
(
    'trg_OrderStatusAudit',
    'trg_PreventNegativeStock',
    'trg_PaymentAudit',
    'trg_PreventInvalidOrderStatus',
    'trg_OrderCancellationAudit'
)
ORDER BY tr.name;