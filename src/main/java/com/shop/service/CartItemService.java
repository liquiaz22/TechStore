package com.shop.service;

import java.util.List;

import com.shop.entity.CartItem;

public interface CartItemService extends GenericService<CartItem> {
    List<CartItem> findByCartId(Long cartId);
}
