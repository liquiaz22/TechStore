package com.shop.service.impl;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import com.shop.dao.OrderDAO;
import com.shop.dao.impl.OrderDAOImpl;
import com.shop.entity.Addresses;
import com.shop.entity.Cart;
import com.shop.entity.Order;
import com.shop.entity.OrderItem;
import com.shop.entity.OrderStatusHistory;
import com.shop.entity.Payment;
import com.shop.entity.ProductVariant;
import com.shop.entity.User;
import com.shop.service.OrderService;
import com.shop.utils.JpaUtil;
import com.shop.utils.ValidationUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.LockModeType;

public class OrderServiceImpl extends AbstractService<Order> implements OrderService {
    private static final Set<String> PAYMENT_METHODS =
            Set.of("COD", "VNPAY");
    private static final Map<String, Set<String>> TRANSITIONS = Map.of(
            "PENDING", Set.of("CONFIRMED", "CANCELLED"),
            "CONFIRMED", Set.of("PROCESSING", "CANCELLED"),
            "PROCESSING", Set.of("SHIPPING", "CANCELLED"),
            "SHIPPING", Set.of("COMPLETED"),
            "COMPLETED", Set.of(),
            "CANCELLED", Set.of());

    private final OrderDAO orderDAO;

    public OrderServiceImpl() { this(new OrderDAOImpl()); }
    public OrderServiceImpl(OrderDAO dao) { super(dao); this.orderDAO = dao; }

    @Override public Optional<Order> findByCode(String code) { return orderDAO.findByCode(code); }
    @Override public List<Order> findByUserId(Long userId, int page, int size) {
        return orderDAO.findByUserId(userId, page, size);
    }
    @Override public List<Order> findByStatus(String status, int page, int size) {
        return orderDAO.findByStatus(status, page, size);
    }
    @Override public List<Order> searchForAdmin(String keyword, String status,
            LocalDateTime from, LocalDateTime toExclusive, int page, int size) {
        return orderDAO.searchForAdmin(keyword, status, from, toExclusive, page, size);
    }
    @Override public long countForAdmin(String keyword, String status,
            LocalDateTime from, LocalDateTime toExclusive) {
        return orderDAO.countForAdmin(keyword, status, from, toExclusive);
    }

    @Override
    public Order placeOrder(Long userId, Addresses address, Map<Long, Integer> items,
            BigDecimal shippingFee, BigDecimal discountAmount,
            String paymentMethod, String customerNote) {
        validateCheckout(address, items, shippingFee, discountAmount, paymentMethod);
        customerNote = ValidationUtil.optionalText(customerNote, "Ghi chú đơn hàng", 500);
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = em.find(User.class, userId);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                throw new IllegalArgumentException("Tài khoản hiện không thể đặt hàng.");
            }

            Order order = new Order();
            order.setOrderCode(generateOrderCode());
            order.setUser(user);
            order.setReceiverName(address.getReceiverName().trim());
            order.setReceiverPhone(address.getReceiverPhone().trim());
            order.setShippingAddress(address.toShippingAddress());
            order.setCustomerNote(trimToNull(customerNote));
            order.setShippingFee(shippingFee);
            order.setDiscountAmount(discountAmount);
            em.persist(order);

            BigDecimal subtotal = BigDecimal.ZERO;
            for (Map.Entry<Long, Integer> entry : items.entrySet()) {
                int quantity = entry.getValue() == null ? 0 : entry.getValue();
                if (quantity <= 0) throw new IllegalArgumentException("Số lượng sản phẩm phải lớn hơn 0.");

                ProductVariant variant = em.find(ProductVariant.class, entry.getKey(),
                        LockModeType.PESSIMISTIC_WRITE);
                if (variant == null || !variant.isActive()
                        || !"ACTIVE".equals(variant.getProduct().getStatus())) {
                    throw new IllegalArgumentException("Một phiên bản sản phẩm hiện không còn khả dụng.");
                }
                if (variant.getStockQuantity() < quantity) {
                    throw new IllegalStateException("Không đủ tồn kho cho SKU " + variant.getSku() + ".");
                }

                variant.setStockQuantity(variant.getStockQuantity() - quantity);
                BigDecimal lineTotal = variant.getPrice().multiply(BigDecimal.valueOf(quantity));
                subtotal = subtotal.add(lineTotal);

                OrderItem item = new OrderItem();
                item.setOrder(order);
                item.setVariant(variant);
                item.setProductName(variant.getProduct().getName());
                item.setVariantName(variant.getVariantName());
                item.setSku(variant.getSku());
                item.setImageUrl(findPrimaryImage(em, variant));
                item.setUnitPrice(variant.getPrice());
                item.setQuantity(quantity);
                item.setLineTotal(lineTotal);
                em.persist(item);
            }

