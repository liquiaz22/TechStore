package com.shop.service;

import java.util.Map;

import com.shop.dto.VNPayResult;

public interface VNPayPaymentService {
    String createPaymentUrl(String orderCode, Long userId, String clientIp);
    VNPayResult processCallback(Map<String, String> parameters);
}
