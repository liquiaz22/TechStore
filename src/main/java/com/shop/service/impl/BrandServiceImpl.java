package com.shop.service.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.BrandDAO;
import com.shop.dao.impl.BrandDAOImpl;
import com.shop.entity.Brand;
import com.shop.service.BrandService;

public class BrandServiceImpl extends AbstractService<Brand> implements BrandService {
    private final BrandDAO brandDAO;
    public BrandServiceImpl() { this(new BrandDAOImpl()); }
    public BrandServiceImpl(BrandDAO dao) { super(dao); this.brandDAO = dao; }
    @Override public Optional<Brand> findBySlug(String slug) { return brandDAO.findBySlug(slug); }
    @Override public List<Brand> findActive() { return brandDAO.findActive(); }

    @Override
    public boolean create(Brand brand) {
        validate(brand);
        ensureUniqueSlug(brand);
        return brandDAO.create(brand);
    }

    @Override
    public Brand update(Brand brand) {
        validate(brand);
        ensureUniqueSlug(brand);
        return brandDAO.update(brand);
    }

    private void validate(Brand brand) {
        if (brand == null || brand.getName() == null || brand.getName().isBlank()
                || brand.getSlug() == null || brand.getSlug().isBlank()) {
            throw new IllegalArgumentException("Tên và slug thương hiệu không được để trống.");
        }
        brand.setName(brand.getName().trim());
        brand.setSlug(brand.getSlug().trim().toLowerCase(java.util.Locale.ROOT));
        brand.setLogoUrl(brand.getLogoUrl() == null || brand.getLogoUrl().isBlank()
                ? null : brand.getLogoUrl().trim());
        if (brand.getName().length() > 100 || brand.getSlug().length() > 150
                || brand.getLogoUrl() != null && brand.getLogoUrl().length() > 500) {
            throw new IllegalArgumentException("Dữ liệu thương hiệu vượt quá độ dài cho phép.");
        }
        if (!brand.getSlug().matches("[a-z0-9]+(?:-[a-z0-9]+)*")) {
            throw new IllegalArgumentException("Slug thương hiệu chỉ gồm chữ thường, số và dấu gạch ngang.");
        }
    }

    private void ensureUniqueSlug(Brand brand) {
        Optional<Brand> sameSlug = brandDAO.findBySlug(brand.getSlug());
        if (sameSlug.isPresent() && !sameSlug.get().getBrandId().equals(brand.getBrandId())) {
            throw new IllegalArgumentException("Slug thương hiệu đã tồn tại.");
        }
    }
}
