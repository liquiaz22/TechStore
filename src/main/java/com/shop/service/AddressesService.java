package com.shop.service;

import java.util.List;
import java.util.Optional;

import com.shop.entity.Addresses;

public interface AddressesService extends GenericService<Addresses> {
    List<Addresses> findByUserId(Long userId);
    Optional<Addresses> findDefaultByUserId(Long userId);
    Optional<Addresses> findForUser(Long userId, Long addressId);
    Addresses saveForUser(Long userId, Addresses address);
    void deleteForUser(Long userId, Long addressId);
    void setDefaultForUser(Long userId, Long addressId);
}
