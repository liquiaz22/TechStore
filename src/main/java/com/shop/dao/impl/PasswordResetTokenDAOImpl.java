package com.shop.dao.impl;

import java.time.LocalDateTime;

import com.shop.dao.PasswordResetTokenDAO;
import com.shop.entity.PasswordResetToken;
import com.shop.entity.User;
import com.shop.utils.GenericDAOImpl;
import com.shop.utils.JpaUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.LockModeType;

public class PasswordResetTokenDAOImpl extends GenericDAOImpl<PasswordResetToken>
        implements PasswordResetTokenDAO {

    public PasswordResetTokenDAOImpl() {
        super(PasswordResetToken.class);
    }

    @Override
    public long countCreatedSince(Long userId, LocalDateTime since) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT COUNT(t) FROM PasswordResetToken t "
                            + "WHERE t.user.userId = :userId AND t.createdAt >= :since", Long.class)
                    .setParameter("userId", userId)
                    .setParameter("since", since)
                    .getSingleResult();
        } finally {
            em.close();
        }
    }

    @Override
    public void replaceActiveToken(Long userId, PasswordResetToken token, LocalDateTime now) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            User user = em.find(User.class, userId);
            if (user == null) throw new IllegalArgumentException("Không tìm thấy tài khoản.");
            em.createQuery("UPDATE PasswordResetToken t SET t.usedAt = :now "
                            + "WHERE t.user.userId = :userId AND t.usedAt IS NULL")
                    .setParameter("now", now)
                    .setParameter("userId", userId)
                    .executeUpdate();
            token.setUser(user);
            em.persist(token);
            transaction.commit();
        } catch (RuntimeException ex) {
            if (transaction.isActive()) transaction.rollback();
            throw ex;
        } finally {
            em.close();
        }
    }

    @Override
    public void invalidate(String tokenHash, LocalDateTime now) {
        executeUpdate("UPDATE PasswordResetToken t SET t.usedAt = :now "
                        + "WHERE t.tokenHash = :tokenHash AND t.usedAt IS NULL",
                query -> {
                    query.setParameter("now", now);
                    query.setParameter("tokenHash", tokenHash);
                });
    }

    @Override
    public boolean consumeAndChangePassword(String tokenHash, String passwordHash, LocalDateTime now) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            PasswordResetToken token = em.createQuery(
                            "SELECT t FROM PasswordResetToken t JOIN FETCH t.user "
                                    + "WHERE t.tokenHash = :tokenHash", PasswordResetToken.class)
                    .setParameter("tokenHash", tokenHash)
                    .setLockMode(LockModeType.PESSIMISTIC_WRITE)
                    .setMaxResults(1)
                    .getResultStream()
                    .findFirst()
                    .orElse(null);
            if (token == null || token.getUsedAt() != null || !token.getExpiresAt().isAfter(now)
                    || !"ACTIVE".equals(token.getUser().getStatus())) {
                transaction.rollback();
                return false;
            }
            token.getUser().setPasswordHash(passwordHash);
            token.setUsedAt(now);
            em.createQuery("UPDATE PasswordResetToken t SET t.usedAt = :now "
                            + "WHERE t.user.userId = :userId AND t.usedAt IS NULL "
                            + "AND t.passwordResetTokenId <> :tokenId")
                    .setParameter("now", now)
                    .setParameter("userId", token.getUser().getUserId())
                    .setParameter("tokenId", token.getPasswordResetTokenId())
                    .executeUpdate();
            transaction.commit();
            return true;
        } catch (RuntimeException ex) {
            if (transaction.isActive()) transaction.rollback();
            throw ex;
        } finally {
            em.close();
        }
    }
}
