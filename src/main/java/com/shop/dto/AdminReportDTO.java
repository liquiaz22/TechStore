package com.shop.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import lombok.Getter;

public final class AdminReportDTO {
    private AdminReportDTO() {}

    @Getter
    public static final class Summary {
        private final BigDecimal revenue;
        private final long completedOrders;
        private final long totalOrders;
        private final long customerCount;
        private final long productCount;

        public Summary(BigDecimal revenue, long completedOrders, long totalOrders,
                long customerCount, long productCount) {
            this.revenue = revenue;
            this.completedOrders = completedOrders;
            this.totalOrders = totalOrders;
            this.customerCount = customerCount;
            this.productCount = productCount;
        }
    }

    @Getter
    public static final class DailyRevenue {
        private final LocalDate date;
        private final BigDecimal revenue;
        private final int percent;

        public DailyRevenue(LocalDate date, BigDecimal revenue, int percent) {
            this.date = date;
            this.revenue = revenue;
            this.percent = percent;
        }
    }

    @Getter
    public static final class StatusCount {
        private final String status;
        private final long count;
        private final int percent;

        public StatusCount(String status, long count, int percent) {
            this.status = status;
            this.count = count;
            this.percent = percent;
        }
    }

    @Getter
    public static final class ProductSales {
        private final String productName;
        private final long quantity;
        private final BigDecimal revenue;

        public ProductSales(String productName, long quantity, BigDecimal revenue) {
            this.productName = productName;
            this.quantity = quantity;
            this.revenue = revenue;
        }
    }

    @Getter
    public static final class StockAlert {
        private final Long variantId;
        private final Long productId;
        private final String sku;
        private final String productName;
        private final String variantName;
        private final int stockQuantity;

        public StockAlert(Long variantId, Long productId, String sku, String productName,
                String variantName, int stockQuantity) {
            this.variantId = variantId;
            this.productId = productId;
            this.sku = sku;
            this.productName = productName;
            this.variantName = variantName;
            this.stockQuantity = stockQuantity;
        }
    }

    @Getter
    public static final class CustomerValue {
        private final Long userId;
        private final String fullName;
        private final String email;
        private final long orderCount;
        private final BigDecimal totalSpent;

        public CustomerValue(Long userId, String fullName, String email,
                long orderCount, BigDecimal totalSpent) {
            this.userId = userId;
            this.fullName = fullName;
            this.email = email;
            this.orderCount = orderCount;
            this.totalSpent = totalSpent;
        }
    }

    @Getter
    public static final class Dashboard {
        private final Summary summary;
        private final List<DailyRevenue> dailyRevenue;
        private final List<StatusCount> statusCounts;
        private final List<ProductSales> topProducts;
        private final List<StockAlert> stockAlerts;
        private final List<CustomerValue> topCustomers;

        public Dashboard(Summary summary, List<DailyRevenue> dailyRevenue,
                List<StatusCount> statusCounts, List<ProductSales> topProducts,
                List<StockAlert> stockAlerts, List<CustomerValue> topCustomers) {
            this.summary = summary;
            this.dailyRevenue = dailyRevenue;
            this.statusCounts = statusCounts;
            this.topProducts = topProducts;
            this.stockAlerts = stockAlerts;
            this.topCustomers = topCustomers;
        }
    }
}
