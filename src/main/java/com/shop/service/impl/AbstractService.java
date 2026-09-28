package com.shop.service.impl;

import java.util.List;

import com.shop.service.GenericService;
import com.shop.utils.GenericDAO;

public abstract class AbstractService<T> implements GenericService<T> {
    protected final GenericDAO<T> dao;

    protected AbstractService(GenericDAO<T> dao) {
        this.dao = dao;
    }

    @Override public boolean create(T entity) { return dao.create(entity); }
    @Override public T update(T entity) { return dao.update(entity); }
    @Override public boolean delete(Object id) { return dao.delete(id); }
    @Override public T findById(Object id) { return dao.findById(id); }
    @Override public List<T> findAll() { return dao.findAll(); }
    @Override public long count() { return dao.count(); }
    @Override public boolean exists(Object id) { return dao.exists(id); }
}
