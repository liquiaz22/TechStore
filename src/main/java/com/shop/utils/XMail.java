package com.shop.utils;

import java.util.Properties;

import com.shop.entity.User;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public final class XMail {
    private XMail() {}

    public static void sendWelcome(User user) {
        String appUrl = ConfigUtil.get("app.url");
        String body = "<p>Chào " + escapeHtml(user.getFullName()) + ",</p>"
                + "<p>Chào mừng bạn đến với TechStore.</p>"
                + "<p><a href=\"" + escapeHtml(appUrl) + "/home\">Truy cập TechStore</a></p>";
        send(user.getEmail(), "Chào mừng bạn đến với TechStore", body);
    }

    public static void sendPasswordResetLink(User user, String resetUrl) {
        String body = "<p>Chào " + escapeHtml(user.getFullName()) + ",</p>"
                + "<p>TechStore nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn.</p>"
                + "<p><a href=\"" + escapeHtml(resetUrl)
                + "\">Đặt lại mật khẩu</a></p>"
                + "<p>Liên kết có hiệu lực trong 30 phút và chỉ sử dụng được một lần. "
                + "Nếu bạn không gửi yêu cầu này, hãy bỏ qua email.</p>";
        send(user.getEmail(), "Đặt lại mật khẩu TechStore", body);
    }

    public static void send(String to, String subject, String htmlContent) {
        String username = requiredConfig("mail.username");
        String password = requiredConfig("mail.password");
        String configuredFrom = ConfigUtil.get("mail.from");
        String fromAddress = configuredFrom == null || configuredFrom.isBlank()
                ? username
                : configuredFrom.trim();

        Properties properties = new Properties();
        properties.setProperty("mail.smtp.host", "smtp.gmail.com");
        properties.setProperty("mail.smtp.port", "587");
        properties.setProperty("mail.smtp.auth", "true");
        properties.setProperty("mail.smtp.starttls.enable", "true");
        properties.setProperty("mail.smtp.starttls.required", "true");
        properties.setProperty("mail.smtp.connectiontimeout", "10000");
        properties.setProperty("mail.smtp.timeout", "10000");
        properties.setProperty("mail.smtp.writetimeout", "10000");

        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            MimeMessage mail = new MimeMessage(session);
            mail.setFrom(new InternetAddress(fromAddress, "TechStore", "UTF-8"));
            mail.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to, false));
            mail.setSubject(subject, "UTF-8");
            mail.setContent(htmlContent, "text/html; charset=UTF-8");
            Transport.send(mail);
        } catch (Exception ex) {
            throw new IllegalStateException("Không thể gửi email. Vui lòng kiểm tra cấu hình mail.", ex);
        }
    }

    private static String requiredConfig(String key) {
        String value = ConfigUtil.get(key);
        if (value == null || value.isBlank()) {
            throw new IllegalStateException("Thiếu cấu hình " + key + ".");
        }
        return value.trim();
    }

    private static String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
