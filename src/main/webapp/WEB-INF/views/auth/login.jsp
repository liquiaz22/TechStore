<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Đăng nhập" scope="request" />
<jsp:include page="../components/store-header.jsp" />
<section class="auth-shell">
    <div class="panel auth-card">
        <p class="eyebrow">Chào mừng trở lại</p>
        <h1>Đăng nhập TechStore</h1>
        <p class="muted">Theo dõi đơn hàng, giỏ hàng và sản phẩm yêu thích.</p>
        <form action="${ctx}/login" method="post">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <div class="field"><label for="email">Email</label><input id="email" name="email" type="email" maxlength="320" value="<c:out value='${email}'/>" required autofocus></div>
            <div class="field"><label for="password">Mật khẩu</label><input id="password" name="password" type="password" minlength="8" maxlength="72" required></div>
            <div class="form-helper"><a href="${ctx}/forgot-password">Quên mật khẩu?</a></div>
            <button class="btn btn-primary btn-block" type="submit">Đăng nhập</button>
        </form>
        <p class="auth-footer">Chưa có tài khoản? <a href="${ctx}/register">Đăng ký ngay</a></p>
    </div>
</section>
<jsp:include page="../components/store-footer.jsp" />
