$ErrorActionPreference = 'Stop'

$scriptDirectory = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    Join-Path (Get-Location) 'scripts'
} else {
    $PSScriptRoot
}
$projectRoot = Split-Path -Parent $scriptDirectory
$templatePath = Join-Path $projectRoot 'Template_TestPlan_Tiếng_Việt.docx'
$outputPath = Join-Path $projectRoot 'Y1_THAO_LUAN_VA_DANH_GIA_TECHSTORE_CAP_NHAT.docx'

if (-not (Test-Path -LiteralPath $templatePath)) {
    throw "Không tìm thấy template: $templatePath"
}

[System.IO.File]::Copy($templatePath, $outputPath, $true)

$word = $null
$document = $null

function Get-EndRange {
    return $script:document.Range($script:document.Content.End - 1, $script:document.Content.End - 1)
}

function Add-Paragraph {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [string]$Style = 'Normal',
        [int]$SpaceAfter = 6
    )
    $range = Get-EndRange
    $range.InsertAfter($Text)
    try { $range.Style = $Style } catch { $range.Style = 'Normal' }
    $range.Font.Name = 'Times New Roman'
    $range.ParagraphFormat.SpaceAfter = $SpaceAfter
    $range.InsertParagraphAfter()
    return $range
}

function Add-Heading {
    param([string]$Text, [int]$Level = 2)
    $style = if ($Level -le 1) { 'Heading 1' } else { 'Heading 2' }
    $range = Add-Paragraph -Text $Text -Style $style -SpaceAfter 8
    $range.ParagraphFormat.KeepWithNext = -1
}

function Add-DisplayHeading {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [int]$FontSize = 18
    )
    $range = Add-Paragraph -Text $Text -Style 'Normal' -SpaceAfter 10
    $range.Font.Name = 'Times New Roman'
    $range.Font.Size = $FontSize
    $range.Font.Bold = -1
    $range.ParagraphFormat.OutlineLevel = 10
    $range.ParagraphFormat.KeepWithNext = -1
    return $range
}

function Add-BodyText {
    param([string]$Text)
    [void](Add-Paragraph -Text $Text -Style 'Body Text' -SpaceAfter 6)
}

function Add-Bullet {
    param([string]$Text)
    $range = Add-Paragraph -Text $Text -Style 'Normal' -SpaceAfter 3
    $range.ListFormat.ApplyBulletDefault()
}

function Add-NumberedItem {
    param([string]$Text)
    $range = Add-Paragraph -Text $Text -Style 'Normal' -SpaceAfter 3
    $range.ListFormat.ApplyNumberDefault()
}

function Add-PageBreak {
    $range = Get-EndRange
    $range.InsertBreak(7)
}

function Add-Table {
    param(
        [Parameter(Mandatory = $true)][object[]]$Rows,
        [int]$FontSize = 10
    )
    if ($Rows.Count -eq 0) { return }
    $columnCount = $Rows[0].Count
    $range = Get-EndRange
    $table = $script:document.Tables.Add($range, $Rows.Count, $columnCount)
    $table.Style = 'Table Grid'
    $table.AllowAutoFit = -1
    for ($rowIndex = 0; $rowIndex -lt $Rows.Count; $rowIndex++) {
        for ($columnIndex = 0; $columnIndex -lt $columnCount; $columnIndex++) {
            $cell = $table.Cell($rowIndex + 1, $columnIndex + 1)
            $cell.Range.Text = [string]$Rows[$rowIndex][$columnIndex]
            $cell.Range.Style = 'Normal'
            $cell.Range.ParagraphFormat.OutlineLevel = 10
            $cell.Range.Font.Name = 'Times New Roman'
            $cell.Range.Font.Size = $FontSize
            $cell.VerticalAlignment = 1
        }
    }
    $table.Rows.Item(1).Range.Bold = -1
    $table.Rows.Item(1).Range.Font.Color = 16777215
    $table.Rows.Item(1).Shading.BackgroundPatternColor = 10053222
    $table.Rows.Item(1).HeadingFormat = -1
    $table.AutoFitBehavior(2)
    $after = $script:document.Range($table.Range.End, $table.Range.End)
    $after.InsertParagraphAfter()
    return $table
}

