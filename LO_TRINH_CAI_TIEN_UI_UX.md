# Lộ trình cải tiến UI/UX TechStore

## 1. Mục tiêu

Nâng cấp giao diện TechStore theo hướng rõ ràng, dễ mua hàng, sử dụng tốt trên
điện thoại và tách biệt hoàn toàn trải nghiệm khách hàng với khu vực quản trị.

Phạm vi của lộ trình này chỉ thay đổi giao diện và trải nghiệm sử dụng. Các luồng
nghiệp vụ, Servlet, Service và cơ sở dữ liệu đang hoạt động sẽ được giữ nguyên,
trừ trường hợp cần bổ sung dữ liệu để hiển thị như số lượng giỏ hàng hoặc ảnh sản
phẩm.

## 2. Định hướng kiến trúc giao diện

Ứng dụng vẫn triển khai trong cùng một project và cùng context `/TechStore`, nhưng
sử dụng hai layout độc lập:

```text
TechStore
├── Storefront layout
│   ├── Header mua hàng
│   ├── Thanh tìm kiếm và danh mục
│   ├── Nội dung trang khách hàng
│   └── Footer cửa hàng
└── Admin layout
    ├── Sidebar quản trị
    ├── Topbar quản trị
    ├── Nội dung dashboard/quản lý
    └── Không dùng footer của cửa hàng
```

URL dự kiến vẫn giữ rõ ràng:

- Khu vực khách hàng: `/home`, `/product`, `/cart`, `/checkout`, `/orders`,
  `/favorites`, `/account/*`.
- Khu vực quản trị: `/admin`, `/admin/products`, `/admin/orders`, `/admin/users`,
  `/admin/catalog`.

## 3. Thứ tự triển khai

### Giai đoạn UI 1: tách layout khách hàng và quản trị

- [x] Tạo `components/store-header.jsp` cho khu vực bán hàng.
- [x] Tạo `components/store-footer.jsp` cho khu vực bán hàng.
- [x] Tạo `components/admin-header.jsp` và `components/admin-footer.jsp`.
- [x] Tạo sidebar quản trị cố định trên desktop.
- [x] Tạo topbar quản trị gồm tiêu đề trang, tên admin và nút đăng xuất.
- [x] Thêm trạng thái active cho mục quản trị đang được mở.
- [x] Không hiển thị banner, footer cửa hàng hoặc menu mua sắm trong trang admin.
- [x] Tách CSS layout và component quản trị sang `assets/css/admin.css`.
- [x] Kiểm tra `AdminAuthorizationFilter` vẫn bảo vệ toàn bộ `/admin/*`.

Tiêu chí hoàn thành:

- Nhìn vào giao diện có thể nhận biết ngay đang ở cửa hàng hay trang quản trị.
- Admin chuyển giữa dashboard, sản phẩm, đơn hàng, người dùng và danh mục mà không
  phải quay lại khu vực bán hàng.
- Layout admin hoạt động được trên desktop, tablet và mobile.

Kết quả xác minh: JSP compilation hoàn tất với 0 lỗi; JavaScript của menu admin
đã vượt qua kiểm tra cú pháp.

### Giai đoạn UI 2: làm lại header và điều hướng cửa hàng

- [x] Đưa ô tìm kiếm sản phẩm lên header.
- [x] Hiển thị các danh mục chính: Điện thoại, Tablet, Laptop và Phụ kiện.
- [x] Thêm icon cho yêu thích, giỏ hàng và tài khoản.
- [x] Hiển thị số lượng sản phẩm trong giỏ hàng.
- [x] Hiển thị số lượng sản phẩm yêu thích.
- [x] Tạo menu hamburger và drawer cho màn hình dưới 960px.
- [x] Giữ đầy đủ menu thay thế trên mobile.
- [x] Bổ sung trạng thái active cho liên kết hiện tại.
- [x] Giữ đăng nhập/đăng ký dễ nhìn trong menu mobile.

Tiêu chí hoàn thành:

- Người dùng luôn truy cập được giỏ hàng và tài khoản trên mọi kích thước màn hình.
- Có thể tìm sản phẩm ngay từ bất kỳ trang khách hàng nào.
- Header không chiếm quá nhiều chiều cao trên điện thoại.

Kết quả xác minh: Java và toàn bộ JSP compile thành công; JavaScript menu mobile
đã vượt qua kiểm tra cú pháp.

### Giai đoạn UI 3: tổ chức lại trang chủ

