package com.shop.service.impl;

import java.util.List;

import com.shop.dao.FavoriteDAO;
import com.shop.dao.ProductDAO;
import com.shop.dao.UserDAO;
import com.shop.dao.impl.FavoriteDAOImpl;
import com.shop.dao.impl.ProductDAOImpl;
import com.shop.dao.impl.UserDAOImpl;
import com.shop.entity.Favorite;
import com.shop.entity.Product;
import com.shop.entity.User;
import com.shop.service.FavoriteService;

public class FavoriteServiceImpl extends AbstractService<Favorite> implements FavoriteService {
    private final FavoriteDAO favoriteDAO;
    private final UserDAO userDAO;
    private final ProductDAO productDAO;

    public FavoriteServiceImpl() {
        this(new FavoriteDAOImpl(), new UserDAOImpl(), new ProductDAOImpl());
    }

    public FavoriteServiceImpl(FavoriteDAO favoriteDAO, UserDAO userDAO, ProductDAO productDAO) {
        super(favoriteDAO);
        this.favoriteDAO = favoriteDAO;
        this.userDAO = userDAO;
        this.productDAO = productDAO;
    }

    @Override public List<Favorite> findByUserId(Long userId) {
        return favoriteDAO.findByUserId(userId);
    }

    @Override public boolean add(Long userId, Long productId) {
        if (favoriteDAO.exists(userId, productId)) return false;
        User user = userDAO.findById(userId);
        Product product = productDAO.findById(productId);
        if (user == null || product == null) throw new IllegalArgumentException("User or product not found");
        return favoriteDAO.create(new Favorite(user, product));
    }

    @Override public boolean remove(Long userId, Long productId) {
        return favoriteDAO.delete(userId, productId);
    }

    @Override public boolean isFavorite(Long userId, Long productId) {
        return favoriteDAO.exists(userId, productId);
    }
}
