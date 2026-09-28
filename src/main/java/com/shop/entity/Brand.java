package com.shop.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "Brands")
@Getter
@Setter
@NoArgsConstructor
public class Brand {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "BrandId")
    private Integer brandId;

    @Column(name = "Name", nullable = false, length = 100)
    private String name;

    @Column(name = "Slug", nullable = false, length = 150)
    private String slug;

    @Column(name = "LogoUrl", length = 500)
    private String logoUrl;

    @Column(name = "IsActive", nullable = false)
    private boolean active = true;
}