            BigDecimal total = subtotal.add(shippingFee).subtract(discountAmount);
            if (total.signum() < 0) throw new IllegalArgumentException("Giá trị giảm vượt quá tổng đơn hàng.");
            order.setSubtotal(subtotal);
            order.setTotalAmount(total);

            Payment payment = new Payment();
            payment.setOrder(order);
            payment.setPaymentMethod(paymentMethod);
            payment.setAmount(total);
            em.persist(payment);

            persistHistory(em, order, "PENDING", "Đơn hàng được tạo", user);

            List<Cart> carts = em.createQuery("FROM Cart c WHERE c.user.userId = :userId "
                    + "AND c.status = 'ACTIVE'", Cart.class)
                    .setParameter("userId", userId).setMaxResults(1).getResultList();
            if (!carts.isEmpty()) carts.get(0).setStatus("ORDERED");

            tx.commit();
            return order;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    @Override
    public Order cancel(Long orderId, Long changedByUserId, String note) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Order order = em.find(Order.class, orderId, LockModeType.PESSIMISTIC_WRITE);
            if (order == null) throw new IllegalArgumentException("Order not found");
            requireTransition(order.getStatus(), "CANCELLED");
            if ("PAID".equals(order.getPaymentStatus())) {
                throw new IllegalStateException(
                        "Đơn hàng đã thanh toán không thể hủy trực tiếp. Vui lòng xử lý hoàn tiền.");
            }

            List<Payment> payments = em.createQuery(
                    "FROM Payment p WHERE p.order.orderId = :orderId", Payment.class)
                    .setParameter("orderId", orderId)
                    .setLockMode(LockModeType.PESSIMISTIC_WRITE)
                    .getResultList();
            boolean activeOnlinePayment = payments.stream().anyMatch(payment ->
                    "VNPAY".equals(payment.getPaymentMethod())
                            && "PENDING".equals(payment.getPaymentStatus())
                            && payment.getCreatedAt() != null
                            && payment.getCreatedAt().isAfter(LocalDateTime.now().minusMinutes(20)));
            if (activeOnlinePayment) {
                throw new IllegalStateException(
                        "Giao dịch VNPay đang chờ xử lý. Vui lòng thử hủy lại sau 20 phút.");
            }

