package com.shop.service.impl;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import com.shop.dao.ProductVariantDAO;
import com.shop.dao.impl.ProductVariantDAOImpl;
import com.shop.entity.ProductVariant;
import com.shop.service.ProductVariantService;
import com.shop.utils.ValidationUtil;

public class ProductVariantServiceImpl extends AbstractService<ProductVariant>
        implements ProductVariantService {
    private final ProductVariantDAO variantDAO;
    public ProductVariantServiceImpl() { this(new ProductVariantDAOImpl()); }
    public ProductVariantServiceImpl(ProductVariantDAO dao) { super(dao); this.variantDAO = dao; }

    @Override public boolean create(ProductVariant variant) {
        validate(variant);
        if (variantDAO.findBySku(variant.getSku()).isPresent()) {
            throw new IllegalArgumentException("SKU already exists");
        }
        return variantDAO.create(variant);
    }

    @Override public ProductVariant update(ProductVariant variant) {
        validate(variant);
        Optional<ProductVariant> sameSku = variantDAO.findBySku(variant.getSku());
        if (sameSku.isPresent() && !sameSku.get().getVariantId().equals(variant.getVariantId())) {
            throw new IllegalArgumentException("SKU already exists");
        }
        return variantDAO.update(variant);
    }

    @Override public Optional<ProductVariant> findBySku(String sku) { return variantDAO.findBySku(sku); }
    @Override public List<ProductVariant> findByProductId(Long id) { return variantDAO.findByProductId(id); }
    @Override public List<ProductVariant> findAvailableByProductId(Long id) {
        return variantDAO.findAvailableByProductId(id);
    }

    private void validate(ProductVariant variant) {
        if (variant == null || variant.getProduct() == null || variant.getPrice() == null) {
            throw new IllegalArgumentException("Sản phẩm, SKU, tên phiên bản và giá không được để trống.");
        }
        variant.setSku(ValidationUtil.requiredText(variant.getSku(), "SKU", 100));
        variant.setVariantName(ValidationUtil.requiredText(
                variant.getVariantName(), "Tên phiên bản", 200));
        variant.setColor(ValidationUtil.optionalText(variant.getColor(), "Màu sắc", 100));
        variant.setRam(ValidationUtil.optionalText(variant.getRam(), "RAM", 50));
        variant.setStorage(ValidationUtil.optionalText(variant.getStorage(), "Dung lượng", 50));
        if (variant.getPrice().signum() < 0 || variant.getStockQuantity() < 0) {
            throw new IllegalArgumentException("Price and stock cannot be negative");
        }
        BigDecimal original = variant.getOriginalPrice();
        if (original != null && original.compareTo(variant.getPrice()) < 0) {
            throw new IllegalArgumentException("Original price cannot be lower than sale price");
        }
    }
}
