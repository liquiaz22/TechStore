package com.shop.utils;

import java.math.BigDecimal;
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
        return new ProductCardDTO(product.getProductId(), product.getName(), product.getSlug(),
                product.getBrand() == null ? null : product.getBrand().getName(), imageUrl,
                cheapest == null ? BigDecimal.ZERO : cheapest.getPrice(),
                cheapest == null ? null : cheapest.getOriginalPrice(),
                variants.stream().anyMatch(v -> v.isActive() && v.getStockQuantity() > 0));
    }
}
