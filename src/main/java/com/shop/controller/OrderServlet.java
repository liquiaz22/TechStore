package com.shop.controller;

import java.io.IOException;

import com.shop.entity.Order;
import com.shop.service.OrderItemService;
import com.shop.service.OrderService;
import com.shop.service.OrderStatusHistoryService;
import com.shop.service.PaymentService;
import com.shop.service.impl.OrderItemServiceImpl;
import com.shop.service.impl.OrderServiceImpl;
import com.shop.service.impl.OrderStatusHistoryServiceImpl;
import com.shop.service.impl.PaymentServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/orders", "/orders/detail", "/orders/cancel"})
public class OrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
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
            request.setAttribute("histories", historyService.findByOrderId(order.getOrderId()));
            request.setAttribute("payments", paymentService.findByOrderId(order.getOrderId()));
            WebUtil.forward(request, response, "order/detail");
            return;
        }
        int page = request.getParameter("page") == null ? 1
                : Math.max(1, Integer.parseInt(request.getParameter("page")));
        request.setAttribute("orders", orderService.findByUserId(userId, page - 1, 20));
        request.setAttribute("currentPage", page);
        WebUtil.forward(request, response, "order/list");
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
            orderService.cancel(order.getOrderId(), userId, "Khách hàng hủy đơn");
            WebUtil.success(request, "Đã hủy đơn hàng và hoàn lại tồn kho.");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            WebUtil.error(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/orders");
    }
}
