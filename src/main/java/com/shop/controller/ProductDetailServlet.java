package com.shop.controller;

import java.io.IOException;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.shop.entity.ProductImage;
import com.shop.entity.ProductVariant;
import com.shop.service.ProductImageService;
import com.shop.service.ProductService;
import com.shop.service.ProductSpecificationService;
import com.shop.service.ProductVariantService;
import com.shop.service.impl.ProductImageServiceImpl;
import com.shop.service.impl.ProductServiceImpl;
import com.shop.service.impl.ProductSpecificationServiceImpl;
import com.shop.service.impl.ProductVariantServiceImpl;
import com.shop.utils.WebUtil;
import com.shop.utils.ProductViewMapper;

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
    private final ProductViewMapper viewMapper = new ProductViewMapper(variantService, imageService);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String slug = request.getParameter("slug");
        var product = productService.findBySlug(slug).orElse(null);
        if (product == null || !"ACTIVE".equals(product.getStatus())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        List<ProductVariant> variants = variantService.findByProductId(product.getProductId());
        List<ProductImage> images = imageService.findByProductId(product.getProductId());
        ProductVariant selectedVariant = variants.stream()
                .filter(variant -> variant.isActive() && variant.getStockQuantity() > 0)
                .findFirst().orElse(null);
        Map<Long, String> variantImageUrls = new LinkedHashMap<>();
        for (ProductImage image : images) {
            if (image.getVariant() != null) {
                variantImageUrls.putIfAbsent(image.getVariant().getVariantId(), image.getImageUrl());
            }
        }

        var relatedProducts = productService.search(null, product.getCategory().getCategoryId(), null,
                        null, null, "latest", 0, 5).stream()
                .filter(item -> !item.getProductId().equals(product.getProductId()))
                .limit(4)
                .map(viewMapper::toCard)
                .toList();

        request.setAttribute("product", product);
        request.setAttribute("variants", variants);
        request.setAttribute("selectedVariant", selectedVariant);
        request.setAttribute("images", images);
        request.setAttribute("variantImageUrls", variantImageUrls);
        request.setAttribute("descriptionParagraphs", descriptionParagraphs(product.getDescription()));
        request.setAttribute("relatedProducts", relatedProducts);
        request.setAttribute("specifications",
                specificationService.findByProductId(product.getProductId()));
        WebUtil.forward(request, response, "product/detail");
    }

    private List<String> descriptionParagraphs(String description) {
        if (description == null || description.isBlank()) return List.of();
        return Arrays.stream(description.replace("\r\n", "\n").split("\\n\\s*\\n|\\n"))
                .map(String::trim)
                .filter(paragraph -> !paragraph.isEmpty())
                .toList();
    }
}
