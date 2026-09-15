package org.example.daos;

import org.example.models.Voucher;
import org.example.utils.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VoucherDAOImpl implements VoucherDAO {

    @Override
    public long createAndReturnId(Voucher v) {
        String sql = "INSERT INTO Vouchers (code, voucher_type, value, min_order_value, max_discount, " +
                "usage_limit, start_date, end_date, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bind(ps, v);
            int affected = ps.executeUpdate();
            if (affected == 0) return 0;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public boolean update(Voucher v) {
        String sql = "UPDATE Vouchers SET code = ?, voucher_type = ?, value = ?, min_order_value = ?, " +
                "max_discount = ?, usage_limit = ?, start_date = ?, end_date = ?, is_active = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            bind(ps, v);
            ps.setLong(10, v.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private void bind(PreparedStatement ps, Voucher v) throws SQLException {
        ps.setString(1, v.getCode());
        ps.setString(2, v.getVoucherType());
        ps.setDouble(3, v.getValue());
        ps.setDouble(4, v.getMinOrderValue());
        if (v.getMaxDiscount() != null) ps.setDouble(5, v.getMaxDiscount()); else ps.setNull(5, Types.DECIMAL);
        if (v.getUsageLimit() != null) ps.setInt(6, v.getUsageLimit()); else ps.setNull(6, Types.INTEGER);
        ps.setTimestamp(7, v.getStartDate() != null ? Timestamp.valueOf(v.getStartDate()) : null);
        ps.setTimestamp(8, v.getEndDate() != null ? Timestamp.valueOf(v.getEndDate()) : null);
        ps.setBoolean(9, v.isActive());
    }

    @Override
    public boolean setActive(long id, boolean active) {
        String sql = "UPDATE Vouchers SET is_active = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setLong(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean delete(long id) {
        String sql = "DELETE FROM Vouchers WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public Voucher findById(long id) {
        String sql = "SELECT * FROM Vouchers WHERE id = ?";
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
    public Voucher findByCode(String code) {
        // UQ_Voucher_Code uses the database collation (case-insensitive in the POB schema),
        // so do not wrap the indexed column in LOWER().
        String sql = "SELECT * FROM Vouchers WHERE code = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Voucher> findAll() {
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT * FROM Vouchers ORDER BY id DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Voucher> findApplicable(double subtotal) {
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT * FROM Vouchers WHERE is_active = 1 " +
                "AND (start_date IS NULL OR start_date <= GETDATE()) " +
                "AND (end_date IS NULL OR end_date >= GETDATE()) " +
                "AND (usage_limit IS NULL OR used_count < usage_limit) " +
                "AND min_order_value <= ? ORDER BY value DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, subtotal);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean incrementUsedCount(long id) {
        // Dieu kien "usage_limit IS NULL OR used_count < usage_limit" ngay trong UPDATE de tranh
        // race condition khi nhieu request dung cung 1 voucher gan sat luc het luot.
        String sql = "UPDATE Vouchers SET used_count = used_count + 1 " +
                "WHERE id = ? AND (usage_limit IS NULL OR used_count < usage_limit)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean decrementUsedCount(long id) {
        // Hoan lai 1 luot da giu cho boi incrementUsedCount, dieu kien used_count > 0 de tranh am.
        String sql = "UPDATE Vouchers SET used_count = used_count - 1 WHERE id = ? AND used_count > 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Voucher map(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setId(rs.getLong("id"));
        v.setCode(rs.getString("code"));
        v.setVoucherType(rs.getString("voucher_type"));
        v.setValue(rs.getDouble("value"));
        v.setMinOrderValue(rs.getDouble("min_order_value"));
        double maxDiscount = rs.getDouble("max_discount");
        v.setMaxDiscount(rs.wasNull() ? null : maxDiscount);
        int usageLimit = rs.getInt("usage_limit");
        v.setUsageLimit(rs.wasNull() ? null : usageLimit);
        v.setUsedCount(rs.getInt("used_count"));
        Timestamp start = rs.getTimestamp("start_date");
        if (start != null) v.setStartDate(start.toLocalDateTime());
        Timestamp end = rs.getTimestamp("end_date");
        if (end != null) v.setEndDate(end.toLocalDateTime());
        v.setActive(rs.getBoolean("is_active"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) v.setCreatedAt(createdAt.toLocalDateTime());
        return v;
    }
}
