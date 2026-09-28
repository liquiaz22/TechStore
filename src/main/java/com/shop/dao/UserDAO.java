package com.shop.dao;

import com.shop.entity.User;
import com.shop.utils.GenericDAO;

import java.util.List;
import java.util.Optional;

public interface UserDAO extends GenericDAO<User> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    List<User> findByRole(String role);
    List<User> findByStatus(String status);
}
