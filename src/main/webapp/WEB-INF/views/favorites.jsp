<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Sản phẩm yêu thích" scope="request" />
<c:set var="favoriteBack" value="/favorites" />
<c:set var="showFavoriteQuickAdd" value="true" />
<jsp:include page="components/store-header.jsp" />
<div class="section-head"><div><p class="eyebrow">Dành riêng cho bạn</p><h1>Sản phẩm yêu thích</h1></div></div>
<c:choose><c:when test="${empty productCards}"><section class="panel empty-state"><h2>Danh sách yêu thích đang trống</h2><a class="btn btn-primary" href="${ctx}/home">Khám phá sản phẩm</a></section></c:when><c:otherwise><section class="product-grid"><c:forEach var="card" items="${productCards}"><%@ include file="components/product-card.jspf" %></c:forEach></section></c:otherwise></c:choose>
<jsp:include page="components/store-footer.jsp" />
