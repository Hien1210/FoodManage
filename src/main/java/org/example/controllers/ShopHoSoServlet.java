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

@WebServlet("/shop/ho-so")
public class ShopHoSoServlet extends HttpServlet {

    private final AccountDAO accountDAO = new AccountDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }
        Account account = (Account) session.getAttribute("account");
        if (account.getRoleId() != 2) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }
        Account fresh = accountDAO.findById(account.getId());
        req.setAttribute("profile", fresh);
        req.getRequestDispatcher("/shop/hoSoShop.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }
        Account account = (Account) session.getAttribute("account");
        if (account.getRoleId() != 2) {
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
            resp.sendRedirect(req.getContextPath() + "/shop/ho-so?error=invalid_input");
            return;
        }
        String validAvatarUrl = (avatarUrl != null && UploadValidationUtil.isValidCloudinaryImageUrl(avatarUrl.trim()))
                ? avatarUrl.trim() : account.getAvatarUrl();

        // Doi email la thao tac nhay cam (email dung de nhan OTP khoi phuc mat khau) - bat buoc
        // xac thuc OTP gui toi email MOI truoc khi luu, tranh truong hop session bi chiem dung
        // roi doi email de chiem tai khoan qua "Quen mat khau".
        if (!email.isEmpty() && !email.equalsIgnoreCase(account.getEmail())) {
            if (accountDAO.tonTaiEmailKhacId(email, account.getId())) {
                resp.sendRedirect(req.getContextPath() + "/shop/ho-so?error=email_exists");
                return;
            }
            Map<String, String> pending = new HashMap<>();
            pending.put("fullName", fullName != null ? fullName.trim() : "");
            pending.put("phone", phone != null ? phone.trim() : "");
            pending.put("email", email);
            pending.put("avatarUrl", validAvatarUrl);
            try {
                SensitiveInfoOtpUtil.generateAndSend(session, "shop_hoso", email, pending);
            } catch (MessagingException e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/shop/ho-so?error=otp_send_failed");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/xac-thuc-thay-doi?purpose=shop_hoso");
            return;
        }

        // Khong sua truc tiep len doi tuong "account" trong session truoc khi biet chac DB update
        // thanh cong - neu update that bai, session se hien thi du lieu khong khop voi DB.
        Account updated = new Account(account.getId(), account.getUserName(), account.getPassWord(),
                account.getEmail(), fullName != null ? fullName.trim() : "", phone != null ? phone.trim() : "",
                validAvatarUrl, account.getRoleId(), account.getStaTus(), account.isDeleted(),
                account.getCreatedAt(), account.getUpdatedAt());
        updated.setLogoUrl(account.getLogoUrl());
        updated.setSuspendReason(account.getSuspendReason());
        updated.setOnline(account.isOnline());

        boolean ok = accountDAO.update(updated);
        if (ok) {
            session.setAttribute("account", updated);
            resp.sendRedirect(req.getContextPath() + "/shop/ho-so?success=1");
        } else {
            resp.sendRedirect(req.getContextPath() + "/shop/ho-so?error=1");
        }
    }
}
