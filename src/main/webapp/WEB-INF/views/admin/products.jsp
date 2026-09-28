<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quản lý sản phẩm" scope="request" />
<jsp:include page="../components/header.jsp" />
<jsp:include page="../components/admin-nav.jsp" />
<div class="section-head"><div><p class="eyebrow">Kho hàng</p><h1>Quản lý sản phẩm</h1></div><a class="btn btn-primary" href="${ctx}/admin/products/form">Thêm sản phẩm</a></div>
<section class="panel table-wrap"><table class="data-table"><thead><tr><th>ID</th><th>Sản phẩm</th><th>Danh mục</th><th>Thương hiệu</th><th>Trạng thái</th><th></th></tr></thead><tbody><c:forEach var="product" items="${products}"><tr><td>${product.productId}</td><td><strong><c:out value="${product.name}" /></strong><br><span class="muted"><c:out value="${product.slug}" /></span></td><td><c:out value="${product.category.name}" /></td><td><c:out value="${empty product.brand ? '-' : product.brand.name}" /></td><td><span class="badge ${product.status == 'ACTIVE' ? 'badge-success' : product.status == 'DRAFT' ? 'badge-warning' : 'badge-neutral'}"><c:out value="${product.status}" /></span></td><td><a class="btn btn-secondary btn-small" href="${ctx}/admin/products/form?id=${product.productId}">Chỉnh sửa</a></td></tr></c:forEach><c:if test="${empty products}"><tr><td colspan="6">Chưa có sản phẩm.</td></tr></c:if></tbody></table></section>
<jsp:include page="../components/footer.jsp" />
