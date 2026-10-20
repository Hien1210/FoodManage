package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.AccountDAO;
import org.example.daos.AccountDAOImpl;
import org.example.daos.ShipperProfileDAO;
import org.example.daos.ShipperProfileDAOImpl;
import org.example.models.Account;
import org.example.models.ShipperProfile;
import org.example.utils.SensitiveInfoOtpUtil;
import org.mindrot.jbcrypt.BCrypt;

import javax.mail.MessagingException;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/shipper/profile")
public class ShipperProfileServlet extends HttpServlet {

    private final AccountDAO accountDAO = new AccountDAOImpl();
    private final ShipperProfileDAO profileDAO = new ShipperProfileDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Account account = currentShipper(req);
        if (account == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        ShipperProfile profile = profileDAO.findByAccountId(account.getId());
        if (profile == null) {
            profile = new ShipperProfile();
            profile.setAccountId(account.getId());
        }

        req.setAttribute("profile", profile);
        req.getRequestDispatcher("/shipper/hosotaixe.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Account account = currentShipper(req);
        if (account == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        String action = req.getParameter("action");

        if ("updateInfo".equals(action)) {
            handleUpdateInfo(req, resp, account);
        } else if ("updatePassword".equals(action)) {
            handleUpdatePassword(req, resp, account);
        } else if ("updateVehicle".equals(action)) {
            handleUpdateVehicle(req, resp, account);
        } else {
            resp.sendRedirect(req.getContextPath() + "/shipper/profile");
        }
    }

    private void handleUpdateInfo(HttpServletRequest req, HttpServletResponse resp, Account account)
            throws IOException, ServletException {
        String fullName  = req.getParameter("fullName")  != null ? req.getParameter("fullName").trim()  : "";
        String phone     = req.getParameter("phone")     != null ? req.getParameter("phone").trim()     : "";
        String email     = req.getParameter("email")     != null ? req.getParameter("email").trim()     : "";
        String avatarUrl = req.getParameter("avatarUrl") != null ? req.getParameter("avatarUrl").trim() : "";

        String infoError = org.example.utils.InputValidationUtil.firstError(
                org.example.utils.InputValidationUtil.checkLine("Họ tên", fullName, org.example.utils.InputValidationUtil.MAX_PERSON_NAME),
                org.example.utils.InputValidationUtil.checkPhone("Số điện thoại", phone));
        if (infoError != null) {
            redirectWithMsg(req, resp, "error", infoError);
            return;
        }
        if (fullName.isEmpty() || email.isEmpty()) {
            redirectWithMsg(req, resp, "error", "Họ tên và email không được để trống.");
            return;
        }
        if (!email.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            redirectWithMsg(req, resp, "error", "Email không đúng định dạng.");
            return;
        }
        if (accountDAO.tonTaiEmailKhacId(email, account.getId())) {
            redirectWithMsg(req, resp, "error", "Email đã được sử dụng bởi tài khoản khác.");
            return;
        }

        String avatarFinal = avatarUrl.isEmpty() ? account.getAvatarUrl() : avatarUrl;

        // Doi email la thao tac nhay cam (email dung de nhan OTP khoi phuc mat khau) - bat buoc
        // xac thuc OTP gui toi email MOI truoc khi luu.
        if (!email.equalsIgnoreCase(account.getEmail())) {
            Map<String, String> pending = new HashMap<>();
            pending.put("fullName", fullName);
            pending.put("phone", phone);
            pending.put("email", email);
            pending.put("avatarUrl", avatarFinal);
            try {
                SensitiveInfoOtpUtil.generateAndSend(req.getSession(), "shipper_profile_info", email, pending);
            } catch (MessagingException e) {
                e.printStackTrace();
                redirectWithMsg(req, resp, "error", "Không gửi được email OTP, vui lòng thử lại.");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/xac-thuc-thay-doi?purpose=shipper_profile_info");
            return;
        }

        account.setFullName(fullName);
        account.setPhone(phone);
        account.setAvatarUrl(avatarFinal);
        account.setPassWord(null); // không cập nhật mật khẩu ở đây

        boolean ok = accountDAO.update(account);
        if (ok) {
            // Cập nhật lại session
            req.getSession().setAttribute("account", account);
            redirectWithMsg(req, resp, "success", "Cập nhật thông tin thành công!");
        } else {
            redirectWithMsg(req, resp, "error", "Cập nhật thất bại, vui lòng thử lại.");
        }
    }

    private void handleUpdatePassword(HttpServletRequest req, HttpServletResponse resp, Account account)
            throws IOException {
        String currentPw = req.getParameter("currentPassword") != null ? req.getParameter("currentPassword") : "";
        String newPw     = req.getParameter("newPassword")     != null ? req.getParameter("newPassword").trim() : "";
        String confirmPw = req.getParameter("confirmPassword") != null ? req.getParameter("confirmPassword").trim() : "";

        // Lấy lại account từ DB để có mật khẩu hash
        Account fromDb = accountDAO.findById(account.getId());
        if (fromDb == null || !BCrypt.checkpw(currentPw, fromDb.getPassWord())) {
            redirectWithMsg(req, resp, "error", "Mật khẩu hiện tại không đúng.");
            return;
        }
        if (newPw.length() < 8 || newPw.length() > 16 || newPw.contains(" ")) {
            redirectWithMsg(req, resp, "error", "Mật khẩu mới phải 8-16 ký tự, không chứa khoảng trắng.");
            return;
        }
        if (!newPw.equals(confirmPw)) {
            redirectWithMsg(req, resp, "error", "Xác nhận mật khẩu không khớp.");
            return;
        }

        String hashed = BCrypt.hashpw(newPw, BCrypt.gensalt());
        boolean ok = accountDAO.capNhatMatKhauTheoEmail(account.getEmail(), hashed);
        if (ok) {
            redirectWithMsg(req, resp, "success", "Đổi mật khẩu thành công!");
        } else {
            redirectWithMsg(req, resp, "error", "Đổi mật khẩu thất bại, vui lòng thử lại.");
        }
    }

    private void handleUpdateVehicle(HttpServletRequest req, HttpServletResponse resp, Account account)
            throws IOException {
        String cccd          = req.getParameter("cccd")          != null ? req.getParameter("cccd").trim()          : "";
        String licenseNumber = req.getParameter("licenseNumber") != null ? req.getParameter("licenseNumber").trim() : "";
        String vehicleType   = req.getParameter("vehicleType")   != null ? req.getParameter("vehicleType").trim()   : "";
        String vehiclePlate  = req.getParameter("vehiclePlate")  != null ? req.getParameter("vehiclePlate").trim()  : "";
        String vehicleModel  = req.getParameter("vehicleModel")  != null ? req.getParameter("vehicleModel").trim()  : "";
        String bankAccount   = req.getParameter("bankAccount")   != null ? req.getParameter("bankAccount").trim()   : "";
        String bankName      = req.getParameter("bankName")      != null ? req.getParameter("bankName").trim()      : "";
        String bankAccountHolder = req.getParameter("bankAccountHolder") != null ? req.getParameter("bankAccountHolder").trim() : "";

        String vehicleError = org.example.utils.InputValidationUtil.firstError(
                org.example.utils.InputValidationUtil.checkLine("Số CCCD", cccd, 50),
                org.example.utils.InputValidationUtil.checkLine("Số bằng lái", licenseNumber, 50),
                org.example.utils.InputValidationUtil.checkLine("Loại phương tiện", vehicleType, 50),
                org.example.utils.InputValidationUtil.checkLine("Biển số", vehiclePlate, 20),
                org.example.utils.InputValidationUtil.checkLine("Mẫu xe", vehicleModel, 100),
                org.example.utils.InputValidationUtil.checkLine("Số tài khoản", bankAccount, 30),
                org.example.utils.InputValidationUtil.checkLine("Tên ngân hàng", bankName, 100),
                org.example.utils.InputValidationUtil.checkLine("Chủ tài khoản", bankAccountHolder, 100));
        if (vehicleError != null) {
            redirectWithMsg(req, resp, "error", vehicleError);
            return;
        }
        if (vehicleType.isEmpty() || vehiclePlate.isEmpty()) {
            redirectWithMsg(req, resp, "error", "Loại phương tiện và biển số không được để trống.");
            return;
        }

        // Doi thong tin ngan hang nhan tien rut la thao tac lien quan tien - bat buoc xac thuc OTP
        // gui toi email da xac thuc cua tai khoan truoc khi luu, tranh session bi chiem dung roi
        // doi tai khoan ngan hang de chiem tien rut cua shipper.
        ShipperProfile existing = profileDAO.findByAccountId(account.getId());
        String oldBankAccount = existing != null ? existing.getBankAccount() : null;
        String oldBankName = existing != null ? existing.getBankName() : null;
        String oldBankAccountHolder = existing != null ? existing.getBankAccountHolder() : null;
        boolean bankChanged = !safeEquals(bankAccount.isEmpty() ? null : bankAccount, oldBankAccount)
                || !safeEquals(bankName.isEmpty() ? null : bankName, oldBankName)
                || !safeEquals(bankAccountHolder.isEmpty() ? null : bankAccountHolder, oldBankAccountHolder);

        if (bankChanged) {
            Map<String, String> pending = new HashMap<>();
            pending.put("cccd", cccd);
            pending.put("licenseNumber", licenseNumber);
            pending.put("vehicleType", vehicleType);
            pending.put("vehiclePlate", vehiclePlate.toUpperCase());
            pending.put("vehicleModel", vehicleModel);
            pending.put("bankAccount", bankAccount);
            pending.put("bankName", bankName);
            pending.put("bankAccountHolder", bankAccountHolder);
            try {
                SensitiveInfoOtpUtil.generateAndSend(req.getSession(), "shipper_vehicle_bank", account.getEmail(), pending);
            } catch (MessagingException e) {
                e.printStackTrace();
                redirectWithMsg(req, resp, "error", "Không gửi được email OTP, vui lòng thử lại.");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/xac-thuc-thay-doi?purpose=shipper_vehicle_bank");
            return;
        }

        ShipperProfile profile = new ShipperProfile();
        profile.setAccountId(account.getId());
        profile.setCccd(cccd.isEmpty() ? null : cccd);
        profile.setLicenseNumber(licenseNumber.isEmpty() ? null : licenseNumber);
        profile.setVehicleType(vehicleType);
        profile.setVehiclePlate(vehiclePlate.toUpperCase());
        profile.setVehicleModel(vehicleModel.isEmpty() ? null : vehicleModel);
        profile.setBankAccount(bankAccount.isEmpty() ? null : bankAccount);
        profile.setBankName(bankName.isEmpty() ? null : bankName);
        profile.setBankAccountHolder(bankAccountHolder.isEmpty() ? null : bankAccountHolder);

        boolean ok = profileDAO.save(profile);
        if (ok) {
            redirectWithMsg(req, resp, "success", "Cập nhật thông tin nghề nghiệp thành công!");
        } else {
            redirectWithMsg(req, resp, "error", "Cập nhật thất bại, vui lòng thử lại.");
        }
    }

    private boolean safeEquals(String a, String b) {
        if (a == null) return b == null;
        return a.equals(b);
    }

    private void redirectWithMsg(HttpServletRequest req, HttpServletResponse resp,
                                 String type, String msg) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/shipper/profile?" + type + "=" +
                java.net.URLEncoder.encode(msg, "UTF-8"));
    }

    private Account currentShipper(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        Object obj = session.getAttribute("account");
        if (!(obj instanceof Account)) return null;
        Account a = (Account) obj;
        return a.getRoleId() == 4 ? a : null;
    }
}
