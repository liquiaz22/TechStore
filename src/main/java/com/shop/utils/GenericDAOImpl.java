package com.shop.utils;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;

import java.util.List;
import java.util.Optional;
import java.util.function.Consumer;

public abstract class GenericDAOImpl<T> implements GenericDAO<T> {

    private final Class<T> entityClass;

    public GenericDAOImpl(Class<T> entityClass) {
        this.entityClass = entityClass;
    }

    /**
     * Create
     */
    @Override
    public boolean create(T entity) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        
        try {
            transaction.begin();
            em.persist(entity);
            transaction.commit();
            return true;
        } catch (RuntimeException e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            throw e;
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    /**
     * Update
     */
    @Override
    public T update(T entity) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        
        try {
            transaction.begin();
            T updatedEntity = em.merge(entity);
            transaction.commit();
            return updatedEntity;
        } catch (RuntimeException e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            throw e;
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    /**
     * Delete by id
     */
    @Override
    public boolean delete(Object id) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        
        try {
            transaction.begin();
            T entity = em.find(entityClass, id);
            if (entity == null) {
                transaction.rollback();
                return false;
            }
            em.remove(entity);
            transaction.commit();
            return true;
        } catch (RuntimeException e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            throw e;
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    /**
     * Find by id
     */
    @Override
    public T findById(Object id) {
        EntityManager em = JpaUtil.getEntityManager();
        
        try {
            return em.find(entityClass, id);
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    /**
     * Find all
     */
    @Override
    public List<T> findAll() {
        EntityManager em = JpaUtil.getEntityManager();
        
        try {
            String jpql = "FROM " + entityClass.getSimpleName();
            TypedQuery<T> query = em.createQuery(jpql, entityClass);
            return query.getResultList();
        } finally {
            if (em != null && em.isOpen()) {
                em.close(); 
            }
        }
    }

    /**
     * Count
     */
    @Override
    public long count() {
        EntityManager em = JpaUtil.getEntityManager();
        
        try {
            String jpql = "SELECT COUNT(e) FROM " + entityClass.getSimpleName() + " e";
            return em.createQuery(jpql, Long.class).getSingleResult();
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    /**
     * Check exists
     */
    @Override
    public boolean exists(Object id) {
        return findById(id) != null;
    }

    protected Optional<T> findOne(String jpql, Consumer<TypedQuery<T>> binder) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<T> query = em.createQuery(jpql, entityClass);
            binder.accept(query);
            return query.setMaxResults(1).getResultStream().findFirst();
        } finally {
            em.close();
        }
    }

    protected List<T> findMany(String jpql, Consumer<TypedQuery<T>> binder) {
        return findMany(jpql, binder, 0, Integer.MAX_VALUE);
    }

    protected List<T> findMany(String jpql, Consumer<TypedQuery<T>> binder,
            int offset, int limit) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            TypedQuery<T> query = em.createQuery(jpql, entityClass);
            binder.accept(query);
            query.setFirstResult(Math.max(0, offset));
            if (limit > 0 && limit < Integer.MAX_VALUE) query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    protected int executeUpdate(String jpql, Consumer<jakarta.persistence.Query> binder) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            jakarta.persistence.Query query = em.createQuery(jpql);
            binder.accept(query);
            int affected = query.executeUpdate();
            transaction.commit();
            return affected;
        } catch (RuntimeException e) {
            if (transaction.isActive()) transaction.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

}
