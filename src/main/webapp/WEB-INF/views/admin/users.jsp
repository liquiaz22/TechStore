<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quản lý người dùng" scope="request" />
<jsp:include page="../components/admin-header.jsp" />

<header class="section-head admin-page-head">
    <div><p class="eyebrow">Tài khoản</p><h1>Quản lý người dùng</h1><p class="muted">Tra cứu tài khoản và kiểm soát quyền truy cập hệ thống.</p></div>
    <span class="admin-count-chip"><strong>${totalUsers}</strong> tài khoản</span>
</header>

<section class="panel filter-panel admin-filter-panel">
    <form action="${ctx}/admin/users" method="get" class="admin-user-filter">
        <div class="field"><label for="userQuery">Tìm người dùng</label><input id="userQuery" name="q" maxlength="150" placeholder="Tên, email hoặc điện thoại" value="<c:out value='${keyword}'/>"></div>
        <div class="field"><label for="userRole">Vai trò</label><select id="userRole" name="role"><option value="">Tất cả</option><option value="CUSTOMER" ${selectedRole == 'CUSTOMER' ? 'selected' : ''}>Khách hàng</option><option value="ADMIN" ${selectedRole == 'ADMIN' ? 'selected' : ''}>Quản trị viên</option></select></div>
        <div class="field"><label for="userStatus">Trạng thái</label><select id="userStatus" name="status"><option value="">Tất cả</option><option value="ACTIVE" ${selectedStatus == 'ACTIVE' ? 'selected' : ''}>Đang hoạt động</option><option value="LOCKED" ${selectedStatus == 'LOCKED' ? 'selected' : ''}>Đã khóa</option></select></div>
        <button class="btn btn-primary" type="submit">Lọc tài khoản</button>
        <a class="btn btn-ghost" href="${ctx}/admin/users">Đặt lại</a>
    </form>
</section>

<c:choose>
    <c:when test="${empty users}"><section class="panel admin-empty-state"><span aria-hidden="true">◎</span><h2>Không tìm thấy người dùng</h2><p>Thử thay đổi từ khóa hoặc bộ lọc tài khoản.</p><a class="btn btn-secondary" href="${ctx}/admin/users">Xóa bộ lọc</a></section></c:when>
    <c:otherwise>
        <section class="panel admin-table-panel">
            <div class="admin-table-heading"><div><h2>Danh sách tài khoản</h2><p>Trang ${currentPage}/${totalPages}</p></div><span>Khóa tài khoản sẽ ngăn người dùng đăng nhập và thực hiện giao dịch.</span></div>
            <div class="table-wrap"><table class="data-table admin-responsive-table"><thead><tr><th>ID</th><th>Người dùng</th><th>Điện thoại</th><th>Vai trò</th><th>Trạng thái</th><th>Thao tác</th></tr></thead><tbody>
                <c:forEach var="account" items="${users}">
                    <tr><td data-label="ID">#${account.userId}</td><td data-label="Người dùng"><strong><c:out value="${account.fullName}" /></strong><br><span class="muted"><c:out value="${account.email}" /></span></td><td data-label="Điện thoại"><c:out value="${empty account.phone ? '—' : account.phone}" /></td><td data-label="Vai trò"><span class="badge badge-neutral">${account.role == 'ADMIN' ? 'Quản trị viên' : 'Khách hàng'}</span></td><td data-label="Trạng thái"><span class="badge ${account.status == 'ACTIVE' ? 'badge-success' : 'badge-danger'}">${account.status == 'ACTIVE' ? 'Đang hoạt động' : 'Đã khóa'}</span></td><td data-label="Thao tác">
                        <c:choose><c:when test="${account.userId == sessionScope.user.userId}"><span class="muted admin-self-account">Tài khoản hiện tại</span></c:when><c:otherwise>
                            <form action="${ctx}/admin/users" method="post"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="userId" value="${account.userId}"><input type="hidden" name="q" value="<c:out value='${keyword}'/>"><input type="hidden" name="filterStatus" value="<c:out value='${selectedStatus}'/>"><input type="hidden" name="role" value="<c:out value='${selectedRole}'/>"><input type="hidden" name="page" value="${currentPage}"><button class="btn ${account.status == 'ACTIVE' ? 'btn-danger' : 'btn-secondary'} btn-small" type="submit" data-confirm="${account.status == 'ACTIVE' ? 'Khóa tài khoản sẽ ngăn người dùng đăng nhập. Tiếp tục?' : 'Mở khóa để tài khoản có thể đăng nhập lại?'}">${account.status == 'ACTIVE' ? 'Khóa tài khoản' : 'Mở khóa'}</button></form>
                        </c:otherwise></c:choose>
                    </td></tr>
                </c:forEach>
            </tbody></table></div>
        </section>
    </c:otherwise>
</c:choose>

<c:if test="${totalPages > 1}"><nav class="pagination admin-pagination" aria-label="Phân trang người dùng"><c:forEach begin="1" end="${totalPages}" var="pageNumber"><c:url var="userPageUrl" value="/admin/users"><c:param name="q" value="${keyword}"/><c:param name="role" value="${selectedRole}"/><c:param name="status" value="${selectedStatus}"/><c:param name="page" value="${pageNumber}"/></c:url><a class="${pageNumber == currentPage ? 'active' : ''}" href="${userPageUrl}">${pageNumber}</a></c:forEach></nav></c:if>

<jsp:include page="../components/admin-footer.jsp" />
