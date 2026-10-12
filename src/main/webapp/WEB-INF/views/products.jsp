<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Tất cả sản phẩm — TechStore" scope="request" />
<c:set var="favoriteBack" value="/products" />
<jsp:include page="components/store-header.jsp" />

<div class="catalog-heading">
    <div>
        <p class="eyebrow">Khám phá sản phẩm</p>
        <h1>Tất cả sản phẩm</h1>
        <p class="muted">Tìm thiết bị phù hợp theo danh mục, thương hiệu và khoảng giá.</p>
    </div>
    <a class="btn btn-ghost" href="${ctx}/home">Về trang chủ</a>
</div>

<div class="catalog-layout">
    <aside class="panel catalog-sidebar" id="catalogFilter" aria-label="Bộ lọc sản phẩm">
        <div class="catalog-filter-head">
            <div><p class="eyebrow">Tìm nhanh</p><h2>Bộ lọc</h2></div>
            <button type="button" data-filter-close aria-label="Đóng bộ lọc">×</button>
        </div>
        <form class="catalog-filter-form" action="${ctx}/products" method="get">
            <div class="field">
                <label for="q">Tìm sản phẩm</label>
                <input id="q" name="q" type="search" maxlength="150"
                       value="<c:out value='${param.q}'/>" placeholder="iPhone, MacBook, tai nghe...">
            </div>
            <div class="field">
                <label for="categoryId">Danh mục</label>
                <select id="categoryId" name="categoryId">
                    <option value="">Tất cả danh mục</option>
                    <c:forEach var="category" items="${categories}"><option value="${category.categoryId}" ${param.categoryId == category.categoryId ? 'selected' : ''}><c:out value="${category.name}" /></option></c:forEach>
                </select>
            </div>
            <div class="field">
                <label for="brandId">Thương hiệu</label>
                <select id="brandId" name="brandId">
                    <option value="">Tất cả thương hiệu</option>
                    <c:forEach var="brand" items="${brands}"><option value="${brand.brandId}" ${param.brandId == brand.brandId ? 'selected' : ''}><c:out value="${brand.name}" /></option></c:forEach>
                </select>
            </div>
            <fieldset class="price-filter">
                <legend>Khoảng giá</legend>
                <div class="price-filter-grid">
                    <div class="field"><label for="minPrice">Từ</label><input id="minPrice" name="minPrice" type="number" min="0" step="1000" value="<c:out value='${param.minPrice}'/>" placeholder="0"></div>
                    <div class="field"><label for="maxPrice">Đến</label><input id="maxPrice" name="maxPrice" type="number" min="0" step="1000" value="<c:out value='${param.maxPrice}'/>" placeholder="50.000.000"></div>
                </div>
            </fieldset>
            <div class="field">
                <label for="sort">Sắp xếp</label>
                <select id="sort" name="sort">
                    <option value="latest" ${sort == 'latest' ? 'selected' : ''}>Mới nhất</option>
                    <option value="price_asc" ${sort == 'price_asc' ? 'selected' : ''}>Giá thấp đến cao</option>
                    <option value="price_desc" ${sort == 'price_desc' ? 'selected' : ''}>Giá cao đến thấp</option>
                </select>
            </div>
            <div class="catalog-filter-actions">
                <button class="btn btn-primary btn-block" type="submit">Áp dụng bộ lọc</button>
                <c:if test="${hasCatalogFilters}"><a class="filter-clear-link" href="${ctx}/products">Xóa tất cả</a></c:if>
            </div>
        </form>
    </aside>
    <button class="catalog-filter-overlay" type="button" data-filter-close aria-label="Đóng bộ lọc"></button>

    <section class="catalog-results" aria-labelledby="catalogResultTitle">
        <div class="catalog-toolbar">
            <div>
                <p class="eyebrow">Kết quả</p>
                <h2 id="catalogResultTitle"><fmt:formatNumber value="${totalProducts}" pattern="#,##0" /> sản phẩm phù hợp</h2>
            </div>
            <button class="btn btn-ghost catalog-filter-toggle" type="button" data-filter-toggle
                    aria-controls="catalogFilter" aria-expanded="false">☷ Bộ lọc</button>
        </div>

        <c:if test="${hasCatalogFilters}">
            <c:url var="removeKeywordUrl" value="/products"><c:param name="categoryId" value="${param.categoryId}"/><c:param name="brandId" value="${param.brandId}"/><c:param name="minPrice" value="${param.minPrice}"/><c:param name="maxPrice" value="${param.maxPrice}"/><c:param name="sort" value="${sort}"/></c:url>
            <c:url var="removeCategoryUrl" value="/products"><c:param name="q" value="${param.q}"/><c:param name="brandId" value="${param.brandId}"/><c:param name="minPrice" value="${param.minPrice}"/><c:param name="maxPrice" value="${param.maxPrice}"/><c:param name="sort" value="${sort}"/></c:url>
            <c:url var="removeBrandUrl" value="/products"><c:param name="q" value="${param.q}"/><c:param name="categoryId" value="${param.categoryId}"/><c:param name="minPrice" value="${param.minPrice}"/><c:param name="maxPrice" value="${param.maxPrice}"/><c:param name="sort" value="${sort}"/></c:url>
            <c:url var="removeMinPriceUrl" value="/products"><c:param name="q" value="${param.q}"/><c:param name="categoryId" value="${param.categoryId}"/><c:param name="brandId" value="${param.brandId}"/><c:param name="maxPrice" value="${param.maxPrice}"/><c:param name="sort" value="${sort}"/></c:url>
            <c:url var="removeMaxPriceUrl" value="/products"><c:param name="q" value="${param.q}"/><c:param name="categoryId" value="${param.categoryId}"/><c:param name="brandId" value="${param.brandId}"/><c:param name="minPrice" value="${param.minPrice}"/><c:param name="sort" value="${sort}"/></c:url>
            <c:url var="removeSortUrl" value="/products"><c:param name="q" value="${param.q}"/><c:param name="categoryId" value="${param.categoryId}"/><c:param name="brandId" value="${param.brandId}"/><c:param name="minPrice" value="${param.minPrice}"/><c:param name="maxPrice" value="${param.maxPrice}"/></c:url>
            <div class="applied-filters" aria-label="Bộ lọc đang áp dụng">
                <span class="applied-filters-label">Đang lọc:</span>
                <c:if test="${not empty param.q}"><a class="filter-chip" href="${removeKeywordUrl}" title="Xóa từ khóa">“<c:out value="${param.q}" />” <span aria-hidden="true">×</span></a></c:if>
                <c:if test="${not empty param.categoryId}"><a class="filter-chip" href="${removeCategoryUrl}" title="Xóa danh mục"><c:out value="${selectedCategoryName}" /> <span aria-hidden="true">×</span></a></c:if>
                <c:if test="${not empty param.brandId}"><a class="filter-chip" href="${removeBrandUrl}" title="Xóa thương hiệu"><c:out value="${selectedBrandName}" /> <span aria-hidden="true">×</span></a></c:if>
                <c:if test="${not empty param.minPrice}"><a class="filter-chip" href="${removeMinPriceUrl}" title="Xóa giá tối thiểu">Từ <fmt:formatNumber value="${param.minPrice}" pattern="#,##0" /> ₫ <span aria-hidden="true">×</span></a></c:if>
                <c:if test="${not empty param.maxPrice}"><a class="filter-chip" href="${removeMaxPriceUrl}" title="Xóa giá tối đa">Đến <fmt:formatNumber value="${param.maxPrice}" pattern="#,##0" /> ₫ <span aria-hidden="true">×</span></a></c:if>
                <c:if test="${sort != 'latest'}"><a class="filter-chip" href="${removeSortUrl}" title="Bỏ sắp xếp">${sort == 'price_asc' ? 'Giá tăng dần' : 'Giá giảm dần'} <span aria-hidden="true">×</span></a></c:if>
                <a class="clear-all-filters" href="${ctx}/products">Xóa tất cả</a>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty productCards}">
                <section class="panel empty-state"><h2>Chưa tìm thấy sản phẩm phù hợp</h2><p class="muted">Thử thay đổi từ khóa, danh mục hoặc khoảng giá.</p><a class="btn btn-primary" href="${ctx}/products">Xóa bộ lọc</a></section>
            </c:when>
            <c:otherwise>
                <div class="product-grid"><c:forEach var="card" items="${productCards}"><%@ include file="components/product-card.jspf" %></c:forEach></div>
            </c:otherwise>
        </c:choose>

        <c:if test="${pageCount > 1}"><nav class="pagination" aria-label="Phân trang"><c:forEach begin="1" end="${pageCount}" var="p"><c:url var="pageUrl" value="/products"><c:param name="page" value="${p}"/><c:param name="q" value="${param.q}"/><c:param name="categoryId" value="${param.categoryId}"/><c:param name="brandId" value="${param.brandId}"/><c:param name="minPrice" value="${param.minPrice}"/><c:param name="maxPrice" value="${param.maxPrice}"/><c:param name="sort" value="${sort}"/></c:url><a class="${p == currentPage ? 'active' : ''}" href="${pageUrl}" aria-label="Trang ${p}" aria-current="${p == currentPage ? 'page' : 'false'}">${p}</a></c:forEach></nav></c:if>
    </section>
</div>
<jsp:include page="components/store-footer.jsp" />
