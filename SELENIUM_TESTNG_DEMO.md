# Demo kiểm thử TechStore bằng TestNG và Selenium

## Phạm vi demo

Bộ test tại `src/test/java/com/shop/selenium` kiểm tra 5 luồng:

1. Trang chủ tải thành công và hiển thị các thành phần chính.
2. Tìm kiếm từ header chuyển đến catalog và giữ đúng từ khóa.
3. Đăng ký với hai mật khẩu không khớp bị từ chối và hiển thị cảnh báo.
4. Khách chưa đăng nhập truy cập giỏ hàng sẽ được chuyển đến đăng nhập.
5. Khách chưa đăng nhập truy cập trang quản trị sẽ được chuyển đến đăng nhập.

Ảnh chụp khi test thất bại được lưu tại `target/selenium-screenshots`.

## Điều kiện chạy

- Java 21 và Maven đã được cấu hình.
- Tomcat đang chạy ứng dụng. Năm test demo không phụ thuộc dữ liệu mẫu trong SQL Server.
- URL mặc định: `http://localhost:8080/TechStore`.
- Máy có Google Chrome hoặc Microsoft Edge.

Selenium Manager sẽ tự tìm hoặc tải WebDriver tương thích với trình duyệt.

## Chạy bằng Maven

Chrome headless và URL mặc định:

```powershell
mvn test
```

Chỉ định URL khác:

```powershell
mvn test -DbaseUrl=http://localhost:8080/TechStore
```

Chạy bằng Edge và hiện cửa sổ trình duyệt:

```powershell
mvn test -Dbrowser=edge -Dheadless=false
```

Có thể dùng biến môi trường thay cho tham số Maven:

- `TECHSTORE_BASE_URL`
- `TECHSTORE_TEST_BROWSER` (`chrome` hoặc `edge`)
- `TECHSTORE_TEST_HEADLESS` (`true` hoặc `false`)

## Kết quả

- Báo cáo TestNG/Surefire: `target/surefire-reports`.
- Ảnh lỗi Selenium: `target/selenium-screenshots`.
