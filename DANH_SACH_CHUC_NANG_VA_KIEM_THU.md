# Danh sách chức năng, phi chức năng và checklist kiểm thử TechStore

Tài liệu được rà soát theo source code hiện tại ngày **30/09/2026**. Phạm vi là
ứng dụng Java Servlet MVC + JSP/JSTL, SQL Server, Tomcat 10.1 và thanh toán VNPay
sandbox trong project TechStore.

## 1. Cách sử dụng tài liệu

Ký hiệu độ ưu tiên:

- **P0**: luồng sống còn, lỗi có thể gây mất tiền, sai đơn, sai kho hoặc lộ dữ liệu.
- **P1**: chức năng chính cần đạt trước khi nộp hoặc phát hành.
- **P2**: giao diện, tương thích và trường hợp biên nên kiểm tra sau P0/P1.

Trạng thái khi thực hiện:

```text
[ ] Chưa chạy   [x] Đạt   [!] Không đạt   [-] Bị chặn/không áp dụng
```

Với mỗi ca không đạt, nên ghi thêm:

```text
Mã lỗi:
Môi trường/trình duyệt:
Dữ liệu đầu vào:
Kết quả thực tế:
Ảnh hoặc log đính kèm:
```

> Các ca cạnh tranh tồn kho, rollback, callback thanh toán và file upload độc hại
> chỉ chạy trên database/test environment có thể phục hồi. Không thử trên dữ liệu
> thật hoặc cổng thanh toán production.

## 2. Chuẩn bị môi trường và dữ liệu

### 2.1. Môi trường

- JDK 21.
- Tomcat 10.1.x.
- SQL Server có database `TechStore` và đủ các script nâng cấp.
- Biến môi trường database, mail và VNPay đã khai báo trong tiến trình Tomcat.
- URL mặc định: `http://localhost:8080/TechStore`.
- Trình duyệt nên có: Chrome, Edge và Firefox bản hiện hành.

### 2.2. Tài khoản và dữ liệu mẫu

Chuẩn bị riêng, không dùng dữ liệu thật:

| Dữ liệu | Yêu cầu |
|---|---|
| Khách A | `CUSTOMER`, `ACTIVE`, có địa chỉ mặc định |
| Khách B | `CUSTOMER`, `ACTIVE`, dùng để thử truy cập chéo dữ liệu |
| Khách bị khóa | `CUSTOMER`, `LOCKED` |
| Admin A | `ADMIN`, `ACTIVE` |
| Admin B | `ADMIN`, `ACTIVE`, dùng kiểm thử không tự khóa tài khoản |
| Sản phẩm thường | `ACTIVE`, có ít nhất 2 phiên bản và nhiều ảnh |
| Sản phẩm sắp hết | Phiên bản còn 1 sản phẩm |
| Sản phẩm hết hàng | Phiên bản có tồn kho 0 |
| Sản phẩm ẩn | Trạng thái `DRAFT` hoặc `INACTIVE` |
| Đơn COD | Có đơn ở từng trạng thái để kiểm tra chuyển trạng thái |
| Đơn VNPay | Có lần thanh toán `PENDING`, `SUCCESS` và `FAILED` |

### 2.3. Thứ tự chạy đề xuất

1. Smoke test hệ thống và trang công khai.
2. Đăng ký, đăng nhập, tài khoản và phân quyền.
3. Catalog, chi tiết, yêu thích và giỏ hàng.
4. Checkout COD, đơn hàng và tồn kho.
5. Quản trị catalog, sản phẩm, đơn hàng, người dùng và báo cáo.
6. VNPay sandbox.
7. Bảo mật, transaction, cạnh tranh dữ liệu.
8. Responsive, accessibility, hiệu năng và deploy sạch.

## 3. Chức năng hiện có

### 3.1. Hệ thống và trang công khai

- Trang chủ `/home`, danh mục nổi bật, sản phẩm mới và sản phẩm theo danh mục.
- Trang `/products` tìm kiếm, lọc danh mục, thương hiệu, khoảng giá; sắp xếp mới
  nhất, giá tăng và giá giảm; phân trang 12 sản phẩm.
- Trang `/product?slug=...` hiển thị ảnh, phiên bản, giá, giá gốc, giảm giá, tồn
  kho, mô tả, thông số kỹ thuật và sản phẩm liên quan.
- Header có tìm kiếm, danh mục, số lượng yêu thích, tổng số lượng trong giỏ và
  menu responsive.
- Trang `/health` kiểm tra ứng dụng và kết nối database.
- Trang lỗi riêng cho HTTP 403, 404 và 500.

### 3.2. Xác thực và tài khoản

- Đăng ký tài khoản khách hàng; email được chuẩn hóa chữ thường.
- Mật khẩu dài 8–72 ký tự và được băm bằng BCrypt cost 12.
- Đăng nhập tài khoản `ACTIVE`; từ chối sai mật khẩu hoặc tài khoản `LOCKED`.
- Đổi session ID sau đăng nhập và đổi mật khẩu.
- Chuyển admin thẳng đến `/admin`; khách hàng đến URL đã lưu hoặc `/home`.
- Đăng xuất bằng POST và hủy session.
- Xem/cập nhật họ tên, số điện thoại.
- Đổi mật khẩu bằng mật khẩu hiện tại; không cho dùng lại mật khẩu cũ.
- Quên mật khẩu qua email với thông báo chung không làm lộ email tồn tại.
- Token đặt lại mật khẩu ngẫu nhiên, chỉ lưu SHA-256, hết hạn sau 30 phút, dùng
  một lần; tối đa 3 yêu cầu/15 phút cho mỗi tài khoản.
- Thêm, sửa, xóa, chọn địa chỉ mặc định; mọi thao tác giới hạn theo chủ sở hữu.

### 3.3. Yêu thích và giỏ hàng

- Thêm/bỏ sản phẩm yêu thích; hiển thị số lượng ở header.
- Trang yêu thích có chọn phiên bản và thêm nhanh vào giỏ.
- Thêm phiên bản vào giỏ; gộp dòng khi cùng SKU.
- Cập nhật số lượng, xóa dòng, tính lại thành tiền và tổng tiền.
- Chặn số lượng không dương, vượt tồn kho, phiên bản ngừng bán hoặc sản phẩm ẩn.
- Chỉ có một giỏ `ACTIVE` cho mỗi người dùng.

### 3.4. Checkout, đơn hàng và thanh toán

- Checkout bắt buộc đăng nhập và giỏ không rỗng.
- Chọn địa chỉ đã lưu hoặc nhập địa chỉ mới.
- Chọn COD hoặc VNPay; tổng tiền được tính lại phía server.
- Token checkout dùng một lần để hạn chế đặt trùng do nhấn nút nhiều lần.
- Tạo đơn, chi tiết đơn snapshot, payment, lịch sử trạng thái và trừ tồn kho
  trong cùng transaction; giỏ chuyển thành `ORDERED`.
