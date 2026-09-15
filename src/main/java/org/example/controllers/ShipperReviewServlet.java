package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.ShipperReviewDAO;
import org.example.daos.ShipperReviewDAOImpl;
import org.example.models.Account;
import org.example.models.ShipperReviewOrder;

import java.io.IOException;
import java.util.List;

/**
 * Trang "Đánh giá & Báo cáo" của Shipper
 * GET /shipper/danh-gia — danh sách đơn DONE + trạng thái đã feedback / bom hàng chưa
 */
@WebServlet("/shipper/danh-gia")
public class ShipperReviewServlet extends HttpServlet {

    private final ShipperReviewDAO shipperReviewDAO = new ShipperReviewDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) { resp.sendRedirect(req.getContextPath() + "/dangnhap"); return; }
        Account account = (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 4) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        // One query filters completed orders, joins the shop name and checks feedback.
        List<ShipperReviewOrder> doneOrders = shipperReviewDAO.findCompletedOrders(account.getId());

        req.setAttribute("doneOrders",   doneOrders);
        req.setAttribute("tenShipper",   account.getFullName() != null ? account.getFullName() : account.getUserName());
        req.getRequestDispatcher("/shipper/danhGia.jsp").forward(req, resp);
    }
}
