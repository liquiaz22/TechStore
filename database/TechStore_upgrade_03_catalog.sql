USE TechStore;
GO

/* Chạy một lần cho database đã có trước giai đoạn hoàn thiện quản trị sản phẩm. */

IF COL_LENGTH('dbo.ProductVariants', 'UpdatedAt') IS NULL
BEGIN
    ALTER TABLE dbo.ProductVariants ADD UpdatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_ProductVariants_UpdatedAt DEFAULT SYSUTCDATETIME() WITH VALUES;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_ProductSpecifications_ProductName'
                 AND object_id = OBJECT_ID('dbo.ProductSpecifications'))
    CREATE UNIQUE INDEX UX_ProductSpecifications_ProductName
        ON dbo.ProductSpecifications(ProductId, SpecificationName);
GO
