package com.shop.utils;

import java.util.Locale;
import java.util.regex.Pattern;

public final class ValidationUtil {
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?"
                    + "(?:\\.[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?)+$",
            Pattern.CASE_INSENSITIVE);
    private static final Pattern VIETNAM_PHONE_PATTERN = Pattern.compile("0[0-9]{9}");

    private ValidationUtil() {}

    public static String requiredText(String value, String fieldName, int maxLength) {
        String normalized = value == null ? null : value.trim();
        if (normalized == null || normalized.isEmpty()) {
            throw new IllegalArgumentException(fieldName + " không được để trống.");
        }
        requireMaxLength(normalized, fieldName, maxLength);
        return normalized;
    }

    public static String optionalText(String value, String fieldName, int maxLength) {
        if (value == null || value.isBlank()) return null;
        String normalized = value.trim();
        requireMaxLength(normalized, fieldName, maxLength);
        return normalized;
    }

    public static String email(String value) {
        String normalized = requiredText(value, "Email", 320).toLowerCase(Locale.ROOT);
        int at = normalized.lastIndexOf('@');
        if (!EMAIL_PATTERN.matcher(normalized).matches() || at > 64
                || normalized.length() - at - 1 > 255) {
            throw new IllegalArgumentException("Email không đúng định dạng.");
        }
        return normalized;
    }

    public static String optionalPhone(String value, String fieldName) {
        if (value == null || value.isBlank()) return null;
        return phone(value, fieldName);
    }

    public static String phone(String value, String fieldName) {
        String normalized = requiredText(value, fieldName, 20)
                .replaceAll("[\\s.()\\-]", "");
        if (normalized.startsWith("+84")) normalized = "0" + normalized.substring(3);
        if (!VIETNAM_PHONE_PATTERN.matcher(normalized).matches()) {
            throw new IllegalArgumentException(fieldName
                    + " phải gồm 10 chữ số và bắt đầu bằng 0 (hoặc mã +84).");
        }
        return normalized;
    }

    public static void requireMaxLength(String value, String fieldName, int maxLength) {
        if (value != null && value.length() > maxLength) {
            throw new IllegalArgumentException(fieldName + " không được vượt quá "
                    + maxLength + " ký tự.");
        }
    }
}
