<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Giỏ hàng" scope="request" />
<jsp:include page="components/header.jsp" />
<div class="section-head"><div><p class="eyebrow">Sẵn sàng đặt hàng</p><h1>Giỏ hàng</h1></div><a class="btn btn-ghost" href="${ctx}/home">Tiếp tục mua sắm</a></div>
<c:choose>
    <c:when test="${empty cartItems}"><section class="panel empty-state"><h2>Giỏ hàng đang trống</h2><p class="muted">Thêm một thiết bị ông thích rồi quay lại đây.</p><a class="btn btn-primary" href="${ctx}/home">Xem sản phẩm</a></section></c:when>
    <c:otherwise>
        <section class="panel table-wrap"><table class="data-table"><thead><tr><th>Sản phẩm</th><th>Đơn giá</th><th>Số lượng</th><th>Thành tiền</th><th></th></tr></thead><tbody>
        <c:forEach var="item" items="${cartItems}"><tr><td><div class="table-product"><img src="${ctx}/assets/images/product-placeholder.svg" alt="Sản phẩm"><div><strong><c:out value="${item.variant.product.name}" /></strong><br><span class="muted"><c:out value="${item.variant.variantName}" /> · <c:out value="${item.variant.sku}" /></span></div></div></td><td class="money"><fmt:formatNumber value="${item.variant.price}" pattern="#,##0" /> ₫</td><td><form action="${ctx}/cart/update" method="post" class="inline-form"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="variantId" value="${item.variant.variantId}"><input class="quantity-input" name="quantity" type="number" min="1" max="${item.variant.stockQuantity}" value="${item.quantity}" required><button class="btn btn-secondary btn-small" type="submit">Cập nhật</button></form></td><td class="money"><fmt:formatNumber value="${item.variant.price * item.quantity}" pattern="#,##0" /> ₫</td><td><form action="${ctx}/cart/remove" method="post"><input type="hidden" name="_csrf" value="${sessionScope.csrfToken}"><input type="hidden" name="variantId" value="${item.variant.variantId}"><button class="btn btn-danger btn-small" type="submit" data-confirm="Xóa sản phẩm này khỏi giỏ?">Xóa</button></form></td></tr></c:forEach>
        </tbody></table></section>
        <section class="panel summary-card subsection"><div class="summary-line"><span>Tạm tính</span><strong><fmt:formatNumber value="${subtotal}" pattern="#,##0" /> ₫</strong></div><div class="summary-line"><span>Phí vận chuyển</span><span>Miễn phí</span></div><div class="summary-line summary-total"><strong>Tổng dự kiến</strong><strong class="price"><fmt:formatNumber value="${subtotal}" pattern="#,##0" /> ₫</strong></div><a class="btn btn-primary btn-block" href="${ctx}/checkout">Tiến hành đặt hàng</a></section>
    </c:otherwise>
</c:choose>
<jsp:include page="components/footer.jsp" />
