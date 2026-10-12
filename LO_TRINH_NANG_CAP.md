# Lộ trình nâng cấp TechStore

## 1. Mục tiêu

TechStore hiện đã đáp ứng luồng bán hàng cơ bản bằng JSP/Servlet MVC:

```text
Xem sản phẩm -> Yêu thích/Giỏ hàng -> Checkout COD
    -> Theo dõi đơn hàng -> Admin xử lý đơn
```

Giai đoạn tiếp theo tập trung hoàn thiện trải nghiệm tài khoản, quản trị sản phẩm, đơn hàng, báo cáo, thanh toán trực tuyến và khả năng triển khai thực tế.

## 2. Thứ tự ưu tiên

| Giai đoạn | Nội dung | Mức ưu tiên |
|---|---|---|
| 1 | Hồ sơ, địa chỉ và khôi phục mật khẩu | Cao |
| 2 | Hoàn thiện quản trị sản phẩm | Cao |
| 3 | Nâng cấp quản lý đơn hàng | Cao |
| 4 | Báo cáo quản trị | Trung bình |
| 5 | Thanh toán trực tuyến | Trung bình |
| 6 | Kiểm thử, bảo mật và triển khai production | Cao trước khi phát hành |

## 3. Giai đoạn 1: tài khoản khách hàng

### 3.1. Hồ sơ cá nhân

- [x] Tạo trang `GET /account/profile` để hiển thị thông tin tài khoản.
- [x] Tạo chức năng `POST /account/profile` để cập nhật họ tên và số điện thoại.
- [x] Kiểm tra định dạng, độ dài dữ liệu ở phía server.
- [x] Không cho phép thay đổi email qua form hồ sơ.
- [x] Hiển thị thông báo thành công hoặc lỗi trên JSP.

### 3.2. Đổi mật khẩu

- [x] Yêu cầu nhập mật khẩu hiện tại.
- [x] Kiểm tra mật khẩu mới và xác nhận mật khẩu.
- [x] Mã hóa mật khẩu mới bằng BCrypt.
- [ ] Vô hiệu hóa session cũ nếu cần thiết.
- [x] Áp dụng CSRF cho form đổi mật khẩu.

### 3.3. Quản lý địa chỉ

- [x] Tạo trang `GET /account/addresses`.
- [x] Thêm địa chỉ nhận hàng.
- [x] Cập nhật địa chỉ.
- [x] Xóa địa chỉ nếu địa chỉ thuộc đúng người dùng.
- [x] Chọn một địa chỉ mặc định.
- [x] Khi đặt hàng, ưu tiên hiển thị địa chỉ mặc định.
- [x] Không cho người dùng sửa hoặc xóa địa chỉ của tài khoản khác.

Database hiện đã có bảng `Addresses`, cần rà soát các cột tối thiểu:

- `AddressID`.
- `UserID`.
- `RecipientName`.
- `Phone`.
- `AddressLine`.
- `Ward`.
- `District`.
- `Province`.
- `IsDefault`.
- `CreatedAt`, `UpdatedAt` nếu cần theo dõi thời gian.

### 3.4. Quên mật khẩu qua email

- [x] Tạo trang nhập email tại `GET /forgot-password`.
- [x] Tạo token ngẫu nhiên, đủ mạnh và chỉ sử dụng một lần.
- [x] Chỉ lưu hash của token trong database.
- [x] Thiết lập thời gian hết hạn token là 30 phút.
- [x] Tạo chức năng gửi đường dẫn đặt lại mật khẩu qua email.
- [x] Tạo trang `GET /reset-password?token=...`.
- [x] Cập nhật mật khẩu bằng `POST /reset-password`.
- [x] Đánh dấu token đã sử dụng sau khi đổi mật khẩu thành công.
- [x] Luôn hiển thị thông báo chung để tránh lộ email có tồn tại hay không.
- [x] Giới hạn tối đa 3 yêu cầu trong 15 phút cho mỗi tài khoản.

Cần bổ sung bảng `PasswordResetTokens` nếu database chưa có:

```text
PasswordResetTokenID
UserID
TokenHash
ExpiresAt
UsedAt
CreatedAt
```

