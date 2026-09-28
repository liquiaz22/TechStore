package com.shop.controller.admin;

import java.io.IOException;

import com.shop.service.OrderService;
import com.shop.service.impl.OrderServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/admin/orders", "/admin/orders/status"})
public class AdminOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final OrderService orderService = new OrderServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String status = WebUtil.trimToNull(request.getParameter("status"));
        request.setAttribute("selectedStatus", status);
        request.setAttribute("orders", status == null
                ? orderService.findAll() : orderService.findByStatus(status, 0, 100));
        WebUtil.forward(request, response, "admin/orders");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            orderService.updateStatus(WebUtil.longParam(request, "orderId"),
                    request.getParameter("status"), WebUtil.currentUser(request).getUserId(),
                    WebUtil.trimToNull(request.getParameter("note")));
            WebUtil.success(request, "Đã cập nhật trạng thái đơn hàng.");
        } catch (RuntimeException ex) {
            WebUtil.error(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/admin/orders");
    }
}
