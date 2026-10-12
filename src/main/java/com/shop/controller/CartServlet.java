package com.shop.controller;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import com.shop.entity.CartItem;
import com.shop.service.CartService;
import com.shop.service.ProductImageService;
import com.shop.service.impl.CartServiceImpl;
import com.shop.service.impl.ProductImageServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/cart", "/cart/add", "/cart/update", "/cart/remove"})
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final CartService cartService = new CartServiceImpl();
    private final ProductImageService imageService = new ProductImageServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        var cartItems = cartService.getItems(userId);
        Map<Long, String> cartItemImageUrls = new LinkedHashMap<>();
        for (CartItem item : cartItems) {
            String imageUrl = imageService.findByVariantId(item.getVariant().getVariantId()).stream()
                    .findFirst()
                    .or(() -> imageService.findPrimaryByProductId(
                            item.getVariant().getProduct().getProductId()))
                    .or(() -> imageService.findByProductId(
                            item.getVariant().getProduct().getProductId()).stream().findFirst())
                    .map(image -> image.getImageUrl())
                    .orElse("assets/images/product-placeholder.svg");
            cartItemImageUrls.put(item.getVariant().getVariantId(), imageUrl);
        }
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartItemImageUrls", cartItemImageUrls);
        request.setAttribute("subtotal", cartService.calculateSubtotal(userId));
        WebUtil.forward(request, response, "cart");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        String redirectPath = "/cart";
        try {
            Long variantId = WebUtil.longParam(request, "variantId");
            String path = request.getServletPath();
            if (path.endsWith("/add")) {
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                cartService.addItem(userId, variantId, quantity);
                WebUtil.success(request, "Đã thêm sản phẩm vào giỏ hàng.");
                if ("checkout".equals(request.getParameter("next"))) {
                    redirectPath = "/checkout";
                }
            } else if (path.endsWith("/update")) {
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                cartService.updateQuantity(userId, variantId, quantity);
                WebUtil.success(request, "Đã cập nhật giỏ hàng.");
            } else if (path.endsWith("/remove")) {
                cartService.removeItem(userId, variantId);
                WebUtil.success(request, "Đã xóa sản phẩm khỏi giỏ hàng.");
            }
        } catch (IllegalArgumentException | IllegalStateException ex) {
            WebUtil.error(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, redirectPath);
    }
}
