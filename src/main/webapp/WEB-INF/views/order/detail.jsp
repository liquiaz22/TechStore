<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Chi tiết đơn hàng" scope="request" />
<c:set var="orderStatusLabel" value="${orderStatusLabels[order.status]}" />
<c:set var="paymentStatusLabel" value="${paymentStatusLabels[order.paymentStatus]}" />
<jsp:include page="../components/store-header.jsp" />

<nav class="order-breadcrumb" aria-label="Đường dẫn">
    <a href="${ctx}/orders">Đơn hàng của tôi</a>
    <span aria-hidden="true">/</span>
    <span><c:out value="${order.orderCode}" /></span>
</nav>

<header class="section-head order-detail-head">
    <div>
        <p class="eyebrow">Chi tiết đơn hàng</p>
        <h1><c:out value="${order.orderCode}" /></h1>
        <p class="muted">Đặt lúc <c:out value="${orderCreatedAtDisplay}" /></p>
    </div>
    <span class="badge status-badge status-badge-large ${orderStatusClasses[order.status]}">
        <span class="status-badge-icon" aria-hidden="true"><c:out value="${orderStatusIcons[order.status]}" /></span>
        <c:out value="${empty orderStatusLabel ? order.status : orderStatusLabel}" />
    </span>
</header>

<c:choose>
    <c:when test="${order.status == 'CANCELLED'}">
        <section class="order-cancelled-notice" role="status">
            <span class="order-notice-icon" aria-hidden="true">×</span>
            <div>
                <strong>Đơn hàng đã được hủy</strong>
                <c:choose>
                    <c:when test="${not empty cancellationHistory}">
                        <p><c:out value="${historyNoteDisplays[cancellationHistory.historyId]}" /></p>
                        <small>Ghi nhận lúc <c:out value="${historyCreatedAtDisplays[cancellationHistory.historyId]}" /></small>
                    </c:when>
                    <c:otherwise><p>Đơn hàng này không còn tiếp tục được xử lý.</p></c:otherwise>
                </c:choose>
            </div>
        </section>
    </c:when>
    <c:otherwise>
        <section class="panel order-progress-panel" aria-label="Tiến trình đơn hàng">
            <h2>Tiến trình đơn hàng</h2>
            <ol class="order-progress">
                <li class="${orderProgressStep >= 1 ? 'completed' : ''} ${orderProgressStep == 1 ? 'active' : ''}">
                    <span aria-hidden="true">${orderProgressStep > 1 ? '✓' : '1'}</span><strong>Đặt hàng</strong><small>Đã tiếp nhận</small>
                </li>
                <li class="${orderProgressStep >= 2 ? 'completed' : ''} ${orderProgressStep == 2 ? 'active' : ''}">
                    <span aria-hidden="true">${orderProgressStep > 2 ? '✓' : '2'}</span><strong>Xác nhận</strong><small>Kiểm tra đơn</small>
                </li>
                <li class="${orderProgressStep >= 3 ? 'completed' : ''} ${orderProgressStep == 3 ? 'active' : ''}">
                    <span aria-hidden="true">${orderProgressStep > 3 ? '✓' : '3'}</span><strong>Chuẩn bị</strong><small>Đóng gói hàng</small>
                </li>
                <li class="${orderProgressStep >= 4 ? 'completed' : ''} ${orderProgressStep == 4 ? 'active' : ''}">
                    <span aria-hidden="true">${orderProgressStep > 4 ? '✓' : '4'}</span><strong>Đang giao</strong><small>Trên đường đến bạn</small>
                </li>
                <li class="${orderProgressStep >= 5 ? 'completed active' : ''}">
                    <span aria-hidden="true">${orderProgressStep >= 5 ? '✓' : '5'}</span><strong>Hoàn thành</strong><small>Đã nhận hàng</small>
                </li>
            </ol>
        </section>
    </c:otherwise>
</c:choose>

