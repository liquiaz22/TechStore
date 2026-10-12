package com.shop.controller.payment;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import com.shop.dto.VNPayResult;
import com.shop.service.VNPayPaymentService;
import com.shop.service.impl.VNPayPaymentServiceImpl;
import com.shop.utils.VNPayConfig;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {
        "/payment/vnpay/start", "/payment/vnpay/return", "/payment/vnpay/ipn"
})
public class VNPayServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final VNPayPaymentService vnpayService = new VNPayPaymentServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!request.getServletPath().endsWith("/start")) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        try {
            String paymentUrl = vnpayService.createPaymentUrl(
                    request.getParameter("orderCode"),
                    WebUtil.currentUser(request).getUserId(),
                    VNPayConfig.clientIp(request));
            response.sendRedirect(paymentUrl);
        } catch (IllegalArgumentException | IllegalStateException ex) {
            WebUtil.error(request, ex.getMessage());
            WebUtil.redirect(request, response, "/orders");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, String> parameters = singleValueParameters(request);
        VNPayResult result = parameters == null
                ? new VNPayResult("99", "Invalid Data", false, null,
                        "Phản hồi VNPay chứa tham số không hợp lệ.")
                : vnpayService.processCallback(parameters);
        if (request.getServletPath().endsWith("/ipn")) {
            writeIpnResponse(response, result);
            return;
        }
        response.setHeader("Cache-Control", "no-store");
        request.setAttribute("paymentResult", result);
        WebUtil.forward(request, response, "payment/vnpay-result");
    }

    private Map<String, String> singleValueParameters(HttpServletRequest request) {
        Map<String, String> result = new LinkedHashMap<>();
        for (Map.Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
            if (entry.getValue() == null || entry.getValue().length != 1) return null;
            if (entry.getKey() == null || entry.getKey().length() > 100
                    || entry.getValue()[0] == null || entry.getValue()[0].length() > 1000) {
                return null;
            }
            result.put(entry.getKey(), entry.getValue()[0]);
        }
        return result;
    }

    private void writeIpnResponse(HttpServletResponse response, VNPayResult result)
            throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setHeader("Cache-Control", "no-store");
        response.getWriter().write("{\"RspCode\":\"" + json(result.getResponseCode())
                + "\",\"Message\":\"" + json(result.getResponseMessage()) + "\"}");
    }

    private String json(String value) {
        return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