- [x] Giảm chiều cao banner và thay số lượng sản phẩm bằng nội dung có giá trị.
- [x] Hiển thị chính sách nổi bật: hàng chính hãng, bảo hành, giao hàng và thanh toán
  an toàn.
- [x] Thêm khối danh mục nổi bật bằng icon SVG.
- [x] Chia sản phẩm thành các khu vực: sản phẩm mới, điện thoại, laptop, tablet và
  phụ kiện nổi bật.
- [x] Chỉ giữ tìm kiếm chính trên header của trang chủ.
- [x] Chuyển bộ lọc nâng cao sang trang `/products`.
- [x] Thêm nút “Xem tất cả” cho từng danh mục.
- [x] Hiển thị trạng thái rỗng có nút xóa bộ lọc hoặc quay lại danh sách.

Tiêu chí hoàn thành:

- Người dùng hiểu cửa hàng bán gì ngay trong màn hình đầu tiên.
- Người dùng có thể truy cập một danh mục bằng tối đa một thao tác từ trang chủ.
- Bộ lọc không lấn át nội dung sản phẩm.

Kết quả xác minh: Java và JSP compile với 0 lỗi; bốn danh mục đang hoạt động đều
có 10 sản phẩm để hiển thị; CSS và JavaScript vượt qua kiểm tra cú pháp cơ bản.

### Giai đoạn UI 4: nâng cấp danh sách và card sản phẩm

- [x] Cho phép nhấn vào ảnh, tên hoặc vùng nội dung chính của card để xem chi tiết.
- [x] Giữ nút yêu thích độc lập với liên kết chi tiết.
- [x] Hiển thị giá hiện tại, giá cũ và phần trăm giảm khi hợp lệ.
- [x] Hiển thị 2–3 thông số quan trọng tùy danh mục.
- [x] Thêm trạng thái đã yêu thích/chưa yêu thích rõ ràng.
- [x] Thêm `aria-label` cho các nút chỉ có icon.
- [x] Làm card đồng chiều cao và đặt giá/nút hành động ở vị trí nhất quán.
- [x] Tạo filter sidebar trên desktop và filter drawer trên mobile.
- [x] Hiển thị các bộ lọc đang áp dụng dưới dạng chip và có nút “Xóa tất cả”.
- [x] Giữ nguyên bộ lọc khi chuyển trang phân trang.

Tiêu chí hoàn thành:

- Người dùng so sánh nhanh được các sản phẩm cùng loại.
- Bộ lọc đang áp dụng luôn nhìn thấy và có thể xóa dễ dàng.
- Card không bị vỡ bố cục khi tên sản phẩm dài hoặc thiếu ảnh.

Kết quả xác minh: Java và toàn bộ JSP compile với 0 lỗi; JavaScript vượt qua
kiểm tra cú pháp; card dùng chung cho trang chủ, danh sách và yêu thích. Font đã
được chuẩn hóa sớm sang Be Vietnam Pro, kèm Segoe UI/Arial làm font dự phòng.
JSP fragment của card và cấu hình Jasper cũng được ép UTF-8; mã Java sinh ra đã
được quét và không còn chuỗi mojibake như `TÃ¹y chá»n` hay `chi tiáº¿t`.

### Giai đoạn UI 5: nâng cấp trang chi tiết sản phẩm

- [x] Thêm breadcrumb: Trang chủ → Danh mục → Sản phẩm.
- [x] Cho thumbnail thay đổi ảnh lớn khi nhấn.
- [x] Làm nổi bật phiên bản đang chọn bằng viền và màu nền.
- [x] Cập nhật giá, tồn kho và ảnh khi người dùng đổi phiên bản.
- [x] Giới hạn số lượng theo tồn kho của phiên bản được chọn.
- [x] Thêm hai hành động: “Mua ngay” và “Thêm vào giỏ hàng”.
- [x] Hiển thị chính sách bảo hành, giao hàng và thanh toán an toàn.
- [x] Trình bày mô tả dài thành các đoạn dễ đọc.
- [x] Tối ưu bảng thông số kỹ thuật trên mobile.
- [x] Thêm khu vực sản phẩm liên quan cùng danh mục hoặc thương hiệu.

Tiêu chí hoàn thành:

- Thay đổi phiên bản phản ánh đúng giá và tồn kho trên giao diện.
- Người dùng hiểu được sản phẩm, giá và chính sách trước khi thêm vào giỏ.
- Các hành động mua hàng luôn dễ nhìn nhưng không che nội dung.

