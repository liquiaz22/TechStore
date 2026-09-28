# Kế hoạch triển khai website TechStore

## 1. Mục tiêu dự án

Xây dựng website bán điện thoại, iPad/tablet, laptop và phụ kiện với các chức năng:

- Đăng ký, đăng nhập và đăng xuất.
- Trang chủ.
- Danh sách, tìm kiếm và lọc sản phẩm.
- Chi tiết sản phẩm và lựa chọn phiên bản.
- Danh sách sản phẩm yêu thích.
- Giỏ hàng.
- Đặt hàng.
- Thanh toán.
- Lịch sử và chi tiết đơn hàng.
- Trang quản trị.

### Công nghệ

- Frontend: JSP/JSTL kết hợp HTML, CSS và JavaScript trong kiến trúc MVC.
- Backend: Java Servlet theo kiến trúc MVC, Maven, Tomcat.
- Database: Microsoft SQL Server và JDBC.
- Xác thực: `HttpSession`, mật khẩu được băm bằng BCrypt hoặc Argon2.

## 2. Trạng thái hiện tại

- [x] Đã tạo database `TechStore`.
- [x] Đã tạo các bảng chính trong `database/TechStore.sql`.
- [x] Đã rà soát và tạo `database/TechStore_upgrade_01.sql` để bổ sung constraint/index.
- [x] Đã tạo và chạy `database/TechStore_seed_tgdd_demo.sql`: 40 sản phẩm demo, mỗi danh mục 10 sản phẩm.
- [x] Đã tạo project Java Maven dạng WAR.
- [x] Hoàn thiện cấu trúc MVC gồm Entity, DAO, Service, Servlet/Filter và JSP.
- [x] Kết nối Java với SQL Server qua JPA đã chạy thành công trên Tomcat Eclipse.
- [x] Đã tạo bản giao diện JSP cho các module chính để kiểm thử luồng MVC.
- [x] Build WAR và deploy thử trên Tomcat 10.1.57.
- [x] Hoàn tất kiểm thử tích hợp các luồng JSP chính bằng bộ smoke test tự động 36/36.
- [x] Chốt tiếp tục dùng Servlet MVC + JSP/JSTL, không chuyển sang RESTful API.

### Mốc hiện tại — 28/09/2026

Dự án đã hoàn thành **phần kiểm thử các luồng JSP chính của Bước 14**. Bộ `scripts/integration-smoke.ps1` chạy đạt 36/36 kiểm tra trên Tomcat và SQL Server, gồm tài khoản, validation, CSRF, phân quyền, sản phẩm, yêu thích, giỏ hàng, checkout, đơn hàng, tồn kho và CRUD catalog admin. Dự án tiếp tục dùng Servlet MVC + JSP/JSTL. Bước tiếp theo là hoàn thiện an toàn dữ liệu hình ảnh, bổ sung kiểm thử cạnh tranh/rollback chuyên sâu và chuẩn bị đóng gói triển khai.

## 3. Kiểm tra database hiện tại

Database hiện có 15 bảng nghiệp vụ:

| Nhóm | Bảng | Mục đích | Đánh giá |
|---|---|---|---|
| Tài khoản | `Users` | Tài khoản, mật khẩu, vai trò và trạng thái | Đủ |
| Tài khoản | `Addresses` | Địa chỉ nhận hàng của người dùng | Đủ |
| Danh mục | `Categories` | Danh mục phân cấp | Đủ |
| Danh mục | `Brands` | Thương hiệu | Đủ |
| Sản phẩm | `Products` | Thông tin chung của sản phẩm | Đủ |
| Sản phẩm | `ProductVariants` | SKU, màu, RAM, dung lượng, giá, tồn kho | Đủ |
| Sản phẩm | `ProductImages` | Ảnh chung hoặc ảnh theo phiên bản | Đủ |
| Sản phẩm | `ProductSpecifications` | Thông số kỹ thuật | Đủ |
| Khách hàng | `Favorites` | Sản phẩm yêu thích | Đủ |
| Mua hàng | `Carts` | Giỏ hàng đang hoạt động hoặc đã chốt | Đủ |
| Mua hàng | `CartItems` | Các phiên bản trong giỏ | Đủ |
| Đơn hàng | `Orders` | Thông tin và tổng tiền đơn hàng | Đủ |
| Đơn hàng | `OrderItems` | Chi tiết đơn, có dữ liệu snapshot | Đủ |
| Đơn hàng | `OrderStatusHistory` | Lịch sử trạng thái đơn | Đủ |
| Thanh toán | `Payments` | Các lần/giao dịch thanh toán | Đủ |

