import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;

import com.shop.service.impl.UserServiceImpl;

class test {

    // Khởi tạo đối tượng chứa hàm cần test
    private final UserServiceImpl userService = new UserServiceImpl();

    // 1. Test trường hợp mật khẩu là Null
    @Test
    void testValidatePassword_Null_ThrowsException() {
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.validatePassword(null);
        });
        assertEquals("Mật khẩu phải dài từ 8 đến 72 ký tự.", exception.getMessage());
    }
    @Test
    void testValidatePassword_Null() {
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.validatePassword(null);
        });
        assertEquals("", exception.getMessage());
    }
    
    // 2. Test biên dưới: Độ dài nhỏ hơn 8 (7 ký tự)
    @Test
    void testValidatePassword_LengthLessThan8_ThrowsException() {
        String shortPassword = "1234567"; 
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.validatePassword(shortPassword);
        });
        assertEquals("Mật khẩu phải dài từ 8 đến 72 ký tự.", exception.getMessage());
    }

    // 3. Test biên dưới hợp lệ: Độ dài đúng bằng 8
    @Test
    void testValidatePassword_LengthExactly8_Success() {
        String validPassword = "12345678"; 
        // Hàm assertDoesNotThrow đảm bảo code chạy trơn tru, không quăng lỗi
        assertDoesNotThrow(() -> {
            userService.validatePassword(validPassword);
        });
    }

    // 4. Test biên trên hợp lệ: Độ dài đúng bằng 72
    @Test
    void testValidatePassword_LengthExactly72_Success() {
        String longPassword = "a".repeat(72); 
        assertDoesNotThrow(() -> {
            userService.validatePassword(longPassword);
        });
    }

    // 5. Test biên trên: Độ dài lớn hơn 72 (73 ký tự)
    @Test
    void testValidatePassword_LengthGreaterThan72_ThrowsException() {
        String tooLongPassword = "a".repeat(73); 
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            userService.validatePassword(tooLongPassword);
        });
        assertEquals("Mật khẩu phải dài từ 8 đến 72 ký tự.", exception.getMessage());
    }
}