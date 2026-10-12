# TechStore

Website bán điện thoại, iPad, laptop và phụ kiện công nghệ, xây dựng bằng Java Servlet theo kiến trúc MVC.

## Công nghệ

- Java 21, Jakarta Servlet 6, JSP/JSTL.
- Hibernate/JPA và Microsoft SQL Server.
- Maven WAR, Apache Tomcat 10.1.
- HTML, CSS và JavaScript.

## Cấu hình môi trường

Ứng dụng đọc thông tin nhạy cảm từ biến môi trường, không lưu mật khẩu thật trong source code:

- `TECHSTORE_DB_USERNAME`
- `TECHSTORE_DB_PASSWORD`
- `TECHSTORE_MAIL_USERNAME`
- `TECHSTORE_MAIL_PASSWORD`
- `TECHSTORE_VNPAY_TMN_CODE`
- `TECHSTORE_VNPAY_HASH_SECRET`
- `TECHSTORE_VNPAY_PAY_URL` (tùy chọn, dùng khi chuyển sandbox/production)
- `TECHSTORE_VNPAY_RETURN_URL` (tùy chọn, mặc định lấy từ `app.url`)

Các biến VNPay chỉ cần thiết khi sử dụng chức năng thanh toán VNPay; hai biến
`TMN_CODE` và `HASH_SECRET` là bắt buộc.

Khi đăng ký môi trường VNPay, cấu hình IPN URL là
`{app.url}/payment/vnpay/ipn`. VNPay phải truy cập được URL này từ Internet;
`localhost` chỉ phù hợp để kiểm tra luồng trả về trên trình duyệt.

## Khởi tạo database

Chạy các script theo thứ tự:

1. `database/TechStore.sql`
2. `database/TechStore_upgrade_01.sql`
3. `database/TechStore_upgrade_02_account.sql`
4. `database/TechStore_upgrade_03_catalog.sql`
5. `database/TechStore_upgrade_04_reports.sql`
6. `database/TechStore_upgrade_05_vnpay.sql`
7. `database/TechStore_seed_tgdd_demo.sql`

Với database đang sử dụng, chỉ chạy các file `upgrade` chưa được áp dụng. Các script nâng cấp mới được viết theo kiểu có thể chạy lại an toàn. Sau khi tạo hoặc thay đổi biến môi trường, cần khởi động lại Eclipse/Tomcat để tiến trình Java nhận giá trị mới.

## Build và chạy

```bash
mvn clean package
```

Deploy file WAR trong thư mục `target` lên Tomcat 10.1, sau đó truy cập:

```text
http://localhost:8080/TechStore/home
```

## Kiểm thử tích hợp

Khi ứng dụng và SQL Server đang chạy trên máy Windows:

```powershell
./scripts/integration-smoke.ps1
```

Bộ kiểm thử tự tạo và dọn dữ liệu tạm sau khi hoàn tất. Xem tiến độ và hướng dẫn chi tiết trong `KE_HOACH_TRIEN_KHAI.md`.