## 4. Giai đoạn 2: hoàn thiện quản trị sản phẩm

### 4.1. Phiên bản sản phẩm

- [x] Cho phép sửa phiên bản sản phẩm.
- [x] Cho phép ngừng bán phiên bản thay vì xóa khi đã phát sinh đơn hàng.
- [x] Quản lý tên phiên bản, màu sắc, dung lượng, SKU, giá và tồn kho.
- [x] Không cho phép SKU trùng.
- [x] Cảnh báo khi số lượng tồn kho thấp.
- [x] Ghi nhận thời điểm cập nhật tồn kho.

### 4.2. Hình ảnh sản phẩm

- [x] Upload JPEG/PNG và kiểm tra nội dung file thật.
- [x] Giới hạn kích thước file, kích thước ảnh và số pixel.
- [x] Đặt tên file ngẫu nhiên để tránh trùng tên.
- [x] Chọn ảnh đại diện cho sản phẩm hoặc từng phiên bản.
- [x] Sắp xếp thứ tự hiển thị ảnh.
- [x] Xóa file vật lý khi bản ghi ảnh bị xóa qua trang quản trị.
- [ ] Di chuyển nơi lưu ảnh ra ngoài thư mục deploy của Tomcat.
- [ ] Cân nhắc Cloudinary, S3 hoặc thư mục dữ liệu riêng khi triển khai production.

### 4.3. Thông số và trạng thái sản phẩm

- [x] Cải thiện giao diện thêm/sửa/xóa thông số kỹ thuật.
- [x] Không cho tạo hai thông số trùng tên trong cùng một sản phẩm.
- [x] Cho phép sắp xếp thứ tự thông số.
- [x] Dùng trạng thái để ẩn/ngừng bán sản phẩm thay vì xóa dữ liệu đã được đặt hàng.

## 5. Giai đoạn 3: nâng cấp quản lý đơn hàng

### 5.1. Trang quản trị đơn hàng

- [x] Tìm kiếm theo mã đơn hàng.
- [x] Tìm kiếm theo email, tên hoặc số điện thoại khách hàng.
- [x] Lọc theo trạng thái và khoảng ngày.
- [x] Phân trang danh sách đơn hàng.
- [x] Hiển thị timeline lịch sử trạng thái.
- [x] Cho admin nhập ghi chú khi cập nhật trạng thái.
- [x] Yêu cầu lý do khi hủy đơn.
- [x] Không cho chuyển trạng thái sai luồng.

Luồng trạng thái dự kiến:

```text
PENDING -> CONFIRMED -> PROCESSING -> SHIPPING -> COMPLETED
    \-----------> CANCELLED <-------------------/
```

### 5.2. Thông báo và chứng từ

- [ ] Gửi email xác nhận khi đặt hàng thành công.
- [ ] Gửi email khi trạng thái đơn hàng thay đổi.
- [ ] Tạo trang in đơn hàng hoặc hóa đơn.
- [ ] Bảo đảm chỉ chủ sở hữu hoặc admin được xem hóa đơn.

### 5.3. Đổi trả và hoàn tiền

- [ ] Thiết kế trạng thái yêu cầu đổi trả.
- [ ] Cho khách nhập lý do và gửi yêu cầu.
- [ ] Cho admin duyệt hoặc từ chối yêu cầu.
- [ ] Hoàn lại tồn kho đúng một lần khi yêu cầu được chấp nhận.
- [ ] Lưu lịch sử xử lý và người thực hiện.

## 6. Giai đoạn 4: báo cáo quản trị

- [x] Tổng doanh thu theo ngày và khoảng thời gian tùy chọn (có thể chọn trọn tháng).
- [x] Số lượng đơn theo từng trạng thái.
- [x] Sản phẩm bán chạy.
- [x] Sản phẩm có tồn kho thấp.
- [x] Sản phẩm đã hết hàng.
- [x] Khách hàng có tổng giá trị mua cao.
- [x] Hiển thị biểu đồ cơ bản trên dashboard.
- [x] Xuất báo cáo CSV tương thích Excel.
- [x] Chỉ tính doanh thu từ đơn ở trạng thái `COMPLETED`.

