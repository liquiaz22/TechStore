<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quản lý người dùng" scope="request" />
<jsp:include page="../components/header.jsp" />
<jsp:include page="../components/admin-nav.jsp" />
<div class="section-head"><div><p class="eyebrow">Tài khoản</p><h1>Quản lý người dùng</h1></div></div>
<section class="panel table-wrap"><table class="data-table"><thead><tr><th>ID</th><th>Người dùng</th><th>Điện thoại</th><th>Vai trò</th><th>Trạng thái</th><th></th></tr></thead><tbody><c:forEach var="account" items="${users}"><tr><td>${account.userId}</td><td><strong><c:out value="${account.fullName}" /></strong><br><span class="muted"><c:out value="${account.email}" /></span></td><td><c:out value="${account.phone}" /></td><td><c:out value="${account.role}" /></td><td><span class="badge ${account.status == 'ACTIVE' ? 'badge-success' : 'badge-danger'}"><c:out value="${account.status}" /></span></td><td><c:if test="${account.userId != sessionScope.user.userId}"><form action="${ctx}/admin/users" method="post"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="userId" value="${account.userId}"><button class="btn ${account.status == 'ACTIVE' ? 'btn-danger' : 'btn-secondary'} btn-small" type="submit">${account.status == 'ACTIVE' ? 'Khóa' : 'Mở khóa'}</button></form></c:if></td></tr></c:forEach></tbody></table></section>
<jsp:include page="../components/footer.jsp" />
