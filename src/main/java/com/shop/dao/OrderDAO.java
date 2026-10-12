package com.shop.dao;

import java.util.List;
import java.util.Optional;
import java.time.LocalDateTime;

import com.shop.entity.Order;
import com.shop.utils.GenericDAO;

public interface OrderDAO extends GenericDAO<Order> {
    Optional<Order> findByCode(String orderCode);
    List<Order> findByUserId(Long userId, int page, int pageSize);
    List<Order> findByStatus(String status, int page, int pageSize);
    List<Order> searchForAdmin(String keyword, String status, LocalDateTime from,
            LocalDateTime toExclusive, int page, int pageSize);
    long countForAdmin(String keyword, String status, LocalDateTime from,
            LocalDateTime toExclusive);
}
