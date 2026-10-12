<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Không tìm thấy" scope="request" />
<jsp:include page="../components/store-header.jsp" />
<section class="empty-state"><div class="error-code">404</div><h1>Không tìm thấy trang hoặc dữ liệu</h1><a class="btn btn-primary" href="${ctx}/home">Về trang chủ</a></section>
<jsp:include page="../components/store-footer.jsp" />
