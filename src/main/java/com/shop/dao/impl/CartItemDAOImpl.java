package com.shop.dao.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.CartItemDAO;
import com.shop.entity.CartItem;
import com.shop.utils.GenericDAOImpl;

public class CartItemDAOImpl extends GenericDAOImpl<CartItem> implements CartItemDAO {
    public CartItemDAOImpl() { super(CartItem.class); }

    @Override
    public List<CartItem> findByCartId(Long cartId) {
        return findMany("SELECT ci FROM CartItem ci JOIN FETCH ci.variant v "
                + "JOIN FETCH v.product WHERE ci.cart.cartId = :cartId ORDER BY ci.cartItemId",
                q -> q.setParameter("cartId", cartId));
    }

    @Override
    public Optional<CartItem> findByCartAndVariant(Long cartId, Long variantId) {
        return findOne("FROM CartItem ci WHERE ci.cart.cartId = :cartId "
                + "AND ci.variant.variantId = :variantId",
                q -> q.setParameter("cartId", cartId).setParameter("variantId", variantId));
    }

    @Override
    public int deleteByCartId(Long cartId) {
        return executeUpdate("DELETE FROM CartItem ci WHERE ci.cart.cartId = :cartId",
                q -> q.setParameter("cartId", cartId));
    }
}
