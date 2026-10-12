package com.shop.dao.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.AddressesDAO;
import com.shop.entity.Addresses;
import com.shop.entity.User;
import com.shop.utils.GenericDAOImpl;
import com.shop.utils.JpaUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

public class AddressesDAOImpl extends GenericDAOImpl<Addresses> implements AddressesDAO {

	public AddressesDAOImpl() {
		super(Addresses.class);
	}

    @Override
    public Addresses findById(Object id) {
        return findOne("SELECT a FROM Addresses a JOIN FETCH a.user WHERE a.addressId = :id",
                q -> q.setParameter("id", id)).orElse(null);
    }

    @Override
    public List<Addresses> findByUserId(Long userId) {
        return findMany("FROM Addresses a WHERE a.user.userId = :userId "
                + "ORDER BY a.defaultAddress DESC, a.addressId DESC",
                q -> q.setParameter("userId", userId));
    }

    @Override
    public Optional<Addresses> findDefaultByUserId(Long userId) {
        return findOne("FROM Addresses a WHERE a.user.userId = :userId "
                + "AND a.defaultAddress = true",
                q -> q.setParameter("userId", userId));
    }

    @Override
    public int clearDefaultByUserId(Long userId) {
        return executeUpdate("UPDATE Addresses a SET a.defaultAddress = false "
                + "WHERE a.user.userId = :userId AND a.defaultAddress = true",
                q -> q.setParameter("userId", userId));
    }

    @Override
    public Addresses saveForUser(Long userId, Addresses address) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            User user = em.find(User.class, userId);
            if (user == null) throw new IllegalArgumentException("Không tìm thấy tài khoản.");

            Addresses target;
            if (address.getAddressId() == null) {
                target = address;
                target.setUser(user);
            } else {
                target = em.find(Addresses.class, address.getAddressId());
                if (target == null || !target.getUser().getUserId().equals(userId)) {
                    throw new IllegalArgumentException("Địa chỉ không thuộc tài khoản này.");
                }
                copyEditableFields(address, target);
            }

            Long addressCount = em.createQuery(
                    "SELECT COUNT(a) FROM Addresses a WHERE a.user.userId = :userId", Long.class)
                    .setParameter("userId", userId)
                    .getSingleResult();
            boolean makeDefault = address.isDefaultAddress() || addressCount == 0
                    || (target.getAddressId() != null && target.isDefaultAddress());
            if (makeDefault) {
                em.createQuery("UPDATE Addresses a SET a.defaultAddress = false "
                                + "WHERE a.user.userId = :userId AND a.defaultAddress = true")
                        .setParameter("userId", userId)
                        .executeUpdate();
            }
            target.setDefaultAddress(makeDefault);
            if (target.getAddressId() == null) em.persist(target);
            transaction.commit();
            return target;
        } catch (RuntimeException ex) {
            if (transaction.isActive()) transaction.rollback();
            throw ex;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean deleteForUser(Long userId, Long addressId) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            Addresses address = em.find(Addresses.class, addressId);
            if (address == null || !address.getUser().getUserId().equals(userId)) {
                transaction.rollback();
                return false;
            }
            boolean wasDefault = address.isDefaultAddress();
            em.remove(address);
            em.flush();
            if (wasDefault) {
                em.createQuery("SELECT a FROM Addresses a WHERE a.user.userId = :userId "
                                + "ORDER BY a.addressId DESC", Addresses.class)
                        .setParameter("userId", userId)
                        .setMaxResults(1)
                        .getResultStream()
                        .findFirst()
                        .ifPresent(next -> next.setDefaultAddress(true));
            }
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
    public boolean setDefaultForUser(Long userId, Long addressId) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            Addresses address = em.find(Addresses.class, addressId);
            if (address == null || !address.getUser().getUserId().equals(userId)) {
                transaction.rollback();
                return false;
            }
            em.createQuery("UPDATE Addresses a SET a.defaultAddress = false "
                            + "WHERE a.user.userId = :userId AND a.defaultAddress = true")
                    .setParameter("userId", userId)
                    .executeUpdate();
            address.setDefaultAddress(true);
            transaction.commit();
            return true;
        } catch (RuntimeException ex) {
            if (transaction.isActive()) transaction.rollback();
            throw ex;
        } finally {
            em.close();
        }
    }

    private void copyEditableFields(Addresses source, Addresses target) {
        target.setReceiverName(source.getReceiverName());
        target.setReceiverPhone(source.getReceiverPhone());
        target.setProvince(source.getProvince());
        target.setDistrict(source.getDistrict());
        target.setWard(source.getWard());
        target.setAddressLine(source.getAddressLine());
    }

}
