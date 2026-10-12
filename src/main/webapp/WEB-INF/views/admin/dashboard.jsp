<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Tổng quan vận hành" scope="request" />
<jsp:include page="../components/admin-header.jsp" />

<c:url var="exportUrl" value="/admin/reports/export"><c:param name="from" value="${fromDate}"/><c:param name="to" value="${toDate}"/></c:url>
<header class="section-head admin-page-head">
    <div><p class="eyebrow">Dashboard</p><h1>Tổng quan cửa hàng</h1><p class="muted">Theo dõi doanh thu, đơn cần xử lý và cảnh báo tồn kho.</p></div>
    <a class="btn btn-secondary" href="${exportUrl}">↓ Xuất báo cáo CSV</a>
</header>

<section class="panel filter-panel admin-filter-panel">
    <form action="${ctx}/admin" method="get" class="report-filter">
        <div class="field"><label for="from">Từ ngày</label><input id="from" name="from" type="date" value="${fromDate}" required></div>
        <div class="field"><label for="to">Đến ngày</label><input id="to" name="to" type="date" value="${toDate}" required></div>
        <button class="btn btn-primary" type="submit">Cập nhật báo cáo</button>
    </form>
</section>

<section class="admin-action-center" aria-labelledby="actionCenterTitle">
    <div class="admin-section-title"><div><p class="eyebrow">Cần chú ý</p><h2 id="actionCenterTitle">Việc cần xử lý</h2></div><span>Ưu tiên theo tình trạng vận hành hiện tại</span></div>
    <div class="admin-action-grid">
        <a class="admin-action-card action-warning" href="${ctx}/admin/orders?status=PENDING"><span class="admin-action-icon" aria-hidden="true">!</span><div><small>Chờ xác nhận</small><strong>${pendingOrderCount} đơn hàng</strong><p>Mở danh sách và xác nhận các đơn mới.</p></div><span aria-hidden="true">→</span></a>
        <a class="admin-action-card action-info" href="${ctx}/admin/orders"><span class="admin-action-icon" aria-hidden="true">↻</span><div><small>Đang vận hành</small><strong>${ordersInProgressCount} đơn đang xử lý</strong><p>Theo dõi đơn đã xác nhận, chuẩn bị và đang giao.</p></div><span aria-hidden="true">→</span></a>
        <a class="admin-action-card action-danger" href="#stockAlerts"><span class="admin-action-icon" aria-hidden="true">↓</span><div><small>Cảnh báo tồn kho</small><strong>${fn:length(report.stockAlerts)} phiên bản</strong><p>Mở sản phẩm để bổ sung hoặc điều chỉnh tồn kho.</p></div><span aria-hidden="true">→</span></a>
    </div>
</section>

<section class="report-stat-grid admin-kpi-grid" aria-label="Chỉ số chính">
    <article class="report-stat-card"><span>Doanh thu hoàn tất</span><strong><fmt:formatNumber value="${report.summary.revenue}" pattern="#,##0" /> ₫</strong><small>Trong khoảng ngày đã chọn</small></article>
    <article class="report-stat-card"><span>Đơn hoàn tất</span><strong>${report.summary.completedOrders}</strong><small>Đã ghi nhận doanh thu</small></article>
    <article class="report-stat-card"><span>Tổng đơn trong kỳ</span><strong>${report.summary.totalOrders}</strong><small>Tất cả trạng thái</small></article>
    <article class="report-stat-card"><span>Khách hàng</span><strong>${report.summary.customerCount}</strong><small>Tài khoản khách hàng</small></article>
    <article class="report-stat-card"><span>Sản phẩm đang bán</span><strong>${report.summary.productCount}</strong><small>Sản phẩm hoạt động</small></article>
</section>

<div class="split-grid report-charts">
    <section class="panel">
        <div class="admin-panel-heading"><div><p class="eyebrow">Doanh thu</p><h2>Theo ngày</h2></div></div>
        <div class="bar-chart bar-chart-scroll">
            <c:forEach var="item" items="${report.dailyRevenue}"><div class="bar-row"><span class="bar-label"><c:out value="${item.date}" /></span><div class="bar-track"><span class="bar-fill" style="width:${item.percent}%"></span></div><strong><fmt:formatNumber value="${item.revenue}" pattern="#,##0" /> ₫</strong></div></c:forEach>
        </div>
    </section>
    <section class="panel">
        <div class="admin-panel-heading"><div><p class="eyebrow">Đơn hàng</p><h2>Theo trạng thái</h2></div><a class="admin-text-link" href="${ctx}/admin/orders">Xem tất cả</a></div>
        <div class="bar-chart">
            <c:forEach var="item" items="${report.statusCounts}"><div class="bar-row"><span class="bar-label"><c:out value="${statusLabels[item.status]}" /></span><div class="bar-track"><span class="bar-fill bar-fill-green" style="width:${item.percent}%"></span></div><strong>${item.count}</strong></div></c:forEach>
        </div>
    </section>
