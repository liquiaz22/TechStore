package com.shop.service.impl;

import java.util.List;

import com.shop.dao.ProductSpecificationDAO;
import com.shop.dao.impl.ProductSpecificationDAOImpl;
import com.shop.entity.ProductSpecification;
import com.shop.service.ProductSpecificationService;
import com.shop.utils.ValidationUtil;

public class ProductSpecificationServiceImpl extends AbstractService<ProductSpecification>
        implements ProductSpecificationService {
    private final ProductSpecificationDAO specificationDAO;
    public ProductSpecificationServiceImpl() { this(new ProductSpecificationDAOImpl()); }
    public ProductSpecificationServiceImpl(ProductSpecificationDAO dao) {
        super(dao); this.specificationDAO = dao;
    }
    @Override public List<ProductSpecification> findByProductId(Long id) {
        return specificationDAO.findByProductId(id);
    }
    @Override public boolean create(ProductSpecification specification) {
        validate(specification);
        ensureUniqueName(specification);
        return specificationDAO.create(specification);
    }

    @Override public ProductSpecification update(ProductSpecification specification) {
        validate(specification);
        ensureUniqueName(specification);
        return specificationDAO.update(specification);
    }

    private void validate(ProductSpecification specification) {
        if (specification == null || specification.getProduct() == null) {
            throw new IllegalArgumentException("Sản phẩm của thông số không hợp lệ.");
        }
        specification.setSpecificationName(ValidationUtil.requiredText(
                specification.getSpecificationName(), "Tên thông số", 150));
        specification.setSpecificationValue(ValidationUtil.requiredText(
                specification.getSpecificationValue(), "Giá trị thông số", 500));
        if (specification.getSortOrder() < 0) {
            throw new IllegalArgumentException("Thứ tự thông số không được âm.");
        }
    }

    private void ensureUniqueName(ProductSpecification specification) {
        if (specificationDAO.existsByName(specification.getProduct().getProductId(),
                specification.getSpecificationName(), specification.getSpecificationId())) {
            throw new IllegalArgumentException("Tên thông số đã tồn tại trong sản phẩm này.");
        }
    }
}
