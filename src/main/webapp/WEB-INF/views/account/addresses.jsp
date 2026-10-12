<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Địa chỉ nhận hàng" scope="request" />
<jsp:include page="../components/store-header.jsp" />

<div class="section-head">
    <div><p class="eyebrow">Tài khoản</p><h1>Địa chỉ nhận hàng</h1></div>
    <a class="btn btn-secondary" href="${ctx}/account/profile">Về hồ sơ</a>
</div>

<div class="account-grid account-grid-address">
    <section class="panel">
        <h2><c:out value="${empty editingAddress.addressId ? 'Thêm địa chỉ' : 'Cập nhật địa chỉ'}" /></h2>
        <form action="${ctx}/account/addresses" method="post" class="stack-form">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="save">
            <input type="hidden" name="addressId" value="<c:out value='${editingAddress.addressId}'/>">
            <div class="form-grid">
                <div class="field"><label for="receiverName">Người nhận</label><input id="receiverName" name="receiverName" maxlength="150" value="<c:out value='${editingAddress.receiverName}'/>" required></div>
                <div class="field"><label for="receiverPhone">Số điện thoại</label><input id="receiverPhone" name="receiverPhone" type="tel" inputmode="tel" maxlength="20" pattern="[0-9+ .()\-]{10,20}" value="<c:out value='${editingAddress.receiverPhone}'/>" required></div>
                <div class="field"><label for="province">Tỉnh/thành</label><input id="province" name="province" maxlength="100" value="<c:out value='${editingAddress.province}'/>" required></div>
                <div class="field"><label for="district">Quận/huyện</label><input id="district" name="district" maxlength="100" value="<c:out value='${editingAddress.district}'/>" required></div>
                <div class="field"><label for="ward">Phường/xã</label><input id="ward" name="ward" maxlength="100" value="<c:out value='${editingAddress.ward}'/>" required></div>
                <div class="field"><label for="addressLine">Địa chỉ cụ thể</label><input id="addressLine" name="addressLine" maxlength="255" value="<c:out value='${editingAddress.addressLine}'/>" required></div>
            </div>
            <label class="check-row"><input type="checkbox" name="defaultAddress" value="true" ${editingAddress.defaultAddress ? 'checked' : ''}> Dùng làm địa chỉ mặc định</label>
            <div class="form-actions">
                <button class="btn btn-primary" type="submit"><c:out value="${empty editingAddress.addressId ? 'Thêm địa chỉ' : 'Lưu thay đổi'}" /></button>
                <c:if test="${not empty editingAddress.addressId}"><a class="btn btn-ghost" href="${ctx}/account/addresses">Hủy sửa</a></c:if>
            </div>
        </form>
    </section>

    <section class="panel">
        <h2>Địa chỉ đã lưu</h2>
        <c:choose>
            <c:when test="${empty addresses}">
                <div class="empty-inline"><p class="muted">Bạn chưa lưu địa chỉ nhận hàng nào.</p></div>
            </c:when>
            <c:otherwise>
                <div class="saved-addresses">
                    <c:forEach var="address" items="${addresses}">
                        <article class="saved-address">
                            <div>
                                <div class="address-title"><strong><c:out value="${address.receiverName}" /></strong><c:if test="${address.defaultAddress}"><span class="badge badge-success">Mặc định</span></c:if></div>
                                <div><c:out value="${address.receiverPhone}" /></div>
                                <div class="muted"><c:out value="${address.toShippingAddress()}" /></div>
                            </div>
                            <div class="table-actions">
                                <a class="btn btn-secondary btn-small" href="${ctx}/account/addresses?edit=${address.addressId}">Sửa</a>
                                <c:if test="${not address.defaultAddress}">
                                    <form action="${ctx}/account/addresses" method="post">
                                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="default">
                                        <input type="hidden" name="addressId" value="${address.addressId}">
                                        <button class="btn btn-ghost btn-small" type="submit">Đặt mặc định</button>
                                    </form>
                                </c:if>
                                <form action="${ctx}/account/addresses" method="post" onsubmit="return confirm('Xóa địa chỉ này?')">
                                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="addressId" value="${address.addressId}">
                                    <button class="btn btn-danger btn-small" type="submit">Xóa</button>
                                </form>
                            </div>
                        </article>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</div>

<jsp:include page="../components/store-footer.jsp" />
