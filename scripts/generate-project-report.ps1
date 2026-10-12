$ErrorActionPreference = 'Stop'

$scriptDirectory = if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    Join-Path (Get-Location) 'scripts'
} else {
    $PSScriptRoot
}
$projectRoot = Split-Path -Parent $scriptDirectory
$templatePath = Join-Path $projectRoot 'template_document.docx'
$outputPath = Join-Path $projectRoot 'BAO_CAO_DU_AN_TECHSTORE.docx'

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
        [string]$Style = 'Body Text',
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
    $style = if ($Level -le 1) { 'Heading 1' } elseif ($Level -eq 2) { 'Heading 2' } else { 'Heading 3' }
    $range = Add-Paragraph -Text $Text -Style $style -SpaceAfter 8
    $range.ParagraphFormat.KeepWithNext = -1
}

function Add-DisplayHeading {
    param([string]$Text, [int]$FontSize = 18)
    $range = Add-Paragraph -Text $Text -Style 'Normal' -SpaceAfter 10
    $range.Font.Name = 'Times New Roman'
    $range.Font.Size = $FontSize
    $range.Font.Bold = -1
    $range.ParagraphFormat.Alignment = 1
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
    $range.ParagraphFormat.OutlineLevel = 10
}

function Add-NumberedItem {
    param([string]$Text)
    $range = Add-Paragraph -Text $Text -Style 'Normal' -SpaceAfter 3
    $range.ListFormat.ApplyNumberDefault()
    $range.ParagraphFormat.OutlineLevel = 10
}

function Add-PageBreak {
    $range = Get-EndRange
    $range.InsertBreak(7)
}

function Add-Caption {
    param([string]$Text)
    $range = Add-Paragraph -Text $Text -Style 'Body Text' -SpaceAfter 4
    $range.Font.Bold = -1
    $range.Font.Italic = -1
    $range.ParagraphFormat.Alignment = 1
    $range.ParagraphFormat.OutlineLevel = 10
}

