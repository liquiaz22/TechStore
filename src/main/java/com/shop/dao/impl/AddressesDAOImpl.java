package com.shop.dao.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.AddressesDAO;
import com.shop.entity.Addresses;
import com.shop.utils.GenericDAOImpl;

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

}
