package com.shop.service;

import java.util.List;

import com.shop.entity.ProductSpecification;

public interface ProductSpecificationService extends GenericService<ProductSpecification> {
    List<ProductSpecification> findByProductId(Long productId);
}
