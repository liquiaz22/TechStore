package com.shop.dao.impl;

import java.util.List;

import com.shop.dao.OrderItemDAO;
import com.shop.entity.OrderItem;
import com.shop.utils.GenericDAOImpl;

public class OrderItemDAOImpl extends GenericDAOImpl<OrderItem> implements OrderItemDAO {
    public OrderItemDAOImpl() { super(OrderItem.class); }

    @Override
    public List<OrderItem> findByOrderId(Long orderId) {
        return findMany("FROM OrderItem oi LEFT JOIN FETCH oi.variant "
                + "WHERE oi.order.orderId = :orderId ORDER BY oi.orderItemId",
                q -> q.setParameter("orderId", orderId));
    }
}
