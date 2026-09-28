package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.*;
import org.example.models.*;

import java.io.IOException;

@WebServlet("/user/yeu-cau-hoan-tien")
public class RefundRequestServlet extends HttpServlet {

    private final RefundRequestDAO refundDAO = new RefundRequestDAOImpl();
    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Account account = getUser(req, resp);
        if (account == null) return;

        long orderId = parseLong(req.getParameter("orderId"));
        if (orderId <= 0) { resp.sendRedirect(req.getContextPath() + "/user/donhang"); return; }

        Order order = orderDAO.findById(orderId);
        // Chỉ cho phép hoàn tiền khi: đơn của chính họ, đã CANCELLED, đã PAID (payment_status = REFUNDED = chờ hoàn)
        if (order == null || order.getUserId() != account.getId()
                || !"CANCELLED".equalsIgnoreCase(order.getStaTus())
                || !"REFUNDED".equalsIgnoreCase(order.getPaymentStatus())) {
            resp.sendRedirect(req.getContextPath() + "/user/donhang");
            return;
        }

        // Nếu đã gửi yêu cầu rồi
        RefundRequest existing = refundDAO.findByOrderId(orderId);
        req.setAttribute("order", order);
        req.setAttribute("existing", existing);
        req.getRequestDispatcher("/user/yeuCauHoanTien.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Account account = getUser(req, resp);
        if (account == null) return;

        long orderId = parseLong(req.getParameter("orderId"));
        Order order = orderId > 0 ? orderDAO.findById(orderId) : null;

        if (order == null || order.getUserId() != account.getId()
                || !"CANCELLED".equalsIgnoreCase(order.getStaTus())
                || !"REFUNDED".equalsIgnoreCase(order.getPaymentStatus())) {
            resp.sendRedirect(req.getContextPath() + "/user/donhang");
            return;
        }

        // Không cho gửi 2 lần
        if (refundDAO.findByOrderId(orderId) != null) {
            resp.sendRedirect(req.getContextPath() + "/user/yeu-cau-hoan-tien?orderId=" + orderId + "&dup=1");
            return;
        }

        String bankName = trim(req.getParameter("bankName"));
        String bankAccountNumber = trim(req.getParameter("bankAccountNumber"));
        String bankAccountHolder = trim(req.getParameter("bankAccountHolder"));
        String note = trim(req.getParameter("note"));

        if (bankName.isEmpty() || bankAccountNumber.isEmpty() || bankAccountHolder.isEmpty()) {
            req.setAttribute("order", order);
            req.setAttribute("error", "Vui lòng điền đầy đủ thông tin ngân hàng");
            req.getRequestDispatcher("/user/yeuCauHoanTien.jsp").forward(req, resp);
            return;
        }

        String refundError = org.example.utils.InputValidationUtil.firstError(
                org.example.utils.InputValidationUtil.checkLine("Tên ngân hàng", bankName, 100),
                org.example.utils.InputValidationUtil.checkLine("Số tài khoản", bankAccountNumber, 50),
                org.example.utils.InputValidationUtil.checkLine("Chủ tài khoản", bankAccountHolder, 200),
                org.example.utils.InputValidationUtil.checkMultiline("Ghi chú", note, 500));
        if (refundError != null) {
            req.setAttribute("order", order);
            req.setAttribute("error", refundError);
            req.getRequestDispatcher("/user/yeuCauHoanTien.jsp").forward(req, resp);
            return;
        }

        RefundRequest refund = new RefundRequest();
        refund.setOrderId(orderId);
        refund.setAccountId(account.getId());
        refund.setAmount(order.getTotalPrice() != null ? order.getTotalPrice() : 0);
        refund.setBankName(bankName);
        refund.setBankAccountNumber(bankAccountNumber);
        refund.setBankAccountHolder(bankAccountHolder);
        refund.setNote(note);

        boolean ok = refundDAO.create(refund);
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/user/yeu-cau-hoan-tien?orderId=" + orderId + "&success=1");
        } else {
            req.setAttribute("order", order);
            req.setAttribute("error", "Gửi yêu cầu thất bại, vui lòng thử lại");
            req.getRequestDispatcher("/user/yeuCauHoanTien.jsp").forward(req, resp);
        }
    }

    private Account getUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Account account = session != null ? (Account) session.getAttribute("account") : null;
        if (account == null || account.getRoleId() != 3) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        return account;
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }
    private long parseLong(String s) { try { return Long.parseLong(trim(s)); } catch (Exception e) { return 0; } }
}
