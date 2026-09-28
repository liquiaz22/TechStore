<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Đặt hàng" scope="request" />
<jsp:include page="components/header.jsp" />
<div class="section-head"><div><p class="eyebrow">Bước cuối</p><h1>Thông tin đặt hàng</h1></div></div>
<form action="${ctx}/checkout" method="post" class="checkout-grid">
    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
    <div class="panel">
        <h2>Địa chỉ nhận hàng</h2>
        <div class="address-list">
            <c:forEach var="address" items="${addresses}" varStatus="loop"><label class="address-option"><input data-address-select type="radio" name="addressId" value="${address.addressId}" ${address.defaultAddress || loop.first ? 'checked' : ''}><span><strong><c:out value="${address.receiverName}" /></strong> · <c:out value="${address.receiverPhone}" /><br><span class="muted"><c:out value="${address.toShippingAddress()}" /></span></span></label></c:forEach>
            <label class="address-option"><input data-address-select type="radio" name="addressId" value="" ${empty addresses ? 'checked' : ''}><span><strong>Nhập địa chỉ khác</strong></span></label>
        </div>
        <div data-manual-address ${not empty addresses ? 'hidden' : ''}>
            <div class="form-grid">
                <div class="field"><label>Người nhận</label><input name="receiverName" maxlength="150" value="<c:out value='${param.receiverName}'/>"></div>
                <div class="field"><label>Số điện thoại</label><input name="receiverPhone" type="tel" inputmode="tel" maxlength="20" pattern="[0-9+ .()\-]{10,20}" value="<c:out value='${param.receiverPhone}'/>"></div>
                <div class="field"><label>Tỉnh/thành</label><input name="province" maxlength="100" value="<c:out value='${param.province}'/>"></div>
                <div class="field"><label>Quận/huyện</label><input name="district" maxlength="100" value="<c:out value='${param.district}'/>"></div>
                <div class="field"><label>Phường/xã</label><input name="ward" maxlength="100" value="<c:out value='${param.ward}'/>"></div>
                <div class="field"><label>Địa chỉ cụ thể</label><input name="addressLine" maxlength="255" value="<c:out value='${param.addressLine}'/>"></div>
            </div>
        </div>
        <div class="field subsection"><label for="customerNote">Ghi chú</label><textarea id="customerNote" name="customerNote" maxlength="500"><c:out value="${param.customerNote}" /></textarea></div>
        <div class="field"><label for="paymentMethod">Phương thức thanh toán</label><select id="paymentMethod" name="paymentMethod"><option value="COD">Thanh toán khi nhận hàng (COD)</option></select></div>
    </div>
    <aside class="panel sticky"><h2>Đơn hàng</h2><c:forEach var="item" items="${cartItems}"><div class="summary-line"><span><c:out value="${item.variant.product.name}" /> × ${item.quantity}</span><strong><fmt:formatNumber value="${item.variant.price * item.quantity}" pattern="#,##0" /> ₫</strong></div></c:forEach><div class="summary-line summary-total"><strong>Tổng thanh toán</strong><strong class="price"><fmt:formatNumber value="${subtotal}" pattern="#,##0" /> ₫</strong></div><button class="btn btn-primary btn-block" type="submit">Xác nhận đặt hàng</button></aside>
</form>
<jsp:include page="components/footer.jsp" />