## 7. Giai đoạn 5: thanh toán trực tuyến

Triển khai sau khi luồng COD, tồn kho và rollback đã được kiểm thử ổn định.

- [x] Chọn VNPay làm cổng thanh toán ban đầu.
- [x] Tách URL sandbox/production bằng biến môi trường.
- [x] Không lưu khóa bí mật trong source code.
- [x] Tạo yêu cầu thanh toán từ tổng tiền do server tính.
- [x] Kiểm tra chữ ký HMAC-SHA512 của Return URL và IPN.
- [x] Đối chiếu mã giao dịch, số tiền và trạng thái giao dịch.
- [x] Chống xử lý callback trùng bằng mã giao dịch duy nhất và xử lý idempotent.
- [x] Cập nhật `Payments` và `Orders` trong cùng transaction.
- [x] Xử lý giao dịch thất bại, bị hủy hoặc hết hạn.
- [x] Tạo trang kết quả thanh toán thành công/thất bại và chức năng thanh toán lại.
- [x] Cung cấp IPN phía server, không tin dữ liệu chưa xác minh từ trình duyệt.

## 8. Giai đoạn 6: kiểm thử, bảo mật và triển khai

### 8.1. Kiểm thử bắt buộc

- [ ] Hai khách cùng mua phiên bản chỉ còn một sản phẩm.
- [ ] Cố ý tạo lỗi giữa transaction để kiểm tra rollback đơn hàng và tồn kho.
- [ ] Hủy đơn nhiều lần không được hoàn kho nhiều lần.
- [ ] Callback thanh toán gửi lặp không được ghi nhận thanh toán nhiều lần.
- [ ] Kiểm tra quyền sở hữu hồ sơ, địa chỉ, đơn hàng và hóa đơn.
- [ ] Kiểm tra CSRF trên mọi thao tác thay đổi dữ liệu.
- [ ] Kiểm tra giao diện desktop, tablet và mobile.
- [ ] Chạy lại Maven build, JSP compilation và bộ smoke test.

### 8.2. Cấu hình production

- [ ] Tách cấu hình development và production.
- [ ] Dùng tài khoản SQL Server có quyền vừa đủ thay cho `sa`.
- [ ] Bật HTTPS.
- [ ] Thiết lập `Secure`, `HttpOnly` và `SameSite` cho cookie.
- [ ] Không ghi mật khẩu, token hoặc khóa bí mật vào log.
- [ ] Cấu hình logging và xoay vòng log.
- [ ] Lập lịch backup SQL Server.
- [ ] Thử phục hồi database từ bản backup.
- [ ] Chuẩn bị cách tạo tài khoản admin an toàn.
- [ ] Build WAR và kiểm thử trên Tomcat sạch trước khi phát hành.

## 9. Kế hoạch thực hiện gần nhất

Thứ tự triển khai ở lần làm tiếp theo:

```text
Hồ sơ cá nhân
    -> Quản lý địa chỉ
    -> Đổi mật khẩu
    -> Quên mật khẩu qua email
    -> Kiểm thử toàn bộ tài khoản
    -> Hoàn thiện quản trị phiên bản và hình ảnh sản phẩm
    -> Nâng cấp quản lý đơn hàng
    -> Báo cáo admin
    -> Thanh toán online
    -> Kiểm thử và triển khai production
```

## 10. Tiêu chí hoàn thành đợt nâng cấp kế tiếp

Đợt nâng cấp tài khoản được xem là hoàn thành khi:

- Khách hàng xem và cập nhật được hồ sơ của chính mình.
- Khách hàng đổi mật khẩu bằng mật khẩu hiện tại.
- Khách hàng thêm, sửa, xóa và chọn địa chỉ mặc định.
- Checkout sử dụng được địa chỉ mặc định.
- Khách hàng nhận được email đặt lại mật khẩu.
- Token đặt lại mật khẩu hết hạn và không thể dùng lại.
- Người dùng không truy cập hoặc chỉnh sửa được dữ liệu của tài khoản khác.
- Tất cả form thay đổi dữ liệu đều được kiểm tra đầu vào và CSRF.
- Maven build, JSP compilation và kiểm thử luồng tài khoản đều thành công.
