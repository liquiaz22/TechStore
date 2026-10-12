package com.shop.controller.admin;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.shop.entity.Order;
import com.shop.entity.OrderStatusHistory;
import com.shop.entity.Payment;
import com.shop.service.OrderItemService;
import com.shop.service.OrderService;
import com.shop.service.OrderStatusHistoryService;
import com.shop.service.PaymentService;
import com.shop.service.impl.OrderItemServiceImpl;
import com.shop.service.impl.OrderServiceImpl;
import com.shop.service.impl.OrderStatusHistoryServiceImpl;
import com.shop.service.impl.PaymentServiceImpl;
import com.shop.utils.ValidationUtil;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/admin/orders", "/admin/orders/detail", "/admin/orders/status"})
public class AdminOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int PAGE_SIZE = 20;
    private static final DateTimeFormatter DISPLAY_DATE_TIME =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final Set<String> STATUSES = Set.of(
            "PENDING", "CONFIRMED", "PROCESSING", "SHIPPING", "COMPLETED", "CANCELLED");
    private static final Map<String, List<String>> NEXT_STATUSES = Map.of(
            "PENDING", List.of("CONFIRMED", "CANCELLED"),
            "CONFIRMED", List.of("PROCESSING", "CANCELLED"),
            "PROCESSING", List.of("SHIPPING", "CANCELLED"),
            "SHIPPING", List.of("COMPLETED"),
            "COMPLETED", List.of(),
            "CANCELLED", List.of());
    private static final Map<String, String> STATUS_LABELS = Map.of(
            "PENDING", "Chờ xác nhận",
            "CONFIRMED", "Đã xác nhận",
            "PROCESSING", "Đang chuẩn bị",
            "SHIPPING", "Đang giao",
            "COMPLETED", "Hoàn thành",
            "CANCELLED", "Đã hủy");
    private static final Map<String, String> STATUS_CLASSES = Map.of(
            "PENDING", "badge-warning",
            "CONFIRMED", "badge-info",
            "PROCESSING", "badge-info",
            "SHIPPING", "badge-shipping",
            "COMPLETED", "badge-success",
            "CANCELLED", "badge-danger");
    private static final Map<String, String> PAYMENT_STATUS_LABELS = Map.ofEntries(
            Map.entry("UNPAID", "Chưa thanh toán"),
            Map.entry("PAID", "Đã thanh toán"),
            Map.entry("PENDING", "Đang chờ xử lý"),
            Map.entry("SUCCESS", "Thành công"),
            Map.entry("FAILED", "Thất bại"),
            Map.entry("REFUNDED", "Đã hoàn tiền"));
    private static final Map<String, String> PAYMENT_STATUS_CLASSES = Map.ofEntries(
            Map.entry("UNPAID", "badge-warning"),
            Map.entry("PAID", "badge-success"),
            Map.entry("PENDING", "badge-warning"),
            Map.entry("SUCCESS", "badge-success"),
            Map.entry("FAILED", "badge-danger"),
            Map.entry("REFUNDED", "badge-neutral"));
    private static final Map<String, String> PAYMENT_METHOD_LABELS = Map.of(
            "COD", "Thanh toán khi nhận hàng (COD)",
            "VNPAY", "Thanh toán trực tuyến qua VNPay");
    private final OrderService orderService = new OrderServiceImpl();
    private final OrderItemService itemService = new OrderItemServiceImpl();
    private final OrderStatusHistoryService historyService = new OrderStatusHistoryServiceImpl();
    private final PaymentService paymentService = new PaymentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getServletPath().endsWith("/detail")) {
            showDetail(request, response);
            return;
        }
        try {
            String keyword = ValidationUtil.optionalText(
                    request.getParameter("q"), "Từ khóa", 150);
            String status = WebUtil.trimToNull(request.getParameter("status"));
            if (status != null && !STATUSES.contains(status)) {
                throw new IllegalArgumentException("Trạng thái lọc không hợp lệ.");
            }
            LocalDate fromDate = parseDate(request.getParameter("from"), "Từ ngày");
            LocalDate toDate = parseDate(request.getParameter("to"), "Đến ngày");
            if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
                throw new IllegalArgumentException("Từ ngày không được sau đến ngày.");
            }
            int page = parsePage(request.getParameter("page"));
            var from = fromDate == null ? null : fromDate.atStartOfDay();
            var toExclusive = toDate == null ? null : toDate.plusDays(1).atStartOfDay();
            long total = orderService.countForAdmin(keyword, status, from, toExclusive);
            int totalPages = Math.max(1, (int) Math.ceil(total / (double) PAGE_SIZE));
            page = Math.min(page, totalPages);

            request.setAttribute("orders", orderService.searchForAdmin(
                    keyword, status, from, toExclusive, page - 1, PAGE_SIZE));
            request.setAttribute("selectedStatus", status);
            request.setAttribute("keyword", keyword);
            request.setAttribute("fromDate", fromDate);
            request.setAttribute("toDate", toDate);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalOrders", total);
            request.setAttribute("nextStatuses", NEXT_STATUSES);
            Map<Long, String> orderCreatedAtDisplays = new HashMap<>();
            @SuppressWarnings("unchecked")
            List<Order> orders = (List<Order>) request.getAttribute("orders");
            for (Order order : orders) {
                orderCreatedAtDisplays.put(order.getOrderId(), formatDateTime(order.getCreatedAt()));
            }
            request.setAttribute("orderCreatedAtDisplays", orderCreatedAtDisplays);
            setStatusMetadata(request);
        } catch (IllegalArgumentException ex) {
            request.setAttribute("pageError", ex.getMessage());
            request.setAttribute("orders", List.of());
            request.setAttribute("totalOrders", 0L);
            request.setAttribute("currentPage", 1);
            request.setAttribute("totalPages", 1);
            request.setAttribute("nextStatuses", NEXT_STATUSES);
            setStatusMetadata(request);
        }
        WebUtil.forward(request, response, "admin/orders");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String orderCode = WebUtil.trimToNull(request.getParameter("orderCode"));
        try {
            String status = request.getParameter("status");
            String note = ValidationUtil.optionalText(request.getParameter("note"), "Ghi chú", 500);
            if ("CANCELLED".equals(status) && note == null) {
                throw new IllegalArgumentException("Phải nhập lý do khi hủy đơn.");
            }
            orderService.updateStatus(WebUtil.longParam(request, "orderId"), status,
                    WebUtil.currentUser(request).getUserId(), note);
            WebUtil.success(request, "Đã cập nhật trạng thái đơn hàng.");
        } catch (RuntimeException ex) {
            WebUtil.error(request, ex.getMessage());
        }
        if (orderCode != null) {
            String filters = detailFilterQuery(request);
            WebUtil.redirect(request, response, "/admin/orders/detail?code="
                    + encode(orderCode)
                    + (filters.isEmpty() ? "" : "&" + filters.substring(1)));
        } else {
            WebUtil.redirect(request, response, "/admin/orders");
        }
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = WebUtil.trimToNull(request.getParameter("code"));
        Order order = code == null ? null : orderService.findByCode(code).orElse(null);
        if (order == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        List<OrderStatusHistory> histories = historyService.findByOrderId(order.getOrderId());
        List<Payment> payments = paymentService.findByOrderId(order.getOrderId());
        Map<Long, String> historyCreatedAtDisplays = new HashMap<>();
        Map<Long, String> historyNoteDisplays = new HashMap<>();
        for (OrderStatusHistory history : histories) {
            historyCreatedAtDisplays.put(history.getHistoryId(), formatDateTime(history.getCreatedAt()));
            historyNoteDisplays.put(history.getHistoryId(), displayHistoryNote(history.getNote()));
        }
        Map<Long, String> paymentCreatedAtDisplays = new HashMap<>();
        Map<Long, String> paymentPaidAtDisplays = new HashMap<>();
        for (Payment payment : payments) {
            paymentCreatedAtDisplays.put(payment.getPaymentId(), formatDateTime(payment.getCreatedAt()));
            paymentPaidAtDisplays.put(payment.getPaymentId(), formatDateTime(payment.getPaidAt()));
        }
        request.setAttribute("order", order);
        request.setAttribute("orderItems", itemService.findByOrderId(order.getOrderId()));
        request.setAttribute("histories", histories);
        request.setAttribute("payments", payments);
        request.setAttribute("orderCreatedAtDisplay", formatDateTime(order.getCreatedAt()));
        request.setAttribute("historyCreatedAtDisplays", historyCreatedAtDisplays);
        request.setAttribute("historyNoteDisplays", historyNoteDisplays);
        request.setAttribute("paymentCreatedAtDisplays", paymentCreatedAtDisplays);
        request.setAttribute("paymentPaidAtDisplays", paymentPaidAtDisplays);
        request.setAttribute("allowedNextStatuses", NEXT_STATUSES.getOrDefault(
                order.getStatus(), List.of()));
        request.setAttribute("backToOrdersUrl", request.getContextPath()
                + "/admin/orders" + listFilterQuery(request));
        setStatusMetadata(request);
        WebUtil.forward(request, response, "admin/order-detail");
    }

    private void setStatusMetadata(HttpServletRequest request) {
        request.setAttribute("statusLabels", STATUS_LABELS);
        request.setAttribute("statusClasses", STATUS_CLASSES);
        request.setAttribute("paymentStatusLabels", PAYMENT_STATUS_LABELS);
        request.setAttribute("paymentStatusClasses", PAYMENT_STATUS_CLASSES);
        request.setAttribute("paymentMethodLabels", PAYMENT_METHOD_LABELS);
    }

    private String formatDateTime(LocalDateTime value) {
        return value == null ? "—" : value.format(DISPLAY_DATE_TIME);
    }

    private String displayHistoryNote(String note) {
        if (note == null || note.isBlank()) return "";
        if ("Order created".equalsIgnoreCase(note.trim())) return "Đơn hàng được tạo";
        return note;
    }

    private String listFilterQuery(HttpServletRequest request) {
        StringBuilder query = new StringBuilder();
        appendQuery(query, "q", request.getParameter("q"));
        appendQuery(query, "status", request.getParameter("filterStatus"));
        appendQuery(query, "from", request.getParameter("from"));
        appendQuery(query, "to", request.getParameter("to"));
        appendQuery(query, "page", request.getParameter("page"));
        return query.toString();
    }

    private String detailFilterQuery(HttpServletRequest request) {
        StringBuilder query = new StringBuilder();
        appendQuery(query, "q", request.getParameter("q"));
        appendQuery(query, "filterStatus", request.getParameter("filterStatus"));
        appendQuery(query, "from", request.getParameter("from"));
        appendQuery(query, "to", request.getParameter("to"));
        appendQuery(query, "page", request.getParameter("page"));
        return query.toString();
    }

    private void appendQuery(StringBuilder query, String name, String value) {
        String normalized = WebUtil.trimToNull(value);
        if (normalized == null) return;
        query.append(query.isEmpty() ? '?' : '&')
                .append(name).append('=').append(encode(normalized));
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private int parsePage(String value) {
        try {
            return value == null || value.isBlank() ? 1 : Math.max(1, Integer.parseInt(value));
        } catch (NumberFormatException ex) {
            return 1;
        }
    }

    private LocalDate parseDate(String value, String fieldName) {
        if (value == null || value.isBlank()) return null;
        try {
            return LocalDate.parse(value);
        } catch (DateTimeParseException ex) {
            throw new IllegalArgumentException(fieldName + " không hợp lệ.");
        }
    }
}
