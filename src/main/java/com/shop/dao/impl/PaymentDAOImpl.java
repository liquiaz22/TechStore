package com.shop.dao.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.PaymentDAO;
import com.shop.entity.Payment;
import com.shop.utils.GenericDAOImpl;

public class PaymentDAOImpl extends GenericDAOImpl<Payment> implements PaymentDAO {
    public PaymentDAOImpl() { super(Payment.class); }

    @Override
    public List<Payment> findByOrderId(Long orderId) {
        return findMany("FROM Payment p WHERE p.order.orderId = :orderId ORDER BY p.createdAt DESC",
                q -> q.setParameter("orderId", orderId));
    }

    @Override
    public Optional<Payment> findByProviderTransactionId(String transactionId) {
        return findOne("FROM Payment p WHERE p.providerTransactionId = :transactionId",
                q -> q.setParameter("transactionId", transactionId));
    }
}
