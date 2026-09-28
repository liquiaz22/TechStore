package com.shop.utils;

import java.util.Properties;

import com.shop.entity.User;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;


public class XMail {
    static String path = ConfigUtil.get("app.url");
    
    static final String USERNAME = ConfigUtil.get("mail.username");
    static final String PASSWORD = ConfigUtil.get("mail.password");
	
	static public void sendWelcome(User user) {
		var to = user.getEmail();
		var subject = "Chào mừng bạn đến với TechStore";
		var body = path + "/home/index/";
		XMail.send(to, subject, body);
	}
	
	static public void sendPasswordResetLink(User user, String resetUrl) {
		var to = user.getEmail();
		var subject = "Dat lai mat khau TechStore";
		var body = "Nhan vao lien ket sau de dat lai mat khau: " + resetUrl;
		XMail.send(to, subject, body);
	}
	
	
	static public void send(String to, String subject, String content) {
		var from = "FPT Polytechnic <183anhka@gmail.com>";
		send(from, to, subject, content);
	}
	
	static public void send(String from, String to, String subject, String content) {
		var props = new Properties();
		props.setProperty("mail.smtp.host", "smtp.gmail.com");
		props.setProperty("mail.smtp.port", "587");
		props.setProperty("mail.smtp.auth", "true");
		props.setProperty("mail.smtp.starttls.enable", "true");
		var session = Session.getInstance(props, new Authenticator() {
			@Override
			protected PasswordAuthentication getPasswordAuthentication() {
				return new PasswordAuthentication(USERNAME, PASSWORD);
			}
		});

		try {
			var mail = new MimeMessage(session);
			mail.setFrom(new InternetAddress(from));
			mail.setRecipients(Message.RecipientType.TO, to);
			mail.setSubject(subject, "utf8");
			mail.setContent(content, "text/html; charset=utf8");
			mail.setReplyTo(mail.getFrom());
			
			Transport.send(mail);
			System.out.println("Mail was sent to " + to);
		} catch (MessagingException e) {
			e.printStackTrace();
		}
	}
}
