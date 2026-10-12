package com.shop.service.impl;

import java.util.List;
import java.util.Optional;

import com.shop.dao.AddressesDAO;
import com.shop.dao.UserDAO;
import com.shop.dao.impl.AddressesDAOImpl;
import com.shop.dao.impl.UserDAOImpl;
import com.shop.entity.Addresses;
import com.shop.entity.User;
import com.shop.service.AddressesService;
import com.shop.utils.ValidationUtil;

public class AddressesServiceImpl extends AbstractService<Addresses> implements AddressesService {
    private final AddressesDAO addressesDAO;
    private final UserDAO userDAO;

    public AddressesServiceImpl() { this(new AddressesDAOImpl(), new UserDAOImpl()); }

    public AddressesServiceImpl(AddressesDAO addressesDAO, UserDAO userDAO) {
        super(addressesDAO);
        this.addressesDAO = addressesDAO;
        this.userDAO = userDAO;
    }

    @Override
    public List<Addresses> findByUserId(Long userId) {
        return addressesDAO.findByUserId(userId);
    }

    @Override
    public Optional<Addresses> findDefaultByUserId(Long userId) {
        return addressesDAO.findDefaultByUserId(userId);
    }

    @Override
    public Optional<Addresses> findForUser(Long userId, Long addressId) {
        if (userId == null || addressId == null) return Optional.empty();
        Addresses address = addressesDAO.findById(addressId);
        return address != null && address.getUser().getUserId().equals(userId)
                ? Optional.of(address)
                : Optional.empty();
    }

    @Override
    public Addresses saveForUser(Long userId, Addresses address) {
        if (address == null) throw new IllegalArgumentException("Address is required");
        validate(address);
        if (userDAO.findById(userId) == null) throw new IllegalArgumentException("Không tìm thấy tài khoản.");
        return addressesDAO.saveForUser(userId, address);
    }

    @Override
    public void deleteForUser(Long userId, Long addressId) {
        if (!addressesDAO.deleteForUser(userId, addressId)) {
            throw new IllegalArgumentException("Địa chỉ không tồn tại hoặc không thuộc tài khoản này.");
        }
    }

    @Override
    public void setDefaultForUser(Long userId, Long addressId) {
        if (!addressesDAO.setDefaultForUser(userId, addressId)) {
            throw new IllegalArgumentException("Địa chỉ không tồn tại hoặc không thuộc tài khoản này.");
        }
    }

    private void validate(Addresses address) {
        address.setReceiverName(ValidationUtil.requiredText(
                address.getReceiverName(), "Tên người nhận", 150));
        address.setReceiverPhone(ValidationUtil.phone(
                address.getReceiverPhone(), "Số điện thoại người nhận"));
        address.setProvince(ValidationUtil.requiredText(address.getProvince(), "Tỉnh/thành", 100));
        address.setDistrict(ValidationUtil.requiredText(address.getDistrict(), "Quận/huyện", 100));
        address.setWard(ValidationUtil.requiredText(address.getWard(), "Phường/xã", 100));
        address.setAddressLine(ValidationUtil.requiredText(
                address.getAddressLine(), "Địa chỉ cụ thể", 255));
        ValidationUtil.requireMaxLength(address.toShippingAddress(), "Địa chỉ giao hàng", 500);
    }

}
