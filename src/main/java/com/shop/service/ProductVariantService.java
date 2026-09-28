package com.shop.service;

import java.util.List;
import java.util.Optional;

import com.shop.entity.ProductVariant;

public interface ProductVariantService extends GenericService<ProductVariant> {
    Optional<ProductVariant> findBySku(String sku);
    List<ProductVariant> findByProductId(Long productId);
    List<ProductVariant> findAvailableByProductId(Long productId);
}
