package com.shop.service.impl;

import java.util.List;

import com.shop.dao.CartItemDAO;
import com.shop.dao.impl.CartItemDAOImpl;
import com.shop.entity.CartItem;
import com.shop.service.CartItemService;

public class CartItemServiceImpl extends AbstractService<CartItem> implements CartItemService {
    private final CartItemDAO cartItemDAO;
    public CartItemServiceImpl() { this(new CartItemDAOImpl()); }
    public CartItemServiceImpl(CartItemDAO dao) { super(dao); this.cartItemDAO = dao; }
    @Override public List<CartItem> findByCartId(Long id) { return cartItemDAO.findByCartId(id); }
}
