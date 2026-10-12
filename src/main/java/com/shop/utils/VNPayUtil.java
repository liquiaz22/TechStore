package com.shop.utils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.TreeMap;

public final class VNPayUtil {
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    private static final ZoneId VIETNAM_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private VNPayUtil() {}

    public static String createPaymentUrl(BigDecimal amount, String transactionRef,
            String clientIp) {
        long vnpayAmount = toVnpayAmount(amount);
        if (transactionRef == null || !transactionRef.matches("[A-Za-z0-9]{1,100}")) {
            throw new IllegalArgumentException("Mã tham chiếu VNPay không hợp lệ.");
        }

        LocalDateTime now = LocalDateTime.now(VIETNAM_ZONE);
        Map<String, String> parameters = new TreeMap<>();
        parameters.put("vnp_Version", "2.1.0");
        parameters.put("vnp_Command", "pay");
        parameters.put("vnp_TmnCode", VNPayConfig.terminalCode());
        parameters.put("vnp_Amount", String.valueOf(vnpayAmount));
        parameters.put("vnp_CurrCode", "VND");
        parameters.put("vnp_TxnRef", transactionRef);
        parameters.put("vnp_OrderInfo", "Thanh toan don hang TechStore " + transactionRef);
        parameters.put("vnp_OrderType", "other");
        parameters.put("vnp_Locale", "vn");
        parameters.put("vnp_ReturnUrl", VNPayConfig.returnUrl());
        parameters.put("vnp_IpAddr", clientIp);
        parameters.put("vnp_CreateDate", DATE_FORMAT.format(now));
        parameters.put("vnp_ExpireDate", DATE_FORMAT.format(now.plusMinutes(15)));

        String hashData = canonicalData(parameters);
        String signature = VNPayConfig.hmacSHA512(VNPayConfig.hashSecret(), hashData);
        return VNPayConfig.payUrl() + "?" + hashData + "&vnp_SecureHash=" + signature;
    }

    public static boolean verifySignature(Map<String, String> callbackParameters) {
        if (callbackParameters == null) return false;
        String provided = callbackParameters.get("vnp_SecureHash");
        if (provided == null || !provided.matches("(?i)[a-f0-9]{128}")) return false;
        Map<String, String> signedFields = new TreeMap<>();
        callbackParameters.forEach((key, value) -> {
            if (key != null && key.startsWith("vnp_")
                    && !"vnp_SecureHash".equals(key)
                    && !"vnp_SecureHashType".equals(key)
                    && value != null && !value.isEmpty()) {
                signedFields.put(key, value);
            }
        });
        String expected = VNPayConfig.hmacSHA512(
                VNPayConfig.hashSecret(), canonicalData(signedFields));
        return MessageDigest.isEqual(expected.getBytes(StandardCharsets.US_ASCII),
                provided.toLowerCase().getBytes(StandardCharsets.US_ASCII));
    }

    public static long toVnpayAmount(BigDecimal amount) {
        if (amount == null || amount.compareTo(BigDecimal.valueOf(5_000)) < 0) {
            throw new IllegalArgumentException("VNPay yêu cầu số tiền tối thiểu 5.000 ₫.");
        }
        try {
            long result = amount.setScale(0, RoundingMode.UNNECESSARY)
                    .movePointRight(2).longValueExact();
            if (result <= 0 || String.valueOf(result).length() > 12) {
                throw new IllegalArgumentException("Số tiền vượt giới hạn VNPay.");
            }
            return result;
        } catch (ArithmeticException ex) {
            throw new IllegalArgumentException("Số tiền VNPay phải là số nguyên VND.");
        }
    }

    private static String canonicalData(Map<String, String> parameters) {
        StringBuilder result = new StringBuilder();
        for (Map.Entry<String, String> entry : new TreeMap<>(parameters).entrySet()) {
            if (entry.getValue() == null || entry.getValue().isEmpty()) continue;
            if (result.length() > 0) result.append('&');
            result.append(encode(entry.getKey())).append('=').append(encode(entry.getValue()));
        }
        return result.toString();
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.US_ASCII);
    }
}
