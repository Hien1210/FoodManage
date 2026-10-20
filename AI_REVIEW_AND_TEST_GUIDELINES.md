# 🤖 AI SYSTEM INSTRUCTIONS: CODE REVIEW & TESTING GUIDELINES (PROJECT POB)

> **Dành cho AI Agent / Code Reviewer / Tester:** > Tài liệu này chứa toàn bộ quy tắc, tiêu chuẩn mã nguồn, danh mục kiểm tra (Checklist) và định dạng phản hồi bắt buộc khi AI tiến hành đọc, review code hoặc sinh kịch bản test cho dự án **POB (Food Ordering System)**.

---

## 📑 MỤC LỤC
1. [Ngữ Cảnh & Kiến Trúc Dự Án](#1-ngữ-cảnh--kiến-trúc-dự-án)
2. [Quy Trình Review Code Bằng AI (AI Code Review Workflow)](#2-quy-trình-review-code-bằng-ai)
3. [Checklist Kiểm Tra Code Dành Cho AI](#3-checklist-kiểm-tra-code-dành-cho-ai)
4. [Định Dạng Báo Cáo Review Bắt Buộc (AI Output Format)](#4-định-dạng-báo-cáo-review-bắt-buộc)
5. [Quy Trình Sinh Kịch Bản Test (AI Test Generation Guidelines)](#5-quy-trình-sinh-kịch-bản-test)

---

## 1. 🏗️ NGỮ CẢNH & KIẾN TRÚC DỰ ÁN

AI phải tuân thủ ngữ cảnh kỹ thuật sau của hệ thống khi phân tích mã nguồn:
* **Công nghệ cốt lõi:** Java 17+, Java Servlet / JSP thuần (Jakarta Servlet API), Maven (`pom.xml`), Apache Tomcat.
* **Mô hình kiến trúc:** MVC (Servlet Controller → DAO Layer → Model POJO → JSP View). **Không sử dụng Spring Framework / Spring Boot**.
* **Cơ sở dữ liệu:** SQL Server (`POB`), truy vấn qua JDBC (`DBUtil.java`).
* **Mật khẩu & Xác thực:** `jbcrypt` (hash mật khẩu), OTP qua `javax.mail`.
* **Giao tiếp Realtime:** Jakarta WebSocket (`/ws/tracking`, `/ws/notification`) lưu trữ session in-memory.
* **Tích hợp bên thứ ba (Third-party integrations):** PayOS API (Thanh toán VietQR), Cloudinary (lưu ảnh sản phẩm/avatar), Leaflet JS + Nominatim (bản đồ & Geocoding).

---

## 2. 🔄 QUY TRÌNH REVIEW CODE BẰNG AI

Khi AI nhận được yêu cầu review một Pull Request (PR) hoặc một đoạn code, AI phải tuân theo luồng xử lý 4 bước nghiêm ngặt:

1. **Phân tích Ngữ cảnh & Đọc Code:** Nắm bắt luồng dữ liệu (Data flow) từ JSP → Servlet → DAO → Database.
2. **Kiểm tra Bảo mật & Lỗi Nghiêm trọng (Security/Crash):** Ưu tiên rà soát các lỗ hổng có thể làm sập hệ thống hoặc lộ dữ liệu.
3. **Kiểm tra Quy chuẩn Clean Code & Hiệu năng:** Đánh giá độ phức tạp, khả năng bảo trì và tốc độ thực thi của code.
4. **Xuất Báo cáo:** Phân loại lỗi theo mức độ (Severity Standard) và cung cấp code sửa lỗi trực tiếp.

---

## 3. 📝 CHECKLIST KIỂM TRA CODE DÀNH CHO AI

AI phải tự đối chiếu đoạn code được cung cấp với các tiêu chí dưới đây:

### 3.1. Bảo mật (Security - Priority 1)
- [ ] **SQL Injection:** Có dùng `PreparedStatement` cho tất cả các truy vấn CSDL không? (Nghiêm cấm nối chuỗi SQL động kiểu `SELECT * FROM ... WHERE id = '` + input).
- [ ] **XSS (Cross-Site Scripting):** Dữ liệu đầu ra hiển thị trên JSP có được escape HTML thích hợp không (sử dụng `<c:out>` hoặc thư viện encode)?
- [ ] **Lộ Secret / API Key:** Có hardcode mật khẩu Database, PayOS CheckSumKey, Cloudinary Secret trực tiếp trong code không? (Yêu cầu phải dùng biến môi trường hoặc file config).
- [ ] **Phân quyền (IDOR/Authorization):** Các Servlet có kiểm tra quyền sở hữu dữ liệu (ví dụ: `order.userId == account.id` hoặc Role `SUPER_ADMIN`) trước khi thực hiện UPDATE/DELETE không?

### 3.2. Quản lý Kết nối & Tài nguyên (Resource Management)
- [ ] **JDBC Leak:** Các đối tượng `Connection`, `PreparedStatement`, `ResultSet` có được đóng an toàn trong khối `try-with-resources` hoặc block `finally` không?
- [ ] **Null Pointer Handling:** Có kiểm tra `null` trước khi gọi method trên đối tượng (đặc biệt là dữ liệu từ `request.getParameter()`, kết quả trả về từ DAO) không?

### 3.3. Logic Nghiệp vụ & Clean Code
- [ ] **Tương thích Schema:** Tên bảng, cột trong câu lệnh SQL JDBC phải khớp chính xác với DDL thực tế (ví dụ: `Order_Logs`, `Cart_Items` có dấu gạch dưới).
- [ ] **Xử lý Ngoại lệ (Exception Handling):** Có khối `catch (Exception e)` nào bị bỏ trống (empty catch) và nuốt lỗi âm thầm không? Mọi ngoại lệ phải được ghi log (`e.printStackTrace()` hoặc Logger) hoặc trả về thông báo lỗi cho người dùng.
- [ ] **Quy chuẩn Đặt tên:** Tuân thủ chuẩn Java (camelCase cho biến/hàm, PascalCase cho Class, UPPER_SNAKE_CASE cho hằng số).

---

## 4. 🎯 ĐỊNH DẠNG BÁO CÁO REVIEW BẮT BUỘC (AI OUTPUT FORMAT)

AI **phải luôn luôn** trả về kết quả review theo đúng mẫu Markdown dưới đây, không được thay đổi cấu trúc:

```markdown
## 📋 AI Code Review Report

### 1. Tổng Quan
- **Đánh giá chung:** [PASS / PASS WITH WARNINGS / REJECT]
- **Số lượng lỗi phát hiện:** 🔴 Critical: X | 🟡 Warning: Y | 🟢 Suggestion: Z

---

### 2. Chi Tiết Các Lỗi & Gợi Ý Sửa Đổi

#### 🔴 [CRITICAL] - Lỗi Nghiêm Trọng (Bắt buộc sửa trước khi Merge)
* **Vị trí:** `TênFile.java` (Dòng XX)
* **Mô tả lỗi:** [Mô tả chi tiết lỗi nguy hiểm: SQLi, IDOR, Crash, Leak connection,...]
* **Code hiện tại:**
  ```java
  // Code bị lỗi
Gợi ý khắc phục:

Java
// Code đã tối ưu/sửa lỗi
🟡 [WARNING] - Cảnh Báo Hiệu Năng & Logic
Vị trí: TênFile.java (Dòng YY)

Mô tả: [Code chưa tối ưu, thiếu try-with-resources, vòng lặp sinh truy vấn N+1...]

Gợi ý khắc phục: [Code minh họa]

🟢 [SUGGESTION] - Gợi Ý Clean Code & Readability
Vị trí: TênFile.jsp / TênFile.java

Mô tả: [Đặt tên chưa rõ ràng, code lặp lại cần tách hàm, format code chưa chuẩn...]

3. Kết Luận & Hành Động Kế Tiếp
[ ] Developer action: [Tóm tắt ngắn gọn các gạch đầu dòng Dev cần thực hiện]


---

## 5. 🧪 QUY TRÌNH SINH KỊCH BẢN TEST (AI TEST GENERATION GUIDELINES)

Khi được yêu cầu viết Test Case / Unit Test / Integration Test cho một chức năng, AI phải tạo kịch bản theo đúng định dạng bảng tiêu chuẩn sau:

### 5.1. Cấu Trúc Bảng Test Case Bắt Buộc

| ID Test Case | Tên kịch bản Test | Dữ liệu đầu vào (Input) | Điều kiện tiên quyết | Các bước thực hiện | Kết quả kỳ vọng (Expected Output) | Loại Test |
|---|---|---|---|---|---|---|
| `TC_LOGIN_01` | Đăng nhập thành công với USER | Username: `user1`, Pass: `123456` | Tài khoản trạng thái ACTIVE | 1. Nhập User/Pass<br>2. Bấm Đăng nhập | Chuyển hướng tới `/home`, Session lưu `account` | Happy Path |
| `TC_LOGIN_02` | Đăng nhập sai Mật khẩu | Username: `user1`, Pass: `sai_pass` | Tài khoản tồn tại | 1. Nhập Sai Pass<br>2. Bấm Đăng nhập | Báo lỗi "Tài khoản hoặc mật khẩu không chính xác", lưu lại trang cũ | Edge Case |
| `TC_CHECKOUT_01` | Tách đơn đa Shop khi Checkout | Giỏ hàng có sản phẩm Shop A & Shop B | User đã đăng nhập, giỏ hàng hợp lệ | 1. Vào Checkout<br>2. Chọn PayOS<br>3. Bấm Thanh toán | Tạo thành công 2 bản ghi `Orders` riêng biệt tương ứng 2 Shop | Integration |
### 5.2 tài khoản 
Admin Accounts
Nickname: Hien123
Password: 12345678

Shipper Accounts
Nickname: Hien2008
Password: 12345678

Shop Accounts
Nickname: Bao   (role shop, chưa có bản ghi shop)
Password: 12345678

User Accounts
Nickname: HienMap
Password: 12345678

Shop Owner (chủ shop `wishe`, có sẵn món `QA_TEST`, đã đặt vị trí)
Nickname: pob
Password: 12345678

Ghi chú test (DB thật): đơn #1, khiếu nại/đánh giá `QA_TEST`, hồ sơ tài xế `Hien2008` đã duyệt. Gửi OTP email đang lỗi (Gmail 535), nên tránh thao tác đổi email/ngân hàng/khoá PayOS trong lúc test.

### 5.3. Các Bộ Dữ Liệu Test Bắt Buộc Phải Bao Phủ
AI luôn phải thiết kế đủ 3 nhóm kịch bản kiểm thử:
1. **Happy Path (Luồng chuẩn):** Người dùng nhập đúng dữ liệu lý tưởng, hệ thống xử lý thành công không có lỗi.
2. **Boundary / Edge Cases (Ngoại lệ & Biên):**
   * Chuỗi rỗng `""`, giá trị `null`, khoảng trắng thừa.
   * Số lượng sản phẩm âm (`-1`), giá trị bằng `0` hoặc thập phân không hợp lệ.
   * Hành vi nhập sai định dạng email, sai định dạng số điện thoại.
3. **Security Test Cases:**
   * Thử nghiệm SQL Injection qua các ô tìm kiếm hoặc form đăng nhập (`' OR '1'='1`).
   * Truy cập trái phép endpoint (ví dụ: User thường cố tình truy cập vào URL `/admin/bao-cao-van-hanh`).
   * Tấn công XSS qua form bình luận/khiếu nại (`<script>alert('XSS')</script>`).