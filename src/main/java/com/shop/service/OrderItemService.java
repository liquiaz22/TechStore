package com.shop.service;

import java.util.List;

import com.shop.entity.OrderItem;

public interface OrderItemService extends GenericService<OrderItem> {
    List<OrderItem> findByOrderId(Long orderId);
}
