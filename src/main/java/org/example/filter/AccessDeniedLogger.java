package org.example.filter;

import jakarta.servlet.http.HttpServletRequest;
import org.example.models.Account;
import org.example.services.AuditLogService;
import org.example.utils.AuditModules;

import java.util.concurrent.ConcurrentHashMap;

/**
 * Ghi Audit Log (module Security) khi một tài khoản ĐÃ đăng nhập bị filter chặn truy cập (403).
 * Chỉ ghi tối đa 1 dòng / phút cho mỗi cặp (tài khoản, method, đường dẫn) để kẻ thử quyền liên tục
 * không làm đầy bảng AuditLogs. Lỗi khi ghi log không được làm hỏng luồng trả 403.
 */
final class AccessDeniedLogger {

    private static final long WINDOW_MILLIS = 60_000L;
    private static final int MAX_TRACKED = 5_000;
    private static final int MAX_URI_LENGTH = 300;

    private static final ConcurrentHashMap<String, Long> LAST_LOGGED = new ConcurrentHashMap<>();
    private static final AuditLogService AUDIT = new AuditLogService();

    private AccessDeniedLogger() {
    }

    static void log(HttpServletRequest req, Account account, String requiredArea) {
        try {
            long now = System.currentTimeMillis();
            String uri = req.getRequestURI();
            String key = account.getId() + "|" + req.getMethod() + "|" + uri;

            if (LAST_LOGGED.size() > MAX_TRACKED) {
                LAST_LOGGED.entrySet().removeIf(e -> now - e.getValue() > WINDOW_MILLIS);
            }
            Long previous = LAST_LOGGED.get(key);
            if (previous != null && now - previous < WINDOW_MILLIS) {
                return;
            }
            LAST_LOGGED.put(key, now);

            String shownUri = uri.length() > MAX_URI_LENGTH ? uri.substring(0, MAX_URI_LENGTH) + "..." : uri;
            String description = "Tài khoản " + account.getUserName() + " (role " + account.getRoleId() + ") bị chặn "
                    + req.getMethod() + " " + shownUri + " - khu vực yêu cầu: " + requiredArea;
            AUDIT.log(req, account, "Truy cập bị từ chối", AuditModules.SECURITY, description, account.getId(), "Account");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
