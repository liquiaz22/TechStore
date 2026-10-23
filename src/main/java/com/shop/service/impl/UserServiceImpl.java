package com.shop.service.impl;

import java.util.Optional;

import org.mindrot.jbcrypt.BCrypt;

import com.shop.dao.UserDAO;
import com.shop.dao.impl.UserDAOImpl;
import com.shop.entity.User;
import com.shop.service.UserService;
import com.shop.utils.ValidationUtil;

public class UserServiceImpl extends AbstractService<User> implements UserService {
    private final UserDAO userDAO;

    public UserServiceImpl() { this(new UserDAOImpl()); }

    public UserServiceImpl(UserDAO userDAO) {
        super(userDAO);
        this.userDAO = userDAO;
    }

    @Override
    public User register(User user, String rawPassword) {
        if (user == null) throw new IllegalArgumentException("User is required");
        String email = normalizeEmail(user.getEmail());
        if (userDAO.existsByEmail(email)) throw new IllegalArgumentException("Email already exists");
        validatePassword(rawPassword);
        user.setEmail(email);
        user.setFullName(ValidationUtil.requiredText(user.getFullName(), "Họ và tên", 150));
        user.setPhone(ValidationUtil.optionalPhone(user.getPhone(), "Số điện thoại"));
        user.setPasswordHash(BCrypt.hashpw(rawPassword, BCrypt.gensalt(12)));
        user.setRole("CUSTOMER");
        user.setStatus("ACTIVE");
        userDAO.create(user);
        return user;
    }

    @Override
    public Optional<User> authenticate(String email, String rawPassword) {
        if (rawPassword == null || rawPassword.isEmpty() || rawPassword.length() > 72) {
            return Optional.empty();
        }
        String normalizedEmail;
        try {
            normalizedEmail = normalizeEmail(email);
        } catch (IllegalArgumentException ex) {
            return Optional.empty();
        }
        return userDAO.findByEmail(normalizedEmail)
                .filter(user -> "ACTIVE".equals(user.getStatus()))
                .filter(user -> BCrypt.checkpw(rawPassword, user.getPasswordHash()));
    }

    @Override
    public Optional<User> findByEmail(String email) {
        return userDAO.findByEmail(normalizeEmail(email));
    }

    @Override
    public User updateProfile(Long userId, String fullName, String phone) {
        User user = requireUser(userId);
        user.setFullName(ValidationUtil.requiredText(fullName, "Họ và tên", 150));
        user.setPhone(ValidationUtil.optionalPhone(phone, "Số điện thoại"));
        return userDAO.update(user);
    }

    @Override
    public void changePassword(Long userId, String currentPassword, String newPassword) {
        User user = requireUser(userId);
        if (currentPassword == null || currentPassword.isEmpty()
                || currentPassword.length() > 72
                || !BCrypt.checkpw(currentPassword, user.getPasswordHash())) {
            throw new IllegalArgumentException("Mật khẩu hiện tại không đúng.");
        }
        validatePassword(newPassword);
        if (BCrypt.checkpw(newPassword, user.getPasswordHash())) {
            throw new IllegalArgumentException("Mật khẩu mới phải khác mật khẩu hiện tại.");
        }
        user.setPasswordHash(BCrypt.hashpw(newPassword, BCrypt.gensalt(12)));
        userDAO.update(user);
    }

    private User requireUser(Long userId) {
        User user = userDAO.findById(userId);
        if (user == null) throw new IllegalArgumentException("User not found");
        return user;
    }

    private String normalizeEmail(String email) {
        return ValidationUtil.email(email);
    }

    public void validatePassword(String password) {
        if (password == null || password.length() < 8 || password.length() > 72) {
            throw new IllegalArgumentException("Mật khẩu phải dài từ 8 đến 72 ký tự.");
        }
    }

}
