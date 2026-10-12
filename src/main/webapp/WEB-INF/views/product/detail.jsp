<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="${product.name}" scope="request" />
<c:set var="favoriteBack" value="/product?slug=${product.slug}" />
<jsp:include page="../components/store-header.jsp" />

<c:url var="categoryUrl" value="/products"><c:param name="categoryId" value="${product.category.categoryId}" /></c:url>
<nav class="breadcrumb" aria-label="Đường dẫn trang">
    <a href="${ctx}/home">Trang chủ</a><span aria-hidden="true">›</span>
    <a href="${categoryUrl}"><c:out value="${product.category.name}" /></a><span aria-hidden="true">›</span>
    <span aria-current="page"><c:out value="${product.name}" /></span>
</nav>

<c:set var="productMainImage" value="assets/images/product-placeholder.svg" />
<c:if test="${not empty images}"><c:set var="productMainImage" value="${images[0].imageUrl}" /></c:if>
<c:set var="productMainImageSrc" value="${ctx}/${productMainImage}" />
<c:if test="${fn:startsWith(productMainImage, 'http')}"><c:set var="productMainImageSrc" value="${productMainImage}" /></c:if>
<c:set var="mainImage" value="${productMainImage}" />
<c:if test="${not empty selectedVariant && not empty variantImageUrls[selectedVariant.variantId]}"><c:set var="mainImage" value="${variantImageUrls[selectedVariant.variantId]}" /></c:if>
<c:set var="mainImageSrc" value="${ctx}/${mainImage}" />
<c:if test="${fn:startsWith(mainImage, 'http')}"><c:set var="mainImageSrc" value="${mainImage}" /></c:if>

<section class="product-detail-layout">
    <div class="product-gallery" data-product-gallery>
        <div class="gallery-main-wrap">
            <img class="gallery-main" id="productMainImage" src="${mainImageSrc}"
                 data-default-image="${productMainImageSrc}" alt="<c:out value='${product.name}'/>">
        </div>
        <div class="thumb-grid" aria-label="Hình ảnh sản phẩm">
            <c:forEach var="imageItem" items="${images}" varStatus="loop">
                <c:set var="imageSrc" value="${ctx}/${imageItem.imageUrl}" />
                <c:if test="${fn:startsWith(imageItem.imageUrl, 'http')}"><c:set var="imageSrc" value="${imageItem.imageUrl}" /></c:if>
                <button class="gallery-thumb ${imageItem.imageUrl == mainImage ? 'active' : ''}" type="button"
                        data-gallery-thumbnail data-image-url="${imageSrc}"
                        aria-label="Xem ảnh ${loop.count} của ${fn:escapeXml(product.name)}">
                    <img src="${imageSrc}" alt="Ảnh ${loop.count} của <c:out value='${product.name}'/>">
                </button>
            </c:forEach>
        </div>
    </div>

    <div class="detail-copy panel" data-product-purchase data-context-path="${ctx}">
        <p class="eyebrow"><c:out value="${empty product.brand ? 'TechStore' : product.brand.name}" /></p>
        <h1><c:out value="${product.name}" /></h1>
        <p class="product-short-description"><c:out value="${product.shortDescription}" /></p>

        <div class="detail-price-block" aria-live="polite">
            <c:choose>
                <c:when test="${not empty selectedVariant}">
                    <strong class="detail-price" data-detail-price><fmt:formatNumber value="${selectedVariant.price}" pattern="#,##0" /> ₫</strong>
                    <span class="detail-old-price" data-detail-old-price ${empty selectedVariant.originalPrice || selectedVariant.originalPrice <= selectedVariant.price ? 'hidden' : ''}><fmt:formatNumber value="${selectedVariant.originalPrice}" pattern="#,##0" /> ₫</span>
                    <span class="detail-discount" data-detail-discount ${empty selectedVariant.originalPrice || selectedVariant.originalPrice <= selectedVariant.price ? 'hidden' : ''}><c:if test="${not empty selectedVariant.originalPrice && selectedVariant.originalPrice > selectedVariant.price}">Tiết kiệm <fmt:formatNumber value="${(selectedVariant.originalPrice - selectedVariant.price) * 100 / selectedVariant.originalPrice}" maxFractionDigits="0" />%</c:if></span>
                </c:when>
                <c:otherwise><strong class="detail-price" data-detail-price>Liên hệ</strong><span class="detail-old-price" data-detail-old-price hidden></span><span class="detail-discount" data-detail-discount hidden></span></c:otherwise>
            </c:choose>
        </div>

        <form action="${ctx}/cart/add" method="post" data-purchase-form>
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <fieldset class="variant-fieldset">
                <legend>Chọn phiên bản</legend>
                <div class="variant-list">
                    <c:forEach var="variant" items="${variants}">
                        <c:set var="variantImage" value="${variantImageUrls[variant.variantId]}" />
                        <label class="variant-option ${!variant.active || variant.stockQuantity <= 0 ? 'unavailable' : ''}">
                            <input type="radio" name="variantId" value="${variant.variantId}"
                                   data-variant-choice data-price="${variant.price}"
                                   data-original-price="${variant.originalPrice}"
                                   data-stock="${variant.stockQuantity}"
                                   data-image-url="<c:out value='${variantImage}'/>"
                                   ${not empty selectedVariant && selectedVariant.variantId == variant.variantId ? 'checked' : ''}
                                   ${!variant.active || variant.stockQuantity <= 0 ? 'disabled' : ''}>
                            <span class="variant-copy"><strong><c:out value="${variant.variantName}" /></strong><small>SKU: <c:out value="${variant.sku}" /></small></span>
                            <span class="variant-meta"><strong><fmt:formatNumber value="${variant.price}" pattern="#,##0" /> ₫</strong><small>${variant.stockQuantity > 0 && variant.active ? 'Còn hàng' : 'Hết hàng'}</small></span>
                        </label>
                    </c:forEach>
                </div>
            </fieldset>

            <div class="purchase-controls">
                <div class="quantity-field">
                    <label for="quantity">Số lượng</label>
                    <div class="quantity-stepper">
                        <button type="button" data-quantity-minus aria-label="Giảm số lượng" ${empty selectedVariant ? 'disabled' : ''}>−</button>
                        <input id="quantity" name="quantity" type="number" min="1"
                               max="${empty selectedVariant ? 1 : selectedVariant.stockQuantity}" value="1" required ${empty selectedVariant ? 'disabled' : ''}>
                        <button type="button" data-quantity-plus aria-label="Tăng số lượng" ${empty selectedVariant ? 'disabled' : ''}>+</button>
                    </div>
                </div>
                <p class="detail-stock ${empty selectedVariant ? 'out-of-stock' : ''}" data-detail-stock aria-live="polite">
                    <c:choose><c:when test="${not empty selectedVariant}">Còn ${selectedVariant.stockQuantity} sản phẩm</c:when><c:otherwise>Sản phẩm đang tạm hết hàng</c:otherwise></c:choose>
                </p>
            </div>

            <div class="purchase-actions">
                <c:choose>
                    <c:when test="${empty sessionScope.user}">
                        <a class="btn btn-buy-now" href="${ctx}/login">Mua ngay</a>
                        <a class="btn btn-primary" href="${ctx}/login">Đăng nhập để thêm giỏ</a>
                    </c:when>
                    <c:otherwise>
                        <button class="btn btn-buy-now" type="submit" name="next" value="checkout" ${empty selectedVariant ? 'disabled' : ''}>Mua ngay</button>
                        <button class="btn btn-primary" type="submit" name="next" value="cart" ${empty selectedVariant ? 'disabled' : ''}>Thêm vào giỏ hàng</button>
                    </c:otherwise>
                </c:choose>
            </div>
        </form>

        <div class="purchase-policies" aria-label="Chính sách mua hàng">
            <article><span aria-hidden="true">✓</span><div><strong>Bảo hành chính hãng</strong><small>Hỗ trợ đổi trả theo chính sách</small></div></article>
            <article><span aria-hidden="true">⌁</span><div><strong>Giao hàng toàn quốc</strong><small>Kiểm tra sản phẩm khi nhận hàng</small></div></article>
            <article><span aria-hidden="true">▣</span><div><strong>Thanh toán an toàn</strong><small>Hỗ trợ COD và VNPay</small></div></article>
        </div>
    </div>
