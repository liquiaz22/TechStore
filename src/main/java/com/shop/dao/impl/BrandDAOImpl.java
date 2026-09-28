package com.shop.dao.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.BrandDAO;
import com.shop.entity.Brand;
import com.shop.utils.GenericDAOImpl;

public class BrandDAOImpl extends GenericDAOImpl<Brand> implements BrandDAO {
    public BrandDAOImpl() { super(Brand.class); }

    @Override
    public List<Brand> findAll() {
        return findMany("FROM Brand b ORDER BY b.name", q -> {});
    }

    @Override
    public Optional<Brand> findBySlug(String slug) {
        return findOne("FROM Brand b WHERE b.slug = :slug",
                q -> q.setParameter("slug", slug));
    }

    @Override
    public List<Brand> findActive() {
        return findMany("FROM Brand b WHERE b.active = true ORDER BY b.name", q -> {});
    }
}