- Lịch sử đơn hàng có phân trang; chi tiết có tiến trình, sản phẩm, địa chỉ,
  tổng tiền, thanh toán và timeline.
- Khách chỉ xem và hủy đơn của mình; hủy yêu cầu lý do, hoàn kho đúng luồng.
- Không cho hủy đơn đã thanh toán hoặc đang có giao dịch VNPay `PENDING` chưa
  quá 20 phút.
- Thanh toán lại VNPay với đơn hợp lệ.
- VNPay Return URL và IPN xác minh HMAC-SHA512, terminal, số tiền, mã giao dịch;
  xử lý callback lặp theo hướng idempotent.

### 3.5. Quản trị

- Layout admin riêng, chỉ vai trò `ADMIN` truy cập được.
- Dashboard theo khoảng ngày: doanh thu đơn hoàn thành, số đơn, trạng thái đơn,
  doanh thu theo ngày, sản phẩm bán chạy, cảnh báo kho và khách mua nhiều.
- Xuất CSV UTF-8 tương thích Excel và chống CSV formula injection.
- Quản lý danh mục phân cấp và thương hiệu: thêm, sửa, ẩn/hiện, slug duy nhất.
- Quản lý sản phẩm: tìm kiếm, lọc trạng thái, phân trang, thêm và sửa; trạng thái
  `DRAFT`, `ACTIVE`, `INACTIVE`.
- Quản lý phiên bản: SKU, tên, màu, RAM, dung lượng, giá, giá gốc, tồn kho,
  đang bán/ngừng bán; SKU duy nhất.
- Quản lý ảnh: URL hoặc upload JPEG/PNG, chọn ảnh chính, liên kết phiên bản, thứ
  tự hiển thị, cập nhật metadata và xóa ảnh/file local.
- Quản lý thông số kỹ thuật: thêm, sửa, xóa, sắp xếp; không trùng tên trong cùng
  sản phẩm.
- Quản lý đơn: tìm theo mã/email/tên/điện thoại, lọc trạng thái/ngày, phân trang,
  xem chi tiết, payment và timeline; cập nhật đúng luồng trạng thái.
- Hủy đơn từ admin bắt buộc nhập lý do.
- Quản lý người dùng: tìm kiếm, lọc vai trò/trạng thái, phân trang, khóa/mở khóa;
  không cho admin tự khóa tài khoản đang dùng.

### 3.6. Ma trận URL và quyền truy cập

| Nhóm | URL chính | Chưa đăng nhập | Customer | Admin |
|---|---|---:|---:|---:|
| Cửa hàng | `/`, `/home`, `/products`, `/product` | Có | Có | Có |
| Xác thực | `/login`, `/register`, `/forgot-password`, `/reset-password` | Có | Có, nhưng login tự chuyển trang | Có, nhưng login tự chuyển admin |
| Yêu thích | `/favorites`, `/favorites/toggle` | Chuyển login | Có | Có |
| Giỏ và checkout | `/cart/*`, `/checkout` | Chuyển login | Có | Có |
| Đơn khách hàng | `/orders`, `/orders/detail`, `/orders/cancel` | Chuyển login | Chỉ dữ liệu của mình | Có thể xem chi tiết; trang admin nên dùng `/admin/orders` |
| Tài khoản | `/account/profile`, `/account/password`, `/account/addresses` | Chuyển login | Có | Có |
| Bắt đầu VNPay | `/payment/vnpay/start` | Chuyển login | Chỉ đơn của mình | Chỉ đơn hợp lệ theo quyền sở hữu |
| VNPay callback | `/payment/vnpay/return`, `/payment/vnpay/ipn` | Công khai, kiểm bằng chữ ký | Công khai, kiểm bằng chữ ký | Công khai, kiểm bằng chữ ký |
| Quản trị | `/admin`, `/admin/*` | Chuyển login | HTTP 403 | Có |
| Trạng thái | `/health` | Có | Có | Có |

## 4. Phi chức năng hiện có

### 4.1. Kiến trúc và khả năng bảo trì

- MVC tách Servlet Controller, Service, DAO/JPA Entity, Filter và JSP.
- JSP nằm trong `WEB-INF/views`, không truy cập trực tiếp từ trình duyệt.
- Cấu hình nhạy cảm được đọc từ biến môi trường, không lưu mật khẩu thật trong
  source.
- Hibernate dùng `hbm2ddl.auto=validate`, không tự ý thay đổi schema.
- UTF-8 được áp dụng cho request, response, JSP, source và CSV.

### 4.2. Bảo mật

- Session timeout 30 phút, cookie `HttpOnly`, chỉ theo dõi session bằng cookie.
- CSRF token cho POST/PUT/PATCH/DELETE; callback VNPay được miễn CSRF nhưng bắt
  buộc chữ ký hợp lệ.
- Phân tách authentication và authorization admin.
- Bảo vệ quyền sở hữu địa chỉ, đơn hàng và thanh toán lại.
- Đổi session ID sau đăng nhập/đổi mật khẩu để giảm session fixation.
- Header `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY` và
  `Referrer-Policy: strict-origin-when-cross-origin`.
- Validation email, số điện thoại Việt Nam, độ dài chuỗi, số lượng, giá, tồn kho,
  trạng thái, slug và URL ảnh.
- Upload kiểm tra MIME lẫn nội dung ảnh thật; tối đa 5 MB, cạnh tối đa 6000 px và
  tối đa 25 triệu pixel; tên file được tạo ngẫu nhiên.
- VNPay đối chiếu chữ ký, terminal, số tiền, transaction ID và chống callback
  trùng.

### 4.3. Toàn vẹn và độ tin cậy dữ liệu

- Unique constraint/index cho email, slug, SKU, token reset, mã giao dịch và một
  giỏ active/người dùng.
- Check constraint cho trạng thái, số tiền, số lượng, tồn kho và công thức tổng.
- Đặt/hủy/cập nhật đơn và xử lý thanh toán dùng transaction.
- Khóa bi quan khi trừ/hoàn tồn kho, chuyển trạng thái và xử lý payment.
- `OrderItems` lưu snapshot sản phẩm để đơn cũ không thay đổi khi catalog đổi.
- Trang và dữ liệu có trạng thái rỗng; lỗi 403/404/500 có trang riêng.

### 4.4. UI/UX và accessibility

- Responsive cho desktop, tablet và mobile; menu/drawer riêng trên mobile.
- Font Be Vietnam Pro cùng font hệ thống dự phòng; văn bản UTF-8.
- Focus ring, skip link, alt ảnh, tên truy cập cho nút icon và thông báo live.
- Drawer dùng `inert`, giữ focus, đóng bằng `Escape` và trả focus về nút mở.
- Hỗ trợ `prefers-reduced-motion`; control chính có vùng bấm khoảng 44 px.
- Trạng thái có nhãn chữ/icon, không chỉ phụ thuộc màu sắc.

