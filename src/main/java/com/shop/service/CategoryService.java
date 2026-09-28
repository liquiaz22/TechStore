package com.shop.service;

import java.util.List;
import java.util.Optional;

import com.shop.entity.Category;

public interface CategoryService extends GenericService<Category> {
    Optional<Category> findBySlug(String slug);
    List<Category> findActive();
    List<Category> findByParentId(Integer parentId);
}
