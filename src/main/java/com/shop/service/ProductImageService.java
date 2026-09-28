package com.shop.service;

import java.util.List;
import java.util.Optional;

import com.shop.entity.ProductImage;

public interface ProductImageService extends GenericService<ProductImage> {
    List<ProductImage> findByProductId(Long productId);
    List<ProductImage> findByVariantId(Long variantId);
    Optional<ProductImage> findPrimaryByProductId(Long productId);
}
