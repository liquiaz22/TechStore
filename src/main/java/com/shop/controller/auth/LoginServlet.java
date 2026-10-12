package com.shop.controller.auth;

import java.io.IOException;

import com.shop.service.UserService;
import com.shop.service.impl.UserServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        var currentUser = WebUtil.currentUser(request);
        if (currentUser != null) {
            WebUtil.redirect(request, response,
                    "ADMIN".equals(currentUser.getRole()) ? "/admin" : "/home");
            return;
        }
        WebUtil.forward(request, response, "auth/login");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        var user = userService.authenticate(email, password);
        if (user.isEmpty()) {
            request.setAttribute("pageError", "Email hoặc mật khẩu không đúng, hoặc tài khoản đã bị khóa.");
            request.setAttribute("email", email);
            WebUtil.forward(request, response, "auth/login");
            return;
        }
        request.changeSessionId();
        request.getSession().setAttribute("user", user.get());
        String savedUrl = (String) request.getSession().getAttribute("savedUrl");
        request.getSession().removeAttribute("savedUrl");

        boolean validSavedUrl = savedUrl != null
                && savedUrl.startsWith(request.getContextPath() + "/");
        boolean admin = "ADMIN".equals(user.get().getRole());
        if (admin) {
            if (validSavedUrl && savedUrl.startsWith(request.getContextPath() + "/admin")) {
                response.sendRedirect(savedUrl);
            } else {
                WebUtil.redirect(request, response, "/admin");
            }
            return;
        }
        if (validSavedUrl && !savedUrl.startsWith(request.getContextPath() + "/admin")) {
            response.sendRedirect(savedUrl);
            return;
        }
        WebUtil.redirect(request, response, "/home");
    }
}
