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
    public Addresses saveForUser(Long userId, Addresses address) {
        if (address == null) throw new IllegalArgumentException("Address is required");
        validate(address);
        User user = userDAO.findById(userId);
        if (user == null) throw new IllegalArgumentException("User not found");

        if (address.getAddressId() != null) {
            Addresses current = addressesDAO.findById(address.getAddressId());
            if (current == null || !current.getUser().getUserId().equals(userId)) {
                throw new IllegalArgumentException("Address does not belong to this user");
            }
        }

        boolean firstAddress = addressesDAO.findByUserId(userId).isEmpty();
        address.setUser(user);
        if (address.isDefaultAddress() || firstAddress) {
            addressesDAO.clearDefaultByUserId(userId);
            address.setDefaultAddress(true);
        }
        return address.getAddressId() == null
                ? createAndReturn(address)
                : addressesDAO.update(address);
    }

    private Addresses createAndReturn(Addresses address) {
        addressesDAO.create(address);
        return address;
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
