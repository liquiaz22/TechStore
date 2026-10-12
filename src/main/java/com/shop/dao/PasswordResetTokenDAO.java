package com.shop.dao;

import java.time.LocalDateTime;

import com.shop.entity.PasswordResetToken;
import com.shop.utils.GenericDAO;

public interface PasswordResetTokenDAO extends GenericDAO<PasswordResetToken> {
    long countCreatedSince(Long userId, LocalDateTime since);
    void replaceActiveToken(Long userId, PasswordResetToken token, LocalDateTime now);
    void invalidate(String tokenHash, LocalDateTime now);
    boolean consumeAndChangePassword(String tokenHash, String passwordHash, LocalDateTime now);
}
