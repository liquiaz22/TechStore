package com.shop.service.impl;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import com.shop.dao.PaymentDAO;
import com.shop.dao.impl.PaymentDAOImpl;
import com.shop.entity.Order;
import com.shop.entity.Payment;
import com.shop.service.PaymentService;
import com.shop.utils.JpaUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.LockModeType;

public class PaymentServiceImpl extends AbstractService<Payment> implements PaymentService {
    private final PaymentDAO paymentDAO;
    public PaymentServiceImpl() { this(new PaymentDAOImpl()); }
    public PaymentServiceImpl(PaymentDAO dao) { super(dao); this.paymentDAO = dao; }

    @Override public List<Payment> findByOrderId(Long id) { return paymentDAO.findByOrderId(id); }
    @Override public Optional<Payment> findByProviderTransactionId(String id) {
        return paymentDAO.findByProviderTransactionId(id);
    }
    @Override public Payment markSuccess(Long paymentId, String transactionId) {
        return changeStatus(paymentId, transactionId, "SUCCESS");
    }
    @Override public Payment markFailed(Long paymentId, String transactionId) {
        return changeStatus(paymentId, transactionId, "FAILED");
    }

    private Payment changeStatus(Long paymentId, String transactionId, String status) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Payment payment = em.find(Payment.class, paymentId, LockModeType.PESSIMISTIC_WRITE);
            if (payment == null) throw new IllegalArgumentException("Payment not found");
            if ("SUCCESS".equals(payment.getPaymentStatus())) {
                if ("SUCCESS".equals(status)) {
                    tx.commit();
                    return payment;
                }
                throw new IllegalStateException("A successful payment cannot be marked failed");
            }
            if (transactionId != null && !transactionId.isBlank()) {
                List<Long> duplicate = em.createQuery("SELECT p.paymentId FROM Payment p "
                        + "WHERE p.providerTransactionId = :transactionId AND p.paymentId <> :paymentId",
                        Long.class).setParameter("transactionId", transactionId)
                        .setParameter("paymentId", paymentId).setMaxResults(1).getResultList();
                if (!duplicate.isEmpty()) throw new IllegalArgumentException("Transaction ID already exists");
                payment.setProviderTransactionId(transactionId.trim());
            }
            payment.setPaymentStatus(status);
            Order order = payment.getOrder();
            if ("SUCCESS".equals(status)) {
                payment.setPaidAt(LocalDateTime.now());
                order.setPaymentStatus("PAID");
            } else {
                order.setPaymentStatus("FAILED");
            }
            tx.commit();
            return payment;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