### 4.5. Khoảng trống production đang biết

Các mục dưới đây **chưa được xem là đã hoàn thiện**:

- Chưa cấu hình HTTPS, cookie `Secure` và `SameSite` trong project.
- Chưa có Content-Security-Policy và HSTS.
- Chưa có rate limit chung cho đăng nhập; chỉ quên mật khẩu có giới hạn theo tài khoản.
- Chưa có logging tập trung, xoay vòng log, monitoring và cảnh báo production.
- Chưa có lịch backup/restore SQL Server được tự động hóa.
- Ảnh upload đang nằm trong thư mục deploy Tomcat, có thể mất khi redeploy.
- Chưa có SLA/benchmark hiệu năng chính thức và bộ kiểm thử tải tự động.
- Chưa có email xác nhận đơn/trạng thái, hóa đơn in, đổi trả/hoàn tiền hoàn chỉnh,
  đánh giá sản phẩm, audit log hay quản lý banner.
- Mã giảm giá/khuyến mãi chủ động chưa nằm trong phạm vi hiện tại.

### 4.6. Điểm rủi ro cần ưu tiên khi kiểm thử

Đây là các điểm thấy trực tiếp khi rà source, chưa khẳng định là lỗi cho đến khi
chạy test:

- `GET /payment/vnpay/start` chưa được tách nhánh từ chối rõ trong `doGet`; ưu
  tiên chạy PAY-12.
- Một số tham số số được parse trực tiếp, ví dụ page lịch sử đơn hoặc ID form
  admin; request sửa thủ công có thể đi tới trang 500. Chạy SEC-09 và ghi defect
  nếu ứng dụng không trả 400/thông báo validation.
- Danh sách admin sản phẩm và người dùng hiện lấy danh sách rồi lọc/phân trang
  trong Java. Dữ liệu nhỏ ổn nhưng cần chạy PERF-04 với dữ liệu lớn.
- Ảnh upload nằm trong webapp deploy, vì vậy cần chạy OPS-04 trước khi xem hệ
  thống là sẵn sàng production.
- Chưa có rate limit đăng nhập, CSP, HSTS, cookie Secure/SameSite và quy trình
  hoàn tiền. Đây là risk đã biết, không nên ghi Pass chỉ vì luồng demo hoạt động.

## 5. Checklist kiểm thử chức năng

### 5.1. Hệ thống và điều hướng

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | SYS-01 | P1 | Mở `/` và `/home`. | Vào được trang chủ, HTTP 200, không lỗi font/ảnh. |
| [ ] | SYS-02 | P0 | Mở `/health` khi SQL Server hoạt động. | Báo ứng dụng và database hoạt động. |
| [ ] | SYS-03 | P1 | Tắt database rồi mở `/health` và `/home`, sau đó bật lại. | Health báo lỗi có kiểm soát; trang không lộ stack trace/mật khẩu. |
| [ ] | SYS-04 | P1 | Mở URL không tồn tại. | HTTP 404 và trang lỗi đúng layout. |
| [ ] | SYS-05 | P1 | Mở trực tiếp `/WEB-INF/views/home.jsp`. | Không truy cập trực tiếp được JSP. |
| [ ] | SYS-06 | P2 | Đi qua logo, header, menu danh mục, footer, Back/Forward. | URL, trạng thái menu và lịch sử trình duyệt đúng. |

### 5.2. Đăng ký, đăng nhập và session

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | AUTH-01 | P0 | Đăng ký với dữ liệu hợp lệ. | Tạo `CUSTOMER/ACTIVE`, mật khẩu không lưu dạng rõ, chuyển đến đăng nhập. |
| [ ] | AUTH-02 | P1 | Nhập email có chữ hoa và khoảng trắng. | Email được trim, lưu chữ thường và đăng nhập được. |
| [ ] | AUTH-03 | P1 | Thử email sai định dạng và email dài quá giới hạn. | Hiển thị lỗi, không tạo user. |
| [ ] | AUTH-04 | P0 | Đăng ký lại email đã tồn tại, kể cả khác hoa/thường. | Bị từ chối, không tạo bản ghi trùng. |
| [ ] | AUTH-05 | P1 | Thử họ tên rỗng và dài hơn 150 ký tự. | Bị từ chối, giữ dữ liệu form hợp lý. |
| [ ] | AUTH-06 | P1 | Thử số điện thoại `090...`, định dạng `+84`, có dấu cách/gạch và số sai. | Chuẩn hóa số hợp lệ; từ chối số không đủ 10 chữ số/bắt đầu sai. |
| [ ] | AUTH-07 | P0 | Thử mật khẩu 7, 8, 72, 73 ký tự và xác nhận không khớp. | Chỉ 8–72 ký tự và xác nhận đúng được chấp nhận. |
| [ ] | AUTH-08 | P0 | Đăng nhập đúng/sai mật khẩu và email không tồn tại. | Đúng thì tạo session; sai dùng thông báo chung, không lộ nguyên nhân. |
| [ ] | AUTH-09 | P0 | Khóa user rồi thử đăng nhập. | Không đăng nhập được. |
| [ ] | AUTH-10 | P1 | Mở `/cart` khi chưa đăng nhập, sau đó đăng nhập. | Chuyển về `/cart`; không mất query string ở URL đã lưu. |
| [ ] | AUTH-11 | P0 | Đăng nhập admin từ trang login bình thường. | Chuyển thẳng đến `/admin`. |
| [ ] | AUTH-12 | P0 | Khách cố mở `/admin`; người chưa login mở `/admin`. | Khách nhận 403; người chưa login chuyển login rồi về admin nếu đăng nhập admin. |
| [ ] | AUTH-13 | P0 | Ghi nhận JSESSIONID trước/sau đăng nhập. | Session ID thay đổi sau đăng nhập. |
| [ ] | AUTH-14 | P0 | Đăng xuất rồi dùng Back hoặc URL bảo vệ. | Session hết hiệu lực, quay về login; logout GET không thực hiện được. |
| [ ] | AUTH-15 | P1 | Không thao tác 30 phút rồi truy cập trang bảo vệ. | Session hết hạn và yêu cầu đăng nhập lại. |

