<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Đặt hàng" scope="request" />
<jsp:include page="components/store-header.jsp" />

<nav class="checkout-progress" aria-label="Tiến trình đặt hàng">
    <a class="checkout-step completed" href="${ctx}/cart"><span>✓</span><strong>Giỏ hàng</strong></a>
    <div class="checkout-progress-line completed"></div>
    <div class="checkout-step active" aria-current="step"><span>2</span><strong>Giao hàng</strong></div>
    <div class="checkout-progress-line"></div>
    <div class="checkout-step"><span>3</span><strong>Thanh toán</strong></div>
    <div class="checkout-progress-line"></div>
    <div class="checkout-step"><span>4</span><strong>Hoàn tất</strong></div>
</nav>

<div class="section-head checkout-heading"><div><p class="eyebrow">Thông tin đặt hàng</p><h1>Giao hàng và thanh toán</h1><p class="muted">Kiểm tra kỹ thông tin trước khi xác nhận đơn.</p></div></div>

<form action="${ctx}/checkout" method="post" class="checkout-grid checkout-form" data-checkout-form>
    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
    <input type="hidden" name="checkoutToken" value="${sessionScope.checkoutToken}">
    <div class="checkout-main-stack">
        <section class="panel checkout-section">
            <div class="checkout-section-head"><span>1</span><div><h2>Địa chỉ nhận hàng</h2><p>Chọn địa chỉ đã lưu hoặc nhập địa chỉ mới.</p></div></div>

            <c:if test="${not empty addresses}">
                <h3 class="checkout-subtitle">Địa chỉ đã lưu</h3>
                <div class="address-list saved-checkout-addresses">
                    <c:forEach var="address" items="${addresses}">
                        <label class="address-option ${selectedAddressId == address.addressId ? 'selected' : ''}">
                            <input data-address-select type="radio" name="addressId" value="${address.addressId}" ${selectedAddressId == address.addressId ? 'checked' : ''}>
                            <span class="address-radio-mark" aria-hidden="true"></span>
                            <span class="address-option-copy"><strong><c:out value="${address.receiverName}" /></strong><span><c:out value="${address.receiverPhone}" /></span><small><c:out value="${address.toShippingAddress()}" /></small></span>
                            <c:if test="${address.defaultAddress}"><span class="badge badge-success">Mặc định</span></c:if>
                        </label>
                    </c:forEach>
                </div>
            </c:if>

            <label class="address-option new-address-option ${empty selectedAddressId ? 'selected' : ''}">
                <input data-address-select type="radio" name="addressId" value="" ${empty selectedAddressId ? 'checked' : ''}>
                <span class="address-radio-mark" aria-hidden="true"></span>
                <span class="address-option-copy"><strong>Nhập địa chỉ giao hàng mới</strong><small>Thông tin này chỉ dùng cho đơn hàng hiện tại.</small></span>
            </label>
            <c:if test="${not empty fieldErrors.addressId}"><small class="field-error"><c:out value="${fieldErrors.addressId}" /></small></c:if>

            <div class="manual-address" data-manual-address ${not empty selectedAddressId ? 'hidden' : ''}>
                <h3 class="checkout-subtitle">Thông tin người nhận <span>* Bắt buộc</span></h3>
                <div class="form-grid">
                    <div class="field ${not empty fieldErrors.receiverName ? 'field-invalid' : ''}"><label for="receiverName">Người nhận <span class="required-mark">*</span></label><input id="receiverName" name="receiverName" maxlength="150" autocomplete="name" value="<c:out value='${param.receiverName}'/>" data-required-message="Vui lòng nhập tên người nhận." ${empty selectedAddressId ? 'required' : ''}><small class="field-error" data-field-error="receiverName"><c:out value="${fieldErrors.receiverName}" /></small></div>
                    <div class="field ${not empty fieldErrors.receiverPhone ? 'field-invalid' : ''}"><label for="receiverPhone">Số điện thoại <span class="required-mark">*</span></label><input id="receiverPhone" name="receiverPhone" type="tel" inputmode="tel" maxlength="20" autocomplete="tel" pattern="[0-9+ .()\-]{10,20}" value="<c:out value='${param.receiverPhone}'/>" data-required-message="Vui lòng nhập số điện thoại." data-pattern-message="Số điện thoại phải có từ 10 đến 20 ký tự hợp lệ." ${empty selectedAddressId ? 'required' : ''}><small class="field-error" data-field-error="receiverPhone"><c:out value="${fieldErrors.receiverPhone}" /></small></div>
                    <div class="field ${not empty fieldErrors.province ? 'field-invalid' : ''}"><label for="province">Tỉnh/thành <span class="required-mark">*</span></label><input id="province" name="province" maxlength="100" autocomplete="address-level1" value="<c:out value='${param.province}'/>" data-required-message="Vui lòng nhập tỉnh hoặc thành phố." ${empty selectedAddressId ? 'required' : ''}><small class="field-error" data-field-error="province"><c:out value="${fieldErrors.province}" /></small></div>
                    <div class="field ${not empty fieldErrors.district ? 'field-invalid' : ''}"><label for="district">Quận/huyện <span class="required-mark">*</span></label><input id="district" name="district" maxlength="100" autocomplete="address-level2" value="<c:out value='${param.district}'/>" data-required-message="Vui lòng nhập quận hoặc huyện." ${empty selectedAddressId ? 'required' : ''}><small class="field-error" data-field-error="district"><c:out value="${fieldErrors.district}" /></small></div>
                    <div class="field ${not empty fieldErrors.ward ? 'field-invalid' : ''}"><label for="ward">Phường/xã <span class="required-mark">*</span></label><input id="ward" name="ward" maxlength="100" autocomplete="address-level3" value="<c:out value='${param.ward}'/>" data-required-message="Vui lòng nhập phường hoặc xã." ${empty selectedAddressId ? 'required' : ''}><small class="field-error" data-field-error="ward"><c:out value="${fieldErrors.ward}" /></small></div>
                    <div class="field ${not empty fieldErrors.addressLine ? 'field-invalid' : ''}"><label for="addressLine">Địa chỉ cụ thể <span class="required-mark">*</span></label><input id="addressLine" name="addressLine" maxlength="255" autocomplete="street-address" value="<c:out value='${param.addressLine}'/>" placeholder="Số nhà, tên đường..." data-required-message="Vui lòng nhập địa chỉ cụ thể." ${empty selectedAddressId ? 'required' : ''}><small class="field-error" data-field-error="addressLine"><c:out value="${fieldErrors.addressLine}" /></small></div>
                </div>
            </div>
        </section>

        <section class="panel checkout-section">
            <div class="checkout-section-head"><span>2</span><div><h2>Phương thức thanh toán</h2><p>Chọn cách thanh toán phù hợp với bạn.</p></div></div>
            <div class="payment-options">
                <label class="payment-option ${param.paymentMethod != 'VNPAY' || not vnpayAvailable ? 'selected' : ''}">
                    <input type="radio" name="paymentMethod" value="COD" ${param.paymentMethod != 'VNPAY' || not vnpayAvailable ? 'checked' : ''} required>
                    <span class="payment-option-icon" aria-hidden="true">₫</span>
                    <span><strong>Thanh toán khi nhận hàng</strong><small>Thanh toán tiền mặt cho nhân viên giao hàng.</small></span>
                </label>
                <label class="payment-option ${param.paymentMethod == 'VNPAY' && vnpayAvailable ? 'selected' : ''} ${not vnpayAvailable ? 'payment-option-disabled' : ''}">
                    <input type="radio" name="paymentMethod" value="VNPAY"
                           ${param.paymentMethod == 'VNPAY' && vnpayAvailable ? 'checked' : ''}
                           ${not vnpayAvailable ? 'disabled' : ''} required>
                    <span class="payment-option-icon vnpay-icon" aria-hidden="true">V</span>
                    <span><strong>Thanh toán trực tuyến qua VNPay</strong><small>${vnpayAvailable ? 'Hỗ trợ QR, thẻ ATM nội địa và tài khoản ngân hàng.' : 'Tạm thời chưa khả dụng do thiếu cấu hình Sandbox.'}</small></span>
                </label>
            </div>
            <c:if test="${not empty fieldErrors.paymentMethod}"><small class="field-error"><c:out value="${fieldErrors.paymentMethod}" /></small></c:if>
            <c:choose>
                <c:when test="${not vnpayAvailable}">
                    <div class="vnpay-checkout-notice vnpay-unavailable-notice" role="status">
                        <strong>VNPay tạm thời chưa khả dụng</strong>
                        <span>Cửa hàng chưa thiết lập thông tin VNPay Sandbox. Bạn vẫn có thể đặt hàng bằng COD.</span>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="vnpay-checkout-notice" data-vnpay-notice ${param.paymentMethod == 'VNPAY' ? '' : 'hidden'}><strong>Chuẩn bị chuyển sang VNPay</strong><span>Sau khi tạo đơn, bạn sẽ được chuyển đến cổng VNPay để hoàn tất thanh toán.</span></div>
                </c:otherwise>
            </c:choose>
            <div class="field checkout-note-field"><label for="customerNote">Ghi chú đơn hàng <span class="optional-label">Không bắt buộc</span></label><textarea id="customerNote" name="customerNote" maxlength="500" placeholder="Ví dụ: giao hàng trong giờ hành chính"><c:out value="${param.customerNote}" /></textarea><small class="muted">Tối đa 500 ký tự.</small></div>
        </section>
    </div>

    <aside class="panel checkout-summary">
        <h2>Đơn hàng của bạn</h2>
        <div class="checkout-summary-items">
            <c:forEach var="item" items="${cartItems}">
                <c:url var="checkoutProductUrl" value="/product"><c:param name="slug" value="${item.variant.product.slug}" /></c:url>
                <c:set var="checkoutImageUrl" value="${checkoutItemImageUrls[item.variant.variantId]}" />
                <article class="checkout-summary-item">
                    <a href="${checkoutProductUrl}"><c:choose><c:when test="${fn:startsWith(checkoutImageUrl, 'http')}"><img src="${checkoutImageUrl}" alt="<c:out value='${item.variant.product.name}'/>"></c:when><c:otherwise><img src="${ctx}/${checkoutImageUrl}" alt="<c:out value='${item.variant.product.name}'/>"></c:otherwise></c:choose><span class="checkout-item-quantity">${item.quantity}</span></a>
                    <div><a href="${checkoutProductUrl}"><strong><c:out value="${item.variant.product.name}" /></strong></a><small><c:out value="${item.variant.variantName}" /> · SL: ${item.quantity}</small></div>
                    <strong class="checkout-item-price"><fmt:formatNumber value="${item.variant.price * item.quantity}" pattern="#,##0" /> ₫</strong>
                </article>
            </c:forEach>
        </div>
        <div class="checkout-totals">
            <div class="summary-line"><span>Tạm tính</span><strong><fmt:formatNumber value="${subtotal}" pattern="#,##0" /> ₫</strong></div>
            <div class="summary-line"><span>Phí vận chuyển</span><span class="free-shipping">Miễn phí</span></div>
            <div class="summary-line summary-total"><strong>Tổng thanh toán</strong><strong class="price"><fmt:formatNumber value="${subtotal}" pattern="#,##0" /> ₫</strong></div>
        </div>
        <button class="btn btn-primary btn-block checkout-submit" type="submit" data-checkout-submit>${param.paymentMethod == 'VNPAY' && vnpayAvailable ? 'Thanh toán qua VNPay' : 'Đặt hàng COD'}</button>
        <p class="checkout-submit-note">Bằng việc đặt hàng, bạn xác nhận thông tin giao nhận ở trên là chính xác.</p>
    </aside>
</form>
<jsp:include page="components/store-footer.jsp" />
