package com.shop.dao;

import java.util.List;
import java.util.Optional;

import com.shop.entity.ProductImage;
import com.shop.utils.GenericDAO;

public interface ProductImageDAO extends GenericDAO<ProductImage> {
    List<ProductImage> findByProductId(Long productId);
    List<ProductImage> findByVariantId(Long variantId);
    Optional<ProductImage> findPrimaryByProductId(Long productId);
}
