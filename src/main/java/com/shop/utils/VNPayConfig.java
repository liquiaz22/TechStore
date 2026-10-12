package com.shop.utils;

import java.nio.charset.StandardCharsets;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import jakarta.servlet.http.HttpServletRequest;

public final class VNPayConfig {
    private VNPayConfig() {}

    public static boolean isPaymentConfigured() {
        try {
            validatePaymentConfiguration();
            return true;
        } catch (IllegalStateException ex) {
            return false;
        }
    }

    public static void validatePaymentConfiguration() {
        requireForPayment("vnpay.tmn.code", "TECHSTORE_VNPAY_TMN_CODE");
        requireForPayment("vnpay.hash.secret", "TECHSTORE_VNPAY_HASH_SECRET");
        required("vnpay.pay.url");
        returnUrl();
    }

    public static String payUrl() {
        return required("vnpay.pay.url");
    }

    public static String terminalCode() {
        return required("vnpay.tmn.code");
    }

    public static String hashSecret() {
        return required("vnpay.hash.secret");
    }

    public static String returnUrl() {
        String configured = ConfigUtil.get("vnpay.return.url");
        if (configured != null && !configured.isBlank()) return configured.trim();
        String appUrl = required("app.url");
        if (appUrl.endsWith("/")) appUrl = appUrl.substring(0, appUrl.length() - 1);
        return appUrl + "/payment/vnpay/return";
    }

    public static String hmacSHA512(String key, String data) {
        if (key == null || data == null) throw new IllegalArgumentException("Dữ liệu ký không hợp lệ.");
        try {
            Mac hmac = Mac.getInstance("HmacSHA512");
            hmac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] result = hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(result.length * 2);
            for (byte value : result) hex.append(String.format("%02x", value & 0xff));
            return hex.toString();
        } catch (Exception ex) {
            throw new IllegalStateException("Không thể tạo chữ ký VNPay.", ex);
        }
    }

    public static String clientIp(HttpServletRequest request) {
        String address = request.getRemoteAddr();
        if (address == null || address.isBlank()) return "127.0.0.1";
        address = address.trim();
        return address.length() <= 45 ? address : address.substring(0, 45);
    }

    private static String required(String key) {
        String value = ConfigUtil.get(key);
        if (value == null || value.isBlank()) {
            throw new IllegalStateException("Thiếu cấu hình bắt buộc: " + key);
        }
        return value.trim();
    }

    private static String requireForPayment(String key, String environmentName) {
        String value = ConfigUtil.get(key);
        if (value == null || value.isBlank()) {
            throw new IllegalStateException(
                    "VNPay chưa được cấu hình. Thiếu biến môi trường " + environmentName + ".");
        }
        return value.trim();
    }
}
