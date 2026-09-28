package com.shop.dao.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.OrderDAO;
import com.shop.entity.Order;
import com.shop.utils.GenericDAOImpl;

public class OrderDAOImpl extends GenericDAOImpl<Order> implements OrderDAO {
    public OrderDAOImpl() { super(Order.class); }

    @Override
    public List<Order> findAll() {
        return findMany("SELECT o FROM Order o JOIN FETCH o.user ORDER BY o.createdAt DESC", q -> {});
    }

    @Override
    public Order findById(Object id) {
        return findOne("SELECT o FROM Order o JOIN FETCH o.user WHERE o.orderId = :id",
                q -> q.setParameter("id", id)).orElse(null);
    }

    @Override
    public Optional<Order> findByCode(String orderCode) {
        return findOne("SELECT o FROM Order o JOIN FETCH o.user WHERE o.orderCode = :orderCode",
                q -> q.setParameter("orderCode", orderCode));
    }

    @Override
    public List<Order> findByUserId(Long userId, int page, int pageSize) {
        int safeSize = Math.max(1, Math.min(pageSize, 100));
        return findMany("FROM Order o WHERE o.user.userId = :userId ORDER BY o.createdAt DESC",
                q -> q.setParameter("userId", userId), Math.max(0, page) * safeSize, safeSize);
    }

    @Override
    public List<Order> findByStatus(String status, int page, int pageSize) {
        int safeSize = Math.max(1, Math.min(pageSize, 100));
        return findMany("SELECT o FROM Order o JOIN FETCH o.user "
                + "WHERE o.status = :status ORDER BY o.createdAt DESC",
                q -> q.setParameter("status", status), Math.max(0, page) * safeSize, safeSize);
    }
}
