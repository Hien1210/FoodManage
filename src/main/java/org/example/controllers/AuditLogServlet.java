package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.AuditLogDAO;
import org.example.daos.AuditLogDAOImpl;
import org.example.models.Account;
import org.example.models.AuditLog;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * Trang "Audit Log - Nhật ký hệ thống" (Super Admin) - /admin/audit-logs
 * Chỉ đọc/tìm kiếm; việc GHI log do AuditLogService.log(...) đảm nhiệm,
 * được gọi từ các servlet nghiệp vụ khác (xem hướng dẫn tích hợp).
 */
@WebServlet("/admin/audit-logs")
public class AuditLogServlet extends HttpServlet {

    private static final int PAGE_SIZE = 20;

    private final AuditLogDAO auditLogDAO = new AuditLogDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!requireSuperAdmin(req, resp)) return;

        Long accountId = parseLong(req.getParameter("accountId"));
        String module = trimToNull(req.getParameter("module"));
        String action = trimToNull(req.getParameter("action"));
        LocalDate fromDate = parseDate(req.getParameter("fromDate"));
        LocalDate toDate = parseDate(req.getParameter("toDate"));
        int page = parsePage(req.getParameter("page"));

        List<AuditLog> logs = List.of();
        List<String> modules = List.of();
        int totalCount = 0;
        int totalPages = 1;

        try {
            totalCount = auditLogDAO.count(accountId, module, action, fromDate, toDate);
            totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) PAGE_SIZE));
            if (page > totalPages) page = totalPages;

            logs = auditLogDAO.search(accountId, module, action, fromDate, toDate, page, PAGE_SIZE);
            modules = auditLogDAO.findDistinctModules();
        } catch (RuntimeException e) {
            e.printStackTrace();
            req.setAttribute("loi", "Khong the tai du lieu audit log, vui long thu lai sau.");
        }

        req.setAttribute("logs", logs);
        req.setAttribute("modules", modules);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", PAGE_SIZE);

        // Tra lai gia tri filter da chon de JSP giu nguyen tren form sau khi submit
        req.setAttribute("filterAccountId", req.getParameter("accountId"));
        req.setAttribute("filterModule", module);
        req.setAttribute("filterAction", action);
        req.setAttribute("filterFromDate", req.getParameter("fromDate"));
        req.setAttribute("filterToDate", req.getParameter("toDate"));

        req.getRequestDispatcher("/admin/AuditLogs.jsp").forward(req, resp);
    }

    private boolean requireSuperAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Account account = session != null ? (Account) session.getAttribute("account") : null;
        if (account == null || account.getRoleId() != 1) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return false;
        }
        return true;
    }

    private Long parseLong(String val) {
        try { return (val == null || val.isBlank()) ? null : Long.parseLong(val.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    private LocalDate parseDate(String val) {
        try { return (val == null || val.isBlank()) ? null : LocalDate.parse(val.trim()); }
        catch (Exception e) { return null; }
    }

    private int parsePage(String val) {
        try {
            int p = Integer.parseInt(val);
            return Math.max(p, 1);
        } catch (Exception e) {
            return 1;
        }
    }

    private String trimToNull(String val) {
        if (val == null) return null;
        String trimmed = val.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
