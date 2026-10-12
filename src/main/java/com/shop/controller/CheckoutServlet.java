package com.shop.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.shop.entity.Addresses;
import com.shop.entity.CartItem;
import com.shop.service.AddressesService;
import com.shop.service.CartService;
import com.shop.service.OrderService;
import com.shop.service.ProductImageService;
import com.shop.service.VNPayPaymentService;
import com.shop.service.impl.AddressesServiceImpl;
import com.shop.service.impl.CartServiceImpl;
import com.shop.service.impl.OrderServiceImpl;
import com.shop.service.impl.ProductImageServiceImpl;
import com.shop.service.impl.VNPayPaymentServiceImpl;
import com.shop.utils.VNPayConfig;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final CartService cartService = new CartServiceImpl();
    private final AddressesService addressesService = new AddressesServiceImpl();
    private final OrderService orderService = new OrderServiceImpl();
    private final ProductImageService imageService = new ProductImageServiceImpl();
    private final VNPayPaymentService vnpayPaymentService = new VNPayPaymentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        List<CartItem> items = cartService.getItems(userId);
        if (items.isEmpty()) {
            WebUtil.error(request, "Giỏ hàng đang trống.");
            WebUtil.redirect(request, response, "/cart");
            return;
        }
        var addresses = addressesService.findByUserId(userId);
        String selectedAddressId = request.getParameter("addressId");
        if (selectedAddressId != null && !selectedAddressId.isBlank()) {
            String candidate = selectedAddressId;
            boolean belongsToUser = addresses.stream()
                    .anyMatch(address -> address.getAddressId().toString().equals(candidate));
            if (!belongsToUser) selectedAddressId = null;
        }
        if (selectedAddressId == null && !addresses.isEmpty()) {
            selectedAddressId = addresses.stream().filter(Addresses::isDefaultAddress)
                    .findFirst().orElse(addresses.get(0)).getAddressId().toString();
        }
        Map<Long, String> checkoutItemImageUrls = new LinkedHashMap<>();
        for (CartItem item : items) {
            String imageUrl = imageService.findByVariantId(item.getVariant().getVariantId()).stream()
                    .findFirst()
                    .or(() -> imageService.findPrimaryByProductId(
                            item.getVariant().getProduct().getProductId()))
                    .or(() -> imageService.findByProductId(
                            item.getVariant().getProduct().getProductId()).stream().findFirst())
                    .map(image -> image.getImageUrl())
                    .orElse("assets/images/product-placeholder.svg");
            checkoutItemImageUrls.put(item.getVariant().getVariantId(), imageUrl);
        }
        HttpSession session = request.getSession();
        if (session.getAttribute("checkoutToken") == null) {
            session.setAttribute("checkoutToken", UUID.randomUUID().toString());
        }
        request.setAttribute("cartItems", items);
        request.setAttribute("checkoutItemImageUrls", checkoutItemImageUrls);
        request.setAttribute("subtotal", cartService.calculateSubtotal(userId));
        request.setAttribute("addresses", addresses);
        request.setAttribute("selectedAddressId", selectedAddressId);
        request.setAttribute("vnpayAvailable", VNPayConfig.isPaymentConfigured());
        WebUtil.forward(request, response, "checkout");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        try {
            String paymentMethod = request.getParameter("paymentMethod");
            if ("VNPAY".equals(paymentMethod)) {
                // Check before consuming the one-time token and before creating the order.
                VNPayConfig.validatePaymentConfiguration();
            }
            consumeCheckoutToken(request);
            Addresses address = resolveAddress(request, userId);
            Map<Long, Integer> quantities = new LinkedHashMap<>();
            cartService.getItems(userId).forEach(item ->
                    quantities.put(item.getVariant().getVariantId(), item.getQuantity()));
            var order = orderService.placeOrder(userId, address, quantities,
                    BigDecimal.ZERO, BigDecimal.ZERO, paymentMethod,
                    request.getParameter("customerNote"));
            if ("VNPAY".equals(paymentMethod)) {
                try {
                    String paymentUrl = vnpayPaymentService.createPaymentUrl(
                            order.getOrderCode(), userId, VNPayConfig.clientIp(request));
                    response.sendRedirect(paymentUrl);
                } catch (RuntimeException ex) {
                    WebUtil.error(request, "Đơn hàng đã được tạo nhưng chưa thể kết nối VNPay: "
                            + ex.getMessage());
                    WebUtil.redirect(request, response,
                            "/orders/detail?code=" + order.getOrderCode());
                }
                return;
            }
            WebUtil.success(request, "Đặt hàng thành công.");
            WebUtil.redirect(request, response, "/orders/detail?code=" + order.getOrderCode());
        } catch (IllegalArgumentException | IllegalStateException ex) {
            request.setAttribute("pageError", ex.getMessage());
            request.setAttribute("fieldErrors", fieldErrors(ex.getMessage()));
            doGet(request, response);
        }
    }

    private void consumeCheckoutToken(HttpServletRequest request) {
        HttpSession session = request.getSession();
        String submittedToken = request.getParameter("checkoutToken");
        synchronized (session) {
            String expectedToken = (String) session.getAttribute("checkoutToken");
            if (expectedToken == null || submittedToken == null
                    || !expectedToken.equals(submittedToken)) {
                throw new IllegalStateException(
                        "Yêu cầu đặt hàng đã được xử lý hoặc không còn hiệu lực. Vui lòng thử lại.");
            }
            session.removeAttribute("checkoutToken");
        }
    }

    private Map<String, String> fieldErrors(String message) {
        Map<String, String> errors = new LinkedHashMap<>();
        if (message == null) return errors;
        String normalized = message.toLowerCase(java.util.Locale.ROOT);
        if (normalized.contains("tên người nhận")) errors.put("receiverName", message);
        else if (normalized.contains("số điện thoại")) errors.put("receiverPhone", message);
        else if (normalized.contains("tỉnh/thành")) errors.put("province", message);
        else if (normalized.contains("quận/huyện")) errors.put("district", message);
        else if (normalized.contains("phường/xã")) errors.put("ward", message);
        else if (normalized.contains("địa chỉ cụ thể")) errors.put("addressLine", message);
        else if (normalized.contains("địa chỉ giao hàng")) errors.put("addressId", message);
        else if (normalized.contains("phương thức") || normalized.contains("payment method")
                || normalized.contains("vnpay")) {
            errors.put("paymentMethod", message);
        }
        return errors;
    }

    private Addresses resolveAddress(HttpServletRequest request, Long userId) {
        String addressId = request.getParameter("addressId");
        if (addressId != null && !addressId.isBlank()) {
            try {
                return addressesService.findForUser(userId, Long.valueOf(addressId))
                        .orElseThrow(() -> new IllegalArgumentException(
                                "Địa chỉ giao hàng không hợp lệ."));
            } catch (NumberFormatException ex) {
                throw new IllegalArgumentException("Địa chỉ giao hàng không hợp lệ.");
            }
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
