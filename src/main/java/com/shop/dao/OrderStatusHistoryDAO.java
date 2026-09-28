package com.shop.dao;

import java.util.List;

import com.shop.entity.OrderStatusHistory;
import com.shop.utils.GenericDAO;

public interface OrderStatusHistoryDAO extends GenericDAO<OrderStatusHistory> {
    List<OrderStatusHistory> findByOrderId(Long orderId);
}
