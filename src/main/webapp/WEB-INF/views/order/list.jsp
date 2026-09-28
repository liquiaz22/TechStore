<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Lịch sử đơn hàng" scope="request" />
<jsp:include page="../components/header.jsp" />
<div class="section-head"><div><p class="eyebrow">Theo dõi mua sắm</p><h1>Lịch sử đơn hàng</h1></div></div>
<c:choose><c:when test="${empty orders}"><section class="panel empty-state"><h2>Ông chưa có đơn hàng nào</h2><a class="btn btn-primary" href="${ctx}/home">Mua sắm ngay</a></section></c:when><c:otherwise><section class="panel table-wrap"><table class="data-table"><thead><tr><th>Mã đơn</th><th>Ngày tạo</th><th>Trạng thái</th><th>Thanh toán</th><th>Tổng tiền</th><th></th></tr></thead><tbody><c:forEach var="order" items="${orders}"><tr><td><strong><c:out value="${order.orderCode}" /></strong></td><td><c:out value="${order.createdAt}" /></td><td><span class="badge ${order.status == 'COMPLETED' ? 'badge-success' : order.status == 'CANCELLED' ? 'badge-danger' : 'badge-warning'}"><c:out value="${order.status}" /></span></td><td><c:out value="${order.paymentStatus}" /></td><td class="money"><fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /> ₫</td><td><a class="btn btn-secondary btn-small" href="${ctx}/orders/detail?code=${order.orderCode}">Chi tiết</a></td></tr></c:forEach></tbody></table></section></c:otherwise></c:choose>
<jsp:include page="../components/footer.jsp" />
