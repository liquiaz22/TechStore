<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Quản trị TechStore" scope="request" />
<jsp:include page="../components/header.jsp" />
<jsp:include page="../components/admin-nav.jsp" />
<div class="section-head"><div><p class="eyebrow">Admin</p><h1>Tổng quan cửa hàng</h1></div></div>
<section class="stat-grid"><div class="stat-card"><span>Người dùng</span><strong>${userCount}</strong></div><div class="stat-card"><span>Sản phẩm</span><strong>${productCount}</strong></div><div class="stat-card"><span>Đơn hàng</span><strong>${orderCount}</strong></div></section>
<section class="panel"><div class="section-head"><h2>Đơn đang chờ xác nhận</h2><a class="btn btn-secondary" href="${ctx}/admin/orders">Xem tất cả</a></div><div class="table-wrap"><table class="data-table"><thead><tr><th>Mã đơn</th><th>Khách hàng</th><th>Ngày tạo</th><th>Tổng tiền</th><th></th></tr></thead><tbody><c:forEach var="order" items="${pendingOrders}"><tr><td><c:out value="${order.orderCode}" /></td><td><c:out value="${order.user.fullName}" /></td><td><c:out value="${order.createdAt}" /></td><td class="money"><fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /> ₫</td><td><a class="btn btn-small btn-secondary" href="${ctx}/orders/detail?code=${order.orderCode}">Chi tiết</a></td></tr></c:forEach><c:if test="${empty pendingOrders}"><tr><td colspan="5">Không có đơn đang chờ.</td></tr></c:if></tbody></table></div></section>
<jsp:include page="../components/footer.jsp" />
