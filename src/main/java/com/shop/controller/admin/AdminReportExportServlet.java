package com.shop.controller.admin;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

import com.shop.dto.AdminReportDTO.Dashboard;
import com.shop.service.AdminReportService;
import com.shop.service.impl.AdminReportServiceImpl;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/reports/export")
public class AdminReportExportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AdminReportService reportService = new AdminReportServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            LocalDate toDate = parseRequiredDate(request.getParameter("to"));
            LocalDate fromDate = parseRequiredDate(request.getParameter("from"));
            Dashboard report = reportService.getDashboard(fromDate, toDate);

            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/csv; charset=UTF-8");
            response.setHeader("Content-Disposition", "attachment; filename=techstore-report-"
                    + fromDate + "-" + toDate + ".csv");
            writeCsv(response.getWriter(), fromDate, toDate, report);
        } catch (IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
        }
    }

    private void writeCsv(PrintWriter writer, LocalDate fromDate, LocalDate toDate,
            Dashboard report) {
        writer.write('\uFEFF');
        row(writer, "BÁO CÁO TECHSTORE", fromDate + " đến " + toDate);
        row(writer, "Doanh thu đơn hoàn tất", report.getSummary().getRevenue());
        row(writer, "Số đơn hoàn tất", report.getSummary().getCompletedOrders());
        row(writer, "Tổng đơn trong kỳ", report.getSummary().getTotalOrders());
        writer.println();

        row(writer, "DOANH THU THEO NGÀY");
        row(writer, "Ngày", "Doanh thu");
        report.getDailyRevenue().forEach(item -> row(writer, item.getDate(), item.getRevenue()));
        writer.println();

        row(writer, "ĐƠN THEO TRẠNG THÁI");
        row(writer, "Trạng thái", "Số đơn");
        report.getStatusCounts().forEach(item -> row(writer, item.getStatus(), item.getCount()));
        writer.println();

        row(writer, "SẢN PHẨM BÁN CHẠY");
        row(writer, "Sản phẩm", "Số lượng", "Doanh thu");
        report.getTopProducts().forEach(item -> row(
                writer, item.getProductName(), item.getQuantity(), item.getRevenue()));
        writer.println();

        row(writer, "SẢN PHẨM SẮP HẾT HÀNG");
        row(writer, "SKU", "Sản phẩm", "Phiên bản", "Tồn kho");
        report.getStockAlerts().forEach(item -> row(writer, item.getSku(),
                item.getProductName(), item.getVariantName(), item.getStockQuantity()));
        writer.println();

        row(writer, "KHÁCH HÀNG MUA NHIỀU");
        row(writer, "Khách hàng", "Email", "Số đơn", "Tổng chi tiêu");
        report.getTopCustomers().forEach(item -> row(writer, item.getFullName(),
                item.getEmail(), item.getOrderCount(), item.getTotalSpent()));
    }

    private void row(PrintWriter writer, Object... values) {
        for (int index = 0; index < values.length; index++) {
            if (index > 0) writer.print(',');
            writer.print(csv(values[index]));
        }
        writer.println();
    }

    private String csv(Object value) {
        String text = value == null ? "" : value.toString();
        if (!text.isEmpty() && "=+-@".indexOf(text.charAt(0)) >= 0) {
            text = "'" + text;
        }
        return "\"" + text.replace("\"", "\"\"") + "\"";
    }

    private LocalDate parseRequiredDate(String value) {
        try {
            if (value == null || value.isBlank()) throw new DateTimeParseException("empty", "", 0);
            return LocalDate.parse(value);
        } catch (DateTimeParseException ex) {
            throw new IllegalArgumentException("Ngày xuất báo cáo không hợp lệ.");
        }
    }
}
