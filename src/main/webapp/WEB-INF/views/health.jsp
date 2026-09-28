<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Trạng thái hệ thống" scope="request" />
<jsp:include page="components/header.jsp" />
<section class="narrow-section">
    <div class="panel health-panel">
        <h1>Trạng thái hệ thống</h1>
        <p>Ứng dụng: <strong class="status-ok">Hoạt động</strong></p>
        <p>SQL Server:
            <c:choose>
                <c:when test="${databaseOk}"><strong class="status-ok">Đã kết nối</strong></c:when>
                <c:otherwise><strong class="status-bad">Chưa kết nối</strong></c:otherwise>
            </c:choose>
        </p>
        <c:if test="${not empty healthError}">
            <pre class="error-detail"><c:out value="${healthError}" /></pre>
        </c:if>
    </div>
</section>
<jsp:include page="components/footer.jsp" />
