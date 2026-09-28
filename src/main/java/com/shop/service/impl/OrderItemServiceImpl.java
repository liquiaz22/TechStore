package com.shop.service.impl;

import java.util.List;

import com.shop.dao.OrderItemDAO;
import com.shop.dao.impl.OrderItemDAOImpl;
import com.shop.entity.OrderItem;
import com.shop.service.OrderItemService;

public class OrderItemServiceImpl extends AbstractService<OrderItem> implements OrderItemService {
    private final OrderItemDAO orderItemDAO;
    public OrderItemServiceImpl() { this(new OrderItemDAOImpl()); }
    public OrderItemServiceImpl(OrderItemDAO dao) { super(dao); this.orderItemDAO = dao; }
    @Override public List<OrderItem> findByOrderId(Long id) { return orderItemDAO.findByOrderId(id); }
}
