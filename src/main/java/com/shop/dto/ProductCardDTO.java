package com.shop.dto;

import java.math.BigDecimal;

/**
 * DTO dành cho thẻ sản phẩm trên JSP.
 *
 * Dùng JavaBean getter thay vì record accessor để Jakarta EL có thể đọc
 * các thuộc tính như ${card.slug}, ${card.name} và ${card.inStock}.
 */
public final class ProductCardDTO {
    private final Long productId;
    private final String name;
    private final String slug;
    private final String brandName;
    private final String imageUrl;
    private final BigDecimal price;
    private final BigDecimal originalPrice;
    private final boolean inStock;

    public ProductCardDTO(Long productId, String name, String slug, String brandName,
            String imageUrl, BigDecimal price, BigDecimal originalPrice, boolean inStock) {
        this.productId = productId;
        this.name = name;
        this.slug = slug;
        this.brandName = brandName;
        this.imageUrl = imageUrl;
        this.price = price;
        this.originalPrice = originalPrice;
        this.inStock = inStock;
    }

    public Long getProductId() {
        return productId;
    }

    public String getName() {
        return name;
    }

    public String getSlug() {
        return slug;
    }

    public String getBrandName() {
        return brandName;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public BigDecimal getOriginalPrice() {
        return originalPrice;
    }

    public boolean isInStock() {
        return inStock;
    }
}
