package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.*;
import org.example.models.Account;
import org.example.models.Feedback;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * User gửi feedback cho Shop hoặc Shipper
 * GET  /feedback?orderId=&targetType=SHOP|SHIPPER  → form
 * POST /feedback                                    → lưu
 */
@WebServlet("/feedback")
public class FeedbackServlet extends HttpServlet {

    private final FeedbackDAO feedbackDAO = new FeedbackDAOImpl();
    private final OrderDAO    orderDAO    = new OrderDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Account account = getAccount(req, resp);
        if (account == null) return;

        String orderIdStr  = req.getParameter("orderId");
        String targetType  = req.getParameter("targetType"); // SHOP | SHIPPER

        if (orderIdStr == null || targetType == null) {
            resp.sendRedirect(req.getContextPath() + "/user/donhang");
            return;
        }

        long orderId;
        try { orderId = Long.parseLong(orderIdStr); } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/user/donhang"); return;
        }

        // Kiểm tra quyền
        if (!feedbackDAO.canFeedback(orderId, "USER", account.getId(), targetType, getTargetId(orderId, targetType))) {
            resp.sendRedirect(req.getContextPath() + "/user/donhang?error=1");
            return;
        }

        // Kiểm tra đã feedback chưa
        if (feedbackDAO.existsByOrderAndType(orderId, "USER", targetType)) {
            resp.sendRedirect(req.getContextPath() + "/user/donhang?error=1");
            return;
        }

        req.setAttribute("orderId",    orderId);
        req.setAttribute("targetType", targetType);
        req.getRequestDispatcher("/user/guiFeedback.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Account account = getAccount(req, resp);
        if (account == null) return;

        long orderId; int rating;
        try {
            orderId = Long.parseLong(req.getParameter("orderId"));
            rating  = Integer.parseInt(req.getParameter("rating"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/user/donhang"); return;
        }
        if (rating < 1 || rating > 5) {
            // Khop dung CHECK (rating BETWEEN 1 AND 5) cua DB - chan som truoc khi INSERT that bai.
            resp.sendRedirect(req.getContextPath() + "/user/donhang?error=1"); return;
        }
        String targetType = req.getParameter("targetType");
        String comment    = req.getParameter("comment");
        boolean anonymous = "true".equals(req.getParameter("is_anonymous"));
        if (comment != null && org.example.utils.InputValidationUtil.checkMultiline("Nhận xét", comment, 1000) != null) {
            resp.sendRedirect(req.getContextPath() + "/user/donhang?error=1");
            return;
        }

        long targetId = getTargetId(orderId, targetType);

        // Kiểm tra quyền lần nữa (tránh giả mạo POST)
        if (!feedbackDAO.canFeedback(orderId, "USER", account.getId(), targetType, targetId)) {
            resp.sendRedirect(req.getContextPath() + "/user/donhang");
            return;
        }
        if (feedbackDAO.existsByOrderAndType(orderId, "USER", targetType)) {
            resp.sendRedirect(req.getContextPath() + "/user/donhang");
            return;
        }

        Feedback f = new Feedback();
        f.setOrderId(orderId);
        f.setReviewerType("USER");
        f.setReviewerId(account.getId());
        f.setTargetType(targetType);
        f.setTargetId(targetId);
        f.setRating(rating);
        f.setComment(comment);
        f.setAnonymous(anonymous);

        long feedbackId = feedbackDAO.saveAndReturnId(f);
        if (feedbackId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/user/donhang?error=1");
            return;
        }
        String[] imageUrls = req.getParameterValues("imageUrls[]");
        if (imageUrls != null && imageUrls.length > 0) {
            List<String> urls = new ArrayList<>();
            for (String u : imageUrls) {
                if (u != null && !u.isBlank()) urls.add(u);
            }
            if (!urls.isEmpty()) feedbackDAO.saveFeedbackImages(feedbackId, urls);
        }
        resp.sendRedirect(req.getContextPath() + "/user/donhang?success=1");
    }

    /** Lấy targetId từ đơn hàng */
    private long getTargetId(long orderId, String targetType) {
        var order = orderDAO.findById(orderId);
        if (order == null) return 0L;
        return "SHOP".equals(targetType) ? order.getShopId() : order.getShipperId();
    }

    private Account getAccount(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { resp.sendRedirect(req.getContextPath() + "/dangnhap"); return null; }
        Account account = (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 3) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        return account;
    }
}
