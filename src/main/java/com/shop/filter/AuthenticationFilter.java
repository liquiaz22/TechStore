package com.shop.filter;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebFilter(urlPatterns = {
        "/favorites", "/favorites/*", "/cart", "/cart/*",
        "/checkout", "/orders", "/orders/*", "/account/*", "/payment/vnpay/start"
})
public class AuthenticationFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        if (httpRequest.getSession().getAttribute("user") == null) {
            String savedUrl = httpRequest.getRequestURI();
            if (httpRequest.getQueryString() != null) savedUrl += "?" + httpRequest.getQueryString();
            httpRequest.getSession().setAttribute("savedUrl", savedUrl);
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }
        chain.doFilter(request, response);
    }
}
