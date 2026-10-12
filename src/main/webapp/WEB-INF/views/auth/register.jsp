<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Đăng ký" scope="request" />
<jsp:include page="../components/store-header.jsp" />
<section class="auth-shell">
    <div class="panel auth-card">
        <p class="eyebrow">Tạo tài khoản</p>
        <h1>Tham gia TechStore</h1>
        <form action="${ctx}/register" method="post">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <div class="field"><label for="fullName">Họ và tên</label><input id="fullName" name="fullName" maxlength="150" value="<c:out value='${param.fullName}'/>" required></div>
            <div class="field"><label for="email">Email</label><input id="email" name="email" type="email" maxlength="320" value="<c:out value='${param.email}'/>" required></div>
            <div class="field"><label for="phone">Số điện thoại</label><input id="phone" name="phone" type="tel" inputmode="tel" maxlength="20" pattern="[0-9+ .()\-]{10,20}" value="<c:out value='${param.phone}'/>"></div>
            <div class="field"><label for="password">Mật khẩu</label><input id="password" name="password" type="password" minlength="8" maxlength="72" required></div>
            <div class="field"><label for="confirmPassword">Xác nhận mật khẩu</label><input id="confirmPassword" name="confirmPassword" type="password" minlength="8" maxlength="72" required></div>
            <button class="btn btn-primary btn-block" type="submit">Tạo tài khoản</button>
        </form>
        <p class="auth-footer">Đã có tài khoản? <a href="${ctx}/login">Đăng nhập</a></p>
    </div>
</section>
<jsp:include page="../components/store-footer.jsp" />
