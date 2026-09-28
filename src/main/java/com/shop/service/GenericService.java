package com.shop.service;

import java.util.List;

public interface GenericService<T> {
    boolean create(T entity);
    T update(T entity);
    boolean delete(Object id);
    T findById(Object id);
    List<T> findAll();
    long count();
    boolean exists(Object id);
}
