package com.shop.service;

import java.util.List;
import java.util.Optional;

import com.shop.entity.Payment;

public interface PaymentService extends GenericService<Payment> {
    List<Payment> findByOrderId(Long orderId);
    Optional<Payment> findByProviderTransactionId(String transactionId);
    Payment markSuccess(Long paymentId, String providerTransactionId);
    Payment markFailed(Long paymentId, String providerTransactionId);
}
