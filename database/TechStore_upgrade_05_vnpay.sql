USE TechStore;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* Bổ sung dữ liệu đối soát cho từng lần thanh toán VNPay. */

IF COL_LENGTH('dbo.Payments', 'MerchantTransactionRef') IS NULL
    ALTER TABLE dbo.Payments ADD MerchantTransactionRef VARCHAR(100) NULL;
GO

IF COL_LENGTH('dbo.Payments', 'ProviderResponseCode') IS NULL
    ALTER TABLE dbo.Payments ADD ProviderResponseCode VARCHAR(10) NULL;
GO

IF COL_LENGTH('dbo.Payments', 'BankCode') IS NULL
    ALTER TABLE dbo.Payments ADD BankCode VARCHAR(30) NULL;
GO

IF COL_LENGTH('dbo.Payments', 'UpdatedAt') IS NULL
    ALTER TABLE dbo.Payments ADD UpdatedAt DATETIME2 NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_Payments_MerchantTransactionRef'
                 AND object_id = OBJECT_ID('dbo.Payments'))
    CREATE UNIQUE INDEX UX_Payments_MerchantTransactionRef
        ON dbo.Payments(MerchantTransactionRef)
        WHERE MerchantTransactionRef IS NOT NULL;
GO
