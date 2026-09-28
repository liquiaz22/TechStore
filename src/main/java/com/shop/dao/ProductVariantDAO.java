package com.shop.dao;

import java.util.List;
import java.util.Optional;

import com.shop.entity.ProductVariant;
import com.shop.utils.GenericDAO;

public interface ProductVariantDAO extends GenericDAO<ProductVariant> {
    Optional<ProductVariant> findBySku(String sku);
    List<ProductVariant> findByProductId(Long productId);
    List<ProductVariant> findAvailableByProductId(Long productId);
    boolean decreaseStock(Long variantId, int quantity);
}
