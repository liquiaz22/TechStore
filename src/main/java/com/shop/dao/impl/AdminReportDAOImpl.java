package com.shop.dao.impl;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import com.shop.dao.AdminReportDAO;
import com.shop.dto.AdminReportDTO.CustomerValue;
import com.shop.dto.AdminReportDTO.ProductSales;
import com.shop.dto.AdminReportDTO.StockAlert;
import com.shop.dto.AdminReportDTO.Summary;
import com.shop.utils.JpaUtil;

import jakarta.persistence.EntityManager;

public class AdminReportDAOImpl implements AdminReportDAO {
    @Override
    public Summary summarize(LocalDateTime from, LocalDateTime toExclusive) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            Object[] completed = em.createQuery(
                            "SELECT COALESCE(SUM(o.totalAmount), 0), COUNT(o) FROM Order o "
                                    + "WHERE o.status = 'COMPLETED' "
                                    + "AND COALESCE(o.updatedAt, o.createdAt) >= :from "
                                    + "AND COALESCE(o.updatedAt, o.createdAt) < :to", Object[].class)
                    .setParameter("from", from)
                    .setParameter("to", toExclusive)
                    .getSingleResult();
            long totalOrders = em.createQuery(
                            "SELECT COUNT(o) FROM Order o WHERE o.createdAt >= :from "
                                    + "AND o.createdAt < :to", Long.class)
                    .setParameter("from", from).setParameter("to", toExclusive)
                    .getSingleResult();
            long customers = em.createQuery("SELECT COUNT(u) FROM User u WHERE u.role = 'CUSTOMER'",
                    Long.class).getSingleResult();
            long products = em.createQuery("SELECT COUNT(p) FROM Product p WHERE p.status = 'ACTIVE'",
                    Long.class).getSingleResult();
            return new Summary(asMoney(completed[0]), asLong(completed[1]),
                    totalOrders, customers, products);
        } finally {
            em.close();
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Object[]> findDailyRevenue(LocalDateTime from, LocalDateTime toExclusive) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createNativeQuery("SELECT CAST(COALESCE(UpdatedAt, CreatedAt) AS date), "
                            + "SUM(TotalAmount) "
                            + "FROM Orders WHERE Status = 'COMPLETED' "
                            + "AND COALESCE(UpdatedAt, CreatedAt) >= :from "
                            + "AND COALESCE(UpdatedAt, CreatedAt) < :to "
                            + "GROUP BY CAST(COALESCE(UpdatedAt, CreatedAt) AS date) "
                            + "ORDER BY CAST(COALESCE(UpdatedAt, CreatedAt) AS date)")
                    .setParameter("from", from)
                    .setParameter("to", toExclusive)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<Object[]> countByStatus(LocalDateTime from, LocalDateTime toExclusive) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT o.status, COUNT(o) FROM Order o "
                            + "WHERE o.createdAt >= :from AND o.createdAt < :to "
                            + "GROUP BY o.status", Object[].class)
                    .setParameter("from", from)
                    .setParameter("to", toExclusive)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<ProductSales> findTopProducts(LocalDateTime from, LocalDateTime toExclusive, int limit) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT oi.productName, SUM(oi.quantity), SUM(oi.lineTotal) "
                            + "FROM OrderItem oi WHERE oi.order.status = 'COMPLETED' "
                            + "AND COALESCE(oi.order.updatedAt, oi.order.createdAt) >= :from "
                            + "AND COALESCE(oi.order.updatedAt, oi.order.createdAt) < :to "
                            + "GROUP BY oi.productName ORDER BY SUM(oi.quantity) DESC, "
                            + "SUM(oi.lineTotal) DESC", Object[].class)
                    .setParameter("from", from)
                    .setParameter("to", toExclusive)
                    .setMaxResults(safeLimit(limit))
                    .getResultList().stream()
                    .map(row -> new ProductSales(String.valueOf(row[0]),
                            asLong(row[1]), asMoney(row[2])))
                    .toList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<StockAlert> findStockAlerts(int threshold, int limit) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT v.variantId, v.product.productId, v.sku, v.product.name, "
                            + "v.variantName, v.stockQuantity "
                            + "FROM ProductVariant v WHERE v.active = true "
                            + "AND v.product.status = 'ACTIVE' AND v.stockQuantity <= :threshold "
                            + "ORDER BY v.stockQuantity, v.product.name, v.variantName", Object[].class)
                    .setParameter("threshold", Math.max(0, threshold))
                    .setMaxResults(safeLimit(limit))
                    .getResultList().stream()
                    .map(row -> new StockAlert(((Number) row[0]).longValue(),
                            ((Number) row[1]).longValue(), String.valueOf(row[2]),
                            String.valueOf(row[3]), String.valueOf(row[4]),
                            ((Number) row[5]).intValue()))
                    .toList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<CustomerValue> findTopCustomers(LocalDateTime from,
            LocalDateTime toExclusive, int limit) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT o.user.userId, o.user.fullName, o.user.email, "
                            + "COUNT(o), SUM(o.totalAmount) FROM Order o "
                            + "WHERE o.status = 'COMPLETED' "
                            + "AND COALESCE(o.updatedAt, o.createdAt) >= :from "
                            + "AND COALESCE(o.updatedAt, o.createdAt) < :to "
                            + "GROUP BY o.user.userId, o.user.fullName, o.user.email "
                            + "ORDER BY SUM(o.totalAmount) DESC", Object[].class)
                    .setParameter("from", from)
                    .setParameter("to", toExclusive)
                    .setMaxResults(safeLimit(limit))
                    .getResultList().stream()
                    .map(row -> new CustomerValue(((Number) row[0]).longValue(),
                            String.valueOf(row[1]), String.valueOf(row[2]),
                            asLong(row[3]), asMoney(row[4])))
                    .toList();
        } finally {
            em.close();
        }
    }

    private int safeLimit(int limit) {
        return Math.max(1, Math.min(limit, 100));
    }

    private long asLong(Object value) {
        return value == null ? 0 : ((Number) value).longValue();
    }

    private BigDecimal asMoney(Object value) {
        if (value == null) return BigDecimal.ZERO;
        return value instanceof BigDecimal decimal ? decimal : new BigDecimal(value.toString());
    }
}