### 5.3. Quên và đặt lại mật khẩu

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | RESET-01 | P1 | Gửi email tồn tại, không tồn tại và sai định dạng. | Giao diện luôn trả cùng thông báo chung. |
| [ ] | RESET-02 | P0 | Kiểm tra email reset của tài khoản active. | Link dùng đúng `app.url`, có token; database chỉ lưu hash, không lưu token thô. |
| [ ] | RESET-03 | P0 | Dùng token hợp lệ đổi mật khẩu 8–72 ký tự. | Đổi thành công; mật khẩu cũ thất bại, mật khẩu mới đăng nhập được. |
| [ ] | RESET-04 | P0 | Dùng lại token đã dùng. | Bị từ chối. |
| [ ] | RESET-05 | P0 | Dùng token sai, rỗng, quá 200 ký tự hoặc token quá 30 phút. | Bị từ chối bằng thông báo an toàn. |
| [ ] | RESET-06 | P1 | Yêu cầu link mới khi link cũ còn hiệu lực. | Token active cũ bị thay thế/không còn dùng được. |
| [ ] | RESET-07 | P1 | Gửi 4 lần trong 15 phút cho cùng tài khoản. | Tối đa 3 yêu cầu được tạo/gửi; phản hồi không lộ việc bị giới hạn. |
| [ ] | RESET-08 | P1 | Gỡ cấu hình mail và thử gửi. | Không lộ mật khẩu/stack trace ra UI; token thất bại được vô hiệu hóa. |

### 5.4. Trang chủ, catalog và chi tiết sản phẩm

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | CAT-01 | P1 | Mở trang chủ với dữ liệu mẫu. | Hiển thị tối đa 8 sản phẩm mới và tối đa 4 sản phẩm mỗi danh mục có dữ liệu. |
| [ ] | CAT-02 | P1 | Tìm theo tên/từ khóa tiếng Việt, hoa/thường và từ không tồn tại. | Kết quả đúng; trường hợp rỗng có thông báo phù hợp. |
| [ ] | CAT-03 | P1 | Lọc riêng và kết hợp danh mục, hãng, giá min/max. | Chỉ hiện sản phẩm phù hợp và giữ filter trong URL. |
| [ ] | CAT-04 | P1 | Nhập giá âm, min lớn hơn max, chuỗi thay cho số. | Không lỗi 500; báo dữ liệu lọc không hợp lệ. |
| [ ] | CAT-05 | P1 | Sắp xếp mới nhất, giá tăng, giá giảm trên nhiều trang. | Thứ tự đúng và không mất filter khi đổi trang. |
| [ ] | CAT-06 | P1 | Thử page 0, âm, rất lớn và không phải số. | Chuẩn hóa hoặc hiển thị an toàn, không lỗi 500. |
| [ ] | CAT-07 | P1 | Mở chi tiết sản phẩm active bằng slug hợp lệ. | Ảnh, phiên bản, giá, tồn, mô tả, thông số và liên quan đúng. |
| [ ] | CAT-08 | P0 | Mở slug sai, sản phẩm `DRAFT/INACTIVE`. | HTTP 404; sản phẩm ẩn không xuất hiện trong catalog. |
| [ ] | CAT-09 | P1 | Chọn từng phiên bản. | Giá, giá gốc, giảm giá, tồn kho và ảnh đổi đúng. |
| [ ] | CAT-10 | P1 | Sản phẩm không ảnh/không thông số/không biến thể khả dụng. | Có placeholder/trạng thái rỗng; nút mua bị vô hiệu đúng. |
| [ ] | CAT-11 | P1 | Phiên bản tồn kho 0 hoặc ngừng bán. | Không thể thêm vào giỏ dù sửa request thủ công. |
| [ ] | CAT-12 | P2 | Kiểm tra ký tự HTML/script trong tên/mô tả dữ liệu test. | Nội dung được escape, script không chạy. |

### 5.5. Yêu thích

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | FAV-01 | P1 | Chưa đăng nhập bấm yêu thích. | Chuyển đến login. |
| [ ] | FAV-02 | P1 | Thêm một sản phẩm từ card/chi tiết. | Có đúng một dòng favorite; icon/count/header cập nhật. |
| [ ] | FAV-03 | P1 | Bấm lại cùng sản phẩm. | Bỏ yêu thích, không có bản ghi trùng. |
| [ ] | FAV-04 | P1 | Trang yêu thích rỗng và có nhiều sản phẩm. | Empty state/card hiển thị đúng. |
| [ ] | FAV-05 | P0 | Sửa `productId` không tồn tại hoặc gửi favorite của user khác. | Không lỗi dữ liệu, không tác động tài khoản khác. |

### 5.6. Giỏ hàng

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | CART-01 | P1 | Thêm một phiên bản với số lượng hợp lệ. | Tạo giỏ active/dòng giỏ, count header và tổng tiền đúng. |
| [ ] | CART-02 | P1 | Thêm lại cùng SKU nhiều lần. | Gộp một dòng và cộng số lượng. |
| [ ] | CART-03 | P0 | Thêm/cập nhật số lượng 0, âm, chữ, vượt tồn kho. | Bị từ chối; dữ liệu cũ không đổi. |
| [ ] | CART-04 | P0 | Thêm biến thể inactive, sản phẩm inactive hoặc ID không tồn tại. | Bị từ chối phía server. |
| [ ] | CART-05 | P1 | Cập nhật tăng/giảm số lượng bằng nút và nhập trực tiếp. | Thành tiền dòng/tổng dự kiến cập nhật; phải lưu trước checkout. |
| [ ] | CART-06 | P1 | Xóa một dòng và dòng cuối cùng. | Dòng bị xóa; giỏ rỗng có empty state. |
| [ ] | CART-07 | P0 | Khách A sửa request với variant trong giỏ Khách B. | Giỏ B không thay đổi. |
| [ ] | CART-08 | P0 | Admin giảm tồn kho dưới số lượng đang nằm trong giỏ rồi checkout. | Checkout chặn và không tạo đơn/trừ kho. |
| [ ] | CART-09 | P1 | Đổi giá sản phẩm sau khi đã thêm giỏ. | Giỏ/checkout dùng giá server hiện hành; không tin giá gửi từ client. |
| [ ] | CART-10 | P1 | Đặt hàng xong rồi mở giỏ. | Giỏ cũ thành `ORDERED`, giỏ active mới/rỗng được dùng. |

### 5.7. Hồ sơ và địa chỉ

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | ACC-01 | P1 | Sửa họ tên và số điện thoại hợp lệ. | Database và tên trên header/session cập nhật. |
| [ ] | ACC-02 | P1 | Họ tên rỗng/quá 150 và điện thoại sai. | Bị từ chối, không ghi dữ liệu lỗi. |
| [ ] | ACC-03 | P0 | Đổi mật khẩu với mật khẩu hiện tại đúng. | Thành công, session ID đổi, đăng nhập bằng mật khẩu mới được. |
| [ ] | ACC-04 | P0 | Mật khẩu hiện tại sai, mật khẩu mới trùng cũ, xác nhận sai, dài 7/73. | Bị từ chối đúng lý do, hash không đổi. |
| [ ] | ADDR-01 | P1 | Thêm địa chỉ đủ trường và điện thoại hợp lệ. | Địa chỉ được lưu cho đúng user. |
| [ ] | ADDR-02 | P1 | Bỏ trống từng trường, vượt giới hạn và điện thoại sai. | Hiển thị validation, không tạo dữ liệu rác. |
| [ ] | ADDR-03 | P1 | Sửa rồi xóa địa chỉ của chính mình. | Thay đổi đúng; danh sách và checkout cập nhật. |
| [ ] | ADDR-04 | P1 | Đặt địa chỉ mặc định lần lượt cho hai địa chỉ. | Mỗi user chỉ có tối đa một địa chỉ mặc định. |
| [ ] | ADDR-05 | P0 | Khách A sửa/xóa/default địa chỉ của Khách B bằng ID thủ công. | Bị từ chối; dữ liệu B không đổi. |
| [ ] | ADDR-06 | P1 | Xóa địa chỉ mặc định rồi mở checkout. | Không lỗi; chọn địa chỉ còn lại hoặc form nhập mới. |

