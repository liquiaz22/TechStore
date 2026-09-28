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
        if (specification == null || specification.getProduct() == null) {
            throw new IllegalArgumentException("Sản phẩm của thông số không hợp lệ.");
        }
        specification.setSpecificationName(ValidationUtil.requiredText(
                specification.getSpecificationName(), "Tên thông số", 150));
        specification.setSpecificationValue(ValidationUtil.requiredText(
                specification.getSpecificationValue(), "Giá trị thông số", 500));
        return specificationDAO.create(specification);
    }
}
