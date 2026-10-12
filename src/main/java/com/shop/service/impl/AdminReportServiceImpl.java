package com.shop.service.impl;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.shop.dao.AdminReportDAO;
import com.shop.dao.impl.AdminReportDAOImpl;
import com.shop.dto.AdminReportDTO.DailyRevenue;
import com.shop.dto.AdminReportDTO.Dashboard;
import com.shop.dto.AdminReportDTO.StatusCount;
import com.shop.service.AdminReportService;

public class AdminReportServiceImpl implements AdminReportService {
    private static final List<String> STATUSES = List.of(
            "PENDING", "CONFIRMED", "PROCESSING", "SHIPPING", "COMPLETED", "CANCELLED");
    private final AdminReportDAO reportDAO;

    public AdminReportServiceImpl() {
        this(new AdminReportDAOImpl());
    }

    public AdminReportServiceImpl(AdminReportDAO reportDAO) {
        this.reportDAO = reportDAO;
    }

    @Override
    public Dashboard getDashboard(LocalDate fromDate, LocalDate toDate) {
        validateRange(fromDate, toDate);
        LocalDateTime from = fromDate.atStartOfDay();
        LocalDateTime toExclusive = toDate.plusDays(1).atStartOfDay();
        var summary = reportDAO.summarize(from, toExclusive);
        var daily = buildDailyRevenue(fromDate, toDate,
                reportDAO.findDailyRevenue(from, toExclusive));
        var statuses = buildStatusCounts(reportDAO.countByStatus(from, toExclusive));
        return new Dashboard(summary, daily, statuses,
                reportDAO.findTopProducts(from, toExclusive, 10),
                reportDAO.findStockAlerts(5, 20),
                reportDAO.findTopCustomers(from, toExclusive, 10));
    }

    private List<DailyRevenue> buildDailyRevenue(LocalDate fromDate, LocalDate toDate,
            List<Object[]> rawRows) {
        Map<LocalDate, BigDecimal> values = new LinkedHashMap<>();
        fromDate.datesUntil(toDate.plusDays(1)).forEach(date -> values.put(date, BigDecimal.ZERO));
        for (Object[] row : rawRows) values.put(asDate(row[0]), asMoney(row[1]));
        BigDecimal maximum = values.values().stream().max(BigDecimal::compareTo).orElse(BigDecimal.ZERO);
        List<DailyRevenue> result = new ArrayList<>();
        values.forEach((date, revenue) -> result.add(new DailyRevenue(
                date, revenue, percent(revenue, maximum))));
        return result;
    }

    private List<StatusCount> buildStatusCounts(List<Object[]> rawRows) {
        Map<String, Long> values = new LinkedHashMap<>();
        STATUSES.forEach(status -> values.put(status, 0L));
        for (Object[] row : rawRows) values.put(String.valueOf(row[0]), ((Number) row[1]).longValue());
        long maximum = values.values().stream().mapToLong(Long::longValue).max().orElse(0L);
        return values.entrySet().stream()
                .map(entry -> new StatusCount(entry.getKey(), entry.getValue(),
                        maximum == 0 ? 0 : (int) Math.round(entry.getValue() * 100.0 / maximum)))
                .toList();
    }

    private int percent(BigDecimal value, BigDecimal maximum) {
        if (maximum.signum() == 0) return 0;
        return value.multiply(BigDecimal.valueOf(100))
                .divide(maximum, 0, java.math.RoundingMode.HALF_UP).intValue();
    }

    private LocalDate asDate(Object value) {
        if (value instanceof LocalDate date) return date;
        if (value instanceof Date date) return date.toLocalDate();
        return LocalDate.parse(value.toString());
    }

    private BigDecimal asMoney(Object value) {
        if (value == null) return BigDecimal.ZERO;
        return value instanceof BigDecimal decimal ? decimal : new BigDecimal(value.toString());
    }

    private void validateRange(LocalDate fromDate, LocalDate toDate) {
        if (fromDate == null || toDate == null || fromDate.isAfter(toDate)) {
            throw new IllegalArgumentException("Khoảng ngày báo cáo không hợp lệ.");
        }
        if (fromDate.plusDays(366).isBefore(toDate)) {
            throw new IllegalArgumentException("Khoảng báo cáo tối đa là 366 ngày.");
        }
    }
}
