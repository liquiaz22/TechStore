package com.shop.service;

import java.util.List;
import java.util.Optional;

import com.shop.entity.Brand;

public interface BrandService extends GenericService<Brand> {
    Optional<Brand> findBySlug(String slug);
    List<Brand> findActive();
}
