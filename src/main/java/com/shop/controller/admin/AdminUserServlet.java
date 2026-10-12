package com.shop.controller.admin;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Locale;
import java.util.Set;

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
    private static final int PAGE_SIZE = 15;
    private static final Set<String> STATUSES = Set.of("ACTIVE", "LOCKED");
    private static final Set<String> ROLES = Set.of("ADMIN", "CUSTOMER");
    private final UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = WebUtil.trimToNull(request.getParameter("q"));
        if (keyword != null && keyword.length() > 150) {
            throw new ServletException("Từ khóa tìm kiếm quá dài.");
        }
        String status = WebUtil.trimToNull(request.getParameter("status"));
        String role = WebUtil.trimToNull(request.getParameter("role"));
        if (status != null && !STATUSES.contains(status)) status = null;
        if (role != null && !ROLES.contains(role)) role = null;
        String normalizedKeyword = keyword == null ? null : keyword.toLowerCase(Locale.ROOT);
        String selectedStatus = status;
        String selectedRole = role;
        List<User> filtered = userService.findAll().stream()
                .filter(user -> normalizedKeyword == null
                        || user.getFullName().toLowerCase(Locale.ROOT).contains(normalizedKeyword)
                        || user.getEmail().toLowerCase(Locale.ROOT).contains(normalizedKeyword)
                        || (user.getPhone() != null && user.getPhone().contains(normalizedKeyword)))
                .filter(user -> selectedStatus == null || selectedStatus.equals(user.getStatus()))
                .filter(user -> selectedRole == null || selectedRole.equals(user.getRole()))
                .toList();
        int totalPages = Math.max(1, (int) Math.ceil(filtered.size() / (double) PAGE_SIZE));
        int page = Math.min(parsePage(request.getParameter("page")), totalPages);
        int fromIndex = Math.min((page - 1) * PAGE_SIZE, filtered.size());
        int toIndex = Math.min(fromIndex + PAGE_SIZE, filtered.size());
        request.setAttribute("users", filtered.subList(fromIndex, toIndex));
        request.setAttribute("totalUsers", filtered.size());
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedRole", role);
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
        WebUtil.redirect(request, response, "/admin/users" + filterQuery(request));
    }

    private int parsePage(String value) {
        try {
            return value == null || value.isBlank() ? 1 : Math.max(1, Integer.parseInt(value));
        } catch (NumberFormatException ex) {
            return 1;
        }
    }

    private String filterQuery(HttpServletRequest request) {
        StringBuilder query = new StringBuilder();
        appendQuery(query, "q", request.getParameter("q"));
        appendQuery(query, "status", request.getParameter("filterStatus"));
        appendQuery(query, "role", request.getParameter("role"));
        appendQuery(query, "page", request.getParameter("page"));
        return query.toString();
    }

    private void appendQuery(StringBuilder query, String name, String value) {
        String normalized = WebUtil.trimToNull(value);
        if (normalized == null) return;
        query.append(query.isEmpty() ? '?' : '&').append(name).append('=')
                .append(URLEncoder.encode(normalized, StandardCharsets.UTF_8));
    }
}
