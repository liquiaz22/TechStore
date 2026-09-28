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

Hai biến VNPay chỉ cần thiết khi sử dụng chức năng thanh toán VNPay.

## Khởi tạo database

Chạy các script theo thứ tự:

1. `database/TechStore.sql`
2. `database/TechStore_upgrade_01.sql`
3. `database/TechStore_seed_tgdd_demo.sql`

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
