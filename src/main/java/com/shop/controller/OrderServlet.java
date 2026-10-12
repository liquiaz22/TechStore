package com.shop.controller;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
import com.shop.utils.VNPayConfig;
import com.shop.utils.WebUtil;
import com.shop.utils.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/orders", "/orders/detail", "/orders/cancel"})
public class OrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final DateTimeFormatter DISPLAY_DATE_TIME =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final Map<String, String> ORDER_STATUS_LABELS = Map.of(
            "PENDING", "Chờ xác nhận",
            "CONFIRMED", "Đã xác nhận",
            "PROCESSING", "Đang chuẩn bị",
            "SHIPPING", "Đang giao",
            "COMPLETED", "Hoàn thành",
            "CANCELLED", "Đã hủy");
    private static final Map<String, String> ORDER_STATUS_CLASSES = Map.of(
            "PENDING", "badge-warning",
            "CONFIRMED", "badge-info",
            "PROCESSING", "badge-info",
            "SHIPPING", "badge-shipping",
            "COMPLETED", "badge-success",
            "CANCELLED", "badge-danger");
    private static final Map<String, String> ORDER_STATUS_ICONS = Map.of(
            "PENDING", "◷",
            "CONFIRMED", "✓",
            "PROCESSING", "↻",
            "SHIPPING", "→",
            "COMPLETED", "✓",
            "CANCELLED", "×");
    private static final Map<String, String> PAYMENT_STATUS_LABELS = Map.ofEntries(
            Map.entry("UNPAID", "Chưa thanh toán"),
            Map.entry("PAID", "Đã thanh toán"),
            Map.entry("PENDING", "Đang chờ xử lý"),
            Map.entry("SUCCESS", "Thành công"),
            Map.entry("FAILED", "Thanh toán thất bại"),
            Map.entry("REFUNDED", "Đã hoàn tiền"));
    private static final Map<String, String> PAYMENT_STATUS_CLASSES = Map.ofEntries(
            Map.entry("UNPAID", "badge-warning"),
            Map.entry("PAID", "badge-success"),
            Map.entry("PENDING", "badge-warning"),
            Map.entry("SUCCESS", "badge-success"),
            Map.entry("FAILED", "badge-danger"),
            Map.entry("REFUNDED", "badge-neutral"));
    private static final Map<String, String> PAYMENT_STATUS_ICONS = Map.ofEntries(
            Map.entry("UNPAID", "!"),
            Map.entry("PAID", "✓"),
            Map.entry("PENDING", "◷"),
            Map.entry("SUCCESS", "✓"),
            Map.entry("FAILED", "×"),
            Map.entry("REFUNDED", "↩"));
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
        Long userId = WebUtil.currentUser(request).getUserId();
        if (request.getServletPath().endsWith("/detail")) {
            Order order = orderService.findByCode(request.getParameter("code")).orElse(null);
            if (order == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (!order.getUser().getUserId().equals(userId)
                    && !"ADMIN".equals(WebUtil.currentUser(request).getRole())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            request.setAttribute("order", order);
            request.setAttribute("orderItems", itemService.findByOrderId(order.getOrderId()));
            List<OrderStatusHistory> histories = historyService.findByOrderId(order.getOrderId());
            List<Payment> payments = paymentService.findByOrderId(order.getOrderId());
            request.setAttribute("histories", histories);
            request.setAttribute("payments", payments);
            request.setAttribute("latestPayment", payments.isEmpty() ? null : payments.get(0));
            prepareDetailDisplay(request, order, histories, payments);
            WebUtil.forward(request, response, "order/detail");
            return;
        }
        int page = request.getParameter("page") == null ? 1
                : Math.max(1, Integer.parseInt(request.getParameter("page")));
        List<Order> orders = orderService.findByUserId(userId, page - 1, 20);
        Map<Long, String> orderCreatedAtDisplays = new HashMap<>();
        for (Order order : orders) {
            orderCreatedAtDisplays.put(order.getOrderId(), formatDateTime(order.getCreatedAt()));
        }
        request.setAttribute("orders", orders);
        request.setAttribute("orderCreatedAtDisplays", orderCreatedAtDisplays);
        request.setAttribute("currentPage", page);
        prepareStatusMetadata(request);
        WebUtil.forward(request, response, "order/list");
    }

    private void prepareDetailDisplay(HttpServletRequest request, Order order,
            List<OrderStatusHistory> histories, List<Payment> payments) {
        prepareStatusMetadata(request);
        request.setAttribute("vnpayAvailable", VNPayConfig.isPaymentConfigured());
        request.setAttribute("orderCreatedAtDisplay", formatDateTime(order.getCreatedAt()));
        request.setAttribute("orderProgressStep", progressStep(order.getStatus()));

        Map<Long, String> paymentCreatedAtDisplays = new HashMap<>();
        Map<Long, String> paymentPaidAtDisplays = new HashMap<>();
        for (Payment payment : payments) {
            paymentCreatedAtDisplays.put(payment.getPaymentId(), formatDateTime(payment.getCreatedAt()));
            paymentPaidAtDisplays.put(payment.getPaymentId(), formatDateTime(payment.getPaidAt()));
        }
        request.setAttribute("paymentCreatedAtDisplays", paymentCreatedAtDisplays);
        request.setAttribute("paymentPaidAtDisplays", paymentPaidAtDisplays);

        Map<Long, String> historyCreatedAtDisplays = new HashMap<>();
        Map<Long, String> historyNoteDisplays = new HashMap<>();
        OrderStatusHistory cancellationHistory = null;
        for (OrderStatusHistory history : histories) {
            historyCreatedAtDisplays.put(history.getHistoryId(), formatDateTime(history.getCreatedAt()));
            historyNoteDisplays.put(history.getHistoryId(), displayHistoryNote(history.getNote()));
            if ("CANCELLED".equals(history.getStatus())) cancellationHistory = history;
        }
        request.setAttribute("historyCreatedAtDisplays", historyCreatedAtDisplays);
        request.setAttribute("historyNoteDisplays", historyNoteDisplays);
        request.setAttribute("cancellationHistory", cancellationHistory);

        boolean cancellableStatus = "PENDING".equals(order.getStatus())
                || "CONFIRMED".equals(order.getStatus())
                || "PROCESSING".equals(order.getStatus());
        boolean activeOnlinePayment = payments.stream().anyMatch(payment ->
                "VNPAY".equals(payment.getPaymentMethod())
                        && "PENDING".equals(payment.getPaymentStatus())
                        && payment.getCreatedAt() != null
                        && payment.getCreatedAt().isAfter(LocalDateTime.now().minusMinutes(20)));
        boolean customerView = !"ADMIN".equals(WebUtil.currentUser(request).getRole());
        boolean canCancel = customerView && cancellableStatus
                && !"PAID".equals(order.getPaymentStatus()) && !activeOnlinePayment;
        request.setAttribute("canCancelOrder", canCancel);
        if (customerView && cancellableStatus && activeOnlinePayment) {
            request.setAttribute("cancelUnavailableReason",
                    "Giao dịch VNPay đang được xử lý. Có thể hủy đơn sau khi giao dịch hết thời gian chờ 20 phút.");
        } else if (customerView && cancellableStatus && "PAID".equals(order.getPaymentStatus())) {
            request.setAttribute("cancelUnavailableReason",
                    "Đơn đã thanh toán. Vui lòng liên hệ cửa hàng để được hỗ trợ hoàn tiền và hủy đơn.");
        }
    }

    private void prepareStatusMetadata(HttpServletRequest request) {
        request.setAttribute("orderStatusLabels", ORDER_STATUS_LABELS);
        request.setAttribute("orderStatusClasses", ORDER_STATUS_CLASSES);
        request.setAttribute("orderStatusIcons", ORDER_STATUS_ICONS);
        request.setAttribute("paymentStatusLabels", PAYMENT_STATUS_LABELS);
        request.setAttribute("paymentStatusClasses", PAYMENT_STATUS_CLASSES);
        request.setAttribute("paymentStatusIcons", PAYMENT_STATUS_ICONS);
        request.setAttribute("paymentMethodLabels", PAYMENT_METHOD_LABELS);
    }

    private int progressStep(String status) {
        return switch (status) {
            case "PENDING" -> 1;
            case "CONFIRMED" -> 2;
            case "PROCESSING" -> 3;
            case "SHIPPING" -> 4;
            case "COMPLETED" -> 5;
            default -> 0;
        };
    }

    private String formatDateTime(LocalDateTime value) {
        return value == null ? "—" : value.format(DISPLAY_DATE_TIME);
    }

    private String displayHistoryNote(String note) {
        if (note == null || note.isBlank()) return "";
        if ("Order created".equalsIgnoreCase(note.trim())) return "Đơn hàng được tạo";
        return note;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        try {
            Order order = orderService.findById(WebUtil.longParam(request, "orderId"));
            if (order == null || !order.getUser().getUserId().equals(userId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            String reason = ValidationUtil.requiredText(
                    request.getParameter("reason"), "Lý do hủy đơn", 500);
            orderService.cancel(order.getOrderId(), userId, "Khách hàng: " + reason);
            WebUtil.success(request, "Đã hủy đơn hàng và hoàn lại tồn kho.");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            WebUtil.error(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/orders");
    }
}
