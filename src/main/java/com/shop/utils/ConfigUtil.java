package com.shop.utils;

import java.io.InputStream;
import java.util.Properties;

public class ConfigUtil {
	
    private static final Properties properties = new Properties();

    static {
        try (InputStream input = Thread.currentThread().getContextClassLoader()
                .getResourceAsStream("META-INF/config.properties")) {
            
            if (input == null) {
                System.out.println("Không tìm thấy file config.properties!");
            } else {
                properties.load(input);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String get(String key) {
        String environmentKey = "TECHSTORE_" + key.toUpperCase().replace('.', '_');
        String environmentValue = System.getenv(environmentKey);
        if (environmentValue != null && !environmentValue.isBlank()) {
            return environmentValue;
        }

        String configuredValue = properties.getProperty(key);
        if (configuredValue != null && configuredValue.startsWith("TECHSTORE_")) {
            String referencedValue = System.getenv(configuredValue);
            return referencedValue == null ? "" : referencedValue;
        }
        return configuredValue;
    }
}
