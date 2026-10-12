package com.shop.controller.auth;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.shop.service.PasswordResetService;
import com.shop.service.impl.PasswordResetServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ForgotPasswordServlet.class.getName());
    private static final String GENERIC_MESSAGE = "Nếu email tồn tại và đang hoạt động, "
            + "TechStore sẽ gửi liên kết đặt lại mật khẩu.";
    private final PasswordResetService passwordResetService = new PasswordResetServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        WebUtil.forward(request, response, "auth/forgot-password");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            passwordResetService.requestReset(request.getParameter("email"));
        } catch (RuntimeException ex) {
            LOGGER.log(Level.WARNING, "Password reset email could not be sent", ex);
        }
        request.setAttribute("requestAccepted", true);
        request.setAttribute("pageMessage", GENERIC_MESSAGE);
        WebUtil.forward(request, response, "auth/forgot-password");
    }
}
