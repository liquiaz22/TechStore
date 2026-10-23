package com.shop.selenium;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.Duration;

import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.edge.EdgeOptions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.ITestResult;
import org.testng.annotations.AfterClass;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeClass;

abstract class SeleniumTestBase {
    protected WebDriver driver;
    protected WebDriverWait wait;
    protected String baseUrl;

    @BeforeClass(alwaysRun = true)
    public void setUpBrowser() {
        baseUrl = readSetting("baseUrl", "TECHSTORE_BASE_URL",
                "http://localhost:8080/TechStore");
        baseUrl = baseUrl.replaceAll("/+$", "");

        String browser = readSetting("browser", "TECHSTORE_TEST_BROWSER", "chrome")
                .trim().toLowerCase();
        boolean headless = Boolean.parseBoolean(
                readSetting("headless", "TECHSTORE_TEST_HEADLESS", "true"));

        driver = switch (browser) {
            case "edge" -> new EdgeDriver(edgeOptions(headless));
            case "chrome" -> new ChromeDriver(chromeOptions(headless));
            default -> throw new IllegalArgumentException(
                    "Trình duyệt không được hỗ trợ: " + browser + ". Chỉ dùng chrome hoặc edge.");
        };
        driver.manage().window().setSize(new org.openqa.selenium.Dimension(1440, 1000));
        driver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(30));
        driver.manage().timeouts().implicitlyWait(Duration.ofMillis(250));
        wait = new WebDriverWait(driver, Duration.ofSeconds(15));
    }

    @AfterMethod(alwaysRun = true)
    public void captureFailure(ITestResult result) throws IOException {
        if (!result.isSuccess() && driver instanceof TakesScreenshot screenshotDriver) {
            Path outputDirectory = Path.of("target", "selenium-screenshots");
            Files.createDirectories(outputDirectory);
            File screenshot = screenshotDriver.getScreenshotAs(OutputType.FILE);
            String safeName = result.getName().replaceAll("[^a-zA-Z0-9._-]", "_");
            Files.copy(screenshot.toPath(), outputDirectory.resolve(safeName + ".png"),
                    StandardCopyOption.REPLACE_EXISTING);
        }
    }

    @AfterClass(alwaysRun = true)
    public void closeBrowser() {
        if (driver != null) {
            driver.quit();
        }
    }

    protected void open(String path) {
        driver.get(baseUrl + (path.startsWith("/") ? path : "/" + path));
    }

    private ChromeOptions chromeOptions(boolean headless) {
        ChromeOptions options = new ChromeOptions();
        if (headless) {
            options.addArguments("--headless=new");
        }
        options.addArguments("--disable-gpu", "--no-sandbox", "--disable-dev-shm-usage",
                "--window-size=1440,1000", "--lang=vi-VN");
        return options;
    }

    private EdgeOptions edgeOptions(boolean headless) {
        EdgeOptions options = new EdgeOptions();
        if (headless) {
            options.addArguments("--headless=new");
        }
        options.addArguments("--disable-gpu", "--no-sandbox", "--disable-dev-shm-usage",
                "--window-size=1440,1000", "--lang=vi-VN");
        return options;
    }

    private String readSetting(String systemProperty, String environmentVariable,
            String defaultValue) {
        String value = System.getProperty(systemProperty);
        if (value == null || value.isBlank()) {
            value = System.getenv(environmentVariable);
        }
        return value == null || value.isBlank() ? defaultValue : value;
    }
}
