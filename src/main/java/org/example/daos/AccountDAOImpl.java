package org.example.daos;

import org.example.models.Account;
import org.example.utils.DBUtil;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AccountDAOImpl implements AccountDAO {
    @Override
    public Boolean dangkyNguoiDung(String username, String password, String email, String fullname, String phone) {
        String sql = "INSERT INTO Accounts (username, password, email, full_name, phone, role_id) VALUES (?, ?, ?, ?, ?, 3)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, username);
            pst.setString(2, password);
            pst.setString(3, email);
            pst.setNString(4, fullname);
            pst.setString(5, phone);
            return pst.executeUpdate() == 1;

        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public Boolean tonTaiEmail(String email) {
        String sql = "SELECT 1 FROM Accounts WHERE email = ?";
        return exists(sql, email);
    }

    @Override
    public Boolean tonTaiUsername(String username) {
        String sql = "SELECT 1 FROM Accounts WHERE username = ?";
        return exists(sql, username);
    }

    @Override
    public Boolean tonTaiEmailKhacId(String email, long id) {
        String sql = "SELECT 1 FROM Accounts WHERE email = ? AND id <> ?";
        return exists(sql, email, id);
    }

    @Override
    public Boolean tonTaiUsernameKhacId(String username, long id) {
        String sql = "SELECT 1 FROM Accounts WHERE username = ? AND id <> ?";
        return exists(sql, username, id);
    }

    @Override
    public Boolean capNhatMatKhauTheoEmail(String email, String password) {
        if (password == null || !password.matches("^\\$2[aby]\\$.{56}$")) {
            System.err.println("capNhatMatKhauTheoEmail: tu choi luu password khong dung dinh dang BCrypt hash cho email=" + email);
            return false;
        }
        String sql = "UPDATE Accounts SET password = ? WHERE email = ?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, password);
            pst.setString(2, email);
            return pst.executeUpdate() == 1;

        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public Account DangNhap(String username, String password) {
        // Lấy các cột cơ bản + is_deleted (luôn tồn tại)
        String sql = "SELECT id, username, password, email, full_name, phone, avatar_url, role_id, is_deleted, status, logo_url FROM Accounts WHERE username = ?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, username);

            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    Account acc = mapAccount(rs);
                    acc.setDeleted(rs.getBoolean("is_deleted"));
                    acc.setStaTus(rs.getString("status"));

                    if (!BCrypt.checkpw(password, acc.getPassWord())) {
                        return null;
                    }

                    // Nếu bị đình chỉ, lấy thêm lý do (cột có thể chưa tồn tại → bỏ qua lỗi)
                    if (acc.isDeleted()) {
                        try (PreparedStatement p2 = con.prepareStatement(
                                "SELECT suspend_reason FROM Accounts WHERE id = ?")) {
                            p2.setLong(1, acc.getId());
                            try (ResultSet rs2 = p2.executeQuery()) {
                                if (rs2.next()) acc.setSuspendReason(rs2.getString("suspend_reason"));
                            }
                        } catch (Exception ignored) {}
                    }

                    return acc;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public List<Account> getAll() {
        String sql = "SELECT id, username, password, email, full_name, phone, avatar_url, role_id FROM Accounts ORDER BY id DESC";
        List<Account> danhsach = new ArrayList<>();

        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            while (rs.next()) {
                danhsach.add(mapAccount(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return danhsach;
    }

    @Override
    public Account findById(long id) {
        String sql = "SELECT id, username, password, email, full_name, phone, avatar_url, role_id, logo_url, created_at FROM Accounts WHERE id = ?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setLong(1, id);

            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return mapAccount(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public Boolean create(Account account) {
        String sql = "INSERT INTO Accounts (username, password, email, full_name, phone, avatar_url, role_id) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, account.getUserName());
            pst.setString(2, account.getPassWord());
            pst.setString(3, account.getEmail());
            pst.setNString(4, account.getFullName());
            pst.setString(5, account.getPhone());
            pst.setString(6, account.getAvatarUrl());
            pst.setLong(7, account.getRoleId());
            return pst.executeUpdate() == 1;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public long createAndReturnId(Account account) {
        String sql = "INSERT INTO Accounts (username, password, email, full_name, phone, avatar_url, role_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, account.getUserName());
            ps.setString(2, account.getPassWord());
            ps.setString(3, account.getEmail());
            ps.setNString(4, account.getFullName());
            ps.setString(5, account.getPhone());
            ps.setString(6, account.getAvatarUrl());
            ps.setLong(7, account.getRoleId());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0L;
    }

    @Override
    public Boolean update(Account account) {
        boolean updatePassword = account.getPassWord() != null && !account.getPassWord().isBlank();
        String sql = updatePassword
                ? "UPDATE Accounts SET username = ?, email = ?, full_name = ?, phone = ?, avatar_url = ?, role_id = ?, password = ? WHERE id = ?"
                : "UPDATE Accounts SET username = ?, email = ?, full_name = ?, phone = ?, avatar_url = ?, role_id = ? WHERE id = ?";

        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, account.getUserName());
            pst.setString(2, account.getEmail());
            pst.setNString(3, account.getFullName());
            pst.setString(4, account.getPhone());
            pst.setString(5, account.getAvatarUrl());
            pst.setLong(6, account.getRoleId());

            if (updatePassword) {
                pst.setString(7, account.getPassWord());
                pst.setLong(8, account.getId());
            } else {
                pst.setLong(7, account.getId());
            }

            return pst.executeUpdate() == 1;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Boolean delete(long id) {
        // "Xóa cứng" = xóa toàn bộ dữ liệu cá nhân + vô hiệu hóa tài khoản & shop.
        // Không xóa row khỏi DB để tránh vi phạm FK với Orders/Shops.
        try (Connection con = DBUtil.getConnection()) {
            con.setAutoCommit(false);
            try {
                // 1. Xóa dữ liệu không có FK chặn
                exec(con, "DELETE FROM Account_Appeals WHERE account_id = ?", id);
                exec(con, "DELETE FROM Notifications WHERE account_id = ?", id);
                exec(con, "DELETE FROM Feedbacks WHERE reviewer_id = ?", id);
                exec(con, "DELETE FROM Shipper_Profiles WHERE account_id = ?", id);
                exec(con, "DELETE FROM User_Profiles WHERE account_id = ?", id);

                // 2. Bỏ liên kết shipper khỏi đơn hàng (cột cho phép NULL)
                exec(con, "UPDATE Orders SET shipper_id = NULL WHERE shipper_id = ?", id);

                // 3. Vô hiệu hóa shop (nếu có) — giữ row để FK Orders.shop_id không vỡ
                exec(con, "UPDATE Shops SET is_deleted = 1 WHERE owner_id = ?", id);

                // 4. Ẩn danh + vô hiệu hóa tài khoản — xóa toàn bộ thông tin cá nhân
                String anonymize =
                    "UPDATE Accounts SET " +
                    "  username   = CONCAT('deleted_', id), " +
                    "  email      = CONCAT('deleted_', id, '@removed.invalid'), " +
                    "  password   = 'DELETED', " +
                    "  full_name  = N'Tài khoản đã xóa', " +
                    "  phone      = NULL, " +
                    "  avatar_url = NULL, " +
                    "  is_deleted = 1 " +
                    "WHERE id = ?";
                exec(con, anonymize, id);

                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                e.printStackTrace();
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private void exec(Connection con, String sql, long param) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, param);
            ps.executeUpdate();
        }
    }

    private boolean hasRows(Connection con, String sql, long param) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    @Override
    public Boolean softDelete(long id, String reason) {
        // Bước 1: set is_deleted = 1 (cột luôn tồn tại)
        String sql1 = "UPDATE Accounts SET is_deleted = 1 WHERE id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql1)) {
            pst.setLong(1, id);
            boolean ok = pst.executeUpdate() == 1;
            if (!ok) return false;

            // Bước 2: lưu lý do (cột có thể chưa tồn tại → bỏ qua lỗi)
            try (PreparedStatement p2 = con.prepareStatement(
                    "UPDATE Accounts SET suspend_reason = ? WHERE id = ?")) {
                p2.setString(1, reason != null && !reason.isBlank() ? reason : "Vi phạm điều khoản sử dụng");
                p2.setLong(2, id);
                p2.executeUpdate();
            } catch (Exception ignored) {}

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public int getTotalAccounts() {
        String sql = "SELECT COUNT(*) FROM Accounts WHERE is_deleted = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public boolean isBlockedOrDeleted(long accountId) {
        String sql = "SELECT is_deleted, status FROM Accounts WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    boolean deleted = rs.getBoolean("is_deleted");
                    String status = rs.getString("status");
                    return deleted || "BLOCKED".equalsIgnoreCase(status);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public int countSuspendedAccounts() {
        String sql = "SELECT COUNT(*) FROM Accounts WHERE is_deleted = 1 OR status = 'BLOCKED'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int countActiveShippers() {
        String sql = "SELECT COUNT(*) FROM Accounts WHERE role_id = 4 AND status = 'ACTIVE' AND is_deleted = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public List<Account> searchByUsernameOrEmail(String keyword) {
        List<Account> accounts = new ArrayList<>();
        String sql = "SELECT * FROM Accounts WHERE is_deleted = 0 " +
                "AND (username LIKE ? OR email LIKE ?) " +
                "ORDER BY id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Account account = new Account();
                account.setId(rs.getLong("id"));
                account.setUserName(rs.getString("username"));
                account.setPassWord(rs.getString("password"));
                account.setEmail(rs.getString("email"));
                account.setFullName(rs.getString("full_name"));
                account.setPhone(rs.getString("phone"));
                account.setAvatarUrl(rs.getString("avatar_url"));
                account.setRoleId(rs.getLong("role_id"));
                account.setStaTus(rs.getString("status"));
                account.setDeleted(rs.getBoolean("is_deleted"));

                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                if (createdAt != null) {
                    account.setCreatedAt(createdAt.toLocalDateTime());
                }
                java.sql.Timestamp updatedAt = rs.getTimestamp("updated_at");
                if (updatedAt != null) {
                    account.setUpdatedAt(updatedAt.toLocalDateTime());
                }

                accounts.add(account);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return accounts;
    }

    @Override
    public List<Account> getAll(String sortField, String sortOrder) {
        List<Account> accounts = new ArrayList<>();

        // Xác định cột sắp xếp
        String orderBy = "id";
        if (sortField != null) {
            switch (sortField) {
                case "username":
                    orderBy = "username";
                    break;
                case "fullname":
                    orderBy = "full_name";
                    break;
                case "email":
                    orderBy = "email";
                    break;
                case "role":
                    orderBy = "role_id";
                    break;
                case "id":
                default:
                    orderBy = "id";
                    break;
            }
        }

        // Xác định thứ tự sắp xếp
        String order = "DESC";
        if ("ASC".equalsIgnoreCase(sortOrder)) {
            order = "ASC";
        }

        String sql = "SELECT * FROM Accounts WHERE is_deleted = 0 ORDER BY " + orderBy + " " + order;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Account account = new Account();
                account.setId(rs.getLong("id"));
                account.setUserName(rs.getString("username"));
                account.setPassWord(rs.getString("password"));
                account.setEmail(rs.getString("email"));
                account.setFullName(rs.getString("full_name"));
                account.setPhone(rs.getString("phone"));
                account.setAvatarUrl(rs.getString("avatar_url"));
                account.setRoleId(rs.getLong("role_id"));
                account.setStaTus(rs.getString("status"));
                account.setDeleted(rs.getBoolean("is_deleted"));

                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                if (createdAt != null) {
                    account.setCreatedAt(createdAt.toLocalDateTime());
                }
                java.sql.Timestamp updatedAt = rs.getTimestamp("updated_at");
                if (updatedAt != null) {
                    account.setUpdatedAt(updatedAt.toLocalDateTime());
                }

                accounts.add(account);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return accounts;
    }

    @Override
    public List<Account> searchByUsernameOrEmail(String keyword, String sortField, String sortOrder) {
        List<Account> accounts = new ArrayList<>();

        // Xác định cột sắp xếp
        String orderBy = "id";
        if (sortField != null) {
            switch (sortField) {
                case "username":
                    orderBy = "username";
                    break;
                case "fullname":
                    orderBy = "full_name";
                    break;
                case "email":
                    orderBy = "email";
                    break;
                case "role":
                    orderBy = "role_id";
                    break;
                case "id":
                default:
                    orderBy = "id";
                    break;
            }
        }

        // Xác định thứ tự sắp xếp
        String order = "DESC";
        if ("ASC".equalsIgnoreCase(sortOrder)) {
            order = "ASC";
        }

        String sql = "SELECT * FROM Accounts WHERE is_deleted = 0 " +
                "AND (username LIKE ? OR email LIKE ?) " +
                "ORDER BY " + orderBy + " " + order;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Account account = new Account();
                account.setId(rs.getLong("id"));
                account.setUserName(rs.getString("username"));
                account.setPassWord(rs.getString("password"));
                account.setEmail(rs.getString("email"));
                account.setFullName(rs.getString("full_name"));
                account.setPhone(rs.getString("phone"));
                account.setAvatarUrl(rs.getString("avatar_url"));
                account.setRoleId(rs.getLong("role_id"));
                account.setStaTus(rs.getString("status"));
                account.setDeleted(rs.getBoolean("is_deleted"));

                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                if (createdAt != null) {
                    account.setCreatedAt(createdAt.toLocalDateTime());
                }
                java.sql.Timestamp updatedAt = rs.getTimestamp("updated_at");
                if (updatedAt != null) {
                    account.setUpdatedAt(updatedAt.toLocalDateTime());
                }

                accounts.add(account);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return accounts;
    }

    private Boolean exists(String sql, String value) {
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, value);

            try (ResultSet rs = pst.executeQuery()) {
                return rs.next();
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            return true;
        }
    }

    @Override
    public boolean updateAvatar(long id, String avatarUrl) {
        String sql = "UPDATE Accounts SET avatar_url = ? WHERE id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, avatarUrl);
            pst.setLong(2, id);
            return pst.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateLogo(long id, String logoUrl) {
        String sql = "UPDATE Accounts SET logo_url = ? WHERE id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, logoUrl);
            pst.setLong(2, id);
            return pst.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Boolean exists(String sql, String value, long id) {
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, value);
            pst.setLong(2, id);

            try (ResultSet rs = pst.executeQuery()) {
                return rs.next();
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            return true;
        }
    }

    private Account mapAccount(ResultSet rs) throws SQLException {
        Account acc = new Account();
        acc.setAvatarUrl(rs.getString("avatar_url"));
        acc.setEmail(rs.getString("email"));
        acc.setId(rs.getLong("id"));
        acc.setPassWord(rs.getString("password"));
        acc.setFullName(rs.getString("full_name"));
        acc.setPhone(rs.getString("phone"));
        acc.setRoleId(rs.getLong("role_id"));
        acc.setUserName(rs.getString("username"));
        try { acc.setOnline(rs.getBoolean("is_online")); } catch (SQLException ignored) {}
        try { acc.setLogoUrl(rs.getString("logo_url")); } catch (SQLException ignored) {}
        try {
            java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
            if (createdAt != null) acc.setCreatedAt(createdAt.toLocalDateTime());
        } catch (SQLException ignored) {}
        return acc;
    }

    @Override
    public int countPendingShopAccounts() {
        String sql = "SELECT COUNT(*) FROM Accounts WHERE role_id = 2 AND (status IS NULL OR status <> 'ACTIVE') AND is_deleted = 0";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public List<Account> findTop5PendingShopAccounts() {
        List<Account> list = new ArrayList<>();
        String sql = "SELECT TOP 5 * FROM Accounts WHERE role_id = 2 AND (status IS NULL OR status <> 'ACTIVE') AND is_deleted = 0 ORDER BY created_at DESC";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            while (rs.next()) {
                list.add(mapAccountFull(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Account> findPendingShipperAccounts() {
        List<Account> list = new ArrayList<>();
        String sql = "SELECT * FROM Accounts WHERE role_id = 4 AND status = 'PENDING' AND is_deleted = 0 ORDER BY created_at DESC";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            while (rs.next()) {
                list.add(mapAccountFull(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Account> findOnlineShippers() {
        List<Account> list = new ArrayList<>();
        String sql = "SELECT * FROM Accounts WHERE role_id = 4 AND status = 'ACTIVE' AND is_deleted = 0 AND is_online = 1 ORDER BY full_name ASC";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            while (rs.next()) {
                list.add(mapAccountFull(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Account> findPendingShopAccounts() {
        List<Account> list = new ArrayList<>();
        String sql = "SELECT a.* FROM Accounts a INNER JOIN Shops s ON s.owner_id = a.id WHERE s.is_deleted = 0 AND a.is_deleted = 0 AND LOWER(s.status) = 'pending' ORDER BY a.created_at DESC";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            while (rs.next()) {
                list.add(mapAccountFull(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean updateAccountStatus(long accountId, String status) {
        String sql = "UPDATE Accounts SET status = ?, updated_at = GETDATE() WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, accountId);
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateShipperOnlineStatus(long accountId, boolean isOnline) {
        String sql = "UPDATE Accounts SET is_online = ?, updated_at = GETDATE() WHERE id = ? AND role_id = 4";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isOnline);
            ps.setLong(2, accountId);
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Account mapAccountFull(ResultSet rs) throws SQLException {
        Account account = new Account();
        account.setId(rs.getLong("id"));
        account.setUserName(rs.getString("username"));
        account.setPassWord(rs.getString("password"));
        account.setEmail(rs.getString("email"));
        account.setFullName(rs.getString("full_name"));
        account.setPhone(rs.getString("phone"));
        account.setAvatarUrl(rs.getString("avatar_url"));
        account.setRoleId(rs.getLong("role_id"));
        account.setStaTus(rs.getString("status"));
        account.setDeleted(rs.getBoolean("is_deleted"));
        try { account.setOnline(rs.getBoolean("is_online")); } catch (SQLException ignored) {}
        try { account.setLogoUrl(rs.getString("logo_url")); } catch (SQLException ignored) {}

        java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            account.setCreatedAt(createdAt.toLocalDateTime());
        }
        java.sql.Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            account.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        return account;
    }

    @Override
    public int getLoyaltyPoints(long accountId) {
        String sql = "SELECT loyalty_points FROM Accounts WHERE id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setLong(1, accountId);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) return rs.getInt("loyalty_points");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public boolean addLoyaltyPoints(long accountId, int delta) {
        // Chan diem am ngay trong dieu kien UPDATE (giong pattern incrementUsedCount cua Voucher) —
        // tranh race condition khi 2 request tru diem gan nhu dong thoi lam am diem.
        String sql = "UPDATE Accounts SET loyalty_points = loyalty_points + ? WHERE id = ? AND loyalty_points + ? >= 0";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setInt(1, delta);
            pst.setLong(2, accountId);
            pst.setInt(3, delta);
            return pst.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
