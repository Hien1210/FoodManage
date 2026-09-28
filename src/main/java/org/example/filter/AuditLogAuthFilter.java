package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.models.Account;

import java.io.IOException;

/**
 * Chan rieng khu vuc Audit Log ("/admin/audit-logs"), CHI cho role 1 (Super Admin).
 * Ly do can filter rieng thay vi dua vao AuthFilter/AppFilter dung chung cho "/admin/*":
 * 2 filter do dang cho ca role 1 (Super Admin) va role 2 (Shop Owner) di qua,
 * trong khi Audit Log chua lich su thao tac nhay cam nen chi Super Admin duoc xem.
 */
@WebFilter(urlPatterns = "/admin/audit-logs")
public class AuditLogAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        Filter.super.init(filterConfig);
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        Account account = null;
        if (session != null) {
            Object obj = session.getAttribute("account");
            if (obj instanceof Account) {
                account = (Account) obj;
            }
        }

        if (account == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        if (account.getRoleId() != 1) {
            AccessDeniedLogger.log(req, account, "Super Admin (Audit Log)");
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chi Super Admin duoc xem Audit Log.");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        Filter.super.destroy();
    }
}
