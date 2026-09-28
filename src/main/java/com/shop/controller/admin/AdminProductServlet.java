package com.shop.controller.admin;

import java.io.IOException;

import com.shop.entity.Product;
import com.shop.service.BrandService;
import com.shop.service.CategoryService;
import com.shop.service.ProductImageService;
import com.shop.service.ProductService;
import com.shop.service.ProductSpecificationService;
import com.shop.service.ProductVariantService;
import com.shop.service.impl.BrandServiceImpl;
import com.shop.service.impl.CategoryServiceImpl;
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

@WebServlet(urlPatterns = {"/admin/products", "/admin/products/form", "/admin/products/save"})
public class AdminProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ProductService productService = new ProductServiceImpl();
    private final CategoryService categoryService = new CategoryServiceImpl();
    private final BrandService brandService = new BrandServiceImpl();
    private final ProductVariantService variantService = new ProductVariantServiceImpl();
    private final ProductImageService imageService = new ProductImageServiceImpl();
    private final ProductSpecificationService specificationService =
            new ProductSpecificationServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getServletPath().endsWith("/form")) {
            Long id = request.getParameter("id") == null ? null : Long.valueOf(request.getParameter("id"));
            Product product = id == null ? new Product() : productService.findById(id);
            if (id != null && product == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            request.setAttribute("product", product);
            request.setAttribute("categories", categoryService.findActive());
            request.setAttribute("brands", brandService.findActive());
            if (id != null) {
                request.setAttribute("variants", variantService.findByProductId(id));
                request.setAttribute("images", imageService.findByProductId(id));
                request.setAttribute("specifications", specificationService.findByProductId(id));
            }
            WebUtil.forward(request, response, "admin/product-form");
            return;
        }
        request.setAttribute("products", productService.findAll());
        WebUtil.forward(request, response, "admin/products");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            Long id = request.getParameter("id") == null || request.getParameter("id").isBlank()
                    ? null : Long.valueOf(request.getParameter("id"));
            Product product = id == null ? new Product() : productService.findById(id);
            if (product == null) throw new IllegalArgumentException("Không tìm thấy sản phẩm.");
            product.setName(required(request, "name"));
            product.setSlug(required(request, "slug"));
            product.setShortDescription(WebUtil.trimToNull(request.getParameter("shortDescription")));
            product.setDescription(WebUtil.trimToNull(request.getParameter("description")));
            product.setStatus(required(request, "status"));
            product.setCategory(categoryService.findById(Integer.valueOf(required(request, "categoryId"))));
            String brandId = request.getParameter("brandId");
            product.setBrand(brandId == null || brandId.isBlank()
                    ? null : brandService.findById(Integer.valueOf(brandId)));
            if (id == null) productService.create(product); else productService.update(product);
            WebUtil.success(request, "Đã lưu sản phẩm.");
            WebUtil.redirect(request, response, "/admin/products/form?id=" + product.getProductId());
        } catch (RuntimeException ex) {
            WebUtil.error(request, ex.getMessage());
            WebUtil.redirect(request, response, "/admin/products");
        }
    }

    private String required(HttpServletRequest request, String name) {
        String value = WebUtil.trimToNull(request.getParameter(name));
        if (value == null) throw new IllegalArgumentException(name + " không được để trống.");
        return value;
    }
}
