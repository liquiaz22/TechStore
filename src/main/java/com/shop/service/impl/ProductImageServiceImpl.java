package com.shop.service.impl;

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
        return imageDAO.create(image);
    }
}
