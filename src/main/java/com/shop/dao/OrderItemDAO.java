package com.shop.dao;

import java.util.List;

import com.shop.entity.OrderItem;
import com.shop.utils.GenericDAO;

public interface OrderItemDAO extends GenericDAO<OrderItem> {
    List<OrderItem> findByOrderId(Long orderId);
}
