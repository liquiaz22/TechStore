package com.shop.utils;

import java.io.IOException;

import com.shop.entity.User;

//lam viec voi User dang dang nhap 
public class XAuth {
	public static void setUser(User user) {
		XHttp.getSession().setAttribute("user", user); //luu tai khoan vao session
	}
	
	public static User getUser() {
		return (User) XHttp.getSession().getAttribute("user");//lay ngdung hien dang dang nhap
	}

	public static void removeUser() {
		XHttp.getSession().removeAttribute("user");//xoa attribute "user" khoi session
	}

	public static boolean isAuthenticated() {//da xac thuc da dang nhap
		return getUser() != null;
	}

	public static boolean isAdmin() {
		return isAuthenticated()
				&& "ADMIN".equals(getUser().getRole());// xac dinh role
	}

	public static void saveUrl() {// luu URL dang muon truy cap
		var savedUrl = XPath.getRequestUrl().toString();
		var queryString = XPath.getQueryString();

		if (queryString != null && !queryString.isBlank()) {
			savedUrl += "?" + queryString;
		}

		XAttr.setSession("saved-url", savedUrl);
	}

	public static boolean backToSavedUrl() throws IOException {// dua ve URL da luu 
		var savedUrl = (String) XAttr.getSession("saved-url");

		if (savedUrl != null && !savedUrl.isBlank()) {
			XAttr.removeSession("saved-url");
			XHttp.getResponse().sendRedirect(savedUrl);
			return true;
		}

		return false;
	}

	public static void logoff() {// xoa User dang dang nhap va xoa URL da luu
		XAuth.removeUser();
		XAttr.removeSession("saved-url");
	}
}