<div class="order-detail-layout">
    <div class="order-detail-main">
        <section class="panel order-products-panel">
            <div class="order-panel-head">
                <div><p class="eyebrow">Sản phẩm</p><h2>Sản phẩm đã đặt</h2></div>
                <span>${fn:length(orderItems)} sản phẩm</span>
            </div>
            <div class="order-product-list">
                <c:forEach var="item" items="${orderItems}">
                    <c:set var="orderItemImage" value="${empty item.imageUrl ? 'assets/images/product-placeholder.svg' : item.imageUrl}" />
                    <c:set var="orderItemImageSrc" value="${ctx}/${orderItemImage}" />
                    <c:if test="${fn:startsWith(orderItemImage, 'http')}"><c:set var="orderItemImageSrc" value="${orderItemImage}" /></c:if>
                    <article class="order-product-item">
                        <img src="${orderItemImageSrc}" alt="<c:out value='${item.productName}'/>">
                        <div class="order-product-copy">
                            <strong><c:out value="${item.productName}" /></strong>
                            <span><c:out value="${item.variantName}" /></span>
                            <small>SKU: <c:out value="${item.sku}" /></small>
                        </div>
                        <div class="order-product-quantity"><span>Số lượng</span><strong>× ${item.quantity}</strong></div>
                        <div class="order-product-price">
                            <span><fmt:formatNumber value="${item.unitPrice}" pattern="#,##0" /> ₫ / sản phẩm</span>
                            <strong><fmt:formatNumber value="${item.lineTotal}" pattern="#,##0" /> ₫</strong>
                        </div>
                    </article>
                </c:forEach>
            </div>
            <dl class="order-totals">
                <div><dt>Tạm tính</dt><dd><fmt:formatNumber value="${order.subtotal}" pattern="#,##0" /> ₫</dd></div>
                <div><dt>Phí giao hàng</dt><dd><fmt:formatNumber value="${order.shippingFee}" pattern="#,##0" /> ₫</dd></div>
                <c:if test="${order.discountAmount > 0}"><div><dt>Giảm giá</dt><dd class="status-ok">− <fmt:formatNumber value="${order.discountAmount}" pattern="#,##0" /> ₫</dd></div></c:if>
                <div class="order-total-final"><dt>Tổng thanh toán</dt><dd><fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /> ₫</dd></div>
            </dl>
        </section>

        <section class="panel order-history-panel">
            <div class="order-panel-head">
                <div><p class="eyebrow">Cập nhật</p><h2>Lịch sử xử lý</h2></div>
            </div>
            <ol class="order-status-timeline">
                <c:forEach var="history" items="${histories}">
                    <c:set var="historyStatusLabel" value="${orderStatusLabels[history.status]}" />
                    <li class="${history.status == 'CANCELLED' ? 'cancelled' : ''}">
                        <span class="timeline-marker" aria-hidden="true"><c:out value="${orderStatusIcons[history.status]}" /></span>
                        <div class="timeline-content">
                            <div>
                                <strong><c:out value="${empty historyStatusLabel ? history.status : historyStatusLabel}" /></strong>
                                <time><c:out value="${historyCreatedAtDisplays[history.historyId]}" /></time>
                            </div>
                            <c:if test="${not empty historyNoteDisplays[history.historyId]}">
                                <p><c:out value="${historyNoteDisplays[history.historyId]}" /></p>
                            </c:if>
                            <c:if test="${not empty history.changedBy}">
                                <small>Cập nhật bởi <c:out value="${history.changedBy.fullName}" /></small>
                            </c:if>
                        </div>
                    </li>
                </c:forEach>
            </ol>
        </section>
    </div>

    <aside class="order-detail-sidebar">
        <section class="panel order-info-panel">
            <div class="order-panel-head"><div><p class="eyebrow">Nhận hàng</p><h2>Thông tin giao hàng</h2></div></div>
            <dl class="order-info-list">
                <div><dt>Người nhận</dt><dd><c:out value="${order.receiverName}" /></dd></div>
                <div><dt>Điện thoại</dt><dd><c:out value="${order.receiverPhone}" /></dd></div>
                <div><dt>Địa chỉ</dt><dd><c:out value="${order.shippingAddress}" /></dd></div>
                <c:if test="${not empty order.customerNote}"><div><dt>Ghi chú</dt><dd><c:out value="${order.customerNote}" /></dd></div></c:if>
            </dl>

            <c:if test="${canCancelOrder}">
                <details class="cancel-order-box">
                    <summary>Yêu cầu hủy đơn hàng</summary>
                    <form action="${ctx}/orders/cancel" method="post" class="stack-form">
                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="orderId" value="${order.orderId}">
                        <div class="field">
                            <label for="cancelReason">Lý do hủy đơn <span class="required-mark">*</span></label>
                            <textarea id="cancelReason" name="reason" maxlength="500" required
                                      placeholder="Cho cửa hàng biết lý do bạn muốn hủy..."></textarea>
                        </div>
                        <button class="btn btn-danger btn-block" type="submit"
                                data-confirm="Bạn chắc chắn muốn hủy đơn hàng này?">Xác nhận hủy đơn</button>
                    </form>
                </details>
            </c:if>
            <c:if test="${not empty cancelUnavailableReason}">
                <p class="cancel-unavailable-note"><span aria-hidden="true">!</span><c:out value="${cancelUnavailableReason}" /></p>
            </c:if>
        </section>

        <section class="panel order-payment-panel">
            <div class="order-panel-head"><div><p class="eyebrow">Giao dịch</p><h2>Thanh toán</h2></div></div>
            <div class="order-payment-summary">
                <span>Trạng thái thanh toán</span>
                <span class="badge status-badge ${paymentStatusClasses[order.paymentStatus]}">
                    <span class="status-badge-icon" aria-hidden="true"><c:out value="${paymentStatusIcons[order.paymentStatus]}" /></span>
                    <c:out value="${empty paymentStatusLabel ? order.paymentStatus : paymentStatusLabel}" />
                </span>
            </div>
            <c:choose>
                <c:when test="${empty payments}"><p class="muted">Chưa có giao dịch thanh toán cho đơn hàng này.</p></c:when>
                <c:otherwise>
                    <div class="payment-history order-payment-history">
                        <c:forEach var="payment" items="${payments}">
                            <c:set var="transactionStatusLabel" value="${paymentStatusLabels[payment.paymentStatus]}" />
                            <c:set var="paymentMethodLabel" value="${paymentMethodLabels[payment.paymentMethod]}" />
                            <article class="payment-entry">
                                <div class="payment-entry-head">
                                    <strong><c:out value="${empty paymentMethodLabel ? payment.paymentMethod : paymentMethodLabel}" /></strong>
                                    <span class="badge status-badge ${paymentStatusClasses[payment.paymentStatus]}">
                                        <span class="status-badge-icon" aria-hidden="true"><c:out value="${paymentStatusIcons[payment.paymentStatus]}" /></span>
                                        <c:out value="${empty transactionStatusLabel ? payment.paymentStatus : transactionStatusLabel}" />
                                    </span>
                                </div>
                                <dl>
                                    <div><dt>Số tiền</dt><dd><fmt:formatNumber value="${payment.amount}" pattern="#,##0" /> ₫</dd></div>
                                    <div><dt>Tạo lúc</dt><dd><c:out value="${paymentCreatedAtDisplays[payment.paymentId]}" /></dd></div>
                                    <c:if test="${not empty payment.paidAt}"><div><dt>Thanh toán lúc</dt><dd><c:out value="${paymentPaidAtDisplays[payment.paymentId]}" /></dd></div></c:if>
                                    <c:if test="${not empty payment.providerTransactionId}"><div><dt>Mã giao dịch</dt><dd class="transaction-code"><c:out value="${payment.providerTransactionId}" /></dd></div></c:if>
                                    <c:if test="${not empty payment.bankCode}"><div><dt>Ngân hàng</dt><dd><c:out value="${payment.bankCode}" /></dd></div></c:if>
                                </dl>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
            <c:if test="${not empty latestPayment && latestPayment.paymentMethod == 'VNPAY' && not vnpayAvailable && order.paymentStatus != 'PAID' && order.status != 'CANCELLED' && order.status != 'COMPLETED'}">
                <p class="cancel-unavailable-note"><span aria-hidden="true">!</span>Kênh VNPay tạm thời chưa sẵn sàng. Vui lòng thử lại sau hoặc liên hệ cửa hàng.</p>
            </c:if>
            <c:if test="${not empty latestPayment && latestPayment.paymentMethod == 'VNPAY' && vnpayAvailable && order.paymentStatus != 'PAID' && order.status != 'CANCELLED' && order.status != 'COMPLETED' && sessionScope.user.role != 'ADMIN'}">
                <form action="${ctx}/payment/vnpay/start" method="post" class="order-retry-payment">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="orderCode" value="${order.orderCode}">
                    <button class="btn btn-primary btn-block" type="submit">Thanh toán lại qua VNPay</button>
                </form>
            </c:if>
        </section>
    </aside>
</div>

<jsp:include page="../components/store-footer.jsp" />
