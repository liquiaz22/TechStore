<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:out value="${empty pageTitle ? 'TechStore' : pageTitle}" /></title>
    <link rel="stylesheet" href="${ctx}/assets/css/main.css">
</head>
<body>
<header class="site-header">
    <div class="container nav-wrap">
        <a class="brand" href="${ctx}/home"><span>Tech</span>Store</a>
        <nav class="main-nav" aria-label="Điều hướng chính">
            <a href="${ctx}/home">Sản phẩm</a>
            <c:if test="${not empty sessionScope.user}">
                <a href="${ctx}/favorites">Yêu thích</a>
                <a href="${ctx}/cart">Giỏ hàng</a>
                <a href="${ctx}/orders">Đơn hàng</a>
            </c:if>
            <c:if test="${sessionScope.user.role == 'ADMIN'}">
                <a href="${ctx}/admin">Quản trị</a>
            </c:if>
        </nav>
        <div class="nav-account">
            <c:choose>
                <c:when test="${empty sessionScope.user}">
                    <a class="btn btn-ghost" href="${ctx}/login">Đăng nhập</a>
                    <a class="btn btn-primary" href="${ctx}/register">Đăng ký</a>
                </c:when>
                <c:otherwise>
                    <span class="user-name"><c:out value="${sessionScope.user.fullName}" /></span>
                    <form action="${ctx}/logout" method="post" class="inline-form">
                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                        <button class="btn btn-ghost" type="submit">Đăng xuất</button>
                    </form>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>
<main class="page-shell">
    <div class="container">
        <c:if test="${not empty sessionScope.flashSuccess}">
            <div class="alert alert-success"><c:out value="${sessionScope.flashSuccess}" /></div>
            <c:remove var="flashSuccess" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.flashError}">
            <div class="alert alert-error"><c:out value="${sessionScope.flashError}" /></div>
            <c:remove var="flashError" scope="session" />
        </c:if>
        <c:if test="${not empty pageError}">
            <div class="alert alert-error"><c:out value="${pageError}" /></div>
        </c:if>
