package com.shop.controller.admin;

import java.io.IOException;

import com.shop.entity.Brand;
import com.shop.entity.Category;
import com.shop.service.BrandService;
import com.shop.service.CategoryService;
import com.shop.service.impl.BrandServiceImpl;
import com.shop.service.impl.CategoryServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/catalog")
public class AdminCatalogServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final CategoryService categoryService = new CategoryServiceImpl();
    private final BrandService brandService = new BrandServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("categories", categoryService.findAll());
        request.setAttribute("brands", brandService.findAll());
        Integer editCategoryId = WebUtil.integerParam(request, "editCategory");
        Integer editBrandId = WebUtil.integerParam(request, "editBrand");
        if (editCategoryId != null) {
            request.setAttribute("editCategory", categoryService.findById(editCategoryId));
        }
        if (editBrandId != null) {
            request.setAttribute("editBrand", brandService.findById(editBrandId));
        }
        WebUtil.forward(request, response, "admin/catalog");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String type = request.getParameter("type");
            String action = request.getParameter("action");
            if ("category".equals(type)) handleCategory(request, action);
            else if ("brand".equals(type)) handleBrand(request, action);
            else throw new IllegalArgumentException("Loại dữ liệu không hợp lệ.");
            WebUtil.success(request, "Đã cập nhật dữ liệu catalog.");
        } catch (RuntimeException ex) {
            WebUtil.error(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/admin/catalog");
    }

    private void handleCategory(HttpServletRequest request, String action) {
        if ("toggle".equals(action)) {
            Integer id = WebUtil.integerParam(request, "id");
            Category category = id == null ? null : categoryService.findById(id);
            if (category == null) throw new IllegalArgumentException("Không tìm thấy danh mục.");
            category.setActive(!category.isActive());
            categoryService.update(category);
            return;
        }
        saveCategory(request);
    }

    private void handleBrand(HttpServletRequest request, String action) {
        if ("toggle".equals(action)) {
            Integer id = WebUtil.integerParam(request, "id");
            Brand brand = id == null ? null : brandService.findById(id);
            if (brand == null) throw new IllegalArgumentException("Không tìm thấy thương hiệu.");
            brand.setActive(!brand.isActive());
            brandService.update(brand);
            return;
        }
        saveBrand(request);
    }

    private void saveCategory(HttpServletRequest request) {
        Integer id = WebUtil.integerParam(request, "id");
        Category category = id == null ? new Category() : categoryService.findById(id);
        if (category == null) throw new IllegalArgumentException("Không tìm thấy danh mục.");
        category.setName(required(request, "name"));
        category.setSlug(required(request, "slug"));
        category.setActive(request.getParameter("active") != null);
        Integer parentId = WebUtil.integerParam(request, "parentId");
        if (parentId != null && parentId.equals(id)) {
            throw new IllegalArgumentException("Danh mục không thể là cha của chính nó.");
        }
        category.setParentCategory(parentId == null ? null : categoryService.findById(parentId));
        if (id == null) categoryService.create(category); else categoryService.update(category);
    }

    private void saveBrand(HttpServletRequest request) {
        Integer id = WebUtil.integerParam(request, "id");
        Brand brand = id == null ? new Brand() : brandService.findById(id);
        if (brand == null) throw new IllegalArgumentException("Không tìm thấy thương hiệu.");
        brand.setName(required(request, "name"));
        brand.setSlug(required(request, "slug"));
        brand.setLogoUrl(WebUtil.trimToNull(request.getParameter("logoUrl")));
        brand.setActive(request.getParameter("active") != null);
        if (id == null) brandService.create(brand); else brandService.update(brand);
    }

    private String required(HttpServletRequest request, String name) {
        String value = WebUtil.trimToNull(request.getParameter(name));
        if (value == null) throw new IllegalArgumentException(name + " không được để trống.");
        return value;
    }
}
