package com.shop.utils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

import com.shop.dto.ProductCardDTO;
import com.shop.entity.Product;
import com.shop.entity.ProductImage;
import com.shop.entity.ProductVariant;
import com.shop.service.ProductImageService;
import com.shop.service.ProductVariantService;

public class ProductViewMapper {
    private final ProductVariantService variantService;
    private final ProductImageService imageService;

    public ProductViewMapper(ProductVariantService variantService, ProductImageService imageService) {
        this.variantService = variantService;
        this.imageService = imageService;
    }

    public ProductCardDTO toCard(Product product) {
        List<ProductVariant> variants = variantService.findByProductId(product.getProductId());
        ProductVariant cheapest = variants.stream().filter(ProductVariant::isActive)
                .min((a, b) -> a.getPrice().compareTo(b.getPrice())).orElse(null);
        String imageUrl = imageService.findPrimaryByProductId(product.getProductId())
                .map(ProductImage::getImageUrl).orElse("assets/images/product-placeholder.svg");
        BigDecimal price = cheapest == null ? BigDecimal.ZERO : cheapest.getPrice();
        BigDecimal originalPrice = cheapest == null ? null : cheapest.getOriginalPrice();
        return new ProductCardDTO(product.getProductId(), product.getName(), product.getSlug(),
                product.getBrand() == null ? null : product.getBrand().getName(),
                product.getCategory() == null ? null : product.getCategory().getName(), imageUrl,
                price, originalPrice, discountPercent(price, originalPrice),
                quickSpecs(cheapest), variantOptions(variants),
                variants.stream().anyMatch(v -> v.isActive() && v.getStockQuantity() > 0));
    }

    private int discountPercent(BigDecimal price, BigDecimal originalPrice) {
        if (price == null || originalPrice == null || originalPrice.signum() <= 0
                || originalPrice.compareTo(price) <= 0) {
            return 0;
        }
        return originalPrice.subtract(price)
                .multiply(BigDecimal.valueOf(100))
                .divide(originalPrice, 0, RoundingMode.HALF_UP)
                .intValue();
    }

    private List<String> quickSpecs(ProductVariant variant) {
        if (variant == null) return List.of();
        List<String> specs = new ArrayList<>(3);
        addSpec(specs, "RAM", variant.getRam());
        addSpec(specs, "Bộ nhớ", variant.getStorage());
        addSpec(specs, "Màu", variant.getColor());
        return specs;
    }

    private void addSpec(List<String> specs, String label, String value) {
        if (value != null && !value.isBlank() && specs.size() < 3) {
            specs.add(label + " " + value.trim());
        }
    }

    private List<String> variantOptions(List<ProductVariant> variants) {
        return variants.stream()
                .filter(ProductVariant::isActive)
                .map(ProductVariant::getVariantName)
                .filter(name -> name != null && !name.isBlank())
                .map(String::trim)
                .distinct()
                .limit(3)
                .toList();
    }
}
