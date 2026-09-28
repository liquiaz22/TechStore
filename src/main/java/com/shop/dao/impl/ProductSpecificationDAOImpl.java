package com.shop.dao.impl;

import java.util.List;

import com.shop.dao.ProductSpecificationDAO;
import com.shop.entity.ProductSpecification;
import com.shop.utils.GenericDAOImpl;

public class ProductSpecificationDAOImpl extends GenericDAOImpl<ProductSpecification>
        implements ProductSpecificationDAO {
    public ProductSpecificationDAOImpl() { super(ProductSpecification.class); }

    @Override
    public List<ProductSpecification> findByProductId(Long productId) {
        return findMany("FROM ProductSpecification s WHERE s.product.productId = :productId "
                + "ORDER BY s.sortOrder, s.specificationId",
                q -> q.setParameter("productId", productId));
    }
}
