package com.shop.controller.account;

import java.io.IOException;

import com.shop.service.UserService;
import com.shop.service.impl.UserServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/account/password")
public class AccountPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        WebUtil.redirect(request, response, "/account/profile");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String newPassword = request.getParameter("newPassword");
            if (newPassword == null
                    || !newPassword.equals(request.getParameter("confirmPassword"))) {
                throw new IllegalArgumentException("Mật khẩu xác nhận không khớp.");
            }
            userService.changePassword(
                    WebUtil.currentUser(request).getUserId(),
                    request.getParameter("currentPassword"),
                    newPassword);
            request.changeSessionId();
            WebUtil.success(request, "Đổi mật khẩu thành công.");
            WebUtil.redirect(request, response, "/account/profile");
        } catch (IllegalArgumentException ex) {
            request.setAttribute("pageError", ex.getMessage());
            request.setAttribute("profile", WebUtil.currentUser(request));
            request.setAttribute("passwordFormOpen", true);
            WebUtil.forward(request, response, "account/profile");
        }
    }
}