### 5.8. Checkout COD và tạo đơn

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | CHK-01 | P0 | Mở checkout khi chưa đăng nhập hoặc giỏ rỗng. | Chuyển login hoặc giỏ với thông báo phù hợp. |
| [ ] | CHK-02 | P1 | Có địa chỉ mặc định rồi mở checkout. | Tự chọn địa chỉ mặc định; nếu không có chọn địa chỉ đầu tiên/form mới. |
| [ ] | CHK-03 | P0 | Chèn `addressId` của Khách B. | Server bỏ/từ chối ID, không dùng địa chỉ B. |
| [ ] | CHK-04 | P1 | Đặt COD bằng địa chỉ lưu hợp lệ. | Tạo đơn `PENDING`, payment COD `PENDING`, chuyển chi tiết đơn. |
| [ ] | CHK-05 | P1 | Đặt COD bằng địa chỉ nhập mới hợp lệ. | Snapshot người nhận/địa chỉ đúng; không bắt buộc lưu vào sổ địa chỉ. |
| [ ] | CHK-06 | P1 | Sai từng trường địa chỉ và ghi chú trên 500 ký tự. | Báo lỗi tại trường, không tạo đơn. |
| [ ] | CHK-07 | P0 | Gửi payment method ngoài `COD/VNPAY`. | Bị từ chối phía server. |
| [ ] | CHK-08 | P0 | Sửa HTML gửi giá, subtotal, discount hoặc shipping fee giả. | Tổng đơn vẫn do server tính; client không điều khiển được giá. |
| [ ] | CHK-09 | P0 | Nhấn submit hai lần/gửi lại cùng `checkoutToken`. | Chỉ tạo một đơn; lần sau báo yêu cầu hết hiệu lực. |
| [ ] | CHK-10 | P0 | Đặt hàng khi một SKU vừa hết kho. | Toàn transaction rollback: không đơn rác, không payment/history rác, kho không âm. |
| [ ] | CHK-11 | P0 | Đặt đơn nhiều SKU hợp lệ. | Từng line total, subtotal, total và số lượng kho đều chính xác. |
| [ ] | CHK-12 | P0 | Đối chiếu sau đặt đơn. | Có Order, OrderItems snapshot, Payment, history `PENDING`; cart thành `ORDERED`. |

### 5.9. Lịch sử, chi tiết và hủy đơn

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | ORD-01 | P1 | Mở lịch sử có trên 20 đơn và đổi trang. | Đúng user, mới trước, phân trang không trùng/mất đơn. |
| [ ] | ORD-02 | P1 | Mở chi tiết mã đơn hợp lệ/sai. | Hợp lệ hiển thị đầy đủ; sai trả 404. |
| [ ] | ORD-03 | P0 | Khách B mở mã đơn của Khách A. | HTTP 403, không lộ dữ liệu đơn. |
| [ ] | ORD-04 | P1 | Đối chiếu sản phẩm, snapshot SKU/giá/ảnh, tổng, địa chỉ, timeline. | Khớp dữ liệu tại lúc đặt hàng. |
| [ ] | ORD-05 | P0 | Khách hủy đơn `PENDING/CONFIRMED/PROCESSING` chưa thanh toán, có lý do. | Đơn `CANCELLED`, payment thất bại, lịch sử có lý do, kho hoàn đúng một lần. |
| [ ] | ORD-06 | P0 | Hủy không có lý do hoặc quá 500 ký tự. | Bị từ chối. |
| [ ] | ORD-07 | P0 | Hủy lại đơn đã hủy; hủy `SHIPPING/COMPLETED`. | Bị từ chối, kho không hoàn thêm. |
| [ ] | ORD-08 | P0 | Hủy đơn `PAID`. | Bị từ chối và hướng dẫn xử lý hoàn tiền. |
| [ ] | ORD-09 | P0 | Hủy đơn có VNPay pending mới dưới 20 phút và sau khi quá hạn. | Trước hạn bị chặn; sau hạn có thể hủy nếu trạng thái đơn cho phép. |
| [ ] | ORD-10 | P0 | Khách A gửi POST hủy `orderId` của B. | HTTP 403, đơn B không đổi. |

### 5.10. VNPay sandbox

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | PAY-01 | P0 | Gỡ `TMN_CODE/HASH_SECRET`, chọn VNPay. | Không tạo đơn và không tạo payment pending; báo thiếu cấu hình. |
| [ ] | PAY-02 | P0 | Cấu hình đúng và checkout VNPay. | Tạo đơn, redirect đúng sandbox, amount/order reference đúng. |
| [ ] | PAY-03 | P0 | Thanh toán sandbox thành công. | Chữ ký hợp lệ; payment `SUCCESS`, order payment `PAID`, có mã giao dịch. |
| [ ] | PAY-04 | P0 | Hủy/thất bại/hết hạn tại VNPay. | Payment `FAILED`, order payment phản ánh thất bại, trang kết quả rõ ràng. |
| [ ] | PAY-05 | P0 | Sửa một tham số Return/IPN sau khi ký. | Mã 97/Invalid Checksum; không cập nhật dữ liệu. |
| [ ] | PAY-06 | P0 | Callback đúng chữ ký nhưng sai terminal hoặc sai số tiền. | Bị từ chối; payment/order không thành công. |
| [ ] | PAY-07 | P0 | Gửi lại callback thành công y hệt nhiều lần. | Chỉ ghi nhận một lần; trả trạng thái đã xử lý, không nhân đôi giao dịch. |
| [ ] | PAY-08 | P0 | Dùng cùng provider transaction ID cho payment khác. | Bị từ chối do mã giao dịch đã dùng. |
| [ ] | PAY-09 | P0 | Callback đến sau khi đơn đã hủy. | Không chuyển đơn/payment sang thành công. |
| [ ] | PAY-10 | P1 | Thanh toán lại đơn chưa trả sau payment fail/hết 20 phút. | Tạo hoặc dùng attempt hợp lệ mới, reference duy nhất. |
| [ ] | PAY-11 | P0 | Khách B yêu cầu thanh toán lại đơn A; thử đơn paid/cancelled/completed. | Tất cả bị từ chối. |
| [ ] | PAY-12 | P1 | Gọi POST vào Return/IPN hoặc GET `/start`. | Trả method/status phù hợp; `/start` chỉ chấp nhận POST đã login. |
| [ ] | PAY-13 | P1 | Gửi tham số callback lặp key, key >100 hoặc value >1000. | Báo dữ liệu không hợp lệ, không lỗi 500. |
| [ ] | PAY-14 | P1 | Kiểm tra response IPN. | JSON hợp lệ, UTF-8, `Cache-Control: no-store`. |