Kết quả xác minh: Java và toàn bộ JSP compile với 0 lỗi; JavaScript hợp lệ;
Jasper sinh đúng chữ Việt UTF-8. Luồng “Mua ngay” thêm phiên bản vào giỏ rồi
chuyển tới checkout, còn service tiếp tục kiểm tra lại tồn kho ở phía server.

### Giai đoạn UI 6: cải thiện yêu thích và giỏ hàng

- [x] Dùng ảnh thật của sản phẩm trong giỏ hàng thay cho placeholder.
- [x] Trên mobile chuyển mỗi dòng giỏ hàng thành một card thay vì chỉ cuộn bảng ngang.
- [x] Dùng nút tăng/giảm số lượng bên cạnh ô số lượng.
- [x] Vô hiệu hóa tăng số lượng khi đạt giới hạn tồn kho.
- [x] Cập nhật thành tiền và tổng tiền rõ ràng sau khi thay đổi số lượng.
- [x] Đổi nút xóa màu đỏ lớn thành icon/nút phụ và vẫn yêu cầu xác nhận.
- [x] Thêm liên kết quay lại chi tiết sản phẩm.
- [x] Đồng bộ card yêu thích với card ở trang danh sách sản phẩm (đã làm sớm trong UI 4).
- [x] Thêm nút chuyển sản phẩm yêu thích vào giỏ nếu phiên bản đã được chọn.

Tiêu chí hoàn thành:

- Giỏ hàng sử dụng thuận tiện ở độ rộng 320px trở lên.
- Không thể nhập số lượng âm, bằng 0 hoặc vượt tồn kho.
- Tổng tiền và trạng thái giỏ hàng luôn dễ nhận biết.

Kết quả xác minh: Java và toàn bộ JSP compile với 0 lỗi; JavaScript hợp lệ;
Jasper sinh đúng chữ Việt UTF-8. Tổng tiền được xem trước ngay khi đổi số lượng,
nhưng checkout bị khóa cho tới khi người dùng lưu thay đổi để dữ liệu giao diện
không lệch với giỏ hàng trong SQL Server.

### Giai đoạn UI 7: cải thiện checkout và thanh toán

- [x] Thêm thanh tiến trình: Giỏ hàng → Giao hàng → Thanh toán → Hoàn tất.
- [x] Làm nổi bật địa chỉ đang được chọn.
- [x] Tách rõ địa chỉ đã lưu và form nhập địa chỉ mới.
- [x] Đánh dấu trường bắt buộc và hiển thị lỗi gần trường tương ứng.
- [x] Hiển thị ảnh nhỏ, phiên bản và số lượng trong phần tóm tắt đơn hàng.
- [x] Khi chọn COD, nút chính hiển thị “Đặt hàng COD”.
- [x] Khi chọn VNPay, nút chính hiển thị “Thanh toán qua VNPay”.
- [x] Hiển thị thông báo người dùng sẽ được chuyển sang VNPay.
- [x] Khóa nút submit sau lần nhấn đầu để hạn chế gửi form lặp.
- [x] Tạo trang kết quả thanh toán có thông tin ngắn gọn và hành động tiếp theo.

Tiêu chí hoàn thành:

- Người dùng biết mình đang ở bước nào và hành động tiếp theo là gì.
- Không tạo hai đơn do nhấn nút xác nhận liên tục.
- Checkout hoạt động rõ ràng trên desktop và mobile.

Kết quả xác minh: Java và toàn bộ JSP compile với 0 lỗi; JavaScript hợp lệ;
Jasper sinh đúng chữ Việt UTF-8. Ngoài việc khóa nút trên trình duyệt, checkout
còn dùng token một lần trong session để chặn hai request đồng thời tạo trùng đơn.
Ứng dụng kiểm tra cấu hình VNPay trước khi tiêu thụ token hoặc tạo đơn; khi thiếu
`TMN_CODE`/`HASH_SECRET`, lựa chọn VNPay bị vô hiệu hóa và người dùng vẫn có
thể đặt hàng COD mà không phát sinh thêm đơn hoặc giao dịch `PENDING`.

### Giai đoạn UI 8: lịch sử và chi tiết đơn hàng

