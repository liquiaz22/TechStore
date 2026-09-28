param(
    [string]$BaseUrl = 'http://localhost:8080/TechStore',
    [string]$SqlServer = 'localhost',
    [string]$Database = 'TechStore',
    [switch]$KeepTestData
)

$ErrorActionPreference = 'Stop'
$runId = [DateTime]::UtcNow.ToString('yyyyMMddHHmmss')
$testEmail = 'codex.integration.' + $runId + '@techstore.local'
$otherEmail = 'codex.integration.other.' + $runId + '@techstore.local'
$invalidEmail = 'codex.integration.invalid.' + $runId + '@invalid'
$testCategorySlug = 'codex-category-' + $runId
$testBrandSlug = 'codex-brand-' + $runId
$testPassword = 'Ts!' + $runId + 'Aa'
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$results = [System.Collections.Generic.List[object]]::new()

function Add-Result([string]$name, [bool]$passed, [string]$details) {
    $script:results.Add([PSCustomObject]@{ Test = $name; Passed = $passed; Details = $details })
    if (-not $passed) { throw "Integration test failed: $name - $details" }
}

function Get-Csrf([string]$html) {
    $token = [regex]::Match($html, 'name="_csrf"\s+value="([^"]+)"').Groups[1].Value
    if (-not $token) { throw 'CSRF token was not found in HTML.' }
    return $token
}

