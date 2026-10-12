<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Lỗi hệ thống" scope="request" />
<jsp:include page="../components/store-header.jsp" />
<section class="empty-state"><div class="error-code">500</div><h1>Hệ thống đang gặp lỗi</h1><p>Kiểm tra cấu hình tại trang trạng thái hoặc log Tomcat.</p><a class="btn btn-primary" href="${ctx}/health">Kiểm tra hệ thống</a></section>
<jsp:include page="../components/store-footer.jsp" />
