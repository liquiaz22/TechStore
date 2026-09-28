package com.shop.dao.impl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

import com.shop.dao.ProductDAO;
import com.shop.entity.Product;
import com.shop.utils.GenericDAOImpl;
import com.shop.utils.JpaUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;

public class ProductDAOImpl extends GenericDAOImpl<Product> implements ProductDAO {
    public ProductDAOImpl() { super(Product.class); }

    @Override
    public List<Product> findAll() {
        return findMany("SELECT p FROM Product p JOIN FETCH p.category "
                + "LEFT JOIN FETCH p.brand ORDER BY p.createdAt DESC", q -> {});
    }

    @Override
    public Optional<Product> findBySlug(String slug) {
        return findOne("SELECT p FROM Product p JOIN FETCH p.category "
                + "LEFT JOIN FETCH p.brand WHERE p.slug = :slug",
                q -> q.setParameter("slug", slug));
    }

    @Override
    public List<Product> search(String keyword, Integer categoryId, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice, String sort, int page, int pageSize) {
        if ("price_asc".equals(sort) || "price_desc".equals(sort)) {
            return searchByPrice(keyword, categoryId, brandId, minPrice, maxPrice,
                    sort, page, pageSize);
        }
        String jpql = "SELECT DISTINCT p FROM Product p JOIN FETCH p.category "
                + "LEFT JOIN FETCH p.brand " + buildWhere(keyword, categoryId, brandId, minPrice, maxPrice)
                + " ORDER BY p.createdAt DESC, p.productId DESC";
        int safeSize = Math.max(1, Math.min(pageSize, 100));
        return findMany(jpql, q -> bind(q, keyword, categoryId, brandId, minPrice, maxPrice),
                Math.max(0, page) * safeSize, safeSize);
    }

    @Override
    public long countSearch(String keyword, Integer categoryId, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            Query query = em.createQuery("SELECT COUNT(DISTINCT p.productId) FROM Product p "
                    + buildWhere(keyword, categoryId, brandId, minPrice, maxPrice));
            bind(query, keyword, categoryId, brandId, minPrice, maxPrice);
            return (Long) query.getSingleResult();
        } finally {
            em.close();
        }
    }

    private String buildWhere(String keyword, Integer categoryId, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice) {
        StringBuilder where = new StringBuilder("WHERE p.status = 'ACTIVE' ");
        if (keyword != null && !keyword.isBlank()) {
            where.append("AND (LOWER(p.name) LIKE :keyword OR LOWER(p.shortDescription) LIKE :keyword) ");
        }
        if (categoryId != null) where.append("AND p.category.categoryId = :categoryId ");
        if (brandId != null) where.append("AND p.brand.brandId = :brandId ");
        where.append("AND EXISTS (SELECT v.variantId FROM ProductVariant v "
                + "WHERE v.product = p AND v.active = true ");
        if (minPrice != null) where.append("AND v.price >= :minPrice ");
        if (maxPrice != null) where.append("AND v.price <= :maxPrice ");
        where.append(") ");
        return where.toString();
    }

    private void bind(Query query, String keyword, Integer categoryId, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice) {
        if (keyword != null && !keyword.isBlank()) {
            query.setParameter("keyword", "%" + keyword.trim().toLowerCase(Locale.ROOT) + "%");
        }
        if (categoryId != null) query.setParameter("categoryId", categoryId);
        if (brandId != null) query.setParameter("brandId", brandId);
        if (minPrice != null) query.setParameter("minPrice", minPrice);
        if (maxPrice != null) query.setParameter("maxPrice", maxPrice);
    }

    private List<Product> searchByPrice(String keyword, Integer categoryId, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice, String sort, int page, int pageSize) {
        int safeSize = Math.max(1, Math.min(pageSize, 100));
        String direction = "price_desc".equals(sort) ? "DESC" : "ASC";
        String idJpql = "SELECT p.productId FROM Product p "
                + "JOIN ProductVariant sortVariant ON sortVariant.product = p "
                + "AND sortVariant.active = true "
                + buildWhere(keyword, categoryId, brandId, minPrice, maxPrice)
                + "GROUP BY p.productId "
                + "ORDER BY MIN(sortVariant.price) " + direction + ", p.productId DESC";

        EntityManager em = JpaUtil.getEntityManager();
        try {
            Query idQuery = em.createQuery(idJpql);
            bind(idQuery, keyword, categoryId, brandId, minPrice, maxPrice);
            idQuery.setFirstResult(Math.max(0, page) * safeSize);
            idQuery.setMaxResults(safeSize);
            @SuppressWarnings("unchecked")
            List<Long> ids = idQuery.getResultList();
            if (ids.isEmpty()) return List.of();

            List<Product> products = em.createQuery(
                    "SELECT DISTINCT p FROM Product p JOIN FETCH p.category "
                            + "LEFT JOIN FETCH p.brand WHERE p.productId IN :ids",
                    Product.class)
                    .setParameter("ids", ids)
                    .getResultList();
            Map<Long, Product> productsById = products.stream().collect(
                    Collectors.toMap(Product::getProductId, Function.identity()));
            List<Product> ordered = new ArrayList<>(ids.size());
            for (Long id : ids) {
                Product product = productsById.get(id);
                if (product != null) ordered.add(product);
            }
            return ordered;
        } finally {
            em.close();
        }
    }
}
