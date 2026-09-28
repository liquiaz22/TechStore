CREATE DATABASE TechStore;
GO

USE TechStore;
GO

CREATE TABLE Users (
    UserId          BIGINT IDENTITY(1,1) PRIMARY KEY,
    Email           VARCHAR(320) NOT NULL,
    PasswordHash    VARCHAR(255) NOT NULL,
    FullName        NVARCHAR(150) NOT NULL,
    Phone           VARCHAR(20) NULL,
    Role            VARCHAR(20) NOT NULL
                    CONSTRAINT DF_Users_Role DEFAULT 'CUSTOMER',
    Status          VARCHAR(20) NOT NULL
                    CONSTRAINT DF_Users_Status DEFAULT 'ACTIVE',
    CreatedAt       DATETIME2 NOT NULL
                    CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt       DATETIME2 NULL,

    CONSTRAINT CK_Users_Role
        CHECK (Role IN ('CUSTOMER', 'ADMIN')),
    CONSTRAINT CK_Users_Status
        CHECK (Status IN ('ACTIVE', 'LOCKED'))
);

CREATE UNIQUE INDEX UX_Users_Email ON Users(Email);
GO

CREATE TABLE Addresses (
    AddressId       BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserId          BIGINT NOT NULL,
    ReceiverName    NVARCHAR(150) NOT NULL,
    ReceiverPhone   VARCHAR(20) NOT NULL,
    Province        NVARCHAR(100) NOT NULL,
    District        NVARCHAR(100) NOT NULL,
    Ward            NVARCHAR(100) NOT NULL,
    AddressLine     NVARCHAR(255) NOT NULL,
    IsDefault       BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Addresses_Users
        FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
GO

CREATE TABLE Categories (
    CategoryId          INT IDENTITY(1,1) PRIMARY KEY,
    ParentCategoryId    INT NULL,
    Name                NVARCHAR(100) NOT NULL,
    Slug                VARCHAR(150) NOT NULL,
    IsActive            BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Categories_Parent
        FOREIGN KEY (ParentCategoryId)
        REFERENCES Categories(CategoryId)
);

CREATE UNIQUE INDEX UX_Categories_Slug ON Categories(Slug);
GO

CREATE TABLE Brands (
    BrandId      INT IDENTITY(1,1) PRIMARY KEY,
    Name         NVARCHAR(100) NOT NULL,
    Slug         VARCHAR(150) NOT NULL,
    LogoUrl      NVARCHAR(500) NULL,
    IsActive     BIT NOT NULL DEFAULT 1
);

CREATE UNIQUE INDEX UX_Brands_Slug ON Brands(Slug);
GO

CREATE TABLE Products (
    ProductId        BIGINT IDENTITY(1,1) PRIMARY KEY,
    CategoryId       INT NOT NULL,
    BrandId          INT NULL,
    Name             NVARCHAR(250) NOT NULL,
    Slug             VARCHAR(300) NOT NULL,
    ShortDescription NVARCHAR(1000) NULL,
    Description      NVARCHAR(MAX) NULL,
    Status           VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CreatedAt        DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt        DATETIME2 NULL,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT FK_Products_Brands
        FOREIGN KEY (BrandId) REFERENCES Brands(BrandId),
    CONSTRAINT CK_Products_Status
        CHECK (Status IN ('DRAFT', 'ACTIVE', 'INACTIVE'))
);

CREATE UNIQUE INDEX UX_Products_Slug ON Products(Slug);
CREATE INDEX IX_Products_CategoryId ON Products(CategoryId);
CREATE INDEX IX_Products_BrandId ON Products(BrandId);
GO

CREATE TABLE ProductVariants (
    VariantId        BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProductId        BIGINT NOT NULL,
    SKU              VARCHAR(100) NOT NULL,
    VariantName      NVARCHAR(200) NOT NULL,
    Color            NVARCHAR(100) NULL,
    Ram              NVARCHAR(50) NULL,
    Storage          NVARCHAR(50) NULL,
    Price            DECIMAL(18,2) NOT NULL,
    OriginalPrice    DECIMAL(18,2) NULL,
    StockQuantity    INT NOT NULL DEFAULT 0,
    IsActive         BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_ProductVariants_Products
        FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    CONSTRAINT CK_ProductVariants_Price
        CHECK (Price >= 0),
    CONSTRAINT CK_ProductVariants_OriginalPrice
        CHECK (OriginalPrice IS NULL OR OriginalPrice >= Price),
    CONSTRAINT CK_ProductVariants_Stock
        CHECK (StockQuantity >= 0)
);

CREATE UNIQUE INDEX UX_ProductVariants_SKU
    ON ProductVariants(SKU);

CREATE INDEX IX_ProductVariants_ProductId
    ON ProductVariants(ProductId);
GO

CREATE TABLE ProductImages (
    ImageId      BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProductId    BIGINT NOT NULL,
    VariantId    BIGINT NULL,
    ImageUrl     NVARCHAR(500) NOT NULL,
    IsPrimary    BIT NOT NULL DEFAULT 0,
    SortOrder    INT NOT NULL DEFAULT 0,

    CONSTRAINT FK_ProductImages_Products
        FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    CONSTRAINT FK_ProductImages_Variants
        FOREIGN KEY (VariantId) REFERENCES ProductVariants(VariantId)
);
GO

CREATE TABLE ProductSpecifications (
    SpecificationId BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProductId        BIGINT NOT NULL,
    SpecificationName NVARCHAR(150) NOT NULL,
    SpecificationValue NVARCHAR(500) NOT NULL,
    SortOrder        INT NOT NULL DEFAULT 0,

    CONSTRAINT FK_ProductSpecifications_Products
        FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);
GO

CREATE TABLE Favorites (
    UserId      BIGINT NOT NULL,
    ProductId   BIGINT NOT NULL,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Favorites PRIMARY KEY (UserId, ProductId),
    CONSTRAINT FK_Favorites_Users
        FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Favorites_Products
        FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);
GO

CREATE TABLE Carts (
    CartId      BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserId      BIGINT NOT NULL,
    Status      VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt   DATETIME2 NULL,

    CONSTRAINT FK_Carts_Users
        FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT CK_Carts_Status
        CHECK (Status IN ('ACTIVE', 'ORDERED', 'ABANDONED'))
);

CREATE UNIQUE INDEX UX_Carts_ActiveUser
    ON Carts(UserId)
    WHERE Status = 'ACTIVE';
GO

CREATE TABLE CartItems (
    CartItemId  BIGINT IDENTITY(1,1) PRIMARY KEY,
    CartId      BIGINT NOT NULL,
    VariantId   BIGINT NOT NULL,
    Quantity    INT NOT NULL,

    CONSTRAINT FK_CartItems_Carts
        FOREIGN KEY (CartId) REFERENCES Carts(CartId),
    CONSTRAINT FK_CartItems_Variants
        FOREIGN KEY (VariantId) REFERENCES ProductVariants(VariantId),
    CONSTRAINT CK_CartItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT UQ_CartItems UNIQUE (CartId, VariantId)
);
GO

CREATE TABLE Orders (
    OrderId         BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderCode       VARCHAR(30) NOT NULL,
    UserId          BIGINT NOT NULL,

    ReceiverName    NVARCHAR(150) NOT NULL,
    ReceiverPhone   VARCHAR(20) NOT NULL,
    ShippingAddress NVARCHAR(500) NOT NULL,

    Status           VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    PaymentStatus    VARCHAR(30) NOT NULL DEFAULT 'UNPAID',

    Subtotal         DECIMAL(18,2) NOT NULL,
    ShippingFee      DECIMAL(18,2) NOT NULL DEFAULT 0,
    DiscountAmount   DECIMAL(18,2) NOT NULL DEFAULT 0,
    TotalAmount      DECIMAL(18,2) NOT NULL,

    CustomerNote     NVARCHAR(500) NULL,
    CreatedAt        DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt        DATETIME2 NULL,

    CONSTRAINT FK_Orders_Users
        FOREIGN KEY (UserId) REFERENCES Users(UserId),

    CONSTRAINT UQ_Orders_OrderCode UNIQUE (OrderCode),

    CONSTRAINT CK_Orders_Status CHECK (
        Status IN (
            'PENDING',
            'CONFIRMED',
            'PROCESSING',
            'SHIPPING',
            'COMPLETED',
            'CANCELLED'
        )
    ),

    CONSTRAINT CK_Orders_PaymentStatus CHECK (
        PaymentStatus IN ('UNPAID', 'PAID', 'FAILED', 'REFUNDED')
    ),

    CONSTRAINT CK_Orders_Amounts CHECK (
        Subtotal >= 0 AND
        ShippingFee >= 0 AND
        DiscountAmount >= 0 AND
        TotalAmount >= 0
    )
);

CREATE INDEX IX_Orders_UserId_CreatedAt
    ON Orders(UserId, CreatedAt DESC);
GO

CREATE TABLE OrderItems (
    OrderItemId     BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderId         BIGINT NOT NULL,
    VariantId       BIGINT NULL,

    ProductName     NVARCHAR(250) NOT NULL,
    VariantName     NVARCHAR(200) NULL,
    SKU             VARCHAR(100) NOT NULL,
    ImageUrl        NVARCHAR(500) NULL,

    UnitPrice       DECIMAL(18,2) NOT NULL,
    Quantity        INT NOT NULL,
    LineTotal       DECIMAL(18,2) NOT NULL,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    CONSTRAINT FK_OrderItems_Variants
        FOREIGN KEY (VariantId) REFERENCES ProductVariants(VariantId),
    CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderItems_Price
        CHECK (UnitPrice >= 0 AND LineTotal >= 0)
);

CREATE INDEX IX_OrderItems_OrderId ON OrderItems(OrderId);
GO

CREATE TABLE Payments (
    PaymentId           BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderId             BIGINT NOT NULL,
    PaymentMethod       VARCHAR(30) NOT NULL,
    PaymentStatus       VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    Amount              DECIMAL(18,2) NOT NULL,
    ProviderTransactionId VARCHAR(200) NULL,
    PaidAt              DATETIME2 NULL,
    CreatedAt           DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    CONSTRAINT CK_Payments_Method
        CHECK (PaymentMethod IN ('COD', 'VNPAY', 'MOMO', 'BANK_TRANSFER')),
    CONSTRAINT CK_Payments_Status
        CHECK (PaymentStatus IN ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED')),
    CONSTRAINT CK_Payments_Amount CHECK (Amount >= 0)
);
GO

CREATE TABLE OrderStatusHistory (
    HistoryId     BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderId       BIGINT NOT NULL,
    Status        VARCHAR(30) NOT NULL,
    Note          NVARCHAR(500) NULL,
    ChangedBy     BIGINT NULL,
    CreatedAt     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_OrderStatusHistory_Orders
        FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    CONSTRAINT FK_OrderStatusHistory_Users
        FOREIGN KEY (ChangedBy) REFERENCES Users(UserId)
);
GO