### Kết luận database

Bộ bảng hiện tại **đủ để làm toàn bộ các trang trong phạm vi ban đầu**. Không cần tạo thêm bảng trước khi bắt đầu phần Java.

### Dữ liệu sản phẩm demo

Script `database/TechStore_seed_tgdd_demo.sql` chứa dữ liệu công khai tham khảo từ Thế Giới Di Động, thu thập ngày 28/09/2026:

- 10 điện thoại.
- 10 máy tính bảng/iPad.
- 10 laptop.
- 10 phụ kiện.
- Mỗi sản phẩm có thương hiệu, một phiên bản, giá, giá gốc nếu có, tồn kho demo, ảnh chính, thông số cơ bản và URL nguồn.
- Script đồng bộ theo `Product.Slug` và `ProductVariant.SKU`, vì vậy có thể chạy lại mà không nhân đôi dữ liệu.

Khi chạy bằng `sqlcmd`, phải chỉ định UTF-8 để không lỗi dấu tiếng Việt:

```powershell
sqlcmd -S localhost -E -d master -C -b -f 65001 -i database\TechStore_seed_tgdd_demo.sql
```

Giá và ảnh CDN chỉ phù hợp cho bài tập/demo. Trước khi triển khai thương mại cần dùng dữ liệu, ảnh và chính sách giá mà chủ website có quyền sử dụng.

Thiết kế đúng ở các điểm quan trọng:

- Tách `Products` và `ProductVariants`, nên mỗi màu/dung lượng có SKU, giá và tồn kho riêng.
- `OrderItems` lưu snapshot tên, SKU, ảnh và giá tại thời điểm mua.
- `Payments` tách khỏi `Orders`, cho phép lưu nhiều lần thử thanh toán.
- Có `OrderStatusHistory` để theo dõi quá trình xử lý đơn.
- Có unique index cho email, slug và SKU.
- Có filtered unique index bảo đảm mỗi người chỉ có một giỏ `ACTIVE`.

### Nên bổ sung trước khi nhập dữ liệu thật

Các mục dưới đây không yêu cầu thêm bảng, chỉ cần thêm constraint/index hoặc xử lý tại Service:

1. Thêm index cho các khóa ngoại thường dùng:

   - `Addresses(UserId)`.
   - `ProductImages(ProductId)` và `ProductImages(VariantId)`.
   - `ProductSpecifications(ProductId)`.
   - `Favorites(ProductId)`.
   - `CartItems(VariantId)`.
   - `Payments(OrderId)`.
   - `OrderStatusHistory(OrderId, CreatedAt)`.

2. Thêm `CHECK` cho `OrderStatusHistory.Status` để chỉ nhận các trạng thái hợp lệ giống `Orders.Status`.

3. Thêm kiểm tra nghiệp vụ:

   - `TotalAmount = Subtotal + ShippingFee - DiscountAmount`.
   - `LineTotal = UnitPrice * Quantity`.
   - Phiên bản trong `ProductImages` phải thuộc đúng `ProductId`.
   - Mỗi người dùng chỉ có tối đa một địa chỉ mặc định.
   - Không cho giảm tồn kho xuống dưới 0.

4. Chuẩn hóa email trong Java trước khi lưu và đăng nhập: `trim()` rồi chuyển về chữ thường.

5. Không xóa vật lý sản phẩm, phiên bản, danh mục hoặc người dùng đã tham gia đơn hàng; chuyển trạng thái sang `INACTIVE` hoặc `LOCKED`.

