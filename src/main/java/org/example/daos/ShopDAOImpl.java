package org.example.daos;

import org.example.models.DailyOrderStat;
import org.example.models.Shop;
import org.example.models.ShopRevenueStat;
import org.example.utils.DBUtil;
import org.example.utils.EncryptionUtil;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class ShopDAOImpl implements ShopDAO {


    private static final String SELECT_ALL = "SELECT * FROM Shops WHERE is_deleted = 0";
    private static final String SELECT_PENDING = "SELECT * FROM Shops WHERE is_deleted = 0 AND status = 'PENDING' ORDER BY created_at DESC";
    private static final String SELECT_BY_ID = "SELECT * FROM Shops WHERE id = ? AND is_deleted = 0";
    private static final String SELECT_BY_OWNER_ID = "SELECT TOP 1 * FROM Shops WHERE owner_id = ? AND is_deleted = 0 ORDER BY id DESC";

    private static final String INSERT = "INSERT INTO Shops (owner_id, shop_name, shop_description, shop_address, shop_phone, shop_logo, status, rejection_reason, approved_by, approved_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String UPDATE = "UPDATE Shops SET owner_id = ?, shop_name = ?, shop_description = ?, shop_address = ?, shop_phone = ?, shop_logo = ?, status = ?, rejection_reason = ?, approved_by = ?, approved_at = ?, client_key = ?, api_key = ?, check_sum_key = ?, locationX = ?, locationY = ?, open_time = ?, close_time = ?, updated_at = GETDATE() WHERE id = ?";

    private static final String UPDATE_APPROVAL = "UPDATE Shops SET status = ?, rejection_reason = ?, approved_by = ?, approved_at = GETDATE(), updated_at = GETDATE() WHERE id = ? AND is_deleted = 0";

    private static final String DELETE_SOFT = "UPDATE Shops SET is_deleted = 1, updated_at = GETDATE() WHERE id = ?";

    private static final String SEARCH_BY_PRODUCT =
            "SELECT DISTINCT s.* FROM Shops s " +
            "JOIN Products p ON p.shop_id = s.id " +
            "WHERE p.product_name LIKE ? AND p.is_deleted = 0 " +
            "AND UPPER(p.status) <> 'HIDDEN' AND s.is_deleted = 0";

    @Override
    public List<org.example.models.Shop> selectAllShops() {
        List<Shop> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_ALL);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToShop(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Shop> selectPendingShops() {
        List<Shop> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_PENDING);
             ResultSet rs = ps.executeQuery()) {


            while (rs.next()) {
                list.add(mapResultSetToShop(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Shop selectShopById(long id) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BY_ID)) {

            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToShop(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Shop selectShopByOwnerId(long ownerId) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BY_OWNER_ID)) {

            ps.setLong(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToShop(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public void insertShop(Shop shop) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(INSERT)) {

            ps.setLong(1, shop.getOwnerId());
            ps.setString(2, shop.getShopName());
            ps.setString(3, shop.getShopDescription());
            ps.setString(4, shop.getShopAddress());
            ps.setString(5, shop.getShopPhone());
            ps.setString(6, shop.getShopLogo());

            ps.setString(7, (shop.getStatus() != null && !shop.getStatus().isEmpty()) ? shop.getStatus() : "pending");
            ps.setString(8, shop.getRejectionReason());

            if (shop.getApprovedBy() > 0) {
                ps.setLong(9, shop.getApprovedBy());
            } else {
                ps.setNull(9, Types.BIGINT);
            }

            ps.setTimestamp(10, shop.getApproveDate() != null ? Timestamp.valueOf(shop.getApproveDate()) : null);

            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void updateShop(Shop shop) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(UPDATE)) {

            ps.setLong(1, shop.getOwnerId());
            ps.setString(2, shop.getShopName());
            ps.setString(3, shop.getShopDescription());
            ps.setString(4, shop.getShopAddress());
            ps.setString(5, shop.getShopPhone());
            ps.setString(6, shop.getShopLogo());
            ps.setString(7, (shop.getStatus() != null && !shop.getStatus().isEmpty()) ? shop.getStatus() : "pending");
            ps.setString(8, shop.getRejectionReason());

            if (shop.getApprovedBy() > 0) {
                ps.setLong(9, shop.getApprovedBy());
            } else {
                ps.setNull(9, Types.BIGINT);
            }

            ps.setTimestamp(10, shop.getApproveDate() != null ? Timestamp.valueOf(shop.getApproveDate()) : null);
            ps.setString(11, EncryptionUtil.encrypt(shop.getClientKey()));
            ps.setString(12, EncryptionUtil.encrypt(shop.getApiKey()));
            ps.setString(13, EncryptionUtil.encrypt(shop.getCheckSumKey()));
            if (shop.getLocationX() != null) {
                ps.setDouble(14, shop.getLocationX());
            } else {
                ps.setNull(14, Types.DECIMAL);
            }
            if (shop.getLocationY() != null) {
                ps.setDouble(15, shop.getLocationY());
            } else {
                ps.setNull(15, Types.DECIMAL);
            }
            if (shop.getOpenTime() != null) {
                ps.setTime(16, Time.valueOf(shop.getOpenTime()));
            } else {
                ps.setNull(16, Types.TIME);
            }
            if (shop.getCloseTime() != null) {
                ps.setTime(17, Time.valueOf(shop.getCloseTime()));
            } else {
                ps.setNull(17, Types.TIME);
            }
            ps.setLong(18, shop.getId()); // ID de tim ban ghi can update

            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean updateShopApproval(long shopId, String status, String rejectionReason, long approvedBy) {



        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(UPDATE_APPROVAL)) {

            ps.setString(1, status);
            ps.setString(2, rejectionReason);
            ps.setLong(3, approvedBy);
            ps.setLong(4, shopId);
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public void deleteShop(long id) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(DELETE_SOFT)) {

            ps.setLong(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int countPendingShops() {
        String sql = "SELECT COUNT(*) FROM Shops WHERE status = 'PENDING' AND is_deleted = 0";
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
    public int countBlockedShops() {
        String sql = "SELECT COUNT(*) FROM Shops WHERE status = 'BLOCKED'";
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
    public List<Shop> findTop5PendingShops() {
        List<Shop> shops = new ArrayList<>();
        String sql = "SELECT DISTINCT TOP 5 id, shop_name, shop_address, shop_phone, created_at " +
                "FROM Shops WHERE status = 'PENDING' AND is_deleted = 0 " +
                "ORDER BY created_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Shop shop = new Shop();
                shop.setId(rs.getLong("id"));
                shop.setShopName(rs.getString("shop_name"));
                shop.setShopAddress(rs.getString("shop_address"));
                shop.setShopPhone(rs.getString("shop_phone"));
                //Timestamp thành LocalDateTime.
                java.sql.Timestamp timestamp = rs.getTimestamp("created_at");
                if (timestamp != null) {
                    shop.setCreatedAt(timestamp.toLocalDateTime());
                }

                shops.add(shop);

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return shops;
    }

    @Override
    public double getTotalRevenue() {
        String sql = "SELECT ISNULL(SUM(total_price), 0) FROM Orders WHERE status = 'DONE'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0D;
    }

    @Override
    public List<ShopRevenueStat> findTop5ShopsByRevenue() {
        List<ShopRevenueStat> result = new ArrayList<>();
        String sql = "SELECT TOP 5 s.shop_name, COUNT(o.id) AS tong_don, " +
                "ISNULL(SUM(CASE WHEN o.status = 'DONE' THEN o.total_price ELSE 0 END), 0) AS doanh_thu " +
                "FROM Shops s " +
                "LEFT JOIN Orders o ON o.shop_id = s.id " +
                "WHERE s.is_deleted = 0 " +
                "GROUP BY s.id, s.shop_name " +
                "ORDER BY doanh_thu DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.add(new ShopRevenueStat(
                        rs.getString("shop_name"),
                        rs.getInt("tong_don"),
                        rs.getDouble("doanh_thu")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    @Override
    public List<DailyOrderStat> findDailyOrderStats(int days) {
        String sql = "SELECT CAST(created_at AS DATE) AS ngay, " +
                "COUNT(CASE WHEN status = 'DONE' THEN 1 END) AS don_thanh_cong, " +
                "COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) AS don_huy, " +
                "ISNULL(SUM(CASE WHEN status = 'DONE' THEN total_price ELSE 0 END), 0) AS doanh_thu " +
                "FROM Orders " +
                "WHERE created_at >= DATEADD(DAY, ?, CAST(GETDATE() AS DATE)) " +
                "GROUP BY CAST(created_at AS DATE)";

        DateTimeFormatter labelFormat = DateTimeFormatter.ofPattern("dd/MM");
        Map<LocalDate, DailyOrderStat> byDate = new HashMap<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, -(days - 1));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDate date = rs.getDate("ngay").toLocalDate();
                    byDate.put(date, new DailyOrderStat(
                            date.format(labelFormat),
                            rs.getInt("don_thanh_cong"),
                            rs.getInt("don_huy"),
                            rs.getDouble("doanh_thu")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        List<DailyOrderStat> result = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (int i = days - 1; i >= 0; i--) {
            LocalDate day = today.minusDays(i);
            DailyOrderStat stat = byDate.get(day);
            result.add(stat != null ? stat : new DailyOrderStat(day.format(labelFormat), 0, 0, 0D));
        }
        return result;
    }

    @Override
    public boolean updateCommissionRate(long shopId, Double commissionRate) {
        String sql = "UPDATE Shops SET commission_rate = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (commissionRate != null) {
                ps.setDouble(1, commissionRate);
            } else {
                ps.setNull(1, Types.DECIMAL);
            }
            ps.setLong(2, shopId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateBankInfo(long shopId, String bankCode, String bankAccountNumber, String bankAccountName) {
        String sql = "UPDATE Shops SET bank_code = ?, bank_account_number = ?, bank_account_name = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, bankCode);
            ps.setString(2, bankAccountNumber);
            ps.setString(3, bankAccountName);
            ps.setLong(4, shopId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<Shop> searchShopsByProductName(String keyword) {
        List<Shop> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SEARCH_BY_PRODUCT)) {

            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToShop(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Ánh xạ chuẩn xác từ tên cột Snake_case của SQL Server sang các hàm Setter của Model Java
    private Shop mapResultSetToShop(ResultSet rs) throws SQLException {
        Shop shop = new Shop();

        shop.setId(rs.getLong("id"));
        shop.setOwnerId(rs.getLong("owner_id"));
        shop.setShopName(rs.getString("shop_name"));
        shop.setShopDescription(rs.getString("shop_description"));
        shop.setShopAddress(rs.getString("shop_address"));
        shop.setShopPhone(rs.getString("shop_phone"));
        shop.setShopLogo(rs.getString("shop_logo"));
        shop.setStatus(rs.getString("status"));
        shop.setRejectionReason(rs.getString("rejection_reason"));
        shop.setApprovedBy(rs.getLong("approved_by"));
        shop.setClientKey(EncryptionUtil.decrypt(rs.getString("client_key")));
        shop.setApiKey(EncryptionUtil.decrypt(rs.getString("api_key")));
        shop.setCheckSumKey(EncryptionUtil.decrypt(rs.getString("check_sum_key")));
        shop.setLocationX(rs.getObject("locationX", Double.class));
        shop.setLocationY(rs.getObject("locationY", Double.class));

        Time openTime = rs.getTime("open_time");
        if (openTime != null) shop.setOpenTime(openTime.toLocalTime());
        Time closeTime = rs.getTime("close_time");
        if (closeTime != null) shop.setCloseTime(closeTime.toLocalTime());
        try {
            double commissionRate = rs.getDouble("commission_rate");
            if (!rs.wasNull()) shop.setCommissionRate(commissionRate);
        } catch (SQLException e) {
            // "S0022" = invalid column name (cot chua ton tai vi chua chay migration_shop_commission_rate.sql,
            // truong hop nay khong can log). Cac loi khac (mat ket noi, timeout...) van log de khong nuot am tham.
            if (!"S0022".equals(e.getSQLState())) {
                e.printStackTrace();
            }
        }
        try {
            shop.setBankCode(rs.getString("bank_code"));
            shop.setBankAccountNumber(rs.getString("bank_account_number"));
            shop.setBankAccountName(rs.getString("bank_account_name"));
        } catch (SQLException e) {
            // Chua chay migration_shop_bank_info.sql thi bo qua, khong log
            if (!"S0022".equals(e.getSQLState())) {
                e.printStackTrace();
            }
        }

        // Xử lý các cột thời gian dạng DATETIME2
        Timestamp approvedAtTs = rs.getTimestamp("approved_at");
        if (approvedAtTs != null) {
            shop.setApproveDate(approvedAtTs.toLocalDateTime());
        }

        shop.setDeleted(rs.getBoolean("is_deleted"));

        Timestamp createdAtTs = rs.getTimestamp("created_at");
        if (createdAtTs != null) {
            shop.setCreatedAt(createdAtTs.toLocalDateTime());
        }

        Timestamp updatedAtTs = rs.getTimestamp("updated_at");
        if (updatedAtTs != null) {
            shop.setUpdatedAt(updatedAtTs.toLocalDateTime());
        }

        return shop;
    }
}
