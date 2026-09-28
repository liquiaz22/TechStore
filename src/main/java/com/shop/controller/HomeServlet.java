package com.shop.controller;

import java.io.IOException;
import java.math.BigDecimal;

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
            request.setAttribute("productCards", products.stream().map(viewMapper::toCard).toList());
            request.setAttribute("categories", categoryService.findActive());
            request.setAttribute("brands", brandService.findActive());
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("sort", sort);
            request.setAttribute("pageCount", Math.max(1, (int) Math.ceil((double) total / pageSize)));
            WebUtil.forward(request, response, "home");
        } catch (RuntimeException ex) {
            getServletContext().log("Khong the tai danh sach san pham", ex);
            request.setAttribute("pageError",
                    "Chưa thể tải dữ liệu sản phẩm. Hãy kiểm tra kết nối SQL Server tại trang trạng thái.");
            request.setAttribute("productCards", java.util.List.of());
            request.setAttribute("categories", java.util.List.of());
            request.setAttribute("brands", java.util.List.of());
            request.setAttribute("currentPage", 1);
            request.setAttribute("pageCount", 1);
            WebUtil.forward(request, response, "home");
        }
    }

    private String normalizeSort(String sort) {
        return switch (sort == null ? "" : sort) {
            case "price_asc", "price_desc" -> sort;
            default -> "latest";
        };
    }
}
