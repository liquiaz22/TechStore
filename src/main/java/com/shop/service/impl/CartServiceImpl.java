package com.shop.service.impl;

import java.math.BigDecimal;
import java.util.List;

import com.shop.dao.CartDAO;
import com.shop.dao.CartItemDAO;
import com.shop.dao.ProductVariantDAO;
import com.shop.dao.UserDAO;
import com.shop.dao.impl.CartDAOImpl;
import com.shop.dao.impl.CartItemDAOImpl;
import com.shop.dao.impl.ProductVariantDAOImpl;
import com.shop.dao.impl.UserDAOImpl;
import com.shop.entity.Cart;
import com.shop.entity.CartItem;
import com.shop.entity.ProductVariant;
import com.shop.entity.User;
import com.shop.service.CartService;

public class CartServiceImpl extends AbstractService<Cart> implements CartService {
    private final CartDAO cartDAO;
    private final CartItemDAO cartItemDAO;
    private final ProductVariantDAO variantDAO;
    private final UserDAO userDAO;

    public CartServiceImpl() {
        this(new CartDAOImpl(), new CartItemDAOImpl(), new ProductVariantDAOImpl(), new UserDAOImpl());
    }

    public CartServiceImpl(CartDAO cartDAO, CartItemDAO cartItemDAO,
            ProductVariantDAO variantDAO, UserDAO userDAO) {
        super(cartDAO);
        this.cartDAO = cartDAO;
        this.cartItemDAO = cartItemDAO;
        this.variantDAO = variantDAO;
        this.userDAO = userDAO;
    }

    @Override public Cart getOrCreateActiveCart(Long userId) {
        return cartDAO.findActiveByUserId(userId).orElseGet(() -> {
            User user = userDAO.findById(userId);
            if (user == null) throw new IllegalArgumentException("User not found");
            Cart cart = new Cart();
            cart.setUser(user);
            cartDAO.create(cart);
            return cart;
        });
    }

    @Override public List<CartItem> getItems(Long userId) {
        return cartDAO.findActiveByUserId(userId)
                .map(cart -> cartItemDAO.findByCartId(cart.getCartId()))
                .orElseGet(List::of);
    }

    @Override public long countItems(Long userId) {
        return cartItemDAO.countQuantityByUserId(userId);
    }

    @Override public CartItem addItem(Long userId, Long variantId, int quantity) {
        if (quantity <= 0) throw new IllegalArgumentException("Số lượng phải lớn hơn 0.");
        Cart cart = getOrCreateActiveCart(userId);
        ProductVariant variant = requireAvailableVariant(variantId, quantity);
        CartItem item = cartItemDAO.findByCartAndVariant(cart.getCartId(), variantId).orElse(null);
        if (item == null) {
            item = new CartItem();
            item.setCart(cart);
            item.setVariant(variant);
            item.setQuantity(quantity);
            cartItemDAO.create(item);
        } else {
            int newQuantity = item.getQuantity() + quantity;
            if (newQuantity > variant.getStockQuantity()) {
                throw new IllegalArgumentException("Số lượng yêu cầu vượt quá tồn kho.");
            }
            item.setQuantity(newQuantity);
            item = cartItemDAO.update(item);
        }
        return item;
    }

    @Override public CartItem updateQuantity(Long userId, Long variantId, int quantity) {
        if (quantity <= 0) throw new IllegalArgumentException("Số lượng phải lớn hơn 0.");
        Cart cart = cartDAO.findActiveByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Active cart not found"));
        ProductVariant variant = requireAvailableVariant(variantId, quantity);
        CartItem item = cartItemDAO.findByCartAndVariant(cart.getCartId(), variantId)
                .orElseThrow(() -> new IllegalArgumentException("Cart item not found"));
        item.setVariant(variant);
        item.setQuantity(quantity);
        return cartItemDAO.update(item);
    }

    @Override public boolean removeItem(Long userId, Long variantId) {
        return cartDAO.findActiveByUserId(userId)
                .flatMap(cart -> cartItemDAO.findByCartAndVariant(cart.getCartId(), variantId))
                .map(item -> cartItemDAO.delete(item.getCartItemId()))
                .orElse(false);
    }

    @Override public BigDecimal calculateSubtotal(Long userId) {
        return getItems(userId).stream()
                .map(item -> item.getVariant().getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private ProductVariant requireAvailableVariant(Long variantId, int quantity) {
        ProductVariant variant = variantDAO.findById(variantId);
        if (variant == null || !variant.isActive() || !"ACTIVE".equals(variant.getProduct().getStatus())) {
            throw new IllegalArgumentException("Phiên bản sản phẩm hiện không khả dụng.");
        }
        if (quantity > variant.getStockQuantity()) {
            throw new IllegalArgumentException("Số lượng yêu cầu vượt quá tồn kho.");
        }
        return variant;
    }
}
