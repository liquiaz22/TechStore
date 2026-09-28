package com.shop.controller;

import java.io.IOException;

import com.shop.service.ProductImageService;
import com.shop.service.ProductService;
import com.shop.service.ProductSpecificationService;
import com.shop.service.ProductVariantService;
import com.shop.service.impl.ProductImageServiceImpl;
import com.shop.service.impl.ProductServiceImpl;
import com.shop.service.impl.ProductSpecificationServiceImpl;
import com.shop.service.impl.ProductVariantServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/product")
public class ProductDetailServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ProductService productService = new ProductServiceImpl();
    private final ProductVariantService variantService = new ProductVariantServiceImpl();
    private final ProductImageService imageService = new ProductImageServiceImpl();
    private final ProductSpecificationService specificationService =
            new ProductSpecificationServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String slug = request.getParameter("slug");
        var product = productService.findBySlug(slug).orElse(null);
        if (product == null || !"ACTIVE".equals(product.getStatus())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        request.setAttribute("product", product);
        request.setAttribute("variants", variantService.findByProductId(product.getProductId()));
        request.setAttribute("images", imageService.findByProductId(product.getProductId()));
        request.setAttribute("specifications",
                specificationService.findByProductId(product.getProductId()));
        WebUtil.forward(request, response, "product/detail");
    }
}
