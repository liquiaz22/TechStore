package com.shop.dao.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.ProductImageDAO;
import com.shop.entity.ProductImage;
import com.shop.utils.GenericDAOImpl;

public class ProductImageDAOImpl extends GenericDAOImpl<ProductImage> implements ProductImageDAO {
    public ProductImageDAOImpl() { super(ProductImage.class); }

    @Override
    public List<ProductImage> findByProductId(Long productId) {
        return findMany("FROM ProductImage i WHERE i.product.productId = :productId "
                + "ORDER BY i.primary DESC, i.sortOrder, i.imageId",
                q -> q.setParameter("productId", productId));
    }

    @Override
    public List<ProductImage> findByVariantId(Long variantId) {
        return findMany("FROM ProductImage i WHERE i.variant.variantId = :variantId "
                + "ORDER BY i.primary DESC, i.sortOrder, i.imageId",
                q -> q.setParameter("variantId", variantId));
    }

    @Override
    public Optional<ProductImage> findPrimaryByProductId(Long productId) {
        return findOne("FROM ProductImage i WHERE i.product.productId = :productId "
                + "AND i.primary = true ORDER BY i.sortOrder, i.imageId",
                q -> q.setParameter("productId", productId));
    }
}
