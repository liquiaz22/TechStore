package com.shop.service.impl;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import com.shop.dto.VNPayResult;
import com.shop.entity.Order;
import com.shop.entity.Payment;
import com.shop.service.VNPayPaymentService;
import com.shop.utils.JpaUtil;
import com.shop.utils.VNPayConfig;
import com.shop.utils.VNPayUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.LockModeType;

public class VNPayPaymentServiceImpl implements VNPayPaymentService {
    private static final int ATTEMPT_EXPIRY_MINUTES = 20;

    @Override
    public String createPaymentUrl(String orderCode, Long userId, String clientIp) {
        // Validate before prepareAttempt() opens a transaction and writes a Payment row.
        // A missing merchant configuration must never leave a new PENDING attempt behind.
        VNPayConfig.validatePaymentConfiguration();
        Payment payment = prepareAttempt(orderCode, userId);
        return VNPayUtil.createPaymentUrl(
                payment.getAmount(), payment.getMerchantTransactionRef(), clientIp);
    }

    @Override
    public VNPayResult processCallback(Map<String, String> parameters) {
        if (!VNPayUtil.verifySignature(parameters)) {
            return result("97", "Invalid Checksum", false, null,
                    "Chữ ký phản hồi VNPay không hợp lệ.");
        }
        if (!VNPayConfig.terminalCode().equals(parameters.get("vnp_TmnCode"))) {
            return result("97", "Invalid Terminal", false, null,
                    "Mã website VNPay không hợp lệ.");
        }

        String reference;
        String amountValue;
        String responseCode;
        String transactionStatus;
        String transactionNumber;
        String bankCode;
        try {
            reference = required(parameters, "vnp_TxnRef", "[A-Za-z0-9]{1,100}");
            amountValue = required(parameters, "vnp_Amount", "[0-9]{1,12}");
            responseCode = required(parameters, "vnp_ResponseCode", "[0-9]{2}");
            transactionStatus = required(parameters, "vnp_TransactionStatus", "[0-9]{2}");
            transactionNumber = optional(parameters.get("vnp_TransactionNo"), 200);
            bankCode = optional(parameters.get("vnp_BankCode"), 30);
        } catch (IllegalArgumentException ex) {
            return result("99", "Invalid Data", false, null, ex.getMessage());
        }
        long callbackAmount;
        try {
            callbackAmount = Long.parseLong(amountValue);
        } catch (NumberFormatException ex) {
            return result("04", "Invalid Amount", false, null,
                    "Số tiền VNPay không hợp lệ.");
        }

        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            Payment payment = em.createQuery("SELECT p FROM Payment p JOIN FETCH p.order "
                            + "WHERE p.merchantTransactionRef = :reference", Payment.class)
                    .setParameter("reference", reference)
                    .setLockMode(LockModeType.PESSIMISTIC_WRITE)
                    .setMaxResults(1)
                    .getResultStream().findFirst().orElse(null);
            if (payment == null || !"VNPAY".equals(payment.getPaymentMethod())) {
                transaction.rollback();
                return result("01", "Order not Found", false, null,
                        "Không tìm thấy giao dịch thanh toán.");
            }
            Order order = payment.getOrder();
            if (payment.getAmount().compareTo(order.getTotalAmount()) != 0
                    || VNPayUtil.toVnpayAmount(payment.getAmount()) != callbackAmount) {
                transaction.rollback();
                return result("04", "Invalid Amount", false, order.getOrderCode(),
                        "Số tiền VNPay không khớp với đơn hàng.");
            }
            if (!"PENDING".equals(payment.getPaymentStatus())) {
                boolean successful = "SUCCESS".equals(payment.getPaymentStatus());
                transaction.rollback();
                return result("02", "Order already confirmed", successful,
                        order.getOrderCode(), successful
                                ? "Giao dịch đã được ghi nhận thành công trước đó."
                                : "Giao dịch đã được xử lý trước đó.");
            }
            if ("CANCELLED".equals(order.getStatus())) {
                transaction.rollback();
                return result("02", "Order already confirmed", false,
                        order.getOrderCode(), "Đơn hàng đã bị hủy.");
            }

            boolean successful = "00".equals(responseCode) && "00".equals(transactionStatus);
            payment.setProviderResponseCode(responseCode);
            payment.setBankCode(bankCode);
            if (successful) {
                if (transactionNumber == null || !transactionNumber.matches("[0-9]{1,15}")) {
                    transaction.rollback();
                    return result("99", "Invalid Transaction Number", false,
                            order.getOrderCode(), "Mã giao dịch VNPay không hợp lệ.");
                }
                List<Long> duplicate = em.createQuery("SELECT p.paymentId FROM Payment p "
                                + "WHERE p.paymentMethod = 'VNPAY' "
                                + "AND p.providerTransactionId = :transactionNumber "
                                + "AND p.paymentId <> :paymentId", Long.class)
                        .setParameter("transactionNumber", transactionNumber)
                        .setParameter("paymentId", payment.getPaymentId())
                        .setMaxResults(1).getResultList();
                if (!duplicate.isEmpty()) {
                    transaction.rollback();
                    return result("02", "Order already confirmed", false,
                            order.getOrderCode(), "Mã giao dịch VNPay đã được sử dụng.");
                }
                payment.setProviderTransactionId(transactionNumber);
                payment.setPaymentStatus("SUCCESS");
                payment.setPaidAt(LocalDateTime.now());
                order.setPaymentStatus("PAID");
            } else {
                payment.setPaymentStatus("FAILED");
                if (!hasSuccessfulPayment(em, order.getOrderId())) {
                    order.setPaymentStatus("FAILED");
                }
            }
            transaction.commit();
            return result("00", "Confirm Success", successful, order.getOrderCode(),
                    successful ? "Thanh toán VNPay thành công."
                            : failureMessage(responseCode));
        } catch (IllegalArgumentException ex) {
            if (transaction.isActive()) transaction.rollback();
            return result("99", "Invalid Data", false, null, ex.getMessage());
        } catch (RuntimeException ex) {
            if (transaction.isActive()) transaction.rollback();
            return result("99", "Unknown error", false, null,
                    "Không thể xử lý kết quả VNPay.");
        } finally {
            em.close();
        }
    }

    private Payment prepareAttempt(String orderCode, Long userId) {
        if (orderCode == null || !orderCode.matches("[A-Za-z0-9]{1,30}")) {
            throw new IllegalArgumentException("Mã đơn hàng không hợp lệ.");
        }
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            Order order = em.createQuery("SELECT o FROM Order o JOIN FETCH o.user "
                            + "WHERE o.orderCode = :orderCode", Order.class)
                    .setParameter("orderCode", orderCode)
                    .setLockMode(LockModeType.PESSIMISTIC_WRITE)
                    .setMaxResults(1).getResultStream().findFirst().orElse(null);
            if (order == null || !order.getUser().getUserId().equals(userId)) {
                throw new IllegalArgumentException("Không tìm thấy đơn hàng của tài khoản này.");
            }
            if ("PAID".equals(order.getPaymentStatus())) {
                throw new IllegalStateException("Đơn hàng đã được thanh toán.");
            }
            if ("CANCELLED".equals(order.getStatus()) || "COMPLETED".equals(order.getStatus())) {
                throw new IllegalStateException("Trạng thái đơn hàng không cho phép thanh toán lại.");
            }

            List<Payment> attempts = em.createQuery("SELECT p FROM Payment p "
                            + "WHERE p.order.orderId = :orderId AND p.paymentMethod = 'VNPAY' "
                            + "ORDER BY p.createdAt DESC", Payment.class)
                    .setParameter("orderId", order.getOrderId())
                    .setLockMode(LockModeType.PESSIMISTIC_WRITE)
                    .setMaxResults(1).getResultList();
            Payment payment = attempts.isEmpty() ? null : attempts.get(0);
            if (payment != null && "PENDING".equals(payment.getPaymentStatus())
                    && payment.getCreatedAt().isBefore(
                            LocalDateTime.now().minusMinutes(ATTEMPT_EXPIRY_MINUTES))) {
                payment.setPaymentStatus("FAILED");
                payment.setProviderResponseCode("EXPIRED");
                payment = null;
            }
            if (payment == null || !"PENDING".equals(payment.getPaymentStatus())) {
                payment = new Payment();
                payment.setOrder(order);
                payment.setPaymentMethod("VNPAY");
                payment.setAmount(order.getTotalAmount());
                em.persist(payment);
                em.flush();
            }
            if (payment.getMerchantTransactionRef() == null) {
                payment.setMerchantTransactionRef("TS" + order.getOrderId()
                        + "P" + payment.getPaymentId());
            }
            order.setPaymentStatus("UNPAID");
            transaction.commit();
            return payment;
        } catch (RuntimeException ex) {
            if (transaction.isActive()) transaction.rollback();
            throw ex;
        } finally {
            em.close();
        }
    }

    private boolean hasSuccessfulPayment(EntityManager em, Long orderId) {
        return !em.createQuery("SELECT p.paymentId FROM Payment p "
                        + "WHERE p.order.orderId = :orderId AND p.paymentStatus = 'SUCCESS'", Long.class)
                .setParameter("orderId", orderId).setMaxResults(1).getResultList().isEmpty();
    }

    private String required(Map<String, String> parameters, String name, String pattern) {
        String value = parameters.get(name);
        if (value == null || !value.matches(pattern)) {
            throw new IllegalArgumentException("Dữ liệu VNPay không hợp lệ.");
        }
        return value;
    }

    private String optional(String value, int maxLength) {
        if (value == null || value.isBlank()) return null;
        String trimmed = value.trim();
        if (trimmed.length() > maxLength || trimmed.chars().anyMatch(Character::isISOControl)) {
            throw new IllegalArgumentException("Dữ liệu VNPay vượt giới hạn.");
        }
        return trimmed;
    }

    private VNPayResult result(String code, String responseMessage, boolean successful,
            String orderCode, String displayMessage) {
        return new VNPayResult(code, responseMessage, successful, orderCode, displayMessage);
    }

    private String failureMessage(String code) {
        return switch (code) {
            case "05" -> "Tài khoản không đủ số dư.";
            case "06" -> "Mã xác thực giao dịch không đúng.";
            case "07" -> "Giao dịch đang được VNPay xem xét.";
            case "09" -> "Tài khoản chưa đăng ký Internet Banking.";
            case "10" -> "Thông tin xác thực không đúng quá số lần cho phép.";
            case "11" -> "Giao dịch đã hết hạn chờ thanh toán.";
            case "12" -> "Tài khoản hoặc thẻ đang bị khóa.";
            case "24" -> "Bạn đã hủy giao dịch VNPay.";
            case "65" -> "Tài khoản đã vượt hạn mức giao dịch trong ngày.";
            case "75" -> "Ngân hàng thanh toán đang bảo trì.";
            case "79" -> "Mật khẩu thanh toán không đúng quá số lần cho phép.";
            default -> "Thanh toán VNPay không thành công.";
        };
    }
}
