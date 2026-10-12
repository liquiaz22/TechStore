package com.shop.dao.impl;

import java.util.List;

import com.shop.dao.ProductSpecificationDAO;
import com.shop.entity.ProductSpecification;
import com.shop.utils.GenericDAOImpl;

public class ProductSpecificationDAOImpl extends GenericDAOImpl<ProductSpecification>
        implements ProductSpecificationDAO {
    public ProductSpecificationDAOImpl() { super(ProductSpecification.class); }

    @Override
    public ProductSpecification findById(Object id) {
        return findOne("SELECT s FROM ProductSpecification s JOIN FETCH s.product "
                        + "WHERE s.specificationId = :id",
                q -> q.setParameter("id", id)).orElse(null);
    }

    @Override
    public List<ProductSpecification> findByProductId(Long productId) {
        return findMany("FROM ProductSpecification s WHERE s.product.productId = :productId "
                + "ORDER BY s.sortOrder, s.specificationId",
                q -> q.setParameter("productId", productId));
    }

    @Override
    public boolean existsByName(Long productId, String name, Long excludedId) {
        String jpql = "SELECT s FROM ProductSpecification s "
                + "WHERE s.product.productId = :productId "
                + "AND LOWER(s.specificationName) = LOWER(:name)"
                + (excludedId == null ? "" : " AND s.specificationId <> :excludedId");
        return findOne(jpql, q -> {
            q.setParameter("productId", productId);
            q.setParameter("name", name);
            if (excludedId != null) q.setParameter("excludedId", excludedId);
        }).isPresent();
    }
}
