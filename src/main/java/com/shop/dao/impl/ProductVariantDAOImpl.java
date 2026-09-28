package com.shop.dao.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.ProductVariantDAO;
import com.shop.entity.ProductVariant;
import com.shop.utils.GenericDAOImpl;

public class ProductVariantDAOImpl extends GenericDAOImpl<ProductVariant>
        implements ProductVariantDAO {
    public ProductVariantDAOImpl() { super(ProductVariant.class); }

    @Override
    public ProductVariant findById(Object id) {
        return findOne("SELECT v FROM ProductVariant v JOIN FETCH v.product WHERE v.variantId = :id",
                q -> q.setParameter("id", id)).orElse(null);
    }

    @Override
    public Optional<ProductVariant> findBySku(String sku) {
        return findOne("FROM ProductVariant v JOIN FETCH v.product WHERE v.sku = :sku",
                q -> q.setParameter("sku", sku));
    }

    @Override
    public List<ProductVariant> findByProductId(Long productId) {
        return findMany("FROM ProductVariant v WHERE v.product.productId = :productId "
                + "ORDER BY v.price, v.variantId",
                q -> q.setParameter("productId", productId));
    }

    @Override
    public List<ProductVariant> findAvailableByProductId(Long productId) {
        return findMany("FROM ProductVariant v WHERE v.product.productId = :productId "
                + "AND v.active = true AND v.stockQuantity > 0 ORDER BY v.price, v.variantId",
                q -> q.setParameter("productId", productId));
    }

    @Override
    public boolean decreaseStock(Long variantId, int quantity) {
        if (quantity <= 0) throw new IllegalArgumentException("Quantity must be positive");
        return executeUpdate("UPDATE ProductVariant v SET v.stockQuantity = v.stockQuantity - :quantity "
                + "WHERE v.variantId = :variantId AND v.active = true "
                + "AND v.stockQuantity >= :quantity",
                q -> q.setParameter("quantity", quantity).setParameter("variantId", variantId)) == 1;
    }
}
