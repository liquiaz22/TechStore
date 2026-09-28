package com.shop.dao.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.CategoryDAO;
import com.shop.entity.Category;
import com.shop.utils.GenericDAOImpl;

public class CategoryDAOImpl extends GenericDAOImpl<Category> implements CategoryDAO {
    public CategoryDAOImpl() { super(Category.class); }

    @Override
    public Category findById(Object id) {
        return findOne("SELECT c FROM Category c LEFT JOIN FETCH c.parentCategory "
                + "WHERE c.categoryId = :id", q -> q.setParameter("id", id)).orElse(null);
    }

    @Override
    public List<Category> findAll() {
        return findMany("SELECT c FROM Category c LEFT JOIN FETCH c.parentCategory "
                + "ORDER BY c.name", q -> {});
    }

    @Override
    public Optional<Category> findBySlug(String slug) {
        return findOne("FROM Category c WHERE c.slug = :slug",
                q -> q.setParameter("slug", slug));
    }

    @Override
    public List<Category> findActive() {
        return findMany("FROM Category c WHERE c.active = true ORDER BY c.name", q -> {});
    }

    @Override
    public List<Category> findByParentId(Integer parentId) {
        if (parentId == null) {
            return findMany("FROM Category c WHERE c.parentCategory IS NULL ORDER BY c.name", q -> {});
        }
        return findMany("FROM Category c WHERE c.parentCategory.categoryId = :parentId ORDER BY c.name",
                q -> q.setParameter("parentId", parentId));
    }
}