### Bảng mở rộng, chưa cần làm ngay

Chỉ tạo khi phạm vi dự án thực sự cần:

- `InventoryTransactions`: lịch sử nhập, xuất và điều chỉnh kho.
- `Coupons` và `CouponUsages`: mã giảm giá.
- `Reviews`: đánh giá sản phẩm.
- `PasswordResetTokens`: quên mật khẩu.
- `EmailVerificationTokens`: xác minh email.
- `Banners`: quản lý banner trang chủ bằng admin.
- `AuditLogs`: lưu thao tác quan trọng của quản trị viên.

Không nên thêm các bảng này trong phiên bản đầu nếu chưa có màn hình hoặc yêu cầu tương ứng.

## 4. Kiến trúc MVC phía Java

Luồng xử lý chuẩn:

```text
Browser
   -> Filter
   -> Servlet Controller
   -> Service
   -> DAO
   -> SQL Server
   -> Servlet đặt dữ liệu vào request
   -> JSP render HTML
```

Quy tắc phân lớp:

- `Controller`: đọc request, gọi Service, chọn JSP hoặc redirect.
- `Service`: validation nghiệp vụ, transaction và phối hợp nhiều DAO.
- `DAO`: chỉ truy vấn database, dùng `PreparedStatement`.
- `Model/Entity`: biểu diễn bản ghi database.
- `DTO`: dữ liệu dành riêng cho form hoặc màn hình.
- `JSP`: chỉ hiển thị dữ liệu; không viết SQL và hạn chế Java scriptlet.
- `Filter`: encoding, đăng nhập, phân quyền và các kiểm tra dùng chung.

## 5. Cấu trúc project đề xuất

```text
web-ban-hang/
├── pom.xml
├── database/
│   └── TechStore.sql
└── src/
    ├── main/
    │   ├── java/
    │   │   └── com/techstore/
    │   │       ├── controller/
    │   │       │   ├── auth/
    │   │       │   ├── admin/
    │   │       │   ├── HomeServlet.java
    │   │       │   ├── ProductServlet.java
    │   │       │   ├── CartServlet.java
    │   │       │   ├── CheckoutServlet.java
    │   │       │   ├── OrderServlet.java
    │   │       │   └── PaymentServlet.java
    │   │       ├── service/
    │   │       ├── dao/
    │   │       │   └── impl/
    │   │       ├── model/
    │   │       ├── dto/
    │   │       ├── filter/
    │   │       ├── exception/
    │   │       └── util/
    │   ├── resources/
    │   │   └── db.properties
    │   └── webapp/
    │       ├── assets/
    │       │   ├── css/
    │       │   ├── js/
    │       │   └── images/
    │       └── WEB-INF/
    │           └── views/
    │               ├── components/
    │               ├── auth/
    │               ├── product/
    │               ├── cart/
    │               ├── order/
    │               ├── payment/
    │               ├── admin/
    │               └── error/
    └── test/
        └── java/
```

Các JSP nên nằm trong `WEB-INF/views` để người dùng không truy cập trực tiếp mà phải đi qua Servlet.

## 6. Các bước triển khai

### Bước 1: Khởi tạo project

- [x] Đã cài JDK và cấu hình project compile theo Java 21.
- [x] Đã có Apache Tomcat 10.1 phù hợp Jakarta Servlet.
- [x] Đã tạo Maven Web Application dạng WAR.
- [x] Đã thiết lập encoding UTF-8 trong Maven.
- [x] Đã thêm Servlet API, JSTL, SQL Server JDBC, Hibernate và BCrypt.
- [x] Đã chạy JSP trên Tomcat và nhận HTTP 200.

> Nếu dùng Tomcat 10+, import Servlet phải là `jakarta.servlet.*`; không trộn với `javax.servlet.*` của các phiên bản cũ.

### Bước 2: Tạo tầng dùng chung

