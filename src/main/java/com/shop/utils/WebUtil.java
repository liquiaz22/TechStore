package com.shop.utils;

import java.io.IOException;
import java.math.BigDecimal;

import com.shop.entity.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public final class WebUtil {
    private WebUtil() {}

    public static User currentUser(HttpServletRequest request) {
        return (User) request.getSession().getAttribute("user");
    }

    public static long longParam(HttpServletRequest request, String name) {
        return Long.parseLong(request.getParameter(name));
    }

    public static Integer integerParam(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null || value.isBlank() ? null : Integer.valueOf(value);
    }

    public static BigDecimal decimalParam(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null || value.isBlank() ? null : new BigDecimal(value);
    }

    public static String trimToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    public static void success(HttpServletRequest request, String message) {
        request.getSession().setAttribute("flashSuccess", message);
    }

    public static void error(HttpServletRequest request, String message) {
        request.getSession().setAttribute("flashError", message);
    }

    public static void forward(HttpServletRequest request, HttpServletResponse response, String view)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/" + view + ".jsp").forward(request, response);
    }

    public static void redirect(HttpServletRequest request, HttpServletResponse response, String path)
            throws IOException {
        response.sendRedirect(request.getContextPath() + path);
    }
}
