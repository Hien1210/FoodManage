package org.example.daos;

import org.example.models.UserAddress;
import org.example.utils.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserAddressDAOImpl implements UserAddressDAO {

    private static final String SELECT_COLS =
        "id, account_id, label, full_address, receiver_name, receiver_phone, is_default, created_at";

    @Override
    public List<UserAddress> findByAccountId(long accountId) {
        List<UserAddress> list = new ArrayList<>();
        String sql = "SELECT id, account_id, label, full_address, receiver_name, receiver_phone, is_default, created_at, locationX, locationY " +
                     "FROM User_Addresses WHERE account_id = ? AND is_deleted = 0 ORDER BY is_default DESC, id ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public UserAddress findById(long id) {
        String sql = "SELECT id, account_id, label, full_address, receiver_name, receiver_phone, is_default, created_at, locationX, locationY " +
                     "FROM User_Addresses WHERE id = ? AND is_deleted = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean create(UserAddress a) {
        String sql = "INSERT INTO User_Addresses (account_id, label, full_address, receiver_name, receiver_phone, is_default, locationX, locationY) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, a.getAccountId());
            ps.setNString(2, a.getLabel());
            ps.setNString(3, a.getFullAddress());
            ps.setNString(4, a.getReceiverName());
            ps.setString(5, a.getReceiverPhone());
            ps.setBoolean(6, a.isDefault());
            if (a.getLocationX() != null) {
                ps.setDouble(7, a.getLocationX());
            } else {
                ps.setNull(7, Types.DECIMAL);
            }
            if (a.getLocationY() != null) {
                ps.setDouble(8, a.getLocationY());
            } else {
                ps.setNull(8, Types.DECIMAL);
            }
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean update(UserAddress a) {
        String sql = "UPDATE User_Addresses SET label = ?, full_address = ?, receiver_name = ?, receiver_phone = ?, locationX = ?, locationY = ? " +
                     "WHERE id = ? AND account_id = ? AND is_deleted = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, a.getLabel());
            ps.setNString(2, a.getFullAddress());
            ps.setNString(3, a.getReceiverName());
            ps.setString(4, a.getReceiverPhone());
            if (a.getLocationX() != null) {
                ps.setDouble(5, a.getLocationX());
            } else {
                ps.setNull(5, Types.DECIMAL);
            }
            if (a.getLocationY() != null) {
                ps.setDouble(6, a.getLocationY());
            } else {
                ps.setNull(6, Types.DECIMAL);
            }
            ps.setLong(7, a.getId());
            ps.setLong(8, a.getAccountId());
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(long id) {
        // Soft delete: set is_deleted = 1
        String sql = "UPDATE User_Addresses SET is_deleted = 1 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean setDefault(long addressId, long accountId) {
        String sql1 = "UPDATE User_Addresses SET is_default = 0 WHERE account_id = ?";
        String sql2 = "UPDATE User_Addresses SET is_default = 1 WHERE id = ? AND account_id = ?";
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(sql1)) {
                ps1.setLong(1, accountId);
                ps1.executeUpdate();
            }
            if (addressId > 0) {
                try (PreparedStatement ps2 = conn.prepareStatement(sql2)) {
                    ps2.setLong(1, addressId);
                    ps2.setLong(2, accountId);
                    ps2.executeUpdate();
                }
            }
            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private UserAddress map(ResultSet rs) throws SQLException {
        UserAddress a = new UserAddress();
        a.setId(rs.getLong("id"));
        a.setUserId(rs.getLong("account_id"));
        a.setLabel(rs.getString("label"));
        a.setAddress(rs.getString("full_address"));
        a.setReceiverName(rs.getString("receiver_name"));
        a.setReceiverPhone(rs.getString("receiver_phone"));
        a.setDefault(rs.getBoolean("is_default"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) a.setCreatedAt(ca.toLocalDateTime());
        a.setLocationX(rs.getObject("locationX", Double.class));
        a.setLocationY(rs.getObject("locationY", Double.class));
        return a;
    }
}
