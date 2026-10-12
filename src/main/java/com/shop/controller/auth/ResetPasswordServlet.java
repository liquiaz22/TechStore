package com.shop.controller.auth;

import java.io.IOException;

import com.shop.service.PasswordResetService;
import com.shop.service.impl.PasswordResetServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final PasswordResetService passwordResetService = new PasswordResetServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("token", request.getParameter("token"));
        WebUtil.forward(request, response, "auth/reset-password");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        try {
            String newPassword = request.getParameter("newPassword");
            if (newPassword == null
                    || !newPassword.equals(request.getParameter("confirmPassword"))) {
                throw new IllegalArgumentException("Mật khẩu xác nhận không khớp.");
            }
            passwordResetService.resetPassword(token, newPassword);
            WebUtil.success(request, "Đặt lại mật khẩu thành công. Bạn có thể đăng nhập ngay.");
            WebUtil.redirect(request, response, "/login");
        } catch (IllegalArgumentException ex) {
            request.setAttribute("token", token);
            request.setAttribute("pageError", ex.getMessage());
            WebUtil.forward(request, response, "auth/reset-password");
        }
    }
}
