package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.AccountDAO;
import org.example.daos.AccountDAOImpl;
import org.example.models.Account;
import org.example.utils.SensitiveInfoOtpUtil;
import org.example.utils.UploadValidationUtil;

import javax.mail.MessagingException;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/user/thong-tin-ca-nhan")
public class UserThongTinCaNhanServlet extends HttpServlet {

    private final AccountDAO accountDAO = new AccountDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }
        Account account = (Account) session.getAttribute("account");
        if (account.getRoleId() != 3) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }
        Account fresh = accountDAO.findById(account.getId());
        req.setAttribute("profile", fresh);
        req.getRequestDispatcher("/user/thongTinCaNhan.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }
        Account account = (Account) session.getAttribute("account");
        if (account.getRoleId() != 3) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        String fullName  = req.getParameter("fullName");
        String phone     = req.getParameter("phone");
        String email     = req.getParameter("email") != null ? req.getParameter("email").trim() : "";
        String avatarUrl = req.getParameter("avatarUrl");
        if (org.example.utils.InputValidationUtil.firstError(
                org.example.utils.InputValidationUtil.checkLine("Họ tên", fullName == null ? "" : fullName.trim(), org.example.utils.InputValidationUtil.MAX_PERSON_NAME),
                org.example.utils.InputValidationUtil.checkPhone("Số điện thoại", phone == null ? "" : phone.trim())) != null) {
            resp.sendRedirect(req.getContextPath() + "/user/thong-tin-ca-nhan?error=invalid_input");
            return;
        }

        String validAvatarUrl = (avatarUrl != null && UploadValidationUtil.isValidCloudinaryImageUrl(avatarUrl.trim()))
                ? avatarUrl.trim() : account.getAvatarUrl();

        if (!email.isEmpty() && !email.equalsIgnoreCase(account.getEmail())) {
            if (accountDAO.tonTaiEmailKhacId(email, account.getId())) {
                resp.sendRedirect(req.getContextPath() + "/user/thong-tin-ca-nhan?error=email_exists");
                return;
            }
            Map<String, String> pending = new HashMap<>();
            pending.put("fullName", fullName != null ? fullName.trim() : "");
            pending.put("phone", phone != null ? phone.trim() : "");
            pending.put("email", email);
            pending.put("avatarUrl", validAvatarUrl);
            try {
                SensitiveInfoOtpUtil.generateAndSend(session, "user_hoso", email, pending);
            } catch (MessagingException e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/user/thong-tin-ca-nhan?error=otp_send_failed");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/xac-thuc-thay-doi?purpose=user_hoso");
            return;
        }

        account.setFullName(fullName != null ? fullName.trim() : "");
        account.setPhone(phone != null ? phone.trim() : "");
        account.setAvatarUrl(validAvatarUrl);

        boolean ok = accountDAO.update(account);
        if (ok) {
            session.setAttribute("account", account);
            resp.sendRedirect(req.getContextPath() + "/user/thong-tin-ca-nhan?success=1");
        } else {
            resp.sendRedirect(req.getContextPath() + "/user/thong-tin-ca-nhan?error=1");
        }
    }
}