function Replace-AllText {
    param([string]$FindText, [string]$ReplacementText)
    $range = $script:document.Content
    $find = $range.Find
    $find.ClearFormatting()
    $find.Replacement.ClearFormatting()
    $find.Text = $FindText
    $find.Replacement.Text = $ReplacementText
    [void]$find.Execute($FindText, $false, $false, $false, $false, $false,
        $true, 1, $false, $ReplacementText, 2)
}

function Set-NonTocTitle {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [int]$FontSize = 18,
        [int]$Alignment = 1
    )
    $range = $script:document.Content.Duplicate
    $range.Find.ClearFormatting()
    $range.Find.Text = $Text
    if ($range.Find.Execute()) {
        $range.Style = 'Normal'
        $range.Font.Name = 'Times New Roman'
        $range.Font.Size = $FontSize
        $range.Font.Bold = -1
        $range.ParagraphFormat.Alignment = $Alignment
        $range.ParagraphFormat.OutlineLevel = 10
    }
}

try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $script:document = $word.Documents.Open($outputPath)
    $document = $script:document

    Replace-AllText 'KẾ HOẠCH KIỂM THỬ' 'THẢO LUẬN VÀ ĐÁNH GIÁ ĐỀ TÀI'
    Replace-AllText 'DỰ ÁN: ABC - XYZ' 'Y1 - ĐỀ TÀI TECHSTORE'
    Set-NonTocTitle -Text 'THẢO LUẬN VÀ ĐÁNH GIÁ ĐỀ TÀI' -FontSize 24
    Set-NonTocTitle -Text 'Y1 - ĐỀ TÀI TECHSTORE' -FontSize 16
    Set-NonTocTitle -Text 'LỊCH SỬ SỬA ĐỔI' -FontSize 18

    $history = $document.Tables.Item(1)
    while ($history.Rows.Count -gt 2) {
        [void]$history.Rows.Item($history.Rows.Count).Delete()
    }
    $history.Cell(2, 1).Range.Text = '30/09/2026'
    $history.Cell(2, 2).Range.Text = '1.0'
    $history.Cell(2, 3).Range.Text = 'Hoàn thiện nội dung Y1 cho đề tài TechStore'
    $history.Cell(2, 4).Range.Text = 'Nhóm dự án TechStore'
    $history.Cell(2, 5).Range.Text = '[Giảng viên/Nhóm trưởng duyệt]'

    $searchRange = $document.Content.Duplicate
    $searchRange.Find.ClearFormatting()
    $searchRange.Find.Text = 'MỤC LỤC'
    if (-not $searchRange.Find.Execute()) {
        throw 'Không tìm thấy vị trí MỤC LỤC trong template.'
    }
    $deleteRange = $document.Range($searchRange.Start, $document.Content.End - 1)
    $deleteRange.Delete()

    [void](Add-DisplayHeading -Text 'MỤC LỤC' -FontSize 18)
    [void](Add-Paragraph -Text '[[TECHSTORE_Y1_TOC]]' -Style 'Normal' -SpaceAfter 0)
    Add-PageBreak

    [void](Add-DisplayHeading -Text 'Y1. THẢO LUẬN VÀ ĐÁNH GIÁ ĐỀ TÀI' -FontSize 20)
    Add-Heading '1. TỔNG QUAN ĐỀ TÀI TECHSTORE' 1
    Add-BodyText 'TechStore là website thương mại điện tử bán điện thoại, iPad/máy tính bảng, laptop và phụ kiện. Hệ thống được xây dựng bằng Java Servlet/JSP theo mô hình MVC, Hibernate/JPA, SQL Server, Apache Tomcat và HTML/CSS/JavaScript. Website có khu vực cửa hàng dành cho khách hàng, khu vực quản trị dành cho ADMIN, chức năng thanh toán COD/VNPay sandbox và gửi email đặt lại mật khẩu.'
    Add-BodyText 'Việc kiểm thử cần tập trung không chỉ vào khả năng hiển thị của giao diện mà còn vào tính đúng đắn của nghiệp vụ, quyền truy cập, giao dịch cơ sở dữ liệu, tồn kho và thanh toán. Các sai sót ở đơn hàng, số tiền, tồn kho hoặc phân quyền có mức ảnh hưởng cao hơn lỗi trình bày thông thường.'

    Add-Heading '1.1. Đánh giá đặc điểm của đề tài' 2
    [void](Add-Table -Rows @(
        @('Đặc điểm', 'Đánh giá đối với hoạt động kiểm thử'),
        @('Nhiều vai trò sử dụng', 'Phải kiểm tra Guest, CUSTOMER và ADMIN; đặc biệt là chuyển hướng, HTTP 403 và quyền sở hữu dữ liệu.'),
        @('Luồng mua hàng nhiều bước', 'Cần kiểm thử xuyên suốt từ sản phẩm, variant, giỏ hàng, checkout, tạo đơn, thanh toán đến lịch sử đơn.'),
        @('Dữ liệu có quan hệ', 'Phải đối soát Users, Products, ProductVariants, Carts, Orders, OrderItems, Payments và lịch sử trạng thái.'),
        @('Tích hợp bên ngoài', 'VNPay sandbox và email có thể không ổn định; cần tách lỗi hệ thống với lỗi môi trường/dịch vụ.'),
        @('Thay đổi trạng thái', 'Đơn hàng và thanh toán phải tuân thủ các chuyển trạng thái hợp lệ, không xử lý lặp callback.'),
        @('Rủi ro đồng thời', 'Hai người mua SKU cuối hoặc hai thao tác hủy cùng lúc có thể làm tồn kho âm hoặc hoàn kho trùng.'),
        @('Giao diện responsive', 'Cần kiểm tra desktop/mobile, bàn phím, font tiếng Việt, trạng thái lỗi/rỗng/loading và CTA chính.')
    ))

    Add-Heading '1.2. Mục tiêu thảo luận và đánh giá' 2
    Add-Bullet 'Xác định đầy đủ các nhiệm vụ cần thực hiện để lập và quản lý kế hoạch kiểm thử.'
    Add-Bullet 'Lựa chọn các mức kiểm thử phù hợp với kiến trúc và mức rủi ro của TechStore.'
    Add-Bullet 'Làm cơ sở cho tài liệu TEST_PLAN_TECHSTORE.docx, testcase, dữ liệu kiểm thử và báo cáo tổng kết.'

    Add-PageBreak
    Add-Heading '2. Y1.a - CÁC NHIỆM VỤ CHÍNH ĐỂ LẬP KẾ HOẠCH KIỂM THỬ' 1
    Add-Heading '2.1. Mục tiêu của hoạt động lập kế hoạch' 2
    Add-BodyText 'Lập kế hoạch kiểm thử nhằm thống nhất nhóm sẽ kiểm tra nội dung gì, kiểm tra bằng cách nào, ai thực hiện, thực hiện khi nào, trên môi trường nào và dựa vào tiêu chí nào để kết luận phiên bản đạt hay không đạt. Kế hoạch phải ưu tiên những rủi ro có thể gây sai tiền, sai đơn, sai tồn kho, mất dữ liệu hoặc vượt quyền.'

    Add-Heading '2.2. Danh sách nhiệm vụ chính' 2
    [void](Add-Table -Rows @(
        @('STT', 'Nhiệm vụ', 'Áp dụng cho TechStore', 'Đầu ra'),
        @('1', 'Thu thập và phân tích yêu cầu', 'Rà source code, database, tài liệu triển khai, UI/UX và yêu cầu bài tập.', 'Danh sách yêu cầu và câu hỏi cần làm rõ'),
        @('2', 'Xác định mục tiêu kiểm thử', 'Xác nhận chức năng đúng, dữ liệu toàn vẹn, quyền an toàn và UI sử dụng được.', 'Mục tiêu đo được của đợt kiểm thử'),
        @('3', 'Xác định phạm vi', 'Chốt chức năng được kiểm thử, không kiểm thử và giới hạn phiên bản.', 'Danh sách in-scope/out-of-scope'),
        @('4', 'Nhận diện và ưu tiên rủi ro', 'Ưu tiên xác thực, phân quyền, checkout, tồn kho, đơn hàng và VNPay.', 'Risk register và mức P0/P1/P2'),
        @('5', 'Chọn chiến lược và mức kiểm thử', 'Áp dụng Unit, Integration, System và Acceptance theo từng thành phần.', 'Test strategy và test level matrix'),
        @('6', 'Chọn loại và kỹ thuật kiểm thử', 'Functional, security, compatibility, responsive, accessibility, performance; dùng biên, phân vùng, bảng quyết định và chuyển trạng thái.', 'Danh mục test type/technique'),
        @('7', 'Xác định môi trường và công cụ', 'Java 21, Tomcat 10.1, SQL Server, Chrome/Edge/Firefox, Postman/cURL, SSMS và VNPay sandbox.', 'Cấu hình môi trường và tool list'),
        @('8', 'Chuẩn bị dữ liệu kiểm thử', 'Tạo Guest/Customer/Locked/Admin, SKU còn hàng/hết hàng, đơn COD/VNPay và dữ liệu biên.', 'Test data và script seed/cleanup'),
        @('9', 'Ước lượng nguồn lực và phân công', 'Giao module cho Test Manager, Test Designer, Tester và Developer; xác định người review.', 'Bảng vai trò và phân công'),
        @('10', 'Lập lịch thực hiện', 'Xếp các mốc review, thiết kế testcase, test vòng 1, sửa lỗi, regression và nghiệm thu.', 'Schedule/Gantt và milestone'),
        @('11', 'Xác định tiêu chí kiểm soát', 'Đặt điều kiện bắt đầu, tạm dừng, tiếp tục, kết thúc và chấp nhận.', 'Entry/exit/suspension criteria'),
        @('12', 'Quy định quản lý lỗi', 'Thống nhất severity, trạng thái, bằng chứng, owner và quy trình retest.', 'Defect workflow và defect template'),
        @('13', 'Xác định báo cáo và sản phẩm bàn giao', 'Test Plan, Test Case, Test Result, Defect Log, Test Summary và Sign-off.', 'Danh sách deliverables'),
        @('14', 'Review, phê duyệt và cập nhật', 'Nhóm review chéo; trưởng nhóm/giảng viên duyệt; cập nhật khi phạm vi thay đổi.', 'Test Plan được phê duyệt và lịch sử sửa đổi')
    ) -FontSize 9)

    Add-Heading '2.3. Trình tự thực hiện đề xuất' 2
    Add-NumberedItem 'Phân tích yêu cầu, source code, database và các luồng sử dụng thực tế.'
    Add-NumberedItem 'Chốt mục tiêu, phạm vi và những rủi ro quan trọng của phiên bản.'
    Add-NumberedItem 'Chọn mức kiểm thử, loại kiểm thử, kỹ thuật thiết kế và tiêu chí đánh giá.'
    Add-NumberedItem 'Chuẩn bị môi trường, tài khoản, dữ liệu, công cụ và bản build.'
    Add-NumberedItem 'Ước lượng công việc, phân công thành viên và lập lịch thực hiện.'
    Add-NumberedItem 'Thiết kế/review testcase; thực thi; ghi nhận defect; retest và regression.'
    Add-NumberedItem 'Tổng hợp kết quả, đánh giá tiêu chí chấp nhận và lập Test Summary Report.'

    Add-Heading '2.4. Phân công trách nhiệm ở mức lập kế hoạch' 2
    [void](Add-Table -Rows @(
        @('Vai trò', 'Trách nhiệm trong giai đoạn lập kế hoạch'),
        @('Test Manager/Trưởng nhóm', 'Chốt phạm vi, ưu tiên, lịch trình, nguồn lực, tiêu chí dừng và phê duyệt kế hoạch.'),
        @('Test Designer', 'Phân tích yêu cầu, xây ma trận truy vết, chọn kỹ thuật và thiết kế testcase/dữ liệu.'),
        @('Tester', 'Ước lượng khối lượng, chuẩn bị môi trường/dữ liệu, góp ý tính khả thi và thực thi theo phân công.'),
        @('Developer', 'Cung cấp thông tin kỹ thuật, build/log, hỗ trợ cô lập lỗi và sửa lỗi.'),
        @('Người duyệt', 'Kiểm tra mức phù hợp với yêu cầu đề tài và chấp thuận Test Plan/Test Summary.')
    ))
    Add-BodyText 'Tên thành viên thực tế và phân công chi tiết được điền trong bảng Nhân sự của TEST_PLAN_TECHSTORE.docx trước khi nhóm nộp bài.'

    Add-PageBreak
    Add-Heading '3. Y1.b - CÁC MỨC KIỂM THỬ CẦN THỰC HIỆN' 1
    Add-Heading '3.1. Phân biệt mức kiểm thử và loại kiểm thử' 2
    Add-BodyText 'Mức kiểm thử thể hiện phạm vi tích hợp tăng dần của đối tượng được kiểm tra: Unit/Component → Integration → System → Acceptance. Functional, security, performance, compatibility, usability, regression và smoke là loại hoặc mục đích kiểm thử; chúng có thể được thực hiện tại một hoặc nhiều mức, nhưng không thay thế bốn mức kiểm thử.'

    Add-Heading '3.2. Mức 1 - Kiểm thử đơn vị (Unit/Component Testing)' 2
    Add-BodyText 'Mục tiêu: kiểm tra từng lớp, phương thức hoặc quy tắc nghiệp vụ độc lập trước khi tích hợp với Servlet, database và dịch vụ bên ngoài.'
    [void](Add-Table -Rows @(
        @('Nội dung', 'Áp dụng cho TechStore'),
        @('Đối tượng', 'ValidationUtil, VNPayUtil, ProductViewMapper và các phương thức nghiệp vụ trong Service.'),
        @('Ca tiêu biểu', 'Email/điện thoại/mật khẩu ở giá trị biên; tính tổng tiền; chuẩn hóa dữ liệu; sinh/kiểm tra chữ ký VNPay; chuyển trạng thái hợp lệ.'),
        @('Cách cô lập', 'Mock DAO, request/session và adapter dịch vụ ngoài khi cần.'),
        @('Người thực hiện', 'Developer, có Tester/Test Designer review yêu cầu và dữ liệu biên.'),
        @('Công cụ đề xuất', 'JUnit 5, Mockito và Maven Surefire. Hiện dự án chưa có src/test nên đây là hạng mục cần bổ sung.'),
        @('Điều kiện đạt', 'Các quy tắc quan trọng đều có ca dương/âm/biên; không có test thất bại trong bản build bàn giao.')
    ))

    Add-Heading '3.3. Mức 2 - Kiểm thử tích hợp (Integration Testing)' 2
    Add-BodyText 'Mục tiêu: xác nhận các lớp và hệ thống con trao đổi dữ liệu chính xác, transaction được commit/rollback đúng và tích hợp bên ngoài được xử lý an toàn.'
    [void](Add-Table -Rows @(
        @('Nhóm tích hợp', 'Điểm cần kiểm tra'),
        @('Servlet → Service → DAO → SQL Server', 'Tham số request, validation, truy vấn, mapping entity, transaction và thông báo lỗi.'),
        @('Giỏ hàng → Checkout → Order → Stock', 'Tạo snapshot đơn, tổng tiền, trừ tồn kho, xóa giỏ và rollback khi lỗi.'),
        @('Authentication → Session → Filter', 'Login/logout, timeout, CUSTOMER/ADMIN, redirect và HTTP 403.'),
        @('Password reset → SMTP → Token', 'Sinh token, thời hạn, dùng một lần, mail test và che dữ liệu nhạy cảm.'),
        @('Order → VNPay Return/IPN → Payment', 'Chữ ký, số tiền, mã giao dịch, callback lặp, retry và đối soát trạng thái.'),
        @('Admin → Catalog/Order/User', 'CRUD, upload ảnh, cập nhật trạng thái, khóa user và dữ liệu dashboard/CSV.'),
        @('Công cụ', 'integration-smoke.ps1, Postman/cURL, Browser DevTools, SSMS/sqlcmd và VNPay sandbox.'),
        @('Điều kiện đạt', 'Không sai hoặc mất dữ liệu; transaction đúng; tích hợp lỗi phải có xử lý và thông báo kiểm soát.')
    ))

    Add-Heading '3.4. Mức 3 - Kiểm thử hệ thống (System Testing)' 2
    Add-BodyText 'Mục tiêu: kiểm tra toàn bộ website đã deploy trên Tomcat như một sản phẩm hoàn chỉnh, từ giao diện đến database và các tích hợp được cấu hình cho môi trường test.'
    [void](Add-Table -Rows @(
        @('Phạm vi', 'Nội dung kiểm tra'),
        @('Luồng khách hàng', 'Trang chủ → catalog → chi tiết → yêu thích/giỏ → checkout → COD/VNPay → lịch sử/chi tiết/hủy đơn.'),
        @('Luồng tài khoản', 'Đăng ký, đăng nhập, đăng xuất, quên/đặt lại mật khẩu, hồ sơ, đổi mật khẩu và địa chỉ.'),
        @('Luồng quản trị', 'Đăng nhập ADMIN → dashboard → catalog/sản phẩm/variant/ảnh/spec → đơn hàng → user → báo cáo CSV.'),
        @('Xử lý lỗi', '403/404/500, validation, dữ liệu rỗng, mất kết nối tạm thời và link/resource.'),
        @('Phi chức năng', 'Responsive, compatibility, accessibility, usability, security cơ bản, hiệu năng local và reliability.'),
        @('Trình duyệt/kích thước', 'Chrome, Edge, Firefox; 1440, 1024, 768, 500 và 390 px.'),
        @('Điều kiện đạt', '100% P0 đạt; tối thiểu 95% P1 đạt; không còn lỗi Critical/High chưa được chấp nhận.')
    ))

    Add-Heading '3.5. Mức 4 - Kiểm thử chấp nhận (Acceptance Testing/UAT)' 2
    Add-BodyText 'Mục tiêu: xác nhận TechStore đáp ứng yêu cầu môn học và đủ khả năng bàn giao dưới góc nhìn người sử dụng/người duyệt, không chỉ dưới góc nhìn kỹ thuật.'
    [void](Add-Table -Rows @(
        @('Nội dung', 'Kế hoạch UAT'),
        @('Người thực hiện', 'Đại diện nhóm, nhóm khác/khách hàng giả định và giảng viên hoặc người được giao nghiệm thu.'),
        @('Kịch bản chính', 'Khách tìm/mua sản phẩm; thanh toán COD/VNPay sandbox; xem/hủy đơn; ADMIN quản lý sản phẩm, đơn và tài khoản.'),
        @('Dữ liệu', 'Dữ liệu gần thực tế nhưng không chứa thông tin cá nhân hoặc tài khoản production.'),
        @('Bằng chứng', 'UAT checklist, ảnh/video, defect còn lại, Test Summary Report và biên bản Sign-off.'),
        @('Điều kiện chấp nhận', 'Luồng nghiệp vụ chính đạt; không có Critical/High; giới hạn còn lại được ghi rõ và người duyệt chấp nhận.')
    ))

    Add-Heading '3.6. Ma trận áp dụng các mức kiểm thử' 2
    [void](Add-Table -Rows @(
        @('Phân hệ', 'Unit', 'Integration', 'System', 'Acceptance', 'Ưu tiên'),
        @('Xác thực và tài khoản', 'Có', 'Có', 'Có', 'Có', 'P0'),
        @('Catalog và chi tiết sản phẩm', 'Có', 'Có', 'Có', 'Có', 'P1'),
        @('Yêu thích và giỏ hàng', 'Có', 'Có', 'Có', 'Có', 'P0'),
        @('Checkout, đơn hàng và tồn kho', 'Có', 'Có', 'Có', 'Có', 'P0'),
        @('VNPay', 'Có', 'Có', 'Có', 'Có', 'P0'),
        @('Admin và báo cáo', 'Có', 'Có', 'Có', 'Có', 'P1/P0 theo quyền'),
        @('UI/UX và responsive', 'Không áp dụng chính', 'Một phần', 'Có', 'Có', 'P1'),
        @('Bảo mật và toàn vẹn dữ liệu', 'Có', 'Có', 'Có', 'Có', 'P0')
    ) -FontSize 9)

    Add-Heading '3.7. Thứ tự và tiêu chí chuyển mức' 2
    Add-NumberedItem 'Bắt đầu Unit Test khi yêu cầu của lớp/phương thức đã rõ; chỉ tích hợp khi các quy tắc trọng yếu đã đạt.'
    Add-NumberedItem 'Bắt đầu Integration Test khi module build được, database test sẵn sàng và các dependency đã cấu hình.'
    Add-NumberedItem 'Bắt đầu System Test khi ứng dụng deploy hoàn chỉnh, smoke test đạt và dữ liệu test đã được seed.'
    Add-NumberedItem 'Bắt đầu UAT khi lỗi Critical/High đã đóng, regression đạt và Test Summary sơ bộ đã có.'
    Add-BodyText 'Nếu phát hiện lỗi ở mức cao hơn, nhóm phải phân tích nguyên nhân, bổ sung testcase ở mức thấp phù hợp và chạy hồi quy các luồng liên quan.'

    Add-PageBreak
    Add-Heading '4. KẾT LUẬN VÀ ĐỀ XUẤT' 1
    Add-BodyText 'TechStore có đầy đủ đặc điểm của một hệ thống bán hàng nhiều lớp và có rủi ro nghiệp vụ đáng kể ở xác thực, phân quyền, thanh toán, đơn hàng và tồn kho. Vì vậy, kế hoạch không nên chỉ kiểm tra giao diện thủ công mà cần phối hợp bốn mức Unit, Integration, System và Acceptance.'
    Add-BodyText 'Nhóm ưu tiên hoàn thiện kiểm thử tự động ở mức Unit vì source hiện chưa có thư mục src/test; tiếp tục duy trì smoke/integration test; dùng dữ liệu test tách biệt; đối soát database cho các luồng tiền, đơn và tồn kho; lưu bằng chứng đầy đủ để phục vụ môn Kiểm thử cơ bản.'
    Add-Bullet 'Điền tên thành viên thật vào bảng phân công và xác định người review cho từng module.'
    Add-Bullet 'Liên kết mã yêu cầu với testcase và defect để tạo ma trận truy vết.'
    Add-Bullet 'Chốt version/build trước mỗi vòng test và không đưa secret vào tài liệu hoặc bằng chứng.'
    Add-Bullet 'Sau mỗi lần sửa lỗi, retest lỗi và chạy regression các luồng liên quan trước khi nghiệm thu.'

    Add-Heading 'TÀI LIỆU LIÊN QUAN' 1
    [void](Add-Table -Rows @(
        @('Tài liệu', 'Vai trò'),
        @('TEST_PLAN_TECHSTORE.docx', 'Kế hoạch kiểm thử chi tiết của dự án.'),
        @('DANH_SACH_CHUC_NANG_VA_KIEM_THU.md', 'Danh sách chức năng, phi chức năng và các điểm cần kiểm thử.'),
        @('KE_HOACH_TRIEN_KHAI.md', 'Kiến trúc, tiến độ và thông tin triển khai hệ thống.'),
        @('database/TechStore.sql', 'Cấu trúc dữ liệu và các ràng buộc cần đối soát.'),
        @('scripts/integration-smoke.ps1', 'Bộ kiểm thử tích hợp/smoke hiện có.')
    ))

    $tocSearch = $document.Content.Duplicate
    $tocSearch.Find.ClearFormatting()
    $tocSearch.Find.Text = '[[TECHSTORE_Y1_TOC]]'
    if (-not $tocSearch.Find.Execute()) {
        throw 'Không tìm thấy marker mục lục.'
    }
    $tocStart = $tocSearch.Start
    $tocSearch.Text = ''
    $tocRange = $document.Range($tocStart, $tocStart)
    [void]$document.TablesOfContents.Add($tocRange, $true, 1, 2, $false, '',
        $true, $true, '', $true, $true, $true)

    foreach ($toc in $document.TablesOfContents) { $toc.Update() }
    $document.Fields.Update() | Out-Null
    $document.Save()
    $pageCount = $document.ComputeStatistics(2)
    $tableCount = $document.Tables.Count
    $tocCount = $document.TablesOfContents.Count
    $document.Close($true)
    $document = $null
    $script:document = $null
    $word.Quit()
    $word = $null

    Write-Output "Created=$outputPath"
    Write-Output "Pages=$pageCount Tables=$tableCount TOC=$tocCount"
} finally {
    if ($document -ne $null) {
        try { $document.Close($false) } catch {}
    }
    if ($word -ne $null) {
        try { $word.Quit() } catch {}
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
