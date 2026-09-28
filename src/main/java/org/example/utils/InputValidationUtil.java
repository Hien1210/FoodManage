package org.example.utils;

import java.util.regex.Pattern;

/**
 * Kiểm tra đầu vào phía máy chủ cho các trường văn bản tự do (họ tên, tên shop, địa chỉ, mô tả...).
 * Mỗi hàm trả về thông báo lỗi tiếng Việt, hoặc null nếu hợp lệ. Việc escape khi hiển thị vẫn bắt buộc
 * (xem CRUD_DA_LAM.md mục 105); đây chỉ là lớp phòng thủ thứ hai: giới hạn độ dài theo cột DB và
 * từ chối ký tự điều khiển / dấu &lt; &gt; vốn không có lý do hợp lệ trong các trường này.
 */
public final class InputValidationUtil {

    public static final int MAX_PERSON_NAME = 100;   // Accounts.full_name, User_Addresses.receiver_name
    public static final int MAX_PHONE = 20;          // Accounts.phone, Shops.shop_phone, User_Addresses.receiver_phone
    public static final int MAX_SHOP_NAME = 255;     // Shops.shop_name
    public static final int MAX_ADDRESS = 500;
    public static final int MAX_LABEL = 50;          // User_Addresses.label
    public static final int MAX_DESCRIPTION = 2000;
    public static final int MAX_SUBJECT = 200;

    private static final Pattern PHONE = Pattern.compile("^[0-9+()\\-. ]+$");

    private InputValidationUtil() {
    }

    /** Văn bản một dòng: không xuống dòng, không ký tự điều khiển, không &lt; &gt;, độ dài tối đa {@code max}. */
    public static String checkLine(String fieldName, String value, int max) {
        return check(fieldName, value, max, false);
    }

    /** Văn bản nhiều dòng (mô tả, nội dung): cho phép xuống dòng và tab. */
    public static String checkMultiline(String fieldName, String value, int max) {
        return check(fieldName, value, max, true);
    }

    public static String checkPhone(String fieldName, String value) {
        if (value == null || value.isEmpty()) {
            return null;
        }
        if (value.length() > MAX_PHONE) {
            return fieldName + " không được dài quá " + MAX_PHONE + " ký tự!";
        }
        if (!PHONE.matcher(value).matches()) {
            return fieldName + " chỉ được chứa chữ số và các ký tự + ( ) - .";
        }
        return null;
    }

    /** Trả về lỗi đầu tiên khác null trong danh sách, hoặc null nếu tất cả hợp lệ. */
    public static String firstError(String... errors) {
        for (String e : errors) {
            if (e != null) {
                return e;
            }
        }
        return null;
    }

    private static String check(String fieldName, String value, int max, boolean allowNewlines) {
        if (value == null || value.isEmpty()) {
            return null;
        }
        if (value.length() > max) {
            return fieldName + " không được dài quá " + max + " ký tự!";
        }
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            if (c == '<' || c == '>') {
                return fieldName + " không được chứa ký tự < hoặc >!";
            }
            if (Character.isISOControl(c) && !(allowNewlines && (c == '\n' || c == '\r' || c == '\t'))) {
                return fieldName + " chứa ký tự không hợp lệ!";
            }
        }
        return null;
    }
}
