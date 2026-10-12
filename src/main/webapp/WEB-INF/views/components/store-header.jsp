<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request" />
<c:set var="favoriteHeaderUrl" value="${ctx}/login" />
<c:set var="cartHeaderUrl" value="${ctx}/login" />
<c:if test="${not empty sessionScope.user}">
    <c:set var="favoriteHeaderUrl" value="${ctx}/favorites" />
    <c:set var="cartHeaderUrl" value="${ctx}/cart" />
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:out value="${empty pageTitle ? 'TechStore' : pageTitle}" /></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/main.css">
</head>
<body>
<a class="skip-link" href="#mainContent">Bỏ qua điều hướng</a>
<header class="site-header store-header">
    <div class="container store-header-main">
        <button class="store-menu-toggle" type="button" data-store-menu-toggle
                aria-controls="storeNavigation" aria-expanded="false" aria-label="Mở menu">
            <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M4 7h16M4 12h16M4 17h16" /></svg>
        </button>
        <a class="brand" href="${ctx}/home" aria-label="TechStore - Trang chủ"><span>Tech</span>Store</a>

        <form class="store-search store-search-desktop" action="${ctx}/products" method="get" role="search">
            <label class="sr-only" for="headerSearch">Tìm kiếm sản phẩm</label>
            <input id="headerSearch" name="q" type="search" maxlength="150"
                   value="<c:out value='${param.q}'/>" placeholder="Tìm điện thoại, laptop, phụ kiện...">
            <button type="submit" aria-label="Tìm kiếm">
                <svg aria-hidden="true" viewBox="0 0 24 24"><circle cx="11" cy="11" r="7" /><path d="m20 20-4-4" /></svg>
            </button>
        </form>

        <div class="store-quick-actions">
            <a class="store-action ${storePath == '/favorites' ? 'active' : ''}"
               href="${favoriteHeaderUrl}"
               aria-label="Sản phẩm yêu thích">
                <span class="store-action-icon"><svg aria-hidden="true" viewBox="0 0 24 24"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8l1.1 1.1L12 21l7.8-7.5 1.1-1.1a5.5 5.5 0 0 0-.1-7.8Z" /></svg><c:if test="${favoriteCount > 0}"><span class="store-count">${favoriteCount > 99 ? '99+' : favoriteCount}</span></c:if></span>
                <span class="store-action-label">Yêu thích</span>
            </a>
            <a class="store-action ${storePath == '/cart' ? 'active' : ''}"
               href="${cartHeaderUrl}"
               aria-label="Giỏ hàng">
                <span class="store-action-icon"><svg aria-hidden="true" viewBox="0 0 24 24"><path d="M3 4h2l2.2 10.2a2 2 0 0 0 2 1.6h7.9a2 2 0 0 0 2-1.6L20.5 8H6" /><circle cx="10" cy="20" r="1" /><circle cx="18" cy="20" r="1" /></svg><c:if test="${cartItemCount > 0}"><span class="store-count">${cartItemCount > 99 ? '99+' : cartItemCount}</span></c:if></span>
                <span class="store-action-label">Giỏ hàng</span>
            </a>

            <c:choose>
                <c:when test="${empty sessionScope.user}">
                    <a class="store-action store-login" href="${ctx}/login">
                        <span class="store-action-icon"><svg aria-hidden="true" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4" /><path d="M4 21a8 8 0 0 1 16 0" /></svg></span>
                        <span class="store-action-label">Đăng nhập</span>
                    </a>
                    <a class="btn btn-primary store-register" href="${ctx}/register">Đăng ký</a>
                </c:when>
                <c:otherwise>
                    <details class="store-account-menu">
                        <summary aria-label="Mở menu tài khoản">
                            <span class="store-action-icon"><svg aria-hidden="true" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4" /><path d="M4 21a8 8 0 0 1 16 0" /></svg></span>
                            <span class="store-user-copy"><small>Tài khoản</small><strong><c:out value="${sessionScope.user.fullName}" /></strong></span>
                            <span class="account-chevron" aria-hidden="true">⌄</span>
                        </summary>
                        <div class="store-account-dropdown">
                            <a href="${ctx}/account/profile">Hồ sơ cá nhân</a>
                            <a href="${ctx}/account/addresses">Địa chỉ nhận hàng</a>
                            <a href="${ctx}/orders">Đơn hàng của tôi</a>
                            <c:if test="${sessionScope.user.role == 'ADMIN'}"><a href="${ctx}/admin">Trang quản trị</a></c:if>
                            <form action="${ctx}/logout" method="post">
                                <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                <button type="submit">Đăng xuất</button>
                            </form>
                        </div>
                    </details>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="store-nav-bar">
        <nav class="container store-navigation" id="storeNavigation" aria-label="Danh mục và điều hướng cửa hàng">
            <div class="store-mobile-nav-head">
                <strong>Danh mục sản phẩm</strong>
                <button type="button" data-store-menu-close aria-label="Đóng menu">×</button>
            </div>
            <form class="store-search store-search-mobile" action="${ctx}/products" method="get" role="search">
                <label class="sr-only" for="mobileHeaderSearch">Tìm kiếm sản phẩm</label>
                <input id="mobileHeaderSearch" name="q" type="search" maxlength="150"
                       value="<c:out value='${param.q}'/>" placeholder="Tìm sản phẩm...">
                <button type="submit" aria-label="Tìm kiếm">
                    <svg aria-hidden="true" viewBox="0 0 24 24"><circle cx="11" cy="11" r="7" /><path d="m20 20-4-4" /></svg>
                </button>
            </form>
            <a class="${storePath == '/home' ? 'active' : ''}" href="${ctx}/home">Trang chủ</a>
            <a class="${(storePath == '/products' || storePath == '/product') && empty param.categoryId ? 'active' : ''}" href="${ctx}/products">Tất cả sản phẩm</a>
            <c:forEach var="headerCategory" items="${headerCategories}">
                <c:url var="headerCategoryUrl" value="/products"><c:param name="categoryId" value="${headerCategory.categoryId}" /></c:url>
                <a class="${param.categoryId == headerCategory.categoryId ? 'active' : ''}" href="${headerCategoryUrl}"><c:out value="${headerCategory.name}" /></a>
            </c:forEach>
            <c:if test="${empty sessionScope.user}"><div class="store-mobile-auth"><a class="btn btn-ghost" href="${ctx}/login">Đăng nhập</a><a class="btn btn-primary" href="${ctx}/register">Đăng ký</a></div></c:if>
            <c:if test="${not empty sessionScope.user}"><a class="store-nav-orders ${fn:startsWith(storePath, '/orders') ? 'active' : ''}" href="${ctx}/orders">Tra cứu đơn hàng</a></c:if>
            <c:if test="${sessionScope.user.role == 'ADMIN'}"><a class="store-nav-admin" href="${ctx}/admin">Quản trị</a></c:if>
        </nav>
    </div>
    <button class="store-menu-overlay" type="button" data-store-menu-close aria-label="Đóng menu"></button>
</header>
<main class="page-shell" id="mainContent" tabindex="-1">
    <div class="container">
        <c:if test="${not empty sessionScope.flashSuccess}">
            <div class="alert alert-success" role="status"><c:out value="${sessionScope.flashSuccess}" /></div>
            <c:remove var="flashSuccess" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.flashError}">
            <div class="alert alert-error" role="alert"><c:out value="${sessionScope.flashError}" /></div>
            <c:remove var="flashError" scope="session" />
        </c:if>
        <c:if test="${not empty pageError}">
            <div class="alert alert-error" role="alert"><c:out value="${pageError}" /></div>
        </c:if>
