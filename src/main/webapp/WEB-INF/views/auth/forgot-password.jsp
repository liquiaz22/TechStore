<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quên mật khẩu" scope="request" />
<jsp:include page="../components/store-header.jsp" />
<section class="auth-shell">
    <div class="panel auth-card">
        <p class="eyebrow">Khôi phục tài khoản</p>
        <h1>Quên mật khẩu</h1>
        <p class="muted">Nhập email đăng ký. Liên kết đặt lại mật khẩu có hiệu lực trong 30 phút.</p>
        <c:if test="${requestAccepted}"><div class="alert alert-success"><c:out value="${pageMessage}" /></div></c:if>
        <form action="${ctx}/forgot-password" method="post">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <div class="field"><label for="email">Email</label><input id="email" name="email" type="email" maxlength="320" value="<c:out value='${param.email}'/>" required autofocus></div>
            <button class="btn btn-primary btn-block" type="submit">Gửi liên kết đặt lại</button>
        </form>
        <p class="auth-footer"><a href="${ctx}/login">Quay lại đăng nhập</a></p>
    </div>
</section>
<jsp:include page="../components/store-footer.jsp" />