- [x] Đã tạo `JpaUtil` và cấu hình persistence unit `TechStore`.
- [x] Đã hỗ trợ URL, username và password qua biến môi trường.
- [x] Không lưu mật khẩu database/mail thật trong source code.
- [ ] Tạo exception chung cho DAO và Service.
- [x] Đã tạo `ApplicationFilter` xử lý UTF-8, security header và CSRF.
- [x] Đã tạo trang lỗi 403, 404 và 500.
- [x] Đã tạo `/health` chạy `SELECT 1` và xác nhận JPA kết nối SQL Server thành công trên Tomcat Eclipse.

Các biến môi trường mà `ConfigUtil` hỗ trợ ghi đè lên cấu hình local:

- `TECHSTORE_DB_URL`.
- `TECHSTORE_DB_USERNAME`.
- `TECHSTORE_DB_PASSWORD`.
- `TECHSTORE_MAIL_USERNAME`.
- `TECHSTORE_MAIL_PASSWORD`.
- `TECHSTORE_VNPAY_TMN_CODE`.
- `TECHSTORE_VNPAY_HASH_SECRET`.
- `TECHSTORE_APP_URL`.

Không ghi mật khẩu thật vào `src/main/resources/META-INF/config.properties`.

Lưu ý: việc ghi `db.username=TECHSTORE_DB_USERNAME` trong `config.properties` chỉ là **tham chiếu tên biến**, không tự tạo biến môi trường. Biến phải được khai báo trong đúng tiến trình chạy Tomcat, ví dụ tại `Run Configurations > Apache Tomcat > Environment` của Eclipse. Sau khi thêm hoặc đổi biến ở Windows, cần khởi động lại Eclipse/Tomcat rồi mở `/health` để xác nhận.

### Bước 3: Tạo Model và DAO nền tảng

- [x] Đã ánh xạ đủ 15 bảng bằng JPA Entity và một `FavoriteId` cho khóa kép.
- [x] Đã hoàn thiện 15 DAO interface và 15 DAO implementation.
- [x] Đã hoàn thiện Service interface/implementation cho các nhóm nghiệp vụ.
- [x] Đã compile toàn bộ Java source thành công theo Java 21.

Nên làm theo thứ tự:

1. `User`, `Address`.
2. `Category`, `Brand`.
3. `Product`, `ProductVariant`, `ProductImage`, `ProductSpecification`.
4. `Favorite`.
5. `Cart`, `CartItem`.
6. `Order`, `OrderItem`, `OrderStatusHistory`.
7. `Payment`.

Mỗi DAO cần tối thiểu:

- Tìm theo ID.
- Danh sách có phân trang nếu dữ liệu có thể lớn.
- Thêm và cập nhật.
- Các truy vấn riêng theo nghiệp vụ.
- Dùng `PreparedStatement` cho mọi tham số.
- Dùng try-with-resources để đóng `Connection`, `Statement`, `ResultSet`.

### Bước 4: Module đăng ký và đăng nhập

- [x] Form đăng ký và validation phía server.
- [x] Service kiểm tra email trùng.
- [x] Service băm mật khẩu bằng BCrypt trước khi lưu.
- [x] Form đăng nhập.
- [x] Lưu người dùng vào `HttpSession`.
- [x] Đăng xuất và hủy session.
- [x] Tạo `AuthenticationFilter` cho trang cần đăng nhập.
- [x] Tạo `AdminAuthorizationFilter` cho `/admin/*`.
- [x] Đổi session ID sau khi đăng nhập thành công.

### Bước 5: Module sản phẩm và trang chủ

> Đã có DAO/Service, Servlet và JSP cho trang chủ, danh sách và chi tiết sản phẩm.

- [x] Hiển thị danh mục và sản phẩm trên trang chủ.
- [x] Danh sách sản phẩm có phân trang tại `/products`.
- [x] Tìm kiếm theo từ khóa.
- [x] Lọc theo danh mục, thương hiệu và khoảng giá.
- [x] Sắp xếp theo giá tăng, giá giảm hoặc mới nhất; giữ lựa chọn khi lọc và phân trang.
- [x] Chi tiết sản phẩm, ảnh, thông số và các phiên bản.
- [x] Hiển thị tồn kho/trạng thái phiên bản để kiểm soát lựa chọn.
- [x] Dùng slug cho URL chi tiết.