### 5.11. Admin dashboard và báo cáo

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | RPT-01 | P1 | Mở dashboard mặc định. | Khoảng 30 ngày, KPI/biểu đồ/danh sách tải đúng. |
| [ ] | RPT-02 | P1 | Chọn khoảng ngày hợp lệ, cùng ngày, qua tháng/năm. | Dữ liệu đúng và đủ cả hai đầu ngày. |
| [ ] | RPT-03 | P1 | Ngày sai hoặc from sau to. | Báo lỗi và dùng khoảng dự phòng, không lỗi 500. |
| [ ] | RPT-04 | P0 | Đối chiếu doanh thu với SQL. | Chỉ đơn `COMPLETED` được tính doanh thu. |
| [ ] | RPT-05 | P1 | Đối chiếu số đơn/trạng thái, top sản phẩm, cảnh báo kho, top khách. | Khớp dữ liệu database và khoảng ngày. |
| [ ] | RPT-06 | P1 | Xuất CSV. | Tên file/ngày đúng, UTF-8 BOM, mở Excel không lỗi dấu. |
| [ ] | RPT-07 | P0 | Dữ liệu bắt đầu bằng `=`, `+`, `-`, `@` rồi xuất CSV. | Giá trị được thêm `'`, không chạy công thức khi mở Excel. |
| [ ] | RPT-08 | P1 | Xuất CSV với ngày rỗng/sai. | HTTP 400, không tải file lỗi. |

### 5.12. Admin catalog, sản phẩm và tài sản

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | ACAT-01 | P1 | Thêm/sửa danh mục gốc và con hợp lệ. | Lưu đúng quan hệ cha con và trạng thái. |
| [ ] | ACAT-02 | P1 | Slug trùng, sai format, tên/slug rỗng hoặc quá dài. | Bị từ chối, không có bản ghi trùng. |
| [ ] | ACAT-03 | P1 | Chọn chính danh mục làm cha. | Bị từ chối. |
| [ ] | ACAT-04 | P1 | Ẩn/hiện danh mục. | Header/filter/form admin phản ánh đúng; sản phẩm không bị xóa. |
| [ ] | ACAT-05 | P1 | Thêm/sửa/ẩn/hiện thương hiệu; thử slug trùng. | CRUD trạng thái đúng, slug duy nhất. |
| [ ] | APROD-01 | P1 | Tìm tên/slug, lọc `ACTIVE/DRAFT/INACTIVE`, đổi trang. | Kết quả/count/filter/pagination đúng và được giữ khi quay lại. |
| [ ] | APROD-02 | P1 | Thêm/sửa sản phẩm hợp lệ. | Lưu tên, slug, category, brand, mô tả, trạng thái đúng. |
| [ ] | APROD-03 | P1 | Slug sản phẩm trùng/sai; mô tả vượt 1.000/20.000 ký tự. | Bị từ chối phía server. |
| [ ] | APROD-04 | P1 | Chuyển sản phẩm giữa DRAFT/ACTIVE/INACTIVE. | Chỉ ACTIVE xuất hiện và mở được ở storefront. |
| [ ] | AVAR-01 | P1 | Thêm/sửa phiên bản đủ trường. | SKU, thuộc tính, giá, tồn, trạng thái lưu đúng. |
| [ ] | AVAR-02 | P0 | SKU trùng; giá/tồn âm; giá gốc thấp hơn giá bán. | Bị từ chối, dữ liệu cũ nguyên vẹn. |
| [ ] | AVAR-03 | P0 | Sửa `variantId` thuộc sản phẩm khác. | Bị từ chối/404; không chuyển dữ liệu chéo. |
| [ ] | AVAR-04 | P1 | Ngừng bán phiên bản đã có trong đơn cũ. | Storefront không bán nữa; snapshot đơn cũ vẫn đọc được. |
| [ ] | AIMG-01 | P1 | Thêm ảnh bằng URL HTTP/HTTPS và đường dẫn local hợp lệ. | Ảnh lưu/hiển thị đúng. |
| [ ] | AIMG-02 | P0 | URL `javascript:`, `file:`, chứa `..`, backslash hoặc host/schema sai. | Bị từ chối. |
| [ ] | AIMG-03 | P1 | Upload JPEG/PNG thật dưới 5 MB. | Tên ngẫu nhiên 32 ký tự, file và bản ghi được tạo. |
| [ ] | AIMG-04 | P0 | File giả đổi đuôi/MIME, GIF/PDF, >5 MB, >6000 px hoặc >25M pixel. | Bị từ chối, không để lại file/bản ghi rác. |
| [ ] | AIMG-05 | P1 | Vừa chọn URL vừa upload; không chọn gì. | Bị từ chối. |
| [ ] | AIMG-06 | P1 | Gán ảnh cho variant của sản phẩm khác. | Bị từ chối. |
| [ ] | AIMG-07 | P1 | Đổi ảnh chính/thứ tự; thử thứ tự âm. | Chỉ một ảnh chính đúng phạm vi; âm bị từ chối. |
| [ ] | AIMG-08 | P1 | Xóa ảnh upload local và ảnh URL. | Xóa bản ghi; file local tương ứng bị xóa, URL ngoài không tác động file hệ thống. |
| [ ] | ASPEC-01 | P1 | Thêm/sửa/xóa/sắp xếp thông số. | Chi tiết sản phẩm hiển thị đúng thứ tự. |
| [ ] | ASPEC-02 | P1 | Trùng tên trong cùng sản phẩm, rỗng/quá dài, sort âm. | Bị từ chối. |
| [ ] | ASPEC-03 | P0 | Sửa/xóa spec bằng ID thuộc sản phẩm khác. | Bị từ chối, dữ liệu không đổi. |

