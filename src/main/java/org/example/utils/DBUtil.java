package org.example.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Thông tin kết nối lấy từ {@link ConfigUtil}: biến môi trường DB_URL / DB_USER / DB_PASSWORD,
 * hoặc khoá db.url / db.user / db.password trong src/main/resources/config.properties
 * (file này nằm trong .gitignore, mẫu ở config.properties.example).
 */
public class DBUtil {
    private static final String URL = ConfigUtil.get("db.url", null);
    private static final String USER = ConfigUtil.get("db.user", null);
    private static final String PASSWORD = ConfigUtil.get("db.password", null);

    public static Connection getConnection() {
        Connection connection = null;
        try {
            if (URL == null || USER == null || PASSWORD == null) {
                throw new IllegalStateException(
                        "Thiếu cấu hình database: đặt db.url/db.user/db.password trong config.properties "
                                + "hoặc biến môi trường DB_URL/DB_USER/DB_PASSWORD.");
            }
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(URL, USER, PASSWORD);

        } catch (ClassNotFoundException | SQLException | IllegalStateException e) {
            e.printStackTrace();
        }
        return connection;
    }
}