function Invoke-Scalar([string]$query) {
    $lines = & sqlcmd -S $SqlServer -E -d $Database -C -f 65001 -W -h -1 `
        -Q "SET NOCOUNT ON; $query"
    if ($LASTEXITCODE -ne 0) { throw "sqlcmd failed: $query" }
    return ($lines | Where-Object { $_ -and $_.Trim() } | Select-Object -First 1).Trim()
}

function Cleanup-TestUser {
    $safeEmail = $testEmail.Replace("'", "''")
    $safeOtherEmail = $otherEmail.Replace("'", "''")
    $safeInvalidEmail = $invalidEmail.Replace("'", "''")
    $safeCategorySlug = $testCategorySlug.Replace("'", "''")
    $safeBrandSlug = $testBrandSlug.Replace("'", "''")
    $cleanup = @"
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
BEGIN TRANSACTION;
DECLARE @TestUsers TABLE (UserId BIGINT PRIMARY KEY);
INSERT INTO @TestUsers (UserId)
SELECT UserId FROM Users WHERE Email IN ('$safeEmail', '$safeOtherEmail', '$safeInvalidEmail');
IF EXISTS (SELECT 1 FROM @TestUsers)
BEGIN
    UPDATE variant
    SET StockQuantity = StockQuantity + stockRestore.Quantity
    FROM ProductVariants variant
    JOIN (
        SELECT item.VariantId, SUM(item.Quantity) AS Quantity
        FROM OrderItems item
        JOIN Orders orders ON orders.OrderId = item.OrderId
        WHERE orders.UserId IN (SELECT UserId FROM @TestUsers) AND orders.Status <> 'CANCELLED'
          AND item.VariantId IS NOT NULL
        GROUP BY item.VariantId
    ) stockRestore ON stockRestore.VariantId = variant.VariantId;

    DELETE payment FROM Payments payment JOIN Orders orders ON orders.OrderId = payment.OrderId WHERE orders.UserId IN (SELECT UserId FROM @TestUsers);
    DELETE history FROM OrderStatusHistory history JOIN Orders orders ON orders.OrderId = history.OrderId WHERE orders.UserId IN (SELECT UserId FROM @TestUsers);
    DELETE item FROM OrderItems item JOIN Orders orders ON orders.OrderId = item.OrderId WHERE orders.UserId IN (SELECT UserId FROM @TestUsers);
    DELETE FROM Orders WHERE UserId IN (SELECT UserId FROM @TestUsers);
    DELETE item FROM CartItems item JOIN Carts cart ON cart.CartId = item.CartId WHERE cart.UserId IN (SELECT UserId FROM @TestUsers);
    DELETE FROM Carts WHERE UserId IN (SELECT UserId FROM @TestUsers);
    DELETE FROM Favorites WHERE UserId IN (SELECT UserId FROM @TestUsers);
    DELETE FROM Addresses WHERE UserId IN (SELECT UserId FROM @TestUsers);
    DELETE FROM Users WHERE UserId IN (SELECT UserId FROM @TestUsers);
END;
DELETE FROM Categories WHERE Slug = '$safeCategorySlug';
DELETE FROM Brands WHERE Slug = '$safeBrandSlug';
COMMIT TRANSACTION;
"@
    $cleanup | & sqlcmd -S $SqlServer -E -d $Database -C -f 65001 -b
    if ($LASTEXITCODE -ne 0) { throw 'Could not clean integration-test data.' }
}

try {
    $registerPage = Invoke-WebRequest -Uri "$BaseUrl/register" -UseBasicParsing `
        -WebSession $session -TimeoutSec 20
    $csrf = Get-Csrf $registerPage.Content

    $invalidEmailResponse = Invoke-WebRequest -Uri "$BaseUrl/register" -Method Post `
        -UseBasicParsing -WebSession $session -TimeoutSec 20 -Body @{
            _csrf = $csrf
            fullName = 'Invalid Email Test'
            email = $invalidEmail
            phone = '0900000000'
            password = $testPassword
            confirmPassword = $testPassword
        }
    $invalidEmailRows = [int](Invoke-Scalar "SELECT COUNT(*) FROM Users WHERE Email='$invalidEmail';")
    Add-Result 'Reject invalid email format' `
        ($invalidEmailRows -eq 0 -and $invalidEmailResponse.Content -match 'alert-error') `
        "Rows=$invalidEmailRows"

    $invalidPhoneResponse = Invoke-WebRequest -Uri "$BaseUrl/register" -Method Post `
        -UseBasicParsing -WebSession $session -TimeoutSec 20 -Body @{
            _csrf = $csrf
            fullName = 'Invalid Phone Test'
            email = $testEmail
            phone = '12345'
            password = $testPassword
            confirmPassword = $testPassword
        }
    $invalidPhoneRows = [int](Invoke-Scalar "SELECT COUNT(*) FROM Users WHERE Email='$testEmail';")
    Add-Result 'Reject invalid registration phone' `
        ($invalidPhoneRows -eq 0 -and $invalidPhoneResponse.Content -match 'alert-error') `
        "Rows=$invalidPhoneRows"

    $longNameResponse = Invoke-WebRequest -Uri "$BaseUrl/register" -Method Post `
        -UseBasicParsing -WebSession $session -TimeoutSec 20 -Body @{
            _csrf = $csrf
            fullName = ('A' * 151)
            email = $testEmail
            phone = '0900000000'
            password = $testPassword
            confirmPassword = $testPassword
        }
    $longNameRows = [int](Invoke-Scalar "SELECT COUNT(*) FROM Users WHERE Email='$testEmail';")
    Add-Result 'Reject oversized registration name' `
        ($longNameRows -eq 0 -and $longNameResponse.Content -match 'alert-error') `
        "Rows=$longNameRows"

    $registerResponse = Invoke-WebRequest -Uri "$BaseUrl/register" -Method Post `
        -UseBasicParsing -WebSession $session -TimeoutSec 20 -Body @{
            _csrf = $csrf
            fullName = 'Codex Integration Test'
            email = $testEmail
            phone = '0900000000'
            password = $testPassword
            confirmPassword = $testPassword
        }
    Add-Result 'Register customer' ($registerResponse.BaseResponse.ResponseUri.AbsolutePath -eq '/TechStore/login') `
        $registerResponse.BaseResponse.ResponseUri.AbsolutePath

    $duplicateResponse = Invoke-WebRequest -Uri "$BaseUrl/register" -Method Post `
        -UseBasicParsing -WebSession $session -TimeoutSec 20 -Body @{
            _csrf = $csrf
            fullName = 'Duplicate Test'
            email = $testEmail
            phone = '0900000000'
            password = $testPassword
            confirmPassword = $testPassword
        }
    Add-Result 'Reject duplicate email' ($duplicateResponse.Content -match 'Email already exists') 'Duplicate email rejected'

    $wrongLogin = Invoke-WebRequest -Uri "$BaseUrl/login" -Method Post -UseBasicParsing `
        -WebSession $session -TimeoutSec 20 -Body @{
            _csrf = $csrf; email = $testEmail; password = 'WrongPassword!'
        }
    Add-Result 'Reject wrong password' ($wrongLogin.Content -match 'alert-error') 'Invalid credentials rejected'

    $loginResponse = Invoke-WebRequest -Uri "$BaseUrl/login" -Method Post -UseBasicParsing `
        -WebSession $session -TimeoutSec 20 -Body @{
            _csrf = $csrf; email = $testEmail; password = $testPassword
        }
    Add-Result 'Login customer' ($loginResponse.Content -match 'Codex Integration Test') 'Session contains current user'

    $csrfStatus = 0
    try {
        Invoke-WebRequest -Uri "$BaseUrl/login" -Method Post -UseBasicParsing -TimeoutSec 20 `
            -Body @{ email = $testEmail; password = $testPassword } | Out-Null
    } catch {
        if ($_.Exception.Response) { $csrfStatus = [int]$_.Exception.Response.StatusCode }
    }
    Add-Result 'Reject POST without CSRF' ($csrfStatus -eq 403) "HTTP $csrfStatus"

    $adminStatus = 0
    try {
        Invoke-WebRequest -Uri "$BaseUrl/admin" -UseBasicParsing -WebSession $session -TimeoutSec 20 | Out-Null
        $adminStatus = 200
    } catch {
        if ($_.Exception.Response) { $adminStatus = [int]$_.Exception.Response.StatusCode }
    }
    Add-Result 'Customer cannot access admin' ($adminStatus -eq 403) "HTTP $adminStatus"

    $homeResponse = Invoke-WebRequest -Uri "$BaseUrl/home" -UseBasicParsing -WebSession $session -TimeoutSec 20
    $productId = [regex]::Match($homeResponse.Content, 'name="productId"\s+value="(\d+)"').Groups[1].Value
    $slug = [regex]::Match($homeResponse.Content, '/product\?slug=([^"&]+)').Groups[1].Value
    Add-Result 'Load product catalog' ([bool]$productId -and [bool]$slug) "ProductId=$productId; Slug=$slug"

    $favoriteResponse = Invoke-WebRequest -Uri "$BaseUrl/favorites/toggle" -Method Post `
        -UseBasicParsing -WebSession $session -TimeoutSec 20 -Body @{
            _csrf = $csrf; productId = $productId; back = '/favorites'
        }
    $favoriteCount = [int](Invoke-Scalar "SELECT COUNT(*) FROM Favorites f JOIN Users u ON u.UserId=f.UserId WHERE u.Email='$testEmail';")
    Add-Result 'Add favorite' ($favoriteCount -eq 1 -and $favoriteResponse.Content -match 'product-card') "FavoriteCount=$favoriteCount"

    $detailResponse = Invoke-WebRequest -Uri "$BaseUrl/product?slug=$slug" -UseBasicParsing `
        -WebSession $session -TimeoutSec 20
    $variantId = [regex]::Match($detailResponse.Content, 'name="variantId"\s+value="(\d+)"').Groups[1].Value
    Add-Result 'Load product detail' ([bool]$variantId) "VariantId=$variantId"
    $stockBefore = [int](Invoke-Scalar "SELECT StockQuantity FROM ProductVariants WHERE VariantId=$variantId;")

    Invoke-WebRequest -Uri "$BaseUrl/cart/add" -Method Post -UseBasicParsing `
        -WebSession $session -TimeoutSec 20 -Body @{
            _csrf = $csrf; variantId = $variantId; quantity = ($stockBefore + 1)
        } | Out-Null
    $overstockRows = [int](Invoke-Scalar "SELECT COUNT(*) FROM CartItems ci JOIN Carts c ON c.CartId=ci.CartId JOIN Users u ON u.UserId=c.UserId WHERE u.Email='$testEmail' AND c.Status='ACTIVE' AND ci.VariantId=$variantId;")
    Add-Result 'Reject quantity above stock' ($overstockRows -eq 0) "CartRows=$overstockRows; Stock=$stockBefore"

    1..2 | ForEach-Object {
        Invoke-WebRequest -Uri "$BaseUrl/cart/add" -Method Post -UseBasicParsing `
            -WebSession $session -TimeoutSec 20 -Body @{
                _csrf = $csrf; variantId = $variantId; quantity = 1
            } | Out-Null
    }
    $cartState = Invoke-Scalar "SELECT CONCAT(COUNT(*), ':', MAX(ci.Quantity)) FROM CartItems ci JOIN Carts c ON c.CartId=ci.CartId JOIN Users u ON u.UserId=c.UserId WHERE u.Email='$testEmail' AND c.Status='ACTIVE' AND ci.VariantId=$variantId;"
    Add-Result 'Merge duplicate SKU in cart' ($cartState -eq '1:2') "Rows:Quantity=$cartState"

    $cartResponse = Invoke-WebRequest -Uri "$BaseUrl/cart" -UseBasicParsing -WebSession $session -TimeoutSec 20
    Add-Result 'Render cart' ($cartResponse.StatusCode -eq 200 -and $cartResponse.Content -match 'href="/TechStore/checkout"') "HTTP $($cartResponse.StatusCode)"

    $checkoutPage = Invoke-WebRequest -Uri "$BaseUrl/checkout" -UseBasicParsing -WebSession $session -TimeoutSec 20
    Add-Result 'Render checkout' ($checkoutPage.StatusCode -eq 200 -and $checkoutPage.Content -match 'action="/TechStore/checkout"') "HTTP $($checkoutPage.StatusCode)"

    $invalidCheckoutPhone = Invoke-WebRequest -Uri "$BaseUrl/checkout" -Method Post -UseBasicParsing `
        -WebSession $session -TimeoutSec 30 -Body @{
            _csrf = $csrf
            addressId = ''
            receiverName = 'Codex Test Receiver'
            receiverPhone = '12345'
            province = 'Ho Chi Minh City'
            district = 'District 1'
            ward = 'Ben Nghe'
            addressLine = '1 Integration Test Street'
            customerNote = ''
            paymentMethod = 'COD'
        }
    $ordersBeforeValidCheckout = [int](Invoke-Scalar "SELECT COUNT(*) FROM Orders orders JOIN Users users ON users.UserId=orders.UserId WHERE users.Email='$testEmail';")
    Add-Result 'Reject invalid checkout phone' `
        ($ordersBeforeValidCheckout -eq 0 -and $invalidCheckoutPhone.Content -match 'alert-error') `
        "Orders=$ordersBeforeValidCheckout"

    $oversizedNoteCheckout = Invoke-WebRequest -Uri "$BaseUrl/checkout" -Method Post -UseBasicParsing `
        -WebSession $session -TimeoutSec 30 -Body @{
            _csrf = $csrf
            addressId = ''
            receiverName = 'Codex Test Receiver'
            receiverPhone = '0900000001'
            province = 'Ho Chi Minh City'
            district = 'District 1'
            ward = 'Ben Nghe'
            addressLine = '1 Integration Test Street'
            customerNote = ('N' * 501)
            paymentMethod = 'COD'
        }
    $ordersAfterOversizedNote = [int](Invoke-Scalar "SELECT COUNT(*) FROM Orders orders JOIN Users users ON users.UserId=orders.UserId WHERE users.Email='$testEmail';")
    Add-Result 'Reject oversized order note' `
        ($ordersAfterOversizedNote -eq 0 -and $oversizedNoteCheckout.Content -match 'alert-error') `
        "Orders=$ordersAfterOversizedNote"

    $checkoutResponse = Invoke-WebRequest -Uri "$BaseUrl/checkout" -Method Post -UseBasicParsing `
        -WebSession $session -TimeoutSec 30 -Body @{
            _csrf = $csrf
            addressId = ''
            receiverName = 'Codex Test Receiver'
            receiverPhone = '0900000001'
            province = 'Ho Chi Minh City'
            district = 'District 1'
            ward = 'Ben Nghe'
            addressLine = '1 Integration Test Street'
            customerNote = 'Temporary integration test data'
            paymentMethod = 'COD'
        }
    $orderId = [regex]::Match($checkoutResponse.Content, 'name="orderId"\s+value="(\d+)"').Groups[1].Value
    $orderCode = [regex]::Match($checkoutResponse.Content, '<h1>([^<]+)</h1>').Groups[1].Value
    Add-Result 'Place COD order' ([bool]$orderId -and $checkoutResponse.Content -match 'PENDING') "OrderId=$orderId; Code=$orderCode"

    $stockAfterOrder = [int](Invoke-Scalar "SELECT StockQuantity FROM ProductVariants WHERE VariantId=$variantId;")
    Add-Result 'Decrease stock in transaction' ($stockAfterOrder -eq ($stockBefore - 2)) "Before=$stockBefore; After=$stockAfterOrder"

    $totalValid = Invoke-Scalar @"
SELECT CASE WHEN EXISTS (
    SELECT 1 FROM Orders orders
    WHERE orders.OrderId=$orderId
      AND orders.Subtotal=(SELECT SUM(item.LineTotal) FROM OrderItems item WHERE item.OrderId=orders.OrderId)
      AND orders.TotalAmount=orders.Subtotal+orders.ShippingFee-orders.DiscountAmount
      AND EXISTS (SELECT 1 FROM Payments payment WHERE payment.OrderId=orders.OrderId AND payment.Amount=orders.TotalAmount)
) THEN 1 ELSE 0 END;
"@
    Add-Result 'Validate backend order total' ($totalValid -eq '1') "OrderId=$orderId"

    $ordersResponse = Invoke-WebRequest -Uri "$BaseUrl/orders" -UseBasicParsing -WebSession $session -TimeoutSec 20
    Add-Result 'Render order history' ($ordersResponse.Content -match [regex]::Escape($orderCode)) "Order=$orderCode"

    $safeEmail = $testEmail.Replace("'", "''")
    $safeOtherEmail = $otherEmail.Replace("'", "''")
    & sqlcmd -S $SqlServer -E -d $Database -C -f 65001 -b -Q "INSERT INTO Users (Email, PasswordHash, FullName, Role, Status) SELECT '$safeOtherEmail', PasswordHash, N'Other Integration User', 'CUSTOMER', 'ACTIVE' FROM Users WHERE Email='$safeEmail';" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Could not create the second temporary user.' }
    $otherSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $otherLoginPage = Invoke-WebRequest -Uri "$BaseUrl/login" -UseBasicParsing -WebSession $otherSession -TimeoutSec 20
    $otherCsrf = Get-Csrf $otherLoginPage.Content
    Invoke-WebRequest -Uri "$BaseUrl/login" -Method Post -UseBasicParsing -WebSession $otherSession `
        -TimeoutSec 20 -Body @{ _csrf=$otherCsrf; email=$otherEmail; password=$testPassword } | Out-Null
    $ownershipStatus = 0
    try {
        Invoke-WebRequest -Uri "$BaseUrl/orders/detail?code=$orderCode" -UseBasicParsing `
            -WebSession $otherSession -TimeoutSec 20 | Out-Null
        $ownershipStatus = 200
    } catch {
        if ($_.Exception.Response) { $ownershipStatus = [int]$_.Exception.Response.StatusCode }
    }
    Add-Result 'Protect order ownership' ($ownershipStatus -eq 403) "HTTP $ownershipStatus"

    Invoke-WebRequest -Uri "$BaseUrl/orders/cancel" -Method Post -UseBasicParsing `
        -WebSession $session -TimeoutSec 30 -Body @{
            _csrf = $csrf; orderId = $orderId
        } | Out-Null
    $orderStatus = Invoke-Scalar "SELECT Status FROM Orders WHERE OrderId=$orderId;"
    $stockAfterCancel = [int](Invoke-Scalar "SELECT StockQuantity FROM ProductVariants WHERE VariantId=$variantId;")
    Add-Result 'Cancel order and restore stock' ($orderStatus -eq 'CANCELLED' -and $stockAfterCancel -eq $stockBefore) `
        "Status=$orderStatus; Stock=$stockAfterCancel"

    Invoke-WebRequest -Uri "$BaseUrl/logout" -Method Post -UseBasicParsing -WebSession $session `
        -TimeoutSec 20 -Body @{ _csrf = $csrf } | Out-Null
    & sqlcmd -S $SqlServer -E -d $Database -C -f 65001 -b `
        -Q "UPDATE Users SET Role='ADMIN' WHERE Email='$safeEmail';" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Could not promote temporary user for admin smoke test.' }

    $adminSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $adminLoginPage = Invoke-WebRequest -Uri "$BaseUrl/login" -UseBasicParsing -WebSession $adminSession -TimeoutSec 20
    $adminCsrf = Get-Csrf $adminLoginPage.Content
    Invoke-WebRequest -Uri "$BaseUrl/login" -Method Post -UseBasicParsing -WebSession $adminSession `
        -TimeoutSec 20 -Body @{ _csrf=$adminCsrf; email=$testEmail; password=$testPassword } | Out-Null

    foreach ($adminPath in @('/admin', '/admin/products', '/admin/catalog', '/admin/orders', '/admin/users')) {
        $adminResponse = Invoke-WebRequest -Uri ($BaseUrl + $adminPath) -UseBasicParsing `
            -WebSession $adminSession -TimeoutSec 30
        Add-Result "Admin page $adminPath" ($adminResponse.StatusCode -eq 200) "HTTP $($adminResponse.StatusCode)"
    }

    Invoke-WebRequest -Uri "$BaseUrl/admin/catalog" -Method Post -UseBasicParsing `
        -WebSession $adminSession -TimeoutSec 20 -Body @{
            _csrf=$adminCsrf; type='category'; action='save'; name='Codex Test Category'
            slug=$testCategorySlug; parentId=''; active='on'
        } | Out-Null
    $categoryId = Invoke-Scalar "SELECT CategoryId FROM Categories WHERE Slug='$testCategorySlug';"
    Add-Result 'Admin creates category' ([bool]$categoryId) "CategoryId=$categoryId"

    Invoke-WebRequest -Uri "$BaseUrl/admin/catalog" -Method Post -UseBasicParsing `
        -WebSession $adminSession -TimeoutSec 20 -Body @{
            _csrf=$adminCsrf; type='brand'; action='save'; name='Codex Test Brand'
            slug=$testBrandSlug; logoUrl='https://example.test/logo.png'; active='on'
        } | Out-Null
    $brandId = Invoke-Scalar "SELECT BrandId FROM Brands WHERE Slug='$testBrandSlug';"
    Add-Result 'Admin creates brand' ([bool]$brandId) "BrandId=$brandId"

    $duplicateCategory = Invoke-WebRequest -Uri "$BaseUrl/admin/catalog" -Method Post -UseBasicParsing `
        -WebSession $adminSession -TimeoutSec 20 -Body @{
            _csrf=$adminCsrf; type='category'; action='save'; name='Duplicate Category'
            slug=$testCategorySlug; parentId=''; active='on'
        }
    $categoryCount = [int](Invoke-Scalar "SELECT COUNT(*) FROM Categories WHERE Slug='$testCategorySlug';")
    Add-Result 'Reject duplicate category slug' ($categoryCount -eq 1 -and $duplicateCategory.Content -match 'alert-error') "Rows=$categoryCount"

    $duplicateBrand = Invoke-WebRequest -Uri "$BaseUrl/admin/catalog" -Method Post -UseBasicParsing `
        -WebSession $adminSession -TimeoutSec 20 -Body @{
            _csrf=$adminCsrf; type='brand'; action='save'; name='Duplicate Brand'
            slug=$testBrandSlug; logoUrl=''; active='on'
        }
    $brandCount = [int](Invoke-Scalar "SELECT COUNT(*) FROM Brands WHERE Slug='$testBrandSlug';")
    Add-Result 'Reject duplicate brand slug' ($brandCount -eq 1 -and $duplicateBrand.Content -match 'alert-error') "Rows=$brandCount"

    Invoke-WebRequest -Uri "$BaseUrl/admin/catalog" -Method Post -UseBasicParsing `
        -WebSession $adminSession -TimeoutSec 20 -Body @{
            _csrf=$adminCsrf; type='category'; action='save'; id=$categoryId
            name='Codex Category Updated'; slug=$testCategorySlug; parentId=''; active='on'
        } | Out-Null
    Invoke-WebRequest -Uri "$BaseUrl/admin/catalog" -Method Post -UseBasicParsing `
        -WebSession $adminSession -TimeoutSec 20 -Body @{
            _csrf=$adminCsrf; type='brand'; action='save'; id=$brandId
            name='Codex Brand Updated'; slug=$testBrandSlug
            logoUrl='https://example.test/updated-logo.png'; active='on'
        } | Out-Null
    $updatedCatalog = Invoke-Scalar "SELECT CONCAT((SELECT Name FROM Categories WHERE CategoryId=$categoryId), '|', (SELECT Name FROM Brands WHERE BrandId=$brandId));"
    Add-Result 'Admin updates category and brand' ($updatedCatalog -eq 'Codex Category Updated|Codex Brand Updated') $updatedCatalog

    $categoryEditPage = Invoke-WebRequest -Uri "$BaseUrl/admin/catalog?editCategory=$categoryId" `
        -UseBasicParsing -WebSession $adminSession -TimeoutSec 20
    $brandEditPage = Invoke-WebRequest -Uri "$BaseUrl/admin/catalog?editBrand=$brandId" `
        -UseBasicParsing -WebSession $adminSession -TimeoutSec 20
    Add-Result 'Render catalog edit forms' `
        ($categoryEditPage.Content -match 'Codex Category Updated' -and $brandEditPage.Content -match 'Codex Brand Updated') `
        'Category and brand edit forms populated'

    Invoke-WebRequest -Uri "$BaseUrl/admin/catalog" -Method Post -UseBasicParsing `
        -WebSession $adminSession -TimeoutSec 20 -Body @{
            _csrf=$adminCsrf; type='category'; action='toggle'; id=$categoryId
        } | Out-Null
    Invoke-WebRequest -Uri "$BaseUrl/admin/catalog" -Method Post -UseBasicParsing `
        -WebSession $adminSession -TimeoutSec 20 -Body @{
            _csrf=$adminCsrf; type='brand'; action='toggle'; id=$brandId
        } | Out-Null
    $inactiveCatalog = Invoke-Scalar "SELECT CONCAT((SELECT CAST(IsActive AS int) FROM Categories WHERE CategoryId=$categoryId), ':', (SELECT CAST(IsActive AS int) FROM Brands WHERE BrandId=$brandId));"
    Add-Result 'Admin hides category and brand' ($inactiveCatalog -eq '0:0') "ActiveFlags=$inactiveCatalog"
}
finally {
    if (-not $KeepTestData) { Cleanup-TestUser }
    $results | Format-Table -AutoSize
    $passed = @($results | Where-Object Passed).Count
    "Passed $passed/$($results.Count) integration checks. Test data kept: $([bool]$KeepTestData)"
}