</section>

<div class="detail-information-grid subsection">
    <section class="panel product-description-section">
        <p class="eyebrow">Thông tin sản phẩm</p><h2>Mô tả sản phẩm</h2>
        <c:choose>
            <c:when test="${empty descriptionParagraphs}"><p class="muted">Nội dung mô tả đang được cập nhật.</p></c:when>
            <c:otherwise><div class="product-description"><c:forEach var="paragraph" items="${descriptionParagraphs}"><p><c:out value="${paragraph}" /></p></c:forEach></div></c:otherwise>
        </c:choose>
    </section>
    <section class="panel product-spec-section">
        <p class="eyebrow">Cấu hình</p><h2>Thông số kỹ thuật</h2>
        <div class="spec-table-wrap"><table class="spec-table"><tbody><c:forEach var="spec" items="${specifications}"><tr><th><c:out value="${spec.specificationName}" /></th><td><c:out value="${spec.specificationValue}" /></td></tr></c:forEach><c:if test="${empty specifications}"><tr><td colspan="2">Chưa cập nhật thông số.</td></tr></c:if></tbody></table></div>
    </section>
</div>

<c:if test="${not empty relatedProducts}">
    <section class="home-block related-products">
        <div class="section-head home-section-head"><div><p class="eyebrow">Có thể bạn sẽ thích</p><h2>Sản phẩm liên quan</h2></div><a class="section-more" href="${categoryUrl}">Xem tất cả →</a></div>
        <div class="product-grid"><c:forEach var="card" items="${relatedProducts}"><%@ include file="../components/product-card.jspf" %></c:forEach></div>
    </section>
</c:if>

<jsp:include page="../components/store-footer.jsp" />