            List<OrderItem> items = em.createQuery(
                    "FROM OrderItem oi WHERE oi.order.orderId = :orderId", OrderItem.class)
                    .setParameter("orderId", orderId).getResultList();
            for (OrderItem item : items) {
                if (item.getVariant() != null) {
                    ProductVariant variant = em.find(ProductVariant.class,
                            item.getVariant().getVariantId(), LockModeType.PESSIMISTIC_WRITE);
                    if (variant != null) variant.setStockQuantity(variant.getStockQuantity() + item.getQuantity());
                }
            }
            for (Payment payment : payments) {
                if (!"SUCCESS".equals(payment.getPaymentStatus())) {
                    payment.setPaymentStatus("FAILED");
                    if (payment.getProviderResponseCode() == null) {
                        payment.setProviderResponseCode("CANCELLED");
                    }
                }
            }
            if (!"PAID".equals(order.getPaymentStatus())) {
                order.setPaymentStatus("FAILED");
            }
            order.setStatus("CANCELLED");
            User changedBy = changedByUserId == null ? null : em.find(User.class, changedByUserId);
            persistHistory(em, order, "CANCELLED", trimToNull(note), changedBy);
            tx.commit();
            return order;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    @Override
    public Order updateStatus(Long orderId, String status, Long changedByUserId, String note) {
        if ("CANCELLED".equals(status)) return cancel(orderId, changedByUserId, note);
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Order order = em.find(Order.class, orderId, LockModeType.PESSIMISTIC_WRITE);
            if (order == null) throw new IllegalArgumentException("Order not found");
            requireTransition(order.getStatus(), status);
            order.setStatus(status);
            if ("COMPLETED".equals(status)) {
                List<Payment> codPayments = em.createQuery("FROM Payment p "
                                + "WHERE p.order.orderId = :orderId "
                                + "AND p.paymentMethod = 'COD' "
                                + "AND p.paymentStatus = 'PENDING'", Payment.class)
                        .setParameter("orderId", orderId)
                        .setLockMode(LockModeType.PESSIMISTIC_WRITE)
                        .getResultList();
                for (Payment payment : codPayments) {
                    payment.setPaymentStatus("SUCCESS");
                    payment.setPaidAt(LocalDateTime.now());
                }
                if (!codPayments.isEmpty()) order.setPaymentStatus("PAID");
            }
            User changedBy = changedByUserId == null ? null : em.find(User.class, changedByUserId);
            persistHistory(em, order, status, trimToNull(note), changedBy);
            tx.commit();
            return order;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    private void validateCheckout(Addresses address, Map<Long, Integer> items,
            BigDecimal shippingFee, BigDecimal discount, String paymentMethod) {
        if (address == null) throw new IllegalArgumentException("Địa chỉ giao hàng không hợp lệ.");
        address.setReceiverName(ValidationUtil.requiredText(
                address.getReceiverName(), "Tên người nhận", 150));
        address.setReceiverPhone(ValidationUtil.phone(
                address.getReceiverPhone(), "Số điện thoại người nhận"));
        address.setProvince(ValidationUtil.requiredText(address.getProvince(), "Tỉnh/thành", 100));
        address.setDistrict(ValidationUtil.requiredText(address.getDistrict(), "Quận/huyện", 100));
        address.setWard(ValidationUtil.requiredText(address.getWard(), "Phường/xã", 100));
        address.setAddressLine(ValidationUtil.requiredText(
                address.getAddressLine(), "Địa chỉ cụ thể", 255));
        ValidationUtil.requireMaxLength(address.toShippingAddress(), "Địa chỉ giao hàng", 500);
        if (items == null || items.isEmpty()) throw new IllegalArgumentException("Giỏ hàng đang trống.");
        if (shippingFee == null || shippingFee.signum() < 0
                || discount == null || discount.signum() < 0) {
            throw new IllegalArgumentException("Phí vận chuyển hoặc số tiền giảm không hợp lệ.");
        }
        if (!PAYMENT_METHODS.contains(paymentMethod)) {
            throw new IllegalArgumentException("Phương thức thanh toán không được hỗ trợ.");
        }
    }

    private void requireTransition(String current, String next) {
        if (next == null || !TRANSITIONS.getOrDefault(current, Set.of()).contains(next)) {
            throw new IllegalStateException("Invalid order status transition: " + current + " -> " + next);
        }
    }

    private void persistHistory(EntityManager em, Order order, String status,
            String note, User changedBy) {
        OrderStatusHistory history = new OrderStatusHistory();
        history.setOrder(order);
        history.setStatus(status);
        history.setNote(note);
        history.setChangedBy(changedBy);
        em.persist(history);
    }

    private String findPrimaryImage(EntityManager em, ProductVariant variant) {
        List<String> images = em.createQuery("SELECT i.imageUrl FROM ProductImage i "
                + "WHERE i.product = :product AND i.primary = true "
                + "AND (i.variant = :variant OR i.variant IS NULL) "
                + "ORDER BY CASE WHEN i.variant = :variant THEN 0 ELSE 1 END, i.sortOrder",
                String.class).setParameter("product", variant.getProduct())
                .setParameter("variant", variant).setMaxResults(1).getResultList();
        return images.isEmpty() ? null : images.get(0);
    }

    private String generateOrderCode() {
        return "TS" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + UUID.randomUUID().toString().substring(0, 6).toUpperCase();
    }

    private String trimToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
