<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Chi tiết đơn hàng" scope="request" />
<c:set var="orderStatusLabel" value="${statusLabels[order.status]}" />
<c:set var="orderPaymentStatusLabel" value="${paymentStatusLabels[order.paymentStatus]}" />
<jsp:include page="../components/admin-header.jsp" />

<nav class="admin-breadcrumb" aria-label="Đường dẫn">
    <a href="${backToOrdersUrl}">Quản lý đơn hàng</a><span aria-hidden="true">/</span><span><c:out value="${order.orderCode}" /></span>
</nav>
<header class="section-head admin-page-head admin-order-detail-head">
    <div><p class="eyebrow">Chi tiết đơn hàng</p><h1><c:out value="${order.orderCode}" /></h1><p class="muted">Đặt lúc <c:out value="${orderCreatedAtDisplay}" /> bởi <c:out value="${order.user.fullName}" /></p></div>
    <div class="admin-head-actions"><span class="badge status-badge-large ${statusClasses[order.status]}"><c:out value="${empty orderStatusLabel ? order.status : orderStatusLabel}" /></span><a class="btn btn-ghost" href="${backToOrdersUrl}">← Quay lại danh sách</a></div>
</header>

<section class="admin-order-overview" aria-label="Tóm tắt đơn hàng">
    <article><span aria-hidden="true">₫</span><div><small>Tổng thanh toán</small><strong><fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /> ₫</strong></div></article>
    <article><span aria-hidden="true">✓</span><div><small>Thanh toán</small><strong><c:out value="${empty orderPaymentStatusLabel ? order.paymentStatus : orderPaymentStatusLabel}" /></strong></div></article>
    <article><span aria-hidden="true">▣</span><div><small>Số sản phẩm</small><strong>${fn:length(orderItems)}</strong></div></article>
    <article><span aria-hidden="true">◎</span><div><small>Khách hàng</small><strong><c:out value="${order.user.email}" /></strong></div></article>
</section>

