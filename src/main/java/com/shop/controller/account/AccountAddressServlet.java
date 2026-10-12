package com.shop.controller.account;

import java.io.IOException;

import com.shop.entity.Addresses;
import com.shop.service.AddressesService;
import com.shop.service.impl.AddressesServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/account/addresses")
public class AccountAddressServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AddressesService addressesService = new AddressesServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        String editId = request.getParameter("edit");
        if (editId != null && !editId.isBlank()) {
            try {
                addressesService.findForUser(userId, Long.valueOf(editId))
                        .ifPresent(address -> request.setAttribute("editingAddress", address));
            } catch (NumberFormatException ignored) {
                request.setAttribute("pageError", "Mã địa chỉ không hợp lệ.");
            }
        }
        request.setAttribute("addresses", addressesService.findByUserId(userId));
        WebUtil.forward(request, response, "account/addresses");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = WebUtil.currentUser(request).getUserId();
        String action = request.getParameter("action");
        try {
            if ("delete".equals(action)) {
                addressesService.deleteForUser(userId, requiredId(request));
                WebUtil.success(request, "Đã xóa địa chỉ.");
            } else if ("default".equals(action)) {
                addressesService.setDefaultForUser(userId, requiredId(request));
                WebUtil.success(request, "Đã chọn địa chỉ mặc định.");
            } else if ("save".equals(action)) {
                Addresses address = addressFromRequest(request);
                boolean isNew = address.getAddressId() == null;
                addressesService.saveForUser(userId, address);
                WebUtil.success(request, isNew
                        ? "Đã thêm địa chỉ mới."
                        : "Đã cập nhật địa chỉ.");
            } else {
                throw new IllegalArgumentException("Thao tác địa chỉ không hợp lệ.");
            }
            WebUtil.redirect(request, response, "/account/addresses");
        } catch (IllegalArgumentException ex) {
            request.setAttribute("pageError", ex.getMessage());
            request.setAttribute("editingAddress", addressFromRequestSafely(request));
            request.setAttribute("addresses", addressesService.findByUserId(userId));
            WebUtil.forward(request, response, "account/addresses");
        }
    }

    private Long requiredId(HttpServletRequest request) {
        try {
            return Long.valueOf(request.getParameter("addressId"));
        } catch (NumberFormatException | NullPointerException ex) {
            throw new IllegalArgumentException("Mã địa chỉ không hợp lệ.");
        }
    }

    private Addresses addressFromRequest(HttpServletRequest request) {
        Addresses address = new Addresses();
        String id = request.getParameter("addressId");
        if (id != null && !id.isBlank()) {
            try {
                address.setAddressId(Long.valueOf(id));
            } catch (NumberFormatException ex) {
                throw new IllegalArgumentException("Mã địa chỉ không hợp lệ.");
            }
        }
        address.setReceiverName(request.getParameter("receiverName"));
        address.setReceiverPhone(request.getParameter("receiverPhone"));
        address.setProvince(request.getParameter("province"));
        address.setDistrict(request.getParameter("district"));
        address.setWard(request.getParameter("ward"));
        address.setAddressLine(request.getParameter("addressLine"));
        address.setDefaultAddress("true".equals(request.getParameter("defaultAddress")));
        return address;
    }

    private Addresses addressFromRequestSafely(HttpServletRequest request) {
        try {
            return addressFromRequest(request);
        } catch (IllegalArgumentException ex) {
            return new Addresses();
        }
    }
}
