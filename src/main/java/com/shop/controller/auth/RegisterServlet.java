package com.shop.controller.auth;

import java.io.IOException;

import com.shop.entity.User;
import com.shop.service.UserService;
import com.shop.service.impl.UserServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        WebUtil.forward(request, response, "auth/register");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String password = request.getParameter("password");
            if (!password.equals(request.getParameter("confirmPassword"))) {
                throw new IllegalArgumentException("Mật khẩu xác nhận không khớp.");
            }
            User user = new User();
            user.setEmail(request.getParameter("email"));
            user.setFullName(request.getParameter("fullName"));
            user.setPhone(WebUtil.trimToNull(request.getParameter("phone")));
            userService.register(user, password);
            WebUtil.success(request, "Đăng ký thành công. Ông có thể đăng nhập ngay.");
            WebUtil.redirect(request, response, "/login");
        } catch (IllegalArgumentException ex) {
            request.setAttribute("pageError", ex.getMessage());
            WebUtil.forward(request, response, "auth/register");
        }
    }
}