<div class="admin-order-detail-layout">
    <div class="admin-order-detail-main">
        <section class="panel">
            <div class="admin-panel-heading"><div><p class="eyebrow">Sản phẩm</p><h2>Sản phẩm trong đơn</h2></div><span>${fn:length(orderItems)} dòng</span></div>
            <div class="admin-order-items">
                <c:forEach var="item" items="${orderItems}">
                    <c:set var="itemImage" value="${empty item.imageUrl ? 'assets/images/product-placeholder.svg' : item.imageUrl}" />
                    <c:set var="itemImageSrc" value="${ctx}/${itemImage}" />
                    <c:if test="${fn:startsWith(itemImage, 'http')}"><c:set var="itemImageSrc" value="${itemImage}" /></c:if>
                    <article>
                        <img src="${itemImageSrc}" alt="<c:out value='${item.productName}'/>">
                        <div><strong><c:out value="${item.productName}" /></strong><span><c:out value="${item.variantName}" /></span><small>SKU: <c:out value="${item.sku}" /></small></div>
                        <span class="admin-item-quantity">× ${item.quantity}</span>
                        <div class="admin-item-price"><small><fmt:formatNumber value="${item.unitPrice}" pattern="#,##0" /> ₫/sp</small><strong><fmt:formatNumber value="${item.lineTotal}" pattern="#,##0" /> ₫</strong></div>
                    </article>
                </c:forEach>
            </div>
            <dl class="admin-order-totals">
                <div><dt>Tạm tính</dt><dd><fmt:formatNumber value="${order.subtotal}" pattern="#,##0" /> ₫</dd></div>
                <div><dt>Phí giao hàng</dt><dd><fmt:formatNumber value="${order.shippingFee}" pattern="#,##0" /> ₫</dd></div>
                <c:if test="${order.discountAmount > 0}"><div><dt>Giảm giá</dt><dd>− <fmt:formatNumber value="${order.discountAmount}" pattern="#,##0" /> ₫</dd></div></c:if>
                <div class="total"><dt>Tổng thanh toán</dt><dd><fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /> ₫</dd></div>
            </dl>
        </section>

        <section class="panel">
            <div class="admin-panel-heading"><div><p class="eyebrow">Giao dịch</p><h2>Lịch sử thanh toán</h2></div><span class="badge ${paymentStatusClasses[order.paymentStatus]}"><c:out value="${empty orderPaymentStatusLabel ? order.paymentStatus : orderPaymentStatusLabel}" /></span></div>
            <c:choose>
                <c:when test="${empty payments}"><div class="admin-inline-empty">Chưa có giao dịch thanh toán.</div></c:when>
                <c:otherwise><div class="admin-payment-list">
                    <c:forEach var="payment" items="${payments}">
                        <c:set var="paymentMethodLabel" value="${paymentMethodLabels[payment.paymentMethod]}" />
                        <c:set var="paymentStatusLabel" value="${paymentStatusLabels[payment.paymentStatus]}" />
                        <article>
                            <div class="admin-payment-head"><strong><c:out value="${empty paymentMethodLabel ? payment.paymentMethod : paymentMethodLabel}" /></strong><span class="badge ${paymentStatusClasses[payment.paymentStatus]}"><c:out value="${empty paymentStatusLabel ? payment.paymentStatus : paymentStatusLabel}" /></span></div>
                            <dl><div><dt>Số tiền</dt><dd><fmt:formatNumber value="${payment.amount}" pattern="#,##0" /> ₫</dd></div><div><dt>Khởi tạo</dt><dd><c:out value="${paymentCreatedAtDisplays[payment.paymentId]}" /></dd></div><c:if test="${not empty payment.paidAt}"><div><dt>Hoàn tất</dt><dd><c:out value="${paymentPaidAtDisplays[payment.paymentId]}" /></dd></div></c:if><c:if test="${not empty payment.providerTransactionId}"><div><dt>Mã giao dịch</dt><dd><c:out value="${payment.providerTransactionId}" /></dd></div></c:if><c:if test="${not empty payment.providerResponseCode}"><div><dt>Mã phản hồi</dt><dd><c:out value="${payment.providerResponseCode}" /></dd></div></c:if></dl>
                        </article>
                    </c:forEach>
                </div></c:otherwise>
            </c:choose>
        </section>

        <section class="panel">
            <div class="admin-panel-heading"><div><p class="eyebrow">Nhật ký</p><h2>Lịch sử xử lý</h2></div></div>
            <ol class="admin-order-timeline">
                <c:forEach var="history" items="${histories}">
                    <c:set var="historyStatusLabel" value="${statusLabels[history.status]}" />
                    <li class="${history.status == 'CANCELLED' ? 'cancelled' : ''}"><span aria-hidden="true">${history.status == 'CANCELLED' ? '×' : '✓'}</span><div><div><strong><c:out value="${empty historyStatusLabel ? history.status : historyStatusLabel}" /></strong><time><c:out value="${historyCreatedAtDisplays[history.historyId]}" /></time></div><c:if test="${not empty historyNoteDisplays[history.historyId]}"><p><c:out value="${historyNoteDisplays[history.historyId]}" /></p></c:if><c:if test="${not empty history.changedBy}"><small>Cập nhật bởi <c:out value="${history.changedBy.fullName}" /></small></c:if></div></li>
                </c:forEach>
            </ol>
        </section>
    </div>

    <aside class="admin-order-detail-sidebar">
        <section class="panel admin-status-update">
            <div class="admin-panel-heading"><div><p class="eyebrow">Xử lý đơn</p><h2>Cập nhật trạng thái</h2></div></div>
            <div class="admin-current-status"><span>Trạng thái hiện tại</span><strong class="badge ${statusClasses[order.status]}"><c:out value="${empty orderStatusLabel ? order.status : orderStatusLabel}" /></strong></div>
            <c:choose>
                <c:when test="${empty allowedNextStatuses}"><div class="admin-terminal-status"><span aria-hidden="true">✓</span><p>Đơn hàng đã ở trạng thái cuối và không thể chuyển tiếp.</p></div></c:when>
                <c:otherwise>
                    <form action="${ctx}/admin/orders/status" method="post" class="stack-form" data-admin-order-status-form>
                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="orderId" value="${order.orderId}">
                        <input type="hidden" name="orderCode" value="${order.orderCode}">
                        <input type="hidden" name="q" value="<c:out value='${param.q}'/>">
                        <input type="hidden" name="filterStatus" value="<c:out value='${param.filterStatus}'/>">
                        <input type="hidden" name="from" value="<c:out value='${param.from}'/>">
                        <input type="hidden" name="to" value="<c:out value='${param.to}'/>">
                        <input type="hidden" name="page" value="<c:out value='${param.page}'/>">
                        <div class="field"><label for="newOrderStatus">Chuyển sang trạng thái</label><select id="newOrderStatus" name="status" data-admin-order-status required><c:forEach var="nextStatus" items="${allowedNextStatuses}"><option value="${nextStatus}"><c:out value="${statusLabels[nextStatus]}" /></option></c:forEach></select></div>
                        <div class="field"><label for="statusNote">Ghi chú xử lý <span class="optional-label" data-admin-note-optional>Không bắt buộc</span></label><textarea id="statusNote" name="note" maxlength="500" data-admin-order-note placeholder="Thông tin dành cho lịch sử đơn hàng"></textarea><small class="muted" data-admin-status-help>Ghi chú sẽ hiển thị trong lịch sử xử lý.</small></div>
                        <div class="admin-danger-explanation" data-admin-cancel-warning hidden><strong>Hủy đơn sẽ hoàn lại tồn kho</strong><span>Thao tác này không thể hoàn tác trực tiếp. Lý do hủy là bắt buộc.</span></div>
                        <button class="btn btn-primary btn-block" type="submit" data-admin-status-submit>Cập nhật trạng thái</button>
                    </form>
                </c:otherwise>
            </c:choose>
        </section>

        <section class="panel">
            <div class="admin-panel-heading"><div><p class="eyebrow">Khách hàng</p><h2>Thông tin giao hàng</h2></div></div>
            <dl class="admin-description-list"><div><dt>Họ tên</dt><dd><c:out value="${order.user.fullName}" /></dd></div><div><dt>Email</dt><dd><c:out value="${order.user.email}" /></dd></div><div><dt>Người nhận</dt><dd><c:out value="${order.receiverName}" /></dd></div><div><dt>Điện thoại</dt><dd><c:out value="${order.receiverPhone}" /></dd></div><div><dt>Địa chỉ</dt><dd><c:out value="${order.shippingAddress}" /></dd></div><c:if test="${not empty order.customerNote}"><div><dt>Ghi chú</dt><dd><c:out value="${order.customerNote}" /></dd></div></c:if></dl>
        </section>
    </aside>
</div>

<jsp:include page="../components/admin-footer.jsp" />
