package com.shop.selenium;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.testng.Assert;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

public class TechStoreSeleniumTest extends SeleniumTestBase {

    @BeforeMethod(alwaysRun = true)
    public void resetGuestSession() {
        driver.manage().deleteAllCookies();
    }

    @Test(priority = 1, description = "Trang chủ hiển thị header, ô tìm kiếm và nội dung chính")
    public void homePageDisplaysMainStorefrontElements() {
        open("/home");

        wait.until(ExpectedConditions.urlContains("/home"));
        WebElement mainHeading = wait.until(
                ExpectedConditions.visibilityOfElementLocated(By.cssSelector("main h1")));

        Assert.assertTrue(driver.getTitle().contains("TechStore"),
                "Tiêu đề trình duyệt phải chứa TechStore.");
        Assert.assertFalse(mainHeading.getText().isBlank(),
                "Trang chủ phải có heading chính.");
        Assert.assertTrue(driver.findElement(By.id("headerSearch")).isDisplayed(),
                "Ô tìm kiếm trên header phải hiển thị ở desktop.");
        Assert.assertTrue(driver.findElement(By.cssSelector("a[href$='/products']")).isDisplayed(),
                "Phải có liên kết đến catalog sản phẩm.");
    }

    @Test(priority = 2, description = "Tìm kiếm từ header chuyển đến catalog và giữ từ khóa")
    public void headerSearchOpensCatalogWithKeyword() {
        open("/home");
        WebElement search = wait.until(
                ExpectedConditions.elementToBeClickable(By.id("headerSearch")));
        search.clear();
        search.sendKeys("iPhone", Keys.ENTER);

        wait.until(ExpectedConditions.urlContains("/products"));
        wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("catalogResultTitle")));

        Assert.assertEquals(driver.findElement(By.id("q")).getDomProperty("value"), "iPhone",
                "Catalog phải giữ lại từ khóa đã tìm.");
        Assert.assertEquals(queryParameter(driver.getCurrentUrl(), "q"), "iPhone",
                "URL catalog phải chứa query q=iPhone.");
    }

    @Test(priority = 3, description = "Đăng ký với mật khẩu xác nhận không khớp bị từ chối")
    public void registrationRejectsMismatchedPasswordConfirmation() {
        open("/register");
        wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("fullName")))
                .sendKeys("Selenium Demo");
        driver.findElement(By.id("email")).sendKeys("selenium.demo@example.com");
        driver.findElement(By.id("password")).sendKeys("Password123!");
        driver.findElement(By.id("confirmPassword")).sendKeys("Password456!");
        driver.findElement(By.cssSelector(".auth-card button[type='submit']")).click();

        WebElement error = wait.until(ExpectedConditions.visibilityOfElementLocated(
                By.cssSelector(".alert.alert-error[role='alert']")));
        Assert.assertTrue(error.getText().toLowerCase().contains("không khớp"),
                "Hệ thống phải báo mật khẩu xác nhận không khớp.");
        Assert.assertTrue(driver.getCurrentUrl().contains("/register"),
                "Dữ liệu không hợp lệ phải ở lại trang đăng ký.");
    }

    @Test(priority = 4, description = "Khách chưa đăng nhập bị chuyển về trang đăng nhập khi mở giỏ hàng")
    public void cartRequiresAuthenticationForGuest() {
        open("/cart");

        wait.until(ExpectedConditions.urlContains("/login"));
        Assert.assertTrue(driver.findElement(By.cssSelector(".auth-card form[action$='/login']"))
                        .isDisplayed(),
                "Khách mở giỏ hàng phải được chuyển đến form đăng nhập.");
    }

    @Test(priority = 5, description = "Khách chưa đăng nhập không được truy cập khu vực quản trị")
    public void adminAreaRequiresAuthenticationForGuest() {
        open("/admin");

        wait.until(ExpectedConditions.urlContains("/login"));
        Assert.assertTrue(driver.findElement(By.cssSelector(".auth-card form[action$='/login']"))
                        .isDisplayed(),
                "Khách mở trang quản trị phải được chuyển đến form đăng nhập.");
    }

    private String queryParameter(String url, String expectedName) {
        String query = URI.create(url).getRawQuery();
        if (query == null) {
            return null;
        }
        for (String pair : query.split("&")) {
            String[] parts = pair.split("=", 2);
            if (URLDecoder.decode(parts[0], StandardCharsets.UTF_8).equals(expectedName)) {
                return parts.length == 2
                        ? URLDecoder.decode(parts[1], StandardCharsets.UTF_8)
                        : "";
            }
        }
        return null;
    }
}
