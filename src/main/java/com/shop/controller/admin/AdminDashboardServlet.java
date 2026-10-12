package com.shop.controller.admin;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Map;

import com.shop.dto.AdminReportDTO.Dashboard;
import com.shop.service.AdminReportService;
import com.shop.service.impl.AdminReportServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin")
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Map<String, String> STATUS_LABELS = Map.of(
            "PENDING", "Chờ xác nhận",
            "CONFIRMED", "Đã xác nhận",
            "PROCESSING", "Đang chuẩn bị",
            "SHIPPING", "Đang giao",
            "COMPLETED", "Hoàn thành",
            "CANCELLED", "Đã hủy");
    private final AdminReportService reportService = new AdminReportServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LocalDate today = LocalDate.now();
        try {
            LocalDate fromDate = parseDate(request.getParameter("from"), today.minusDays(29));
            LocalDate toDate = parseDate(request.getParameter("to"), today);
            setDashboardData(request, fromDate, toDate);
        } catch (IllegalArgumentException ex) {
            request.setAttribute("pageError", ex.getMessage());
            LocalDate fallbackFrom = today.minusDays(29);
            setDashboardData(request, fallbackFrom, today);
        }
        WebUtil.forward(request, response, "admin/dashboard");
    }

    private void setDashboardData(HttpServletRequest request, LocalDate fromDate, LocalDate toDate) {
        Dashboard report = reportService.getDashboard(fromDate, toDate);
        long pendingOrders = report.getStatusCounts().stream()
                .filter(item -> "PENDING".equals(item.getStatus()))
                .mapToLong(item -> item.getCount()).findFirst().orElse(0);
        long ordersInProgress = report.getStatusCounts().stream()
                .filter(item -> "CONFIRMED".equals(item.getStatus())
                        || "PROCESSING".equals(item.getStatus())
                        || "SHIPPING".equals(item.getStatus()))
                .mapToLong(item -> item.getCount()).sum();
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);
        request.setAttribute("report", report);
        request.setAttribute("pendingOrderCount", pendingOrders);
        request.setAttribute("ordersInProgressCount", ordersInProgress);
        request.setAttribute("statusLabels", STATUS_LABELS);
    }

    private LocalDate parseDate(String value, LocalDate fallback) {
        if (value == null || value.isBlank()) return fallback;
        try {
            return LocalDate.parse(value);
        } catch (DateTimeParseException ex) {
            throw new IllegalArgumentException("Ngày báo cáo không hợp lệ.");
        }
    }
}
