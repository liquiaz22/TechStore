package com.shop.dao.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.ProductImageDAO;
import com.shop.entity.ProductImage;
import com.shop.entity.Product;
import com.shop.entity.ProductVariant;
import com.shop.utils.GenericDAOImpl;
import com.shop.utils.JpaUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

public class ProductImageDAOImpl extends GenericDAOImpl<ProductImage> implements ProductImageDAO {
    public ProductImageDAOImpl() { super(ProductImage.class); }

    @Override
    public ProductImage findById(Object id) {
        return findOne("SELECT i FROM ProductImage i JOIN FETCH i.product "
                + "LEFT JOIN FETCH i.variant WHERE i.imageId = :id",
                q -> q.setParameter("id", id)).orElse(null);
    }

    @Override
    public List<ProductImage> findByProductId(Long productId) {
        return findMany("SELECT i FROM ProductImage i JOIN FETCH i.product "
                + "LEFT JOIN FETCH i.variant WHERE i.product.productId = :productId "
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

    @Override
    public boolean createWithPrimarySelection(ProductImage image) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            Product product = em.find(Product.class, image.getProduct().getProductId());
            if (product == null) throw new IllegalArgumentException("Không tìm thấy sản phẩm.");
            ProductVariant variant = image.getVariant() == null ? null
                    : em.find(ProductVariant.class, image.getVariant().getVariantId());
            if (variant != null && !variant.getProduct().getProductId().equals(product.getProductId())) {
                throw new IllegalArgumentException("Phiên bản ảnh không thuộc sản phẩm đã chọn.");
            }
            image.setProduct(product);
            image.setVariant(variant);
            if (image.isPrimary()) clearPrimary(em, product.getProductId(), variant);
            em.persist(image);
            transaction.commit();
            return true;
        } catch (RuntimeException ex) {
            if (transaction.isActive()) transaction.rollback();
            throw ex;
        } finally {
            em.close();
        }
    }

    @Override
    public ProductImage updateMetadata(Long productId, Long imageId, int sortOrder, boolean primary) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            ProductImage image = em.find(ProductImage.class, imageId);
            if (image == null || !image.getProduct().getProductId().equals(productId)) {
                throw new IllegalArgumentException("Không tìm thấy hình ảnh của sản phẩm.");
            }
            if (primary) clearPrimary(em, productId, image.getVariant());
            image.setSortOrder(sortOrder);
            image.setPrimary(primary);
            transaction.commit();
            return image;
        } catch (RuntimeException ex) {
            if (transaction.isActive()) transaction.rollback();
            throw ex;
        } finally {
            em.close();
        }
    }

    private void clearPrimary(EntityManager em, Long productId, ProductVariant variant) {
        if (variant == null) {
            em.createQuery("UPDATE ProductImage i SET i.primary = false "
                            + "WHERE i.product.productId = :productId AND i.variant IS NULL "
                            + "AND i.primary = true")
                    .setParameter("productId", productId)
                    .executeUpdate();
        } else {
            em.createQuery("UPDATE ProductImage i SET i.primary = false "
                            + "WHERE i.variant.variantId = :variantId AND i.primary = true")
                    .setParameter("variantId", variant.getVariantId())
                    .executeUpdate();
        }
    }
}