### Bước 6: Module admin sản phẩm

> Admin catalog đã hỗ trợ thêm, sửa và bật/ẩn danh mục, thương hiệu; slug trùng được chặn tại Service.

- [x] Dashboard cơ bản.
- [x] CRUD danh mục theo hướng thêm, sửa và bật/ẩn.
- [x] CRUD thương hiệu theo hướng thêm, sửa và bật/ẩn.
- [x] Tạo/cập nhật sản phẩm.
- [x] Tạo/xóa phiên bản và cập nhật tồn kho.
- [x] Quản lý ảnh và thông số kỹ thuật ở mức cơ bản.
- [x] Sản phẩm dùng trạng thái hoạt động thay vì xóa cứng.

Nên hoàn thành admin sản phẩm trước giỏ hàng để có dữ liệu thật phục vụ kiểm thử.

### Bước 7: Sản phẩm yêu thích

- [x] Service thêm hoặc bỏ yêu thích.
- [x] Chỉ người đã đăng nhập mới được lưu yêu thích.
- [x] Service xử lý thao tác lặp lại mà không tạo bản ghi trùng.
- [x] Hiển thị trạng thái hết hàng hoặc ngừng bán.

### Bước 8: Giỏ hàng

- [x] Service lấy hoặc tạo giỏ `ACTIVE` của người dùng.
- [x] Service thêm phiên bản sản phẩm vào giỏ.
- [x] Nếu phiên bản đã có thì tăng số lượng.
- [x] Service cập nhật số lượng và xóa sản phẩm.
- [x] Kiểm tra số lượng lớn hơn 0.
- [x] Kiểm tra lại giá, trạng thái và tồn kho từ database khi thao tác/chốt giỏ.
- [x] Tổng tiền được tính ở Service phía server.

### Bước 9: Checkout và tạo đơn

- [x] Cho chọn địa chỉ có sẵn hoặc nhập địa chỉ mới.
- [x] Hiển thị tạm tính, phí vận chuyển, giảm giá và tổng tiền.
- [x] Người dùng chọn phương thức thanh toán COD.
- [x] `OrderService` đọc lại giá và khóa tồn kho từ database.
- [x] Tạo mã đơn duy nhất.
- [x] Lưu snapshot địa chỉ vào `Orders`.
- [x] Lưu snapshot sản phẩm và giá vào `OrderItems`.
- [x] Trừ tồn kho an toàn trong transaction.
- [x] Tạo bản ghi `Payments`.
- [x] Thêm trạng thái đầu tiên vào `OrderStatusHistory`.
- [x] Chuyển giỏ thành `ORDERED`.

Toàn bộ quá trình tạo đơn phải nằm trong **một database transaction**. Có lỗi ở bất kỳ bước nào thì rollback toàn bộ.

Trừ kho nên dùng câu lệnh có điều kiện:

```sql
UPDATE ProductVariants
SET StockQuantity = StockQuantity - ?
WHERE VariantId = ?
  AND IsActive = 1
  AND StockQuantity >= ?;
```

Nếu số dòng cập nhật bằng 0 thì phải báo hết hàng hoặc không đủ số lượng.

### Bước 10: Lịch sử đơn hàng

- [x] DAO/Service lấy danh sách đơn theo người dùng.
- [x] DAO/Service lấy chi tiết đơn và lịch sử trạng thái.
- [x] Không cho người dùng xem đơn của người khác.
- [x] Service chỉ cho hủy ở trạng thái hợp lệ.
- [x] Khi hủy, Service hoàn kho đúng một lần trong transaction.
- [x] Service kiểm tra luồng cập nhật trạng thái hợp lệ.

Luồng trạng thái gợi ý:

