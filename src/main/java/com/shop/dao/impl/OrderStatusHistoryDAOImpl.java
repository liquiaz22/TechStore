package com.shop.dao.impl;

import java.util.List;

import com.shop.dao.OrderStatusHistoryDAO;
import com.shop.entity.OrderStatusHistory;
import com.shop.utils.GenericDAOImpl;

public class OrderStatusHistoryDAOImpl extends GenericDAOImpl<OrderStatusHistory>
        implements OrderStatusHistoryDAO {
    public OrderStatusHistoryDAOImpl() { super(OrderStatusHistory.class); }

    @Override
    public List<OrderStatusHistory> findByOrderId(Long orderId) {
        return findMany("SELECT h FROM OrderStatusHistory h LEFT JOIN FETCH h.changedBy "
                + "WHERE h.order.orderId = :orderId ORDER BY h.createdAt, h.historyId",
                q -> q.setParameter("orderId", orderId));
    }
}