</div>

<div class="split-grid subsection">
    <section class="panel admin-table-panel">
        <div class="admin-table-heading"><div><h2>Sản phẩm bán chạy</h2><p>Tối đa 10 sản phẩm</p></div></div>
        <c:choose><c:when test="${empty report.topProducts}"><div class="admin-inline-empty admin-report-empty">Chưa có đơn hoàn tất trong khoảng này.</div></c:when><c:otherwise><div class="table-wrap"><table class="data-table admin-responsive-table"><thead><tr><th>Sản phẩm</th><th>Đã bán</th><th>Doanh thu</th></tr></thead><tbody><c:forEach var="item" items="${report.topProducts}"><tr><td data-label="Sản phẩm"><c:out value="${item.productName}" /></td><td data-label="Đã bán">${item.quantity}</td><td data-label="Doanh thu" class="money"><fmt:formatNumber value="${item.revenue}" pattern="#,##0" /> ₫</td></tr></c:forEach></tbody></table></div></c:otherwise></c:choose>
    </section>
    <section class="panel admin-table-panel">
        <div class="admin-table-heading"><div><h2>Khách hàng mua nhiều</h2><p>Tối đa 10 khách hàng</p></div></div>
        <c:choose><c:when test="${empty report.topCustomers}"><div class="admin-inline-empty admin-report-empty">Chưa có dữ liệu khách hàng.</div></c:when><c:otherwise><div class="table-wrap"><table class="data-table admin-responsive-table"><thead><tr><th>Khách hàng</th><th>Số đơn</th><th>Tổng chi tiêu</th></tr></thead><tbody><c:forEach var="item" items="${report.topCustomers}"><tr><td data-label="Khách hàng"><strong><c:out value="${item.fullName}" /></strong><br><span class="muted"><c:out value="${item.email}" /></span></td><td data-label="Số đơn">${item.orderCount}</td><td data-label="Tổng chi tiêu" class="money"><fmt:formatNumber value="${item.totalSpent}" pattern="#,##0" /> ₫</td></tr></c:forEach></tbody></table></div></c:otherwise></c:choose>
    </section>
</div>

<section class="panel admin-table-panel subsection" id="stockAlerts">
    <div class="admin-table-heading"><div><h2>Sản phẩm sắp hết hàng</h2><p>Phiên bản đang bán có tồn kho từ 5 sản phẩm trở xuống.</p></div><a class="btn btn-secondary btn-small" href="${ctx}/admin/products">Quản lý sản phẩm</a></div>
    <c:choose>
        <c:when test="${empty report.stockAlerts}"><div class="admin-inline-empty admin-report-empty">Không có sản phẩm sắp hết hàng.</div></c:when>
        <c:otherwise><div class="table-wrap"><table class="data-table admin-responsive-table"><thead><tr><th>SKU</th><th>Sản phẩm</th><th>Phiên bản</th><th>Tồn kho</th><th>Thao tác</th></tr></thead><tbody><c:forEach var="item" items="${report.stockAlerts}"><tr><td data-label="SKU"><c:out value="${item.sku}" /></td><td data-label="Sản phẩm"><c:out value="${item.productName}" /></td><td data-label="Phiên bản"><c:out value="${item.variantName}" /></td><td data-label="Tồn kho"><span class="badge ${item.stockQuantity == 0 ? 'badge-danger' : 'badge-warning'}">${item.stockQuantity}</span></td><td data-label="Thao tác"><a class="btn btn-secondary btn-small" href="${ctx}/admin/products/form?id=${item.productId}&amp;editVariant=${item.variantId}">Cập nhật kho</a></td></tr></c:forEach></tbody></table></div></c:otherwise>
    </c:choose>
</section>

<jsp:include page="../components/admin-footer.jsp" />