```text
PENDING -> CONFIRMED -> PROCESSING -> SHIPPING -> COMPLETED
    |           |
    +-----------+--------------------------------> CANCELLED
```

### Bước 11: Thanh toán

- [x] Service tạo đơn và bản ghi thanh toán COD.
- [ ] Sau đó mới tích hợp VNPay/MoMo nếu dự án yêu cầu.
- [ ] Tạo URL thanh toán ở backend.
- [ ] Xác minh chữ ký callback/IPN ở backend.
- [ ] Đối chiếu mã đơn và số tiền.
- [x] Payment Service không ghi nhận callback/giao dịch thành công hai lần.
- [ ] Không đánh dấu `PAID` chỉ dựa trên kết quả do trình duyệt gửi về.

### Bước 12: Hoàn thiện trang admin

- [x] Danh sách và lọc đơn hàng theo trạng thái.
- [x] Xem chi tiết đơn qua màn hình chi tiết dùng chung.
- [x] Cập nhật trạng thái hợp lệ.
- [x] Quản lý tài khoản và khóa/mở khóa.
- [x] Dashboard thống kê cơ bản.
- [x] Kiểm tra quyền admin tại server bằng Filter.

### Bước 13: Bảo mật và validation

- [x] Escape dữ liệu động chính bằng JSTL `c:out`.
- [x] Có CSRF token cho request thay đổi dữ liệu.
- [x] DAO dùng JPQL parameter, không ghép input trực tiếp vào truy vấn.
- [x] Hoàn thiện validation email, điện thoại, mật khẩu và độ dài input ở Service; JSP có giới hạn tương ứng.
- [x] Cookie session dùng `HttpOnly`; `Secure` và `SameSite` sẽ bật/cấu hình khi triển khai HTTPS.
- [ ] Không ghi password, connection string hoặc dữ liệu thanh toán nhạy cảm vào log.
- [ ] Giới hạn loại file, kích thước file và tên file khi upload ảnh.

### Bước 14: Kiểm thử

- [x] Đã compile toàn bộ source bằng Java 21, không có lỗi biên dịch.
- [x] Đã smoke test ứng dụng trên Tomcat 10.1.57.
- [x] Đã tiền biên dịch toàn bộ JSP bằng Jasper: 0 lỗi.
- [x] Đã integration test đọc danh mục, sản phẩm, phiên bản, ảnh và thông số từ SQL Server trên trang chủ/chi tiết.
- [x] Đã integration test các luồng có ghi dữ liệu: tài khoản, yêu thích, giỏ hàng, checkout, đơn hàng và admin.

- [x] DAO kết nối và ánh xạ dữ liệu đúng trong các luồng tích hợp đã chạy.
- [x] Đăng ký trùng email bị từ chối.
- [x] Sai mật khẩu không đăng nhập được.
- [x] Customer không truy cập được `/admin/*`.
- [x] Thêm cùng một SKU vào giỏ không sinh dòng trùng.
- [x] Không mua vượt tồn kho.
- [ ] Hai người mua đồng thời không làm tồn kho âm.
- [ ] Lỗi giữa lúc tạo đơn phải rollback.
- [x] Tổng tiền đơn được tính ở backend và đúng với chi tiết/thanh toán.
- [x] Người dùng không xem/sửa đơn của người khác.
- [ ] Callback thanh toán lặp không cộng tiền hai lần.
- [x] Kiểm tra giao diện trang chủ/đăng nhập trên desktop và mobile.

### Bước 15: Đóng gói và triển khai

- [ ] Tách cấu hình development và production.
- [ ] Dùng tài khoản SQL Server có quyền vừa đủ, không dùng `sa` cho ứng dụng.
- [x] Build file WAR bằng Maven.
- [x] Deploy WAR thử nghiệm lên Tomcat.
- [ ] Bật HTTPS ở môi trường production.
- [ ] Cấu hình logging và xoay vòng log.
- [ ] Lập lịch backup SQL Server và thử khôi phục backup.
- [ ] Tạo tài khoản admin ban đầu bằng script an toàn.

