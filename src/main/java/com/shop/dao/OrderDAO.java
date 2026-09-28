package com.shop.dao;

import java.util.List;
import java.util.Optional;

import com.shop.entity.Order;
import com.shop.utils.GenericDAO;

public interface OrderDAO extends GenericDAO<Order> {
    Optional<Order> findByCode(String orderCode);
    List<Order> findByUserId(Long userId, int page, int pageSize);
    List<Order> findByStatus(String status, int page, int pageSize);
}