- [x] Việt hóa trạng thái đơn hàng và trạng thái thanh toán.
- [x] Định dạng ngày giờ theo `dd/MM/yyyy HH:mm`.
- [x] Dùng màu và icon nhưng vẫn luôn có nhãn chữ cho trạng thái.
- [x] Trên mobile hiển thị danh sách đơn dạng card.
- [x] Hiển thị tiến trình đơn hàng theo thứ tự xử lý.
- [x] Làm rõ phương thức, trạng thái và lịch sử thanh toán.
- [x] Chỉ hiển thị nút hủy khi trạng thái thực sự cho phép.
- [x] Hiển thị lý do hủy và ghi chú trạng thái một cách dễ đọc.

Ánh xạ trạng thái hiển thị:

| Giá trị hệ thống | Nhãn tiếng Việt |
|---|---|
| `PENDING` | Chờ xác nhận |
| `CONFIRMED` | Đã xác nhận |
| `PROCESSING` | Đang chuẩn bị |
| `SHIPPING` | Đang giao |
| `COMPLETED` | Hoàn thành |
| `CANCELLED` | Đã hủy |
| `UNPAID` | Chưa thanh toán |
| `PAID` | Đã thanh toán |
| `FAILED` | Thanh toán thất bại |
| `REFUNDED` | Đã hoàn tiền |

Kết quả xác minh: Java và toàn bộ JSP compile với 0 lỗi; ngày giờ được chuẩn hóa
trước khi chuyển cho JSP. Điều kiện hủy trên giao diện đã đồng bộ với service,
bao gồm trường hợp đơn đã thanh toán và giao dịch VNPay còn trong 20 phút chờ.
Danh sách đơn dùng card responsive; trang chi tiết có tiến trình xử lý, ảnh sản
phẩm, tổng tiền, thông tin giao hàng, từng giao dịch và timeline ghi chú.

### Giai đoạn UI 9: hoàn thiện trải nghiệm admin

- [x] Sidebar admin có icon, nhãn và trạng thái active.
- [x] Dashboard ưu tiên số liệu quan trọng và cảnh báo cần xử lý.
- [x] Thêm liên kết nhanh từ cảnh báo tồn kho tới sản phẩm tương ứng.
- [x] Các bảng có header rõ, phân trang và trạng thái rỗng.
- [x] Trên mobile cho phép chuyển bảng thành card hoặc ẩn cột phụ hợp lý.
- [x] Không đặt form cập nhật đơn hàng quá lớn trực tiếp trong từng hàng bảng.
- [x] Chuyển thao tác cập nhật phức tạp sang trang chi tiết hoặc modal/drawer.
- [x] Các thao tác nguy hiểm phải có xác nhận và mô tả ảnh hưởng.
- [x] Hiển thị thông báo thành công/lỗi thống nhất sau thao tác.
- [x] Giữ bộ lọc khi admin quay lại từ trang chi tiết.

Tiêu chí hoàn thành:

- Admin nhận biết nhanh đơn cần xử lý, sản phẩm sắp hết và lỗi vận hành.
- Tác vụ thường dùng không cần cuộn ngang trên desktop.
- Không nhầm lẫn giữa hành động dành cho khách hàng và hành động quản trị.

Kết quả xác minh: dashboard có khu vực việc cần xử lý, chỉ số vận hành và liên
kết cảnh báo tồn kho tới đúng sản phẩm/phiên bản. Cập nhật đơn hàng đã được tách
khỏi bảng sang trang chi tiết admin, có giải thích và xác nhận cho thao tác hủy.
Danh sách đơn hàng, sản phẩm và người dùng có bộ lọc, phân trang, trạng thái rỗng
và chuyển thành card trên mobile. Bộ lọc đơn hàng/sản phẩm được giữ khi quay lại
từ trang chi tiết. Java, toàn bộ JSP và JavaScript compile/kiểm tra với 0 lỗi.

### Giai đoạn UI 10: tính nhất quán và accessibility

- [x] Đổi cách xưng hô trên giao diện từ “ông” sang “bạn” hoặc câu trung tính.
- [x] Chuẩn hóa font chữ; dùng Be Vietnam Pro có tải font thật và font hệ thống dự phòng.
- [x] Chuẩn hóa spacing, radius, shadow, font size và chiều cao control.
- [x] Giảm shadow không cần thiết, ưu tiên border nhẹ và khoảng trắng.
- [x] Bổ sung `:focus-visible` rõ ràng cho link, button, input và select.
- [x] Bảo đảm vùng bấm đủ lớn trên màn hình cảm ứng.
- [x] Kiểm tra tương phản chữ, đặc biệt `.eyebrow` trên nền trắng.
- [x] Không truyền tải trạng thái chỉ bằng màu sắc.
- [x] Bổ sung alt text có ý nghĩa cho ảnh sản phẩm.
- [x] Bổ sung label hoặc `aria-label` cho nút icon.
- [x] Hỗ trợ `prefers-reduced-motion`.
- [x] Kiểm tra điều hướng toàn bộ trang chỉ bằng bàn phím.

