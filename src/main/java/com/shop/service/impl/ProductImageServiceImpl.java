package com.shop.service.impl;

import java.net.URI;
import java.util.List;
import java.util.Optional;

import com.shop.dao.ProductImageDAO;
import com.shop.dao.impl.ProductImageDAOImpl;
import com.shop.entity.ProductImage;
import com.shop.service.ProductImageService;
import com.shop.utils.ValidationUtil;

public class ProductImageServiceImpl extends AbstractService<ProductImage>
        implements ProductImageService {
    private final ProductImageDAO imageDAO;
    public ProductImageServiceImpl() { this(new ProductImageDAOImpl()); }
    public ProductImageServiceImpl(ProductImageDAO dao) { super(dao); this.imageDAO = dao; }
    @Override public List<ProductImage> findByProductId(Long id) { return imageDAO.findByProductId(id); }
    @Override public List<ProductImage> findByVariantId(Long id) { return imageDAO.findByVariantId(id); }
    @Override public Optional<ProductImage> findPrimaryByProductId(Long id) {
        return imageDAO.findPrimaryByProductId(id);
    }
    @Override public boolean create(ProductImage image) {
        if (image == null || image.getProduct() == null) {
            throw new IllegalArgumentException("Sản phẩm của hình ảnh không hợp lệ.");
        }
        image.setImageUrl(ValidationUtil.requiredText(image.getImageUrl(), "URL hình ảnh", 500));
        validateImageUrl(image.getImageUrl());
        if (image.getVariant() != null
                && !image.getProduct().getProductId().equals(
                        image.getVariant().getProduct().getProductId())) {
            throw new IllegalArgumentException("Phiên bản ảnh không thuộc sản phẩm đã chọn.");
        }
        if (image.getSortOrder() < 0) {
            throw new IllegalArgumentException("Thứ tự hình ảnh không được âm.");
        }
        return imageDAO.createWithPrimarySelection(image);
    }

    @Override
    public ProductImage updateMetadata(Long productId, Long imageId, int sortOrder, boolean primary) {
        if (sortOrder < 0) throw new IllegalArgumentException("Thứ tự hình ảnh không được âm.");
        return imageDAO.updateMetadata(productId, imageId, sortOrder, primary);
    }

    private void validateImageUrl(String imageUrl) {
        if (imageUrl.startsWith("assets/")) {
            if (imageUrl.contains("..") || imageUrl.contains("\\")
                    || !imageUrl.matches("[A-Za-z0-9/_\\-.]+")) {
                throw new IllegalArgumentException("Đường dẫn hình ảnh cục bộ không hợp lệ.");
            }
            return;
        }
        try {
            URI uri = URI.create(imageUrl);
            if (!("http".equalsIgnoreCase(uri.getScheme())
                    || "https".equalsIgnoreCase(uri.getScheme()))
                    || uri.getHost() == null) {
                throw new IllegalArgumentException("URL hình ảnh chỉ hỗ trợ HTTP hoặc HTTPS.");
            }
        } catch (IllegalArgumentException ex) {
            throw new IllegalArgumentException("URL hình ảnh không hợp lệ.");
        }
    }
}
