package com.shop.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.shop.dto.HomeCategorySectionDTO;
import com.shop.dto.ProductCardDTO;
import com.shop.entity.Category;
import com.shop.entity.Product;
import com.shop.service.BrandService;
import com.shop.service.CategoryService;
import com.shop.service.ProductService;
import com.shop.service.impl.BrandServiceImpl;
import com.shop.service.impl.CategoryServiceImpl;
import com.shop.service.impl.ProductImageServiceImpl;
import com.shop.service.impl.ProductServiceImpl;
import com.shop.service.impl.ProductVariantServiceImpl;
import com.shop.utils.ProductViewMapper;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet({"/home", "/products"})
public class HomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ProductService productService = new ProductServiceImpl();
    private final CategoryService categoryService = new CategoryServiceImpl();
    private final BrandService brandService = new BrandServiceImpl();
    private final ProductViewMapper viewMapper = new ProductViewMapper(
            new ProductVariantServiceImpl(), new ProductImageServiceImpl());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("/home".equals(request.getServletPath()) && !hasCatalogParameters(request)) {
            showHome(request, response);
            return;
        }
        showCatalog(request, response);
    }

    private void showHome(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Category> categories = categoryService.findByParentId(null).stream()
                    .filter(Category::isActive)
                    .toList();
            Map<Long, ProductCardDTO> cardCache = new HashMap<>();
            var featuredProducts = productService.search(null, null, null,
                    null, null, "latest", 0, 8).stream()
                    .map(product -> cachedCard(product, cardCache))
                    .toList();
            List<HomeCategorySectionDTO> sections = new ArrayList<>();
            for (Category category : categories) {
                var cards = productService.search(null, category.getCategoryId(), null,
                                null, null, "latest", 0, 4).stream()
                        .map(product -> cachedCard(product, cardCache))
                        .toList();
                if (!cards.isEmpty()) {
                    sections.add(new HomeCategorySectionDTO(category.getCategoryId(),
                            category.getName(), category.getSlug(), cards));
                }
            }
            request.setAttribute("homeCategories", categories);
            request.setAttribute("featuredProducts", featuredProducts);
            request.setAttribute("homeSections", sections);
            WebUtil.forward(request, response, "home");
        } catch (RuntimeException ex) {
            getServletContext().log("Khong the tai trang chu", ex);
            request.setAttribute("pageError",
                    "Chưa thể tải dữ liệu sản phẩm. Hãy kiểm tra kết nối SQL Server tại trang trạng thái.");
            request.setAttribute("homeCategories", List.of());
            request.setAttribute("featuredProducts", List.of());
            request.setAttribute("homeSections", List.of());
            WebUtil.forward(request, response, "home");
        }
    }

    private void showCatalog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String keyword = WebUtil.trimToNull(request.getParameter("q"));
            Integer categoryId = WebUtil.integerParam(request, "categoryId");
            Integer brandId = WebUtil.integerParam(request, "brandId");
            BigDecimal minPrice = WebUtil.decimalParam(request, "minPrice");
            BigDecimal maxPrice = WebUtil.decimalParam(request, "maxPrice");
            String sort = normalizeSort(request.getParameter("sort"));
            int currentPage = request.getParameter("page") == null
                    ? 1 : Math.max(1, Integer.parseInt(request.getParameter("page")));
            int pageSize = 12;

            var products = productService.search(keyword, categoryId, brandId,
                    minPrice, maxPrice, sort, currentPage - 1, pageSize);
            long total = productService.countSearch(keyword, categoryId, brandId, minPrice, maxPrice);
            var categories = categoryService.findActive();
            var brands = brandService.findActive();
            request.setAttribute("productCards", products.stream().map(viewMapper::toCard).toList());
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.setAttribute("totalProducts", total);
            request.setAttribute("selectedCategoryName", categories.stream()
                    .filter(category -> categoryId != null && categoryId.equals(category.getCategoryId()))
                    .map(Category::getName).findFirst().orElse(null));
            request.setAttribute("selectedBrandName", brands.stream()
                    .filter(brand -> brandId != null && brandId.equals(brand.getBrandId()))
                    .map(brand -> brand.getName()).findFirst().orElse(null));
            request.setAttribute("hasCatalogFilters", keyword != null || categoryId != null
                    || brandId != null || minPrice != null || maxPrice != null
                    || !"latest".equals(sort));
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("sort", sort);
            request.setAttribute("pageCount", Math.max(1, (int) Math.ceil((double) total / pageSize)));
            WebUtil.forward(request, response, "products");
        } catch (RuntimeException ex) {
            getServletContext().log("Khong the tai danh sach san pham", ex);
            request.setAttribute("pageError",
                    "Chưa thể tải dữ liệu sản phẩm. Hãy kiểm tra kết nối SQL Server tại trang trạng thái.");
            request.setAttribute("productCards", java.util.List.of());
            request.setAttribute("categories", java.util.List.of());
            request.setAttribute("brands", java.util.List.of());
            request.setAttribute("totalProducts", 0L);
            request.setAttribute("hasCatalogFilters", false);
            request.setAttribute("currentPage", 1);
            request.setAttribute("pageCount", 1);
            WebUtil.forward(request, response, "products");
        }
    }

    private boolean hasCatalogParameters(HttpServletRequest request) {
        return WebUtil.trimToNull(request.getParameter("q")) != null
                || WebUtil.trimToNull(request.getParameter("categoryId")) != null
                || WebUtil.trimToNull(request.getParameter("brandId")) != null
                || WebUtil.trimToNull(request.getParameter("minPrice")) != null
                || WebUtil.trimToNull(request.getParameter("maxPrice")) != null
                || WebUtil.trimToNull(request.getParameter("sort")) != null
                || WebUtil.trimToNull(request.getParameter("page")) != null;
    }

    private ProductCardDTO cachedCard(Product product, Map<Long, ProductCardDTO> cache) {
        return cache.computeIfAbsent(product.getProductId(), ignored -> viewMapper.toCard(product));
    }

    private String normalizeSort(String sort) {
        return switch (sort == null ? "" : sort) {
            case "price_asc", "price_desc" -> sort;
            default -> "latest";
        };
    }
}
