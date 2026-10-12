package com.shop.service;

import java.util.List;

import com.shop.entity.Favorite;

public interface FavoriteService extends GenericService<Favorite> {
    List<Favorite> findByUserId(Long userId);
    List<Long> findProductIdsByUserId(Long userId);
    long countByUserId(Long userId);
    boolean add(Long userId, Long productId);
    boolean remove(Long userId, Long productId);
    boolean isFavorite(Long userId, Long productId);
}
