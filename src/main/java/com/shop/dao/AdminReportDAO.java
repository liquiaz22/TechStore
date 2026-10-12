package com.shop.dao;

import java.time.LocalDateTime;
import java.util.List;

import com.shop.dto.AdminReportDTO.CustomerValue;
import com.shop.dto.AdminReportDTO.ProductSales;
import com.shop.dto.AdminReportDTO.StockAlert;
import com.shop.dto.AdminReportDTO.Summary;

public interface AdminReportDAO {
    Summary summarize(LocalDateTime from, LocalDateTime toExclusive);
    List<Object[]> findDailyRevenue(LocalDateTime from, LocalDateTime toExclusive);
    List<Object[]> countByStatus(LocalDateTime from, LocalDateTime toExclusive);
    List<ProductSales> findTopProducts(LocalDateTime from, LocalDateTime toExclusive, int limit);
    List<StockAlert> findStockAlerts(int threshold, int limit);
    List<CustomerValue> findTopCustomers(LocalDateTime from, LocalDateTime toExclusive, int limit);
}