function Add-Table {
    param(
        [Parameter(Mandatory = $true)][object[]]$Rows,
        [int]$FontSize = 9
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

function Add-UseCase {
    param(
        [string]$Code,
        [string]$Name,
        [string]$Actor,
        [string]$Precondition,
        [string]$MainFlow,
        [string]$Alternative,
        [string]$Postcondition
    )
    Add-Heading "$Code - $Name" 3
    [void](Add-Table -Rows @(
        @('Thuộc tính', 'Nội dung'),
        @('Tác nhân', $Actor),
        @('Mục tiêu', $Name),
        @('Điều kiện trước', $Precondition),
        @('Luồng chính', $MainFlow),
        @('Luồng thay thế/ngoại lệ', $Alternative),
        @('Điều kiện sau', $Postcondition)
    ) -FontSize 9)
}

function Replace-AllText {
    param([string]$FindText, [string]$ReplacementText)
    foreach ($story in $script:document.StoryRanges) {
        $range = $story
        while ($range -ne $null) {
            $find = $range.Find
            $find.ClearFormatting()
            $find.Replacement.ClearFormatting()
            $find.Text = $FindText
            $find.Replacement.Text = $ReplacementText
            [void]$find.Execute($FindText, $false, $false, $false, $false, $false,
                $true, 1, $false, $ReplacementText, 2)
            $range = $range.NextStoryRange
        }
    }
}

function Set-NonTocTitle {
    param([string]$Text, [int]$FontSize = 18, [int]$Alignment = 1)
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

    Replace-AllText 'BÁO CÁO DỰ ÁN TỐT NGHIỆP' 'BÁO CÁO DỰ ÁN'
    Replace-AllText 'XÂY DỰNG WEBSITE BÁN HÀNG ĐỒ ĐIỆN TỬ' 'XÂY DỰNG WEBSITE TECHSTORE BÁN HÀNG ĐỒ CÔNG NGHỆ'
    Replace-AllText 'TPHCM – 2025' 'TPHCM – 2026'
    Replace-AllText 'Thạc sĩ Huỳnh Khắc Duy' '[Điền tên giảng viên]'
    Replace-AllText 'Nhóm 477' '[Điền tên nhóm]'
    Replace-AllText 'PS39471: Nguyễn Quang Hậu' '[Điền MSSV 1]: [Điền họ tên 1]'
    Replace-AllText 'PS39510: Nguyễn Lê Cường Thịnh' '[Điền MSSV 2]: [Điền họ tên 2]'
    Replace-AllText 'PS39546: Nguyễn Ngọc Đăng Khoa' '[Điền MSSV 3]: [Điền họ tên 3]'
    Replace-AllText 'PS41034: Dư Thành Đạt' '[Điền MSSV 4]: [Điền họ tên 4]'
    Replace-AllText 'PS41058: Nguyễn Minh Tuấn' '[Điền MSSV 5]: [Điền họ tên 5]'
    Set-NonTocTitle -Text 'TRƯỜNG CAO ĐẲNG FPT POLYTECHNIC' -FontSize 16
    Set-NonTocTitle -Text 'BÁO CÁO DỰ ÁN' -FontSize 22
    Set-NonTocTitle -Text 'XÂY DỰNG WEBSITE TECHSTORE BÁN HÀNG ĐỒ CÔNG NGHỆ' -FontSize 20
    Set-NonTocTitle -Text 'TPHCM – 2026' -FontSize 13
    $coverAnchor = $document.Paragraphs.Item(1).Range
    $coverAnchor.Style = 'Normal'
    $coverAnchor.ParagraphFormat.OutlineLevel = 10

    $searchRange = $document.Content.Duplicate
    $searchRange.Find.ClearFormatting()
    $searchRange.Find.Text = 'MỤC LỤC'
    if (-not $searchRange.Find.Execute()) {
        throw 'Không tìm thấy vị trí MỤC LỤC trong template.'
    }
    $deleteRange = $document.Range($searchRange.Start, $document.Content.End - 1)
    $deleteRange.Delete()

    [void](Add-DisplayHeading -Text 'MỤC LỤC' -FontSize 18)
    [void](Add-Paragraph -Text '[[TECHSTORE_REPORT_TOC]]' -Style 'Normal' -SpaceAfter 0)
    Add-PageBreak

    [void](Add-DisplayHeading -Text 'PHIÊN BẢN TÀI LIỆU' -FontSize 18)
    [void](Add-Table -Rows @(
        @('Ngày', 'Phiên bản', 'Mô tả', 'Biên soạn', 'Người duyệt'),
        @('02/10/2026', '1.0', 'Báo cáo tổng thể dự án TechStore', 'Nhóm TechStore', '[Điền tên]')
    ))

    [void](Add-DisplayHeading -Text 'DANH SÁCH THÀNH VIÊN' -FontSize 18)
    [void](Add-Table -Rows @(
        @('STT', 'Họ và tên', 'Mã sinh viên', 'Vai trò/Nhiệm vụ'),
        @('1', '[Điền họ tên]', '[Điền MSSV]', 'Trưởng nhóm/Test Manager'),
        @('2', '[Điền họ tên]', '[Điền MSSV]', 'Backend/Database'),
        @('3', '[Điền họ tên]', '[Điền MSSV]', 'Frontend/UI/UX'),
        @('4', '[Điền họ tên]', '[Điền MSSV]', 'Tester/Tài liệu')
    ))

    [void](Add-DisplayHeading -Text 'GIẢNG VIÊN HƯỚNG DẪN' -FontSize 18)
    Add-BodyText 'Họ và tên: [Điền tên giảng viên]'
    Add-BodyText 'Cơ quan công tác: Trường Cao đẳng FPT Polytechnic.'
    Add-BodyText 'Email/Điện thoại: [Điền thông tin nếu cần]'
    Add-BodyText 'Ý kiến nhận xét, đánh giá: ....................................................................................................................'
    Add-BodyText '...............................................................................................................................................................'
    Add-BodyText 'Giảng viên hướng dẫn (Ký và ghi rõ họ tên)'
    Add-PageBreak

    Add-Heading 'LỜI CẢM ƠN' 1
    Add-BodyText 'Nhóm chúng em xin chân thành cảm ơn quý thầy cô Trường Cao đẳng FPT Polytechnic đã truyền đạt kiến thức về phát triển phần mềm, cơ sở dữ liệu, thiết kế giao diện và kiểm thử. Những kiến thức này là nền tảng để nhóm xây dựng và hoàn thiện dự án TechStore.'
    Add-BodyText 'Nhóm đặc biệt cảm ơn giảng viên hướng dẫn đã góp ý về phạm vi đề tài, quy trình thực hiện và cách đánh giá chất lượng sản phẩm. Trong quá trình triển khai, nhóm đã học được cách phân tích yêu cầu, tổ chức mã nguồn theo MVC, kiểm soát dữ liệu giao dịch và phối hợp kiểm thử theo mức độ rủi ro.'
    Add-BodyText 'Dù đã cố gắng hoàn thiện, báo cáo và sản phẩm vẫn có thể còn hạn chế. Nhóm mong nhận được góp ý để tiếp tục nâng cao chất lượng hệ thống và kỹ năng chuyên môn.'

    Add-Heading 'TÓM TẮT NỘI DUNG DỰ ÁN' 1
    Add-BodyText 'TechStore là website thương mại điện tử chuyên bán điện thoại, iPad/máy tính bảng, laptop và phụ kiện công nghệ. Người dùng có thể duyệt danh mục, tìm kiếm và lọc sản phẩm, xem phiên bản và thông số, đăng ký tài khoản, quản lý hồ sơ/địa chỉ, yêu thích sản phẩm, sử dụng giỏ hàng, đặt hàng và theo dõi lịch sử đơn.'
    Add-BodyText 'Hệ thống hỗ trợ thanh toán khi nhận hàng và VNPay sandbox. Khu vực quản trị được tách khỏi giao diện cửa hàng, cho phép ADMIN theo dõi dashboard, xuất báo cáo CSV, quản lý danh mục, thương hiệu, sản phẩm, phiên bản, hình ảnh, thông số, đơn hàng và tài khoản người dùng.'
    Add-BodyText 'Ứng dụng được xây dựng bằng Java 21, Jakarta Servlet/JSP, JSTL, Hibernate/JPA, SQL Server, Apache Tomcat và Maven theo kiến trúc MVC. Dữ liệu nhạy cảm được nhận qua biến môi trường; hệ thống áp dụng BCrypt, CSRF token, phân quyền và transaction cho các nghiệp vụ quan trọng.'

    Add-PageBreak
    Add-Heading 'PHẦN 1. GIỚI THIỆU ĐỀ TÀI – HỆ THỐNG' 1
    Add-Heading '1. Lý do chọn đề tài' 2
    Add-BodyText 'Nhu cầu mua sắm thiết bị công nghệ trực tuyến ngày càng phổ biến vì khách hàng muốn so sánh cấu hình, giá bán và phiên bản sản phẩm trước khi quyết định. Một cửa hàng công nghệ cũng cần quản lý số lượng tồn kho, đơn hàng, thanh toán và dữ liệu khách hàng một cách nhất quán thay vì xử lý thủ công.'
    Add-BodyText 'Đề tài TechStore được lựa chọn vì bao quát nhiều nghiệp vụ thực tế của thương mại điện tử và phù hợp để vận dụng kiến thức Java Web, cơ sở dữ liệu quan hệ, giao diện responsive, bảo mật và kiểm thử phần mềm. Các luồng giỏ hàng, đặt hàng, VNPay và quản trị tạo điều kiện đánh giá cả chức năng lẫn toàn vẹn dữ liệu.'

    Add-Heading '2. Quy ước tài liệu' 2
    Add-Caption 'Bảng 1. Quy ước sử dụng trong báo cáo'
    [void](Add-Table -Rows @(
        @('Quy ước', 'Ý nghĩa'),
        @('Tên bảng/lớp/package', 'Viết theo đúng định danh kỹ thuật, ví dụ Products, OrderService và com.shop.controller.'),
        @('Guest', 'Người truy cập chưa đăng nhập.'),
        @('CUSTOMER', 'Khách hàng đã đăng nhập.'),
        @('ADMIN', 'Người dùng có quyền truy cập khu vực quản trị.'),
        @('P0/P1/P2', 'Mức ưu tiên kiểm thử: sống còn/chính/bổ sung.'),
        @('[Điền ...]', 'Thông tin nhóm cần bổ sung trước khi nộp.')
    ))

    Add-Heading '3. Chú giải thuật ngữ' 2
    Add-Caption 'Bảng 2. Thuật ngữ và từ viết tắt'
    [void](Add-Table -Rows @(
        @('Thuật ngữ', 'Giải thích'),
        @('MVC', 'Model - View - Controller; cách tách dữ liệu/nghiệp vụ, giao diện và điều phối request.'),
        @('JSP/JSTL', 'Công nghệ render giao diện phía server và thư viện thẻ tiêu chuẩn.'),
        @('JPA/Hibernate', 'Chuẩn ORM và framework ánh xạ entity Java với SQL Server.'),
        @('Variant/SKU', 'Phiên bản bán cụ thể của sản phẩm, có mã, giá và tồn kho riêng.'),
        @('Checkout', 'Quá trình xác nhận địa chỉ, sản phẩm, số lượng và phương thức thanh toán để tạo đơn.'),
        @('Snapshot đơn hàng', 'Tên, SKU, ảnh và đơn giá được lưu tại thời điểm đặt hàng.'),
        @('VNPay Return/IPN', 'Hai kênh trả kết quả và thông báo thanh toán từ VNPay.'),
        @('CSRF', 'Tấn công giả mạo yêu cầu từ trình duyệt người dùng.'),
        @('IDOR', 'Truy cập tài nguyên của người khác bằng cách thay đổi mã định danh.'),
        @('UAT', 'Kiểm thử chấp nhận của người dùng/người duyệt.')
    ))

    Add-Heading '4. Mục tiêu đề tài' 2
    Add-Bullet 'Xây dựng website bán hàng công nghệ có luồng mua sắm đầy đủ và giao diện thích ứng desktop/mobile.'
    Add-Bullet 'Quản lý tập trung danh mục, thương hiệu, sản phẩm, phiên bản, ảnh, thông số, tồn kho và đơn hàng.'
    Add-Bullet 'Bảo đảm khách hàng chỉ truy cập dữ liệu thuộc sở hữu của mình; ADMIN mới được sử dụng chức năng quản trị.'
    Add-Bullet 'Hỗ trợ COD và VNPay sandbox, ghi nhận payment và xử lý callback theo hướng idempotent.'
    Add-Bullet 'Áp dụng kiến trúc MVC, DAO/Service, transaction và cấu hình bí mật qua biến môi trường.'
    Add-Bullet 'Chuẩn bị tài liệu, checklist và môi trường để nhóm thực hiện kiểm thử có hệ thống.'

    Add-Heading '5. Nguồn lực - Kế hoạch' 2
    Add-Heading '5.1. Nguồn lực' 3
    Add-Caption 'Bảng 3. Nguồn lực dự án'
    [void](Add-Table -Rows @(
        @('Nhóm nguồn lực', 'Nội dung'),
        @('Nhân sự', 'Trưởng nhóm, Backend/Database, Frontend/UI/UX, Tester/Tài liệu; tên thật do nhóm bổ sung.'),
        @('Thiết bị', 'Máy tính Windows 10/11 64-bit, CPU Core i5 tương đương, RAM tối thiểu 8 GB.'),
        @('Máy chủ ứng dụng', 'Apache Tomcat 10.1.x chạy context /TechStore.'),
        @('Cơ sở dữ liệu', 'Microsoft SQL Server 2019/2022, database TechStore.'),
        @('Dịch vụ ngoài', 'VNPay sandbox và tài khoản SMTP test.'),
        @('Kho mã nguồn', 'Git/GitHub và Maven để quản lý phiên bản, dependency và đóng gói WAR.'),
        @('Tài liệu', 'Kế hoạch triển khai, lộ trình UI/UX, Test Plan và checklist 188 điểm kiểm thử.')
    ))

    Add-Heading '5.2. Kế hoạch phân chia công việc' 3
    Add-Caption 'Bảng 4. Phân chia công việc đề xuất'
    [void](Add-Table -Rows @(
        @('Vai trò', 'Phạm vi phụ trách', 'Sản phẩm bàn giao'),
        @('Trưởng nhóm/Test Manager', 'Phạm vi, tiến độ, tích hợp, review và nghiệm thu.', 'Kế hoạch, biên bản review, Test Summary.'),
        @('Backend/Database', 'Entity, DAO, Service, Servlet, transaction, SQL Server, VNPay/mail.', 'Source backend, script SQL, log tích hợp.'),
        @('Frontend/UI/UX', 'JSP, CSS, JavaScript, responsive, accessibility và trạng thái giao diện.', 'Các màn hình storefront/admin và bằng chứng UI.'),
        @('Tester/Tài liệu', 'Testcase, dữ liệu test, thực thi, defect và báo cáo.', 'Checklist, defect log, test report.'),
        @('Cả nhóm', 'Review chéo, regression, demo và hoàn thiện báo cáo.', 'WAR, tài liệu dự án và bản trình bày.')
    ))

    Add-Heading '6. Kế hoạch triển khai và nguồn lực thực hiện' 2
    Add-Heading '6.1. Đặc điểm người sử dụng' 3
    Add-Caption 'Bảng 5. Nhóm người sử dụng'
    [void](Add-Table -Rows @(
        @('Tác nhân', 'Đặc điểm và quyền'),
        @('Guest', 'Duyệt catalog, tìm kiếm/lọc, xem chi tiết, đăng ký, đăng nhập và quên mật khẩu.'),
        @('CUSTOMER', 'Quản lý tài khoản/địa chỉ, yêu thích, giỏ hàng, checkout, thanh toán và đơn của chính mình.'),
        @('ADMIN', 'Sử dụng storefront khi cần và truy cập dashboard, báo cáo, catalog, đơn hàng, người dùng.'),
        @('Dịch vụ VNPay/SMTP', 'Tác nhân hệ thống ngoài hỗ trợ thanh toán và gửi email đặt lại mật khẩu.')
    ))

    Add-Heading '6.2. Các công cụ phát triển dự án' 3
    Add-Caption 'Bảng 6. Công cụ sử dụng'
    [void](Add-Table -Rows @(
        @('Công cụ', 'Mục đích'),
        @('Eclipse IDE/VS Code', 'Phát triển Java, JSP, CSS, JavaScript và tài liệu.'),
        @('SQL Server Management Studio', 'Tạo schema, seed dữ liệu, truy vấn và đối soát transaction.'),
        @('Apache Tomcat', 'Deploy và chạy ứng dụng Servlet/JSP.'),
        @('Maven', 'Quản lý dependency, compile và đóng gói WAR.'),
        @('Git/GitHub', 'Quản lý phiên bản và chia sẻ mã nguồn.'),
        @('Browser DevTools/Postman/cURL', 'Kiểm tra request, response, session, header và callback.'),
        @('Microsoft Word/Markdown', 'Soạn báo cáo, Test Plan và checklist.'),
        @('PowerShell integration-smoke', 'Chạy smoke/integration test và dọn dữ liệu kiểm thử.')
    ))

    Add-Heading '6.3. Công nghệ sử dụng trong dự án' 3
    Add-Caption 'Bảng 7. Công nghệ và thư viện'
    [void](Add-Table -Rows @(
        @('Công nghệ', 'Phiên bản/Vai trò'),
        @('Java', '21; ngôn ngữ backend.'),
        @('Jakarta Servlet API', '6.0.0; xử lý HTTP request/response.'),
        @('JSP/JSTL', '3.x; render giao diện phía server.'),
        @('Hibernate/JPA', 'Hibernate 6.4.4.Final, JPA 3.1; ORM và transaction.'),
        @('SQL Server JDBC', '12.6.1.jre11; kết nối SQL Server.'),
        @('HTML/CSS/JavaScript', 'Giao diện storefront và admin.'),
        @('BCrypt', '0.4; băm và kiểm tra mật khẩu.'),
        @('Jakarta Mail', '2.0.1; gửi email reset mật khẩu.'),
        @('Jackson', '2.18.2; xử lý JSON khi cần.'),
        @('Maven WAR Plugin', '3.2.3; đóng gói ứng dụng web.')
    ))

    Add-Heading '6.4. Tiến độ công việc' 3
    Add-Caption 'Bảng 8. Các giai đoạn triển khai'
    [void](Add-Table -Rows @(
        @('Giai đoạn', 'Nội dung', 'Trạng thái'),
        @('1. Khởi tạo và database', 'Project Maven, cấu hình JPA, schema 16 bảng và dữ liệu mẫu.', 'Đã triển khai'),
        @('2. Backend nền tảng', 'Entity, DAO, Service, utility và transaction.', 'Đã triển khai'),
        @('3. Storefront', 'Xác thực, catalog, chi tiết, yêu thích, giỏ, tài khoản.', 'Đã triển khai'),
        @('4. Đặt hàng/thanh toán', 'Checkout, đơn, COD, VNPay sandbox và lịch sử trạng thái.', 'Đã triển khai; cần kiểm thử'),
        @('5. Quản trị', 'Dashboard, CSV, catalog, sản phẩm, đơn và user.', 'Đã triển khai'),
        @('6. UI/UX', 'Tách layout, responsive và accessibility UI1-UI10.', 'Đã triển khai; cần review'),
        @('7. Kiểm thử', 'Thực thi 188 điểm kiểm thử, defect, regression và UAT.', 'Nhóm thực hiện'),
        @('8. Đóng gói/deploy', 'Build WAR, cấu hình môi trường, backup và triển khai.', 'Chưa nghiệm thu')
    ))

    Add-PageBreak
    Add-Heading 'PHẦN 2. PHÂN TÍCH' 1
    Add-Heading '1. Yêu cầu người dùng' 2
    Add-Caption 'Bảng 9. Yêu cầu chức năng cấp cao'
    [void](Add-Table -Rows @(
        @('Mã', 'Vai trò', 'Yêu cầu', 'Ưu tiên'),
        @('REQ-01', 'Guest', 'Xem trang chủ, danh mục, tìm kiếm/lọc/sắp xếp và chi tiết sản phẩm.', 'P1'),
        @('REQ-02', 'Guest', 'Đăng ký, đăng nhập và đặt lại mật khẩu qua email.', 'P0'),
        @('REQ-03', 'CUSTOMER', 'Quản lý hồ sơ, mật khẩu và nhiều địa chỉ nhận hàng.', 'P1'),
        @('REQ-04', 'CUSTOMER', 'Thêm/xóa sản phẩm yêu thích.', 'P1'),
        @('REQ-05', 'CUSTOMER', 'Thêm variant vào giỏ, đổi số lượng và xóa sản phẩm.', 'P0'),
        @('REQ-06', 'CUSTOMER', 'Checkout với địa chỉ hợp lệ và thanh toán COD.', 'P0'),
        @('REQ-07', 'CUSTOMER', 'Thanh toán trực tuyến qua VNPay sandbox.', 'P0'),
        @('REQ-08', 'CUSTOMER', 'Xem lịch sử/chi tiết và hủy đơn khi trạng thái cho phép.', 'P0'),
        @('REQ-09', 'ADMIN', 'Xem KPI, biểu đồ và xuất báo cáo CSV theo khoảng ngày.', 'P1'),
        @('REQ-10', 'ADMIN', 'Quản lý danh mục và thương hiệu.', 'P1'),
        @('REQ-11', 'ADMIN', 'Quản lý sản phẩm, variant, ảnh, thông số và trạng thái.', 'P0'),
        @('REQ-12', 'ADMIN', 'Xem chi tiết, cập nhật trạng thái và lịch sử đơn hàng.', 'P0'),
        @('REQ-13', 'ADMIN', 'Khóa/mở tài khoản khách hàng và kiểm soát vai trò.', 'P0'),
        @('REQ-14', 'Hệ thống', 'Phân quyền, CSRF, validation, transaction và quyền sở hữu dữ liệu.', 'P0'),
        @('REQ-15', 'Hệ thống', 'Hiển thị lỗi 403/404/500 có kiểm soát và không lộ thông tin nhạy cảm.', 'P1')
    ) -FontSize 8)

    Add-Heading '2. Trường hợp sử dụng' 2
    Add-Heading '2.1. Chú giải' 3
    [void](Add-Table -Rows @(
        @('Thành phần', 'Ý nghĩa'),
        @('Actor', 'Người hoặc hệ thống ngoài tương tác với TechStore.'),
        @('Use Case', 'Mục tiêu nghiệp vụ actor thực hiện với hệ thống.'),
        @('Include', 'Hành vi bắt buộc được tái sử dụng.'),
        @('Extend', 'Hành vi bổ sung trong điều kiện cụ thể.'),
        @('Precondition/Postcondition', 'Điều kiện trước và trạng thái hệ thống sau use case.')
    ))

    Add-Heading '2.2. Use case tổng' 3
    Add-BodyText 'Biên hệ thống TechStore gồm hai vùng chính: Storefront và Admin. Guest có thể xem catalog và thực hiện xác thực. CUSTOMER kế thừa khả năng duyệt catalog và có thêm tài khoản, yêu thích, giỏ hàng, checkout, payment và đơn hàng. ADMIN truy cập vùng quản trị sau khi qua AuthenticationFilter và AdminAuthorizationFilter. VNPay/SMTP trao đổi với hệ thống qua các điểm tích hợp có kiểm tra cấu hình và dữ liệu.'
    Add-Caption 'Hình mô tả logic Use Case tổng (dạng phân rã chức năng)'
    [void](Add-Table -Rows @(
        @('Guest', 'CUSTOMER', 'ADMIN', 'Hệ thống ngoài'),
        @('Catalog; đăng ký; đăng nhập; quên mật khẩu', 'Hồ sơ; địa chỉ; yêu thích; giỏ; checkout; đơn; payment', 'Dashboard; catalog; sản phẩm; đơn; user; CSV', 'SQL Server; VNPay sandbox; SMTP')
    ))

    Add-Heading '2.3. Danh sách tác nhân' 3
    Add-Caption 'Bảng 10. Danh sách tác nhân'
    [void](Add-Table -Rows @(
        @('Mã', 'Tác nhân', 'Mô tả'),
        @('ACT-01', 'Guest', 'Người dùng chưa đăng nhập.'),
        @('ACT-02', 'CUSTOMER', 'Khách hàng đã xác thực, thao tác trên dữ liệu thuộc sở hữu của mình.'),
        @('ACT-03', 'ADMIN', 'Người quản trị có quyền vận hành hệ thống.'),
        @('ACT-04', 'VNPay', 'Cổng thanh toán sandbox gửi Return/IPN.'),
        @('ACT-05', 'SMTP server', 'Nhận yêu cầu gửi email reset mật khẩu.'),
        @('ACT-06', 'SQL Server', 'Lưu trữ và bảo đảm ràng buộc dữ liệu.')
    ))

    Add-Heading '2.4. Danh sách Use Case' 3
    Add-Caption 'Bảng 11. Danh sách Use Case chính'
    [void](Add-Table -Rows @(
        @('Mã', 'Use Case', 'Tác nhân'),
        @('UC-01', 'Đăng ký/đăng nhập/đăng xuất', 'Guest, CUSTOMER, ADMIN'),
        @('UC-02', 'Quên và đặt lại mật khẩu', 'Guest, SMTP'),
        @('UC-03', 'Duyệt/tìm kiếm/lọc sản phẩm', 'Guest, CUSTOMER, ADMIN'),
        @('UC-04', 'Xem chi tiết và chọn variant', 'Guest, CUSTOMER, ADMIN'),
        @('UC-05', 'Quản lý yêu thích và giỏ hàng', 'CUSTOMER'),
        @('UC-06', 'Quản lý hồ sơ và địa chỉ', 'CUSTOMER'),
        @('UC-07', 'Checkout và đặt đơn COD', 'CUSTOMER'),
        @('UC-08', 'Thanh toán VNPay', 'CUSTOMER, VNPay'),
        @('UC-09', 'Xem/hủy đơn hàng', 'CUSTOMER'),
        @('UC-10', 'Quản lý catalog/sản phẩm', 'ADMIN'),
        @('UC-11', 'Quản lý đơn hàng', 'ADMIN'),
        @('UC-12', 'Quản lý người dùng', 'ADMIN'),
        @('UC-13', 'Xem dashboard/xuất CSV', 'ADMIN')
    ))

    Add-Heading '2.5. Đặc tả Use Case' 3
    Add-UseCase -Code 'UC-01' -Name 'Đăng ký và đăng nhập' -Actor 'Guest; ADMIN/CUSTOMER khi đăng nhập lại' -Precondition 'Hệ thống và database hoạt động; email đăng ký chưa tồn tại.' -MainFlow 'Người dùng nhập thông tin → hệ thống validate → băm mật khẩu BCrypt → tạo Users/Cart → đăng nhập và tạo session.' -Alternative 'Email trùng, dữ liệu sai, tài khoản bị khóa hoặc mật khẩu không đúng: từ chối và hiển thị thông báo phù hợp.' -Postcondition 'Session chứa người dùng hợp lệ; ADMIN chuyển thẳng /admin, CUSTOMER về storefront.'
    Add-UseCase -Code 'UC-03' -Name 'Tìm kiếm và xem sản phẩm' -Actor 'Guest, CUSTOMER, ADMIN' -Precondition 'Có sản phẩm đang hoạt động.' -MainFlow 'Mở catalog → nhập từ khóa/chọn danh mục, hãng, khoảng giá, sort → hệ thống truy vấn và phân trang → mở chi tiết sản phẩm.' -Alternative 'Không có kết quả hoặc tham số không hợp lệ: hiển thị empty state và chuẩn hóa tham số.' -Postcondition 'Danh sách/chi tiết đúng điều kiện, không lộ sản phẩm bị ẩn.'
    Add-UseCase -Code 'UC-05' -Name 'Quản lý yêu thích và giỏ hàng' -Actor 'CUSTOMER' -Precondition 'Người dùng đã đăng nhập; variant tồn tại.' -MainFlow 'Chọn yêu thích hoặc thêm variant vào giỏ → hệ thống kiểm tra tồn kho → gộp SKU nếu đã có → tính lại số lượng/tổng tiền.' -Alternative 'Hết hàng, số lượng vượt tồn, product/variant bị ẩn hoặc request thiếu CSRF: từ chối thay đổi.' -Postcondition 'Favorites/CartItems phản ánh đúng lựa chọn của người dùng.'
    Add-UseCase -Code 'UC-06' -Name 'Quản lý hồ sơ và địa chỉ' -Actor 'CUSTOMER' -Precondition 'Người dùng đăng nhập.' -MainFlow 'Mở tài khoản → cập nhật thông tin/đổi mật khẩu/thêm-sửa-xóa-chọn địa chỉ mặc định → validate và lưu.' -Alternative 'Dữ liệu sai, mật khẩu cũ sai hoặc địa chỉ không thuộc chủ sở hữu: không cập nhật.' -Postcondition 'Thông tin hợp lệ được lưu; chỉ một địa chỉ mặc định nếu nghiệp vụ yêu cầu.'
    Add-UseCase -Code 'UC-07' -Name 'Checkout và đặt đơn COD' -Actor 'CUSTOMER' -Precondition 'Giỏ có ít nhất một sản phẩm hợp lệ; có địa chỉ nhận hàng.' -MainFlow 'Chọn địa chỉ/COD → xác nhận → transaction khóa/kiểm tra tồn → tạo Orders, OrderItems, history → trừ stock → xóa giỏ.' -Alternative 'Hết hàng, submit lặp, dữ liệu thay đổi hoặc lỗi transaction: rollback, không tạo đơn dở dang.' -Postcondition 'Đơn PENDING có snapshot và tổng tiền đúng; tồn kho/giỏ nhất quán.'
    Add-UseCase -Code 'UC-08' -Name 'Thanh toán VNPay' -Actor 'CUSTOMER, VNPay' -Precondition 'Đơn VNPay hợp lệ và cấu hình sandbox đầy đủ.' -MainFlow 'Hệ thống tạo URL có chữ ký → khách thanh toán → VNPay gọi Return/IPN → kiểm tra chữ ký, số tiền, mã giao dịch → cập nhật Payment/Order.' -Alternative 'Thiếu cấu hình, chữ ký sai, số tiền sai, giao dịch thất bại hoặc callback trùng: không ghi nhận thanh toán thành công; phản hồi kiểm soát.' -Postcondition 'Payment và Order đồng bộ, mã giao dịch không xử lý nhiều lần.'
    Add-UseCase -Code 'UC-09' -Name 'Xem và hủy đơn' -Actor 'CUSTOMER' -Precondition 'Đơn thuộc người dùng.' -MainFlow 'Mở lịch sử → xem chi tiết/timeline → hủy khi trạng thái cho phép → hệ thống cập nhật trạng thái và hoàn tồn một lần.' -Alternative 'IDOR, trạng thái không cho hủy hoặc thao tác trùng: từ chối.' -Postcondition 'Trạng thái, history, payment và stock nhất quán.'
    Add-UseCase -Code 'UC-10' -Name 'Quản lý catalog và sản phẩm' -Actor 'ADMIN' -Precondition 'Đăng nhập vai trò ADMIN và có CSRF hợp lệ.' -MainFlow 'Tạo/sửa danh mục, hãng, sản phẩm, variant, ảnh, thông số và trạng thái hiển thị.' -Alternative 'Slug/SKU trùng, dữ liệu sai, file không hợp lệ hoặc bản ghi đang được tham chiếu: hiển thị lỗi, không làm hỏng dữ liệu.' -Postcondition 'Catalog cập nhật và storefront phản ánh dữ liệu đang hoạt động.'
    Add-UseCase -Code 'UC-11' -Name 'Quản lý đơn hàng' -Actor 'ADMIN' -Precondition 'ADMIN truy cập đơn tồn tại.' -MainFlow 'Tìm kiếm/lọc → xem chi tiết → cập nhật theo chuyển trạng thái cho phép → ghi OrderStatusHistory.' -Alternative 'Chuyển trạng thái sai, request lặp hoặc đơn đã thay đổi: từ chối và giữ dữ liệu cũ.' -Postcondition 'Order và timeline khớp; nghiệp vụ hoàn kho/thanh toán không chạy lặp.'
    Add-UseCase -Code 'UC-12' -Name 'Quản lý người dùng và báo cáo' -Actor 'ADMIN' -Precondition 'ADMIN đã xác thực.' -MainFlow 'Xem danh sách user, khóa/mở CUSTOMER; xem KPI/biểu đồ và xuất CSV theo khoảng ngày.' -Alternative 'Không cho tự khóa tài khoản đang dùng hoặc sửa quyền trái chính sách; khoảng ngày sai được validate.' -Postcondition 'User status cập nhật đúng; báo cáo khớp dữ liệu database.'

    Add-Heading '2.6. Activity Diagram (mô tả luồng)' 3
    Add-BodyText 'Luồng đặt hàng: CUSTOMER đăng nhập → xem catalog → chọn variant → thêm giỏ → cập nhật số lượng → chọn địa chỉ → chọn COD/VNPay → xác nhận checkout → transaction kiểm tra tồn → tạo đơn/snapshot/history → trừ tồn → thanh toán (nếu VNPay) → hiển thị chi tiết đơn.'
    Add-BodyText 'Luồng xử lý đơn: ADMIN đăng nhập → dashboard/danh sách đơn → tìm và mở chi tiết → kiểm tra lịch sử/payment → chọn trạng thái kế tiếp hợp lệ → cập nhật Order → ghi OrderStatusHistory → storefront hiển thị timeline mới.'
    Add-BodyText 'Luồng reset mật khẩu: Guest nhập email → hệ thống tạo token có thời hạn → SMTP gửi liên kết → người dùng mở token → nhập mật khẩu mới → token được xác minh và vô hiệu hóa sau khi dùng.'

    Add-Heading '3. Quan hệ thực thể' 2
    Add-Heading '3.1. Danh sách thực thể' 3
    Add-Caption 'Bảng 12. Danh sách 16 bảng dữ liệu'
    [void](Add-Table -Rows @(
        @('Bảng', 'Mục đích'),
        @('Users', 'Tài khoản, vai trò, mật khẩu băm, trạng thái và hồ sơ cơ bản.'),
        @('Addresses', 'Địa chỉ nhận hàng thuộc người dùng.'),
        @('PasswordResetTokens', 'Token đặt lại mật khẩu, hạn dùng và trạng thái sử dụng.'),
        @('Categories', 'Danh mục sản phẩm.'),
        @('Brands', 'Thương hiệu sản phẩm.'),
        @('Products', 'Thông tin chung, slug, mô tả và trạng thái sản phẩm.'),
        @('ProductVariants', 'SKU, thuộc tính phiên bản, giá, giá gốc và tồn kho.'),
        @('ProductImages', 'Ảnh chính/phụ của sản phẩm hoặc variant.'),
        @('ProductSpecifications', 'Tên/giá trị thông số kỹ thuật.'),
        @('Favorites', 'Quan hệ yêu thích giữa Users và Products.'),
        @('Carts', 'Giỏ hàng của người dùng.'),
        @('CartItems', 'Variant và số lượng trong giỏ.'),
        @('Orders', 'Thông tin đơn, người nhận, tổng tiền, trạng thái và phương thức thanh toán.'),
        @('OrderItems', 'Snapshot sản phẩm/variant trong đơn.'),
        @('Payments', 'Giao dịch COD/VNPay và mã đối soát.'),
        @('OrderStatusHistory', 'Timeline thay đổi trạng thái đơn.')
    ) -FontSize 8)

    Add-Heading '3.2. Sơ đồ quan hệ thực thể (mô tả)' 3
    [void](Add-Table -Rows @(
        @('Nhóm', 'Quan hệ chính'),
        @('Tài khoản', 'Users 1-N Addresses; Users 1-N PasswordResetTokens; Users 1-1 Carts.'),
        @('Catalog', 'Categories 1-N Products; Brands 1-N Products; Products 1-N Variants/Images/Specifications.'),
        @('Tương tác', 'Users N-N Products qua Favorites; Carts 1-N CartItems; ProductVariants 1-N CartItems.'),
        @('Đơn hàng', 'Users 1-N Orders; Orders 1-N OrderItems/Payments/OrderStatusHistory; Variant được tham chiếu và đồng thời lưu snapshot.'),
        @('Toàn vẹn', 'Unique email/slug/SKU; CHECK giá, stock và status; foreign key và index cho truy vấn chính.')
    ))

    Add-Heading '3.3. Các mối quan hệ' 3
    Add-Caption 'Bảng 13. Quan hệ dữ liệu quan trọng'
    [void](Add-Table -Rows @(
        @('Quan hệ', 'Bội số', 'Quy tắc nghiệp vụ'),
        @('Users - Addresses', '1-N', 'Chỉ chủ sở hữu được sửa/xóa; địa chỉ được snapshot vào Orders.'),
        @('Users - Carts', '1-1', 'Mỗi tài khoản có một giỏ hoạt động.'),
        @('Carts - CartItems', '1-N', 'Một SKU chỉ xuất hiện một dòng và tăng quantity khi thêm lặp.'),
        @('Categories - Products', '1-N', 'Danh mục đang được dùng cần xử lý phù hợp khi xóa/ẩn.'),
        @('Brands - Products', '1-N', 'Một sản phẩm thuộc một thương hiệu.'),
        @('Products - ProductVariants', '1-N', 'Giá và tồn kho nằm ở variant.'),
        @('Products - ProductImages', '1-N', 'Một ảnh có thể đánh dấu là ảnh chính.'),
        @('Products - ProductSpecifications', '1-N', 'Thông số hiển thị theo thứ tự.'),
        @('Users - Products', 'N-N', 'Bảng Favorites dùng khóa ghép, không cho trùng.'),
        @('Users - Orders', '1-N', 'CUSTOMER chỉ xem đơn của mình.'),
        @('Orders - OrderItems', '1-N', 'OrderItem lưu snapshot để dữ liệu lịch sử không đổi theo catalog.'),
        @('Orders - Payments', '1-N/logic', 'Cho phép theo dõi lần thanh toán/retry nhưng mã giao dịch phải duy nhất.'),
        @('Orders - OrderStatusHistory', '1-N', 'Mỗi thay đổi trạng thái tạo một bản ghi timeline.')
    ) -FontSize 8)

    Add-PageBreak
    Add-Heading 'PHẦN 3. THIẾT KẾ' 1
    Add-Heading '1. Cơ sở dữ liệu' 2
    Add-Heading '1.1. Thiết kế bảng và ràng buộc' 3
    Add-BodyText 'Database TechStore được tổ chức theo các nhóm tài khoản, catalog, tương tác mua sắm và đơn hàng. Khóa ngoại bảo vệ quan hệ; unique constraint ngăn trùng email, slug, SKU và dữ liệu yêu thích; check constraint giới hạn giá, số lượng, tồn kho và trạng thái. Index được đặt cho khóa ngoại, trường tìm kiếm và trường lọc thường dùng.'
    Add-Caption 'Bảng 14. Quy tắc thiết kế dữ liệu'
    [void](Add-Table -Rows @(
        @('Quy tắc', 'Áp dụng'),
        @('Khóa chính', 'Mỗi bảng có định danh ổn định; bảng Favorites có khóa ghép.'),
        @('Khóa ngoại', 'Không tạo CartItem/OrderItem/Payment không có bản ghi cha hợp lệ.'),
        @('Unique', 'Email, slug, SKU, token/mã giao dịch theo yêu cầu nghiệp vụ.'),
        @('CHECK', 'Giá và stock không âm; quantity dương; status thuộc tập cho phép.'),
        @('Snapshot', 'OrderItems và Orders lưu dữ liệu cần thiết tại thời điểm mua.'),
        @('Transaction', 'Checkout, hủy đơn, cập nhật trạng thái và callback phải nguyên tử.'),
        @('Audit nghiệp vụ', 'OrderStatusHistory lưu người cập nhật, trạng thái và thời điểm.')
    ))

    Add-Heading '1.2. Nguyên tắc toàn vẹn và đồng thời' 3
    Add-Bullet 'Không cho phép stock âm hoặc hoàn stock nhiều lần.'
    Add-Bullet 'Hai checkout cạnh tranh SKU cuối phải chỉ có một giao dịch thành công.'
    Add-Bullet 'Submit/callback lặp phải idempotent, không sinh đơn hoặc payment trùng.'
    Add-Bullet 'Tổng tiền phía server được tính lại từ dữ liệu tin cậy, không nhận trực tiếp từ client.'
    Add-Bullet 'Các thao tác nhiều bảng rollback toàn bộ khi xảy ra lỗi.'

    Add-Heading '2. Giao diện người dùng' 2
    Add-Heading '2.1. Sơ đồ tổ chức giao diện' 3
    [void](Add-Table -Rows @(
        @('Storefront', 'Tài khoản/Đơn hàng', 'Admin'),
        @('Home; Products; Product Detail; Favorites; Cart; Checkout', 'Login; Register; Forgot/Reset; Profile; Addresses; Order List/Detail; VNPay Result', 'Dashboard; Catalog; Products/Form; Orders/Detail; Users; CSV Report')
    ))

    Add-Heading '2.2. Danh sách giao diện' 3
    Add-Caption 'Bảng 15. Các màn hình chính'
    [void](Add-Table -Rows @(
        @('Nhóm', 'Màn hình', 'Mục đích'),
        @('Công khai', 'Trang chủ', 'Danh mục nổi bật, sản phẩm và điều hướng.'),
        @('Công khai', 'Danh sách sản phẩm', 'Search/filter/sort/paging.'),
        @('Công khai', 'Chi tiết sản phẩm', 'Ảnh, variant, thông số, giá và tồn kho.'),
        @('Xác thực', 'Đăng ký/Đăng nhập', 'Tạo và xác thực tài khoản.'),
        @('Xác thực', 'Quên/Đặt lại mật khẩu', 'Khôi phục tài khoản qua email/token.'),
        @('Khách hàng', 'Hồ sơ/Địa chỉ', 'Quản lý thông tin và địa chỉ nhận hàng.'),
        @('Khách hàng', 'Yêu thích', 'Danh sách sản phẩm quan tâm.'),
        @('Khách hàng', 'Giỏ hàng', 'Số lượng, tổng tiền và tồn kho.'),
        @('Khách hàng', 'Checkout', 'Địa chỉ, phương thức và xác nhận đơn.'),
        @('Khách hàng', 'Đơn hàng', 'Danh sách, chi tiết, timeline và hủy đơn.'),
        @('Thanh toán', 'Kết quả VNPay', 'Thông báo kết quả và điều hướng tiếp theo.'),
        @('Admin', 'Dashboard', 'KPI, biểu đồ, đơn mới và khoảng ngày.'),
        @('Admin', 'Catalog/Sản phẩm', 'CRUD danh mục, hãng, sản phẩm và tài sản.'),
        @('Admin', 'Đơn hàng', 'Tìm kiếm, xem và cập nhật trạng thái.'),
        @('Admin', 'Người dùng', 'Tìm kiếm và khóa/mở CUSTOMER.'),
        @('Hệ thống', '403/404/500/Health', 'Phản hồi lỗi và kiểm tra trạng thái hệ thống.')
    ) -FontSize 8)

    Add-Heading '2.3. Design system, responsive và accessibility' 3
    Add-BodyText 'Storefront và Admin sử dụng header/footer riêng nhưng chia sẻ nguyên tắc typography, màu trạng thái, khoảng cách, button, form và thông báo. Các breakpoint mục tiêu gồm 1440, 1024, 768, 500 và 390 px. Giao diện cần có focus rõ, thao tác bàn phím, alt/aria-label phù hợp, reduced motion và không tràn ngang.'
    Add-Bullet 'Trạng thái loading, empty, error, disabled và success phải rõ ràng.'
    Add-Bullet 'Giá, CTA mua hàng và trạng thái tồn kho được ưu tiên trong card/chi tiết sản phẩm.'
    Add-Bullet 'Admin ưu tiên mật độ thông tin, bộ lọc, bảng responsive và thao tác có xác nhận.'
    Add-Bullet 'Toàn bộ trang sử dụng UTF-8 để không lỗi font tiếng Việt.'

    Add-Heading '3. Kiến trúc phần mềm' 2
    Add-Heading '3.1. Luồng MVC' 3
    [void](Add-Table -Rows @(
        @('Tầng', 'Thành phần', 'Trách nhiệm'),
        @('View', 'JSP/JSTL, CSS, JavaScript', 'Hiển thị dữ liệu, form, trạng thái và tương tác phía client.'),
        @('Controller', 'Servlet', 'Nhận request, validate cấp HTTP, gọi service và chọn view/redirect.'),
        @('Business', 'Service/ServiceImpl', 'Quy tắc nghiệp vụ, transaction và phối hợp DAO.'),
        @('Persistence', 'DAO/DAOImpl, GenericDAO', 'Truy vấn và thao tác entity.'),
        @('Model', 'Entity/DTO', 'Ánh xạ database và dữ liệu dành cho view.'),
        @('Cross-cutting', 'Filter, Utils, Listener', 'Auth, authorization, CSRF, encoding, cấu hình, JPA lifecycle và mail/VNPay.')
    ))
    Add-BodyText 'Luồng tổng quát: Browser → Filter → Servlet Controller → Service → DAO/JPA → SQL Server → DTO/Entity → Servlet → JSP → HTML response.'

    Add-Heading '3.2. Bảo mật thiết kế' 3
    Add-Bullet 'Mật khẩu được băm BCrypt; không lưu plaintext.'
    Add-Bullet 'AuthenticationFilter và AdminAuthorizationFilter kiểm soát đăng nhập/vai trò.'
    Add-Bullet 'CSRF token bảo vệ request thay đổi dữ liệu; quyền sở hữu chống IDOR.'
    Add-Bullet 'JPA parameter binding/validation giảm rủi ro SQL injection; output cần escape chống XSS.'
    Add-Bullet 'Secret database, mail và VNPay chỉ được tham chiếu bằng tên biến môi trường.'
    Add-Bullet 'Trang lỗi không hiển thị stack trace hoặc thông tin cấu hình nhạy cảm.'

    Add-PageBreak
    Add-Heading 'PHẦN 4. THỰC THI' 1
    Add-Heading '1. Tổ chức mã nguồn' 2
    Add-Heading '1.1. Sơ đồ tổ chức' 3
    Add-BodyText 'Dự án hiện có 136 file Java, trong đó gồm 23 Servlet, 17 lớp mô hình dữ liệu (16 entity ánh xạ bảng và FavoriteId là khóa ghép nhúng), các interface/implementation DAO và Service, 4 Filter cùng các lớp tiện ích. Mã nguồn và tài nguyên được tổ chức theo chuẩn Maven Web Application.'
    [void](Add-Table -Rows @(
        @('Đường dẫn/package', 'Nội dung'),
        @('com.shop.controller', 'Servlet storefront, account, auth, payment và admin.'),
        @('com.shop.service / impl', 'Interface và triển khai nghiệp vụ.'),
        @('com.shop.dao / impl', 'Interface và triển khai truy cập dữ liệu.'),
        @('com.shop.entity', '16 entity ánh xạ bảng và FavoriteId biểu diễn khóa ghép của Favorites.'),
        @('com.shop.dto', 'DTO dashboard, product card, VNPay result và section trang chủ.'),
        @('com.shop.filter', 'Application, storefront data, authentication và admin authorization.'),
        @('com.shop.utils', 'Config, JPA, validation, web helpers, mail và VNPay.'),
        @('src/main/resources/META-INF', 'persistence.xml và config.properties.'),
        @('src/main/webapp/WEB-INF/views', 'JSP auth, account, product, order, payment, admin, error và components.'),
        @('src/main/webapp/assets', 'CSS, JavaScript và ảnh tĩnh.'),
        @('database', 'Schema, seed và migration SQL Server.'),
        @('scripts', 'Smoke/integration, kiểm tra JSP và script tạo tài liệu.')
    ) -FontSize 8)

    Add-Heading '1.2. Thư viện sử dụng' 3
    Add-Caption 'Bảng 16. Dependency chính trong pom.xml'
    [void](Add-Table -Rows @(
        @('Thư viện', 'Phiên bản', 'Vai trò'),
        @('jakarta.servlet-api', '6.0.0', 'Servlet API cho Tomcat 10.1.'),
        @('jakarta.persistence-api', '3.1.0', 'Annotation/API JPA.'),
        @('hibernate-core', '6.4.4.Final', 'ORM và transaction.'),
        @('mssql-jdbc', '12.6.1.jre11', 'SQL Server driver.'),
        @('jakarta.servlet.jsp.jstl', '3.0.x', 'JSTL cho JSP.'),
        @('jackson-databind', '2.18.2', 'JSON mapping.'),
        @('jbcrypt', '0.4', 'Hash mật khẩu.'),
        @('jakarta.mail', '2.0.1', 'Gửi email.'),
        @('lombok', '1.18.38', 'Giảm mã getter/setter/constructor.'),
        @('maven-war-plugin', '3.2.3', 'Đóng gói WAR.')
    ))

    Add-Heading '2. Các chức năng đã thực thi' 2
    Add-Caption 'Bảng 17. Tình trạng chức năng'
    [void](Add-Table -Rows @(
        @('Module', 'Chức năng hiện có'),
        @('System', 'Home, health, routing, 403/404/500 và static assets.'),
        @('Authentication', 'Register, login/logout, session, account lock và reset password.'),
        @('Catalog', 'Category sections, search, filter, sort, paging, detail, image/spec/variant.'),
        @('Customer', 'Profile, password, addresses, favorites và cart.'),
        @('Order', 'Checkout, COD, VNPay, snapshot, history, detail, cancel và restore stock.'),
        @('Admin dashboard', 'KPI, charts, date range và CSV.'),
        @('Admin catalog', 'Category, brand, product, variant, image và specification.'),
        @('Admin operations', 'Orders, timeline, user search và lock/unlock.'),
        @('Security', 'BCrypt, filters, CSRF, ownership, validation và secret env references.'),
        @('UI/UX', 'Store/admin layout riêng, responsive, mobile menu và accessibility improvements.')
    ))

    Add-Heading '3. Cấu hình và triển khai' 2
    Add-BodyText 'Ứng dụng được build bằng Maven thành WAR và deploy lên Tomcat với context /TechStore. SQL Server chạy database TechStore. config.properties chỉ lưu URL và tên biến môi trường; giá trị username/password database, mail và secret VNPay không được commit.'
    Add-Caption 'Bảng 18. Biến môi trường cần cấu hình'
    [void](Add-Table -Rows @(
        @('Biến', 'Mục đích'),
        @('TECHSTORE_DB_USERNAME', 'Tài khoản SQL Server.'),
        @('TECHSTORE_DB_PASSWORD', 'Mật khẩu SQL Server.'),
        @('TECHSTORE_MAIL_USERNAME', 'Tài khoản gửi mail test.'),
        @('TECHSTORE_MAIL_PASSWORD', 'Mật khẩu/app password email.'),
        @('TECHSTORE_VNPAY_TMN_CODE', 'Mã website VNPay sandbox.'),
        @('TECHSTORE_VNPAY_HASH_SECRET', 'Khóa ký request/callback VNPay.')
    ))
    Add-Bullet 'Build: mvn clean package.'
    Add-Bullet 'Deploy WAR lên Tomcat 10.1.x và truy cập http://localhost:8080/TechStore.'
    Add-Bullet 'Return URL: http://localhost:8080/TechStore/payment?action=vnpay_return (phải khớp context triển khai).'
    Add-Bullet 'Không sử dụng credential production trong môi trường học tập/kiểm thử.'

    Add-PageBreak
    Add-Heading 'PHẦN 5. KIỂM THỬ' 1
    Add-Heading '1. Kế hoạch kiểm thử' 2
    Add-BodyText 'Kế hoạch kiểm thử chi tiết nằm trong TEST_PLAN_TECHSTORE_CAP_NHAT.docx; danh sách chức năng và 188 điểm kiểm thử nằm trong DANH_SACH_CHUC_NANG_VA_KIEM_THU.md. Phần này tóm tắt chiến lược và cung cấp bảng để nhóm điền kết quả thực thi.'

    Add-Heading '1.1. Tiêu chí cần đạt' 3
    Add-Bullet '100% testcase P0 đạt.'
    Add-Bullet 'Ít nhất 95% testcase P1 đạt; phần còn lại có quyết định xử lý hoặc chấp nhận rủi ro.'
    Add-Bullet 'Không còn lỗi Critical/High về tiền, tồn kho, đơn, xác thực, phân quyền, CSRF, IDOR hoặc secret.'
    Add-Bullet 'Không có stock âm, đơn rỗng, tổng tiền sai, hoàn kho lặp hoặc VNPay transaction trùng.'
    Add-Bullet 'Build WAR, JSP compile, smoke test và deploy sạch trên Tomcat đều đạt.'
    Add-Bullet 'Luồng chính hoạt động trên Chrome, Edge, Firefox và các breakpoint mục tiêu.'

    Add-Heading '1.2. Chiến lược triển khai' 3
    Add-Caption 'Bảng 19. Các mức và loại kiểm thử'
    [void](Add-Table -Rows @(
        @('Mức/Loại', 'Nội dung'),
        @('Unit', 'ValidationUtil, VNPayUtil, mapper và quy tắc Service; dự án cần bổ sung JUnit/Mockito.'),
        @('Integration', 'Servlet-Service-DAO-DB, transaction, SMTP, file upload và VNPay sandbox.'),
        @('System', 'End-to-end storefront/admin trên bản deploy Tomcat.'),
        @('Acceptance', 'Nhóm/người duyệt chạy kịch bản nghiệp vụ và ký xác nhận.'),
        @('Security/Data', 'CSRF, IDOR, XSS/SQLi, quyền, secret, rollback và concurrency.'),
        @('UI/UX', 'Responsive, browser compatibility, keyboard, focus, font và accessibility.'),
        @('Regression', 'Chạy lại lỗi đã sửa, module liên quan và bộ P0/smoke.')
    ))

    Add-Heading '1.3. Thống kê kế hoạch kiểm thử' 3
    Add-Caption 'Bảng 20. Phân bố checklist hiện có'
    [void](Add-Table -Rows @(
        @('Mức ưu tiên', 'Số điểm kiểm thử', 'Ý nghĩa', 'Kết quả'),
        @('P0', '79', 'Luồng sống còn và rủi ro cao.', 'Chưa nhập kết quả'),
        @('P1', '105', 'Chức năng chính và phi chức năng quan trọng.', 'Chưa nhập kết quả'),
        @('P2', '4', 'Ca bổ sung/ít ảnh hưởng.', 'Chưa nhập kết quả'),
        @('Tổng', '188', 'Toàn bộ checklist hiện có.', 'Nhóm thực thi và cập nhật')
    ))
    Add-BodyText 'Lưu ý: số lượng trên là kế hoạch/checklist, không phải số testcase đã Pass. Nhóm phải ghi ngày chạy, người chạy, dữ liệu, bằng chứng và defect trước khi tính tỷ lệ đạt.'

    Add-Heading '1.4. Bảng tổng hợp kết quả kiểm thử' 3
    Add-Caption 'Bảng 21. Test Report (nhóm cập nhật sau khi chạy)'
    [void](Add-Table -Rows @(
        @('Module', 'Tổng', 'Pass', 'Fail', 'Blocked', 'Người chạy/Ghi chú'),
        @('System/Navigation', '[Điền]', '[Điền]', '[Điền]', '[Điền]', '[Điền]'),
        @('Authentication/Account', '[Điền]', '[Điền]', '[Điền]', '[Điền]', '[Điền]'),
        @('Catalog/Product', '[Điền]', '[Điền]', '[Điền]', '[Điền]', '[Điền]'),
        @('Favorites/Cart', '[Điền]', '[Điền]', '[Điền]', '[Điền]', '[Điền]'),
        @('Checkout/Order', '[Điền]', '[Điền]', '[Điền]', '[Điền]', '[Điền]'),
        @('VNPay', '[Điền]', '[Điền]', '[Điền]', '[Điền]', '[Điền]'),
        @('Admin', '[Điền]', '[Điền]', '[Điền]', '[Điền]', '[Điền]'),
        @('Security/Database', '[Điền]', '[Điền]', '[Điền]', '[Điền]', '[Điền]'),
        @('UI/UX/Compatibility', '[Điền]', '[Điền]', '[Điền]', '[Điền]', '[Điền]')
    ) -FontSize 8)

    Add-Heading '2. Quản lý lỗi và rủi ro kiểm thử' 2
    Add-Caption 'Bảng 22. Phân loại mức độ lỗi'
    [void](Add-Table -Rows @(
        @('Severity', 'Mô tả', 'Ví dụ'),
        @('Critical', 'Mất tiền/dữ liệu, vượt quyền nghiêm trọng hoặc hệ thống không dùng được.', 'Sai tổng tiền, stock âm, customer vào admin, lộ secret.'),
        @('High', 'Chức năng chính không dùng được và không có cách vòng.', 'Không login/checkout, không trừ/hoàn stock, CSRF/IDOR.'),
        @('Medium', 'Một phần chức năng sai nhưng có cách vòng.', 'Filter/validation/CSV hoặc layout một trình duyệt bị lỗi.'),
        @('Low', 'Lỗi hiển thị/trải nghiệm nhỏ.', 'Khoảng cách, wording, icon hoặc hover chưa nhất quán.')
    ))
    Add-BodyText 'Quy trình defect: New → Triaged → Assigned → In Progress → Fixed → Ready for Retest → Verified → Closed. Lỗi còn tồn tại chuyển Reopened; lỗi hoãn phải ghi lý do và người chấp nhận rủi ro.'

    Add-Heading '3. Tài liệu và bằng chứng kiểm thử' 2
    Add-Bullet 'TEST_PLAN_TECHSTORE_CAP_NHAT.docx: phạm vi, lịch, nguồn lực, chiến lược và tiêu chí.'
    Add-Bullet 'DANH_SACH_CHUC_NANG_VA_KIEM_THU.md: checklist chức năng và phi chức năng.'
    Add-Bullet 'Test Execution Result: Pass/Fail/Blocked, dữ liệu, thời gian và ảnh/log.'
    Add-Bullet 'Defect Log: severity, owner, trạng thái, bước tái hiện và regression.'
    Add-Bullet 'Test Summary Report và Sign-off: kết luận nghiệm thu.'

    Add-PageBreak
    Add-Heading 'PHẦN 6. TỔNG KẾT' 1
    Add-Heading '1. Thời gian phát triển dự án' 2
    Add-BodyText 'Dự án được phát triển theo từng giai đoạn: database và kiến trúc nền; chức năng storefront; giỏ/checkout/đơn; quản trị; tài khoản và thanh toán; cải tiến UI/UX; lập kế hoạch kiểm thử và chuẩn bị triển khai. Ngày tài liệu tổng hợp: 02/10/2026. Nhóm bổ sung ngày bắt đầu/kết thúc thực tế vào bảng tiến độ trước khi nộp.'

    Add-Heading '2. Mức độ hoàn thành' 2
    Add-BodyText 'Phiên bản hiện tại đã có các module chính của website bán hàng: xác thực, catalog, yêu thích, giỏ, tài khoản/địa chỉ, checkout, COD/VNPay, đơn hàng, dashboard và quản trị dữ liệu. Source tổ chức theo MVC và database có ràng buộc cho các nghiệp vụ chính.'
    Add-BodyText 'Các hạng mục còn cần nhóm xác nhận là kết quả kiểm thử thực tế, cấu hình sandbox/mail trên máy chạy, deploy môi trường đích và các tiêu chí production. Không coi chức năng mã giảm giá/khuyến mãi là phạm vi bắt buộc của phiên bản này.'

    Add-Heading '3. Những khó khăn, rủi ro và cách giải quyết' 2
    Add-Caption 'Bảng 23. Khó khăn và hướng xử lý'
    [void](Add-Table -Rows @(
        @('Khó khăn/Rủi ro', 'Cách giải quyết'),
        @('Cấu hình SQL Server, mail và VNPay khác nhau giữa máy', 'Dùng config.properties tham chiếu biến môi trường; có health/log và checklist cấu hình.'),
        @('Sai encoding tiếng Việt', 'Chuẩn hóa UTF-8 ở source, request/response, database, JSP và CSV; kiểm thử dữ liệu dấu.'),
        @('Tồn kho và callback bị xử lý đồng thời', 'Transaction, constraint, kiểm tra trạng thái và testcase concurrency/idempotency.'),
        @('Phân quyền và IDOR', 'Filter vai trò, kiểm tra chủ sở hữu tại service/query và negative test bằng request sửa tay.'),
        @('Ảnh upload mất khi redeploy', 'Backup, kiểm thử deploy sạch; hướng production là storage ngoài webapp.'),
        @('UI nhiều màn hình/kích thước', 'Design system, component JSP dùng chung, breakpoint mục tiêu và checklist accessibility.'),
        @('Thiếu thời gian kiểm thử', 'Ưu tiên P0 → P1 → P2, dùng smoke script và review chéo theo module.')
    ))

    Add-Heading '4. Những bài học rút ra sau khi làm dự án' 2
    Add-Bullet 'Phân tích dữ liệu và trạng thái nghiệp vụ trước khi viết giao diện giúp giảm sửa đổi về sau.'
    Add-Bullet 'Tách Controller-Service-DAO làm mã dễ đọc, dễ kiểm thử và giới hạn transaction rõ hơn.'
    Add-Bullet 'Bảo mật phải được thiết kế từ đầu ở session, quyền, CSRF, ownership và quản lý secret.'
    Add-Bullet 'Luồng thanh toán và tồn kho cần kiểm thử trường hợp lặp, lỗi giữa chừng và đồng thời, không chỉ happy path.'
    Add-Bullet 'Tài liệu và ma trận truy vết giúp nhóm biết chức năng nào đã làm, đã test và còn rủi ro.'
    Add-Bullet 'UI/UX tốt cần phản hồi trạng thái, keyboard/accessibility và responsive chứ không chỉ màu sắc đẹp.'

    Add-Heading '5. Kế hoạch trong tương lai' 2
    Add-Bullet 'Bổ sung src/test với JUnit 5/Mockito và tự động hóa Service/Utils quan trọng.'
    Add-Bullet 'Tự động hóa kiểm thử trình duyệt cho luồng đăng nhập, giỏ, checkout và admin.'
    Add-Bullet 'Triển khai staging/production với HTTPS, secret manager, backup và giám sát log.'
    Add-Bullet 'Chuyển ảnh upload sang storage bền vững ngoài thư mục webapp.'
    Add-Bullet 'Bổ sung email xác nhận đơn/trạng thái, đổi trả/hoàn tiền và hóa đơn khi phạm vi được mở rộng.'
    Add-Bullet 'Tối ưu truy vấn/paging phía database và kiểm thử tải với dữ liệu lớn.'

    Add-Heading 'TÀI LIỆU THAM KHẢO VÀ PHỤ LỤC' 1
    [void](Add-Table -Rows @(
        @('Tài liệu', 'Nội dung'),
        @('README.md', 'Hướng dẫn nhanh dự án.'),
        @('KE_HOACH_TRIEN_KHAI.md', 'Kiến trúc, các bước triển khai và URL.'),
        @('LO_TRINH_NANG_CAP.md', 'Lộ trình hoàn thiện nghiệp vụ.'),
        @('LO_TRINH_CAI_TIEN_UI_UX.md', 'Các giai đoạn UI1-UI10 và design system.'),
        @('DANH_SACH_CHUC_NANG_VA_KIEM_THU.md', 'Chức năng, phi chức năng và 188 điểm kiểm thử.'),
        @('TEST_PLAN_TECHSTORE_CAP_NHAT.docx', 'Kế hoạch kiểm thử tổng thể.'),
        @('database/TechStore.sql', 'Schema và dữ liệu nền SQL Server.'),
        @('pom.xml', 'Dependency và cấu hình build Maven.'),
        @('scripts/integration-smoke.ps1', 'Smoke/integration test hiện có.')
    ))
    Add-BodyText 'Lệnh build: mvn clean package'
    Add-BodyText 'URL local: http://localhost:8080/TechStore'
    Add-BodyText 'Các thông tin trong ngoặc vuông [Điền ...] phải được nhóm hoàn thiện trước khi nộp.'

    $tocSearch = $document.Content.Duplicate
    $tocSearch.Find.ClearFormatting()
    $tocSearch.Find.Text = '[[TECHSTORE_REPORT_TOC]]'
    if (-not $tocSearch.Find.Execute()) {
        throw 'Không tìm thấy marker mục lục.'
    }
    $tocStart = $tocSearch.Start
    $tocSearch.Text = ''
    $tocRange = $document.Range($tocStart, $tocStart)
    [void]$document.TablesOfContents.Add($tocRange, $true, 1, 3, $false, '',
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
