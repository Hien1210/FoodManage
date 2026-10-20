package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.models.Account;

import java.io.IOException;

/**
 * AuthFilter bảo vệ khu vực /admin/*
 * - role 1 (Super Admin): chỉ vào được /admin/super_admin/** (trang tổng quan,
 * duyệt shop,...)
 * - role 2 (Shop Owner): vào được /admin/trangcuahang.jsp và các trang quản lý
 * shop
 *
 * Phân quyền chi tiết hơn theo sub-path:
 * /admin/super_admin/** → chỉ role 1
 * /admin/** → role 1 hoặc role 2
 */
@WebFilter(urlPatterns = "/admin/*")
public class AuthFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        Filter.super.init(filterConfig);
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;


        // ✅ LẤY SESSION ĐÚNG CÁCH
        HttpSession session = req.getSession(false);
        Account acc = null;

        if (session != null) {
            Object obj = session.getAttribute("account");
            if (obj instanceof Account) {
                acc = (Account) obj;
            }
        }

        // Chưa đăng nhập → về trang đăng nhập
        if (acc == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        String uri = req.getRequestURI();

        // /admin/** → cho phép role 1 (Super Admin) VÀ role 2 (Shop Owner)
        if (uri.contains("/admin/")) {
            if (acc.getRoleId() == 1 || acc.getRoleId() == 2) {
                chain.doFilter(request, response);
                return;
            } else {
                AccessDeniedLogger.log(req, acc, "Chủ shop / Super Admin");
                resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Bạn không có quyền truy cập khu vực quản lý này!");
                return;
            }
        }

        chain.doFilter(request, response);
    }




    @Override
    public void destroy() {
        Filter.super.destroy();
    }
}
