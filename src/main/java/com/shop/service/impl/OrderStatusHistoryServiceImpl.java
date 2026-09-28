package com.shop.service.impl;

import java.util.List;

import com.shop.dao.OrderStatusHistoryDAO;
import com.shop.dao.impl.OrderStatusHistoryDAOImpl;
import com.shop.entity.OrderStatusHistory;
import com.shop.service.OrderStatusHistoryService;

public class OrderStatusHistoryServiceImpl extends AbstractService<OrderStatusHistory>
        implements OrderStatusHistoryService {
    private final OrderStatusHistoryDAO historyDAO;
    public OrderStatusHistoryServiceImpl() { this(new OrderStatusHistoryDAOImpl()); }
    public OrderStatusHistoryServiceImpl(OrderStatusHistoryDAO dao) { super(dao); this.historyDAO = dao; }
    @Override public List<OrderStatusHistory> findByOrderId(Long id) {
        return historyDAO.findByOrderId(id);
    }
}
