USE TechStore;
GO

/* Index hỗ trợ dashboard doanh thu và các báo cáo đơn hoàn tất. */

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_Orders_Status_UpdatedAt'
                 AND object_id = OBJECT_ID('dbo.Orders'))
    CREATE INDEX IX_Orders_Status_UpdatedAt
        ON dbo.Orders(Status, UpdatedAt DESC) INCLUDE (TotalAmount, UserId);
GO
