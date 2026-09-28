package com.shop.controller;

import java.io.IOException;

import com.shop.service.CartService;
import com.shop.service.impl.CartServiceImpl;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        request.setAttribute("cartItems", cartService.getItems(userId));
        request.setAttribute("subtotal", cartService.calculateSubtotal(userId));
        WebUtil.forward(request, response, "cart");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        try {
            Long variantId = WebUtil.longParam(request, "variantId");
            String path = request.getServletPath();
            if (path.endsWith("/add")) {
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                cartService.addItem(userId, variantId, quantity);
                WebUtil.success(request, "Đã thêm sản phẩm vào giỏ hàng.");
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
        WebUtil.redirect(request, response, "/cart");
    }
}
