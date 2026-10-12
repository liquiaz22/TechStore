package com.shop.dao;

import com.shop.entity.Addresses;
import com.shop.utils.GenericDAO;

import java.util.List;
import java.util.Optional;

public interface AddressesDAO extends GenericDAO<Addresses> {
    List<Addresses> findByUserId(Long userId);
    Optional<Addresses> findDefaultByUserId(Long userId);
    int clearDefaultByUserId(Long userId);
    Addresses saveForUser(Long userId, Addresses address);
    boolean deleteForUser(Long userId, Long addressId);
    boolean setDefaultForUser(Long userId, Long addressId);
}