### 5.13. Admin đơn hàng và người dùng

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | AORD-01 | P1 | Tìm theo mã, email, tên, điện thoại; lọc trạng thái/ngày. | Kết quả và tổng số đúng. |
| [ ] | AORD-02 | P1 | From sau to, ngày/status sai, keyword >150. | Báo lỗi có kiểm soát, không lỗi 500. |
| [ ] | AORD-03 | P1 | Đổi trang, mở chi tiết rồi quay lại. | Giữ keyword/filter/ngày/page. |
| [ ] | AORD-04 | P1 | Kiểm tra chi tiết, payment, timeline, người cập nhật. | Dữ liệu đầy đủ và đúng nhãn tiếng Việt. |
| [ ] | AORD-05 | P0 | Chuyển đúng luồng `PENDING→CONFIRMED→PROCESSING→SHIPPING→COMPLETED`. | Mỗi bước tạo history; trạng thái cuối đúng. |
| [ ] | AORD-06 | P0 | Thử bỏ bước, lùi trạng thái, đổi đơn terminal. | Bị từ chối. |
| [ ] | AORD-07 | P0 | Chuyển COD sang `COMPLETED`. | Payment COD `SUCCESS`, `PaidAt` có giá trị, order payment `PAID`. |
| [ ] | AORD-08 | P0 | Hủy ở trạng thái cho phép, không nhập/nhập lý do >500. | Bắt buộc lý do hợp lệ, hoàn kho đúng một lần. |
| [ ] | AUSR-01 | P1 | Tìm tên/email/phone, lọc role/status, phân trang. | Kết quả đúng và giữ filter. |
| [ ] | AUSR-02 | P0 | Khóa customer rồi thử session mới/login. | Không đăng nhập mới được. |
| [ ] | AUSR-03 | P1 | Mở khóa rồi đăng nhập lại. | Đăng nhập được. |
| [ ] | AUSR-04 | P0 | Admin tự khóa chính mình. | Bị từ chối. |
| [ ] | AUSR-05 | P0 | Customer gửi POST trực tiếp tới admin users/orders/products. | HTTP 403, không có thay đổi dữ liệu. |

## 6. Checklist bảo mật và phi chức năng

### 6.1. CSRF, session, quyền và dữ liệu đầu vào

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | SEC-01 | P0 | Gửi mọi POST không có `_csrf`, token sai và token của session khác. | HTTP 403, không thay đổi dữ liệu. |
| [ ] | SEC-02 | P0 | Kiểm tra VNPay IPN không cần CSRF nhưng chữ ký sai. | Không bị CSRF chặn; bị chữ ký chặn. |
| [ ] | SEC-03 | P0 | Thử IDOR trên address, order, payment retry, variant/image/spec admin. | Không đọc/sửa/xóa dữ liệu ngoài quyền. |
| [ ] | SEC-04 | P0 | Thử URL savedUrl ngoài context hoặc `/admin` với customer. | Không open redirect, không vượt quyền. |
| [ ] | SEC-05 | P1 | Kiểm tra cookie bằng DevTools. | `HttpOnly`, timeout 30 phút, không dùng URL rewriting. |
| [ ] | SEC-06 | P1 | Kiểm tra response headers. | Có `nosniff`, `DENY`, Referrer-Policy trên trang động. |
| [ ] | SEC-07 | P0 | Nhập `<script>`, quote, HTML vào mọi trường text/tìm kiếm/ghi chú. | Không thực thi script; output được escape. |
| [ ] | SEC-08 | P0 | Thử payload SQL injection vào login/search/filter/ID. | Không bypass login, không lỗi SQL/lộ stack trace, không đổi dữ liệu ngoài ý muốn. |
| [ ] | SEC-09 | P1 | Thử request quá dài, số cực lớn, ID âm/null/chữ. | HTTP/thông báo hợp lý; không 500 hoặc treo. |
| [ ] | SEC-10 | P0 | Xem source/log/network khi dùng DB, mail, VNPay. | Không lộ password, hash secret, token reset hay connection credentials. |
| [ ] | SEC-11 | P1 | Kiểm tra cache trang Return VNPay và trang chứa dữ liệu nhạy cảm. | VNPay result/IPN có `no-store`; đánh giá bổ sung no-store cho trang tài khoản nếu cần. |
| [ ] | SEC-12 | P1 | Thử brute force login trong test. | Ghi nhận hiện chưa có rate limit chung; lập defect/risk nếu yêu cầu môn học có mục này. |

### 6.2. Database, transaction và cạnh tranh

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | DB-01 | P0 | Hai tài khoản cùng checkout SKU chỉ còn 1, gửi gần đồng thời. | Chỉ một đơn thành công; đơn kia báo hết kho; stock không âm. |
| [ ] | DB-02 | P0 | Cố ý gây lỗi giữa lúc tạo OrderItems/Payment trong môi trường test. | Rollback toàn bộ Order, items, payment, history và kho. |
| [ ] | DB-03 | P0 | Gửi hai request hủy cùng đơn gần đồng thời. | Chỉ một request hoàn kho; request còn lại thất bại. |
| [ ] | DB-04 | P0 | Gửi callback VNPay thành công đồng thời/lặp. | Một payment thành công, không trùng provider transaction. |
| [ ] | DB-05 | P0 | Hai request đặt địa chỉ mặc định gần đồng thời. | Mỗi user vẫn chỉ có một địa chỉ mặc định. |
| [ ] | DB-06 | P1 | Chạy lại các script upgrade đã áp dụng. | Script idempotent hoặc thông báo rõ; không phá schema/dữ liệu. |
| [ ] | DB-07 | P1 | Dừng SQL Server giữa request ghi dữ liệu. | Transaction rollback; UI báo lỗi an toàn; sau khi bật lại hệ thống phục hồi. |
| [ ] | DB-08 | P0 | Backup database test, thêm dữ liệu rồi restore. | Restore thành công, ứng dụng đọc lại được. |

Các truy vấn chỉ đọc để đối soát nhanh:

```sql
-- Không có tồn kho âm
SELECT * FROM ProductVariants WHERE StockQuantity < 0;

-- Mỗi người tối đa một giỏ ACTIVE
SELECT UserId, COUNT(*) AS ActiveCarts
FROM Carts WHERE Status = 'ACTIVE'
GROUP BY UserId HAVING COUNT(*) > 1;

-- Mỗi người tối đa một địa chỉ mặc định
SELECT UserId, COUNT(*) AS DefaultAddresses
FROM Addresses WHERE IsDefault = 1
GROUP BY UserId HAVING COUNT(*) > 1;

-- Kiểm tra tổng đơn và từng dòng
SELECT * FROM Orders
WHERE TotalAmount <> Subtotal + ShippingFee - DiscountAmount;

SELECT * FROM OrderItems
WHERE LineTotal <> UnitPrice * Quantity OR Quantity <= 0;

-- Không trùng mã giao dịch VNPay đã có giá trị
SELECT ProviderTransactionId, COUNT(*) AS DuplicateCount
FROM Payments
WHERE ProviderTransactionId IS NOT NULL
GROUP BY ProviderTransactionId HAVING COUNT(*) > 1;

-- Đơn phải có ít nhất một dòng và một bản ghi lịch sử
SELECT o.OrderId, o.OrderCode
FROM Orders o
WHERE NOT EXISTS (SELECT 1 FROM OrderItems i WHERE i.OrderId = o.OrderId)
   OR NOT EXISTS (SELECT 1 FROM OrderStatusHistory h WHERE h.OrderId = o.OrderId);
```