Kết quả xác minh: giao diện đã dùng chung thang khoảng cách 4px, radius 12px,
control chính cao 44px và shadow nhẹ; nhãn trạng thái luôn có nội dung chữ thay vì
chỉ dựa vào màu. Storefront và admin có liên kết bỏ qua điều hướng, focus ring rõ
ràng, alt ảnh sản phẩm và tên truy cập cho nút icon. Menu mobile, bộ lọc mobile và
sidebar admin dùng `inert`, giữ focus trong drawer, hỗ trợ phím `Escape` và trả
focus về nút mở. Chuyển động được giảm theo `prefers-reduced-motion`. Java, toàn
bộ JSP và JavaScript compile/kiểm tra với 0 lỗi; CSS cân bằng dấu ngoặc và không
phát hiện lỗi mã hóa tiếng Việt.

Tham khảo:

- WCAG 2.2: <https://www.w3.org/TR/wcag/>
- Baymard Product List UX: <https://baymard.com/research/ecommerce-product-lists>

## 4. Design system đề xuất

### 4.1. Màu sắc

```text
Background:       #F7F8FC
Surface:          #FFFFFF
Text chính:       #161827
Text phụ:         #667085
Primary:          #4F46E5
Primary hover:    #3730A3
Giá/khuyến cáo:   #D70018
Success:          #047857
Warning:          #B45309
Danger:           #B91C1C
Border:           #E5E7EB
```

### 4.2. Thành phần chung

- Border radius chính: 10–12px.
- Button và input cao tối thiểu khoảng 42–44px.
- Card dùng border nhẹ, shadow chỉ tăng khi hover hoặc cần phân lớp.
- Khoảng cách theo thang 4, 8, 12, 16, 24, 32 và 48px.
- Trạng thái tương tác gồm default, hover, active, focus, disabled và loading.

## 5. Thứ tự ưu tiên rút gọn

Nếu thời gian làm đồ án có hạn, thực hiện theo thứ tự sau:

1. Tách layout admin và cửa hàng.
2. Sửa header và menu mobile.
3. Tổ chức lại trang chủ và card sản phẩm.
4. Nâng cấp trang chi tiết sản phẩm.
5. Cải thiện giỏ hàng và checkout trên mobile.
6. Việt hóa trạng thái và định dạng ngày giờ.
7. Hoàn thiện trang admin.
8. Kiểm tra accessibility và tính nhất quán toàn site.

## 6. Gợi ý kiểm thử UI/UX cho nhóm

- Kiểm tra ở các độ rộng 320px, 375px, 768px, 1024px và 1440px.
- Kiểm tra zoom trình duyệt 200%.
- Dùng toàn bộ chức năng chỉ bằng bàn phím.
- Kiểm tra tên sản phẩm và tên khách hàng rất dài.
- Kiểm tra trạng thái thiếu ảnh, hết hàng, danh sách rỗng và lỗi server.
- Kiểm tra form với dữ liệu rỗng, sai định dạng và vượt độ dài.
- Kiểm tra double-click nút đặt hàng/thanh toán.
- Kiểm tra trạng thái focus, hover, disabled và loading.
- Kiểm tra màu sắc bằng công cụ contrast checker.
- Nhờ người chưa từng dùng hệ thống thực hiện luồng tìm sản phẩm → thêm giỏ →
  checkout và ghi lại nơi họ bị chậm hoặc bối rối.

## 7. Điều kiện hoàn thành

- Storefront và admin dùng hai layout riêng, không còn cảm giác là cùng một trang.
- Tất cả tính năng chính truy cập được trên mobile.
- Trạng thái và ngày giờ được trình bày bằng tiếng Việt dễ hiểu.
- Luồng mua hàng không có bước hoặc nút gây nhầm lẫn.
- Các trang chính hoạt động ở độ rộng từ 320px mà không mất chức năng.
- Giao diện có focus rõ ràng và có thể sử dụng bằng bàn phím.
- Java và JSP vẫn compile thành công sau khi thay đổi giao diện.
