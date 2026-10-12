package com.shop.service;

import java.util.Optional;

import com.shop.entity.User;

public interface UserService extends GenericService<User> {
    User register(User user, String rawPassword);
    Optional<User> authenticate(String email, String rawPassword);
    Optional<User> findByEmail(String email);
    User updateProfile(Long userId, String fullName, String phone);
    void changePassword(Long userId, String currentPassword, String newPassword);
}
