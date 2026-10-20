# intent.md — Kiểm tra hệ thống các chức năng (QA toàn diện)

## Mục tiêu
Rà soát các chức năng của web FOOD MANAGE theo 4 role (Khách hàng, Shop, Shipper, Super Admin), tìm lỗi thật và báo cáo có bằng chứng. Sửa lỗi chỉ khi lỗi rõ ràng và nằm gọn trong code (báo riêng, không sửa lan man).

## Phạm vi
- Cách kiểm tra: **đọc code + build Maven** rồi **chạy thử thật trên trình duyệt** (Tomcat riêng cổng 8090, không đụng Tomcat 8080 của người dùng).
- 4 role: user, shop, shipper, super admin. Tài khoản test lấy từ mục 5.2 của `AI_REVIEW_AND_TEST_GUIDELINES.md`.
- Theo checklist 3.1–3.3 và 3 nhóm test 5.3 (happy path, biên, bảo mật: SQLi, XSS, truy cập trái quyền).

## Tiêu chí chấp nhận
1. Build `mvn package` thành công; app khởi động không lỗi trong log Tomcat.
2. Mỗi role: trang chính mở được, các luồng chính chạy được, không có trang 404/500.
3. Phân quyền: URL của role khác bị chặn.
4. Có báo cáo theo mẫu mục 4 của `AI_REVIEW_AND_TEST_GUIDELINES.md`, mỗi lỗi kèm vị trí file/dòng hoặc cách tái hiện.

## Ràng buộc
- DB là SQL Server thật: hạn chế ghi; dữ liệu test tạo ra phải ghi lại để người dùng biết.
- Không thử thanh toán PayOS thật, không gửi email OTP thật (SMTP hỏng theo ghi chú cũ).
- Không xoá dữ liệu.

## Ngoài phạm vi
Thiết kế lại giao diện, thêm tính năng mới, tối ưu hiệu năng.
