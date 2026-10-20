package org.example.daos;

import org.example.models.AuditLog;
import org.example.utils.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class AuditLogDAOImpl implements AuditLogDAO {

    @Override
    public void log(Long accountId, Long roleId, String action, String module, String description,
                     Long targetId, String targetType, String ipAddress, String userAgent) {
        String sql = "INSERT INTO AuditLogs " +
                "(account_id, role_id, action, module, description, target_id, target_type, ip_address, user_agent, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            setNullableLong(pst, 1, accountId);
            setNullableLong(pst, 2, roleId);
            pst.setString(3, action);
            pst.setString(4, module);
            pst.setString(5, description);
            setNullableLong(pst, 6, targetId);
            pst.setString(7, targetType);
            pst.setString(8, ipAddress);
            pst.setString(9, userAgent);
            pst.executeUpdate();
        } catch (Exception e) {
            // Ghi audit log that bai KHONG duoc lam hong nghiep vu chinh dang chay (vd duyet shop).
            // Chi log ra console de dev biet, khong throw nguoc len servlet.
            e.printStackTrace();
        }
    }

    @Override
    public List<AuditLog> search(Long accountId, String module, String action,
                                  LocalDate fromDate, LocalDate toDate,
                                  int page, int pageSize) {
        List<AuditLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT al.*, a.username, r.name AS role_name " +
                        "FROM AuditLogs al " +
                        "LEFT JOIN Accounts a ON a.id = al.account_id " +
                        "LEFT JOIN Roles r ON r.id = al.role_id ");
        List<Object> params = new ArrayList<>();
        appendWhere(sql, params, accountId, module, action, fromDate, toDate);
        sql.append(" ORDER BY al.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        int offset = Math.max(page - 1, 0) * pageSize;

        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql.toString())) {
            int idx = bindParams(pst, params);
            pst.setInt(idx++, offset);
            pst.setInt(idx, pageSize);
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Loi truy van audit log (search)", e);
        }
        return list;
    }

    @Override
    public int count(Long accountId, String module, String action,
                      LocalDate fromDate, LocalDate toDate) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM AuditLogs al ");
        List<Object> params = new ArrayList<>();
        appendWhere(sql, params, accountId, module, action, fromDate, toDate);

        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql.toString())) {
            bindParams(pst, params);
            try (ResultSet rs = pst.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Loi truy van audit log (count)", e);
        }
    }

    @Override
    public List<String> findDistinctModules() {
        List<String> modules = new ArrayList<>();
        String sql = "SELECT DISTINCT module FROM AuditLogs ORDER BY module ASC";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            while (rs.next()) modules.add(rs.getString(1));
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Loi truy van audit log (findDistinctModules)", e);
        }
        return modules;
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    private void appendWhere(StringBuilder sql, List<Object> params,
                              Long accountId, String module, String action,
                              LocalDate fromDate, LocalDate toDate) {
        List<String> conditions = new ArrayList<>();

        if (accountId != null) {
            conditions.add("al.account_id = ?");
            params.add(accountId);
        }
        if (module != null && !module.isBlank()) {
            conditions.add("al.module = ?");
            params.add(module);
        }
        if (action != null && !action.isBlank()) {
            conditions.add("al.action LIKE ?");
            params.add("%" + action.trim() + "%");
        }
        if (fromDate != null) {
            conditions.add("al.created_at >= ?");
            params.add(Timestamp.valueOf(fromDate.atStartOfDay()));
        }
        if (toDate != null) {
            conditions.add("al.created_at < ?");
            params.add(Timestamp.valueOf(toDate.plusDays(1).atStartOfDay()));
        }

        if (!conditions.isEmpty()) {
            sql.append(" WHERE ").append(String.join(" AND ", conditions));
        }
    }

    private int bindParams(PreparedStatement pst, List<Object> params) throws SQLException {
        int idx = 1;
        for (Object p : params) {
            if (p instanceof Long) pst.setLong(idx, (Long) p);
            else if (p instanceof String) pst.setString(idx, (String) p);
            else if (p instanceof Timestamp) pst.setTimestamp(idx, (Timestamp) p);
            idx++;
        }
        return idx;
    }

    private void setNullableLong(PreparedStatement pst, int index, Long value) throws SQLException {
        if (value != null) pst.setLong(index, value);
        else pst.setNull(index, java.sql.Types.BIGINT);
    }

    private AuditLog map(ResultSet rs) throws SQLException {
        AuditLog log = new AuditLog();
        log.setId(rs.getLong("id"));
        long accId = rs.getLong("account_id");
        log.setAccountId(rs.wasNull() ? null : accId);
        long roleId = rs.getLong("role_id");
        log.setRoleId(rs.wasNull() ? null : roleId);
        log.setAction(rs.getString("action"));
        log.setModule(rs.getString("module"));
        log.setDescription(rs.getString("description"));
        long targetId = rs.getLong("target_id");
        log.setTargetId(rs.wasNull() ? null : targetId);
        log.setTargetType(rs.getString("target_type"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setUserAgent(rs.getString("user_agent"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) log.setCreatedAt(createdAt.toLocalDateTime());
        log.setUsername(rs.getString("username"));
        log.setRoleName(rs.getString("role_name"));
        return log;
    }
}
