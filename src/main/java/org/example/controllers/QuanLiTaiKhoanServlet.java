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
import org.example.daos.ShopDAO;
import org.example.daos.ShopDAOImpl;
import org.example.daos.UserProfileDAO;
import org.example.daos.UserProfileDAOImpl;
import org.example.models.Account;
import org.example.models.ShipperProfile;
import org.example.models.Shop;
import org.example.models.UserProfile;
import org.example.services.AuditLogService;
import org.example.utils.AuditModules;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/quanlitaikhoan")
public class QuanLiTaiKhoanServlet extends HttpServlet {
    private final AccountDAO dao = new AccountDAOImpl();
    private final AuditLogService auditLogService = new AuditLogService();
    private static final String VIEW = "/admin/quanlitaikhoan.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        AccountDAO accountDAO = new AccountDAOImpl();
        ShopDAO shopDAO = new ShopDAOImpl();
        if (!requireAdmin(req, resp)) {
            return;
        }

        String action = req.getParameter("action");
        if ("edit".equals(action)) {
            Long id = parseId(req);
            if (id == null) {
                req.setAttribute("loi", "ID account không hợp lệ");
            } else {
                Account account = dao.findById(id);
                if (account == null) {
                    req.setAttribute("loi", "Không tìm thấy account");
                } else {
                    req.setAttribute("accountSua", account);
                }
            }
        }

        int tongTaiKhoan = accountDAO.getTotalAccounts();
        int shopChoDuyet = shopDAO.countPendingShops();
        int shipperHoatDong = accountDAO.countActiveShippers();
        List<Shop> top5Shop = shopDAO.findTop5PendingShops();

        req.setAttribute("tongTaiKhoan", tongTaiKhoan);
        req.setAttribute("shopChoDuyet", shopChoDuyet);
        req.setAttribute("shipperHoatDong", shipperHoatDong);
        req.setAttribute("top5Shop", top5Shop);

        forwardAccountPage(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!requireAdmin(req, resp)) {
            return;
        }

        String action = req.getParameter("action");
        if (action == null || action.isBlank()) {
            action = "create";
        }

        boolean success;
        switch (action) {
            case "update":
                success = updateAccount(req, resp);
                break;
            case "delete":
            case "softdelete":
                success = deleteAccount(req, resp);
                break;
            case "search":  // ← THÊM CASE NÀY
                searchAccount(req, resp);
                return;
            case "create":
            default:
                success = createAccount(req, resp);
                break;
        }

