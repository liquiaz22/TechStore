package com.shop.service;

import java.math.BigDecimal;
import java.util.List;

import com.shop.entity.Cart;
import com.shop.entity.CartItem;

public interface CartService extends GenericService<Cart> {
    Cart getOrCreateActiveCart(Long userId);
    List<CartItem> getItems(Long userId);
    long countItems(Long userId);
    CartItem addItem(Long userId, Long variantId, int quantity);
    CartItem updateQuantity(Long userId, Long variantId, int quantity);
    boolean removeItem(Long userId, Long variantId);
    BigDecimal calculateSubtotal(Long userId);
}
