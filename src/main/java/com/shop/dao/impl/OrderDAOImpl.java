package com.shop.dao.impl;

import java.util.List;
import java.util.Optional;
import java.time.LocalDateTime;

import com.shop.dao.OrderDAO;
import com.shop.entity.Order;
import com.shop.utils.GenericDAOImpl;
import com.shop.utils.JpaUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import jakarta.persistence.TypedQuery;

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

    @Override
    public List<Order> searchForAdmin(String keyword, String status, LocalDateTime from,
            LocalDateTime toExclusive, int page, int pageSize) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            String jpql = "SELECT o FROM Order o JOIN FETCH o.user" + adminWhere(
                    keyword, status, from, toExclusive) + " ORDER BY o.createdAt DESC";
            TypedQuery<Order> query = em.createQuery(jpql, Order.class);
            bindAdminFilters(query, keyword, status, from, toExclusive);
            int safeSize = Math.max(1, Math.min(pageSize, 100));
            return query.setFirstResult(Math.max(0, page) * safeSize)
                    .setMaxResults(safeSize).getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public long countForAdmin(String keyword, String status, LocalDateTime from,
            LocalDateTime toExclusive) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            String jpql = "SELECT COUNT(o) FROM Order o" + adminWhere(
                    keyword, status, from, toExclusive);
            TypedQuery<Long> query = em.createQuery(jpql, Long.class);
            bindAdminFilters(query, keyword, status, from, toExclusive);
            return query.getSingleResult();
        } finally {
            em.close();
        }
    }

    private String adminWhere(String keyword, String status, LocalDateTime from,
            LocalDateTime toExclusive) {
        StringBuilder where = new StringBuilder(" WHERE 1 = 1");
        if (keyword != null) {
            where.append(" AND (LOWER(o.orderCode) LIKE :keyword")
                    .append(" OR LOWER(o.user.email) LIKE :keyword")
                    .append(" OR LOWER(o.user.fullName) LIKE :keyword")
                    .append(" OR o.receiverPhone LIKE :keyword)");
        }
        if (status != null) where.append(" AND o.status = :status");
        if (from != null) where.append(" AND o.createdAt >= :from");
        if (toExclusive != null) where.append(" AND o.createdAt < :toExclusive");
        return where.toString();
    }

    private void bindAdminFilters(Query query, String keyword, String status,
            LocalDateTime from, LocalDateTime toExclusive) {
        if (keyword != null) query.setParameter("keyword", "%" + keyword.toLowerCase() + "%");
        if (status != null) query.setParameter("status", status);
        if (from != null) query.setParameter("from", from);
        if (toExclusive != null) query.setParameter("toExclusive", toExclusive);
    }
}
