package com.shop.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.time.LocalDateTime;

import com.shop.entity.Addresses;
import com.shop.entity.Order;

public interface OrderService extends GenericService<Order> {
    Optional<Order> findByCode(String orderCode);
    List<Order> findByUserId(Long userId, int page, int pageSize);
    List<Order> findByStatus(String status, int page, int pageSize);
    List<Order> searchForAdmin(String keyword, String status, LocalDateTime from,
            LocalDateTime toExclusive, int page, int pageSize);
    long countForAdmin(String keyword, String status, LocalDateTime from,
            LocalDateTime toExclusive);
    Order placeOrder(Long userId, Addresses shippingAddress, Map<Long, Integer> items,
            BigDecimal shippingFee, BigDecimal discountAmount,
            String paymentMethod, String customerNote);
    Order cancel(Long orderId, Long changedByUserId, String note);
    Order updateStatus(Long orderId, String status, Long changedByUserId, String note);
}
