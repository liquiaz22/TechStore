package com.shop.dao.impl;

import java.util.List;

import com.shop.dao.FavoriteDAO;
import com.shop.entity.Favorite;
import com.shop.entity.FavoriteId;
import com.shop.entity.Product;
import com.shop.entity.User;
import com.shop.utils.GenericDAOImpl;
import com.shop.utils.JpaUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

public class FavoriteDAOImpl extends GenericDAOImpl<Favorite> implements FavoriteDAO {
    public FavoriteDAOImpl() { super(Favorite.class); }

    @Override
    public boolean create(Favorite favorite) {
        if (favorite == null || favorite.getUser() == null || favorite.getProduct() == null) {
            throw new IllegalArgumentException("Favorite user and product are required");
        }

        Long userId = favorite.getUser().getUserId();
        Long productId = favorite.getProduct().getProductId();
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            User managedUser = em.getReference(User.class, userId);
            Product managedProduct = em.getReference(Product.class, productId);
            em.persist(new Favorite(managedUser, managedProduct));
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
    public List<Favorite> findByUserId(Long userId) {
        return findMany("SELECT f FROM Favorite f JOIN FETCH f.product p "
                + "JOIN FETCH p.category LEFT JOIN FETCH p.brand WHERE f.user.userId = :userId "
                + "ORDER BY f.createdAt DESC",
                q -> q.setParameter("userId", userId));
    }

    @Override
    public List<Long> findProductIdsByUserId(Long userId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT f.product.productId FROM Favorite f "
                            + "WHERE f.user.userId = :userId", Long.class)
                    .setParameter("userId", userId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public long countByUserId(Long userId) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT COUNT(f) FROM Favorite f "
                            + "WHERE f.user.userId = :userId", Long.class)
                    .setParameter("userId", userId)
                    .getSingleResult();
        } finally {
            em.close();
        }
    }

    @Override
    public boolean exists(Long userId, Long productId) {
        return exists(new FavoriteId(userId, productId));
    }

    @Override
    public boolean delete(Long userId, Long productId) {
        return delete(new FavoriteId(userId, productId));
    }
}
