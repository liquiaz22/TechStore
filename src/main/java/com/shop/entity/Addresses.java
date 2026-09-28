package com.shop.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "Addresses")
@Getter
@Setter
@NoArgsConstructor
public class Addresses {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "AddressId")
    private Long addressId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "UserId", nullable = false)
    private User user;

    @Column(name = "ReceiverName", nullable = false, length = 150)
    private String receiverName;

    @Column(name = "ReceiverPhone", nullable = false, length = 20)
    private String receiverPhone;

    @Column(name = "Province", nullable = false, length = 100)
    private String province;

    @Column(name = "District", nullable = false, length = 100)
    private String district;

    @Column(name = "Ward", nullable = false, length = 100)
    private String ward;

    @Column(name = "AddressLine", nullable = false, length = 255)
    private String addressLine;

    @Column(name = "IsDefault", nullable = false)
    private boolean defaultAddress;

    public String toShippingAddress() {
        return String.join(", ", addressLine, ward, district, province);
    }
}
