<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Không có quyền truy cập" scope="request" />
<jsp:include page="../components/store-header.jsp" />
<section class="empty-state"><div class="error-code">403</div><h1>Bạn không có quyền truy cập trang này</h1><a class="btn btn-primary" href="${ctx}/home">Về trang chủ</a></section>
<jsp:include page="../components/store-footer.jsp" />
