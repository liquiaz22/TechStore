<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Quản lý đơn hàng" scope="request" />
<jsp:include page="../components/admin-header.jsp" />

<header class="section-head admin-page-head">
    <div>
        <p class="eyebrow">Vận hành</p>
        <h1>Quản lý đơn hàng</h1>
        <p class="muted">Tra cứu đơn và mở trang chi tiết để cập nhật trạng thái an toàn.</p>
    </div>
    <span class="admin-count-chip"><strong><c:out value="${totalOrders}" /></strong> đơn phù hợp</span>
</header>

<section class="panel filter-panel admin-filter-panel">
    <form method="get" action="${ctx}/admin/orders" class="order-filter-grid">
        <div class="field"><label for="q">Tìm kiếm</label><input id="q" name="q" maxlength="150" placeholder="Mã đơn, email, tên, điện thoại" value="<c:out value='${keyword}'/>"></div>
        <div class="field">
            <label for="status">Trạng thái</label>
            <select id="status" name="status">
                <option value="">Tất cả trạng thái</option>
                <c:forTokens var="state" items="PENDING,CONFIRMED,PROCESSING,SHIPPING,COMPLETED,CANCELLED" delims=",">
                    <option value="${state}" ${selectedStatus == state ? 'selected' : ''}><c:out value="${statusLabels[state]}" /></option>
                </c:forTokens>
            </select>
        </div>
        <div class="field"><label for="from">Từ ngày</label><input id="from" name="from" type="date" value="${fromDate}"></div>
        <div class="field"><label for="to">Đến ngày</label><input id="to" name="to" type="date" value="${toDate}"></div>
        <button class="btn btn-primary" type="submit">Áp dụng</button>
        <a class="btn btn-ghost" href="${ctx}/admin/orders">Xóa bộ lọc</a>
    </form>
</section>

<c:choose>
    <c:when test="${empty orders}">
        <section class="panel admin-empty-state">
            <span aria-hidden="true">▤</span>
            <h2>Không tìm thấy đơn hàng</h2>
            <p>Hãy thay đổi từ khóa, trạng thái hoặc khoảng ngày đang lọc.</p>
            <a class="btn btn-secondary" href="${ctx}/admin/orders">Xóa bộ lọc</a>
        </section>
    </c:when>
    <c:otherwise>
        <section class="panel admin-table-panel">
            <div class="admin-table-heading">
                <div><h2>Danh sách đơn hàng</h2><p>Trang ${currentPage}/${totalPages}</p></div>
                <span>Mở chi tiết để xem sản phẩm, thanh toán và lịch sử xử lý.</span>
            </div>
            <div class="table-wrap">
                <table class="data-table admin-responsive-table admin-orders-table">
                    <thead><tr><th>Mã đơn</th><th>Khách hàng</th><th>Ngày đặt</th><th>Tổng tiền</th><th>Thanh toán</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
                    <tbody>
                        <c:forEach var="order" items="${orders}">
                            <c:set var="orderStatusLabel" value="${statusLabels[order.status]}" />
                            <c:set var="paymentStatusLabel" value="${paymentStatusLabels[order.paymentStatus]}" />
                            <c:url var="adminOrderDetailUrl" value="/admin/orders/detail">
                                <c:param name="code" value="${order.orderCode}" />
                                <c:param name="q" value="${keyword}" />
                                <c:param name="filterStatus" value="${selectedStatus}" />
                                <c:param name="from" value="${fromDate}" />
                                <c:param name="to" value="${toDate}" />
                                <c:param name="page" value="${currentPage}" />
                            </c:url>
                            <tr>
                                <td data-label="Mã đơn"><a class="admin-primary-link" href="${adminOrderDetailUrl}"><c:out value="${order.orderCode}" /></a></td>
                                <td data-label="Khách hàng"><strong><c:out value="${order.user.fullName}" /></strong><br><span class="muted"><c:out value="${order.user.email}" /> · <c:out value="${order.receiverPhone}" /></span></td>
                                <td data-label="Ngày đặt"><c:out value="${orderCreatedAtDisplays[order.orderId]}" /></td>
                                <td data-label="Tổng tiền" class="money"><fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /> ₫</td>
                                <td data-label="Thanh toán"><span class="badge ${paymentStatusClasses[order.paymentStatus]}"><c:out value="${empty paymentStatusLabel ? order.paymentStatus : paymentStatusLabel}" /></span></td>
                                <td data-label="Trạng thái"><span class="badge ${statusClasses[order.status]}"><c:out value="${empty orderStatusLabel ? order.status : orderStatusLabel}" /></span></td>
                                <td data-label="Thao tác"><a class="btn btn-secondary btn-small" href="${adminOrderDetailUrl}">Xem và xử lý</a></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </section>
    </c:otherwise>
</c:choose>

<c:if test="${totalPages > 1}">
    <nav class="pagination admin-pagination" aria-label="Phân trang đơn hàng">
        <c:if test="${currentPage > 1}">
            <c:url var="previousPageUrl" value="/admin/orders"><c:param name="q" value="${keyword}"/><c:param name="status" value="${selectedStatus}"/><c:param name="from" value="${fromDate}"/><c:param name="to" value="${toDate}"/><c:param name="page" value="${currentPage - 1}"/></c:url>
            <a href="${previousPageUrl}" aria-label="Trang trước">←</a>
        </c:if>
        <c:forEach begin="1" end="${totalPages}" var="pageNumber">
            <c:if test="${pageNumber == 1 || pageNumber == totalPages || (pageNumber >= currentPage - 2 && pageNumber <= currentPage + 2)}">
                <c:url var="pageUrl" value="/admin/orders"><c:param name="q" value="${keyword}"/><c:param name="status" value="${selectedStatus}"/><c:param name="from" value="${fromDate}"/><c:param name="to" value="${toDate}"/><c:param name="page" value="${pageNumber}"/></c:url>
                <a class="${pageNumber == currentPage ? 'active' : ''}" aria-current="${pageNumber == currentPage ? 'page' : ''}" href="${pageUrl}">${pageNumber}</a>
            </c:if>
            <c:if test="${(pageNumber == 2 && currentPage > 4) || (pageNumber == totalPages - 1 && currentPage < totalPages - 3)}"><span class="pagination-gap">…</span></c:if>
        </c:forEach>
        <c:if test="${currentPage < totalPages}">
            <c:url var="nextPageUrl" value="/admin/orders"><c:param name="q" value="${keyword}"/><c:param name="status" value="${selectedStatus}"/><c:param name="from" value="${fromDate}"/><c:param name="to" value="${toDate}"/><c:param name="page" value="${currentPage + 1}"/></c:url>
            <a href="${nextPageUrl}" aria-label="Trang sau">→</a>
        </c:if>
    </nav>
</c:if>

<jsp:include page="../components/admin-footer.jsp" />