## 7. Kết quả smoke test JSP — 28/09/2026

| Hạng mục | Kết quả |
|---|---|
| Maven compile/package | Thành công, 113 Java source, tạo WAR |
| Tiền biên dịch JSP bằng Jasper | Thành công, 0 lỗi |
| `GET /`, `/home`, `/products` | HTTP 200 |
| `GET /login`, `/register` | HTTP 200 |
| CSS và JavaScript tĩnh | HTTP 200 |
| `/cart`, `/checkout`, `/orders`, `/favorites`, `/admin` khi chưa đăng nhập | HTTP 302 về `/login` |
| Form đăng nhập có CSRF token | Đạt |
| POST không có CSRF token | HTTP 403 |
| JPA/SQL Server trên Tomcat Eclipse | Kết nối thành công; trang chủ và chi tiết đọc dữ liệu thật |
| `GET /home` sau khi nạp dữ liệu | HTTP 200, hiển thị 12/40 sản phẩm ở trang đầu |
| `GET /product?slug=...` | HTTP 200, hiển thị ảnh, giá, tồn kho và thông số |
| Sắp xếp sản phẩm | Giá tăng/giảm đúng qua nhiều trang; mới nhất là mặc định; giữ bộ lọc và phân trang |
| Bộ tích hợp `scripts/integration-smoke.ps1` | Đạt 36/36; dữ liệu test được dọn tự động |
| Validation đầu vào | Chặn email/số điện thoại sai, họ tên và ghi chú đơn vượt giới hạn; không tạo dữ liệu rác |
| Tài khoản và bảo mật | Đăng ký, email trùng, sai mật khẩu, CSRF và quyền admin đều đạt |
| Yêu thích và giỏ hàng | Thêm yêu thích, gộp SKU trùng và chặn vượt tồn kho đều đạt |
| Checkout và đơn hàng | Tạo COD, kiểm tra tổng tiền, trừ/hoàn kho và bảo vệ quyền sở hữu đều đạt |
| Các trang admin | `/admin`, sản phẩm, catalog, đơn hàng và người dùng đều HTTP 200 với tài khoản admin |
| Kiểm tra trực quan | Desktop 1440 px và responsive breakpoint 500 px hiển thị đúng |

File WAR sinh tại `target/TechStore-0.0.1-SNAPSHOT.war`. Ảnh smoke test cục bộ nằm trong `target/ui-smoke/` và không cần commit.

Phần còn chờ kiểm thử chuyên sâu:

- Biến database đã được truyền đúng vào Tomcat Eclipse và kết nối thành công. Hiện ứng dụng còn dùng tài khoản SQL Server `sa`; trước production phải đổi sang tài khoản có quyền vừa đủ.
- Cần test hai checkout chạy đồng thời và tình huống cố ý gây lỗi giữa transaction để xác minh khóa tồn kho/rollback.
- Chưa kiểm thử gửi email và cổng thanh toán online.

## 8. Giai đoạn tiếp theo: hoàn thiện ứng dụng JSP

Dự án giữ nguyên mô hình Servlet MVC: Servlet nhận request và điều phối, Service xử lý nghiệp vụ, DAO/JPA truy cập SQL Server, JSP/JSTL render giao diện. JavaScript chỉ hỗ trợ tương tác giao diện khi cần; xác thực tiếp tục dùng `HttpSession` và các form thay đổi dữ liệu phải gửi CSRF token.

Thứ tự triển khai tiếp theo:

1. Đã hoàn thiện sắp xếp danh sách sản phẩm theo giá và sản phẩm mới nhất.
2. Đã hoàn thiện sửa/ẩn danh mục và thương hiệu trong trang admin.
3. Đã bổ sung validation email, số điện thoại và giới hạn độ dài dữ liệu đầu vào.
4. Hoàn thiện kiểm soát loại file, kích thước và tên file khi upload ảnh sản phẩm.
5. Kiểm thử hai checkout đồng thời và rollback khi transaction tạo đơn gặp lỗi.
6. Rà soát giao diện JSP trên desktop/mobile và thông báo lỗi/thành công của các form.
7. Tách cấu hình development/production, tạo tài khoản SQL Server quyền vừa đủ và cấu hình logging.
8. Build WAR cuối cùng, triển khai Tomcat và lập quy trình backup/khôi phục SQL Server.

