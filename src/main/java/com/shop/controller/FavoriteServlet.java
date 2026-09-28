package com.shop.controller;

import java.io.IOException;

import com.shop.service.FavoriteService;
import com.shop.service.impl.FavoriteServiceImpl;
import com.shop.service.impl.ProductImageServiceImpl;
import com.shop.service.impl.ProductVariantServiceImpl;
import com.shop.utils.ProductViewMapper;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/favorites", "/favorites/toggle"})
public class FavoriteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final FavoriteService favoriteService = new FavoriteServiceImpl();
    private final ProductViewMapper viewMapper = new ProductViewMapper(
            new ProductVariantServiceImpl(), new ProductImageServiceImpl());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        request.setAttribute("productCards", favoriteService.findByUserId(userId).stream()
                .map(favorite -> viewMapper.toCard(favorite.getProduct())).toList());
        WebUtil.forward(request, response, "favorites");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        Long productId = WebUtil.longParam(request, "productId");
        if (favoriteService.isFavorite(userId, productId)) {
            favoriteService.remove(userId, productId);
            WebUtil.success(request, "Đã bỏ sản phẩm khỏi danh sách yêu thích.");
        } else {
            favoriteService.add(userId, productId);
            WebUtil.success(request, "Đã thêm sản phẩm vào danh sách yêu thích.");
        }
        String back = request.getParameter("back");
        WebUtil.redirect(request, response, back != null && back.startsWith("/") ? back : "/favorites");
    }
}
