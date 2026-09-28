<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="TechStore — Công nghệ chính hãng" scope="request" />
<jsp:include page="components/header.jsp" />
<section class="hero">
    <div><p class="eyebrow">Công nghệ cho mọi ngày</p><h1>Chọn thiết bị đúng gu, đúng nhu cầu.</h1><p>Điện thoại, iPad, laptop và phụ kiện chính hãng trong một trải nghiệm mua sắm gọn gàng.</p></div>
    <div class="hero-stat"><span>Sản phẩm đang hiển thị</span><strong>${fn:length(productCards)}</strong><small>Giá và tồn kho được kiểm tra từ hệ thống.</small></div>
</section>

<section class="panel filter-panel">
    <form class="filter-grid" action="${ctx}/home" method="get">
        <div class="field"><label for="q">Tìm sản phẩm</label><input id="q" name="q" value="<c:out value='${param.q}'/>" placeholder="iPhone, MacBook, tai nghe..."></div>
        <div class="field"><label for="categoryId">Danh mục</label><select id="categoryId" name="categoryId"><option value="">Tất cả</option><c:forEach var="category" items="${categories}"><option value="${category.categoryId}" ${param.categoryId == category.categoryId ? 'selected' : ''}><c:out value="${category.name}" /></option></c:forEach></select></div>
        <div class="field"><label for="brandId">Thương hiệu</label><select id="brandId" name="brandId"><option value="">Tất cả</option><c:forEach var="brand" items="${brands}"><option value="${brand.brandId}" ${param.brandId == brand.brandId ? 'selected' : ''}><c:out value="${brand.name}" /></option></c:forEach></select></div>
        <div class="field"><label for="minPrice">Giá từ</label><input id="minPrice" name="minPrice" type="number" min="0" step="1000" value="<c:out value='${param.minPrice}'/>"></div>
        <div class="field"><label for="maxPrice">Giá đến</label><input id="maxPrice" name="maxPrice" type="number" min="0" step="1000" value="<c:out value='${param.maxPrice}'/>"></div>
        <div class="field"><label for="sort">Sắp xếp</label><select id="sort" name="sort"><option value="latest" ${sort == 'latest' ? 'selected' : ''}>Mới nhất</option><option value="price_asc" ${sort == 'price_asc' ? 'selected' : ''}>Giá thấp đến cao</option><option value="price_desc" ${sort == 'price_desc' ? 'selected' : ''}>Giá cao đến thấp</option></select></div>
        <button class="btn btn-primary" type="submit">Lọc</button>
    </form>
</section>

<div class="section-head"><div><p class="eyebrow">Danh sách</p><h2>Sản phẩm công nghệ</h2></div></div>
<c:choose>
    <c:when test="${empty productCards}"><section class="panel empty-state"><h2>Chưa tìm thấy sản phẩm phù hợp</h2><p class="muted">Thử thay đổi từ khóa hoặc khoảng giá.</p></section></c:when>
    <c:otherwise>
        <section class="product-grid">
            <c:forEach var="card" items="${productCards}">
                <article class="product-card">
                    <a href="${ctx}/product?slug=${card.slug}">
                        <c:choose><c:when test="${fn:startsWith(card.imageUrl, 'http')}"><img class="product-image" src="${card.imageUrl}" alt="<c:out value='${card.name}'/>"></c:when><c:otherwise><img class="product-image" src="${ctx}/${card.imageUrl}" alt="<c:out value='${card.name}'/>"></c:otherwise></c:choose>
                    </a>
                    <div class="product-body">
                        <p class="product-brand"><c:out value="${empty card.brandName ? 'TechStore' : card.brandName}" /></p>
                        <h3 class="product-title"><a href="${ctx}/product?slug=${card.slug}"><c:out value="${card.name}" /></a></h3>
                        <div class="price-row"><span class="price"><fmt:formatNumber value="${card.price}" pattern="#,##0" /> ₫</span><c:if test="${not empty card.originalPrice}"><span class="old-price"><fmt:formatNumber value="${card.originalPrice}" pattern="#,##0" /> ₫</span></c:if></div>
                        <p><span class="badge ${card.inStock ? 'badge-success' : 'badge-danger'}">${card.inStock ? 'Còn hàng' : 'Hết hàng'}</span></p>
                        <div class="card-actions"><a class="btn btn-secondary" href="${ctx}/product?slug=${card.slug}">Xem chi tiết</a><c:if test="${not empty sessionScope.user}"><form action="${ctx}/favorites/toggle" method="post" class="inline-form"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="productId" value="${card.productId}"><input type="hidden" name="back" value="/home"><button class="btn btn-ghost" type="submit" title="Yêu thích">♡</button></form></c:if></div>
                    </div>
                </article>
            </c:forEach>
        </section>
    </c:otherwise>
</c:choose>

<c:if test="${pageCount > 1}"><nav class="pagination" aria-label="Phân trang"><c:forEach begin="1" end="${pageCount}" var="p"><c:url var="pageUrl" value="/home"><c:param name="page" value="${p}"/><c:param name="q" value="${param.q}"/><c:param name="categoryId" value="${param.categoryId}"/><c:param name="brandId" value="${param.brandId}"/><c:param name="minPrice" value="${param.minPrice}"/><c:param name="maxPrice" value="${param.maxPrice}"/><c:param name="sort" value="${sort}"/></c:url><a class="${p == currentPage ? 'active' : ''}" href="${pageUrl}">${p}</a></c:forEach></nav></c:if>
<jsp:include page="components/footer.jsp" />
