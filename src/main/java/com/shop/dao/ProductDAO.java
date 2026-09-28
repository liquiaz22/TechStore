package com.shop.dao;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import com.shop.entity.Product;
import com.shop.utils.GenericDAO;

public interface ProductDAO extends GenericDAO<Product> {
    Optional<Product> findBySlug(String slug);
    List<Product> search(String keyword, Integer categoryId, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice, String sort, int page, int pageSize);
    long countSearch(String keyword, Integer categoryId, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice);
}
