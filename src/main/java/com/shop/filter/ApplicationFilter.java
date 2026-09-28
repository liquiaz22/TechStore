package com.shop.filter;

import java.io.IOException;
import java.util.UUID;

import com.shop.utils.XHttp;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter("/*")
public class ApplicationFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        httpResponse.setHeader("X-Content-Type-Options", "nosniff");
        httpResponse.setHeader("X-Frame-Options", "DENY");
        httpResponse.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");

        String uri = httpRequest.getRequestURI();
        if (!uri.contains("/assets/")) {
            HttpSession session = httpRequest.getSession();
            String csrfToken = (String) session.getAttribute("csrfToken");
            if (csrfToken == null) {
                csrfToken = UUID.randomUUID().toString();
                session.setAttribute("csrfToken", csrfToken);
            }
            request.setAttribute("csrfToken", csrfToken);

            if (isUnsafe(httpRequest.getMethod()) && !uri.contains("/payment/callback")) {
                String submitted = httpRequest.getHeader("X-CSRF-Token");
                if (submitted == null) submitted = httpRequest.getParameter("_csrf");
                if (!csrfToken.equals(submitted)) {
                    httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token is invalid");
                    return;
                }
            }
        }

        XHttp.add(request, response);
        try {
            chain.doFilter(request, response);
        } finally {
            XHttp.remove();
        }
    }

    private boolean isUnsafe(String method) {
        return "POST".equalsIgnoreCase(method)
                || "PUT".equalsIgnoreCase(method)
                || "PATCH".equalsIgnoreCase(method)
                || "DELETE".equalsIgnoreCase(method);
    }
}
