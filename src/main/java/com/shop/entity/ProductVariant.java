package com.shop.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "ProductVariants")
@Getter
@Setter
@NoArgsConstructor
public class ProductVariant {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "VariantId")
    private Long variantId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "ProductId", nullable = false)
    private Product product;

    @Column(name = "SKU", nullable = false, length = 100)
    private String sku;

    @Column(name = "VariantName", nullable = false, length = 200)
    private String variantName;

    @Column(name = "Color", length = 100)
    private String color;

    @Column(name = "Ram", length = 50)
    private String ram;

    @Column(name = "Storage", length = 50)
    private String storage;

    @Column(name = "Price", nullable = false, precision = 18, scale = 2)
    private BigDecimal price;

    @Column(name = "OriginalPrice", precision = 18, scale = 2)
    private BigDecimal originalPrice;

    @Column(name = "StockQuantity", nullable = false)
    private int stockQuantity;

    @Column(name = "IsActive", nullable = false)
    private boolean active = true;

    @Column(name = "UpdatedAt", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    void touchUpdatedAt() {
        updatedAt = LocalDateTime.now();
    }
}
