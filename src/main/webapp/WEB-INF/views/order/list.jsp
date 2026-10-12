<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Lịch sử đơn hàng" scope="request" />
<jsp:include page="../components/store-header.jsp" />

<header class="section-head order-page-head">
    <div>
        <p class="eyebrow">Theo dõi mua sắm</p>
        <h1>Đơn hàng của tôi</h1>
        <p class="muted">Kiểm tra trạng thái xử lý, thanh toán và thông tin giao hàng.</p>
    </div>
    <a class="btn btn-secondary" href="${ctx}/products">Tiếp tục mua sắm</a>
</header>

<c:choose>
    <c:when test="${empty orders}">
        <section class="panel empty-state order-empty-state">
            <span class="order-empty-icon" aria-hidden="true">⌑</span>
            <h2>Bạn chưa có đơn hàng nào</h2>
            <p class="muted">Các đơn hàng sau khi đặt sẽ xuất hiện tại đây để bạn theo dõi.</p>
            <a class="btn btn-primary" href="${ctx}/products">Khám phá sản phẩm</a>
        </section>
    </c:when>
    <c:otherwise>
        <section class="order-list" aria-label="Danh sách đơn hàng">
            <c:forEach var="order" items="${orders}">
                <c:set var="orderStatusLabel" value="${orderStatusLabels[order.status]}" />
                <c:set var="paymentStatusLabel" value="${paymentStatusLabels[order.paymentStatus]}" />
                <c:url var="orderDetailUrl" value="/orders/detail">
                    <c:param name="code" value="${order.orderCode}" />
                </c:url>
                <article class="panel order-list-card">
                    <div class="order-list-card-head">
                        <div>
                            <span class="order-list-label">Mã đơn hàng</span>
                            <a class="order-code-link" href="${orderDetailUrl}"><c:out value="${order.orderCode}" /></a>
                        </div>
                        <span class="badge status-badge ${orderStatusClasses[order.status]}">
                            <span class="status-badge-icon" aria-hidden="true"><c:out value="${orderStatusIcons[order.status]}" /></span>
                            <c:out value="${empty orderStatusLabel ? order.status : orderStatusLabel}" />
                        </span>
                    </div>
                    <dl class="order-list-meta">
                        <div>
                            <dt>Ngày đặt</dt>
                            <dd><c:out value="${orderCreatedAtDisplays[order.orderId]}" /></dd>
                        </div>
                        <div>
                            <dt>Thanh toán</dt>
                            <dd>
                                <span class="badge status-badge ${paymentStatusClasses[order.paymentStatus]}">
                                    <span class="status-badge-icon" aria-hidden="true"><c:out value="${paymentStatusIcons[order.paymentStatus]}" /></span>
                                    <c:out value="${empty paymentStatusLabel ? order.paymentStatus : paymentStatusLabel}" />
                                </span>
                            </dd>
                        </div>
                        <div class="order-list-total">
                            <dt>Tổng thanh toán</dt>
                            <dd><fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /> ₫</dd>
                        </div>
                    </dl>
                    <div class="order-list-actions">
                        <span class="muted">Xem sản phẩm, địa chỉ và lịch sử xử lý</span>
                        <a class="btn btn-primary btn-small" href="${orderDetailUrl}">Xem chi tiết <span aria-hidden="true">→</span></a>
                    </div>
                </article>
            </c:forEach>
        </section>

        <c:if test="${currentPage > 1 || fn:length(orders) == 20}">
            <nav class="pagination" aria-label="Phân trang đơn hàng">
                <c:if test="${currentPage > 1}"><a href="${ctx}/orders?page=${currentPage - 1}">← Trang trước</a></c:if>
                <span class="active" aria-current="page">${currentPage}</span>
                <c:if test="${fn:length(orders) == 20}"><a href="${ctx}/orders?page=${currentPage + 1}">Trang sau →</a></c:if>
            </nav>
        </c:if>
    </c:otherwise>
</c:choose>

<jsp:include page="../components/store-footer.jsp" />
