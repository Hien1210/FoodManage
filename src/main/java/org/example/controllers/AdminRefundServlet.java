package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.RefundRequestDAO;
import org.example.daos.RefundRequestDAOImpl;
import org.example.models.Account;
import org.example.models.RefundRequest;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/admin/hoan-tien")
public class AdminRefundServlet extends HttpServlet {

    private final RefundRequestDAO refundDAO = new RefundRequestDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Account admin = getAdmin(req);
        if (admin == null) { resp.sendRedirect(req.getContextPath() + "/dangnhap"); return; }

        String statusFilter = req.getParameter("status");
        if (statusFilter == null) statusFilter = "";

        int page = parsePage(req.getParameter("page"));
        int pageSize = 20;

        List<RefundRequest> list = refundDAO.findAll(statusFilter, pageSize, (page - 1) * pageSize);
        int total = refundDAO.countAll(statusFilter.isEmpty() ? null : statusFilter);
        int pendingCount = refundDAO.countAll("PENDING");
        // Đếm theo từng trạng thái để hiển thị tab lọc kèm số lượng (đồng bộ với /admin/duyet-rut-tien-shop)
        int totalAll = statusFilter.isEmpty() ? total : refundDAO.countAll(null);
        int completedCount = refundDAO.countAll("COMPLETED");
        int rejectedCount = refundDAO.countAll("REJECTED");

        req.setAttribute("refunds", list);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / pageSize));
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("pendingCount", pendingCount);
        req.setAttribute("totalAll", totalAll);
        req.setAttribute("completedCount", completedCount);
        req.setAttribute("rejectedCount", rejectedCount);
        req.getRequestDispatcher("/admin/QuanLyHoanTien.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Account admin = getAdmin(req);
        if (admin == null) { resp.setStatus(403); resp.getWriter().write("{\"success\":false}"); return; }

        long refundId;
        try { refundId = Long.parseLong(req.getParameter("refundId")); } catch (Exception e) { refundId = 0; }
        String action = req.getParameter("action");
        String reason = req.getParameter("reason");
        boolean ok = false;

        if ("complete".equals(action) && refundId > 0) {
            ok = refundDAO.complete(refundId, admin.getId());
        } else if ("reject".equals(action) && refundId > 0 && reason != null && !reason.isBlank()) {
            ok = refundDAO.reject(refundId, admin.getId(), reason.trim());
        }

        PrintWriter out = resp.getWriter();
        out.write(ok ? "{\"success\":true}" : "{\"success\":false,\"message\":\"Thao tác thất bại hoặc đã xử lý rồi\"}");
    }

    private Account getAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        Account a = session != null ? (Account) session.getAttribute("account") : null;
        return (a != null && a.getRoleId() == 1) ? a : null;
    }

    private int parsePage(String s) { try { int p = Integer.parseInt(s); return p < 1 ? 1 : p; } catch (Exception e) { return 1; } }
}
