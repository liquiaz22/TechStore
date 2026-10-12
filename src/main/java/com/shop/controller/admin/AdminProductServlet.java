package com.shop.controller.admin;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import com.shop.entity.Product;
import com.shop.entity.ProductVariant;
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
import com.shop.utils.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/admin/products", "/admin/products/form", "/admin/products/save"})
public class AdminProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int PAGE_SIZE = 15;
    private static final Set<String> PRODUCT_STATUSES = Set.of("ACTIVE", "DRAFT", "INACTIVE");
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
                String editVariantId = request.getParameter("editVariant");
                if (editVariantId != null && !editVariantId.isBlank()) {
                    ProductVariant editingVariant = variantService.findById(Long.valueOf(editVariantId));
                    if (editingVariant == null
                            || !editingVariant.getProduct().getProductId().equals(id)) {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND);
                        return;
                    }
                    request.setAttribute("editingVariant", editingVariant);
                }
            }
            WebUtil.forward(request, response, "admin/product-form");
            return;
        }
        String keyword = ValidationUtil.optionalText(request.getParameter("q"), "Từ khóa", 150);
        String status = WebUtil.trimToNull(request.getParameter("status"));
        if (status != null && !PRODUCT_STATUSES.contains(status)) status = null;
        String normalizedKeyword = keyword == null ? null : keyword.toLowerCase(Locale.ROOT);
        String selectedStatus = status;
        List<Product> filtered = productService.findAll().stream()
                .filter(product -> normalizedKeyword == null
                        || product.getName().toLowerCase(Locale.ROOT).contains(normalizedKeyword)
                        || product.getSlug().toLowerCase(Locale.ROOT).contains(normalizedKeyword))
                .filter(product -> selectedStatus == null
                        || selectedStatus.equals(product.getStatus()))
                .toList();
        int totalPages = Math.max(1, (int) Math.ceil(filtered.size() / (double) PAGE_SIZE));
        int page = Math.min(parsePage(request.getParameter("page")), totalPages);
        int fromIndex = Math.min((page - 1) * PAGE_SIZE, filtered.size());
        int toIndex = Math.min(fromIndex + PAGE_SIZE, filtered.size());
        request.setAttribute("products", filtered.subList(fromIndex, toIndex));
        request.setAttribute("totalProducts", filtered.size());
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
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
            WebUtil.redirect(request, response, "/admin/products/form?id=" + product.getProductId()
                    + productReturnQuery(request));
        } catch (RuntimeException ex) {
            WebUtil.error(request, ex.getMessage());
            WebUtil.redirect(request, response, "/admin/products");
        }
    }

    private int parsePage(String value) {
        try {
            return value == null || value.isBlank() ? 1 : Math.max(1, Integer.parseInt(value));
        } catch (NumberFormatException ex) {
            return 1;
        }
    }

    private String productReturnQuery(HttpServletRequest request) {
        StringBuilder query = new StringBuilder();
        appendQuery(query, "q", request.getParameter("q"));
        appendQuery(query, "listStatus", request.getParameter("listStatus"));
        appendQuery(query, "page", request.getParameter("page"));
        return query.toString();
    }

    private void appendQuery(StringBuilder query, String name, String value) {
        String normalized = WebUtil.trimToNull(value);
        if (normalized == null) return;
        query.append('&').append(name).append('=')
                .append(URLEncoder.encode(normalized, StandardCharsets.UTF_8));
    }

    private String required(HttpServletRequest request, String name) {
        String value = WebUtil.trimToNull(request.getParameter(name));
        if (value == null) throw new IllegalArgumentException(name + " không được để trống.");
        return value;
    }
}
