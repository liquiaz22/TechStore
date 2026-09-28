package com.shop.dao;

import java.util.List;
import java.util.Optional;

import com.shop.entity.Category;
import com.shop.utils.GenericDAO;

public interface CategoryDAO extends GenericDAO<Category> {
    Optional<Category> findBySlug(String slug);
    List<Category> findActive();
    List<Category> findByParentId(Integer parentId);
}
