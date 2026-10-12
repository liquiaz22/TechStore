<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request" />
<c:set var="forwardedAdminPath" value="${requestScope['jakarta.servlet.forward.servlet_path']}" />
<c:set var="adminPath" value="${empty forwardedAdminPath ? pageContext.request.servletPath : forwardedAdminPath}" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:out value="${empty pageTitle ? 'Quản trị TechStore' : pageTitle}" /> — TechStore Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/main.css">
    <link rel="stylesheet" href="${ctx}/assets/css/admin.css">
</head>
<body class="admin-body">
<a class="skip-link" href="#mainContent">Bỏ qua điều hướng quản trị</a>
<div class="admin-shell">
    <aside class="admin-sidebar" id="adminSidebar" aria-label="Điều hướng quản trị">
        <div class="admin-brand-row">
            <a class="admin-brand" href="${ctx}/admin"><span>Tech</span>Store <small>Admin</small></a>
            <button class="admin-sidebar-close" type="button" data-admin-menu-close aria-label="Đóng menu">×</button>
        </div>
        <nav class="admin-side-nav">
            <a class="${adminPath == '/admin' ? 'active' : ''}" href="${ctx}/admin">
                <span class="admin-nav-icon" aria-hidden="true">▦</span><span>Báo cáo</span>
            </a>
            <a class="${fn:startsWith(adminPath, '/admin/catalog') ? 'active' : ''}" href="${ctx}/admin/catalog">
                <span class="admin-nav-icon" aria-hidden="true">◫</span><span>Danh mục &amp; hãng</span>
            </a>
            <a class="${fn:startsWith(adminPath, '/admin/products') ? 'active' : ''}" href="${ctx}/admin/products">
                <span class="admin-nav-icon" aria-hidden="true">◇</span><span>Sản phẩm</span>
            </a>
            <a class="${fn:startsWith(adminPath, '/admin/orders') ? 'active' : ''}" href="${ctx}/admin/orders">
                <span class="admin-nav-icon" aria-hidden="true">▤</span><span>Đơn hàng</span>
            </a>
            <a class="${fn:startsWith(adminPath, '/admin/users') ? 'active' : ''}" href="${ctx}/admin/users">
                <span class="admin-nav-icon" aria-hidden="true">◎</span><span>Người dùng</span>
            </a>
        </nav>
        <a class="admin-store-link" href="${ctx}/home"><span aria-hidden="true">←</span> Xem cửa hàng</a>
    </aside>

    <button class="admin-sidebar-overlay" type="button" data-admin-menu-close aria-label="Đóng menu"></button>

    <div class="admin-workspace">
        <header class="admin-topbar">
            <div class="admin-topbar-title">
                <button class="admin-menu-toggle" type="button" data-admin-menu-toggle
                        aria-controls="adminSidebar" aria-expanded="false" aria-label="Mở menu quản trị">☰</button>
                <div><span>Khu vực quản trị</span><strong><c:out value="${empty pageTitle ? 'TechStore' : pageTitle}" /></strong></div>
            </div>
            <div class="admin-account">
                <div class="admin-account-copy"><strong><c:out value="${sessionScope.user.fullName}" /></strong><span>Quản trị viên</span></div>
                <form action="${ctx}/logout" method="post">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                    <button class="btn btn-ghost btn-small" type="submit">Đăng xuất</button>
                </form>
            </div>
        </header>
        <main class="admin-content" id="mainContent" tabindex="-1">
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
