package com.shop.controller.admin;

import java.io.IOException;

import com.shop.service.OrderService;
import com.shop.service.ProductService;
import com.shop.service.UserService;
import com.shop.service.impl.OrderServiceImpl;
import com.shop.service.impl.ProductServiceImpl;
import com.shop.service.impl.UserServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin")
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserService userService = new UserServiceImpl();
    private final ProductService productService = new ProductServiceImpl();
    private final OrderService orderService = new OrderServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("userCount", userService.count());
        request.setAttribute("productCount", productService.count());
        request.setAttribute("orderCount", orderService.count());
        request.setAttribute("pendingOrders", orderService.findByStatus("PENDING", 0, 8));
        WebUtil.forward(request, response, "admin/dashboard");
    }
}
