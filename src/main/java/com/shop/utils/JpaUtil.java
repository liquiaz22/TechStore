package com.shop.utils;

import java.util.HashMap;
import java.util.Map;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

public class JpaUtil {
	private static volatile EntityManagerFactory factory;

	private static EntityManagerFactory getFactory() {
		EntityManagerFactory current = factory;
		if (current != null && current.isOpen()) {
			return current;
		}

		synchronized (JpaUtil.class) {
			current = factory;
			if (current == null || !current.isOpen()) {
				String url = requireConfig("db.url");
				String username = requireConfig("db.username");
				String password = requireConfig("db.password");

				Map<String, String> properties = new HashMap<>();
				properties.put("jakarta.persistence.jdbc.url", url);
				properties.put("jakarta.persistence.jdbc.user", username);
				properties.put("jakarta.persistence.jdbc.password", password);

				try {
					current = Persistence.createEntityManagerFactory("TechStore", properties);
					factory = current;
				} catch (RuntimeException ex) {
					throw new IllegalStateException(
							"Khong the khoi tao ket noi database. Kiem tra bien moi truong TECHSTORE_DB_*.", ex);
				}
			}
			return current;
		}
	}

	private static String requireConfig(String key) {
		String value = ConfigUtil.get(key);
		if (value == null || value.isBlank()) {
			throw new IllegalStateException("Thieu cau hinh " + key
					+ ". Hay khai bao bien moi truong TECHSTORE_" + key.toUpperCase().replace('.', '_') + ".");
		}
		return value;
	}
	
	public static EntityManager getEntityManager() {
		return getFactory().createEntityManager();

	}
	
	public static void close() {
		EntityManagerFactory current = factory;
		if (current != null && current.isOpen()) {
			current.close();
		}
		factory = null;
    }
}