        if (success) {
            // Thêm param success để JSP hiển thị thông báo thành công
            resp.sendRedirect(req.getContextPath() + "/quanlitaikhoan?success=" + action);
        }
    }

    private void searchAccount(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("searchKeyword");

        List<Account> danhsach;
        if (keyword != null && !keyword.trim().isEmpty()) {
            danhsach = dao.searchByUsernameOrEmail(keyword.trim());
            req.setAttribute("searchKeyword", keyword);

            if (danhsach.isEmpty()) {
                req.setAttribute("loi", "Không tìm thấy tài khoản nào với từ khóa: " + keyword);
            }
        } else {
            danhsach = dao.getAll();
        }

        buildProfileMaps(req, danhsach);
        req.setAttribute("danhsach", danhsach);
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    private void forwardAccountPage(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String sortField = req.getParameter("sortField");
        String sortOrder = req.getParameter("sortOrder");

        if (sortField == null) sortField = "id";
        if (sortOrder == null) sortOrder = "DESC";

        List<Account> danhsach = dao.getAll(sortField, sortOrder);
        req.setAttribute("danhsach", danhsach);
        req.setAttribute("currentSortField", sortField);
        req.setAttribute("currentSortOrder", sortOrder);

        buildProfileMaps(req, danhsach);
        req.setAttribute("pendingShopsCount", new ShopDAOImpl().countPendingShops());

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    private boolean createAccount(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Account account = readAccount(req);
        String password = normalize(req.getParameter("password"));

        String error = validateAccount(account, password, false);
        if (error != null) {
            return fail(req, resp, error, account);
        }

        if (dao.tonTaiUsername(account.getUserName())) {
            return fail(req, resp, "Username đã tồn tại", account);
        }

        if (dao.tonTaiEmail(account.getEmail())) {
            return fail(req, resp, "Email đã tồn tại", account);
        }

        account.setPassWord(BCrypt.hashpw(password, BCrypt.gensalt(12)));
        boolean created = dao.create(account);
        if (!created) {
            return fail(req, resp, "Lỗi tạo account", account);
        }

        Account currentUser = getLoggedInAccount(req);
        auditLogService.log(req, currentUser, "Tạo tài khoản", AuditModules.ACCOUNT,
                "Super Admin " + currentUser.getUserName() + " đã tạo tài khoản \"" + account.getUserName() + "\" (role=" + account.getRoleId() + ")",
                null, AuditModules.ACCOUNT);

        return true;
    }

    /** Helper: build profile maps for Shop (role=2), Shipper (role=4), and Customer (role=3). */
    private void buildProfileMaps(HttpServletRequest req, List<Account> danhsach) {
        ShopDAO shopDAO = new ShopDAOImpl();
        ShipperProfileDAO shipperProfileDAO = new ShipperProfileDAOImpl();
        UserProfileDAO userProfileDAO = new UserProfileDAOImpl();

        Map<Long, Shop> shopProfilesMap = new HashMap<>();
        Map<Long, ShipperProfile> shipperProfilesMap = new HashMap<>();
        Map<Long, UserProfile> userProfilesMap = new HashMap<>();

        for (Account acc : danhsach) {
            long rid = acc.getRoleId();
            if (rid == 2) {
                Shop s = shopDAO.selectShopByOwnerId(acc.getId());
                if (s != null) shopProfilesMap.put(acc.getId(), s);
            } else if (rid == 4) {
                ShipperProfile sp = shipperProfileDAO.findByAccountId(acc.getId());
                if (sp != null) shipperProfilesMap.put(acc.getId(), sp);
            } else if (rid == 3) {
                UserProfile up = userProfileDAO.findByAccountId(acc.getId());
                if (up != null) userProfilesMap.put(acc.getId(), up);
            }
        }

        req.setAttribute("shopProfilesMap", shopProfilesMap);
        req.setAttribute("shipperProfilesMap", shipperProfilesMap);
        req.setAttribute("userProfilesMap", userProfilesMap);
    }

    private boolean updateAccount(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long id = parseId(req);
        if (id == null) {
            return fail(req, resp, "ID account không hợp lệ", null);
        }

        Account currentUser = getLoggedInAccount(req);
        Account targetAccount = dao.findById(id);

        //Kiểm tra targetAccount tồn tại
        if (targetAccount == null) {
            return fail(req, resp, "Không tìm thấy account", null);
        }

        // 🔒 QUAN TRỌNG: Không cho sửa SUPER_ADMIN khác (trừ chính mình)
        if (targetAccount.getRoleId() == 1 && !isCurrentUserTheSameAccount(req, id)) {
            return fail(req, resp, "Không thể sửa thông tin tài khoản SUPER_ADMIN khác!", null);
        }

        // Không cho tự sửa quyền của chính mình
        long newRoleId = parseRoleId(req);
        if (isCurrentUserTheSameAccount(req, id) && newRoleId != 1) {
            return fail(req, resp, "Bạn không thể tự thay đổi quyền của chính mình!", null);
        }

        Account currentAccount = dao.findById(id);
        if (currentAccount == null) {
            return fail(req, resp, "Không tìm thấy account", null);
        }

        Account account = readAccount(req);
        account.setId(id);
        String password = normalize(req.getParameter("password"));

        String error = validateAccount(account, password, true);
        if (error != null) {
            return fail(req, resp, error, account);
        }

        // Check trùng username (loại trừ chính id đang sửa)
        if (dao.tonTaiUsernameKhacId(account.getUserName(), id)) {
            return fail(req, resp, "Username đã tồn tại", account);
        }

        // Check trùng email (loại trừ chính id đang sửa)
        if (dao.tonTaiEmailKhacId(account.getEmail(), id)) {
            return fail(req, resp, "Email đã tồn tại", account);
        }

        account.setPassWord(password.isBlank() ? null : BCrypt.hashpw(password, BCrypt.gensalt(12)));
        boolean updated = dao.update(account);
        if (!updated) {
            return fail(req, resp, "Lỗi cập nhật account", account);
        }

        auditLogService.log(req, currentUser, "Cập nhật tài khoản", AuditModules.ACCOUNT,
                "Super Admin " + currentUser.getUserName() + " đã cập nhật tài khoản \"" + account.getUserName() + "\" (ID=" + id + ")",
                id, AuditModules.ACCOUNT);

        return true;
    }

    private boolean deleteAccount(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long id = parseId(req);
        if (id == null) {
            return fail(req, resp, "ID account không hợp lệ", null);
        }

        Account currentUser = getLoggedInAccount(req);
        Account targetAccount = dao.findById(id);

        if (targetAccount == null) {
            return fail(req, resp, "Không tìm thấy account", null);
        }

        if (currentUser != null && currentUser.getId() == id) {
            return fail(req, resp, "Không thể xóa chính tài khoản đang đăng nhập", null);
        }

        // Không cho xóa SUPER_ADMIN khác
        if (targetAccount.getRoleId() == 1) {
            return fail(req, resp, "Không thể xóa tài khoản SUPER_ADMIN!", null);
        }

        String deleteType = req.getParameter("deleteType");
        boolean deleted;
        String reason = null;
        if ("hard".equals(deleteType)) {
            deleted = dao.delete(id);
        } else {
            reason = req.getParameter("suspendReason");
            deleted = dao.softDelete(id, reason);
        }

        if (!deleted) {
            return fail(req, resp, "Lỗi xóa account", null);
        }

        if ("hard".equals(deleteType)) {
            auditLogService.log(req, currentUser, "Xóa tài khoản", AuditModules.ACCOUNT,
                    "Super Admin " + currentUser.getUserName() + " đã xóa vĩnh viễn tài khoản \"" + targetAccount.getUserName() + "\" (ID=" + id + ")",
                    id, AuditModules.ACCOUNT);
        } else {
            String description = "Super Admin " + currentUser.getUserName() + " đã khóa tài khoản \"" + targetAccount.getUserName() + "\" (ID=" + id + ")"
                    + (reason != null && !reason.isBlank() ? ". Lý do: " + reason : "");
            auditLogService.log(req, currentUser, "Khóa tài khoản", AuditModules.ACCOUNT,
                    description, id, AuditModules.ACCOUNT);
        }

        return true;
    }

    private Account readAccount(HttpServletRequest req) {
        Account account = new Account();
        account.setUserName(normalize(req.getParameter("username")));
        account.setEmail(normalize(req.getParameter("email")));
        account.setFullName(normalize(req.getParameter("fullname")));
        account.setPhone(normalize(req.getParameter("phone")));
        account.setAvatarUrl(normalize(req.getParameter("avatarurl")));
        account.setRoleId(parseRoleId(req));
        return account;
    }

    private String validateAccount(Account account, String password, boolean updating) {
        String textError = org.example.utils.InputValidationUtil.firstError(
                org.example.utils.InputValidationUtil.checkLine("Username", account.getUserName(), 100),
                org.example.utils.InputValidationUtil.checkLine("Email", account.getEmail(), 100),
                org.example.utils.InputValidationUtil.checkLine("Họ tên", account.getFullName(), org.example.utils.InputValidationUtil.MAX_PERSON_NAME),
                org.example.utils.InputValidationUtil.checkPhone("Số điện thoại", account.getPhone()));
        if (textError != null) {
            return textError;
        }
        if (account.getUserName().isBlank()) {
            return "Username không được để trống";
        }

        if (account.getEmail().isBlank()) {
            return "Email không được để trống";
        }

        if (!updating && password.isBlank()) {
            return "Mật khẩu không được để trống";
        }

        // Chi ap dung khi TAO MOI: khong cho phep tao thang role 3 (USER/CUSTOMER) vi customer
        // tu dang ky, khong phai admin tao tay. Khi SUA (updating=true) van phai cho giu nguyen
        // role 3 cua cac tai khoan khach hang co san, neu khong nut "Sua" se luon bao loi voi
        // moi tai khoan khach hang (da so tai khoan trong he thong).
        if (!updating && account.getRoleId() != 1 && account.getRoleId() != 2 && account.getRoleId() != 4) {
            return "Chỉ được tạo tài khoản ADMIN, SHOP hoặc SHIPPER! (Customer tự đăng ký)";
        }

        return null;
    }

    private boolean fail(HttpServletRequest req, HttpServletResponse resp, String message, Account accountForm)
            throws ServletException, IOException {
        req.setAttribute("loi", message);
        if (accountForm != null && accountForm.getId() > 0) {
            req.setAttribute("accountSua", accountForm);
        } else {
            req.setAttribute("accountForm", accountForm);
        }
        forwardAccountPage(req, resp);
        return false;
    }

    private boolean requireAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Account account = getLoggedInAccount(req);
        if (account == null || account.getRoleId() != 1) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return false;
        }

        return true;
    }

    private Account getLoggedInAccount(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (Account) session.getAttribute("account");
    }

    private Long parseId(HttpServletRequest req) {
        try {
            return Long.parseLong(req.getParameter("id"));
        } catch (Exception e) {
            return null;
        }
    }

    private long parseRoleId(HttpServletRequest req) {
        try {
            return Long.parseLong(req.getParameter("roleid"));
        } catch (Exception e) {
            return 0;
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean isCurrentUserTheSameAccount(HttpServletRequest req, Long accountId) {
        Account currentUser = getLoggedInAccount(req);
        return currentUser != null && currentUser.getId() == accountId;
    }
}