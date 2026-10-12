<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="TechStore — Công nghệ chính hãng" scope="request" />
<c:set var="favoriteBack" value="/home" />
<jsp:include page="components/store-header.jsp" />

<section class="hero home-hero">
    <div class="hero-copy">
        <p class="eyebrow">Công nghệ chính hãng</p>
        <h1>Thiết bị đúng nhu cầu,<br>trải nghiệm đúng chất.</h1>
        <p>Điện thoại, máy tính bảng, laptop và phụ kiện được cập nhật giá và tồn kho trực tiếp từ hệ thống.</p>
        <div class="hero-actions"><a class="btn hero-primary-btn" href="${ctx}/products">Khám phá sản phẩm</a><a class="btn hero-secondary-btn" href="#featuredProducts">Sản phẩm mới</a></div>
    </div>
    <div class="hero-product" aria-hidden="true">
        <c:choose>
            <c:when test="${not empty featuredProducts}"><c:set var="heroProduct" value="${featuredProducts[0]}" /><div class="hero-product-glow"></div><c:choose><c:when test="${fn:startsWith(heroProduct.imageUrl, 'http')}"><img src="${heroProduct.imageUrl}" alt="Sản phẩm nổi bật: <c:out value='${heroProduct.name}'/>"></c:when><c:otherwise><img src="${ctx}/${heroProduct.imageUrl}" alt="Sản phẩm nổi bật: <c:out value='${heroProduct.name}'/>"></c:otherwise></c:choose><div class="hero-product-label"><span>Mới tại TechStore</span><strong><c:out value="${heroProduct.name}" /></strong></div></c:when>
            <c:otherwise><div class="hero-device-placeholder">TS</div></c:otherwise>
        </c:choose>
    </div>
</section>

<section class="store-benefits" aria-label="Cam kết của TechStore">
    <article><span class="benefit-icon" aria-hidden="true">✓</span><div><strong>Hàng chính hãng</strong><small>Nguồn gốc rõ ràng</small></div></article>
    <article><span class="benefit-icon" aria-hidden="true">⌁</span><div><strong>Giao hàng miễn phí</strong><small>Trên toàn quốc</small></div></article>
    <article><span class="benefit-icon" aria-hidden="true">↻</span><div><strong>Bảo hành minh bạch</strong><small>Thông tin dễ kiểm tra</small></div></article>
    <article><span class="benefit-icon" aria-hidden="true">◇</span><div><strong>Thanh toán an toàn</strong><small>COD hoặc VNPay</small></div></article>
</section>

<section class="home-block">
    <div class="section-head home-section-head"><div><p class="eyebrow">Mua sắm nhanh</p><h2>Danh mục nổi bật</h2></div><a class="section-more" href="${ctx}/products">Xem tất cả <span aria-hidden="true">→</span></a></div>
    <div class="category-showcase">
        <c:forEach var="category" items="${homeCategories}">
            <c:url var="categoryUrl" value="/products"><c:param name="categoryId" value="${category.categoryId}" /></c:url>
            <a class="category-tile category-${category.slug}" href="${categoryUrl}">
                <span class="category-icon" aria-hidden="true">
                    <c:choose>
                        <c:when test="${category.slug == 'dien-thoai'}"><svg viewBox="0 0 64 64"><rect x="19" y="6" width="26" height="52" rx="6"/><path d="M27 12h10M29 51h6"/></svg></c:when>
                        <c:when test="${category.slug == 'laptop'}"><svg viewBox="0 0 64 64"><rect x="11" y="10" width="42" height="32" rx="3"/><path d="M6 48h52l-4 6H10l-4-6Z"/></svg></c:when>
                        <c:when test="${category.slug == 'may-tinh-bang'}"><svg viewBox="0 0 64 64"><rect x="13" y="7" width="38" height="50" rx="5"/><circle cx="32" cy="51" r="1"/></svg></c:when>
                        <c:otherwise><svg viewBox="0 0 64 64"><path d="M14 23h12v18H14a9 9 0 0 1-9-9 9 9 0 0 1 9-9Zm36 0H38v18h12a9 9 0 0 0 9-9 9 9 0 0 0-9-9Z"/><path d="M26 28h12v8H26z"/></svg></c:otherwise>
                    </c:choose>
                </span>
                <span><strong><c:out value="${category.name}" /></strong><small>Xem sản phẩm</small></span>
                <span class="category-arrow" aria-hidden="true">→</span>
            </a>
        </c:forEach>
    </div>
</section>

<section class="home-block" id="featuredProducts">
    <div class="section-head home-section-head"><div><p class="eyebrow">Vừa cập nhật</p><h2>Sản phẩm mới tại TechStore</h2></div><a class="section-more" href="${ctx}/products?sort=latest">Xem tất cả <span aria-hidden="true">→</span></a></div>
    <c:choose>
        <c:when test="${empty featuredProducts}"><div class="panel empty-state"><h3>Chưa có sản phẩm để hiển thị</h3><p class="muted">Dữ liệu sẽ xuất hiện sau khi sản phẩm được kích hoạt.</p></div></c:when>
        <c:otherwise><div class="product-grid home-product-grid"><c:forEach var="card" items="${featuredProducts}"><%@ include file="components/product-card.jspf" %></c:forEach></div></c:otherwise>
    </c:choose>
</section>

<c:forEach var="section" items="${homeSections}">
    <section class="home-block category-product-section">
        <div class="section-head home-section-head"><div><p class="eyebrow">Gợi ý dành cho bạn</p><h2><c:out value="${section.categoryName}" /> nổi bật</h2></div><c:url var="sectionUrl" value="/products"><c:param name="categoryId" value="${section.categoryId}" /></c:url><a class="section-more" href="${sectionUrl}">Xem tất cả <span aria-hidden="true">→</span></a></div>
        <div class="product-grid"><c:forEach var="card" items="${section.products}"><%@ include file="components/product-card.jspf" %></c:forEach></div>
    </section>
</c:forEach>

<jsp:include page="components/store-footer.jsp" />
