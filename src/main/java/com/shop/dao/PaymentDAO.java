package com.shop.dao;

import java.util.List;
import java.util.Optional;

import com.shop.entity.Payment;
import com.shop.utils.GenericDAO;

public interface PaymentDAO extends GenericDAO<Payment> {
    List<Payment> findByOrderId(Long orderId);
    Optional<Payment> findByProviderTransactionId(String transactionId);
}
