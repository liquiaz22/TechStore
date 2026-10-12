package com.shop.dao;

import java.util.List;

import com.shop.entity.ProductSpecification;
import com.shop.utils.GenericDAO;

public interface ProductSpecificationDAO extends GenericDAO<ProductSpecification> {
    List<ProductSpecification> findByProductId(Long productId);
    boolean existsByName(Long productId, String name, Long excludedId);
}
