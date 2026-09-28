package com.shop.service.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.CategoryDAO;
import com.shop.dao.impl.CategoryDAOImpl;
import com.shop.entity.Category;
import com.shop.service.CategoryService;

public class CategoryServiceImpl extends AbstractService<Category> implements CategoryService {
    private final CategoryDAO categoryDAO;
    public CategoryServiceImpl() { this(new CategoryDAOImpl()); }
    public CategoryServiceImpl(CategoryDAO dao) { super(dao); this.categoryDAO = dao; }
    @Override public Optional<Category> findBySlug(String slug) { return categoryDAO.findBySlug(slug); }
    @Override public List<Category> findActive() { return categoryDAO.findActive(); }
    @Override public List<Category> findByParentId(Integer parentId) { return categoryDAO.findByParentId(parentId); }

    @Override
    public boolean create(Category category) {
        validate(category);
        ensureUniqueSlug(category);
        return categoryDAO.create(category);
    }

    @Override
    public Category update(Category category) {
        validate(category);
        ensureUniqueSlug(category);
        return categoryDAO.update(category);
    }

    private void validate(Category category) {
        if (category == null || category.getName() == null || category.getName().isBlank()
                || category.getSlug() == null || category.getSlug().isBlank()) {
            throw new IllegalArgumentException("Tên và slug danh mục không được để trống.");
        }
        category.setName(category.getName().trim());
        category.setSlug(category.getSlug().trim().toLowerCase(java.util.Locale.ROOT));
        if (category.getName().length() > 100 || category.getSlug().length() > 150) {
            throw new IllegalArgumentException("Tên hoặc slug danh mục vượt quá độ dài cho phép.");
        }
        if (!category.getSlug().matches("[a-z0-9]+(?:-[a-z0-9]+)*")) {
            throw new IllegalArgumentException("Slug danh mục chỉ gồm chữ thường, số và dấu gạch ngang.");
        }
        Integer id = category.getCategoryId();
        Category parent = category.getParentCategory();
        while (parent != null) {
            if (id != null && id.equals(parent.getCategoryId())) {
                throw new IllegalArgumentException("Danh mục cha tạo thành vòng lặp.");
            }
            parent = parent.getParentCategory() == null ? null
                    : categoryDAO.findById(parent.getParentCategory().getCategoryId());
        }
    }

    private void ensureUniqueSlug(Category category) {
        Optional<Category> sameSlug = categoryDAO.findBySlug(category.getSlug());
        if (sameSlug.isPresent()
                && !sameSlug.get().getCategoryId().equals(category.getCategoryId())) {
            throw new IllegalArgumentException("Slug danh mục đã tồn tại.");
        }
    }
}
