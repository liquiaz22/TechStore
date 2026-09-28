<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="${product.name}" scope="request" />
<jsp:include page="../components/header.jsp" />
<section class="detail-grid">
    <div>
        <c:set var="mainImage" value="assets/images/product-placeholder.svg" />
        <c:if test="${not empty images}"><c:set var="mainImage" value="${images[0].imageUrl}" /></c:if>
        <c:choose><c:when test="${fn:startsWith(mainImage, 'http')}"><img class="gallery-main" src="${mainImage}" alt="<c:out value='${product.name}'/>"></c:when><c:otherwise><img class="gallery-main" src="${ctx}/${mainImage}" alt="<c:out value='${product.name}'/>"></c:otherwise></c:choose>
        <div class="thumb-grid"><c:forEach var="imageItem" items="${images}"><c:choose><c:when test="${fn:startsWith(imageItem.imageUrl, 'http')}"><img src="${imageItem.imageUrl}" alt="Ảnh sản phẩm"></c:when><c:otherwise><img src="${ctx}/${imageItem.imageUrl}" alt="Ảnh sản phẩm"></c:otherwise></c:choose></c:forEach></div>
    </div>
    <div class="detail-copy panel">
        <p class="eyebrow"><c:out value="${empty product.brand ? 'TechStore' : product.brand.name}" /></p>
        <h1><c:out value="${product.name}" /></h1>
        <p class="muted"><c:out value="${product.shortDescription}" /></p>
        <form action="${ctx}/cart/add" method="post">
            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
            <div class="variant-list">
                <c:forEach var="variant" items="${variants}" varStatus="loop"><label class="variant-option"><input type="radio" name="variantId" value="${variant.variantId}" ${loop.first ? 'checked' : ''} ${!variant.active || variant.stockQuantity <= 0 ? 'disabled' : ''}><span><strong><c:out value="${variant.variantName}" /></strong><br><small class="muted">SKU: <c:out value="${variant.sku}" /> · Còn ${variant.stockQuantity}</small></span><span class="money"><fmt:formatNumber value="${variant.price}" pattern="#,##0" /> ₫</span></label></c:forEach>
            </div>
            <div class="field"><label for="quantity">Số lượng</label><input class="quantity-input" id="quantity" name="quantity" type="number" min="1" value="1" required></div>
            <c:choose><c:when test="${empty sessionScope.user}"><a class="btn btn-primary btn-block" href="${ctx}/login">Đăng nhập để mua hàng</a></c:when><c:otherwise><button class="btn btn-primary btn-block" type="submit" ${empty variants ? 'disabled' : ''}>Thêm vào giỏ hàng</button></c:otherwise></c:choose>
        </form>
    </div>
</section>
<section class="panel subsection"><h2>Mô tả sản phẩm</h2><p><c:out value="${product.description}" /></p></section>
<section class="panel subsection"><h2>Thông số kỹ thuật</h2><table class="spec-table"><tbody><c:forEach var="spec" items="${specifications}"><tr><th><c:out value="${spec.specificationName}" /></th><td><c:out value="${spec.specificationValue}" /></td></tr></c:forEach><c:if test="${empty specifications}"><tr><td>Chưa cập nhật thông số.</td></tr></c:if></tbody></table></section>
<jsp:include page="../components/footer.jsp" />
