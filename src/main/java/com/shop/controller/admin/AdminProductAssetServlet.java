package com.shop.controller.admin;

import java.io.IOException;
import java.math.BigDecimal;

import com.shop.entity.Product;
import com.shop.entity.ProductImage;
import com.shop.entity.ProductSpecification;
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

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {
        "/admin/products/variant/save", "/admin/products/image/save",
        "/admin/products/image/delete", "/admin/products/spec/save",
        "/admin/products/spec/delete"
})
public class AdminProductAssetServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ProductService productService = new ProductServiceImpl();
    private final ProductVariantService variantService = new ProductVariantServiceImpl();
    private final ProductImageService imageService = new ProductImageServiceImpl();
    private final ProductSpecificationService specificationService =
            new ProductSpecificationServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long productId = WebUtil.longParam(request, "productId");
        try {
            String path = request.getServletPath();
            if (path.endsWith("/variant/save")) saveVariant(request, productId);
            else if (path.endsWith("/image/save")) saveImage(request, productId);
            else if (path.endsWith("/image/delete")) imageService.delete(WebUtil.longParam(request, "id"));
            else if (path.endsWith("/spec/save")) saveSpecification(request, productId);
            else if (path.endsWith("/spec/delete")) specificationService.delete(WebUtil.longParam(request, "id"));
            WebUtil.success(request, "Đã cập nhật dữ liệu sản phẩm.");
        } catch (RuntimeException ex) {
            WebUtil.error(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/admin/products/form?id=" + productId);
    }

    private void saveVariant(HttpServletRequest request, Long productId) {
        Product product = requireProduct(productId);
        String idValue = request.getParameter("id");
        ProductVariant variant = idValue == null || idValue.isBlank()
                ? new ProductVariant() : variantService.findById(Long.valueOf(idValue));
        if (variant == null) throw new IllegalArgumentException("Không tìm thấy phiên bản.");
        variant.setProduct(product);
        variant.setSku(required(request, "sku"));
        variant.setVariantName(required(request, "variantName"));
        variant.setColor(WebUtil.trimToNull(request.getParameter("color")));
        variant.setRam(WebUtil.trimToNull(request.getParameter("ram")));
        variant.setStorage(WebUtil.trimToNull(request.getParameter("storage")));
        variant.setPrice(new BigDecimal(required(request, "price")));
        String original = request.getParameter("originalPrice");
        variant.setOriginalPrice(original == null || original.isBlank() ? null : new BigDecimal(original));
        variant.setStockQuantity(Integer.parseInt(required(request, "stockQuantity")));
        variant.setActive(request.getParameter("active") != null);
        if (variant.getVariantId() == null) variantService.create(variant); else variantService.update(variant);
    }

    private void saveImage(HttpServletRequest request, Long productId) {
        ProductImage image = new ProductImage();
        image.setProduct(requireProduct(productId));
        String variantId = request.getParameter("variantId");
        image.setVariant(variantId == null || variantId.isBlank()
                ? null : variantService.findById(Long.valueOf(variantId)));
        image.setImageUrl(required(request, "imageUrl"));
        image.setPrimary(request.getParameter("primary") != null);
        String sortOrder = request.getParameter("sortOrder");
        image.setSortOrder(sortOrder == null || sortOrder.isBlank() ? 0 : Integer.parseInt(sortOrder));
        imageService.create(image);
    }

    private void saveSpecification(HttpServletRequest request, Long productId) {
        ProductSpecification specification = new ProductSpecification();
        specification.setProduct(requireProduct(productId));
        specification.setSpecificationName(required(request, "specificationName"));
        specification.setSpecificationValue(required(request, "specificationValue"));
        String sortOrder = request.getParameter("sortOrder");
        specification.setSortOrder(sortOrder == null || sortOrder.isBlank() ? 0 : Integer.parseInt(sortOrder));
        specificationService.create(specification);
    }

    private Product requireProduct(Long id) {
        Product product = productService.findById(id);
        if (product == null) throw new IllegalArgumentException("Không tìm thấy sản phẩm.");
        return product;
    }

    private String required(HttpServletRequest request, String name) {
        String value = WebUtil.trimToNull(request.getParameter(name));
        if (value == null) throw new IllegalArgumentException(name + " không được để trống.");
        return value;
    }
}
