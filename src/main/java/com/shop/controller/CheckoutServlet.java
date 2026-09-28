package com.shop.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;

import com.shop.entity.Addresses;
import com.shop.service.AddressesService;
import com.shop.service.CartService;
import com.shop.service.OrderService;
import com.shop.service.impl.AddressesServiceImpl;
import com.shop.service.impl.CartServiceImpl;
import com.shop.service.impl.OrderServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final CartService cartService = new CartServiceImpl();
    private final AddressesService addressesService = new AddressesServiceImpl();
    private final OrderService orderService = new OrderServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        var items = cartService.getItems(userId);
        if (items.isEmpty()) {
            WebUtil.error(request, "Giỏ hàng đang trống.");
            WebUtil.redirect(request, response, "/cart");
            return;
        }
        request.setAttribute("cartItems", items);
        request.setAttribute("subtotal", cartService.calculateSubtotal(userId));
        request.setAttribute("addresses", addressesService.findByUserId(userId));
        WebUtil.forward(request, response, "checkout");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        try {
            Addresses address = resolveAddress(request, userId);
            Map<Long, Integer> quantities = new LinkedHashMap<>();
            cartService.getItems(userId).forEach(item ->
                    quantities.put(item.getVariant().getVariantId(), item.getQuantity()));
            var order = orderService.placeOrder(userId, address, quantities,
                    BigDecimal.ZERO, BigDecimal.ZERO, request.getParameter("paymentMethod"),
                    request.getParameter("customerNote"));
            WebUtil.success(request, "Đặt hàng thành công.");
            WebUtil.redirect(request, response, "/orders/detail?code=" + order.getOrderCode());
        } catch (IllegalArgumentException | IllegalStateException ex) {
            request.setAttribute("pageError", ex.getMessage());
            doGet(request, response);
        }
    }

    private Addresses resolveAddress(HttpServletRequest request, Long userId) {
        String addressId = request.getParameter("addressId");
        if (addressId != null && !addressId.isBlank()) {
            Addresses address = addressesService.findById(Long.valueOf(addressId));
            if (address == null || !address.getUser().getUserId().equals(userId)) {
                throw new IllegalArgumentException("Địa chỉ giao hàng không hợp lệ.");
            }
            return address;
        }
        Addresses address = new Addresses();
        address.setReceiverName(request.getParameter("receiverName"));
        address.setReceiverPhone(request.getParameter("receiverPhone"));
        address.setProvince(request.getParameter("province"));
        address.setDistrict(request.getParameter("district"));
        address.setWard(request.getParameter("ward"));
        address.setAddressLine(request.getParameter("addressLine"));
        return address;
    }
}
