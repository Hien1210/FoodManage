package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.AccountDAO;
import org.example.daos.AccountDAOImpl;
import org.example.daos.ShopDAO;
import org.example.daos.ShopDAOImpl;
import org.example.models.Account;
import org.example.models.Shop;
import org.example.services.AuditLogService;
import org.example.utils.AuditModules;
import org.example.utils.EmailUtil;
import org.example.utils.RateLimitUtil;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

@WebServlet("/dangky-shop")
public class DangKyShopServlet extends HttpServlet {

    private static final String VIEW      = "/shop/registerShop.jsp";
    private static final String DONE_VIEW = "/shop/dangKyChoDuyet.jsp";
    private static final long   OTP_TTL_MILLIS       = 5 * 60 * 1000L;
    private static final int    MAX_REGOTP            = 10;
    private static final long   REGOTP_WINDOW_MILLIS  = 10 * 60 * 1000L;
    private static final long   REGOTP_LOCKOUT_MILLIS = 10 * 60 * 1000L;
    private static final int    MAX_OTP_FAIL          = 5;

    private final AuditLogService auditLogService = new AuditLogService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if ("1".equals(req.getParameter("done"))) {
            req.getRequestDispatcher(DONE_VIEW).forward(req, resp);
            return;
        }
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String action = normalize(req.getParameter("action"));
        switch (action) {
            case "verifyOtp" -> handleVerifyOtp(req, resp);
            case "resendOtp" -> handleResendOtp(req, resp);
            default          -> handleRegister(req, resp);
        }
    }

    /* ------------------------------------------------------------------ */
    /* BƯỚC 1: Validate + lưu session + gửi OTP                           */
    /* ------------------------------------------------------------------ */
    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        AccountDAO dao = new AccountDAOImpl();

        String username        = normalize(req.getParameter("username"));
        String password        = normalize(req.getParameter("password"));
        String confirmPassword = normalize(req.getParameter("confirm_password"));
        String fullname        = normalize(req.getParameter("fullname"));
        String phone           = normalize(req.getParameter("phone"));
        String email           = normalize(req.getParameter("email"));
        String shopName        = normalize(req.getParameter("shopName"));
        String shopDescription = normalize(req.getParameter("shopDescription"));
        String shopAddress     = normalize(req.getParameter("shopAddress"));
        String shopPhone       = normalize(req.getParameter("shopPhone"));
        String shopLogo        = normalize(req.getParameter("shopLogo"));

        if (fullname.isEmpty())    { jsonFail(resp, "Họ tên chủ shop không được để trống!"); return; }
        if (username.isEmpty())    { jsonFail(resp, "Tên đăng nhập không được để trống!"); return; }
        if (!username.matches("^[a-zA-Z0-9_]{3,30}$")) {
            jsonFail(resp, "Tên đăng nhập chỉ được chứa chữ không dấu, số và dấu gạch dưới (_), dài 3–30 ký tự, không có khoảng trắng!");
            return;
        }
        if (email.isEmpty())       { jsonFail(resp, "Email không được để trống!"); return; }
        if (password.isEmpty())    { jsonFail(resp, "Mật khẩu không được để trống!"); return; }
        if (password.length() < 8 || password.length() > 16) { jsonFail(resp, "Mật khẩu phải từ 8–16 ký tự!"); return; }
        if (password.contains(" ")) { jsonFail(resp, "Mật khẩu không được chứa khoảng trắng!"); return; }
        if (!password.equals(confirmPassword)) { jsonFail(resp, "Mật khẩu xác nhận không khớp!"); return; }
        if (shopName.isEmpty())    { jsonFail(resp, "Tên shop không được để trống!"); return; }
        if (shopAddress.isEmpty()) { jsonFail(resp, "Địa chỉ shop không được để trống!"); return; }
        if (shopPhone.isEmpty())   { jsonFail(resp, "Số điện thoại shop không được để trống!"); return; }

        String inputError = org.example.utils.InputValidationUtil.firstError(
                org.example.utils.InputValidationUtil.checkLine("Họ tên", fullname, org.example.utils.InputValidationUtil.MAX_PERSON_NAME),
                org.example.utils.InputValidationUtil.checkPhone("Số điện thoại", phone),
                org.example.utils.InputValidationUtil.checkLine("Tên shop", shopName, org.example.utils.InputValidationUtil.MAX_SHOP_NAME),
                org.example.utils.InputValidationUtil.checkMultiline("Mô tả shop", shopDescription, org.example.utils.InputValidationUtil.MAX_DESCRIPTION),
                org.example.utils.InputValidationUtil.checkLine("Địa chỉ shop", shopAddress, org.example.utils.InputValidationUtil.MAX_ADDRESS),
                org.example.utils.InputValidationUtil.checkPhone("Số điện thoại shop", shopPhone));
        if (inputError != null) { jsonFail(resp, inputError); return; }

        if (dao.tonTaiEmail(email))    { jsonFail(resp, "Email đã được đăng ký!"); return; }
        if (dao.tonTaiUsername(username)) { jsonFail(resp, "Tên đăng nhập đã được đăng ký!"); return; }

        String regOtpKey = "regotp:" + RateLimitUtil.getClientIp(req);
        if (RateLimitUtil.isBlocked(regOtpKey)) {
            jsonFail(resp, "Bạn đã yêu cầu OTP quá nhiều lần, vui lòng thử lại sau.");
            return;
        }
        boolean justLocked = RateLimitUtil.recordFailure(regOtpKey, MAX_REGOTP, REGOTP_WINDOW_MILLIS, REGOTP_LOCKOUT_MILLIS);
        if (justLocked) {
            auditLogService.log(req, null, "Khoá gửi OTP đăng ký Shop (rate limit)", AuditModules.SECURITY,
                    "IP " + RateLimitUtil.getClientIp(req) + " bị khoá gửi OTP đăng ký Shop, email: " + email,
                    null, "Account");
        }

        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));
        String otp = String.format("%06d", new java.security.SecureRandom().nextInt(1000000));

        try {
            EmailUtil.sendEmail(email, "Xác nhận đăng ký Shop POB", buildShopOtpEmail(otp, email));
        } catch (Exception e) {
            e.printStackTrace();
            jsonFail(resp, "Không thể gửi email, vui lòng thử lại sau ít phút.");
            return;
        }

        HttpSession session = req.getSession();
        session.setAttribute("otp",             otp);
        session.setAttribute("otpExpiredAt",    System.currentTimeMillis() + OTP_TTL_MILLIS);
        session.setAttribute("username",        username);
        session.setAttribute("password",        hashedPassword);
        session.setAttribute("fullname",        fullname);
        session.setAttribute("phone",           phone);
        session.setAttribute("email",           email);
        session.setAttribute("registerRoleId",  2L);
        session.setAttribute("shopName",        shopName);
        session.setAttribute("shopDescription", shopDescription);
        session.setAttribute("shopAddress",     shopAddress);
        session.setAttribute("shopPhone",       shopPhone);
        session.setAttribute("shopLogo",        shopLogo);

        jsonOk(resp, "OTP đã được gửi đến email của bạn.");
    }

    /* ------------------------------------------------------------------ */
    /* BƯỚC 2: Xác nhận OTP → tạo Account + Shop                         */
    /* ------------------------------------------------------------------ */
    private void handleVerifyOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        Object otpSession = session.getAttribute("otp");
        if (otpSession == null) {
            jsonFail(resp, "Phiên đăng ký đã hết hạn, vui lòng đăng ký lại.");
            return;
        }

        Long expiredAt = (Long) session.getAttribute("otpExpiredAt");
        if (expiredAt != null && System.currentTimeMillis() > expiredAt) {
            clearSession(session);
            jsonFail(resp, "Mã OTP đã hết hạn, vui lòng đăng ký lại.");
            return;
        }

        String entered = normalize(req.getParameter("otp1"))
                       + normalize(req.getParameter("otp2"))
                       + normalize(req.getParameter("otp3"))
                       + normalize(req.getParameter("otp4"))
                       + normalize(req.getParameter("otp5"))
                       + normalize(req.getParameter("otp6"));

        if (!MessageDigest.isEqual(
                otpSession.toString().getBytes(StandardCharsets.UTF_8),
                entered.getBytes(StandardCharsets.UTF_8))) {

            int failCount = 1;
            Object fc = session.getAttribute("otpFailCount");
            if (fc instanceof Integer) failCount = (Integer) fc + 1;

            if (failCount >= MAX_OTP_FAIL) {
                clearSession(session);
                jsonFail(resp, "Nhập sai OTP quá nhiều lần, vui lòng đăng ký lại.");
                return;
            }
            session.setAttribute("otpFailCount", failCount);
            jsonFail(resp, "Mã OTP không chính xác! (lần " + failCount + "/" + MAX_OTP_FAIL + ")");
            return;
        }

        // OTP đúng — tạo Account
        AccountDAO accountDAO = new AccountDAOImpl();
        ShopDAO    shopDAO    = new ShopDAOImpl();

        Account account = new Account();
        account.setUserName((String) session.getAttribute("username"));
        account.setPassWord((String) session.getAttribute("password"));
        account.setEmail((String)    session.getAttribute("email"));
        account.setFullName((String) session.getAttribute("fullname"));
        account.setPhone((String)    session.getAttribute("phone"));
        account.setRoleId(2L);

        long newId = accountDAO.createAndReturnId(account);
        if (newId <= 0) {
            jsonFail(resp, "Đăng ký tài khoản thất bại, vui lòng thử lại!");
            return;
        }

        // Tạo Shop với status pending
        Shop shop = new Shop();
        shop.setOwnerId(newId);
        shop.setShopName((String)        session.getAttribute("shopName"));
        shop.setShopDescription((String) session.getAttribute("shopDescription"));
        shop.setShopAddress((String)     session.getAttribute("shopAddress"));
        shop.setShopPhone((String)       session.getAttribute("shopPhone"));
        shop.setShopLogo((String)        session.getAttribute("shopLogo"));
        shop.setStatus("pending");
        shop.setRejectionReason(null);
        shop.setApprovedBy(0);
        shop.setApproveDate(null);
        shopDAO.insertShop(shop);

        clearSession(session);
        jsonOk(resp, "Đăng ký thành công! Vui lòng chờ Admin duyệt.");
    }

    /* ------------------------------------------------------------------ */
    /* Gửi lại OTP                                                         */
    /* ------------------------------------------------------------------ */
    private void handleResendOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        String email = (String) session.getAttribute("email");
        if (email == null) { jsonFail(resp, "Phiên đăng ký đã hết hạn."); return; }

        String resendKey = "otpresend:" + RateLimitUtil.getClientIp(req);
        if (RateLimitUtil.isBlocked(resendKey)) {
            jsonFail(resp, "Vui lòng đợi trước khi gửi lại OTP.");
            return;
        }
        RateLimitUtil.recordFailure(resendKey, 3, 10 * 60 * 1000L, 10 * 60 * 1000L);

        String newOtp = String.format("%06d", new java.security.SecureRandom().nextInt(1000000));
        session.setAttribute("otp",          newOtp);
        session.setAttribute("otpExpiredAt", System.currentTimeMillis() + OTP_TTL_MILLIS);
        session.removeAttribute("otpFailCount");

        try {
            EmailUtil.sendEmail(email, "Xác nhận đăng ký Shop POB", buildShopOtpEmail(newOtp, email));
            jsonOk(resp, "Đã gửi lại mã OTP đến " + email + ".");
        } catch (Exception e) {
            jsonFail(resp, "Không thể gửi email, vui lòng thử lại!");
        }
    }

    /* ------------------------------------------------------------------ */
    /* Helpers                                                             */
    /* ------------------------------------------------------------------ */
    private void clearSession(HttpSession session) {
        for (String key : new String[]{"otp","otpExpiredAt","otpFailCount","username","password",
                "fullname","phone","email","registerRoleId",
                "shopName","shopDescription","shopAddress","shopPhone","shopLogo"}) {
            session.removeAttribute(key);
        }
    }

    private void jsonOk(HttpServletResponse resp, String msg) throws IOException {
        resp.getWriter().write("{\"ok\":true,\"message\":\"" + escapeJson(msg) + "\"}");
    }

    private void jsonFail(HttpServletResponse resp, String msg) throws IOException {
        resp.getWriter().write("{\"ok\":false,\"message\":\"" + escapeJson(msg) + "\"}");
    }

    private String escapeJson(String s) {
        return s == null ? "" : s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private String buildShopOtpEmail(String otp, String email) {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>Xác nhận đăng ký Shop</title>
        </head>
        <body style="margin:0;padding:0;font-family:'Segoe UI',Arial,sans-serif;background:#f4f7fb;">
            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%%" style="max-width:600px;margin:40px auto;background:#ffffff;border-radius:16px;box-shadow:0 8px 32px rgba(0,0,0,0.08);overflow:hidden;">
                <tr>
                    <td style="background:linear-gradient(135deg,#1a1a2e,#273053);padding:32px 40px;text-align:center;">
                        <h1 style="color:#ffffff;font-size:24px;font-weight:700;margin:0;letter-spacing:1px;">🏪 POB</h1>
                        <p style="color:rgba(255,255,255,0.6);font-size:13px;margin:6px 0 0;letter-spacing:2px;">HỆ THỐNG ĐẶT HÀNG</p>
                    </td>
                </tr>
                <tr>
                    <td style="padding:40px 40px 30px;">
                        <h2 style="color:#1a1a2e;font-size:20px;font-weight:600;margin:0 0 8px;">Đăng ký Shop</h2>
                        <p style="color:#666;font-size:15px;line-height:1.6;margin:0 0 24px;">
                            Chào bạn,<br>
                            Vui lòng nhập mã OTP dưới đây để hoàn tất đăng ký tài khoản <strong>Shop</strong> trên hệ thống POB.
                        </p>
                        <div style="background:#f8f9fc;border-radius:12px;padding:28px;text-align:center;border:1px dashed #d1d5e5;margin-bottom:24px;">
                            <div style="font-size:11px;color:#888;text-transform:uppercase;letter-spacing:1.5px;margin-bottom:8px;">Mã xác thực (OTP)</div>
                            <div style="font-size:36px;font-weight:800;color:#273053;letter-spacing:8px;font-family:'Courier New',monospace;">%s</div>
                            <div style="font-size:12px;color:#999;margin-top:10px;">⏳ Hiệu lực trong <strong>5 phút</strong></div>
                        </div>
                        <div style="background:#f0fdf4;border-radius:8px;padding:14px 18px;border-left:4px solid #20d489;margin-bottom:24px;">
                            <p style="color:#166534;font-size:13px;margin:0;">📧 Email đăng ký: <strong>%s</strong></p>
                        </div>
                        <p style="color:#aaa;font-size:12px;margin:0;">Không chia sẻ mã này với bất kỳ ai. Mã có hiệu lực trong 5 phút.</p>
                    </td>
                </tr>
                <tr>
                    <td style="background:#f8f9fc;padding:20px 40px;text-align:center;border-top:1px solid #e9ecef;">
                        <p style="color:#999;font-size:12px;margin:0;">© 2025 POB - Hệ thống đặt hàng<br>
                        <span style="color:#bbb;">Email này được gửi tự động, vui lòng không trả lời.</span></p>
                    </td>
                </tr>
            </table>
        </body>
        </html>
        """.formatted(otp, email);
    }
}
