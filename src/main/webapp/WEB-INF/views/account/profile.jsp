<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Tài khoản của tôi" scope="request" />
<jsp:include page="../components/store-header.jsp" />

<div class="section-head">
    <div><p class="eyebrow">Tài khoản</p><h1>Hồ sơ của tôi</h1></div>
    <a class="btn btn-secondary" href="${ctx}/account/addresses">Quản lý địa chỉ</a>
</div>

<div class="account-grid">
    <section class="panel">
        <h2>Thông tin cá nhân</h2>
        <p class="muted">Cập nhật thông tin dùng khi liên hệ và nhận đơn hàng.</p>
        <form action="${ctx}/account/profile" method="post" class="stack-form">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <div class="field">
                <label for="email">Email</label>
                <input id="email" type="email" value="<c:out value='${profile.email}'/>" disabled>
                <small class="muted">Email đăng nhập hiện chưa hỗ trợ thay đổi.</small>
            </div>
            <div class="field">
                <label for="fullName">Họ và tên</label>
                <input id="fullName" name="fullName" maxlength="150"
                       value="<c:out value='${empty param.fullName ? profile.fullName : param.fullName}'/>" required>
            </div>
            <div class="field">
                <label for="phone">Số điện thoại</label>
                <input id="phone" name="phone" type="tel" inputmode="tel" maxlength="20"
                       pattern="[0-9+ .()\-]{10,20}"
                       value="<c:out value='${empty param.phone ? profile.phone : param.phone}'/>">
            </div>
            <button class="btn btn-primary" type="submit">Lưu hồ sơ</button>
        </form>
    </section>

    <section class="panel">
        <h2>Đổi mật khẩu</h2>
        <p class="muted">Mật khẩu mới phải dài từ 8 đến 72 ký tự.</p>
        <form action="${ctx}/account/password" method="post" class="stack-form">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <div class="field"><label for="currentPassword">Mật khẩu hiện tại</label><input id="currentPassword" name="currentPassword" type="password" maxlength="72" required autocomplete="current-password"></div>
            <div class="field"><label for="newPassword">Mật khẩu mới</label><input id="newPassword" name="newPassword" type="password" minlength="8" maxlength="72" required autocomplete="new-password"></div>
            <div class="field"><label for="confirmPassword">Xác nhận mật khẩu mới</label><input id="confirmPassword" name="confirmPassword" type="password" minlength="8" maxlength="72" required autocomplete="new-password"></div>
            <button class="btn btn-primary" type="submit">Đổi mật khẩu</button>
        </form>
    </section>
</div>

<jsp:include page="../components/store-footer.jsp" />
