/*
    TechStore - dữ liệu sản phẩm demo tham khảo từ Thegioididong.com
    Ngày thu thập: 28/09/2026

    Phạm vi: 10 điện thoại, 10 máy tính bảng, 10 laptop, 10 phụ kiện.
    Giá và tình trạng chỉ dùng cho học tập/demo, có thể thay đổi theo nguồn.
    Ảnh đang dùng URL CDN của nguồn; hãy thay bằng ảnh có quyền sử dụng trước khi production.

    Script có thể chạy lại: sản phẩm được đồng bộ theo Slug, phiên bản theo SKU.
*/

USE TechStore;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;

BEGIN TRY
    BEGIN TRANSACTION;

    MERGE Categories AS target
    USING (VALUES
        (N'Điện thoại', 'dien-thoai'),
        (N'Máy tính bảng', 'may-tinh-bang'),
        (N'Laptop', 'laptop'),
        (N'Phụ kiện', 'phu-kien')
    ) AS source(Name, Slug)
    ON target.Slug = source.Slug
    WHEN MATCHED THEN
        UPDATE SET Name = source.Name, IsActive = 1
    WHEN NOT MATCHED THEN
        INSERT (ParentCategoryId, Name, Slug, IsActive)
        VALUES (NULL, source.Name, source.Slug, 1);

    MERGE Brands AS target
    USING (VALUES
        (N'Apple', 'apple'),
        (N'Xiaomi', 'xiaomi'),
        (N'realme', 'realme'),
        (N'Motorola', 'motorola'),
        (N'OPPO', 'oppo'),
        (N'Samsung', 'samsung'),
        (N'HP', 'hp'),
        (N'ASUS', 'asus'),
        (N'Dell', 'dell'),
        (N'Lenovo', 'lenovo'),
        (N'MSI', 'msi'),
        (N'TORRAS', 'torras'),
        (N'IMOU', 'imou'),
        (N'AUKEY', 'aukey'),
        (N'Modi', 'modi'),
        (N'Tomtoc', 'tomtoc'),
        (N'AVA+', 'ava-plus'),
        (N'Ugreen', 'ugreen')
    ) AS source(Name, Slug)
    ON target.Slug = source.Slug
    WHEN MATCHED THEN
        UPDATE SET Name = source.Name, IsActive = 1
    WHEN NOT MATCHED THEN
        INSERT (Name, Slug, LogoUrl, IsActive)
        VALUES (source.Name, source.Slug, NULL, 1);

    DECLARE @Seed TABLE (
        CategorySlug VARCHAR(150) NOT NULL,
        ProductName NVARCHAR(250) NOT NULL,
        ProductSlug VARCHAR(300) NOT NULL,
        BrandSlug VARCHAR(150) NOT NULL,
        SKU VARCHAR(100) NOT NULL,
        VariantName NVARCHAR(200) NOT NULL,
        Color NVARCHAR(100) NULL,
        Ram NVARCHAR(50) NULL,
        Storage NVARCHAR(50) NULL,
        Price DECIMAL(18,2) NOT NULL,
        OriginalPrice DECIMAL(18,2) NULL,
        StockQuantity INT NOT NULL,
        ImageUrl NVARCHAR(500) NOT NULL,
        SourceUrl NVARCHAR(500) NOT NULL
    );

    INSERT INTO @Seed
        (CategorySlug, ProductName, ProductSlug, BrandSlug, SKU, VariantName,
         Color, Ram, Storage, Price, OriginalPrice, StockQuantity, ImageUrl, SourceUrl)
    VALUES
    -- Điện thoại
    ('dien-thoai', N'Điện thoại iPhone 18 Pro Max 256GB', 'iphone-18-pro-max-256gb', 'apple',
     'TGDD-PH-001', N'256GB - Đen', N'Đen', NULL, N'256 GB', 41990000, NULL, 18,
     N'https://cdn.tgdd.vn/Products/Images/42/370982/iphone-18-pro-max-den-thumb-600x600.jpg',
     N'https://www.thegioididong.com/dtdd/iphone-18-pro-max'),
    ('dien-thoai', N'Điện thoại iPhone 18 Pro 256GB', 'iphone-18-pro-256gb', 'apple',
     'TGDD-PH-002', N'256GB - Đỏ Burgundy', N'Đỏ Burgundy', NULL, N'256 GB', 38490000, 38990000, 16,
     N'https://cdn.tgdd.vn/Products/Images/42/370977/iphone-18-pro-do-thumb-600x600.jpg',
     N'https://www.thegioididong.com/dtdd/iphone-18-pro'),
    ('dien-thoai', N'Điện thoại iPhone Duo 256GB', 'iphone-duo-256gb', 'apple',
     'TGDD-PH-003', N'256GB - Trắng Ánh Sao', N'Trắng Ánh Sao', NULL, N'256 GB', 64990000, NULL, 12,
     N'https://cdn.tgdd.vn/Products/Images/42/370987/iphone-duo-white-thumb-600x600.jpg',
     N'https://www.thegioididong.com/dtdd/iphone-duo'),
    ('dien-thoai', N'Điện thoại Xiaomi Redmi Note 17 4G 4GB/128GB', 'xiaomi-redmi-note-17-4g-4gb-128gb', 'xiaomi',
     'TGDD-PH-004', N'4GB/128GB - Tím', N'Tím', N'4 GB', N'128 GB', 5790000, 6990000, 35,
     N'https://cdn.tgdd.vn/Products/Images/42/369617/xiaomi-redmi-note-17-4g-purple-thumb-600x600.jpg',
     N'https://www.thegioididong.com/dtdd/xiaomi-redmi-note-17-4g-4gb-128gb'),
    ('dien-thoai', N'Điện thoại iPhone 17 Pro Max 256GB', 'iphone-17-pro-max-256gb', 'apple',
     'TGDD-PH-005', N'256GB - Cam Vũ Trụ', N'Cam Vũ Trụ', NULL, N'256 GB', 34490000, 37990000, 28,
     N'https://cdn.tgdd.vn/Products/Images/42/342679/iphone-17-pro-max-cam-thumb-600x600.jpg',
     N'https://www.thegioididong.com/dtdd/iphone-17-pro-max'),
    ('dien-thoai', N'Điện thoại realme 16T 5G 8GB/128GB', 'realme-16t-5g-8gb-128gb', 'realme',
     'TGDD-PH-006', N'8GB/128GB - Xanh', N'Xanh', N'8 GB', N'128 GB', 7790000, 10290000, 30,
     N'https://cdn.tgdd.vn/Products/Images/42/367499/realme-16t-xanh-thumb-600x600.jpg',
     N'https://www.thegioididong.com/dtdd/realme-16t-5g-8gb-128gb'),
    ('dien-thoai', N'Điện thoại Xiaomi Redmi Note 17 Pro 5G 12GB/256GB', 'xiaomi-redmi-note-17-pro-5g-12gb-256gb', 'xiaomi',
     'TGDD-PH-007', N'12GB/256GB - Tím', N'Tím', N'12 GB', N'256 GB', 10490000, 13490000, 26,
     N'https://cdn.tgdd.vn/Products/Images/42/369626/xiaomi-redmi-note-17-pro-5g-purple-thumb-600x600.jpg',
     N'https://www.thegioididong.com/dtdd/xiaomi-redmi-note-17-pro-5g-12gb-256gb'),
    ('dien-thoai', N'Điện thoại Xiaomi Redmi Note 17 Pro Max 5G 12GB/256GB', 'xiaomi-redmi-note-17-pro-max-5g-12gb-256gb', 'xiaomi',
     'TGDD-PH-008', N'12GB/256GB - Tím', N'Tím', N'12 GB', N'256 GB', 12590000, 16990000, 24,
     N'https://cdn.tgdd.vn/Products/Images/42/369628/xiaomi-redmi-note-17-pro-max-5g-purple-thumb-600x600.jpg',
     N'https://www.thegioididong.com/dtdd/xiaomi-redmi-note-17-pro-max-12gb-256gb'),
    ('dien-thoai', N'Điện thoại Motorola Razr Fold 5G 12GB/256GB', 'motorola-razr-fold-5g-12gb-256gb', 'motorola',
     'TGDD-PH-009', N'12GB/256GB - Trắng', N'Trắng', N'12 GB', N'256 GB', 39490000, 49990000, 14,
     N'https://cdn.tgdd.vn/Products/Images/42/368236/motorola-razr-fold-trang-thumb-600x600.jpg',
     N'https://www.thegioididong.com/dtdd/motorola-razr-fold-12gb-256gb'),
    ('dien-thoai', N'Điện thoại iPhone 17 256GB', 'iphone-17-256gb', 'apple',
     'TGDD-PH-010', N'256GB - Xanh Lá Xô Thơm', N'Xanh Lá Xô Thơm', NULL, N'256 GB', 26990000, 28990000, 32,
     N'https://cdn.tgdd.vn/Products/Images/42/342667/iphone-17-xanh-thumb-600x600.jpg',
     N'https://www.thegioididong.com/dtdd/iphone-17'),

    -- Máy tính bảng
    ('may-tinh-bang', N'Máy tính bảng iPad A16 WiFi 128GB', 'ipad-a16-wifi-128gb', 'apple',
     'TGDD-TB-001', N'WiFi 128GB - Xanh Dương', N'Xanh Dương', NULL, N'128 GB', 11890000, 12790000, 30,
     N'https://cdn.tgdd.vn/Products/Images/522/335308/ipad-11-wifi-blue-thumb-600x600.jpg',
     N'https://www.thegioididong.com/may-tinh-bang/ipad-11-wifi-128gb'),
    ('may-tinh-bang', N'Máy tính bảng iPad Air M4 11 inch WiFi 128GB', 'ipad-air-m4-11-wifi-128gb', 'apple',
     'TGDD-TB-002', N'WiFi 128GB - Đen Xám', N'Đen - Xám', NULL, N'128 GB', 20290000, 20990000, 22,
     N'https://cdn.tgdd.vn/Products/Images/522/363417/ipad-air-m4-11-inch-wifi-128gb-xam-thumb-600x600.jpg',
     N'https://www.thegioididong.com/may-tinh-bang/ipad-air-m4-11-inch-wifi-128gb'),
    ('may-tinh-bang', N'Máy tính bảng OPPO Pad 5 8GB/256GB', 'oppo-pad-5-8gb-256gb', 'oppo',
     'TGDD-TB-003', N'8GB/256GB - Hồng', N'Hồng', N'8 GB', N'256 GB', 12540000, 13990000, 27,
     N'https://cdn.tgdd.vn/Products/Images/522/361231/oppo-pad-5-8gb-256gb-hong-thumb-600x600.jpg',
     N'https://www.thegioididong.com/may-tinh-bang/oppo-pad-5-8gb-256gb'),
    ('may-tinh-bang', N'Máy tính bảng Xiaomi Pad 8 8GB/256GB', 'xiaomi-pad-8-8gb-256gb', 'xiaomi',
     'TGDD-TB-004', N'8GB/256GB - Xanh Dương', N'Xanh Dương', N'8 GB', N'256 GB', 11290000, 13490000, 28,
     N'https://cdn.tgdd.vn/Products/Images/522/362717/xiaomi-pad-8-xanh-duong-thumb-600x600.jpg',
     N'https://www.thegioididong.com/may-tinh-bang/xiaomi-pad-8-8gb-256gb'),
    ('may-tinh-bang', N'Máy tính bảng Samsung Galaxy Tab A11+ 5G 6GB/128GB', 'samsung-galaxy-tab-a11-plus-5g-6gb-128gb', 'samsung',
     'TGDD-TB-005', N'5G 6GB/128GB - Xám', N'Xám', N'6 GB', N'128 GB', 7840000, 8890000, 34,
     N'https://cdn.tgdd.vn/Products/Images/522/359089/samsung-galaxy-tab-a11-plus-5g-6gb-128gb-xam-600x600.jpg',
     N'https://www.thegioididong.com/may-tinh-bang/samsung-galaxy-tab-a11-plus-5g-6gb-128gb'),
    ('may-tinh-bang', N'Máy tính bảng Samsung Galaxy Tab A11+ WiFi 6GB/128GB', 'samsung-galaxy-tab-a11-plus-wifi-6gb-128gb', 'samsung',
     'TGDD-TB-006', N'WiFi 6GB/128GB - Xám', N'Xám', N'6 GB', N'128 GB', 6440000, 7590000, 36,
     N'https://cdn.tgdd.vn/Products/Images/522/359086/samsung-galaxy-tab-a11-plus-wifi-6gb-128gb-xam-600x600.jpg',
     N'https://www.thegioididong.com/may-tinh-bang/samsung-galaxy-tab-a11-plus-wifi-6gb-128gb'),
    ('may-tinh-bang', N'Máy tính bảng Xiaomi Pad 8 Pro 8GB/256GB', 'xiaomi-pad-8-pro-8gb-256gb', 'xiaomi',
     'TGDD-TB-007', N'8GB/256GB - Xám', N'Xám', N'8 GB', N'256 GB', 15190000, 17990000, 25,
     N'https://cdn.tgdd.vn/Products/Images/522/362719/xiaomi-pad-8-pro-xam-thumb-600x600.jpg',
     N'https://www.thegioididong.com/may-tinh-bang/xiaomi-pad-8-pro-8gb-256gb'),
    ('may-tinh-bang', N'Máy tính bảng OPPO Pad SE WiFi màn hình nhám 4GB/128GB', 'oppo-pad-se-wifi-4gb-128gb', 'oppo',
     'TGDD-TB-008', N'WiFi 4GB/128GB - Bạc', N'Bạc', N'4 GB', N'128 GB', 6090000, 7290000, 38,
     N'https://cdn.tgdd.vn/Products/Images/522/339287/oppo-pad-se-sliver-thumb-600x600.jpg',
     N'https://www.thegioididong.com/may-tinh-bang/oppo-pad-se-matte-display-edition'),
    ('may-tinh-bang', N'Máy tính bảng iPad Pro M5 11 inch WiFi 256GB', 'ipad-pro-m5-11-wifi-256gb', 'apple',
     'TGDD-TB-009', N'WiFi 256GB - Đen', N'Đen', NULL, N'256 GB', 34490000, 35590000, 15,
     N'https://cdn.tgdd.vn/Products/Images/522/358082/ipad-pro-m5-wifi-11-inch-black-thumb-600x600.jpg',
     N'https://www.thegioididong.com/may-tinh-bang/ipad-pro-m5-11-inch-wifi-256gb'),
    ('may-tinh-bang', N'Máy tính bảng iPad mini 7 WiFi 128GB', 'ipad-mini-7-wifi-128gb', 'apple',
     'TGDD-TB-010', N'WiFi 128GB - Tím', N'Tím', NULL, N'128 GB', 15990000, 16490000, 26,
     N'https://cdn.tgdd.vn/Products/Images/522/331229/ipad-mini-7-wifi-purple-thumb-600x600.jpg',
     N'https://www.thegioididong.com/may-tinh-bang/ipad-mini-7-wifi'),

    -- Laptop
    ('laptop', N'Laptop HP 15 fc0023AU - D0BH1PA (R5 7520U, 16GB, 512GB, Full HD, Win11)', 'hp-15-fc0023au-d0bh1pa', 'hp',
     'TGDD-LT-001', N'16GB/512GB - Vàng', N'Vàng', N'16 GB', N'512 GB SSD', 21290000, 24290000, 20,
     N'https://cdn.tgdd.vn/2026/09/timerseo/361311-600x600-4.png',
     N'https://www.thegioididong.com/laptop/hp-15-fc0023au-r5-7520u-d0bh1pa'),
    ('laptop', N'Laptop MacBook Neo 13 inch A18 Pro 8GB/256GB', 'macbook-neo-13-a18-pro-8gb-256gb', 'apple',
     'TGDD-LT-002', N'8GB/256GB - Xanh Dương', N'Xanh Dương', N'8 GB', N'256 GB SSD', 18990000, 19490000, 18,
     N'https://cdn.tgdd.vn/Products/Images/44/363537/macbook-neo-13-inch-a18-pro-8gb-256gb-xanh-duong-600x600.jpg',
     N'https://www.thegioididong.com/laptop/macbook-neo-13-inch-a18-pro-8gb-256gb'),
    ('laptop', N'Laptop Asus Vivobook S14 S3407VA - LY146W (Core 5 210H, 16GB, 512GB, WUXGA, Win11)', 'asus-vivobook-s14-s3407va-ly146w', 'asus',
     'TGDD-LT-003', N'16GB/512GB - Bạc', N'Bạc', N'16 GB', N'512 GB SSD', 21490000, 22990000, 22,
     N'https://cdn.tgdd.vn/2026/09/timerseo/358132-600x600-3.png',
     N'https://www.thegioididong.com/laptop/asus-vivobook-s14-s3407va-core-5-210h-ly146w'),
    ('laptop', N'Laptop Dell 15 DC15255 - DC5R5973W1-2Y (R5 7530U, 16GB, 512GB, Full HD 120Hz, OfficeHS24+365, Win11)', 'dell-15-dc15255-dc5r5973w1-2y', 'dell',
     'TGDD-LT-004', N'16GB/512GB - Bạc', N'Bạc', N'16 GB', N'512 GB SSD', 23990000, 25690000, 17,
     N'https://cdn.tgdd.vn/2026/09/timerseo/368556-600x600-3.png',
     N'https://www.thegioididong.com/laptop/dell-15-dc15255-r5-7530u-dc5r5973w1-2y'),
    ('laptop', N'Laptop Lenovo IdeaPad Slim 3 15IPH11 - 83UR00A4VN (Ultra 5 322, 16GB, 512GB, WUXGA, Win11)', 'lenovo-ideapad-slim-3-15iph11-83ur00a4vn', 'lenovo',
     'TGDD-LT-005', N'16GB/512GB - Xám', N'Xám', N'16 GB', N'512 GB SSD', 23690000, 31990000, 19,
     N'https://cdn.tgdd.vn/2026/09/timerseo/367016-600x600-3.png',
     N'https://www.thegioididong.com/laptop/lenovo-ideapad-slim-3-15iph11-ultra-5-322-83ur00a4vn'),
    ('laptop', N'Laptop HP 240R G10 - C3RU7AT (Core 5 120U, 16GB, 512GB, Full HD, Win11)', 'hp-240r-g10-c3ru7at', 'hp',
     'TGDD-LT-006', N'16GB/512GB - Bạc', N'Bạc', N'16 GB', N'512 GB SSD', 22990000, 29090000, 21,
     N'https://cdn.tgdd.vn/2026/09/timerseo/355729-600x600-4.png',
     N'https://www.thegioididong.com/laptop/hp-240r-g10-core-5-120u-c3ru7at'),
    ('laptop', N'Laptop Dell 15 DC15250 - DC5I5897W1 (i5 1334U, 16GB, 512GB, Full HD+ 120Hz, OfficeH24+365, Win11)', 'dell-15-dc15250-dc5i5897w1', 'dell',
     'TGDD-LT-007', N'16GB/512GB - Bạc', N'Bạc', N'16 GB', N'512 GB SSD', 22990000, 24490000, 23,
     N'https://cdn.tgdd.vn/2026/09/timerseo/362025-600x600-3.png',
     N'https://www.thegioididong.com/laptop/dell-15-dc15250-i5-1334u-dc5i5897w1'),
    ('laptop', N'Laptop MacBook Air 13 inch M5 16GB/512GB/8GPU 70W', 'macbook-air-13-m5-16gb-512gb', 'apple',
     'TGDD-LT-008', N'16GB/512GB - Xanh da trời nhạt', N'Xanh da trời nhạt', N'16 GB', N'512 GB SSD', 34790000, 36590000, 16,
     N'https://cdn.tgdd.vn/Products/Images/44/363487/macbook-air-13-inch-m5-16gb-512gb-70w-xanh-da-troi-1-600x600.jpg',
     N'https://www.thegioididong.com/laptop/macbook-air-13-inch-m5-16gb-512gb-70w'),
    ('laptop', N'Laptop MSI Modern 15 F1MG-1264VN (Core 5 120U, 16GB, 512GB, Full HD, Win11)', 'msi-modern-15-f1mg-1264vn', 'msi',
     'TGDD-LT-009', N'16GB/512GB - Xám', N'Xám', N'16 GB', N'512 GB SSD', 19190000, 22390000, 24,
     N'https://cdn.tgdd.vn/2026/09/timerseo/369212-600x600-3.png',
     N'https://www.thegioididong.com/laptop/msi-modern-15-f1mg-1264vn-core-5-120u'),
    ('laptop', N'Laptop Asus Vivobook 16 A1607QA - MB067W (X1 26 100, 16GB, 512GB, WUXGA, Win11)', 'asus-vivobook-16-a1607qa-mb067w', 'asus',
     'TGDD-LT-010', N'16GB/512GB - Bạc', N'Bạc', N'16 GB', N'512 GB SSD', 19490000, 22990000, 25,
     N'https://cdn.tgdd.vn/2026/09/timerseo/364397-600x600-3.png',
     N'https://www.thegioididong.com/laptop/asus-vivobook-16-a1607qa-x1-26-100-mb067w'),

    -- Phụ kiện
    ('phu-kien', N'Ốp lưng Magnetic iPhone 18 Pro Max TPU PC TORRAS Q3 AIR', 'op-lung-magnetic-iphone-18-pro-max-torras-q3-air', 'torras',
     'TGDD-PK-001', N'Màu tím', N'Tím', NULL, NULL, 1716000, 1950000, 45,
     N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/60/371271/op-lung-magnetic-iphone-18-pro-max-tpu-pc-torras-q3-air-thumb-639248495697129718-600x600.jpg',
     N'https://www.thegioididong.com/op-lung-flipcover/op-lung-magnetic-iphone-18-pro-max-tpu-pc-torras-q3-air'),
    ('phu-kien', N'Miếng dán kính cường lực iPhone 17 Pro/18 Pro AR HD tràn viền TORRAS', 'kinh-cuong-luc-iphone-17-pro-18-pro-torras', 'torras',
     'TGDD-PK-002', N'Màu trắng', N'Trắng', NULL, NULL, 350000, 410000, 60,
     N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/1363/370277/kinh-cuong-luc-iphone-17-pro-torras-ar-hd-tran-vien-thumb-639231675322303285-600x600.jpg',
     N'https://www.thegioididong.com/mieng-dan-man-hinh/kinh-cuong-luc-iphone-17-pro-torras-ar-hd-tran-vien'),
    ('phu-kien', N'Sạc nhanh Type-C 20W TORRAS ICENANO kèm cáp Type-C 1.2m', 'sac-nhanh-type-c-20w-torras-icenano', 'torras',
     'TGDD-PK-003', N'20W - Trắng', N'Trắng', NULL, NULL, 530000, 590000, 50,
     N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/9499/370101/sac-nhanh-type-c-20w-torras-icenano-kem-cap-type-c-1-2m-thumb-639216472807661484-600x600.jpg',
     N'https://www.thegioididong.com/adapter-sac/sac-nhanh-type-c-20w-torras-icenano-kem-cap-type-c-1-2m'),
    ('phu-kien', N'Loa Bluetooth Xiaomi Sound Play', 'loa-bluetooth-xiaomi-sound-play', 'xiaomi',
     'TGDD-PK-004', N'Màu đen', N'Đen', NULL, NULL, 1590000, 1990000, 31,
     N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/2162/367810/loa-bluetooth-xiaomi-sound-play-thumb-639156457293475267-600x600.jpg',
     N'https://www.thegioididong.com/loa-laptop/loa-bluetooth-xiaomi-sound-play'),
    ('phu-kien', N'Camera IP 3MP IMOU Cue 2E C32SP', 'camera-ip-3mp-imou-cue-2e-c32sp', 'imou',
     'TGDD-PK-005', N'3MP - Trắng', N'Trắng', NULL, NULL, 370000, 450000, 40,
     N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/4728/369653/camera-ip-imou-cue-2e-c32sp-thumb2-639207598973740800-600x600.jpg',
     N'https://www.thegioididong.com/camera-giam-sat/camera-ip-imou-cue-2e-c32sp'),
    ('phu-kien', N'Pin sạc dự phòng Polymer 10000mAh Type-C PD QC 3.0 15W Aukey PB-Y46', 'pin-sac-du-phong-aukey-pb-y46', 'aukey',
     'TGDD-PK-006', N'10000mAh - Xám', N'Xám', NULL, NULL, 305000, 500000, 55,
     N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/57/361088/pin-sac-du-phong-polymer-10000mah-type-c-pd-qc-30-15w-aukey-pb-y46-xam-dam-thumb-639076131714090718-600x600.jpg',
     N'https://www.thegioididong.com/sac-dtdd/pin-sac-du-phong-polymer-10000mah-type-c-pd-qc-30-15w-aukey-pb-y46-xam-dam'),
    ('phu-kien', N'Đèn pha năng lượng mặt trời Modi MD-PT58-120-W', 'den-pha-nang-luong-mat-troi-modi-md-pt58-120-w', 'modi',
     'TGDD-PK-007', N'120W - Đen', N'Đen', NULL, NULL, 760000, 945000, 29,
     N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/14098/368720/den-pha-nang-luong-mat-troi-modi-md-pt58-120-w-wh-thumb-639183250099155208-600x600.jpg',
     N'https://www.thegioididong.com/den-nang-luong-mat-troi/den-pha-nang-luong-mat-troi-modi-md-pt58-120-w-wh'),
    ('phu-kien', N'Túi đeo chéo Tomtoc Aviator-T37 Travel Crossbody T37S1D1', 'tui-deo-cheo-tomtoc-aviator-t37', 'tomtoc',
     'TGDD-PK-008', N'Màu đen', N'Đen', NULL, NULL, 918000, 1080000, 36,
     N'https://cdnv2.tgdd.vn/mwg-static/dmx/Products/Images/13818/364553/tui-deo-cheo-tomtoc-aviator-t37-travel-crossbody-t37s1d1-thumb-639099514097438475-300x300.jpg',
     N'https://www.thegioididong.com/tui-dung-phu-kien/tui-deo-cheo-tomtoc-aviator-t37-travel-crossbody-t37s1d1'),
    ('phu-kien', N'Quạt cầm tay AVA+ Mini JF329', 'quat-cam-tay-ava-plus-mini-jf329', 'ava-plus',
     'TGDD-PK-009', N'Màu be', N'Màu be', NULL, NULL, 150000, 250000, 65,
     N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/7922/366973/quat-cam-tay-ava-mini-jf329-thumb2-639148831548248471-600x600.jpg',
     N'https://www.thegioididong.com/quat-mini/quat-cam-tay-ava-mini-jf329'),
    ('phu-kien', N'Sạc nhanh 2 cổng Type-C QC3.0 PD 30W Ugreen X516', 'sac-nhanh-2-cong-type-c-30w-ugreen-x516', 'ugreen',
     'TGDD-PK-010', N'30W - Đen', N'Đen', NULL, NULL, 250000, 350000, 58,
     N'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/9499/337969/adapter-sac-2-cong-type-c-pd-qc-3-0-gan-30w-ugreen-x516-6501-thumb02-639002929181128112-600x600.jpg',
     N'https://www.thegioididong.com/adapter-sac/adapter-sac-2-cong-type-c-pd-qc-3-0-gan-30w-ugreen-x516-6501');

    MERGE Products AS target
    USING (
        SELECT s.*, c.CategoryId, b.BrandId
        FROM @Seed s
        JOIN Categories c ON c.Slug = s.CategorySlug
        JOIN Brands b ON b.Slug = s.BrandSlug
    ) AS source
    ON target.Slug = source.ProductSlug
    WHEN MATCHED THEN
        UPDATE SET
            CategoryId = source.CategoryId,
            BrandId = source.BrandId,
            Name = source.ProductName,
            ShortDescription = N'Dữ liệu sản phẩm mẫu dùng cho website TechStore.',
            Description = N'Dữ liệu demo tham khảo từ Thế Giới Di Động, cập nhật ngày 28/09/2026. '
                        + N'Giá có thể thay đổi theo thời điểm và khu vực. Nguồn: ' + source.SourceUrl,
            Status = 'ACTIVE',
            UpdatedAt = SYSUTCDATETIME()
    WHEN NOT MATCHED THEN
        INSERT (CategoryId, BrandId, Name, Slug, ShortDescription, Description, Status)
        VALUES (
            source.CategoryId, source.BrandId, source.ProductName, source.ProductSlug,
            N'Dữ liệu sản phẩm mẫu dùng cho website TechStore.',
            N'Dữ liệu demo tham khảo từ Thế Giới Di Động, cập nhật ngày 28/09/2026. '
            + N'Giá có thể thay đổi theo thời điểm và khu vực. Nguồn: ' + source.SourceUrl,
            'ACTIVE'
        );

    MERGE ProductVariants AS target
    USING (
        SELECT p.ProductId, s.*
        FROM @Seed s
        JOIN Products p ON p.Slug = s.ProductSlug
    ) AS source
    ON target.SKU = source.SKU
    WHEN MATCHED THEN
        UPDATE SET
            ProductId = source.ProductId,
            VariantName = source.VariantName,
            Color = source.Color,
            Ram = source.Ram,
            Storage = source.Storage,
            Price = source.Price,
            OriginalPrice = source.OriginalPrice,
            StockQuantity = source.StockQuantity,
            IsActive = 1
    WHEN NOT MATCHED THEN
        INSERT (ProductId, SKU, VariantName, Color, Ram, Storage, Price, OriginalPrice, StockQuantity, IsActive)
        VALUES (
            source.ProductId, source.SKU, source.VariantName, source.Color, source.Ram,
            source.Storage, source.Price, source.OriginalPrice, source.StockQuantity, 1
        );

    UPDATE image
    SET image.IsPrimary = 0
    FROM ProductImages image
    JOIN Products product ON product.ProductId = image.ProductId
    JOIN @Seed seed ON seed.ProductSlug = product.Slug;

    MERGE ProductImages AS target
    USING (
        SELECT p.ProductId, v.VariantId, s.ImageUrl
        FROM @Seed s
        JOIN Products p ON p.Slug = s.ProductSlug
        JOIN ProductVariants v ON v.SKU = s.SKU
    ) AS source
    ON target.ProductId = source.ProductId AND target.ImageUrl = source.ImageUrl
    WHEN MATCHED THEN
        UPDATE SET VariantId = source.VariantId, IsPrimary = 1, SortOrder = 0
    WHEN NOT MATCHED THEN
        INSERT (ProductId, VariantId, ImageUrl, IsPrimary, SortOrder)
        VALUES (source.ProductId, source.VariantId, source.ImageUrl, 1, 0);

    -- Làm mới thông số của riêng bộ dữ liệu seed để tránh giữ dữ liệu cũ/sai encoding.
    DELETE specification
    FROM ProductSpecifications specification
    JOIN Products product ON product.ProductId = specification.ProductId
    JOIN @Seed seed ON seed.ProductSlug = product.Slug;

    DECLARE @Specifications TABLE (
        ProductId BIGINT NOT NULL,
        SpecificationName NVARCHAR(150) NOT NULL,
        SpecificationValue NVARCHAR(500) NOT NULL,
        SortOrder INT NOT NULL
    );

    INSERT INTO @Specifications (ProductId, SpecificationName, SpecificationValue, SortOrder)
    SELECT p.ProductId, valuesToInsert.SpecificationName,
           valuesToInsert.SpecificationValue, valuesToInsert.SortOrder
    FROM @Seed s
    JOIN Products p ON p.Slug = s.ProductSlug
    JOIN Brands b ON b.Slug = s.BrandSlug
    CROSS APPLY (VALUES
        (N'Thương hiệu', b.Name, 1),
        (N'Màu sắc', s.Color, 2),
        (N'RAM', s.Ram, 3),
        (CASE WHEN s.CategorySlug = 'laptop' THEN N'Ổ cứng' ELSE N'Dung lượng' END, s.Storage, 4),
        (N'Nguồn tham khảo', s.SourceUrl, 99)
    ) valuesToInsert(SpecificationName, SpecificationValue, SortOrder)
    WHERE valuesToInsert.SpecificationValue IS NOT NULL
      AND valuesToInsert.SpecificationValue <> N'';

    MERGE ProductSpecifications AS target
    USING @Specifications AS source
    ON target.ProductId = source.ProductId
       AND target.SpecificationName = source.SpecificationName
    WHEN MATCHED THEN
        UPDATE SET SpecificationValue = source.SpecificationValue, SortOrder = source.SortOrder
    WHEN NOT MATCHED THEN
        INSERT (ProductId, SpecificationName, SpecificationValue, SortOrder)
        VALUES (source.ProductId, source.SpecificationName, source.SpecificationValue, source.SortOrder);

    COMMIT TRANSACTION;

    SELECT c.Name AS CategoryName, COUNT(*) AS ProductCount
    FROM Products p
    JOIN Categories c ON c.CategoryId = p.CategoryId
    JOIN @Seed s ON s.ProductSlug = p.Slug
    GROUP BY c.Name
    ORDER BY c.Name;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
