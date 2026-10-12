<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Kết quả thanh toán VNPay" scope="request" />
<jsp:include page="../components/store-header.jsp" />
<nav class="checkout-progress payment-progress" aria-label="Tiến trình đặt hàng">
    <div class="checkout-step completed"><span>✓</span><strong>Giỏ hàng</strong></div>
    <div class="checkout-progress-line completed"></div>
    <div class="checkout-step completed"><span>✓</span><strong>Giao hàng</strong></div>
    <div class="checkout-progress-line completed"></div>
    <div class="checkout-step ${paymentResult.transactionSuccessful ? 'completed' : 'active'}"><span>${paymentResult.transactionSuccessful ? '✓' : '3'}</span><strong>Thanh toán</strong></div>
    <div class="checkout-progress-line ${paymentResult.transactionSuccessful ? 'completed' : ''}"></div>
    <div class="checkout-step ${paymentResult.transactionSuccessful ? 'completed' : ''}"><span>${paymentResult.transactionSuccessful ? '✓' : '4'}</span><strong>Hoàn tất</strong></div>
</nav>
<section class="panel empty-state payment-result-card">
    <div class="payment-result-icon ${paymentResult.transactionSuccessful ? 'payment-result-success' : 'payment-result-failed'}">${paymentResult.transactionSuccessful ? '✓' : '!'}</div>
    <p class="eyebrow">VNPay</p>
    <h1>${paymentResult.transactionSuccessful ? 'Thanh toán thành công' : 'Thanh toán chưa thành công'}</h1>
    <p class="muted"><c:out value="${paymentResult.displayMessage}" /></p>
    <dl class="payment-result-details">
        <c:if test="${not empty paymentResult.orderCode}"><div><dt>Mã đơn hàng</dt><dd><c:out value="${paymentResult.orderCode}" /></dd></div></c:if>
        <div><dt>Mã phản hồi VNPay</dt><dd><c:out value="${paymentResult.responseCode}" /></dd></div>
        <div><dt>Trạng thái</dt><dd>${paymentResult.transactionSuccessful ? 'Đã thanh toán' : 'Chưa thanh toán'}</dd></div>
    </dl>
    <c:if test="${!paymentResult.transactionSuccessful}"><p class="payment-result-hint">Bạn có thể mở chi tiết đơn hàng để thử thanh toán lại hoặc chọn phương thức khác.</p></c:if>
    <div class="form-actions payment-result-actions">
        <c:choose>
            <c:when test="${not empty paymentResult.orderCode && not empty sessionScope.user}"><a class="btn btn-primary" href="${ctx}/orders/detail?code=${paymentResult.orderCode}">Xem đơn hàng</a></c:when>
            <c:when test="${not empty sessionScope.user}"><a class="btn btn-primary" href="${ctx}/orders">Lịch sử đơn hàng</a></c:when>
            <c:otherwise><a class="btn btn-primary" href="${ctx}/login">Đăng nhập</a></c:otherwise>
        </c:choose>
        <a class="btn btn-ghost" href="${ctx}/home">Về trang chủ</a>
    </div>
</section>
<jsp:include page="../components/store-footer.jsp" />