### 6.3. Responsive, trình duyệt và accessibility

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi |
|---|---|---|---|---|
| [ ] | UI-01 | P1 | Kiểm tra 1440, 1024, 768, 500 và 390 px trên mọi trang chính. | Không tràn ngang, che nội dung hoặc mất thao tác chính. |
| [ ] | UI-02 | P1 | Kiểm tra Chrome, Edge, Firefox. | Chức năng và layout nhất quán; form/date/details hoạt động. |
| [ ] | UI-03 | P1 | Dùng Tab/Shift+Tab/Enter/Space/Escape toàn bộ storefront. | Thứ tự focus hợp lý, focus luôn thấy, mọi thao tác làm được bằng bàn phím. |
| [ ] | UI-04 | P1 | Mở menu, bộ lọc mobile và sidebar admin bằng bàn phím. | Focus bị giữ trong drawer, `Escape` đóng, focus trở về nút mở. |
| [ ] | UI-05 | P1 | Dùng skip link ở storefront/admin. | Bỏ qua điều hướng và focus tới nội dung chính. |
| [ ] | UI-06 | P1 | Dùng screen reader kiểm tra form, ảnh, nút icon, alert và trạng thái. | Có label/tên truy cập/alt; thông báo lỗi/thành công được đọc. |
| [ ] | UI-07 | P2 | Bật `prefers-reduced-motion`. | Animation/transition được giảm đáng kể. |
| [ ] | UI-08 | P1 | Zoom trình duyệt 200% và tăng font hệ thống. | Nội dung vẫn đọc/thao tác được, không mất dữ liệu. |
| [ ] | UI-09 | P1 | Kiểm tra tương phản bằng Lighthouse/axe/DevTools. | Chữ, focus, badge và button đạt WCAG AA phù hợp. |
| [ ] | UI-10 | P2 | Kiểm tra trạng thái loading, empty, error, disabled, out-of-stock. | Không chỉ dùng màu; thông điệp và hành động tiếp theo rõ ràng. |
| [ ] | UI-11 | P1 | Nhập tiếng Việt ở tài khoản, địa chỉ, tìm kiếm, ghi chú, admin và CSV. | Không có chuỗi lỗi kiểu `Ã`, `Ä`, `â`; lưu/đọc UTF-8 đúng. |

### 6.4. Hiệu năng, ổn định và deploy

Project chưa có SLA chính thức. Có thể dùng các ngưỡng dưới đây làm mục tiêu học
tập ban đầu, không phải cam kết production:

| Đã chạy | Mã | Ưu tiên | Cách kiểm tra | Kết quả mong đợi đề xuất |
|---|---|---|---|---|
| [ ] | PERF-01 | P1 | Đo `/home`, `/products`, `/product`, `/cart` sau warm-up trên máy local. | Phần lớn request dưới 2 giây, không query/lỗi tăng bất thường. |
| [ ] | PERF-02 | P1 | 20 user đồng thời duyệt catalog 5 phút. | Không 5xx, không cạn connection, response ổn định. |
| [ ] | PERF-03 | P0 | 10 user đồng thời checkout SKU tồn kho thấp. | Đúng tính toàn vẹn kho như DB-01. |
| [ ] | PERF-04 | P1 | Catalog/admin có hàng nghìn sản phẩm/user/đơn. | Phân trang hoạt động; không tải toàn bộ gây chậm quá mức. Ghi chú: admin products/users hiện lọc trên danh sách lấy từ Service nên cần theo dõi RAM/thời gian. |
| [ ] | OPS-01 | P0 | Chạy `mvn clean package`. | Build thành công và tạo WAR. |
| [ ] | OPS-02 | P0 | Deploy WAR lên một Tomcat sạch, không dùng thư mục publish cũ của Eclipse. | Khởi động không lỗi, `/health` đạt, mọi asset/JSP tải được. |
| [ ] | OPS-03 | P1 | Restart Tomcat trong lúc có dữ liệu đã tạo. | Dữ liệu bền vững; session cũ hết hiệu lực hợp lý. |
| [ ] | OPS-04 | P1 | Redeploy sau khi đã upload ảnh. | Ghi nhận rủi ro ảnh local bị mất; chưa coi đạt production cho tới khi tách storage. |
| [ ] | OPS-05 | P0 | Kiểm tra môi trường production giả lập. | Không dùng `sa`; secret chỉ ở env; URL Return VNPay và app URL đúng domain HTTPS. |
| [ ] | OPS-06 | P1 | Xem log khi lỗi DB/mail/payment/upload. | Có đủ thông tin chẩn đoán nhưng không chứa password, token hay secret. |

## 7. Bộ kiểm thử tự động sẵn có

Khi Tomcat và SQL Server đang chạy, có thể chạy:

```powershell
./scripts/integration-smoke.ps1
```

Bộ script hiện có tự tạo và dọn dữ liệu test, bao phủ đăng ký, validation, đăng
nhập, CSRF, quyền admin, catalog, yêu thích, giỏ hàng, checkout COD, tổng tiền,
tồn kho, quyền sở hữu đơn, hủy đơn và CRUD danh mục/thương hiệu admin.

Có thể chỉ định môi trường khác:

```powershell
./scripts/integration-smoke.ps1 `
  -BaseUrl 'http://localhost:8080/TechStore' `
  -SqlServer 'localhost' `
  -Database 'TechStore'
```

Chỉ dùng `-KeepTestData` khi cần điều tra lỗi và nhớ dọn dữ liệu sau đó.

Những nhóm **chưa được script hiện tại bao phủ đầy đủ** và cần kiểm thử bổ sung:

- Hồ sơ, đổi mật khẩu, địa chỉ và email reset password.
- Toàn bộ VNPay sandbox/Return/IPN/idempotency.
- CRUD sản phẩm, biến thể, ảnh, thông số đầy đủ.
- Luồng trạng thái đơn hàng admin và báo cáo CSV.
- Race condition, rollback cưỡng bức, backup/restore.
- Accessibility, responsive, đa trình duyệt, tải và deploy sạch.

## 8. Tiêu chí kết thúc kiểm thử

Chỉ nên chốt phiên bản khi:

- 100% ca P0 đạt; không còn lỗi sai tiền, sai kho, sai quyền hoặc lộ secret.
- Ít nhất 95% ca P1 đạt; mọi lỗi P1 còn lại có quyết định xử lý rõ ràng.
- Không còn HTTP 500 ở luồng người dùng hợp lệ hoặc dữ liệu biên thông thường.
- Không có stock âm, đơn rỗng, tổng tiền sai, callback ghi nhận trùng hoặc IDOR.
- Build WAR, JSP compile, smoke test và deploy Tomcat sạch đều đạt.
- Có biên bản trình duyệt/màn hình đã kiểm tra và ảnh bằng chứng cho luồng P0.
- Database test đã được dọn, backup và thử restore thành công.
