---
name: ai-native-sdlc
description: Quy trình phát triển AI-native (Plan → Build → Test → Deploy → Maintain) dựa trên "AI-Native SDLC Playbook" của Claude Academy. Dùng khi bắt đầu một tính năng/nhiệm vụ mới, cần viết intent, thiết kế, review, hoặc chuẩn hoá cách làm việc giữa người và AI.
---

# AI-Native SDLC

Nguồn: https://academy.claude.com/courses/ai-native-sdlc-playbook/introduction

## Nguyên tắc cốt lõi

- SDLC là một **vòng lặp liên tục**, không phải chuỗi bàn giao giữa các vai trò. AI có mặt ở mọi giai đoạn; con người vẫn chịu trách nhiệm cho các quyết định cần phán đoán.
- Viết code không còn là nút thắt. Nút thắt đã chuyển sang **lập kế hoạch, review và deploy**, nên tập trung tối ưu ở đó.
- Mỗi giai đoạn tạo ra **artifact được commit** (yêu cầu, thiết kế, code, review, ghi chép sự cố) và artifact đó kích hoạt giai đoạn kế tiếp. Chuỗi commit chính là audit trail; không dùng phê duyệt thủ công thay cho nó.
- Tri thức của tổ chức (chuẩn code, compliance, kiến trúc) phải được mã hoá thành `CLAUDE.md` và skill có version, để agent quyết định nhất quán giữa các phiên.

## 5 giai đoạn

### 1. Plan & Design
- Tổng hợp tài liệu nguồn (yêu cầu, ticket, hội thoại) thành file `intent.md` dạng máy đọc được: mục tiêu, phạm vi, tiêu chí chấp nhận, ràng buộc, ngoài phạm vi.
- Nén phần thiết kế vào một phiên làm việc có agent dẫn dắt, dựa trên chuẩn đã mã hoá. Kết quả (design note) được commit cùng `intent.md`.
- Người quyết định: phạm vi, đánh đổi, ưu tiên.

### 2. Build
- Sinh test trước hoặc song song với code, dựa trên tiêu chí chấp nhận trong `intent.md`.
- Bám `CLAUDE.md` và các skill của dự án; nếu phát hiện quy ước mới hoặc hay bị sai, cập nhật lại vào `CLAUDE.md`/skill thay vì chỉ sửa một lần.

### 3. Test
- Đánh giá **liên tục trong lúc làm**, không chờ đến cổng cuối giai đoạn: chạy test, lint, build sau mỗi thay đổi có ý nghĩa.
- Bổ sung test cho hành vi mới và cho lỗi vừa sửa.

### 4. Deploy
- Review nhiều lớp bằng agent (đúng/sai logic, bảo mật, hiệu năng, đơn giản hoá). Review của người dành cho code quan trọng (auth, tiền, dữ liệu, migration).
- Áp governance bằng **hook** làm cổng phê duyệt (ví dụ chặn lệnh nguy hiểm, bắt buộc test pass trước khi commit/push) thay vì quy trình giấy tờ.

### 5. Maintain
- Dùng agent giám sát production (log, metric, lỗi).
- Khi vượt ngưỡng, ghi lại thành yêu cầu/sự cố mới (`intent.md` mới) và đưa trở lại vòng lặp Plan.

## Cách áp dụng khi được gọi

1. Xác định nhiệm vụ đang ở giai đoạn nào; nếu chưa có `intent.md` thì viết trước (hỏi người dùng những chỗ chưa rõ, không tự đoán phạm vi).
2. Làm theo đúng giai đoạn, kết thúc mỗi giai đoạn bằng một artifact rõ ràng (file `.md` hoặc commit).
3. Đánh dấu rõ điểm nào cần con người quyết định và dừng lại hỏi ở đó.
4. Cuối nhiệm vụ: ghi lại điều học được vào `CLAUDE.md`/skill nếu nó sẽ lặp lại.

## Lưu ý riêng cho dự án này

- Trước khi làm: đọc `PROJECT_STRUCTURE.md` và `CRUD_DA_LAM.md`. Sau khi làm xong: đọc `AI_REVIEW_AND_TEST_GUIDELINES.md`, cập nhật các file `.md` liên quan, và cập nhật `database.md` nếu đổi bảng/cột (xem `CLAUDE.md`).
- Giai đoạn Build/Test/Deploy của dự án này trùng với các bước trên; skill này chỉ bổ sung phần Plan (intent) và Maintain.
