package com.shop.dao.impl;

import java.util.List;
import java.util.Locale;
import java.util.Optional;

import com.shop.dao.UserDAO;
import com.shop.entity.User;
import com.shop.utils.GenericDAOImpl;

public class UserDAOImpl extends GenericDAOImpl<User> implements UserDAO {

	public UserDAOImpl() {
		super(User.class);
	}

    @Override
    public Optional<User> findByEmail(String email) {
        String normalized = email == null ? "" : email.trim().toLowerCase(Locale.ROOT);
        return findOne("FROM User u WHERE LOWER(u.email) = :email",
                q -> q.setParameter("email", normalized));
    }

    @Override
    public boolean existsByEmail(String email) {
        return findByEmail(email).isPresent();
    }

    @Override
    public List<User> findByRole(String role) {
        return findMany("FROM User u WHERE u.role = :role ORDER BY u.createdAt DESC",
                q -> q.setParameter("role", role));
    }

    @Override
    public List<User> findByStatus(String status) {
        return findMany("FROM User u WHERE u.status = :status ORDER BY u.createdAt DESC",
                q -> q.setParameter("status", status));
    }

}
