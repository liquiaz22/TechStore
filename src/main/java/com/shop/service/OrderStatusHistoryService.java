package com.shop.service;

import java.util.List;

import com.shop.entity.OrderStatusHistory;

public interface OrderStatusHistoryService extends GenericService<OrderStatusHistory> {
    List<OrderStatusHistory> findByOrderId(Long orderId);
}
