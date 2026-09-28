<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Danh mục và thương hiệu" scope="request" />
<jsp:include page="../components/header.jsp" />
<jsp:include page="../components/admin-nav.jsp" />

<div class="section-head">
    <div><p class="eyebrow">Catalog</p><h1>Danh mục &amp; thương hiệu</h1></div>
</div>

<div class="split-grid">
    <section class="panel">
        <h2>${empty editCategory ? 'Thêm danh mục' : 'Chỉnh sửa danh mục'}</h2>
        <form action="${ctx}/admin/catalog" method="post" class="form-grid">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <input type="hidden" name="type" value="category">
            <input type="hidden" name="action" value="save">
            <input type="hidden" name="id" value="${editCategory.categoryId}">
            <div class="field"><label for="categoryName">Tên</label><input id="categoryName" name="name" maxlength="100" value="<c:out value='${editCategory.name}'/>" required></div>
            <div class="field"><label for="categorySlug">Slug</label><input id="categorySlug" name="slug" maxlength="150" pattern="[a-z0-9]+(-[a-z0-9]+)*" value="<c:out value='${editCategory.slug}'/>" required></div>
            <div class="field full"><label for="parentId">Danh mục cha</label><select id="parentId" name="parentId"><option value="">Không có</option><c:forEach var="category" items="${categories}"><c:if test="${empty editCategory or category.categoryId != editCategory.categoryId}"><option value="${category.categoryId}" ${not empty editCategory.parentCategory && editCategory.parentCategory.categoryId == category.categoryId ? 'selected' : ''}><c:out value="${category.name}" /></option></c:if></c:forEach></select></div>
            <label class="check-row full"><input type="checkbox" name="active" ${empty editCategory or editCategory.active ? 'checked' : ''}> Đang hoạt động</label>
            <button class="btn btn-primary" type="submit">${empty editCategory ? 'Thêm danh mục' : 'Lưu thay đổi'}</button>
            <c:if test="${not empty editCategory}"><a class="btn btn-ghost" href="${ctx}/admin/catalog">Hủy sửa</a></c:if>
        </form>

        <div class="table-wrap subsection">
            <table class="data-table">
                <thead><tr><th>Tên</th><th>Slug</th><th>Danh mục cha</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
                <tbody>
                <c:forEach var="category" items="${categories}">
                    <tr>
                        <td><c:out value="${category.name}" /></td>
                        <td><c:out value="${category.slug}" /></td>
                        <td><c:out value="${empty category.parentCategory ? '-' : category.parentCategory.name}" /></td>
                        <td><span class="badge ${category.active ? 'badge-success' : 'badge-neutral'}">${category.active ? 'ACTIVE' : 'INACTIVE'}</span></td>
                        <td><div class="table-actions"><a class="btn btn-secondary btn-small" href="${ctx}/admin/catalog?editCategory=${category.categoryId}">Sửa</a><form action="${ctx}/admin/catalog" method="post"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="type" value="category"><input type="hidden" name="action" value="toggle"><input type="hidden" name="id" value="${category.categoryId}"><button class="btn btn-small ${category.active ? 'btn-danger' : 'btn-primary'}" type="submit">${category.active ? 'Ẩn' : 'Bật'}</button></form></div></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </section>

    <section class="panel">
        <h2>${empty editBrand ? 'Thêm thương hiệu' : 'Chỉnh sửa thương hiệu'}</h2>
        <form action="${ctx}/admin/catalog" method="post" class="form-grid">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <input type="hidden" name="type" value="brand">
            <input type="hidden" name="action" value="save">
            <input type="hidden" name="id" value="${editBrand.brandId}">
            <div class="field"><label for="brandName">Tên</label><input id="brandName" name="name" maxlength="100" value="<c:out value='${editBrand.name}'/>" required></div>
            <div class="field"><label for="brandSlug">Slug</label><input id="brandSlug" name="slug" maxlength="150" pattern="[a-z0-9]+(-[a-z0-9]+)*" value="<c:out value='${editBrand.slug}'/>" required></div>
            <div class="field full"><label for="logoUrl">Logo URL</label><input id="logoUrl" name="logoUrl" maxlength="500" value="<c:out value='${editBrand.logoUrl}'/>"></div>
            <label class="check-row full"><input type="checkbox" name="active" ${empty editBrand or editBrand.active ? 'checked' : ''}> Đang hoạt động</label>
            <button class="btn btn-primary" type="submit">${empty editBrand ? 'Thêm thương hiệu' : 'Lưu thay đổi'}</button>
            <c:if test="${not empty editBrand}"><a class="btn btn-ghost" href="${ctx}/admin/catalog">Hủy sửa</a></c:if>
        </form>

        <div class="table-wrap subsection">
            <table class="data-table">
                <thead><tr><th>Tên</th><th>Slug</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
                <tbody>
                <c:forEach var="brand" items="${brands}">
                    <tr>
                        <td><c:out value="${brand.name}" /></td>
                        <td><c:out value="${brand.slug}" /></td>
                        <td><span class="badge ${brand.active ? 'badge-success' : 'badge-neutral'}">${brand.active ? 'ACTIVE' : 'INACTIVE'}</span></td>
                        <td><div class="table-actions"><a class="btn btn-secondary btn-small" href="${ctx}/admin/catalog?editBrand=${brand.brandId}">Sửa</a><form action="${ctx}/admin/catalog" method="post"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="type" value="brand"><input type="hidden" name="action" value="toggle"><input type="hidden" name="id" value="${brand.brandId}"><button class="btn btn-small ${brand.active ? 'btn-danger' : 'btn-primary'}" type="submit">${brand.active ? 'Ẩn' : 'Bật'}</button></form></div></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </section>
</div>

<jsp:include page="../components/footer.jsp" />
