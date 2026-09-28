package com.shop.dao.impl;

import java.util.Optional;

import com.shop.dao.CartDAO;
import com.shop.entity.Cart;
import com.shop.utils.GenericDAOImpl;

public class CartDAOImpl extends GenericDAOImpl<Cart> implements CartDAO {
    public CartDAOImpl() { super(Cart.class); }

    @Override
    public Optional<Cart> findActiveByUserId(Long userId) {
        return findOne("SELECT c FROM Cart c JOIN FETCH c.user "
                + "WHERE c.user.userId = :userId AND c.status = 'ACTIVE'",
                q -> q.setParameter("userId", userId));
    }
}
