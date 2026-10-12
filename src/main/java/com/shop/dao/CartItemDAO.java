package com.shop.dao;

import java.util.List;
import java.util.Optional;

import com.shop.entity.CartItem;
import com.shop.utils.GenericDAO;

public interface CartItemDAO extends GenericDAO<CartItem> {
    List<CartItem> findByCartId(Long cartId);
    Optional<CartItem> findByCartAndVariant(Long cartId, Long variantId);
    long countQuantityByUserId(Long userId);
    int deleteByCartId(Long cartId);
}
