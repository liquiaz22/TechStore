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
@Table(name = "Payments")
@Getter
@Setter
@NoArgsConstructor
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PaymentId")
    private Long paymentId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "OrderId", nullable = false)
    private Order order;

    @Column(name = "PaymentMethod", nullable = false, length = 30)
    private String paymentMethod;

    @Column(name = "PaymentStatus", nullable = false, length = 30)
    private String paymentStatus = "PENDING";

    @Column(name = "Amount", nullable = false, precision = 18, scale = 2)
    private BigDecimal amount;

    @Column(name = "ProviderTransactionId", length = 200)
    private String providerTransactionId;

    @Column(name = "MerchantTransactionRef", length = 100)
    private String merchantTransactionRef;

    @Column(name = "ProviderResponseCode", length = 10)
    private String providerResponseCode;

    @Column(name = "BankCode", length = 30)
    private String bankCode;

    @Column(name = "PaidAt")
    private LocalDateTime paidAt;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    @PrePersist
    void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (paymentStatus == null || paymentStatus.isBlank()) paymentStatus = "PENDING";
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
