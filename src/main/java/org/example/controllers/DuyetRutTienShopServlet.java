package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.ShopWalletDAO;
import org.example.daos.ShopWalletDAOImpl;
import org.example.models.Account;
import org.example.models.ShopWithdrawal;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/admin/duyet-rut-tien-shop")
public class DuyetRutTienShopServlet extends HttpServlet {

    private final ShopWalletDAO walletDAO = new ShopWalletDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isSuperAdmin(req, resp)) return;

        String statusFilter = req.getParameter("status");
        if (statusFilter == null || statusFilter.isBlank()) statusFilter = "";

        int page = parsePage(req.getParameter("page"));
        int pageSize = 20;
        int offset = (page - 1) * pageSize;

        List<ShopWithdrawal> withdrawals = walletDAO.getAllWithdrawals(statusFilter, pageSize, offset);
        int total = walletDAO.countWithdrawals(statusFilter.isEmpty() ? null : statusFilter);
        int pendingCount = walletDAO.countWithdrawals("PENDING");
        // Đếm theo từng trạng thái để hiển thị tab lọc kèm số lượng (giống mẫu thiết kế) — mỗi lần load trang
        // chỉ thêm 3 câu COUNT(*) rẻ, không ảnh hưởng truy vấn danh sách chính.
        int totalAll = statusFilter.isEmpty() ? total : walletDAO.countWithdrawals(null);
        int approvedCount = walletDAO.countWithdrawals("APPROVED");
        int rejectedCount = walletDAO.countWithdrawals("REJECTED");

        req.setAttribute("withdrawals", withdrawals);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", (int) Math.ceil((double) total / pageSize));
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("pendingCount", pendingCount);
        req.setAttribute("totalAll", totalAll);
        req.setAttribute("approvedCount", approvedCount);
        req.setAttribute("rejectedCount", rejectedCount);
        req.getRequestDispatcher("/admin/DuyetRutTienShop.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Account admin = getAdmin(req);
        if (admin == null) {
            resp.setStatus(403);
            resp.getWriter().write("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }

        long withdrawalId;
        try { withdrawalId = Long.parseLong(req.getParameter("withdrawalId")); }
        catch (Exception e) { withdrawalId = 0; }

        String action = req.getParameter("action");
        String reason = req.getParameter("reason");
        boolean ok = false;

        if ("approve".equals(action) && withdrawalId > 0) {
            ok = walletDAO.approveWithdrawal(withdrawalId, admin.getId());
        } else if ("reject".equals(action) && withdrawalId > 0) {
            if (reason == null || reason.isBlank()) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng nhập lý do từ chối\"}");
                return;
            }
            ok = walletDAO.rejectWithdrawal(withdrawalId, admin.getId(), reason.trim());
        }

        PrintWriter out = resp.getWriter();
        if (ok) {
            out.write("{\"success\":true}");
        } else {
            out.write("{\"success\":false,\"message\":\"Thao tác thất bại. Yêu cầu có thể đã được xử lý.\"}");
        }
    }

    private boolean isSuperAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Account account = getAdmin(req);
        if (account == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return false;
        }
        return true;
    }

    private Account getAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        Account account = session != null ? (Account) session.getAttribute("account") : null;
        if (account == null || account.getRoleId() != 1) return null;
        return account;
    }

    private int parsePage(String s) {
        try { int p = Integer.parseInt(s); return p < 1 ? 1 : p; }
        catch (Exception e) { return 1; }
    }
}
