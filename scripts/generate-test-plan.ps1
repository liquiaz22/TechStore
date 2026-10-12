$ErrorActionPreference = 'Stop'

$scriptDirectory = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    Join-Path (Get-Location) 'scripts'
} else {
    $PSScriptRoot
}
$projectRoot = Split-Path -Parent $scriptDirectory
$templatePath = Join-Path $projectRoot 'Template_TestPlan_Tiếng_Việt.docx'
$outputPath = Join-Path $projectRoot 'TEST_PLAN_TECHSTORE_CAP_NHAT.docx'

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

function Add-BodyLabel {
    param([Parameter(Mandatory = $true)][string]$Text)
    $range = Add-Paragraph -Text $Text -Style 'Body Text' -SpaceAfter 6
    $range.Font.Name = 'Times New Roman'
    $range.Font.Size = 12
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

function Add-PageBreak {
    $range = Get-EndRange
    $range.InsertBreak(7)
}

function Add-Table {
    param(
        [Parameter(Mandatory = $true)][object[]]$Rows,
        [int[]]$Widths = @()
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
            $cell.Range.Font.Size = 10
            $cell.VerticalAlignment = 1
        }
    }
    $table.Rows.Item(1).Range.Bold = -1
    $table.Rows.Item(1).Range.Font.Color = 16777215
    $table.Rows.Item(1).Shading.BackgroundPatternColor = 10053222
    $table.Rows.Item(1).HeadingFormat = -1
    if ($Widths.Count -eq $columnCount) {
        for ($columnIndex = 0; $columnIndex -lt $columnCount; $columnIndex++) {
            $table.Columns.Item($columnIndex + 1).PreferredWidthType = 2
            $table.Columns.Item($columnIndex + 1).PreferredWidth = $Widths[$columnIndex]
        }
    } else {
        $table.AutoFitBehavior(2)
    }
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

    Replace-AllText 'DỰ ÁN: ABC - XYZ' 'DỰ ÁN: TECHSTORE - WEBSITE BÁN HÀNG ĐỒ CÔNG NGHỆ'
    Set-NonTocTitle -Text 'KẾ HOẠCH KIỂM THỬ' -FontSize 24
    Set-NonTocTitle -Text 'DỰ ÁN: TECHSTORE - WEBSITE BÁN HÀNG ĐỒ CÔNG NGHỆ' -FontSize 16
    Set-NonTocTitle -Text 'LỊCH SỬ SỬA ĐỔI' -FontSize 18

    $history = $document.Tables.Item(1)
    while ($history.Rows.Count -gt 2) {
        [void]$history.Rows.Item($history.Rows.Count).Delete()
    }
    $history.Cell(2, 1).Range.Text = '30/09/2026'
    $history.Cell(2, 2).Range.Text = '1.0'
    $history.Cell(2, 3).Range.Text = 'Kế hoạch kiểm thử tổng thể cho TechStore'
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
    [void](Add-Paragraph -Text '[[TECHSTORE_TOC]]' -Style 'Normal' -SpaceAfter 0)
    Add-PageBreak

    Add-Heading 'GIỚI THIỆU' 1
    Add-Heading 'Mục đích' 2
    Add-BodyText 'Tài liệu này xác định kế hoạch kiểm thử tổng thể cho website TechStore. Kế hoạch mô tả phạm vi, tài nguyên, lịch trình, môi trường, chiến lược, tiêu chí vào/ra, cách quản lý lỗi, rủi ro và các tài liệu cần bàn giao.'
    Add-BodyText 'Mục tiêu chính là xác nhận các luồng mua hàng và quản trị hoạt động đúng; dữ liệu đơn hàng, thanh toán và tồn kho giữ được tính toàn vẹn; người dùng không truy cập được dữ liệu ngoài quyền; giao diện sử dụng tốt trên các thiết bị và trình duyệt mục tiêu.'

    Add-Heading 'Tổng quan' 2
    Add-BodyText 'TechStore là website bán điện thoại, máy tính bảng/iPad, laptop và phụ kiện. Hệ thống sử dụng Java 21, Jakarta Servlet/JSP theo kiến trúc MVC, Hibernate/JPA, SQL Server, Tomcat 10.1, HTML/CSS/JavaScript và tích hợp VNPay sandbox.'
    Add-BodyText 'Hệ thống có hai nhóm giao diện tách biệt: storefront dành cho khách hàng và khu vực quản trị dành cho ADMIN. Dữ liệu nhạy cảm được cấu hình qua biến môi trường; các thao tác thay đổi dữ liệu sử dụng CSRF token.'

    Add-Heading 'Phạm vi' 2
    Add-BodyText 'Test Plan áp dụng cho phiên bản source code TechStore được rà soát ngày 30/09/2026 và triển khai tại context /TechStore. Phạm vi bao gồm kiểm thử chức năng, tích hợp, hệ thống, bảo mật cơ bản, toàn vẹn dữ liệu, tương thích, responsive, accessibility và kiểm thử hồi quy.'
    Add-Bullet 'Trang chủ, danh sách/tìm kiếm/lọc/sắp xếp/phân trang sản phẩm và chi tiết sản phẩm.'
    Add-Bullet 'Đăng ký, đăng nhập, đăng xuất, hồ sơ, đổi/quên/đặt lại mật khẩu và quản lý địa chỉ.'
    Add-Bullet 'Yêu thích, giỏ hàng, checkout, COD, VNPay, lịch sử/chi tiết/hủy đơn.'
    Add-Bullet 'Admin dashboard, báo cáo CSV, catalog, sản phẩm, phiên bản, ảnh, thông số, đơn hàng và người dùng.'
    Add-Bullet 'Phân quyền, CSRF, quyền sở hữu dữ liệu, validation, transaction, tồn kho và callback thanh toán.'

    Add-Heading 'Tài liệu tham chiếu' 2
    [void](Add-Table -Rows @(
        @('Tài liệu', 'Mục đích'),
        @('DANH_SACH_CHUC_NANG_VA_KIEM_THU.md', 'Danh mục 188 điểm kiểm thử và kết quả mong đợi'),
        @('KE_HOACH_TRIEN_KHAI.md', 'Kiến trúc, tiến độ và kết quả smoke test hiện có'),
        @('LO_TRINH_NANG_CAP.md', 'Phạm vi nâng cấp nghiệp vụ và các phần chưa triển khai'),
        @('LO_TRINH_CAI_TIEN_UI_UX.md', 'Yêu cầu và trạng thái cải tiến giao diện'),
        @('database/TechStore.sql và upgrade scripts', 'Schema, constraint, index và dữ liệu nền'),
        @('scripts/integration-smoke.ps1', 'Bộ kiểm thử tích hợp tự động hiện có')
    ))

    Add-Heading 'Các định nghĩa và các từ viết tắt được dùng' 2
    [void](Add-BodyLabel -Text 'Các định nghĩa')
    [void](Add-Table -Rows @(
        @('Thuật ngữ', 'Định nghĩa'),
        @('Storefront', 'Khu vực mua hàng dành cho khách hàng.'),
        @('Admin', 'Khu vực quản trị chỉ dành cho tài khoản có vai trò ADMIN.'),
        @('Variant/SKU', 'Phiên bản bán cụ thể của sản phẩm, có giá và tồn kho riêng.'),
        @('Checkout', 'Quá trình xác nhận địa chỉ, phương thức thanh toán và tạo đơn.'),
        @('Snapshot đơn hàng', 'Tên, SKU, ảnh và giá được lưu tại thời điểm đặt hàng.'),
        @('Callback', 'Phản hồi Return URL hoặc IPN từ VNPay.'),
        @('Idempotent', 'Xử lý lặp cùng một yêu cầu mà không tạo tác động trùng.'),
        @('Regression test', 'Kiểm thử lại để xác nhận thay đổi mới không phá chức năng cũ.')
    ))
    [void](Add-BodyLabel -Text 'Các từ viết tắt')
    [void](Add-Table -Rows @(
        @('Từ viết tắt', 'Mô tả'),
        @('MVC', 'Model - View - Controller'),
        @('JSP/JSTL', 'JavaServer Pages / Jakarta Standard Tag Library'),
        @('DB', 'Database - cơ sở dữ liệu SQL Server'),
        @('CSRF', 'Cross-Site Request Forgery'),
        @('XSS', 'Cross-Site Scripting'),
        @('IDOR', 'Insecure Direct Object Reference'),
        @('IPN', 'Instant Payment Notification của VNPay'),
        @('UAT', 'User Acceptance Testing'),
        @('P0/P1/P2', 'Độ ưu tiên kiểm thử: sống còn / chính / bổ sung')
    ))

    Add-Heading 'Những người sử dụng tài liệu này' 2
    Add-BodyText 'Tài liệu được sử dụng bởi Test Manager, Test Designer, Tester, Developer, trưởng nhóm dự án, giảng viên hướng dẫn và các thành viên tham gia nghiệm thu.'

    Add-PageBreak
    Add-Heading 'LỊCH TRÌNH CÔNG VIỆC' 1
    Add-BodyText 'Lịch dưới đây là lịch đề xuất theo ngày làm việc và có thể điều chỉnh theo lịch của nhóm. Mọi thay đổi phải được ghi vào lịch sử tài liệu.'
    [void](Add-Table -Rows @(
        @('Milestone', 'Deliverables', 'Duration', 'Start Date', 'End Date'),
        @('Lập và duyệt Test Plan', 'Test Plan v1.0', '2 ngày', '30/09/2026', '01/10/2026'),
        @('Chuẩn bị môi trường và dữ liệu', 'Biên bản môi trường, dữ liệu test', '1 ngày', '02/10/2026', '02/10/2026'),
        @('Thiết kế và review Test Case', 'Test Case/Checklist đã duyệt', '2 ngày', '05/10/2026', '06/10/2026'),
        @('Thực thi vòng 1', 'Kết quả test và defect log', '3 ngày', '07/10/2026', '09/10/2026'),
        @('Sửa lỗi và regression', 'Regression result', '2 ngày', '12/10/2026', '13/10/2026'),
        @('Tổng kết và nghiệm thu', 'Test Summary Report', '1 ngày', '14/10/2026', '14/10/2026')
    ))

    Add-Heading 'Biểu đồ Gantt' 2
    [void](Add-Table -Rows @(
        @('Công việc', '30/09-02/10', '05-09/10', '12-14/10'),
        @('Lập kế hoạch', '■■■', '', ''),
        @('Chuẩn bị môi trường/dữ liệu', '■■', '', ''),
        @('Thiết kế và review testcase', '', '■■', ''),
        @('Thực thi vòng 1', '', '■■■', ''),
        @('Sửa lỗi và regression', '', '', '■■'),
        @('Báo cáo tổng kết', '', '', '■')
    ))

    Add-PageBreak
    Add-Heading 'NHỮNG YÊU CẦU VỀ TÀI NGUYÊN' 1
    Add-Heading 'Phần cứng' 2
    [void](Add-Table -Rows @(
        @('Thành phần', 'Cấu hình tối thiểu đề xuất'),
        @('CPU', 'Intel Core i5 hoặc tương đương, 4 nhân'),
        @('RAM', '8 GB; khuyến nghị 16 GB khi chạy Eclipse, Tomcat và SQL Server cùng lúc'),
        @('Ổ đĩa', 'Tối thiểu 10 GB trống cho source, database, log và file upload'),
        @('Kiến trúc', '64-bit'),
        @('Mạng', 'Internet ổn định để tải font, ảnh CDN, gửi mail và dùng VNPay sandbox')
    ))

    Add-Heading 'Phần mềm' 2
    [void](Add-Table -Rows @(
        @('Tên phần mềm', 'Phiên bản', 'Mục đích'),
        @('Windows', '10/11 64-bit', 'Hệ điều hành kiểm thử'),
        @('OpenJDK', '21', 'Biên dịch và chạy ứng dụng'),
        @('Apache Tomcat', '10.1.57 hoặc 10.1.x', 'Servlet container'),
        @('Microsoft SQL Server', '2019/2022 hoặc tương thích', 'Cơ sở dữ liệu'),
        @('Maven', '3.9.x', 'Build WAR và quản lý dependency'),
        @('Eclipse IDE for Enterprise Java', '2026-06 hoặc tương thích', 'Phát triển và deploy local'),
        @('Google Chrome', 'Bản ổn định hiện hành', 'Trình duyệt chính'),
        @('Microsoft Edge', 'Bản ổn định hiện hành', 'Kiểm thử tương thích'),
        @('Mozilla Firefox', 'Bản ổn định hiện hành', 'Kiểm thử tương thích'),
        @('Microsoft Word', '2019/2021/365', 'Đọc và cập nhật tài liệu')
    ))

    Add-Heading 'Công cụ kiểm thử' 2
    [void](Add-Table -Rows @(
        @('Hoạt động', 'Công cụ', 'Mục đích'),
        @('Quản lý Test Case', 'Markdown + Excel/Google Sheets', 'Theo dõi testcase, kết quả và bằng chứng'),
        @('Smoke/Integration', 'scripts/integration-smoke.ps1', 'Chạy kiểm thử tích hợp tự động và dọn dữ liệu test'),
        @('HTTP/Security', 'Browser DevTools, PowerShell Invoke-WebRequest, Postman hoặc curl', 'Kiểm tra request, response, cookie, header, CSRF và callback'),
        @('Database', 'SQL Server Management Studio và sqlcmd', 'Chuẩn bị/đối soát dữ liệu và transaction'),
        @('UI/Accessibility', 'Chrome DevTools, Lighthouse, axe DevTools', 'Responsive, keyboard, contrast và accessibility'),
        @('Performance', 'JMeter hoặc k6 (nếu có)', 'Kiểm thử tải và tranh chấp tồn kho'),
        @('Defect Tracking', 'Excel/Google Sheets hoặc công cụ nhóm chọn', 'Ghi nhận, phân công và theo dõi lỗi'),
        @('Build', 'Maven, javac và Jasper JspC', 'Xác nhận Java/JSP compile')
    ))

    Add-Heading 'Môi trường kiểm thử' 2
    [void](Add-Table -Rows @(
        @('Thành phần', 'Cấu hình'),
        @('Base URL local', 'http://localhost:8080/TechStore'),
        @('Application server', 'Tomcat 10.1.x, context /TechStore'),
        @('Database', 'SQL Server database TechStore dành riêng cho test'),
        @('Payment', 'VNPay sandbox, không sử dụng tài khoản/tiền production'),
        @('Email', 'Tài khoản test hoặc mailbox riêng cho reset password'),
        @('Dữ liệu sản phẩm', '40 sản phẩm demo và dữ liệu biên bổ sung'),
        @('Cấu hình bí mật', 'Biến môi trường của tiến trình Tomcat; không ghi secret vào tài liệu/log')
    ))
    Add-BodyText 'Dữ liệu kiểm thử phải có ít nhất hai CUSTOMER, một CUSTOMER bị khóa, hai ADMIN, sản phẩm nhiều phiên bản, SKU còn 1 sản phẩm, SKU hết hàng, sản phẩm ẩn và các đơn COD/VNPay ở nhiều trạng thái.'

    Add-Heading 'Nhân sự' 2
    [void](Add-Table -Rows @(
        @('Thành viên/Vai trò', 'Trách nhiệm'),
        @('[Điền tên] - Test Manager', 'Duyệt kế hoạch, phân công, theo dõi tiến độ, quyết định tạm dừng/kết thúc.'),
        @('[Điền tên] - Test Designer', 'Phân tích yêu cầu, thiết kế/review testcase và dữ liệu test.'),
        @('[Điền tên] - Tester 1', 'Tài khoản, storefront, sản phẩm, yêu thích và giỏ hàng.'),
        @('[Điền tên] - Tester 2', 'Checkout, đơn hàng, VNPay và kiểm tra database.'),
        @('[Điền tên] - Tester 3', 'Admin, báo cáo, bảo mật, responsive và accessibility.'),
        @('[Điền tên] - Developer', 'Phân tích/sửa lỗi, hỗ trợ log và build bản regression.'),
        @('[Điền tên] - Người duyệt', 'Nghiệm thu Test Plan và Test Summary Report.')
    ))

    Add-PageBreak
    Add-Heading 'PHẠM VI KIỂM THỬ' 1
    Add-Heading 'Những chức năng được kiểm thử' 2
    [void](Add-Table -Rows @(
        @('Mã nhóm', 'Phân hệ', 'Nội dung chính', 'Ưu tiên'),
        @('SYS', 'Hệ thống', 'Trang chủ, health, routing, trang lỗi và tài nguyên tĩnh', 'P1'),
        @('AUTH/RESET', 'Xác thực', 'Đăng ký, login/logout, session, khóa tài khoản và reset password', 'P0'),
        @('CAT', 'Sản phẩm', 'Tìm kiếm, lọc, sort, phân trang, chi tiết và phiên bản', 'P1'),
        @('FAV/CART', 'Yêu thích/Giỏ', 'Toggle yêu thích, gộp SKU, số lượng, tồn kho và tổng tiền', 'P0'),
        @('ACC/ADDR', 'Tài khoản', 'Hồ sơ, đổi mật khẩu và quyền sở hữu địa chỉ', 'P0'),
        @('CHK/ORD', 'Mua hàng', 'Checkout, COD, chống submit trùng, đơn, hủy và hoàn kho', 'P0'),
        @('PAY', 'VNPay', 'Start, Return, IPN, chữ ký, đối soát, idempotency và retry', 'P0'),
        @('RPT', 'Dashboard/Báo cáo', 'KPI, biểu đồ, khoảng ngày và CSV', 'P1'),
        @('ACAT/APROD', 'Admin catalog', 'Danh mục, hãng, sản phẩm, variant, ảnh và thông số', 'P1'),
        @('AORD/AUSR', 'Admin vận hành', 'Xử lý đơn, timeline, khóa/mở user và phân quyền', 'P0'),
        @('SEC/DB', 'Bảo mật/Dữ liệu', 'CSRF, IDOR, XSS, SQLi, transaction, rollback và concurrency', 'P0'),
        @('UI/PERF/OPS', 'Phi chức năng', 'Responsive, accessibility, tải cơ bản và deploy sạch', 'P1')
    ))

    Add-Heading 'Chi tiết phạm vi chức năng' 2
    Add-Bullet 'Khách chưa đăng nhập: duyệt catalog, tìm kiếm/lọc, xem chi tiết, đăng ký, đăng nhập và quên mật khẩu.'
    Add-Bullet 'Khách đã đăng nhập: hồ sơ, địa chỉ, yêu thích, giỏ hàng, checkout, COD/VNPay, lịch sử/chi tiết/hủy đơn.'
    Add-Bullet 'Admin: dashboard, CSV, catalog, sản phẩm/variant/ảnh/spec, đơn hàng, người dùng và quay lại storefront.'
    Add-Bullet 'Tích hợp: SQL Server, SMTP cho reset password, VNPay sandbox Return/IPN và file system upload.'

    Add-Heading 'Những chức năng không được kiểm thử' 2
    Add-BodyText 'Các chức năng sau chưa được triển khai hoặc nằm ngoài phạm vi phiên bản hiện tại nên không được đánh giá là chức năng phải Pass:'
    Add-Bullet 'Mã giảm giá, chương trình khuyến mãi và coupon.'
    Add-Bullet 'Đánh giá/bình luận sản phẩm, quản lý banner và audit log.'
    Add-Bullet 'Đổi trả, hoàn tiền tự động và quy trình duyệt yêu cầu đổi trả.'
    Add-Bullet 'Email xác nhận đơn hàng/trạng thái và trang in hóa đơn.'
    Add-Bullet 'Tính sẵn sàng thực tế của ngân hàng/VNPay production và mạng Internet bên thứ ba.'
    Add-Bullet 'Penetration test chuyên nghiệp, tải production quy mô lớn và kiểm thử thảm họa datacenter.'

    Add-Heading 'Những yêu cầu phi chức năng' 2
    Add-Bullet 'Tương thích Chrome, Edge, Firefox và các kích thước 1440, 1024, 768, 500, 390 px.'
    Add-Bullet 'Không tràn ngang, link chết, font lỗi hoặc mất thao tác chính; UTF-8 đúng trên UI/database/CSV.'
    Add-Bullet 'Có focus rõ, dùng được bằng bàn phím, skip link, alt/aria-label, reduced motion và tương phản phù hợp.'
    Add-Bullet 'Session timeout 30 phút; CSRF, phân quyền, quyền sở hữu dữ liệu và security headers hoạt động.'
    Add-Bullet 'Không lộ password, token, secret, connection string hoặc stack trace nhạy cảm.'
    Add-Bullet 'Không có stock âm, tổng tiền sai, đơn rỗng, callback trùng hoặc hoàn kho nhiều lần.'
    Add-Bullet 'Mục tiêu local tham khảo: phần lớn request trang chính dưới 2 giây sau warm-up và không 5xx ở tải duyệt catalog 20 user.'

    Add-Heading 'Ma trận vai trò và quyền truy cập' 2
    [void](Add-Table -Rows @(
        @('Khu vực', 'Guest', 'CUSTOMER', 'ADMIN'),
        @('Home/catalog/product', 'Cho phép', 'Cho phép', 'Cho phép'),
        @('Login/register/reset', 'Cho phép', 'Tự chuyển nếu đã login', 'Tự chuyển /admin nếu đã login'),
        @('Favorites/cart/checkout/orders/account', 'Chuyển login', 'Dữ liệu của mình', 'Cho phép theo luồng ứng dụng'),
        @('VNPay start', 'Chuyển login', 'Chỉ đơn của mình', 'Chỉ đơn hợp lệ theo chủ sở hữu'),
        @('VNPay Return/IPN', 'Công khai, bắt buộc chữ ký', 'Công khai, bắt buộc chữ ký', 'Công khai, bắt buộc chữ ký'),
        @('/admin và /admin/*', 'Chuyển login', 'HTTP 403', 'Cho phép')
    ))

    Add-PageBreak
    Add-Heading 'CHIẾN LƯỢC KIỂM THỬ' 1
    Add-Heading 'Các giai đoạn kiểm thử' 2
    [void](Add-Table -Rows @(
        @('Giai đoạn', 'Hoạt động', 'Điều kiện hoàn thành'),
        @('1. Review tĩnh', 'Rà yêu cầu, Servlet/Filter/Service/JSP, schema và cấu hình', 'Phạm vi và rủi ro được chốt'),
        @('2. Build/Smoke', 'Build WAR, compile JSP, health và các URL chính', 'Không lỗi build; smoke P0 đạt'),
        @('3. Integration', 'Servlet-Service-DAO-DB, mail, file upload, VNPay sandbox', 'Tích hợp chính hoạt động, không dữ liệu rác'),
        @('4. System test', 'Thực thi checklist chức năng và phi chức năng', 'Toàn bộ testcase được chạy/ghi nhận'),
        @('5. Security/Data', 'CSRF, IDOR, XSS/SQLi, transaction, concurrency', 'Không còn lỗi Critical/High'),
        @('6. Regression', 'Chạy lại lỗi đã sửa và luồng liên quan', 'Không tái phát, smoke đạt'),
        @('7. UAT/Closure', 'Nghiệm thu và Test Summary Report', 'Đạt điều kiện chấp nhận')
    ))

    Add-Heading 'Kỹ thuật thiết kế kiểm thử' 2
    Add-Bullet 'Phân vùng tương đương: dữ liệu hợp lệ/không hợp lệ cho email, điện thoại, trạng thái, URL và file.'
    Add-Bullet 'Giá trị biên: mật khẩu 7/8/72/73, độ dài 150/151, ghi chú 500/501, file 5 MB và số lượng sát tồn kho.'
    Add-Bullet 'Bảng quyết định: quyền Guest/Customer/Admin, trạng thái đơn, payment status và khả năng hủy/thanh toán lại.'
    Add-Bullet 'Chuyển trạng thái: PENDING → CONFIRMED → PROCESSING → SHIPPING → COMPLETED hoặc CANCELLED theo luồng cho phép.'
    Add-Bullet 'Use-case/end-to-end: đăng ký → giỏ → checkout → đơn → admin xử lý → hoàn thành.'
    Add-Bullet 'Error guessing và negative testing: sửa request, IDOR, callback lặp, token sai, MIME giả và tham số cực trị.'
    Add-Bullet 'Concurrency testing: hai checkout SKU cuối, hai hủy đơn và callback song song.'

    Add-Heading 'Kiểm thử chức năng' 2
    [void](Add-Table -Rows @(
        @('Nội dung', 'Kế hoạch'),
        @('Mục đích', 'Xác nhận các chức năng hoạt động đúng yêu cầu và dữ liệu lưu chính xác.'),
        @('Kỹ thuật', 'Black-box, equivalence partitioning, boundary value, decision table, state transition, use-case và negative test.'),
        @('Dữ liệu', 'Dữ liệu hợp lệ, không hợp lệ, rỗng, biên, trùng, không thuộc quyền và thay đổi đồng thời.'),
        @('Cách thực hiện', 'Thủ công theo checklist kết hợp integration-smoke.ps1 và truy vấn SQL đối soát.'),
        @('Tiêu chuẩn dừng', '100% testcase P0/P1 đã thực thi; không còn lỗi Critical/High chưa có quyết định.'),
        @('Phụ trách', 'Test Designer/Tester theo bảng phân công.'),
        @('Xử lý ngoại lệ', 'Ghi defect kèm request, dữ liệu, log, ảnh và trạng thái database trước/sau.')
    ))

    Add-Heading 'Kiểm thử phi chức năng' 2
    [void](Add-Table -Rows @(
        @('Loại', 'Mục đích và cách thực hiện', 'Tiêu chuẩn đề xuất'),
        @('Compatibility', 'Chạy luồng chính trên Chrome, Edge và Firefox.', 'Không khác biệt làm mất chức năng.'),
        @('Responsive', 'Kiểm tra 1440/1024/768/500/390 px.', 'Không tràn ngang, che nội dung hay mất CTA.'),
        @('Accessibility', 'Keyboard, screen reader, zoom 200%, contrast, reduced motion.', 'Không có blocker bàn phím; lỗi nghiêm trọng được sửa.'),
        @('Security', 'CSRF, quyền, IDOR, XSS/SQLi, cookie, header và secret.', 'Không còn Critical/High.'),
        @('Performance', 'Đo response sau warm-up; duyệt catalog 20 user; checkout cạnh tranh.', 'Phần lớn trang chính <2 giây local; không 5xx/stock âm.'),
        @('Reliability', 'Restart, mất DB tạm thời, rollback, callback lặp và deploy sạch.', 'Không hỏng dữ liệu; hệ thống phục hồi có kiểm soát.'),
        @('Usability', 'Quan sát luồng mua hàng/admin, thông báo lỗi, empty/loading/disabled.', 'Người dùng biết trạng thái và hành động tiếp theo.')
    ))

    Add-Heading 'Kiểm thử hồi quy và tự động hóa' 2
    Add-BodyText 'Sau mỗi bản sửa lỗi, chạy lại testcase lỗi, các testcase cùng module và bộ smoke tự động. Trước khi chốt phiên bản phải chạy toàn bộ P0, build WAR, compile JSP và scripts/integration-smoke.ps1 trên database test sạch.'
    Add-BodyText 'Những phần ưu tiên bổ sung tự động hóa: hồ sơ/địa chỉ/reset password, VNPay callback/idempotency, CRUD sản phẩm/variant/ảnh/spec, trạng thái đơn admin, CSV và các ca concurrency.'

    Add-Heading 'Điều kiện bắt đầu kiểm thử' 2
    Add-Bullet 'Source/version cần test đã được chốt và build thành công.'
    Add-Bullet 'Tomcat, SQL Server, database test, biến môi trường và dữ liệu mẫu sẵn sàng.'
    Add-Bullet 'Có tài khoản Guest/Customer/Locked/Admin và quyền truy cập log/database cần thiết.'
    Add-Bullet 'Test Plan, checklist/testcase và phạm vi đã được nhóm duyệt.'
    Add-Bullet 'VNPay sandbox và mail test được cấu hình cho các ca tích hợp tương ứng.'

    Add-Heading 'Điều kiện tạm dừng và tiếp tục' 2
    Add-Bullet 'Tạm dừng khi build/deploy thất bại, database không ổn định, không đăng nhập được mọi vai trò hoặc dữ liệu test bị hỏng.'
    Add-Bullet 'Tạm dừng module thanh toán nếu phát hiện sai số tiền, callback làm ghi nhận trùng hoặc môi trường dùng nhầm production.'
    Add-Bullet 'Tạm dừng checkout concurrency nếu không có backup/khả năng dọn dữ liệu test.'
    Add-Bullet 'Tiếp tục sau khi blocker được sửa, môi trường được xác nhận và smoke test của module đạt.'

    Add-PageBreak
    Add-Heading 'ĐIỀU KIỆN CHẤP NHẬN' 1
    Add-Bullet '100% testcase P0 đạt.'
    Add-Bullet 'Ít nhất 95% testcase P1 đạt; testcase còn lại có quyết định chấp nhận rủi ro hoặc kế hoạch sửa rõ ràng.'
    Add-Bullet 'Không còn lỗi Critical/High mở liên quan tiền, tồn kho, đơn hàng, xác thực, phân quyền, CSRF, IDOR hoặc lộ secret.'
    Add-Bullet 'Không có stock âm, đơn rỗng, tổng tiền sai, hoàn kho nhiều lần hoặc mã giao dịch VNPay trùng.'
    Add-Bullet 'Build WAR, JSP compile, smoke test và deploy trên Tomcat sạch đều đạt.'
    Add-Bullet 'Các luồng chính đạt trên Chrome, Edge, Firefox và màn hình mobile/desktop mục tiêu.'
    Add-Bullet 'Test Summary Report, defect log và bằng chứng kiểm thử đã được cập nhật và người duyệt chấp nhận.'

    Add-Heading 'QUẢN LÝ LỖI' 1
    Add-Heading 'Phân loại lỗi' 2
    [void](Add-Table -Rows @(
        @('Mức độ', 'Định nghĩa', 'Ví dụ TechStore', 'Thời gian phản hồi đề xuất'),
        @('Critical', 'Mất tiền/dữ liệu, vượt quyền nghiêm trọng, hệ thống không dùng được.', 'Sai tổng tiền; stock âm; callback ghi nhận trùng; customer vào admin; lộ secret.', 'Ngay lập tức, dừng phát hành'),
        @('High', 'Chức năng chính không dùng được và không có cách vòng hợp lý.', 'Không login/checkout/đặt đơn; không trừ hoặc hoàn kho; CSRF/IDOR.', 'Trong ngày'),
        @('Medium', 'Một phần chức năng sai nhưng có cách vòng; tác động giới hạn.', 'Filter sai; validation thiếu; CSV lỗi dấu; một trình duyệt lỗi layout đáng kể.', '1-2 ngày làm việc'),
        @('Low', 'Lỗi hiển thị hoặc trải nghiệm nhỏ, không làm sai nghiệp vụ.', 'Căn lề, wording, khoảng cách, icon hoặc trạng thái hover chưa nhất quán.', 'Theo sprint/kế hoạch nhóm')
    ))

    Add-Heading 'Thông tin bắt buộc của defect' 2
    Add-Bullet 'Defect ID, tiêu đề ngắn, module, severity, priority và người phát hiện.'
    Add-Bullet 'Phiên bản build, môi trường, trình duyệt, tài khoản/vai trò và dữ liệu test.'
    Add-Bullet 'Điều kiện trước, bước tái hiện, kết quả mong đợi và kết quả thực tế.'
    Add-Bullet 'Ảnh/video, request/response, log liên quan và truy vấn/bản ghi database trước-sau.'
    Add-Bullet 'Người xử lý, trạng thái, nguyên nhân gốc, bản sửa và testcase regression.'

    Add-Heading 'Quy trình xử lý lỗi' 2
    Add-BodyText 'New → Triaged → Assigned → In Progress → Fixed → Ready for Retest → Verified → Closed. Nếu lỗi vẫn còn thì Reopened; nếu không sửa trong phiên bản này phải chuyển Deferred/Accepted Risk kèm người phê duyệt và lý do.'
    Add-BodyText 'Lỗi Critical/High phải được thông báo ngay cho Test Manager và Developer. Khi lỗi liên quan dữ liệu hoặc thanh toán, giữ lại bản sao log và dữ liệu test trước khi dọn.'

    Add-Heading 'RỦI RO VÀ GIẢM THIỂU' 1
    [void](Add-Table -Rows @(
        @('Rủi ro', 'Khả năng/Tác động', 'Biện pháp'),
        @('VNPay/mail sandbox không ổn định', 'Trung bình/Cao', 'Tách ca cấu hình, lưu request/response, dùng dữ liệu sandbox và chạy lại khi dịch vụ ổn định.'),
        @('Hai checkout tranh chấp SKU cuối', 'Trung bình/Rất cao', 'Test concurrency, đối soát stock và transaction, không dùng dữ liệu thật.'),
        @('Ảnh upload mất khi redeploy', 'Cao/Trung bình', 'Backup upload, test deploy sạch, ghi risk và chuyển storage ra ngoài webapp trước production.'),
        @('Admin products/users chậm với dữ liệu lớn', 'Trung bình/Trung bình', 'Seed dữ liệu lớn, đo PERF-04, chuyển filtering/paging xuống DB nếu vượt ngưỡng.'),
        @('Thiếu thành viên hoặc thời gian', 'Trung bình/Trung bình', 'Ưu tiên P0 rồi P1, chia module rõ, dùng smoke script và review chéo.'),
        @('Dữ liệu test ảnh hưởng lẫn nhau', 'Trung bình/Cao', 'Tên dữ liệu có run ID, backup trước test, cleanup sau test, không dùng production.'),
        @('Secret xuất hiện trong log/tài liệu', 'Thấp/Rất cao', 'Chỉ dùng tên biến môi trường, che giá trị trong ảnh/log và review trước khi nộp.')
    ))

    Add-Heading 'TÀI LIỆU ĐẦU RA' 1
    [void](Add-Table -Rows @(
        @('Tài liệu', 'Nội dung', 'Người chịu trách nhiệm'),
        @('Test Plan', 'Phạm vi, lịch trình, chiến lược, nguồn lực, tiêu chí và rủi ro.', 'Test Manager'),
        @('Test Case/Checklist', '188 điểm kiểm thử, dữ liệu, bước và kết quả mong đợi.', 'Test Designer'),
        @('Test Data', 'Tài khoản, sản phẩm, đơn, payment và script seed/cleanup.', 'Tester/Developer'),
        @('Test Execution Result', 'Pass/Fail/Blocked, thời gian và bằng chứng.', 'Tester'),
        @('Defect Log', 'Danh sách lỗi, severity, owner, trạng thái và regression.', 'Tester/Test Manager'),
        @('Automation Result', 'Kết quả build, JSP compile và integration-smoke.', 'Tester/Developer'),
        @('Test Summary Report', 'Tỷ lệ đạt, lỗi còn lại, rủi ro và đề xuất phát hành.', 'Test Manager'),
        @('Sign-off', 'Xác nhận nghiệm thu hoặc chấp nhận rủi ro.', 'Người duyệt')
    ))

    Add-Heading 'PHỤ LỤC: LỆNH VÀ ĐIỂM KIỂM TRA NHANH' 1
    Add-BodyText 'Build ứng dụng:'
    Add-BodyText 'mvn clean package'
    Add-BodyText 'Chạy kiểm thử tích hợp khi Tomcat và SQL Server đang hoạt động:'
    Add-BodyText './scripts/integration-smoke.ps1'
    Add-BodyText 'Các truy vấn SQL đối soát và toàn bộ testcase chi tiết nằm trong DANH_SACH_CHUC_NANG_VA_KIEM_THU.md. Không đưa mật khẩu database, mail hoặc VNPay secret vào tài liệu kết quả.'

    $tocSearch = $document.Content.Duplicate
    $tocSearch.Find.ClearFormatting()
    $tocSearch.Find.Text = '[[TECHSTORE_TOC]]'
    if (-not $tocSearch.Find.Execute()) {
        throw 'Không tìm thấy marker mục lục.'
    }
    $tocStart = $tocSearch.Start
    $tocSearch.Text = ''
    $tocRange = $document.Range($tocStart, $tocStart)
    $missing = [Type]::Missing
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
