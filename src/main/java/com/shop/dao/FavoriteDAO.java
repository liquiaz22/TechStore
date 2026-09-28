package com.shop.dao;

import java.util.List;

import com.shop.entity.Favorite;
import com.shop.utils.GenericDAO;

public interface FavoriteDAO extends GenericDAO<Favorite> {
    List<Favorite> findByUserId(Long userId);
    boolean exists(Long userId, Long productId);
    boolean delete(Long userId, Long productId);
}
