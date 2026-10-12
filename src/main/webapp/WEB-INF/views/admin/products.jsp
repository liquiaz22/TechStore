<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quản lý sản phẩm" scope="request" />
<jsp:include page="../components/admin-header.jsp" />

<header class="section-head admin-page-head">
    <div><p class="eyebrow">Kho hàng</p><h1>Quản lý sản phẩm</h1><p class="muted">Theo dõi nội dung sản phẩm, trạng thái hiển thị và tồn kho phiên bản.</p></div>
    <a class="btn btn-primary" href="${ctx}/admin/products/form">+ Thêm sản phẩm</a>
</header>

<section class="panel filter-panel admin-filter-panel">
    <form action="${ctx}/admin/products" method="get" class="admin-compact-filter">
        <div class="field"><label for="productQuery">Tìm sản phẩm</label><input id="productQuery" name="q" maxlength="150" placeholder="Tên hoặc slug sản phẩm" value="<c:out value='${keyword}'/>"></div>
        <div class="field"><label for="productStatus">Trạng thái</label><select id="productStatus" name="status"><option value="">Tất cả</option><option value="ACTIVE" ${selectedStatus == 'ACTIVE' ? 'selected' : ''}>Đang bán</option><option value="DRAFT" ${selectedStatus == 'DRAFT' ? 'selected' : ''}>Bản nháp</option><option value="INACTIVE" ${selectedStatus == 'INACTIVE' ? 'selected' : ''}>Ngừng bán</option></select></div>
        <button class="btn btn-primary" type="submit">Lọc sản phẩm</button>
        <a class="btn btn-ghost" href="${ctx}/admin/products">Đặt lại</a>
    </form>
</section>

<c:choose>
    <c:when test="${empty products}">
        <section class="panel admin-empty-state"><span aria-hidden="true">◇</span><h2>Không có sản phẩm phù hợp</h2><p>Thử thay đổi từ khóa hoặc trạng thái đang lọc.</p><a class="btn btn-secondary" href="${ctx}/admin/products">Xóa bộ lọc</a></section>
    </c:when>
    <c:otherwise>
        <section class="panel admin-table-panel">
            <div class="admin-table-heading"><div><h2>Danh sách sản phẩm</h2><p>${totalProducts} kết quả · Trang ${currentPage}/${totalPages}</p></div><span>Chọn chỉnh sửa để quản lý phiên bản, hình ảnh và thông số.</span></div>
            <div class="table-wrap"><table class="data-table admin-responsive-table"><thead><tr><th>ID</th><th>Sản phẩm</th><th>Danh mục</th><th>Thương hiệu</th><th>Trạng thái</th><th>Thao tác</th></tr></thead><tbody>
                <c:forEach var="product" items="${products}">
                    <c:url var="editProductUrl" value="/admin/products/form"><c:param name="id" value="${product.productId}"/><c:param name="q" value="${keyword}"/><c:param name="listStatus" value="${selectedStatus}"/><c:param name="page" value="${currentPage}"/></c:url>
                    <tr><td data-label="ID">#${product.productId}</td><td data-label="Sản phẩm"><strong><c:out value="${product.name}" /></strong><br><span class="muted"><c:out value="${product.slug}" /></span></td><td data-label="Danh mục"><c:out value="${product.category.name}" /></td><td data-label="Thương hiệu"><c:out value="${empty product.brand ? '—' : product.brand.name}" /></td><td data-label="Trạng thái"><span class="badge ${product.status == 'ACTIVE' ? 'badge-success' : product.status == 'DRAFT' ? 'badge-warning' : 'badge-neutral'}">${product.status == 'ACTIVE' ? 'Đang bán' : product.status == 'DRAFT' ? 'Bản nháp' : 'Ngừng bán'}</span></td><td data-label="Thao tác"><a class="btn btn-secondary btn-small" href="${editProductUrl}">Chỉnh sửa</a></td></tr>
                </c:forEach>
            </tbody></table></div>
        </section>
    </c:otherwise>
</c:choose>

<c:if test="${totalPages > 1}">
    <nav class="pagination admin-pagination" aria-label="Phân trang sản phẩm">
        <c:forEach begin="1" end="${totalPages}" var="pageNumber"><c:url var="productPageUrl" value="/admin/products"><c:param name="q" value="${keyword}"/><c:param name="status" value="${selectedStatus}"/><c:param name="page" value="${pageNumber}"/></c:url><a class="${pageNumber == currentPage ? 'active' : ''}" href="${productPageUrl}">${pageNumber}</a></c:forEach>
    </nav>
</c:if>

<jsp:include page="../components/admin-footer.jsp" />
