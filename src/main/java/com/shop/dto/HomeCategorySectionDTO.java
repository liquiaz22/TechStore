package com.shop.dto;

import java.util.List;

public final class HomeCategorySectionDTO {
    private final Integer categoryId;
    private final String categoryName;
    private final String categorySlug;
    private final List<ProductCardDTO> products;

    public HomeCategorySectionDTO(Integer categoryId, String categoryName,
            String categorySlug, List<ProductCardDTO> products) {
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.categorySlug = categorySlug;
        this.products = List.copyOf(products);
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public String getCategorySlug() {
        return categorySlug;
    }

    public List<ProductCardDTO> getProducts() {
        return products;
    }
}
