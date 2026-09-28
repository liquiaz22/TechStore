package com.shop.dao;

import java.util.Optional;

import com.shop.entity.Cart;
import com.shop.utils.GenericDAO;

public interface CartDAO extends GenericDAO<Cart> {
    Optional<Cart> findActiveByUserId(Long userId);
}
