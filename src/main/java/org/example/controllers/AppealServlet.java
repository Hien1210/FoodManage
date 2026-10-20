package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.AppealDAO;
import org.example.daos.AppealDAOImpl;

import java.io.IOException;

@WebServlet("/appeal")
public class AppealServlet extends HttpServlet {

    private final AppealDAO dao = new AppealDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String message = req.getParameter("message");

        // accountId KHÔNG được lấy từ tham số của client (dễ bị giả mạo/spam kháng
        // nghị cho tài khoản người khác). Chỉ chấp nhận accountId mà DangNhapServlet
        // đã xác thực đúng mật khẩu và lưu vào session ngay trước khi forward sang
        // trang kháng nghị.
        HttpSession session = req.getSession(false);
        Object sessionAccountId = session != null ? session.getAttribute("suspendedAccountId") : null;

        if (message != null && org.example.utils.InputValidationUtil.checkMultiline("Nội dung kháng nghị", message, 1000) != null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap?appealError=invalid");
            return;
        }

        if (sessionAccountId == null || message == null || message.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap?appealError=empty");
            return;
        }

        long accountId = (Long) sessionAccountId;

        // Kiểm tra đã có kháng nghị đang chờ chưa
        if (dao.hasPendingAppeal(accountId)) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap?appealError=duplicate");
            return;
        }

        boolean ok = dao.submit(accountId, message.trim());
        session.removeAttribute("suspendedAccountId");
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap?appealSent=1");
        } else {
            resp.sendRedirect(req.getContextPath() + "/dangnhap?appealError=fail");
        }
    }
}
