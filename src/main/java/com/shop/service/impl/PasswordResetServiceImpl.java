package com.shop.service.impl;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Optional;

import org.mindrot.jbcrypt.BCrypt;

import com.shop.dao.PasswordResetTokenDAO;
import com.shop.dao.UserDAO;
import com.shop.dao.impl.PasswordResetTokenDAOImpl;
import com.shop.dao.impl.UserDAOImpl;
import com.shop.entity.PasswordResetToken;
import com.shop.entity.User;
import com.shop.service.PasswordResetService;
import com.shop.utils.ConfigUtil;
import com.shop.utils.ValidationUtil;
import com.shop.utils.XMail;

public class PasswordResetServiceImpl implements PasswordResetService {
    private static final int TOKEN_BYTES = 32;
    private static final int TOKEN_EXPIRY_MINUTES = 30;
    private static final int MAX_REQUESTS_PER_WINDOW = 3;
    private static final int RATE_WINDOW_MINUTES = 15;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private final UserDAO userDAO;
    private final PasswordResetTokenDAO tokenDAO;

    public PasswordResetServiceImpl() {
        this(new UserDAOImpl(), new PasswordResetTokenDAOImpl());
    }

    public PasswordResetServiceImpl(UserDAO userDAO, PasswordResetTokenDAO tokenDAO) {
        this.userDAO = userDAO;
        this.tokenDAO = tokenDAO;
    }

    @Override
    public void requestReset(String email) {
        String normalizedEmail;
        try {
            normalizedEmail = ValidationUtil.email(email);
        } catch (IllegalArgumentException ex) {
            return;
        }
        Optional<User> found = userDAO.findByEmail(normalizedEmail)
                .filter(user -> "ACTIVE".equals(user.getStatus()));
        if (found.isEmpty()) return;

        User user = found.get();
        LocalDateTime now = LocalDateTime.now();
        long recentRequests = tokenDAO.countCreatedSince(
                user.getUserId(), now.minusMinutes(RATE_WINDOW_MINUTES));
        if (recentRequests >= MAX_REQUESTS_PER_WINDOW) return;

        byte[] tokenBytes = new byte[TOKEN_BYTES];
        SECURE_RANDOM.nextBytes(tokenBytes);
        String rawToken = Base64.getUrlEncoder().withoutPadding().encodeToString(tokenBytes);

        PasswordResetToken token = new PasswordResetToken();
        token.setTokenHash(hashToken(rawToken));
        token.setCreatedAt(now);
        token.setExpiresAt(now.plusMinutes(TOKEN_EXPIRY_MINUTES));
        tokenDAO.replaceActiveToken(user.getUserId(), token, now);

        String appUrl = requireAppUrl();
        String resetUrl = appUrl + "/reset-password?token=" + rawToken;
        try {
            XMail.sendPasswordResetLink(user, resetUrl);
        } catch (RuntimeException ex) {
            tokenDAO.invalidate(token.getTokenHash(), LocalDateTime.now());
            throw ex;
        }
    }

    @Override
    public void resetPassword(String rawToken, String newPassword) {
        if (rawToken == null || rawToken.isBlank() || rawToken.length() > 200) {
            throw new IllegalArgumentException("Liên kết đặt lại mật khẩu không hợp lệ hoặc đã hết hạn.");
        }
        validatePassword(newPassword);
        String passwordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
        if (!tokenDAO.consumeAndChangePassword(
                hashToken(rawToken.trim()), passwordHash, LocalDateTime.now())) {
            throw new IllegalArgumentException("Liên kết đặt lại mật khẩu không hợp lệ hoặc đã hết hạn.");
        }
    }

    private String requireAppUrl() {
        String appUrl = ConfigUtil.get("app.url");
        if (appUrl == null || appUrl.isBlank()) {
            throw new IllegalStateException("Thiếu cấu hình app.url để tạo liên kết đặt lại mật khẩu.");
        }
        return appUrl.endsWith("/") ? appUrl.substring(0, appUrl.length() - 1) : appUrl;
    }

    private String hashToken(String rawToken) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest(rawToken.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 is not available", ex);
        }
    }

    private void validatePassword(String password) {
        if (password == null || password.length() < 8 || password.length() > 72) {
            throw new IllegalArgumentException("Mật khẩu phải dài từ 8 đến 72 ký tự.");
        }
    }
}
