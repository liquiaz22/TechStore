package com.shop.dao;

import java.util.List;
import java.util.Optional;

import com.shop.entity.Brand;
import com.shop.utils.GenericDAO;

public interface BrandDAO extends GenericDAO<Brand> {
    Optional<Brand> findBySlug(String slug);
    List<Brand> findActive();
}
