<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Sản phẩm yêu thích" scope="request" />
<jsp:include page="components/header.jsp" />
<div class="section-head"><div><p class="eyebrow">Của riêng ông</p><h1>Sản phẩm yêu thích</h1></div></div>
<c:choose><c:when test="${empty productCards}"><section class="panel empty-state"><h2>Danh sách yêu thích đang trống</h2><a class="btn btn-primary" href="${ctx}/home">Khám phá sản phẩm</a></section></c:when><c:otherwise><section class="product-grid"><c:forEach var="card" items="${productCards}"><article class="product-card"><c:choose><c:when test="${fn:startsWith(card.imageUrl, 'http')}"><img class="product-image" src="${card.imageUrl}" alt="Sản phẩm"></c:when><c:otherwise><img class="product-image" src="${ctx}/${card.imageUrl}" alt="Sản phẩm"></c:otherwise></c:choose><div class="product-body"><p class="product-brand"><c:out value="${card.brandName}" /></p><h3 class="product-title"><c:out value="${card.name}" /></h3><div class="price-row"><span class="price"><fmt:formatNumber value="${card.price}" pattern="#,##0" /> ₫</span></div><div class="card-actions"><a class="btn btn-secondary" href="${ctx}/product?slug=${card.slug}">Chi tiết</a><form action="${ctx}/favorites/toggle" method="post"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="productId" value="${card.productId}"><button class="btn btn-danger" type="submit">Bỏ thích</button></form></div></div></article></c:forEach></section></c:otherwise></c:choose>
<jsp:include page="components/footer.jsp" />
