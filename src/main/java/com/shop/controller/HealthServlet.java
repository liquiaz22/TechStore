package com.shop.controller;

import java.io.IOException;

import com.shop.utils.JpaUtil;
import com.shop.utils.WebUtil;

import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/health")
public class HealthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        EntityManager em = null;
        try {
            em = JpaUtil.getEntityManager();
            Object result = em.createNativeQuery("SELECT 1").getSingleResult();
            request.setAttribute("databaseOk", result != null);
        } catch (RuntimeException ex) {
            request.setAttribute("databaseOk", false);
            request.setAttribute("healthError", ex.getClass().getSimpleName() + ": " + ex.getMessage());
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
        WebUtil.forward(request, response, "health");
    }
}
