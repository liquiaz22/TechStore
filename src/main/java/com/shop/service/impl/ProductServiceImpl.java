package com.shop.service.impl;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import com.shop.dao.ProductDAO;
import com.shop.dao.impl.ProductDAOImpl;
import com.shop.entity.Product;
import com.shop.service.ProductService;
import com.shop.utils.ValidationUtil;

public class ProductServiceImpl extends AbstractService<Product> implements ProductService {
    private final ProductDAO productDAO;
    public ProductServiceImpl() { this(new ProductDAOImpl()); }
    public ProductServiceImpl(ProductDAO dao) { super(dao); this.productDAO = dao; }

    @Override
    public boolean create(Product product) {
        validate(product);
        if (productDAO.findBySlug(product.getSlug()).isPresent()) {
            throw new IllegalArgumentException("Product slug already exists");
        }
        return productDAO.create(product);
    }

    @Override
    public Product update(Product product) {
        validate(product);
        Optional<Product> sameSlug = productDAO.findBySlug(product.getSlug());
        if (sameSlug.isPresent() && !sameSlug.get().getProductId().equals(product.getProductId())) {
            throw new IllegalArgumentException("Product slug already exists");
        }
        return productDAO.update(product);
    }

    @Override public Optional<Product> findBySlug(String slug) { return productDAO.findBySlug(slug); }
    @Override public List<Product> search(String keyword, Integer categoryId, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice, String sort, int page, int pageSize) {
        if (minPrice != null && minPrice.signum() < 0) throw new IllegalArgumentException("Minimum price is invalid");
        if (maxPrice != null && maxPrice.signum() < 0) throw new IllegalArgumentException("Maximum price is invalid");
        if (minPrice != null && maxPrice != null && minPrice.compareTo(maxPrice) > 0) {
            throw new IllegalArgumentException("Minimum price cannot exceed maximum price");
        }
        return productDAO.search(keyword, categoryId, brandId, minPrice, maxPrice,
                normalizeSort(sort), page, pageSize);
    }
    @Override public long countSearch(String keyword, Integer categoryId, Integer brandId,
            BigDecimal minPrice, BigDecimal maxPrice) {
        return productDAO.countSearch(keyword, categoryId, brandId, minPrice, maxPrice);
    }

    private void validate(Product product) {
        if (product == null || product.getCategory() == null) {
            throw new IllegalArgumentException("Sản phẩm và danh mục không được để trống.");
        }
        product.setName(ValidationUtil.requiredText(product.getName(), "Tên sản phẩm", 250));
        product.setSlug(ValidationUtil.requiredText(product.getSlug(), "Slug sản phẩm", 300)
                .toLowerCase(java.util.Locale.ROOT));
        if (!product.getSlug().matches("[a-z0-9]+(?:-[a-z0-9]+)*")) {
            throw new IllegalArgumentException("Slug sản phẩm chỉ gồm chữ thường, số và dấu gạch ngang.");
        }
        product.setShortDescription(ValidationUtil.optionalText(
                product.getShortDescription(), "Mô tả ngắn", 1000));
        product.setDescription(ValidationUtil.optionalText(
                product.getDescription(), "Mô tả sản phẩm", 20000));
        if (product.getStatus() == null
                || !java.util.Set.of("DRAFT", "ACTIVE", "INACTIVE").contains(product.getStatus())) {
            throw new IllegalArgumentException("Trạng thái sản phẩm không hợp lệ.");
        }
    }

    private String normalizeSort(String sort) {
        return switch (sort == null ? "" : sort) {
            case "price_asc", "price_desc" -> sort;
            default -> "latest";
        };
    }
}
