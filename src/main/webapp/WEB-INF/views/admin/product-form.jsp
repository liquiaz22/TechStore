<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="${empty product.productId ? 'Thêm sản phẩm' : 'Chỉnh sửa sản phẩm'}" scope="request" />
<jsp:include page="../components/header.jsp" />
<jsp:include page="../components/admin-nav.jsp" />
<div class="section-head"><div><p class="eyebrow">Sản phẩm</p><h1>${empty product.productId ? 'Thêm sản phẩm' : 'Chỉnh sửa sản phẩm'}</h1></div><a class="btn btn-ghost" href="${ctx}/admin/products">Quay lại</a></div>

<section class="panel">
    <form action="${ctx}/admin/products/save" method="post" class="form-grid">
        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="id" value="${product.productId}">
        <div class="field"><label>Tên sản phẩm</label><input name="name" maxlength="250" value="<c:out value='${product.name}'/>" required></div>
        <div class="field"><label>Slug</label><input name="slug" maxlength="300" pattern="[a-z0-9-]+" value="<c:out value='${product.slug}'/>" required></div>
        <div class="field"><label>Danh mục</label><select name="categoryId" required><option value="">Chọn danh mục</option><c:forEach var="category" items="${categories}"><option value="${category.categoryId}" ${not empty product.category && product.category.categoryId == category.categoryId ? 'selected' : ''}><c:out value="${category.name}" /></option></c:forEach></select></div>
        <div class="field"><label>Thương hiệu</label><select name="brandId"><option value="">Không có</option><c:forEach var="brand" items="${brands}"><option value="${brand.brandId}" ${not empty product.brand && product.brand.brandId == brand.brandId ? 'selected' : ''}><c:out value="${brand.name}" /></option></c:forEach></select></div>
        <div class="field"><label>Trạng thái</label><select name="status"><option value="DRAFT" ${product.status == 'DRAFT' ? 'selected' : ''}>DRAFT</option><option value="ACTIVE" ${product.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option><option value="INACTIVE" ${product.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option></select></div>
        <div class="field full"><label>Mô tả ngắn</label><textarea name="shortDescription" maxlength="1000"><c:out value="${product.shortDescription}" /></textarea></div>
        <div class="field full"><label>Mô tả đầy đủ</label><textarea name="description" maxlength="20000"><c:out value="${product.description}" /></textarea></div>
        <button class="btn btn-primary full" type="submit">Lưu sản phẩm</button>
    </form>
</section>

<c:if test="${not empty product.productId}">
    <section class="panel subsection">
        <h2>Phiên bản sản phẩm</h2>
        <form action="${ctx}/admin/products/variant/save" method="post" class="form-grid">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="productId" value="${product.productId}">
            <div class="field"><label>SKU</label><input name="sku" maxlength="100" required></div><div class="field"><label>Tên phiên bản</label><input name="variantName" maxlength="200" placeholder="256GB - Đen" required></div>
            <div class="field"><label>Màu sắc</label><input name="color" maxlength="100"></div><div class="field"><label>RAM</label><input name="ram" maxlength="50"></div><div class="field"><label>Dung lượng</label><input name="storage" maxlength="50"></div>
            <div class="field"><label>Giá bán</label><input name="price" type="number" min="0" step="1000" required></div><div class="field"><label>Giá gốc</label><input name="originalPrice" type="number" min="0" step="1000"></div><div class="field"><label>Tồn kho</label><input name="stockQuantity" type="number" min="0" value="0" required></div>
            <label class="check-row"><input type="checkbox" name="active" checked> Đang bán</label><button class="btn btn-primary" type="submit">Thêm phiên bản</button>
        </form>
        <div class="table-wrap subsection"><table class="data-table"><thead><tr><th>SKU</th><th>Phiên bản</th><th>Giá</th><th>Tồn kho</th><th>Trạng thái</th></tr></thead><tbody><c:forEach var="variant" items="${variants}"><tr><td><c:out value="${variant.sku}" /></td><td><c:out value="${variant.variantName}" /></td><td class="money"><fmt:formatNumber value="${variant.price}" pattern="#,##0" /> ₫</td><td>${variant.stockQuantity}</td><td><span class="badge ${variant.active ? 'badge-success' : 'badge-neutral'}">${variant.active ? 'ACTIVE' : 'INACTIVE'}</span></td></tr></c:forEach><c:if test="${empty variants}"><tr><td colspan="5">Chưa có phiên bản.</td></tr></c:if></tbody></table></div>
    </section>

    <div class="split-grid subsection">
        <section class="panel"><h2>Hình ảnh</h2><form action="${ctx}/admin/products/image/save" method="post" class="form-grid"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="productId" value="${product.productId}"><div class="field full"><label>URL hình ảnh</label><input name="imageUrl" maxlength="500" required></div><div class="field"><label>Phiên bản</label><select name="variantId"><option value="">Ảnh chung</option><c:forEach var="variant" items="${variants}"><option value="${variant.variantId}"><c:out value="${variant.variantName}" /></option></c:forEach></select></div><div class="field"><label>Thứ tự</label><input name="sortOrder" type="number" value="0"></div><label class="check-row"><input type="checkbox" name="primary"> Ảnh chính</label><button class="btn btn-primary" type="submit">Thêm ảnh</button></form><div class="subsection"><c:forEach var="image" items="${images}"><div class="summary-line"><span><c:out value="${image.imageUrl}" /></span><form action="${ctx}/admin/products/image/delete" method="post"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="productId" value="${product.productId}"><input type="hidden" name="id" value="${image.imageId}"><button class="btn btn-danger btn-small" type="submit">Xóa</button></form></div></c:forEach></div></section>
        <section class="panel"><h2>Thông số kỹ thuật</h2><form action="${ctx}/admin/products/spec/save" method="post" class="form-grid"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="productId" value="${product.productId}"><div class="field"><label>Tên thông số</label><input name="specificationName" maxlength="150" required></div><div class="field"><label>Giá trị</label><input name="specificationValue" maxlength="500" required></div><div class="field"><label>Thứ tự</label><input name="sortOrder" type="number" value="0"></div><button class="btn btn-primary" type="submit">Thêm thông số</button></form><div class="subsection"><c:forEach var="spec" items="${specifications}"><div class="summary-line"><span><strong><c:out value="${spec.specificationName}" />:</strong> <c:out value="${spec.specificationValue}" /></span><form action="${ctx}/admin/products/spec/delete" method="post"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="productId" value="${product.productId}"><input type="hidden" name="id" value="${spec.specificationId}"><button class="btn btn-danger btn-small" type="submit">Xóa</button></form></div></c:forEach></div></section>
    </div>
</c:if>
<jsp:include page="../components/footer.jsp" />
