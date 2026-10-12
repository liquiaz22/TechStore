<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Giỏ hàng" scope="request" />
<jsp:include page="components/store-header.jsp" />

<div class="section-head cart-page-head">
    <div><p class="eyebrow">Sẵn sàng đặt hàng</p><h1>Giỏ hàng</h1><p class="muted">Kiểm tra phiên bản và số lượng trước khi thanh toán.</p></div>
    <a class="btn btn-ghost" href="${ctx}/products">← Tiếp tục mua sắm</a>
</div>

<c:choose>
    <c:when test="${empty cartItems}">
        <section class="panel empty-state"><h2>Giỏ hàng đang trống</h2><p class="muted">Thêm một thiết bị bạn thích rồi quay lại đây.</p><a class="btn btn-primary" href="${ctx}/products">Xem sản phẩm</a></section>
    </c:when>
    <c:otherwise>
        <div class="cart-layout" data-cart>
            <section class="cart-items" aria-label="Sản phẩm trong giỏ hàng">
                <div class="cart-list-head" aria-hidden="true"><span>Sản phẩm</span><span>Đơn giá</span><span>Số lượng</span><span>Thành tiền</span><span></span></div>
                <c:forEach var="item" items="${cartItems}">
                    <c:url var="cartProductUrl" value="/product"><c:param name="slug" value="${item.variant.product.slug}" /></c:url>
                    <c:set var="cartImageUrl" value="${cartItemImageUrls[item.variant.variantId]}" />
                    <article class="cart-item-card" data-cart-item data-unit-price="${item.variant.price}" data-stock="${item.variant.stockQuantity}">
                        <a class="cart-product-image" href="${cartProductUrl}" aria-label="Xem ${fn:escapeXml(item.variant.product.name)}">
                            <c:choose><c:when test="${fn:startsWith(cartImageUrl, 'http')}"><img src="${cartImageUrl}" alt="<c:out value='${item.variant.product.name}'/>"></c:when><c:otherwise><img src="${ctx}/${cartImageUrl}" alt="<c:out value='${item.variant.product.name}'/>"></c:otherwise></c:choose>
                        </a>
                        <div class="cart-product-copy">
                            <a href="${cartProductUrl}"><strong><c:out value="${item.variant.product.name}" /></strong></a>
                            <span><c:out value="${item.variant.variantName}" /></span>
                            <small>SKU: <c:out value="${item.variant.sku}" /></small>
                            <a class="cart-detail-link" href="${cartProductUrl}">Xem chi tiết sản phẩm →</a>
                        </div>
                        <div class="cart-unit-price"><span class="cart-mobile-label">Đơn giá</span><strong><fmt:formatNumber value="${item.variant.price}" pattern="#,##0" /> ₫</strong></div>
                        <form action="${ctx}/cart/update" method="post" class="cart-quantity-form" data-cart-quantity-form data-initial-quantity="${item.quantity}">
                            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                            <input type="hidden" name="variantId" value="${item.variant.variantId}">
                            <span class="cart-mobile-label">Số lượng</span>
                            <div class="quantity-stepper cart-quantity-stepper">
                                <button type="button" data-cart-minus aria-label="Giảm số lượng ${fn:escapeXml(item.variant.product.name)}">−</button>
                                <input name="quantity" type="number" min="1" max="${item.variant.stockQuantity > 0 ? item.variant.stockQuantity : 1}" value="${item.quantity}" required data-cart-quantity ${item.variant.stockQuantity <= 0 ? 'disabled' : ''}>
                                <button type="button" data-cart-plus aria-label="Tăng số lượng ${fn:escapeXml(item.variant.product.name)}" ${item.quantity >= item.variant.stockQuantity ? 'disabled' : ''}>+</button>
                            </div>
                            <small class="cart-stock ${item.variant.stockQuantity <= 0 ? 'out-of-stock' : ''}"><c:choose><c:when test="${item.variant.stockQuantity > 0}">Còn ${item.variant.stockQuantity} sản phẩm</c:when><c:otherwise>Đã hết hàng</c:otherwise></c:choose></small>
                            <button class="cart-save-button" type="submit" ${item.variant.stockQuantity <= 0 ? 'disabled' : ''}>Lưu thay đổi</button>
                        </form>
                        <div class="cart-line-total"><span class="cart-mobile-label">Thành tiền</span><strong data-cart-line-total><fmt:formatNumber value="${item.variant.price * item.quantity}" pattern="#,##0" /> ₫</strong></div>
                        <form action="${ctx}/cart/remove" method="post" class="cart-remove-form">
                            <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                            <input type="hidden" name="variantId" value="${item.variant.variantId}">
                            <button class="cart-remove-button" type="submit" data-confirm="Xóa sản phẩm này khỏi giỏ?" aria-label="Xóa ${fn:escapeXml(item.variant.product.name)} khỏi giỏ" title="Xóa khỏi giỏ">
                                <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M4 7h16M9 7V4h6v3m-8 0 1 13h8l1-13M10 11v5m4-5v5" /></svg>
                            </button>
                        </form>
                    </article>
                </c:forEach>
            </section>

            <aside class="panel cart-summary">
                <p class="eyebrow">Tóm tắt đơn hàng</p><h2>Thanh toán</h2>
                <div class="summary-line"><span>Tạm tính</span><strong data-cart-subtotal><fmt:formatNumber value="${subtotal}" pattern="#,##0" /> ₫</strong></div>
                <div class="summary-line"><span>Phí vận chuyển</span><span class="free-shipping">Miễn phí</span></div>
                <div class="summary-line summary-total"><strong>Tổng dự kiến</strong><strong class="price" data-cart-total aria-live="polite"><fmt:formatNumber value="${subtotal}" pattern="#,##0" /> ₫</strong></div>
                <p class="cart-summary-note">Giá cuối cùng được xác nhận lại khi đặt hàng.</p>
                <p class="cart-dirty-note" data-cart-dirty-note role="status" hidden>Hãy lưu số lượng vừa thay đổi trước khi thanh toán.</p>
                <a class="btn btn-primary btn-block" href="${ctx}/checkout" data-cart-checkout>Tiến hành đặt hàng</a>
                <div class="cart-secure-note"><span aria-hidden="true">▣</span> Thanh toán an toàn qua COD hoặc VNPay</div>
            </aside>
        </div>
    </c:otherwise>
</c:choose>
<jsp:include page="components/store-footer.jsp" />
