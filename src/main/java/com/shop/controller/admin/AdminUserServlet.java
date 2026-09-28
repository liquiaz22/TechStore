package com.shop.controller.admin;

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

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("users", userService.findAll());
        WebUtil.forward(request, response, "admin/users");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            Long id = WebUtil.longParam(request, "userId");
            if (id.equals(WebUtil.currentUser(request).getUserId())) {
                throw new IllegalArgumentException("Không thể khóa chính tài khoản đang đăng nhập.");
            }
            User user = userService.findById(id);
            if (user == null) throw new IllegalArgumentException("Không tìm thấy người dùng.");
            user.setStatus("ACTIVE".equals(user.getStatus()) ? "LOCKED" : "ACTIVE");
            userService.update(user);
            WebUtil.success(request, "Đã cập nhật trạng thái người dùng.");
        } catch (RuntimeException ex) {
            WebUtil.error(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/admin/users");
    }
}
