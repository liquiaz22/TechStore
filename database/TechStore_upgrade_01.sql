USE TechStore;
GO

/* Run once after the original TechStore.sql on an existing database. */

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Addresses_UserId')
    CREATE INDEX IX_Addresses_UserId ON Addresses(UserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Addresses_DefaultUser')
    CREATE UNIQUE INDEX UX_Addresses_DefaultUser ON Addresses(UserId) WHERE IsDefault = 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ProductImages_ProductId')
    CREATE INDEX IX_ProductImages_ProductId ON ProductImages(ProductId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ProductImages_VariantId')
    CREATE INDEX IX_ProductImages_VariantId ON ProductImages(VariantId) WHERE VariantId IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_ProductVariants_Variant_Product')
    CREATE UNIQUE INDEX UX_ProductVariants_Variant_Product
    ON ProductVariants(VariantId, ProductId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ProductImages_VariantProduct')
    ALTER TABLE ProductImages WITH CHECK ADD CONSTRAINT FK_ProductImages_VariantProduct
    FOREIGN KEY (VariantId, ProductId) REFERENCES ProductVariants(VariantId, ProductId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_ProductImages_PrimaryProduct')
    CREATE UNIQUE INDEX UX_ProductImages_PrimaryProduct ON ProductImages(ProductId)
    WHERE IsPrimary = 1 AND VariantId IS NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_ProductImages_PrimaryVariant')
    CREATE UNIQUE INDEX UX_ProductImages_PrimaryVariant ON ProductImages(VariantId)
    WHERE IsPrimary = 1 AND VariantId IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ProductSpecifications_ProductId')
    CREATE INDEX IX_ProductSpecifications_ProductId ON ProductSpecifications(ProductId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Favorites_ProductId')
    CREATE INDEX IX_Favorites_ProductId ON Favorites(ProductId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CartItems_VariantId')
    CREATE INDEX IX_CartItems_VariantId ON CartItems(VariantId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Payments_OrderId')
    CREATE INDEX IX_Payments_OrderId ON Payments(OrderId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Payments_ProviderTransaction')
    CREATE UNIQUE INDEX UX_Payments_ProviderTransaction
    ON Payments(PaymentMethod, ProviderTransactionId)
    WHERE ProviderTransactionId IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderStatusHistory_OrderId_CreatedAt')
    CREATE INDEX IX_OrderStatusHistory_OrderId_CreatedAt
    ON OrderStatusHistory(OrderId, CreatedAt);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_Status_CreatedAt')
    CREATE INDEX IX_Orders_Status_CreatedAt ON Orders(Status, CreatedAt DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_OrderStatusHistory_Status')
    ALTER TABLE OrderStatusHistory WITH CHECK ADD CONSTRAINT CK_OrderStatusHistory_Status
    CHECK (Status IN ('PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPING', 'COMPLETED', 'CANCELLED'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Orders_TotalConsistency')
    ALTER TABLE Orders WITH CHECK ADD CONSTRAINT CK_Orders_TotalConsistency
    CHECK (TotalAmount = Subtotal + ShippingFee - DiscountAmount);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_OrderItems_LineTotal')
    ALTER TABLE OrderItems WITH CHECK ADD CONSTRAINT CK_OrderItems_LineTotal
    CHECK (LineTotal = UnitPrice * Quantity);
GO
