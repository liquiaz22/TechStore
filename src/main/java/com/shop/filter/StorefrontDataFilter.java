package com.shop.filter;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import com.shop.entity.Category;
import com.shop.entity.User;
import com.shop.service.CartService;
import com.shop.service.CategoryService;
import com.shop.service.FavoriteService;
import com.shop.service.impl.CartServiceImpl;
import com.shop.service.impl.CategoryServiceImpl;
import com.shop.service.impl.FavoriteServiceImpl;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@WebFilter("/*")
public class StorefrontDataFilter implements Filter {
    private final CategoryService categoryService = new CategoryServiceImpl();
    private final CartService cartService = new CartServiceImpl();
    private final FavoriteService favoriteService = new FavoriteServiceImpl();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String path = httpRequest.getServletPath();
        if (path.startsWith("/assets/") || path.equals("/admin")
                || path.startsWith("/admin/") || path.equals("/payment/vnpay/ipn")) {
            chain.doFilter(request, response);
            return;
        }

        request.setAttribute("storePath", path);
        request.setAttribute("headerCategories", java.util.List.of());
        request.setAttribute("cartItemCount", 0L);
        request.setAttribute("favoriteCount", 0L);
        request.setAttribute("favoriteProductIdMap", Map.of());
        try {
            request.setAttribute("headerCategories", categoryService.findByParentId(null).stream()
                    .filter(Category::isActive)
                    .limit(6)
                    .toList());

            HttpSession session = httpRequest.getSession(false);
            User user = session == null ? null : (User) session.getAttribute("user");
            if (user != null) {
                request.setAttribute("cartItemCount", cartService.countItems(user.getUserId()));
                Map<Long, Boolean> favoriteProductIdMap = new LinkedHashMap<>();
                favoriteService.findProductIdsByUserId(user.getUserId())
                        .forEach(productId -> favoriteProductIdMap.put(productId, Boolean.TRUE));
                request.setAttribute("favoriteCount", (long) favoriteProductIdMap.size());
                request.setAttribute("favoriteProductIdMap", favoriteProductIdMap);
            }
        } catch (RuntimeException ex) {
            httpRequest.getServletContext().log("Không thể tải dữ liệu header cửa hàng", ex);
        }
        chain.doFilter(request, response);
    }
}
