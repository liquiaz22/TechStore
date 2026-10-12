<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Đặt lại mật khẩu" scope="request" />
<jsp:include page="../components/store-header.jsp" />
<section class="auth-shell">
    <div class="panel auth-card">
        <p class="eyebrow">Khôi phục tài khoản</p>
        <h1>Đặt mật khẩu mới</h1>
        <p class="muted">Mật khẩu mới phải dài từ 8 đến 72 ký tự.</p>
        <c:choose>
            <c:when test="${empty token}">
                <div class="alert alert-error">Liên kết đặt lại mật khẩu không hợp lệ.</div>
                <a class="btn btn-primary btn-block" href="${ctx}/forgot-password">Yêu cầu liên kết mới</a>
            </c:when>
            <c:otherwise>
                <form action="${ctx}/reset-password" method="post">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="token" value="<c:out value='${token}'/>">
                    <div class="field"><label for="newPassword">Mật khẩu mới</label><input id="newPassword" name="newPassword" type="password" minlength="8" maxlength="72" required autocomplete="new-password" autofocus></div>
                    <div class="field"><label for="confirmPassword">Xác nhận mật khẩu mới</label><input id="confirmPassword" name="confirmPassword" type="password" minlength="8" maxlength="72" required autocomplete="new-password"></div>
                    <button class="btn btn-primary btn-block" type="submit">Đặt lại mật khẩu</button>
                </form>
            </c:otherwise>
        </c:choose>
        <p class="auth-footer"><a href="${ctx}/login">Quay lại đăng nhập</a></p>
    </div>
</section>
<jsp:include page="../components/store-footer.jsp" />
