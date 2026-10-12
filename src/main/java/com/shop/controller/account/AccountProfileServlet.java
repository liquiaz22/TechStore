package com.shop.controller.account;

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

@WebServlet("/account/profile")
public class AccountProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = userService.findById(WebUtil.currentUser(request).getUserId());
        if (user == null) {
            request.getSession().invalidate();
            WebUtil.redirect(request, response, "/login");
            return;
        }
        request.getSession().setAttribute("user", user);
        request.setAttribute("profile", user);
        WebUtil.forward(request, response, "account/profile");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            User updated = userService.updateProfile(
                    WebUtil.currentUser(request).getUserId(),
                    request.getParameter("fullName"),
                    request.getParameter("phone"));
            request.getSession().setAttribute("user", updated);
            WebUtil.success(request, "Cập nhật hồ sơ thành công.");
            WebUtil.redirect(request, response, "/account/profile");
        } catch (IllegalArgumentException ex) {
            request.setAttribute("pageError", ex.getMessage());
            request.setAttribute("profile", WebUtil.currentUser(request));
            WebUtil.forward(request, response, "account/profile");
        }
    }
}