## 9. URL/Controller JSP hiện tại

| Chức năng | Method và URL | Controller |
|---|---|---|
| Trang chủ | `GET /home` | `HomeServlet` |
| Danh sách sản phẩm | `GET /products` | `HomeServlet` |
| Đăng ký | `GET/POST /register` | `RegisterServlet` |
| Đăng nhập | `GET/POST /login` | `LoginServlet` |
| Đăng xuất | `POST /logout` | `LogoutServlet` |
| Chi tiết sản phẩm | `GET /product?slug=...` | `ProductDetailServlet` |
| Yêu thích | `GET /favorites`, `POST /favorites/toggle` | `FavoriteServlet` |
| Xem giỏ hàng | `GET /cart` | `CartServlet` |
| Thêm/cập nhật/xóa giỏ | `POST /cart/add`, `/update`, `/remove` | `CartServlet` |
| Checkout và tạo đơn | `GET/POST /checkout` | `CheckoutServlet` |
| Lịch sử đơn | `GET /orders` | `OrderServlet` |
| Chi tiết/hủy đơn | `GET /orders/detail?code=...`, `POST /orders/cancel` | `OrderServlet` |
| Thanh toán | COD được tạo trong checkout; online chưa triển khai | `CheckoutServlet` |
| Quản trị | `/admin/*` | Các Admin Servlet |

Request `GET` chỉ nên dùng để đọc dữ liệu. Thao tác tạo, cập nhật, xóa, đăng xuất và thay đổi trạng thái phải dùng `POST` hoặc method phù hợp.

## 10. Thứ tự làm việc đề xuất

```text
Rà soát database
    -> Khởi tạo Java MVC
    -> Kết nối database
    -> Đăng nhập/phân quyền
    -> Admin sản phẩm
    -> Trang chủ/danh sách/chi tiết sản phẩm
    -> Yêu thích
    -> Giỏ hàng
    -> Checkout và đơn hàng
    -> Lịch sử đơn
    -> Thanh toán
    -> Hoàn thiện admin
    -> Kiểm thử và triển khai
```

## 11. Tiêu chí để kiểm tra kiến trúc Java ở bước tiếp theo

Khi tạo xong bộ khung Java, cần kiểm tra:

- `pom.xml` có đúng dependency và scope hay không.
- Phiên bản Tomcat có khớp `jakarta.servlet`/`javax.servlet` hay không.
- Package được chia đúng `controller`, `service`, `dao`, `model`, `dto`, `filter`, `util`.
- JSP nằm trong `WEB-INF/views`.
- Controller không chứa SQL.
- DAO không xử lý redirect/forward hoặc đọc `HttpServletRequest`.
- Transaction đặt ở Service, đặc biệt là tạo/hủy đơn hàng.
- Connection được đóng an toàn.
- Thông tin kết nối không viết cứng trong Java.
- Authentication và authorization được thực hiện bằng Filter.
- Project build được bằng Maven và chạy được trên Tomcat.

## 12. Mốc hoàn thành phiên bản đầu

Phiên bản đầu được xem là hoàn thành khi:

- Khách đăng ký, đăng nhập và đăng xuất được.
- Admin tạo được sản phẩm cùng phiên bản, ảnh và thông số.
- Khách tìm, lọc và xem chi tiết sản phẩm được.
- Khách thêm yêu thích và giỏ hàng được.
- Khách đặt đơn COD mà tồn kho không bị âm.
- Khách xem được lịch sử và chi tiết đơn của chính mình.
- Admin xem và cập nhật trạng thái đơn được.
- Phân quyền hoạt động đúng.
- Các thao tác tạo đơn có transaction và rollback khi lỗi.

