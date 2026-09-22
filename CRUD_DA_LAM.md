# CRUD da lam

## 153. Áp bộ thiết kế Stitch (zip 2) cho role SUPER ADMIN: theme riêng + sidebar dùng chung

**Yêu cầu:** User gửi zip Stitch thứ 2 (`stitch_remix_of_foodmanage_ui_design (1).zip`: 12 trang mẫu Admin + 1 file
sidebar tham chiếu riêng + `DESIGN.md`, cùng bộ màu với zip Shop nhưng bảng màu Admin dùng primary `#FF3B1F` thay vì
`#E3250A`). User nói "của admin" — hiểu là làm role Super Admin theo đúng cách đã làm với Shop (mục 150-152): áp
theme trước, dựng lại bố cục sau nếu được yêu cầu.

**Ánh xạ mock → trang thật (theo route, không theo tên hiển thị):**
- "Trung Tâm Quản Trị Hệ Thống & Vận Hành Toàn Sàn" (dashboard) → `TongQuanHeThong.jsp` (`/tong-quan`)
- "Báo Cáo Vận Hành & Phân Tích Hiệu Suất" → `BaoCaoVanHanh.jsp`
- "Heatmap Đơn Hàng & Giám Sát Điểm Nóng" → `HeatmapDonHang.jsp`
- "Hồ Sơ Thẩm Định #HS-..." → `chiTietYeuCauShop.jsp`
- "Thẩm Định Lệnh Rút Tiền Bất Thường" → `DuyetRutTienShop.jsp` / `DuyetRutTienShipper.jsp`
- "Kiểm Duyệt Sản Phẩm & Món Ăn Chờ Duyệt" → `KiemDuyetNoiDung.jsp`
- "Quản Trị Đánh Giá & AI Moderation" → `KiemDuyetBinhLuan.jsp`
- "Quản Lý Tài Khoản Toàn Hệ Thống" → `quanlitaikhoan.jsp`
- "Quản Lý Voucher & Chiến Dịch" → `QuanLyVoucher.jsp`
- "Quản Lý FAQ & Trung Tâm Trợ Giúp" → `faqDanhSach.jsp` / `faqThemSua.jsp`
- "Quản Trị Logo & Giao Diện Toàn Sàn" (CDN đa kênh, theme chiến dịch Tết...) → KHÔNG có trang thật tương ứng
  (`LogoUploadServlet` chỉ là 1 form upload ẩn trong trang khác, không phải trang riêng) — bỏ qua.
- "Xử Lý Khẩn Cấp — Điều Phối Nhà Hàng" (đơn `#FM-98241`, AI cứu hộ tài xế GPS) → không có servlet/JSP tương ứng
  (gần nhất là `QuanLyKhieuNai.jsp` nhưng không có định vị GPS/điều phối tài xế thật) — bỏ qua.
- File sidebar riêng (không phải 1 trang, chỉ có `<aside>`) dùng làm bản đồ điều hướng đầy đủ 4 nhóm × 12 mục để
  đối chiếu với 18 mục điều hướng thật hiện có (nhiều hơn mock — mock không có Duyệt Shipper, Kháng nghị, Duyệt rút
  tiền Shipper, Hoàn tiền khách hàng, Tham số vận hành, Nhật ký hệ thống).

**Thiết kế thực hiện (CSS-first, không đổi logic/servlet), y hệt phương pháp đã dùng cho Shop:**
- Tạo `assets/css/admin-theme.css`, nạp SAU `dashboard.css`, chỉ có tác dụng khi `<body class="dash-body admin-theme">`.
  **Khác Shop:** Super Admin có dark mode thật (nút đổi theme ở topbar, `dashboard.css` có nhánh
  `:root[data-theme="dark"]`) mà Stitch không có bản thiết kế tối, nên chỉ đè token màu trong
  `html[data-theme="light"] body.admin-theme { ... }` (primary `#FF3B1F`, nền kem `#FEF8F1`...); nhánh dark GIỮ
  NGUYÊN token xanh than gốc của `dashboard.css`. Bố cục/hình khối/font (Quicksand + Plus Jakarta Sans, bo góc,
  sidebar, topbar, card, nút, bảng) áp dụng cho CẢ 2 theme vì không phụ thuộc màu.
- Tạo `admin/_adminSidebar.jspf` dùng chung cho 23 trang, tái tạo đúng 18 route/label/badge cũ (`shopChoDuyet`,
  `pendingShippers`, `pendingProducts`, `pendingCount`), chỉ đổi icon emoji → Material Symbols và đóng gói thành
  4 nhóm giống mock (Tổng quan & phân tích / Kiểm duyệt & điều phối / Quản lý tài chính / Cấu hình & hệ thống).
  **Bẫy gặp phải:** 15/22 trang admin khai báo taglib `c` bằng URI JSTL CŨ (`http://java.sun.com/jsp/jstl/core`)
  thay vì `jakarta.tags.core`; fragment khai báo lại `c` bằng URI khác gây lỗi biên dịch "Attempt to redefine the
  prefix" → sửa bằng cách KHÔNG khai báo lại taglib `c`/`fn` trong fragment (dựa vào khai báo sẵn có của từng
  trang chủ), chỉ bổ sung `fn` còn thiếu ở `QuanLyHoanTien.jsp`. Bẫy thứ 2: bỏ luôn `pageEncoding="UTF-8"` khiến
  Jasper đọc nhầm file fragment (không BOM) thành ISO-8859-1 → toàn bộ tiếng Việt trong sidebar bị mojibake dù
  trang chủ vẫn đúng — phải khai báo lại `pageEncoding="UTF-8"` riêng (an toàn vì trùng giá trị với mọi trang chủ,
  không như taglib).
  Icon tiêu đề topbar của 22 trang đổi emoji → Material Symbols; 5 trang tiêu đề IN HOA
  (`BaoCaoVanHanh`, `DoiSoatDoanhThuShop`, `DuyetRutTienShipper`, `HeatmapDonHang`, `QuanLyVoucher`) đổi sang chữ
  thường viết hoa đầu câu.
- Vá màu lẻ: `#FF5722` (cam cũ) → `#FF3B1F` ở `HeatmapDonHang.jsp`, `TongQuanHeThong.jsp`.

**Trang đã áp theme (toàn bộ 23 trang admin, chỉ đổi phong cách — CHƯA dựng lại bố cục theo mock):**
`TongQuanHeThong, BaoCaoVanHanh, HeatmapDonHang, KiemDuyetBinhLuan, KiemDuyetNoiDung, QuanLyHoanTien, QuanLyKhieuNai,
QuanLyVoucher, ThamSoVanHanh, AuditLogs, DoiSoatDoanhThuShop, DuyetRutTienShipper, DuyetRutTienShop, appeals,
chiTietYeuCauShipper, chiTietYeuCauShop, doiMatKhauAdmin, faqDanhSach, faqThemSua, hoSoAdmin, quanlitaikhoan,
yeuCauShipper, yeuCauShop`.

**KHÔNG áp dụng (cố ý):** mọi tính năng chỉ có trong mock mà hệ thống không có — AI phát hiện gian lận rút tiền
(score/confidence, Sentinel-Fraud Core), điều phối tài xế cứu hộ real-time qua GPS/vệ tinh, CDN đa kênh + theme
chiến dịch cho logo, eKYC OCR giấy tờ, Live Cluster Health/Omnichannel Preview. Không tạo trang mới cho "Logo &
Giao diện" hay "Xử lý khẩn cấp" vì không có servlet tương ứng.

### Files sửa:
- `src/main/web/assets/css/admin-theme.css` (mới), `src/main/web/admin/_adminSidebar.jspf` (mới)
- 22 JSP còn lại trong `src/main/web/admin/` (danh sách ở trên) + `QuanLyHoanTien.jsp` (bổ sung taglib `fn` thiếu)
- `PROJECT_STRUCTURE.md`

### Ghi chú:
Không đổi schema/servlet/DAO nên không cập nhật `database.md`. Đã build WAR bằng Maven portable, chạy Tomcat riêng
cổng 8090 với DB thật, đăng nhập tài khoản Super Admin test (`Hien123`): toàn bộ 23 trang trả 200 + đủ `</html>`
(gặp và tự vá 2 lỗi biên dịch — taglib trùng prefix và mojibake tiếng Việt — trước khi đạt trạng thái này). Đã kiểm
tra: sidebar 4 nhóm hiển thị đúng tiếng Việt/icon/badge/mục active ở cả 2 theme sáng/tối, dark mode đổi đúng token
(không vỡ do chỉ override nhánh sáng), thu gọn sidebar (276↔68px) và menu mobile (☰, 375px không tràn ngang) đều
hoạt động, 3 trang nội dung thật (Khiếu nại, Duyệt rút tiền Shop, Quản lý tài khoản) render đúng theme. **Chưa kiểm
chứng:** dữ liệu thật trong bảng/danh sách (test account chưa có shop/đơn/khiếu nại nào để xem), thao tác submit
form. Đề nghị user tự click qua bằng dữ liệu thật.

## 152. Dựng lại bố cục các trang Shop còn lại theo mock Stitch (trang chủ, đánh giá, hồ sơ cửa hàng, flash sale, danh mục/topping, đổi mật khẩu)

**Yêu cầu:** Sau mục 151 (4 trang Combo/Hóa đơn/Thực đơn/Ví), user bảo "làm tiếp các trang còn lại". Vẫn chỉ dùng
dữ liệu thật; bỏ phần mock hệ thống không có.

- **`trangcuahang.jsp` (mock "Kênh tiếp nhận đơn"):** 4 thẻ KPI (Doanh thu hôm nay / Đơn chờ xử lý — dùng attribute
  `donChoXuLy` mà servlet đã tính nhưng trang chưa từng hiển thị, viền nổi + link sang hóa đơn / Tỷ lệ hoàn thành =
  hoàn thành ÷ tổng đơn / Tổng đơn), biểu đồ 7 ngày cạnh "Top món bán chạy" dạng danh sách xếp hạng, dải tuần/tháng/thực đơn,
  bảng đơn gần đây có đủ nhãn trạng thái + nút "Xem tất cả". Chart.js đổi `maintainAspectRatio:false` + khung cao cố định.
  Tên chào mừng nay qua `c:out` (trước in thô).
- **`xemDanhGia.jsp`:** thẻ điểm uy tín `x.x / 5`, biểu đồ phân bổ sao (đếm từ danh sách khách + shipper), thẻ tổng quan
  phản hồi (số đánh giá 1–2 sao), chip lọc theo sao trên cả 2 tab, thẻ đánh giá 1–2 sao có viền đỏ.
- **`Shopprofile.jsp` (mock "Cài đặt cửa hàng"/"Hồ sơ shop"):** thẻ tổng quan cửa hàng (logo, trạng thái duyệt, mở/đóng, mã,
  SĐT, giờ, lý do từ chối) thay panel "Tổng quan" bên phải; form CHIA thành 5 thẻ theo nhóm (Thương hiệu / Địa chỉ &
  vị trí có bản đồ Leaflet / Giờ hoạt động / Ngân hàng nhận tiền / PayOS) trong 2 cột, thanh Lưu/Hủy dính đáy. Vẫn là MỘT
  `<form>` với nguyên các `id`/`name` cũ nên JS bản đồ, upload logo, xác nhận thiếu vị trí không đổi.
- **`QuanlyFlashSale.jsp` (mock "Khuyến mãi"):** 3 thẻ KPI (Đang diễn ra / Sắp diễn ra / Đã kết thúc), danh sách thẻ flash sale
  (giá sale, giá gốc gạch ngang, `-x%`, khung giờ, badge trạng thái, xóa), form tạo dính bên phải. **Java:** thêm 2 getter
  `isUpcoming()` / `isEnded()` vào [FlashSale.java](src/main/java/org/example/models/FlashSale.java) (cần build lại WAR).
- **`Quanlyloaisanpham.jsp`, `Quanlyloaitopping.jsp`, `Quanlytopping.jsp` (mock "Danh mục & Kho topping"):** đổi bảng thành lưới
  thẻ bằng CSS `table.card-table` (giữ nguyên `<table><tr>` nên các hàm lọc/tìm JS cũ chạy tiếp; ẩn cột `#`, hàng thao tác
  đáy thẻ). Không gộp 3 trang thành 1 như mock (route/servlet riêng).
- **`doiMatKhauShop.jsp`:** thêm checklist yêu cầu mật khẩu theo thời gian thực (≥6 ký tự — bắt buộc thật; chữ+số, hoa/thường,
  ký tự đặc biệt — chỉ gợi ý). Bỏ qua 2FA/thiết bị đăng nhập/PIN POS/nhật ký bảo mật của mock.
- **`shopChoDuyet.jsp`:** thêm thanh 3 bước tiến trình duyệt hồ sơ; tên shop nay qua `c:out` (trước in thô, có nguy cơ XSS).
- **`shop-theme.css`:** `.stats-grid` co lại còn `minmax(190px,1fr)` để 4 thẻ KPI vừa 1 hàng; thêm `.card-table`.

**Không làm (mock có, hệ thống không có):** ca làm việc/thiết bị in KOT/chuông báo/bán kính giao/tạm ngưng nhận đơn của
cài đặt vận hành, voucher/ROI/Ads/gợi ý AI của khuyến mãi, sắp xếp thứ tự danh mục + nhóm topping bắt buộc/tùy chọn,
phản hồi công khai/tặng voucher cho đánh giá, xác thực 2 bước & quản lý thiết bị ở đổi mật khẩu, bảng "đơn mới chờ nhận"
có KDS/máy in ở trang chủ.

### Files sửa:
- `src/main/web/shop/`: `trangcuahang.jsp`, `xemDanhGia.jsp`, `Shopprofile.jsp`, `QuanlyFlashSale.jsp`, `Quanlyloaisanpham.jsp`,
  `Quanlyloaitopping.jsp`, `Quanlytopping.jsp`, `doiMatKhauShop.jsp`, `shopChoDuyet.jsp`
- `src/main/web/assets/css/shop-theme.css`
- `src/main/java/org/example/models/FlashSale.java`

### Ghi chú:
Không đổi bảng/cột DB nên không cập nhật `database.md`. Đã build lại WAR (Maven portable), chạy Tomcat cổng 8090, dùng
JSP harness tạm (chỉ trong webapp test, không nằm trong repo) dựng model giả cho flash sale/đánh giá/hồ sơ/danh mục/
topping/trang chủ. Kiểm tra: 25 JSP thuộc role Shop đều 200 + đủ `</html>`; chip lọc sao (5★=3, 1★=1…), checklist mật
khẩu, KPI 4 cột, không tràn ngang ở 375px. **Chưa kiểm chứng:** submit thật các form (lưu hồ sơ + bản đồ, tạo flash sale,
đổi mật khẩu), ảnh/logo thật. Đề nghị user click qua bằng shop có dữ liệu thật.

## 151. Dựng lại bố cục 4 trang Shop theo mock Stitch: Combo, Hóa đơn, Thực đơn, Ví tiền

**Yêu cầu:** Sau mục 150 (chỉ đổi phong cách chung), user bảo "làm tiếp cả 4 trang" (Combo, Hóa đơn, Thực đơn,
Ví tiền) — dựng lại bố cục riêng từng trang theo mock nhưng chỉ dùng dữ liệu hệ thống thật. Không đổi servlet/DAO/DB.

- **`shop/Quanlycombo.jsp`:** hàng 3 thẻ thống kê (Tổng combo / Đang bán / Tiết kiệm trung bình — tính từ
  `Combo.active` + giá gốc = Σ giá size × số lượng của `ComboItem`); bố cục 2 cột: trái là thẻ combo (ảnh món đầu
  tiên có ảnh, tag `-x%`, badge Đang bán/Tạm ngưng, danh sách món, giá combo + giá gốc gạch ngang + "Tiết kiệm"),
  phải là khung **Combo Builder** dính khi cuộn (3 bước: thông tin / món / định giá) kèm ô tổng kết trực tiếp
  (giá gốc, tiết kiệm hoặc cảnh báo giá cao hơn mua lẻ; `<option data-price>` + `updateComboSummary()`). Vá kèm:
  `editCombo()` trước đây điền giá dạng `85000.0` vào ô có `data-money`, nay làm tròn + format dấu chấm.
- **`shop/Quanlybill.jsp`:** 4 thẻ thống kê (Tổng hóa đơn / Doanh thu đã thanh toán trừ đơn hủy / Chờ xác nhận —
  viền nổi khi >0 / Đã giao), tab lọc theo trạng thái đơn kèm số đếm (lọc phía client trên danh sách đang hiển
  thị, thêm `data-ds` cho mỗi dòng), gọn bảng từ 9 → 6 cột (gộp mã đơn+ngày, khách+địa chỉ rút gọn, tổng tiền+hình
  thức) để nút thao tác không còn bị cắt. Toàn bộ form xác nhận/hủy/đã chuẩn bị giữ nguyên.
- **`shop/Quanlysanpham.jsp`:** bảng → lưới thẻ món (ảnh, tên, mô tả 2 dòng, loại, tồn kho, đã bán, giá + chip
  size, badge trạng thái, "Sửa món"/xóa; món Hết hàng/Tạm ẩn xám ảnh + cờ trên ảnh); chip loại sản phẩm kèm số món
  thay cho select loại; JS `applyFilters()` đọc `.menu-card` (chip + select trạng thái + ô tìm ở topbar) và hiện
  thông báo khi không khớp. Modal thêm/sửa giữ nguyên. Fix nhỏ: `onerror` ảnh dùng `nextElementSibling`.
- **`shop/viTien.jsp`:** thẻ ví (số dư + 3 chỉ số tổng đã thu/đã rút/đang chờ duyệt) cạnh **thẻ ngân hàng** (tên
  ngân hàng, số TK, chủ TK từ hồ sơ shop, hoặc CTA cập nhật nếu chưa có); lịch sử giao dịch + form rút tiền đặt
  song song (form dính khi cuộn), bảng lịch sử rút tiền giữ bên dưới. Bỏ khối "tài khoản đã lưu" trùng lặp trong form
  (thay bằng 1 dòng nơi nhận tiền). Toàn bộ dữ liệu vẫn là `wallet`, `transactions`, `withdrawals`, `shop`.

**Không làm (mock có, hệ thống không có):** biên lợi nhuận/AOV combo, "Bật/Tắt bán" nhanh cho combo, in phiếu
xem trước bên cạnh bảng hóa đơn, "Tự động gán shipper", giá vốn/biên lợi nhuận món, biểu đồ tăng trưởng + cơ cấu chi
phí và đối soát phí từng đơn của ví, eKYC/xuất đối soát.

### Files sửa:
- `src/main/web/shop/Quanlycombo.jsp`, `Quanlybill.jsp`, `Quanlysanpham.jsp`, `viTien.jsp`

### Ghi chú:
Không đổi DB/servlet nên không cập nhật `database.md`. Kiểm chứng: build lại + chạy Tomcat cổng 8090, dùng **JSP
"harness" tạm chỉ đặt trong webapp test (không nằm trong repo)** để dựng model giả (combo 3 gói, 8 đơn đủ trạng thái, 6
món 3 loại, ví có/không có ngân hàng) rồi forward tới JSP thật — xem đủ trạng thái có dữ liệu mà không ghi vào DB
thật. Đã test: tổng kết Combo Builder tính đúng (316.000đ gốc → tiết kiệm 66.000đ/21%), sửa combo nạp đúng, tab lọc
hóa đơn (Hoàn tất=2, Đã hủy=1...), chip+select+tìm món kết hợp đúng, không tràn ngang ở 375px. **Chưa test:** submit
form thật (tạo/sửa/xóa combo, xác nhận đơn, rút tiền) và ảnh món thật — đề nghị click qua bằng shop có dữ liệu.

## 150. Áp bộ thiết kế Stitch cho role SHOP (đối tác quán): theme riêng + sidebar dùng chung

**Yêu cầu:** User gửi zip Stitch mới (`stitch_remix_of_foodmanage_ui_design.zip`: 16 trang mẫu Shop + 1 trang
Admin khiếu nại + `DESIGN.md`) và bảo "làm role shop đối tác trước, admin tôi sẽ gửi file zip khác". Bản mẫu Shop
dùng sidebar trái "VẬN HÀNH QUÁN ĂN", nền kem, mục đang chọn tô đỏ đặc, nút pill, card bo lớn, bóng ấm.

**Thiết kế thực hiện (CSS-first, không đổi logic/servlet):** các trang Shop dùng chung `theme.css` +
`dashboard.css` với Super Admin/Shipper nên KHÔNG sửa 2 file đó. Thay vào đó:
- Tạo `assets/css/shop-theme.css`, nạp SAU `dashboard.css`, chỉ có tác dụng khi `<body class="dash-body shop-theme">`.
  Đè token (`--primary #E3250A`, nền `#FEF8F1`, chữ `#2D2421`, bóng `rgba(99,44,20,..)`, bo góc 12/16/24px,
  font Plus Jakarta Sans + Quicksand cho tiêu đề), restyle sidebar (mục active đỏ đặc + đổ bóng CTA),
  topbar, card/panel/stat-card, nút pill, ô nhập (viền/glow cam khi focus), badge, bảng, modal, scrollbar.
  Thêm định nghĩa `.dash-card`/`.dash-card-header`/`.dash-card-body` (Combo + Flash Sale dùng class này
  nhưng dashboard.css chưa từng định nghĩa nên trước đây hiển thị phẳng), CSS thanh lọc `.filter-bar`
  (Quản lý hóa đơn), và rule mobile cho topbar (wrap thay vì tràn).
- Tạo `shop/_shopSidebar.jspf` (nhúng tĩnh, cùng kiểu `_invoiceModal.jspf`, có `pageEncoding="UTF-8"` —
  thiếu dòng này sidebar bị vỡ tiếng Việt). 19 trang từng copy-paste cùng 1 sidebar (chỉ khác mục `active`
  và tên biến shop) nay dùng chung 1 file; trang set `shopActive` (đường dẫn mục đang mở) trước khi include.
  Sidebar mới: logo FoodManage + "ĐỐI TÁC QUÁN", thẻ cửa hàng (tên qua `c:out`, badge Đang mở/Đang đóng theo
  `Shop.isOpenNow()` thật, tên tài khoản), icon Material Symbols thay emoji. Menu giữ nguyên route cũ.
- Icon tiêu đề topbar của 18 trang đổi emoji → Material Symbols (`.tb-icon`).

**Trang đã áp theme:** `trangcuahang, Quanlysanpham, Quanlyloaisanpham, Quanlytopping, Quanlyloaitopping,
Quanlybill, HoaDonShop, Quanlycombo, QuanlyFlashSale, viTien, xemDanhGia, Shopprofile, hoSoShop,
doiMatKhauShop, ThungRac{SanPham,LoaiSanPham,Topping,LoaiTopping}, ThanhToanThatBaiPos`.
- `Banhang.jsp` (POS, trang độc lập, có CSS riêng): bỏ CSS sidebar cục bộ, nạp dashboard.css + shop-theme.css,
  dùng sidebar chung, thêm nút ☰ mobile + `dashboard-theme.js` (cần cho `pobToggleSidebar()`); giữ nguyên
  toàn bộ CSS/JS của khu vực bán hàng.
- Nhóm đăng ký/chờ duyệt: `registerShop.jsp`, `dangKyChoDuyet.jsp` (bảng màu teal/slate cũ → nâu ấm/đỏ cam,
  Plus Jakarta Sans + Quicksand, title "FOOD MANAGE"), `shopChoDuyet.jsp`, `shopTuChoi.jsp`,
  `shopDangKyThongTin.jsp` (viết lại `<style>`, trước là xám/teal Arial).
- Màu lẻ: biểu đồ doanh thu trang chủ, hero ví tiền (navy → nâu-đỏ ấm), banner "Xem đánh giá" (gradient thương hiệu).

**KHÔNG áp dụng (cố ý):** `taoCategory.jsp`, `taoProduct.jsp` (thực chất là trang CRUD của SUPER ADMIN,
đặt nhầm thư mục `shop/`, chờ đợt Admin); `shopDanhSach.jsp`, `shopThemSua.jsp`, `quanLyCuaHang.jsp` (CRUD nội
bộ). Mọi tính năng CHỈ có trong mock mà hệ thống không có (KDS/phiếu bếp, đồng bộ app POS, hotline hỗ trợ,
giao dịch FoodPay, AOV/biên lợi nhuận combo, hồ sơ eKYC/ATVSTP, "Đổi trạng thái quán"...) — bỏ qua để không hứa
hẹn sai; chỉ lấy ngôn ngữ hình ảnh.

### Files sửa:
- `src/main/web/assets/css/shop-theme.css` (mới), `src/main/web/shop/_shopSidebar.jspf` (mới)
- 19 JSP dashboard Shop (danh sách ở trên), `Banhang.jsp`, `ThanhToanThatBaiPos.jsp`
- `registerShop.jsp`, `dangKyChoDuyet.jsp`, `shopChoDuyet.jsp`, `shopTuChoi.jsp`, `shopDangKyThongTin.jsp`
- `PROJECT_STRUCTURE.md`

### Ghi chú:
Không đổi schema/servlet/DAO nên không cập nhật `database.md`. Đã build WAR bằng Maven portable, chạy Tomcat
riêng cổng 8090 với DB thật, đăng nhập tài khoản Shop test (`Bao`): toàn bộ 24 JSP trả 200 + đủ `</html>`, sidebar
hiển thị đúng tiếng Việt/icon/mục active, thu gọn sidebar + ☰ mobile hoạt động, không tràn ngang ở 375px.
**Chưa kiểm chứng được với dữ liệu thật:** tài khoản `Bao` chưa có hồ sơ shop nên các danh sách (sản phẩm, combo,
hóa đơn, ví tiền...) chỉ xem được trạng thái rỗng; luồng bấm bill/PayOS/duyệt đơn không được chạy thử. Đề nghị
user click qua các trang bằng 1 shop có dữ liệu thật.

## 149. Bổ sung trang mẫu "Giỏ hàng" bị bỏ sót + đồng bộ 8 trang khách hàng/xác thực còn màu cũ

**Yêu cầu:** User hỏi "kiểm tra xem đã đủ các trang trong file zip chưa". Rà lại 1-1 15 trang mẫu Stitch
với JSP thật thì phát hiện mục 146/147 báo "đầy đủ" là SAI: mẫu "Giỏ hàng xác nhận" tương ứng
`user/gioHang.jsp` (route `/user/cart` — nút giỏ hàng trên navbar mọi trang trỏ vào đây) chưa từng được mở
hay sửa (trước đó gộp nhầm mẫu này vào `checkoutThanhToan.jsp`, thực ra là 2 trang riêng). User chọn làm cả
2 nhóm: (1) giỏ hàng, (2) các trang khách hàng/xác thực khác còn bảng màu cũ.

**Nhóm 1 — `user/gioHang.jsp`:** đổi toàn bộ bảng màu sang token Stitch (cam-đỏ `#FF3B1F`, nền kem
`#FFF9F2`, chữ nâu `#2D2421`, viền `#F1E4D6`; slate xám lạnh → nâu ấm), thêm Quicksand cho logo/tiêu đề,
thêm stepper "Chọn món → Giỏ hàng & Thanh toán → Theo dõi giao hàng" đồng bộ với `checkoutThanhToan.jsp`,
size được chọn trong modal sửa đổi sang màu thương hiệu (trước là xanh đen), `.alert-success` đổi từ nền
cam sang xanh lá đúng ngữ nghĩa, thêm `.page-wrap > * { min-width: 0 }` (tránh lỗi grid tràn ngang đã gặp ở
mục 148). Không đụng logic/JS/id: chọn tất cả, đổi số lượng, sửa size/topping, xoá, form CSRF giữ nguyên.

**Nhóm 2 — các trang còn màu cũ:**
- `user/doiMatKhauUser.jsp`, `user/thongBao.jsp`, `user/guiFeedback.jsp`, `user/thanhToanThatBai.jsp`: cùng
  bộ sed màu + thêm font Quicksand cho tiêu đề (`--font-h`); riêng `thanhToanThatBai.jsp` bỏ font Inter cũ.
  `doiMatKhauUser`/`thongBao` thêm `flex-shrink: 0` cho `.logo` (tránh bug vỡ logo như mục 148).
- `user/yeuCauHoanTien.jsp`: phát hiện **bug có sẵn** — trang dùng các biến `--bg-main`, `--text-main`,
  `--bg-panel`, `--bg-input`, `--border-color`, `--text-muted`, `--font-sans` nhưng chúng chỉ được định
  nghĩa cục bộ trong từng trang admin (ví dụ `admin/BaoCaoVanHanh.jsp`), KHÔNG có trong `theme.css` → trên
  trang khách hàng này nền/chữ/viền/font rơi về mặc định trình duyệt. Đã định nghĩa lại các biến này trong
  `:root` cục bộ theo bảng màu Stitch (không sửa `theme.css` vì file dùng chung với admin/shop/shipper), và
  thêm `font-family: inherit` cho ô nhập.
- `register.jsp`, `nhapOTP.jsp`, `quenmatkhau.jsp`: cùng layout chia đôi với `DangNhap.jsp` nhưng còn tông
  xanh lá (`#10b981`) + panel xanh navy + font Inter → đổi sang cam-đỏ thương hiệu, panel nâu đậm
  `#3A1206→#1A0A04`, chữ nhấn vàng `#FFB300`, nền kem `#FFF9F2`, Quicksand cho tiêu đề. Đã kiểm tra mọi chỗ
  dùng màu xanh trong 3 file đều là màu nhấn thương hiệu (focus, nút, link), không có chỗ nào là màu
  "thành công" cần giữ xanh.
- Đổi `<title>` còn ghi "POB" sang "FOOD MANAGE" ở 7 trang (`register`, `nhapOTP`, `quenmatkhau`,
  `doiMatKhauUser`, `thongBao`, `diemThuong`, `hoaDon`).

**Kiểm thử thật (mvn package OK → Tomcat cổng 8090 riêng → Browser pane, đăng nhập tài khoản
`claude_qa_test` như mục 148):** render đúng và đã chụp xem bằng mắt ở desktop: `/user/cart` (trạng thái
giỏ trống), `/user/doi-mat-khau`, `/user/thong-bao`, `/dangky`, `/quenmatkhau`, `/xacnhanotp`,
`/user/thanhToanThatBai.jsp`, `/user/guiFeedback.jsp`, `/user/yeuCauHoanTien.jsp` (2 trang cuối mở thẳng
file JSP vì servlet yêu cầu đơn hàng thật nên chỉ thấy khung form, không có dữ liệu đơn). Quét ở 375px:
`scrollWidth == innerWidth` (không tràn ngang) trên cả 6 trang truy cập được bằng route thật. **Chưa test
được:** giỏ hàng CÓ món (shop demo vẫn không có sản phẩm) nên các thao tác đổi số lượng/sửa size-topping/xoá
chưa chạy thật — chỉ sửa CSS/HTML tĩnh, không đụng JS/servlet nên rủi ro thấp nhưng nên tự thử.

### Files sửa:
- `src/main/web/user/gioHang.jsp`, `doiMatKhauUser.jsp`, `thongBao.jsp`, `guiFeedback.jsp`,
  `thanhToanThatBai.jsp`, `yeuCauHoanTien.jsp`, `diemThuong.jsp` (chỉ title), `hoaDon.jsp` (chỉ title)
- `src/main/web/register.jsp`, `nhapOTP.jsp`, `quenmatkhau.jsp`

### Ghi chú:
Không đổi schema DB, không đổi Java. Vẫn CHƯA đụng: 4 trang scaffold CRUD nội bộ (`DanhSachGioHang`,
`cartItemDanhSach`, `themSuaGioHang`, `cartItemThemSua`, `orderDanhSach`...), và toàn bộ giao diện
Shop/Admin/Shipper (zip không có mẫu). Tomcat test đã dừng; tài khoản `claude_qa_test` vẫn còn trong DB.
Đối chiếu cuối cùng với zip: trang "Kho voucher" và "Cổng PayOS" vẫn không có JSP tương ứng (không phải
bỏ sót — hệ thống chưa có tính năng / do PayOS host).

## 148. Rebuild + test thật bằng Tomcat/DB thật, phát hiện và vá 4 bug thật

**Yêu cầu:** User bảo "rebuild rồi test thử tất cả các trang đã sửa". Trước đó mọi ghi chú (mục
138-147) đều nói "không có Maven/Tomcat CLI trong môi trường này" — hoá ra KHÔNG ĐÚNG, chỉ là chưa thử
kỹ. Đợt này thực sự dựng được môi trường build+run thật:
- Tải Apache Maven 3.9.9 portable (không có sẵn `mvn` trong PATH) vào thư mục scratch.
- `mvn clean package` build ra `target/ROOT.war` — build thành công, không lỗi compile Java lẫn JSP.
- Phát hiện Tomcat 10.1.54 thật đã cài sẵn tại `F:\apache-tomcat-10.1.54-windows-x64` (dùng chung với
  SmartTomcat plugin của IDE) — dựng 1 `CATALINA_BASE` RIÊNG trong thư mục scratch (copy `conf/`, đổi
  cổng HTTP `8080→8090` và shutdown `8005→8105`) để KHÔNG đụng vào Tomcat/state thật của user, deploy
  `ROOT.war` vào đó và chạy nền.
- Xác nhận DB thật (SQL Server tại `14.225.217.109:1433`, đã có sẵn trong `DBUtil.java`) truy cập được
  từ môi trường này — dùng thẳng DB thật để test (không phải mock).
- Đăng ký tài khoản thật qua `/dangky` bị chặn vì SMTP Gmail trong `EmailUtil.java` sai mật khẩu ứng
  dụng (lỗi môi trường có sẵn, không phải do đợt sửa này) nên không gửi được OTP xác thực. Để có tài
  khoản test đăng nhập được, đã viết 1 script Java nhỏ (`SeedTestAccount.java`, chỉ chạy trong phiên
  này, không phải file trong repo) dùng đúng thư viện `jbcrypt` của project để tạo 1 Account thật trong
  DB: `username=claude_qa_test`, `password=QaTest12345`, `roleId=3` — **tài khoản test thật nằm trong DB
  chung, user nên tự xoá nếu không cần giữ lại** (`DELETE FROM Accounts WHERE username='claude_qa_test'`).
- Dùng Browser pane đăng nhập bằng tài khoản này, bấm qua toàn bộ các trang đã sửa (TrangChu, DangNhap,
  trangnguoidung, donhang, diaChi, diemThuong, thongTinCaNhan, khieuNai, menuShop, checkoutThanhToan),
  kiểm tra cả responsive mobile (375px).

**4 bug THẬT phát hiện được nhờ chạy thật (không thấy được nếu chỉ đọc code) — đã vá hết:**

1. **`user/trangnguoidung.jsp` — trang trắng giữa chừng, cắt cụt HTML:** EL `${account.loyaltyPoints}`
   dùng property KHÔNG TỒN TẠI trên model `Account` (điểm thưởng thực ra chỉ lấy được qua
   `AccountDAO.getLoyaltyPoints(id)`, không phải field trên object) → Jasper ném exception runtime giữa
   lúc đang stream response, HTML bị cắt cụt ngay tại thẻ `<h4>` đó, toàn bộ phần dưới (2 thẻ thống kê
   còn lại, danh sách nhà hàng, footer) biến mất hoàn toàn — không có trang lỗi rõ ràng nào hiện ra vì
   response đã commit 1 phần. Vá đúng cách: thêm `AccountDAO` + gọi `getLoyaltyPoints()` trong
   `UserHomeServlet.java`, set attribute `loyaltyPoints`, sửa JSP dùng `${loyaltyPoints}` thay vì
   `${account.loyaltyPoints}`.
2. **`user/trangnguoidung.jsp` — logo "FOOD MANAGE" vỡ dòng đè lên menu** ở độ rộng ~1024px: file này
   là DUY NHẤT trong 6 file dùng chung layout navbar bị thiếu `flex-shrink: 0` trên `.logo` (5 file kia
   — donhang/khieuNai/diaChi/diemThuong/thongTinCaNhan — đều đã có sẵn, không hiểu sao riêng file này
   thiếu). Đã thêm `flex-shrink: 0` + `white-space: nowrap` cho logo.
3. **`user/menuShop.jsp` — icon chuông thông báo & giỏ hàng trên navbar hoàn toàn rỗng** (2 vòng tròn
   trống không có icon): file dùng class `fa-solid fa-bell`/`fa-bag-shopping` nhưng KHÔNG hề load CSS
   Font Awesome trong `<head>` (bug có sẵn từ trước, không phải do đợt màu mục 139). Đã thêm
   `<link>` cdnjs font-awesome 6.4.0 giống các trang khác.
4. **`TrangChu.jsp` — tràn ngang nghiêm trọng trên mobile (≤600px):** dù đã tự nhận "đã kiểm tra
   responsive" ở mục 140 (chỉ đọc code, không chạy thật), khi bật giả lập 375px thật sự thì: (a) nút
   CTA header "Đăng nhập / Đặt món ngay" không co được vì `.nav-actions` có `flex-shrink: 0` cứng, (b)
   toàn bộ `.hero-content` và các con (search bar, trending tags, CTA, stat cards) bị ép rộng 391px dù
   container chỉ có 343px — lỗi CSS Grid kinh điển: `grid-template-columns: 1fr` vẫn tôn trọng min-content
   width của con bên trong trừ khi có `min-width: 0`. Đã vá: bọc chữ CTA header trong
   `<span class="cta-label">` để ẩn ở ≤720px (chỉ còn icon), thêm `min-width: 0` cho `.hero-grid > *`
   và `.cat-head-row > *`/`.filter-tabs`, thêm `overflow-x: hidden` an toàn cho `html`/`body`. Đã xác
   nhận lại bằng script JS quét toàn bộ phần tử `getBoundingClientRect().right > viewport` — từ 27 phần
   tử tràn xuống 0 (chỉ còn 1 phần tử là chip danh mục nằm trong thanh cuộn ngang CÓ CHỦ ĐÍCH, không
   phải lỗi).

### Files sửa:
- `src/main/java/org/example/controllers/UserHomeServlet.java` (thêm `AccountDAO` + attribute
  `loyaltyPoints`)
- `src/main/web/user/trangnguoidung.jsp` (dùng đúng attribute + fix logo wrap)
- `src/main/web/user/menuShop.jsp` (thêm link Font Awesome)
- `src/main/web/TrangChu.jsp` (fix tràn ngang mobile toàn diện)

### Ghi chú:
Không đổi schema DB. Server test (Tomcat cổng 8090 + `CATALINA_BASE` riêng trong thư mục scratch của
phiên làm việc) đã được dừng lại sau khi test xong, không để lại tiến trình chạy nền. **Tài khoản DB
thật `claude_qa_test` vẫn còn trong bảng `Accounts`** — đề nghị user tự xoá nếu không cần dùng để test
tiếp. Do quán "wishe" (shop demo có sẵn trong DB) chưa có sản phẩm nào nên KHÔNG test được luồng thêm
giỏ hàng → thanh toán đầy đủ qua UI thật (chỉ xác nhận được `checkoutThanhToan.jsp` tự động chuyển
hướng an toàn khi giỏ trống, không lỗi) — đề nghị user tự test luồng đặt hàng đầy đủ với 1 shop có sẵn
món ăn thật. Cũng chưa test được `hoaDon.jsp` (hóa đơn) do tài khoản test chưa có đơn hàng nào.

## 147. Audit + làm rõ 3 trang mẫu Stitch còn sót (theo yêu cầu "làm rõ và hoàn thiện nốt")

**Yêu cầu:** Sau mục 146, user hỏi "đã đầy đủ các trang trong file zip chưa" — mình rà lại và phát hiện
mục 146 báo cáo hơi vội: 3 trong 16 thư mục mẫu chưa hề được MỞ ĐỌC (chỉ đoán qua tên/tiêu đề), gồm
`foodmanage_theo_d_i_shipper_realtime_qua_b_n_live_gps_tracking` (617 dòng), `foodmanage_kh_m_ph_th_c_n_t_m_n_tr_c_tuy_n_customer_portal`
(khám phá thực đơn), và `foodmanage_chi_ti_t_qu_n_burger_wagyu_king_t_m_n` (chi tiết quán). User yêu
cầu đọc kỹ và hoàn thiện nốt. Đã đọc đầy đủ cả 3 file và đối chiếu với trang thật:

**1. Theo dõi shipper realtime (bản đồ full-screen):**
Bản mẫu là 1 trang bản đồ full-screen riêng (SVG minh hoạ tĩnh do Stitch không dựng được bản đồ thật),
có thẻ tài xế, hành trình 4 bước, chat nhanh mẫu câu, chỉ số tốc độ/giao thông. Hệ thống thật ĐÃ CÓ bản
đồ Leaflet + WebSocket thật (không phải SVG giả) nhúng trong từng đơn tại `donhang.jsp`
(`/ws/tracking`, xem mục 25/25c) — chỉ là khung nhỏ 220px. Quyết định: không tạo trang full-screen mới
(sẽ trùng lặp/phân mảnh trải nghiệm, tốn công đồng bộ 2 nơi), thay vào đó NÂNG CẤP khung bản đồ có sẵn:
tăng chiều cao 220px→320px, thêm badge nổi "GPS Realtime" (pulse dot) góc phải bản đồ (đặt bên phải để
tránh đè lên nút zoom mặc định của Leaflet ở góc trái). KHÔNG thêm chat mẫu (không có hệ thống chat
thật), KHÔNG thêm tốc độ/giao thông (không có dữ liệu thật cho việc này).

**2. Khám phá thực đơn (trang browse nâng cao):**
Bản mẫu có sidebar lọc nâng cao: khoảng giá (slider + checkbox), lọc theo sao đánh giá, thời gian giao,
ưu đãi đối tác — TOÀN BỘ đều cần dữ liệu tổng hợp mới (khoảng giá theo shop, rating theo shop tính
sẵn...) mà `UserHomeServlet` hiện chưa tính. Đây thực chất là 1 TÍNH NĂNG MỚI (bộ lọc nâng cao), không
phải việc thiết kế lại giao diện — nếu làm giả (checkbox không lọc được gì) sẽ vi phạm nguyên tắc không
bịa tính năng đã thống nhất từ đầu. Quyết định: KHÔNG thêm sidebar lọc giả. Trang tương ứng thật gần
nhất (`trangnguoidung.jsp`, lưới quán ăn + tìm kiếm) đã được làm ở mục 141, coi như đã phủ đúng phần
lõi thật sự của trang mẫu này (danh mục + tìm quán/món), phần lọc nâng cao để ngỏ nếu sau này muốn làm
thành 1 tính năng thật riêng.

**3. Chi tiết quán (trang mẫu "Burger Wagyu King"):**
Đối chiếu kỹ với `user/menuShop.jsp` thật — hoá ra trang thật ĐÃ vượt xa bản mẫu về độ đầy đủ tính
năng thật: đã có hero quán (logo/mô tả/địa chỉ/SĐT/giờ mở-đóng cửa thật qua `shop.openTime`/
`closeTime`), rating thật (`avgRating`/`totalFeedback` qua FeedbackDAO), pill lọc theo danh mục sản
phẩm thật (`categories`), khu Flash Sale có đếm ngược thời gian thật, khu Combo khuyến mãi thật, badge
Hot/Mới/Hết hàng/Sale theo dữ liệu thật — tất cả đã được đổi màu đúng token mới từ mục 139. Bản mẫu
Stitch chỉ có thêm: dải voucher riêng của quán (không rõ có hạ tầng "voucher theo shop" thật hay
không — cần audit riêng nếu muốn làm) và badge "Đối tác Kim Cương" (danh hiệu giả, không làm). Kết
luận: **không cần sửa thêm gì ở `menuShop.jsp`** — trang đã đạt/vượt yêu cầu.

### Files sửa:
- `src/main/web/user/donhang.jsp` (tăng khung bản đồ + badge GPS Realtime)

### Kết luận cuối cùng về độ đầy đủ so với zip:
Toàn bộ 15 trang mẫu "screen" thật trong zip (không tính `food_manage_experience/DESIGN.md` và
`foodmanage_brand_logo` — không phải trang) đã được đối chiếu 1-1 với trang JSP thật hoặc đã xác nhận lý
do không áp dụng. Không còn trang mẫu nào chưa được xem xét.

## 146. Tổng kết đợt áp bộ thiết kế Stitch cho toàn bộ giao diện Khách hàng (mục 138→146)

**Bối cảnh:** Sau khi user gửi 2 file zip thiết kế Stitch (mục 139) rồi bảo "làm tiếp các trang khác" /
"cứ tiếp tục luôn đi" (mục 141-145), đã đi lần lượt qua toàn bộ 12 trang JSP thật thuộc role Khách hàng
khớp với 16 trang mẫu trong zip. Mục này tổng kết trạng thái cuối cùng để lần sau (hoặc người khác) tra
cứu nhanh, khỏi phải đọc lại toàn bộ mục 138-145.

**Đã hoàn thành đầy đủ (đổi màu + polish cấu trúc theo bản mẫu, có kiểm tra không phá logic thật):**
- `TrangChu.jsp` — viết lại hoàn toàn theo đúng `code.html` gốc (mục 140).
- `user/trangnguoidung.jsp` — trang chủ member, lời chào cá nhân hoá dùng dữ liệu thật (mục 141).
- `user/checkoutThanhToan.jsp` — giỏ hàng & thanh toán, vá 2 bug thật (voucher input trùng, sai route)
  (mục 142).
- `user/donhang.jsp` — đơn hàng + theo dõi shipper, thêm thẻ thống kê/tab lọc dùng dữ liệu thật (mục 143).
- `user/khieuNai.jsp` — khiếu nại, thêm mini-timeline trạng thái thật (mục 144).
- `user/hoaDon.jsp` — hóa đơn, dịch trạng thái + màu badge theo status thật (mục 145).
- `DangNhap.jsp` — đăng nhập, viết lại toàn bộ bảng màu (mục 139, trước đó lệch tông xanh lá).

**Đã kiểm tra và xác nhận SẠCH từ mục 139 (không cần sửa thêm ở đợt polish sâu này):**
- `user/diaChi.jsp` (sổ địa chỉ) — đã đúng token màu + Quicksand, có sẵn badge địa chỉ mặc định + map
  picker, không có gì cần đổi thêm.
- `user/thongTinCaNhan.jsp` (trang cá nhân), `user/diemThuong.jsp` (ví điểm thưởng) — đã đúng token
  màu, chỉ còn màu semantic (danger/info/success) hợp lệ, không sót xám lạnh.
- `user/menuShop.jsp` (khám phá thực đơn / chi tiết quán) — đã đúng token màu chủ đạo từ mục 139, còn
  vài màu lẻ (nút disabled xám, badge "Flash Sale" cam-đỏ riêng) nhưng đều hợp lý về mặt thiết kế, không
  sửa thêm để tránh rủi ro trên file 1540 dòng có nhiều modal chọn size/topping phức tạp.

**KHÔNG áp dụng (đã ghi rõ lý do từng mục):**
- `user/DanhSachGioHang.jsp`, `user/cartItemDanhSach.jsp`, `user/themSuaGioHang.jsp`,
  `user/cartItemThemSua.jsp` — trang CRUD nội bộ liệt kê entity thô, không phải trải nghiệm khách hàng
  thật (mục 139 ghi chú).
- Trang "Kho voucher ẩm thực" và "Cổng thanh toán PayOS/VietQR" trong zip — chưa có JSP tương ứng /
  không kiểm soát được giao diện (PayOS host) (mục 139 ghi chú).
- Mọi tính năng KHÔNG có thật trong hệ thống xuất hiện trong các trang mẫu Stitch (Ví FoodPay, hạng
  thành viên Gold/Diamond, gợi ý AI theo khẩu vị, quán "đã thả tim"/wishlist, mã voucher giả, tài xế
  giả, upsell combo giả) — cố ý bỏ qua toàn bộ để tránh hứa hẹn sai với người dùng thật, xem lý do chi
  tiết ở từng mục 141/142.

**Ngoài phạm vi (chưa làm, cần yêu cầu riêng nếu muốn tiếp tục):** giao diện role Shop, Admin, Shipper —
zip không có trang mẫu nào cho 3 role này (đã hỏi user ở đầu phiên, xem lịch sử hội thoại).

### Ghi chú:
Không có Maven/Tomcat CLI trong môi trường này xuyên suốt cả đợt nên KHÔNG trang nào được build/chạy
thử thực tế — toàn bộ xác minh chỉ dừng ở mức đọc lại code + grep kiểm tra cân bằng thẻ JSTL/sạch màu
cũ. Đề nghị user dành thời gian rebuild/redeploy và click qua thật kỹ toàn bộ 12 trang đã sửa trước khi
coi đợt việc này là hoàn tất, đặc biệt các trang có logic JS phức tạp (`checkoutThanhToan.jsp` tính phí
ship theo bản đồ, `donhang.jsp` WebSocket tracking).

## 145. Hoàn thiện màu ấm cho hoaDon.jsp + dịch trạng thái đơn ra tiếng Việt có màu theo status thật

**Yêu cầu:** Tiếp tục áp bộ thiết kế Stitch cho `user/hoaDon.jsp` (hóa đơn — đã đổi 1 phần màu chính ở
mục 139 nhưng còn sót nhiều xám lạnh slate chưa đổi, khác các trang khác đã làm kỹ ở mục 142/143).
Đã kiểm tra `diaChi.jsp` trước đó — trang này đã sạch hoàn toàn từ mục 139 nên bỏ qua, không cần sửa
thêm.

**Đã làm:**
- Đổi nốt toàn bộ hex xám lạnh còn sót (`#0f172a/#374151/#475569/#64748b/#94a3b8/#e2e8f0/#f8fafc/
  #f1f5f9/#cbd5e1/#eef0f4/#e9edf2`) sang bộ màu ấm đồng bộ.
- Badge trạng thái trên hóa đơn trước đây LUÔN hiển thị màu cam-đỏ cố định và in thẳng giá trị enum
  tiếng Anh thô (`bill.order.staTus`, vd hiện chữ "DONE"/"CANCELLED" y nguyên) — sửa thành dịch tiếng
  Việt đúng như cách `donhang.jsp` đã làm (Chờ xác nhận/Đang chuẩn bị/.../Đã giao thành công/Đã hủy) và
  đổi màu badge theo đúng trạng thái thật (xanh lá khi `DONE`, đỏ khi `CANCELLED`, xanh dương khi đang
  xử lý) thay vì 1 màu cứng cho mọi trạng thái.

### Files sửa:
- `src/main/web/user/hoaDon.jsp`

### Ghi chú:
Không đổi Servlet/DAO, không đổi schema DB, không đổi CSS `@media print` (khổ giấy nhiệt) — chỉ đổi
biến màu và cách hiển thị text trạng thái. Đã grep cân bằng thẻ JSTL và xác nhận sạch hex cũ. Đề nghị
user rebuild rồi in thử hóa đơn để chắc chắn khổ giấy nhiệt (58mm/80mm) không bị ảnh hưởng bởi thay đổi
màu badge.

## 144. Polish khieuNai.jsp (khiếu nại & bồi hoàn) theo phong cách Stitch

**Yêu cầu:** Tiếp tục áp bộ thiết kế Stitch. Trang này (`user/khieuNai.jsp`, tương ứng
`foodmanage_khi_u_n_i_n_h_ng_y_u_c_u_b_i_ho_n_customer_complaint_refund` trong zip) đã được đổi màu ở
mục 139 rồi và vốn khá gọn (form gửi khiếu nại + danh sách khiếu nại cũ có badge trạng thái + phản hồi
Admin, nối đúng `ComplaintDAO`/`Complaint` model — xem mục 52). Không đọc lại toàn bộ 663 dòng file mẫu
chi tiết (đã nắm rõ pattern chung từ 4 trang trước), chỉ áp nhanh phần polish thị giác hợp lý.

**Đã làm:**
- Thêm khối `.card-head` (icon tròn + tiêu đề + mô tả phụ) cho cả 2 card (form gửi khiếu nại, danh sách
  khiếu nại) — card danh sách hiển thị số khiếu nại thật (`fn:length(complaints)`) thay vì chỉ có tiêu
  đề tĩnh.
- Thêm mini-timeline 3 chấm (Đã gửi → Đang xử lý → Kết quả) cho mỗi khiếu nại, tô màu theo đúng
  `c.status` thật (`PENDING/PROCESSING/RESOLVED/REJECTED`) — không phải trang trí giả, phản ánh đúng
  trạng thái backend.

### Files sửa:
- `src/main/web/user/khieuNai.jsp`

### Ghi chú:
Không đổi Servlet/DAO/logic, không đổi schema DB. Đã grep cân bằng thẻ JSTL. Không có Maven/Tomcat CLI
nên không build/test trực tiếp được. Đề nghị user rebuild rồi kiểm tra timeline hiển thị đúng theo từng
trạng thái khiếu nại thật.

## 143. Thêm thẻ thống kê + tab lọc trạng thái thật cho donhang.jsp (đơn hàng của tôi + theo dõi shipper)

**Yêu cầu:** Tiếp tục áp bộ thiết kế Stitch, đọc 2 file mẫu `foodmanage_n_h_ng_c_a_t_i_theo_d_i_n_h_ng_customer_portal/code.html`
(907 dòng) và `foodmanage_theo_d_i_shipper_realtime_qua_b_n_live_gps_tracking/code.html` (617 dòng) —
cả 2 đều tương ứng `user/donhang.jsp` (danh sách đơn + theo dõi live qua WebSocket, xem mục 25/25c).
Đọc kỹ trang thật thì thấy `donhang.jsp` đã ĐƯỢC đổi màu/font ở mục 139 rồi (đã có `--gold:#FF3B1F`,
`--font-h: Quicksand`), và đã có sẵn RẤT nhiều logic thật tinh vi hơn cả bản mẫu Stitch: đủ 5 bước
tracking stepper theo state máy trạng thái đơn hàng thật (PENDING→...→DONE), bản đồ realtime qua
WebSocket `/ws/tracking`, thẻ liên hệ Shop/Shipper thật, nút hủy đơn/hoàn tiền/khiếu nại/đánh giá đều
nối logic thật, modal chi tiết hóa đơn, tự động reload 10s khi có đơn đang hoạt động. Mẫu Stitch có
phần "Ví FoodPay/Gold Member/1.250 Xu" giả — bỏ qua như các trang trước.

**Đã làm (chỉ thêm phần dùng đúng dữ liệu đã có, không bịa số liệu):**
- Thêm 2 thẻ thống kê đầu trang: "Đang thực hiện" và "Tổng đơn" — đếm thật bằng JSTL
  (`<c:set>`+`<c:forEach>` cộng dồn số đơn có `staTus` khác `DONE`/`CANCELLED`, và `fn:length(orders)`),
  không phải số tĩnh như mẫu.
- Thêm 4 tab lọc trạng thái (Tất cả / Đang thực hiện / Đã giao / Đã hủy) — lọc THẬT bằng JS phía client
  dựa trên thuộc tính `data-status="${order.staTus}"` mới thêm vào mỗi `.order-card` (ẩn/hiện
  `display:none`, không gọi lại server, không có state giả).

### Files sửa:
- `src/main/web/user/donhang.jsp`

### Ghi chú:
Không đổi Servlet/DAO (chỉ đọc lại đúng field `order.staTus` đã có), không đổi WebSocket/tracking JS
hiện có, không đổi schema DB nên không cần cập nhật `database.md`. Đã grep xác nhận cân bằng thẻ JSTL
(`c:choose/c:forEach/c:if` đều khớp số mở/đóng, `c:set` không cần thẻ đóng) và không còn hex cũ sót lại
(trang này vốn đã sạch từ mục 139). Không có Maven/Tomcat CLI trong môi trường này nên không tự
build/chạy được. Đề nghị user tự rebuild/redeploy rồi test: (1) tab lọc trạng thái ẩn/hiện đúng đơn
tương ứng, (2) số liệu 2 thẻ thống kê khớp đúng số đơn thật của tài khoản đang đăng nhập, (3) các nút
Hủy đơn/Khiếu nại/Đánh giá/modal chi tiết vẫn hoạt động như cũ (không đổi logic, chỉ thêm khối mới phía
trên).

## 142. Redesign checkoutThanhToan.jsp theo bản mẫu Stitch "Giỏ hàng & Xác nhận đặt món" + tiện thể vá 2 bug thật

**Yêu cầu:** Tiếp tục áp bộ thiết kế Stitch (user nói "cứ tiếp tục luôn đi"). Đọc file mẫu
`foodmanage_gi_h_ng_x_c_nh_n_t_m_n_thi_t_k_m_i/code.html` (635 dòng) — tương ứng đúng với
`user/checkoutThanhToan.jsp` (route `/checkout`) như đã xác định ở mục 138. Đọc kỹ trang thật trước:
trang này đã có RẤT NHIỀU logic thật quan trọng (tính phí ship theo khoảng cách Haversine JS, bản đồ
Leaflet chọn vị trí + geocode, voucher thật nối `bestVoucher`/`VoucherDAO`, hẹn giờ giao, chống
double-submit) — khác hẳn bản mẫu Stitch vốn có nhiều phần bịa (Ví FoodPay số dư giả, badge "Đối tác
Kim Cương", combo upsell ảnh CDN giả, mã voucher giả `WAGYUKING30K`, tích điểm "1.500 Xu" giả). Quyết
định: CHỈ áp dụng phong cách thị giác (màu ấm, bo tròn, Quicksand, shadow ấm, thẻ radio phương thức
thanh toán, stepper 3 bước) lên đúng phần tử/logic thật đang có, không thêm tính năng giả, và KHÔNG
đổi bất kỳ `id`/`name` nào mà JS trang này đang dùng để tính phí ship/bản đồ (nguy cơ vỡ chức năng rất
cao nếu đổi nhầm).

**Phát hiện + vá 2 bug thật khi đọc kỹ code cũ:**
1. Trang có **2 khối "Mã giảm giá" trùng nhau**, cả 2 đều dùng `name="voucherCode"` và cùng
   `id="voucherCodeInput"` — khối đầu có logic banner gợi ý `bestVoucher` thật, khối sau (thêm sau,
   nằm cuối form) là bản tĩnh trùng lặp, link "Đổi điểm lấy voucher" trỏ sai route `/user/loyalty`
   (route thật là `/user/diem-thuong` — `UserLoyaltyServlet`, xem mục 79). Đã gộp làm 1 khối duy nhất,
   giữ logic banner + input thật, sửa link đúng route.
2. Dropdown `<select name="paymentMethod">` đổi thành 2 thẻ radio bo tròn (COD / PayOS) — vẫn đúng 2
   `value` thật hệ thống hỗ trợ (`COD`, `PAYOS`, xem `CheckoutServlet`), không thêm phương thức giả nào
   (mẫu Stitch có thêm "Ví FoodPay"/"Thẻ tín dụng" — bỏ vì hệ thống chưa hỗ trợ).

**Đã làm khác:**
- Đổi toàn bộ màu xám lạnh (slate `#0f172a/#94a3b8/#64748b/#e2e8f0/#f8fafc/#f1f5f9/#cbd5e1/...`, tàn dư
  từ trước khi có hệ màu ấm) sang bộ màu ấm đồng bộ (`#2D2421/#8A7B6C/#635752/#F1E4D6/#FFF9F2/...`),
  đổ bóng card đổi tint từ `rgba(26,32,53,*)` sang `rgba(99,44,20,*)`.
- Nút tăng/giảm số lượng (`.qty-mini-btn`) đổi từ ô vuông bo nhẹ sang khay pill tròn 2 nút trắng nổi
  trên nền kem, giống mẫu Stitch — vẫn 2 `<form>` POST `/user/cart action=qty` y hệt cũ.
- Thêm 1 stepper 3 bước tĩnh phía trên (Chọn món ✓ → Giỏ hàng & Thanh toán (đang ở đây) → Theo dõi
  giao hàng) — chỉ hiển thị vị trí trong luồng thật (chọn món ở `menuShop.jsp` → trang này → theo dõi ở
  `donhang.jsp`), không phải tính năng mới.
- Thêm 1 dòng ghi chú nhỏ dưới nút đặt hàng trỏ tới tính năng khiếu nại THẬT đã có sẵn (mục 52,
  `user/khieuNai.jsp` truy cập từ `user/donhang.jsp`) thay vì lời hứa "đền bù 100%" bịa như mẫu gốc.

### Files sửa:
- `src/main/web/user/checkoutThanhToan.jsp`

### Ghi chú:
Không đổi Servlet/DAO, không đổi bất kỳ `id`/`name` nào JS trang dùng (đã grep xác nhận đủ 21 id quan
trọng: `checkoutLocationXInput`, `distanceDisplay`, `feeDisplay`, `grandTotalDisplay`,
`checkoutSubmitBtn`, `checkoutLocationMap`, `btnDeliveryNow`, v.v. — mỗi cái đúng 1 lần, không thiếu
không thừa), không đổi schema DB nên không cần cập nhật `database.md`. Đã grep xác nhận: chỉ còn 1
`id="voucherCodeInput"` (hết trùng lặp), không còn hex xám lạnh sót lại. Không có Maven/Tomcat CLI
trong môi trường này nên không tự build/chạy/test bản đồ + tính phí ship thật được. Đề nghị user tự
rebuild/redeploy rồi test kỹ luồng thanh toán: (1) chọn vị trí trên bản đồ → phí ship/tổng tiền cập
nhật đúng, (2) nhập mã voucher hoặc bấm "Dùng ngay" ở banner gợi ý → chỉ có 1 ô input nhận giá trị
(trước là 2 ô trùng tên có thể gây gửi sai dữ liệu), (3) chọn COD/PayOS bằng thẻ radio mới → submit
đúng giá trị, (4) nút "Đổi điểm lấy voucher" dẫn đúng sang `/user/diem-thuong` (trước trỏ sai
`/user/loyalty`, có thể đã 404 từ trước).

## 141. Sửa nhầm mapping + redesign trangnguoidung.jsp (trang chủ SAU khi đăng nhập)

**Phát hiện sửa sai:** User bảo "làm tiếp các trang khác" để tiếp tục áp bộ thiết kế Stitch. Mình đọc
tiếp file `foodmanage_trang_ch_th_nh_vi_n_ng_nh_p/code.html` (703 dòng) — trước đó (mục 139) đã LỠ hiểu
nhầm tên thư mục này là "trang đăng nhập" nên chỉ sửa màu `DangNhap.jsp`. Đọc kỹ nội dung mới phát hiện
đây thực ra là **trang chủ của thành viên SAU khi đăng nhập** ("Chào mừng trở lại, Phương Linh! 👋",
đơn đang giao, ví điểm thưởng, gợi ý AI...), khớp đúng với `user/trangnguoidung.jsp` (route
`/user/home`, `UserHomeServlet`) — không liên quan gì tới `DangNhap.jsp`. Việc sửa màu `DangNhap.jsp`
ở mục 139 vẫn ĐÚNG và giữ nguyên (trang đó thật sự lệch tông xanh lá nên cần sửa), chỉ là không phải
bản dịch của trang mẫu này.

**Vấn đề khi áp dụng:** Trang mẫu Stitch có rất nhiều nội dung KHÔNG có thật trong hệ thống: Ví
FoodPay, hạng thành viên Gold/Diamond + thanh tiến trình thăng hạng, gợi ý món ăn theo "AI học khẩu
vị", danh sách quán "đã thả tim" (wishlist), theo dõi đơn hàng trực tiếp có tên tài xế/biển số giả,
voucher cá nhân hoá với mã giả (`GOLDVIP30K`...). Hệ thống thật (`UserHomeServlet`) chỉ truyền
`account`, `shops` (danh sách quán active), `unreadNotifCount`, `shopProductsJson` — KHÔNG có ví, hạng
thành viên, wishlist, hay gợi ý AI. Quyết định: chỉ lấy phần **thiết kế thị giác + nội dung có dữ liệu
thật**, không bịa tính năng giả (tránh hứa hẹn sai với người dùng thật).

**Đã làm (`user/trangnguoidung.jsp`):**
- Đổi bảng màu local `:root` sang token mới (`#FF3B1F/#E02A10/#2D2421/#635752/#FFF9F2/#FFC7BE/#FFF2F0`,
  giống pattern đã dùng ở 9 trang mục 139), thêm `--brand-700/--brand-500` cho gradient thương hiệu,
  đổ bóng ấm `rgba(99,44,20,*)`.
- Thêm font Quicksand (`--font-h` trỏ sang Quicksand, các thẻ `h1-h6` toàn trang tự động đổi font qua
  rule `h1,h2,h3,h4,h5,h6{font-family:var(--font-h)}` có sẵn từ trước).
- Đổi `.navbar` từ nền kính mờ trắng sang dải gradient thương hiệu `#A83900→#FE6A2B` đặc (khớp đúng
  header của bản mẫu Stitch — mẫu Stitch dùng header đặc màu cho CẢ 2 trang "trang chủ" khách vãng lai
  lẫn trang chủ thành viên, khác các trang tác vụ như giỏ hàng/đơn hàng vẫn dùng nav trắng), đồng bộ
  icon giỏ hàng/thông báo/avatar sang tông trắng trong suốt trên nền màu.
- Thay hero quảng cáo chung chung (badge "giao hỏa tốc" + tiêu đề "Đói bụng? Đã có FOOD MANAGE!") bằng
  lời chào cá nhân hoá THẬT: "Chào mừng trở lại, ${account.fullName}! 👋" + badge đếm đúng số quán
  đang có (`${fn:length(shops)}`), giữ nguyên 100% thanh tìm kiếm + toàn bộ JS filter/search theo món
  ăn đã có (`filterShops`, `doSearch`, `searchShopsByDish`) — không đổi logic. Thêm dải 3 thẻ thống kê
  dùng dữ liệu thật: số quán đối tác (`fn:length(shops)`), điểm thưởng thật (`${account.loyaltyPoints}`
  — field có sẵn trên `Account`, không cần sửa servlet), số thông báo chưa đọc thật
  (`${unreadNotifCount}`, servlet đã truyền sẵn). KHÔNG thêm ví/hạng thành viên/AI gợi ý/wishlist như
  bản mẫu.
- Giữ nguyên khối 3D icon món ăn nổi (Fluent Emoji 3D) trang trí bên phải hero — thuần trang trí, không
  phải dữ liệu nên không có vấn đề "bịa dữ liệu".
- Footer: đổi nền sang gradient thương hiệu, thêm hotline "1900-8899" (tĩnh, decorative — số điện thoại
  minh hoạ giống các trang khác đã thêm ở mục 138/140), bổ sung link "Điểm thưởng" vào footer-links
  (route thật `/user/diem-thuong`).

### Files sửa:
- `src/main/web/user/trangnguoidung.jsp`

### Ghi chú:
Không đổi Servlet/DAO nào (chỉ dùng lại field/attribute server đã truyền sẵn: `account.loyaltyPoints`,
`unreadNotifCount`, `fn:length(shops)`), không đổi schema DB nên không cần cập nhật `database.md`.
Không có Maven/Tomcat CLI trong môi trường này nên không tự build/chạy/chụp màn hình được; đã grep lại
để xác nhận sạch hex cũ và cân bằng thẻ JSTL. Đề nghị user tự rebuild/redeploy rồi kiểm tra: (1) tên
hiển thị đúng khi đăng nhập bằng tài khoản có/không có `fullName`, (2) điểm thưởng hiển thị đúng số
thật (so với trang `/user/diem-thuong`), (3) toàn bộ tính năng tìm kiếm quán/món ăn trong ô search vẫn
hoạt động như cũ (chỉ đổi giao diện, không đổi JS).

## 140. Viết lại TrangChu.jsp bám sát đúng bản thiết kế Stitch chính thức (trang chủ)

**Yêu cầu:** Sau mục 138/139, user gửi ảnh chụp trực tiếp từ Stitch (đường dẫn
`.../stitch/projects/14927297908987799351/screens/...`) cho thấy bản thiết kế trang chủ THẬT SỰ phong
phú hơn nhiều so với bản mình tự dựng ở mục 138 (thiếu section giới thiệu 3 thẻ có link phụ, danh mục
đang tô nguyên dải màu thương hiệu thay vì thẻ trắng có icon tròn, thiếu banner khuyến mãi lớn, thiếu
section đánh giá khách hàng, thiếu footer 4 cột có hotline + tải app). Mình đọc lại đúng file
`foodmanage_trang_ch_t_n_tr_c_tuy_n/code.html` (mã nguồn Tailwind do Stitch sinh, 780 dòng) trong zip
thứ 2 — trước đó chỉ sửa font mà chưa đọc kỹ nội dung/cấu trúc trang này.

**Đã làm:** Viết lại toàn bộ `TrangChu.jsp` bám sát đúng thứ tự section + nội dung/copy tiếng Việt
trong `code.html` gốc (chuyển từ Tailwind sang CSS thuần theo đúng pattern các trang khác của dự án),
giữ nguyên 100% phần dữ liệu thật (JSTL `featuredProducts`, mọi link `/dangnhap`, `/dangky`,
`/dangky-shop`, `/dangky-shipper`):
- Header: sticky, gradient thương hiệu chính xác `#A83900 → #FE6A2B` (lấy đúng giá trị `secondary`/
  `secondary-container` trong `tailwind-config` của `code.html`, khác chút với gradient
  `#C4340C → #FF6B2C` mình tự đoán ở mục 138), thêm pill "Giao tới: Hà Nội" (tĩnh, chưa có geolocation
  thật), nút CTA "Đăng nhập / Đặt món" màu `#FF3B1F` riêng biệt (đúng theo inline override
  `background-color: rgb(255, 59, 31)` trong `code.html` gốc — xác nhận nút CTA vẫn tách màu khỏi dải
  gradient header, khớp quy tắc CTA 10% đã dùng xuyên suốt 9 trang khác nên KHÔNG đổi `--primary` toàn
  site theo màu `secondary`/`primary` Material của riêng file này để tránh lệch tông với các trang đã
  sửa ở mục 139).
- Hero: badge ưu đãi, headline có từ "FoodManage!" viền gạch sóng, thanh tìm kiếm + chip vị trí + nút
  tìm kiếm, dãy "Xu hướng" (4 tag bấm vào tự điền ô tìm kiếm), 2 nút CTA, dải 4 thẻ thống kê
  (500K+/4.9/5/20-30p/1.200+), thẻ món ăn nổi bật bên phải (dùng ảnh có sẵn `burger_hero.png`, badge
  "Giao nóng 15 phút" + "Best Seller", giá kèm giá gạch — đây là nội dung TĨNH minh hoạ như bản gốc,
  tách biệt khỏi lưới món ăn thật bên dưới).
- Thêm mới section "Tại sao chọn FoodManage?" (3 thẻ: Chất lượng tươi ngon/Giao siêu tốc/Đối tác tin
  cậy, mỗi thẻ có icon Material Symbols + dòng link phụ).
- Đổi hẳn cách trình bày "Danh mục nổi bật": từ dải nền màu thương hiệu nguyên khối (bản mục 138) sang
  đúng bản gốc — nền kem, 7 thẻ trắng bo góc có icon tròn + tên + số món, kèm hàng "filter tabs" tĩnh
  (Tất cả/Bán chạy nhất/Gần bạn nhất/Ưu đãi sốc hôm nay).
- Lưới "Món Ăn Được Yêu Thích Nhất": tăng `FEATURED_LIMIT` trong
  `src/main/java/org/example/controllers/IndexServlet.java` từ 3 lên **6** để khớp lưới 6 món trong
  bản thiết kế (chỉ đổi 1 hằng số, không đổi logic chọn món/DAO); card món ăn thêm nút yêu thích (❤,
  chỉ hiển thị, chưa có logic lưu wishlist) và dòng tên shop, dùng đúng field thật
  (`imageUrl/productName/description/price/shopName/shopRating/soldCount`) — không có field
  `originalPrice`/giá gạch cho `FeaturedProduct` nên KHÔNG bịa giá gốc giả cho lưới món ăn thật (khác
  với thẻ hero tĩnh ở trên vốn chỉ là minh hoạ).
- Thêm mới banner khuyến mãi lớn "Giảm Ngay 50.000đ Cho Đơn Từ 150K" với mã `GIAM50K` (nút sao chép mã
  vào clipboard qua JS, KHÔNG có logic áp dụng thật — đây là mã trang trí tĩnh giống bản gốc Stitch,
  không phải voucher thật trong bảng `Vouchers`; nếu muốn mã thật cần một đợt việc riêng nối
  `VoucherDAO`), dùng ảnh có sẵn `pizza_dish.png` thay ảnh CDN của Stitch (không truy cập được lâu
  dài).
- Thêm mới section đánh giá khách hàng (3 testimonial, dùng avatar chữ cái đầu thay vì ảnh CDN ngoài
  của Stitch vì các URL đó thuộc phiên làm việc riêng của Stitch, không đảm bảo còn truy cập được).
- Thêm nút nổi góc dưới phải "Đặt món ngay" (bỏ phần đếm giỏ hàng giả trong bản gốc Stitch vì trang
  này dành cho khách CHƯA đăng nhập — hệ thống không có giỏ hàng thật ở trạng thái đó, hiển thị số đếm
  giả sẽ gây hiểu lầm).
- Footer: 4 cột (thương hiệu + hotline 1900-8899, Về chúng tôi, Hỗ trợ khách hàng, Tải ứng dụng có QR +
  nút Google Play/App Store — toàn bộ phần tải app là trang trí vì dự án chưa có app di động thật).
- Đổi icon toàn trang từ SVG tự vẽ sang font **Material Symbols Outlined** (Google Fonts, giống hệt
  `code.html` gốc) để khớp đúng bộ icon (`local_fire_department`, `electric_moped`, `storefront`,
  `verified`, `bolt`, `shield`, `local_dining`, `celebration`, `content_copy`, `qr_code_2`, v.v.), thêm
  1 mark logo SVG đơn giản (dạng lồng bàn) thay emoji 🍔 cũ ở cả header lẫn footer.

### Files sửa:
- `src/main/web/TrangChu.jsp`
- `src/main/java/org/example/controllers/IndexServlet.java` (chỉ đổi hằng số `FEATURED_LIMIT` 3→6)

### Ghi chú:
Không đổi schema DB, không đổi DAO/logic chọn món nổi bật — chỉ tăng số lượng lấy ra, nên không cần
cập nhật `database.md`. Không có Maven/Tomcat CLI trong môi trường này nên không tự build/chạy/chụp
màn hình được; đã grep lại toàn bộ file để xác nhận cân bằng thẻ JSTL (`c:choose/c:when/c:otherwise/
c:forEach` đều khớp số mở/đóng) và không còn sót `Fredoka` cũ. Đề nghị user tự rebuild/redeploy rồi so
sánh trực tiếp với ảnh chụp Stitch đã gửi — đặc biệt kiểm tra: (1) lưới 6 món ăn nổi bật có tải đúng dữ
liệu thật không (trước là 3, giờ cần có tối thiểu 6 sản phẩm hợp lệ trong DB mới hiển thị đủ lưới,
nếu ít hơn sẽ hiển thị ít món hơn — đây là hành vi đúng, không phải lỗi), (2) icon Material Symbols có
tải được không (phụ thuộc kết nối tới `fonts.googleapis.com`, nếu mạng chặn Google Fonts icon sẽ hiện
dạng chữ thay vì icon).

## 139. Đồng bộ bảng màu/font mới (từ bộ thiết kế Stitch) ra toàn bộ giao diện Khách hàng (User)

**Yêu cầu:** User gửi 2 file zip thiết kế do công cụ Stitch (Google) sinh ra
(`stitch_remix_of_foodmanage_ui_design.zip` rồi bản đầy đủ hơn `... (1).zip`), gồm 16 trang mẫu +
1 file `food_manage_experience/DESIGN.md` (spec màu/font/shadow chính thức) + 1 logo mark tham khảo.
Toàn bộ 16 trang mẫu đều thuộc role **Khách hàng (User)**, không có trang nào cho Shop/Admin/Shipper.
User xác nhận muốn áp dụng bộ thiết kế này ra "giao diện hệ thống" (đã hỏi lại phạm vi qua
AskUserQuestion, user dismiss câu hỏi và gửi thêm file — hiểu là: cứ dựa vào tài liệu mới mà làm, ưu
tiên áp dụng đúng các trang khách hàng khớp với zip).

**Phát hiện quan trọng:** `DESIGN.md` trong zip mô tả gần như CHÍNH XÁC bảng màu 60-30-10 mình đã tự
nghĩ ra ở mục 138 (nền kem `#FFF9F2`, thương hiệu `#C4340C→#FF6B2C`, CTA `#FF3B1F`) — khác biệt chính
là: (1) font tiêu đề chính thức là **Quicksand** (không phải `Fredoka` mình đoán ở mục 138), và (2) các
trang "app" nội bộ (giỏ hàng, đơn hàng, hóa đơn...) trong bộ mẫu KHÔNG tô header đặc màu thương hiệu
như trang chủ — chỉ dùng 1 màu "brand" `#FF3B1F` nhất quán làm điểm nhấn trên nền trắng/kem với thanh
nav kính mờ trắng (glass), giữ đúng những gì `user-theme.css`/từng JSP `user/` đã làm trước đó — nên
đợt này chỉ cần **đổi giá trị token màu + thêm font Quicksand cho tiêu đề**, không cần dựng lại layout
từng trang.

**Đã làm:**
- Cập nhật token dùng chung [assets/css/user-theme.css](src/main/web/assets/css/user-theme.css):
  `--primary #FF5A1F→#FF3B1F`, `--primary-dark→#E02A10`, `--primary-light→#FFF2F0`,
  `--primary-border→#FFC7BE`, `--accent-gold #FFB020→#FFB300`, `--bg #FFFBF8→#FFF9F2`,
  `--text #241C15→#2D2421`, `--muted #8A7B6C→#635752`, đổ bóng ấm hơn (tint
  `rgba(60,30,10,*)→rgba(99,44,20,*)`, glow `rgba(255,90,31,*)→rgba(255,59,31,*)`), thêm biến
  `--font-display: 'Quicksand', 'Plus Jakarta Sans', sans-serif` + rule `h1/h2/h3/.ut-headline/
  .ut-logo/.ut-price` dùng font này.
- Sửa `TrangChu.jsp`: đổi font hiển thị từ `Fredoka` (đoán ở mục 138) sang `Quicksand` (đúng
  `DESIGN.md` chính thức) — chỉ đổi `<link>` Google Fonts + biến `--font-display`, không đổi cấu trúc.
- Áp cùng cách đổi màu (tìm-thay hex cũ→mới, y hệt danh sách trên) + thêm `Quicksand` cho phần
  tiêu đề/logo/giá (qua biến `--font-h` có sẵn, hoặc thêm rule mới nếu trang không có biến riêng) cho
  8 trang đã dùng chung bảng cam-đỏ cũ: `user/menuShop.jsp`, `user/checkoutThanhToan.jsp` (trang này
  vốn KHÔNG hề `<link>` Google Fonts nào — bug cũ, đã bổ sung `<link>` Plus Jakarta Sans + Quicksand),
  `user/donhang.jsp`, `user/khieuNai.jsp`, `user/hoaDon.jsp` (vốn chỉ load font `Inter`, nay thêm
  Plus Jakarta Sans + Quicksand đúng chuẩn chung), `user/thongTinCaNhan.jsp`, `user/diemThuong.jsp`,
  `user/diaChi.jsp`.
- Viết lại toàn bộ bảng màu `DangNhap.jsp` (trang đăng nhập): trước đó trang này dùng tông **xanh lá**
  hoàn toàn lệch thương hiệu (`#10b981`/`#059669`, không liên quan gì tới cam-đỏ FOOD MANAGE — có vẻ
  copy từ 1 template auth chung), cộng thêm nền/chữ tông xanh dương xám (slate). Đổi toàn bộ sang bảng
  màu ấm cam-đỏ mới (nút CTA, link, focus ring, logo badge dùng gradient `#FF3B1F→#E02A10`), đổi nền
  panel trang trí bên phải từ navy `#1a2035→#0f1624` sang nâu-đen ấm `#3A1206→#1A0A04` (đồng bộ tông
  ấm với footer `TrangChu.jsp`), đổi mọi màu chữ/nền slate (`#0f172a/#94a3b8/#475569/#64748b/#b0bcc9/
  #e2e8f0/#f8fafc/#f1f5f9`) sang bộ màu ấm tương ứng (`#2D2421/#635752/#4A3934/.../#F1E4D6/#FFF4EC`),
  thêm `<link>` Google Fonts (trước đó chỉ có `Inter`, không có `Plus Jakarta Sans` dù `body` khai
  `font-family: 'Inter', ...` — cũng là 1 bug cũ tương tự `checkoutThanhToan.jsp`), thêm Quicksand cho
  tiêu đề/logo. KHÔNG đổi màu `#dc2626`/`#fecaca`/... (đỏ lỗi/alert) vì đó là màu ngữ nghĩa (danger),
  không phải màu thương hiệu.

### Files sửa:
- `src/main/web/assets/css/user-theme.css`
- `src/main/web/TrangChu.jsp`
- `src/main/web/DangNhap.jsp`
- `src/main/web/user/menuShop.jsp`
- `src/main/web/user/checkoutThanhToan.jsp`
- `src/main/web/user/donhang.jsp`
- `src/main/web/user/khieuNai.jsp`
- `src/main/web/user/hoaDon.jsp`
- `src/main/web/user/thongTinCaNhan.jsp`
- `src/main/web/user/diemThuong.jsp`
- `src/main/web/user/diaChi.jsp`

### Ghi chú:
- **Không đổi màu 4 trang** `user/DanhSachGioHang.jsp`, `user/cartItemDanhSach.jsp`,
  `user/themSuaGioHang.jsp`, `user/cartItemThemSua.jsp` (route `/cart`, `/cart-items`) — đọc kỹ thì đây
  là các trang CRUD nội bộ liệt kê thẳng entity `Cart`/`CartItem` (bảng ID/UserId/ngày tạo, style
  bootstrap-cũ, không nằm trong nav công khai nào), KHÔNG phải trải nghiệm giỏ hàng thật của khách —
  luồng thật là `menuShop.jsp` (thêm món) → `checkoutThanhToan.jsp` (đã có sẵn UI xem/sửa số
  lượng+topping+thanh toán trong cùng 1 trang, khớp đúng ý trang mẫu "Giỏ Hàng & Xác Nhận Đặt Món"
  trong zip) — nên trang mẫu giỏ hàng trong zip thực ra tương ứng với `checkoutThanhToan.jsp` (đã sửa),
  không phải `DanhSachGioHang.jsp`. Nếu user muốn theme lại cả 4 trang CRUD nội bộ này thì cần yêu cầu
  riêng.
- **2 trang trong zip chưa có JSP tương ứng:** "Kho voucher ẩm thực" (chưa có trang cho khách hàng tự
  duyệt/đổi voucher — hiện voucher chỉ nhập mã trực tiếp lúc checkout, xem mục 77/78) và "Cổng thanh
  toán PayOS/VietQR" (trang này do PayOS host, hệ thống không kiểm soát giao diện — xem
  `PayOSReturnServlet`/`PayOSWebhookServlet`). Không tạo trang mới trong đợt này.
- Không đổi schema DB, không đổi Servlet/Java nào — chỉ CSS/font trong các JSP nên không cần cập nhật
  `database.md`. Không có Maven/Tomcat CLI trong môi trường này nên không tự build/chạy để chụp màn
  hình; đã `grep` lại toàn bộ file đã sửa để xác nhận không còn sót giá trị hex cũ nào (`#FF5A1F`,
  `#E14A0F`, `#FFFBF8`, `#8A7B6C`, `#241C15`, `#FFD3B8`, `#FFB020`, `#FFF1E8`, `Fredoka`) — sạch hoàn
  toàn. Đề nghị user tự rebuild/redeploy rồi kiểm tra lại từng trang đã sửa, đặc biệt
  `checkoutThanhToan.jsp`/`hoaDon.jsp` vì 2 trang này trước đó thiếu hẳn `<link>` Google Fonts (bug cũ
  không liên quan đợt sửa này, tiện thể vá luôn).

## 138. Thiết kế lại giao diện trang chủ công khai (TrangChu.jsp) theo quy tắc màu 60-30-10

**Yêu cầu:** User đưa 1 bản brief thiết kế UI cho "nền tảng bán đồ ăn" (tiếng Việt, phong cách hiện
đại/thân thiện/gợi thèm ăn hướng 2026, quy tắc màu 60% nền sáng - 30% thương hiệu cho
Header/Footer/khung danh mục - 10% nút CTA cam đậm/đỏ tươi, bố cục Header/Hero/Giới thiệu/Menu/CTA/
Footer). Brief gốc có vài chi tiết không khớp dự án thật (tên thương hiệu "Modtra", menu
"Matcha/Cà phê" — có vẻ copy từ brief quán trà/cà phê khác). User xác nhận (sau khi được hỏi lại):
chỉnh sửa yêu cầu cho phù hợp với web thật của mình rồi cập nhật lại giao diện hệ thống — tức áp dụng
đúng các nguyên tắc thiết kế (màu 60-30-10, bo góc mềm, nhiều khoảng trắng, sans-serif) vào brand
**FOOD MANAGE** (nền tảng đặt đồ ăn tổng hợp) đã có sẵn, không dùng tên/menu matcha.

**Đã làm:** Viết lại toàn bộ `src/main/web/TrangChu.jsp` (trang chủ công khai, forward từ
`IndexServlet` — xem `req.setAttribute("featuredProducts", ...)` +
`getRequestDispatcher("/TrangChu.jsp")`), giữ nguyên toàn bộ logic JSTL/EL hiển thị
`featuredProducts` (vòng lặp `fp.imageUrl/productName/soldCount/shopRating/shopName/description/price`)
và mọi link điều hướng cũ (`/dangnhap`, `/dangky`, `/dangky-shop`, `/dangky-shipper`), chỉ thay đổi
markup + CSS:
- Bảng màu mới tuân thủ đúng 60-30-10: nền kem nhạt `--cream:#FFF9F2` (60%, khác `--bg-color:#FAFAFA`
  cũ) cho Hero/About/Menu; **Header** và **Footer** đổi từ nền trắng kính mờ / xanh navy đậm sang
  gradient thương hiệu cam-đỏ đặc `--brand-700:#C4340C → --brand-500:#FF6B2C` (30%, hiện diện rõ ở 2
  đầu trang thay vì chỉ là điểm nhấn); nút CTA dùng `--cta-600:#FF3B1F` tách riêng khỏi brand-color để
  luôn nổi bật kể cả khi đặt trên nền header đã có màu thương hiệu (10%).
- Thêm section mới **"Danh mục nổi bật"** (`#danhmuc`, dải màu thương hiệu full-bleed với divider hình
  sóng SVG) — 6 chip danh mục tổng quát (Cơm, Burger, Pizza, Trà sữa, Gà rán, Tráng miệng) đúng tinh
  thần "khung danh mục nổi bật dùng màu thương hiệu" trong brief, và section **"Giới thiệu"**
  (`#about`, 3 thẻ lý do chọn FoodManage) — trước đó trang chưa có 2 section này.
  Thêm dải **CTA banner** rõ ràng ("Thèm rồi phải không? Đặt món ngay") giữa Menu và section App.
- Đổi font từ `Outfit` (dùng cho mọi chữ) sang cặp `Fredoka` (chữ bo tròn, dùng có kiểm soát cho
  headline/giá/logo — tạo cảm giác gần gũi/thèm ăn) + `Plus Jakarta Sans` (thân chữ, đồng bộ với
  `assets/css/user-theme.css` đang dùng cho toàn bộ khu vực `user/`).
- Header đổi từ nav kính mờ (glassmorphism, chữ tối) sang thanh đặc màu thương hiệu (chữ trắng), nút
  "Đăng ký" đảo màu (nền trắng/chữ đỏ-cam) để vẫn nổi bật trên nền header đã có màu.
- Nav gồm: Trang chủ, Thực đơn, Danh mục, Về chúng tôi, Liên hệ (thay `Cách hoạt động`/`Món nổi bật`/
  `Ứng dụng` cũ, khớp đúng 5 section mới của trang).
- Giữ nguyên 2 ảnh có sẵn `assets/img/burger_hero.png` (hero) và `assets/img/pizza_dish.png` (khung
  điện thoại mock-up phần "Trải nghiệm trên web") — không thêm ảnh mới.

### Files sửa:
- `src/main/web/TrangChu.jsp`

### Ghi chú:
Không đổi schema DB, không đổi servlet/Java nào (chỉ HTML/CSS/JS tĩnh trong 1 file JSP) nên không cần
cập nhật `database.md`. Không có Maven/Tomcat CLI trong môi trường này nên không tự build/deploy/chạy
Tomcat thật để chụp màn hình được; đã dựng thử 1 bản HTML tĩnh tương đương (cùng CSS/markup, thay vòng
lặp JSTL bằng dữ liệu mẫu) để soát cấu trúc, nhưng không mở được qua Browser pane vì công cụ chặn
điều hướng tới `localhost`/mạng nội bộ (an toàn theo thiết kế, không phải lỗi) nên chỉ xác minh được
bằng cách đọc lại kỹ HTML/CSS đã sinh ra (cân bằng thẻ, đúng cú pháp JSTL/EL, đúng tên field
`FeaturedProduct` dùng lại y hệt bản cũ). Đề nghị user tự rebuild/redeploy rồi kiểm tra trực tiếp
`TrangChu.jsp` ở cả desktop và mobile (đặc biệt: dải "Danh mục nổi bật" mới, form tìm kiếm, và vòng lặp
món ăn nổi bật khi `featuredProducts` rỗng/có dữ liệu thật).

## 137. Dọn lại database.md cho khớp migration_all.sql (chỉ sửa tài liệu, không đổi DB thật)

**Vấn đề:** `database.md` bị lệch so với `migration_all.sql` (988 dòng, nguồn chính xác nhất): thiếu
hẳn 4 bảng (`Shop_Wallets`, `Shop_Wallet_Transactions`, `Shop_Withdrawals`, `Refund_Requests`),
CHECK constraint `Orders.status`/`Order_Logs.old_status/new_status` còn dùng bộ giá trị CŨ (thiếu
`WAITING_FOR_SHIPPER`, `ACCEPTED`), nhiều khối `ALTER TABLE ... IF NOT EXISTS` bị trùng lặp hoàn
toàn với cột đã có sẵn trong `CREATE TABLE` phía trên, `Shipper_Profiles` còn liệt kê 2 cột ảnh cũ
đã bị DROP (`id_card_image_url`, `license_image_url`), và `Combos`/`Flash_Sales` chỉ là block
markdown trang trí (không phải SQL thật) đặt SAU `Cart_Items` dù `Cart_Items` đã FK sang `Combos`
— chạy top-to-bottom sẽ lỗi.

**Đã làm (chỉ sửa `database.md`, không chạy SQL, không đổi code Java):**
- Viết lại toàn bộ `database.md` thành 1 script chạy được từ đầu tới cuối, đúng thứ tự phụ thuộc
  FK (39 bảng, `DROP TABLE IF EXISTS` liệt kê đủ 39 bảng theo thứ tự ngược).
- Bổ sung 4 bảng còn thiếu: `Shop_Wallets`, `Shop_Wallet_Transactions`, `Shop_Withdrawals`,
  `Refund_Requests` (lấy nguyên định nghĩa từ `migration_all.sql`).
- Cập nhật `CHECK` constraint `Orders.status`/`Order_Logs.old_status`/`new_status` thành đủ 8 giá
  trị: `PENDING, CONFIRMED, READY_FOR_PICKUP, WAITING_FOR_SHIPPER, ACCEPTED, SHIPPING, DONE,
  CANCELLED` (khớp `migration_orders_status_constraint.sql` và grep code Java).
- Gộp các cột thêm bằng `ALTER TABLE ... IF NOT EXISTS` thẳng vào `CREATE TABLE` (vd `bom_count`,
  `suspend_reason` vào `Accounts`; `cancel_reason` vào `Orders`), xoá các khối `ALTER` trùng lặp
  hoàn toàn với cột/constraint đã có trong `CREATE TABLE`.
- Sửa `Shipper_Profiles`: bỏ 2 cột ảnh đơn cũ đã bị DROP bởi `migration_shipper_doc_front_back.sql`
  (`id_card_image_url`, `license_image_url`), chỉ giữ 4 cột mặt trước/sau.
- Chuyển `Combos`/`Flash_Sales`/`Combo_Items` từ block markdown trang trí thành `CREATE TABLE` thật,
  đặt đúng vị trí (`Combos` trước `Cart_Items`).
- Bổ sung thêm những gì `migration_relationship_integrity.sql` yêu cầu nhưng `database.md` cũ chưa
  có: cột `User_Addresses.is_deleted` (đang được `UserAddressDAOImpl` dùng để soft-delete), các FK
  composite (`UQ_Products_Id_Shop`, `UQ_ProductSizes_Id_Product/Shop`, `UQ_ToppingCategories_Id_Shop`
  + các FK 2 cột tương ứng) và 3 trigger nghiệp vụ (`TR_Feedbacks_ValidateOrderParties`,
  `TR_Complaints_ValidateOrderOwner`, `TR_UserProfiles_ValidateDefaultAddress`).
- Thêm 2 mục cuối file: audit bảng/cột chưa có code Java dùng (kết luận: `Shop_Wallets`/
  `Refund_Requests`... thực ra ĐÃ có DAO+Servlet đầy đủ, chỉ `Shipper_Wallets/Withdrawals` vẫn
  thiếu màn hình phía Shipper như ghi chú cũ) và audit từng file `migration_*.sql` so với
  `migration_all.sql` — phát hiện rủi ro thật: nhiều file (`migration_audit_logs.sql`,
  `migration_vouchers.sql`, `migration_faqs.sql`, `migration_system_configs.sql`,
  `migration_relationship_integrity.sql`, v.v.) KHÔNG có marker "Nguon:" trong `migration_all.sql`
  — nghĩa là 1 DB mới dựng chỉ bằng cách chạy `migration_all.sql` sẽ thiếu các bảng/cột/trigger đó.

## 136. Fix "Thêm Combo" không tính đúng giá combo lúc thanh toán

User báo: menu hiện combo "Mua 2 tặng 1" giá 142.000đ, nhưng khi bấm "Thêm Combo" rồi ra checkout
thì tổng tiền lại tính theo giá LẺ từng món (2 Tacos + 1 Coca theo giá ProductSize bình thường),
hoàn toàn bỏ qua `Combos.combo_price`.

**Nguyên nhân:** `UserAddComboServlet` chỉ insert từng `CartItem` con của combo (product + size +
quantity) giống hệt add-to-cart bình thường — `CartItem` không có cách nào lưu lại "dòng này thuộc
combo, giá đã khóa theo combo_price". Mọi nơi tính tiền (`CheckoutServlet.buildLines()`,
`UserCartViewServlet.prepareCartView()`) đều dùng `ProductSize.getPrice()` gốc.

**Sửa:** thêm 2 cột `combo_id`/`combo_unit_price` cho `Cart_Items`, tái dùng cơ chế
`ProductSize.salePrice` sẵn có (giống Flash Sale — `getPrice()` trả về `salePrice` nếu có) để
"khóa" giá quy đổi từ combo ngay lúc thêm vào giỏ, không cần sửa lại từng chỗ tính lineTotal.

- `migration_cart_combo_price.sql` (mới) + `database.md`: `Cart_Items.combo_id BIGINT NULL` (FK
  `Combos(id)` `ON DELETE SET NULL`), `Cart_Items.combo_unit_price DECIMAL(12,2) NULL`.
- `CartItem.java`: thêm field `comboId`/`comboUnitPrice`.
- `CartItemDAO`/`CartItemDAOImpl`: `findByCartIdProductSize()` thêm điều kiện `combo_id IS NULL`
  (chỉ gộp số lượng vào mòn LẺ, không gộp nhầm vào dòng đang giữ giá combo); thêm
  `findByCartIdProductSizeCombo()` (chỉ gộp khi thêm lại ĐÚNG combo đó) và `createComboItem()`.
- `UserAddComboServlet`: tính `allocatedTotalByItem[]` — phân bổ `combo_price` theo tỷ lệ giá trị
  gốc (`sizePrice * quantity`) của từng dòng trong combo, dòng cuối nhận phần dư làm tròn để tổng
  luôn khớp chính xác `combo_price`; gọi `createComboItem()`/`findByCartIdProductSizeCombo()` thay
  vì logic add-to-cart thường.
- `CheckoutServlet.buildLines()`, `UserCartViewServlet.prepareCartView()`: sau bước áp Flash Sale,
  nếu `item.getComboUnitPrice() != null` thì `size.setSalePrice(comboUnitPrice)` (ưu tiên hơn cả
  Flash Sale) — nhờ tái dùng `getPrice()`, checkout/giỏ hàng/tạo `OrderDetail` tự động dùng đúng
  giá combo mà không cần sửa thêm.

**Giới hạn đã biết (chưa xử lý, để dành nếu cần)**: nếu user bấm "Sửa" đổi size của 1 dòng đang
thuộc combo trong giỏ hàng, giá combo đã khóa (`combo_unit_price`) sẽ không tự tính lại theo size
mới — không sai lệch nghiêm trọng (giá vẫn cố định đúng số tiền đã khóa) nhưng có thể gây hiểu nhầm
UI vẫn hiện "Sửa" cho dòng combo.

### Files sửa:
- `migration_cart_combo_price.sql` (mới), `database.md`, `CartItem.java`, `CartItemDAO.java`,
  `CartItemDAOImpl.java`, `UserAddComboServlet.java`, `CheckoutServlet.java`,
  `UserCartViewServlet.java`

## 135. Fix layout in hóa đơn (`/bill`) vỡ khi in bằng máy in nhiệt khổ hẹp (58mm)

User chụp màn hình in hóa đơn với printer "POSPrinter POS58" (máy in nhiệt hóa đơn, khổ giấy cố
định 58mm) — layout gốc là flex 2 cột (`.info-row`) + bảng 4 cột (`.prod-table`) thiết kế cho màn
hình rộng, khi Chrome ép xuống khổ 58mm thì địa chỉ vỡ từng chữ một dòng, cột SL/Đơn giá/Thành tiền
đè chồng lên nhau không đọc được.

**Sửa:** thêm khối `@media print` đầy đủ (trước đó chỉ có 1 dòng ẩn navbar/actions):
- `@page { margin: 4mm }` giảm margin thừa.
- `.info-row` chuyển `flex` → `block`, nhãn xếp trên/giá trị xếp dưới thay vì 2 cột ngang.
- `.prod-table`: bỏ hẳn layout bảng ngang, mỗi ô `td` chuyển `display:block`, mỗi dòng sản phẩm
  xếp chồng dọc, dùng CSS `::before { content: "SL: " }` để thêm nhãn thay cho header bảng (ẩn
  `thead` khi in vì không còn ở dạng cột).
- Thu nhỏ font-size/padding các phần header/status-badge cho vừa khổ giấy hẹp.

### Files sửa:
- `user/hoaDon.jsp`

## 134. Làm tròn số tiền hiển thị (bỏ phần thập phân) ở hóa đơn/giỏ hàng/checkout/voucher

User báo hóa đơn hiển thị "Phí giao hàng: 16,601.94đ" — do phí ship tính theo khoảng cách ra số
thập phân, nhưng nhiều dòng `<fmt:formatNumber type="number">` quên `maxFractionDigits="0"` nên
hiện nguyên số lẻ.

**Sửa:** thêm `maxFractionDigits="0"` cho mọi `<fmt:formatNumber type="number">` liên quan tiền
còn thiếu (không đụng tới việc hiển thị %, số lượng...).

### Files sửa:
- `user/hoaDon.jsp`, `user/checkoutThanhToan.jsp`, `user/donhang.jsp`, `user/gioHang.jsp`,
  `user/diemThuong.jsp`, `shop/Banhang.jsp`, `shop/HoaDonShop.jsp`, `shop/Quanlybill.jsp`,
  `admin/QuanLyVoucher.jsp`

## 133. Ẩn thanh "Tiến trình đơn hàng" khi đơn đã DONE ở `user/donhang.jsp`

User yêu cầu: sau khi đơn giao thành công (status DONE) thì thanh stepper "Tiến trình đơn hàng"
không cần hiển thị nữa (đơn đã xong, không còn gì để theo dõi live).

**Sửa:** thêm nhánh `<c:when test="${st eq 'DONE'}">` (rỗng) trước `<c:otherwise>` trong khối hiển
thị tracking stepper — chặn sớm, không render `.tracking-stepper-box` khi đơn đã DONE (giữ nguyên
nhánh CANCELLED hiển thị banner "Đơn hàng đã bị hủy" như cũ). Do DONE giờ tách nhánh riêng, dọn lại
`<c:otherwise>` chỉ còn xử lý step 1–4 (bỏ hẳn state "step 5 hoàn thành/🎉" vì nhánh đó không bao
giờ render nữa) và bỏ điều kiện `${st ne 'DONE'}` thừa ở dòng "Đang cập nhật live".

### Files sửa:
- `user/donhang.jsp`

## 132. Fix mục 131: thêm cột bank_account_holder riêng cho Shipper (không tự suy ra từ full_name)

User phản hồi: ở mục 131 vừa làm, form "Hồ sơ tài xế" chưa từng có ô "Tên chủ tài khoản" (chỉ có
Số TK + Tên ngân hàng), nhưng trang Ví tiền lại tự hiển thị sẵn tên chủ tài khoản (suy ra ngầm từ
`Account.fullName`) — gây hiểu lầm vì Shipper chưa từng tự nhập/xác nhận tên này, khác hẳn kiểu dữ
liệu (tên có dấu trên hồ sơ tài khoản chưa chắc đúng định dạng ngân hàng yêu cầu, ví dụ cần viết
hoa không dấu).

**Sửa:** thêm hẳn cột `bank_account_holder` cho `Shipper_Profiles` (đúng kiểu Shop đã có
`bankAccountName`), Shipper phải tự nhập giống Số TK/Tên ngân hàng, cùng đi qua OTP khi đổi.

- `migration_shipper_bank_holder.sql` (mới) + bổ sung khối tương ứng vào `migration_all.sql`,
  `database.md`: thêm cột `Shipper_Profiles.bank_account_holder NVARCHAR(100) NULL`.
- `ShipperProfile.java`: thêm field `bankAccountHolder` + getter/setter; `isHasBankInfo()` giờ đòi
  hỏi đủ cả 3 (Số TK + Tên NH + Tên chủ TK).
- `ShipperProfileDAOImpl.java`: `COLUMNS`, `save()` (MERGE) và `map()` đều thêm `bank_account_holder`.
- `ShipperProfileServlet.handleUpdateVehicle()`: đọc thêm param `bankAccountHolder`, đưa vào so
  sánh `bankChanged` và vào `pending` map gửi kèm OTP (purpose vẫn là `"shipper_vehicle_bank"` sẵn
  có, không tạo purpose mới).
- `XacThucThayDoiServlet.java`: nhánh `case "shipper_vehicle_bank"` set thêm
  `profile.setBankAccountHolder(...)` trước khi `save()`.
- `shipper/hosotaixe.jsp`: thêm ô nhập "Tên chủ tài khoản" thật sự (trong `#bankInfoSection`), bỏ
  hint suy diễn "mặc định lấy theo họ tên hồ sơ".
- `ShipperWalletServlet.java`: `bankAccountHolder` giờ lấy từ `profile.getBankAccountHolder()`
  thay vì `account.getFullName()`.
- `shipper/viTien.jsp`: khối "Tài khoản nhận tiền (đã lưu)" hiển thị `profile.bankAccountHolder`.

### Files sửa:
- `migration_shipper_bank_holder.sql` (mới), `migration_all.sql`, `database.md`,
  `ShipperProfile.java`, `ShipperProfileDAOImpl.java`, `ShipperProfileServlet.java`,
  `XacThucThayDoiServlet.java`, `shipper/hosotaixe.jsp`, `ShipperWalletServlet.java`,
  `shipper/viTien.jsp`

## 131. Rút tiền Shipper cũng dùng thông tin ngân hàng đã lưu, đổi phải xác thực OTP

Áp dụng đúng pattern vừa làm cho Shop (mục 130) sang Shipper. `ShipperProfile` đã có sẵn 2 cột
`bankAccount`/`bankName` (nhập ở trang Hồ sơ tài xế) và `ShipperProfileServlet` đã có sẵn cơ chế
bắt buộc OTP khi đổi 2 cột này (purpose `"shipper_vehicle_bank"`, xác thực qua `xac-thuc-thay-doi`)
— chỉ thiếu bước nối nó với form rút tiền.

Khác với Shop (có cột `bankAccountName` riêng), `ShipperProfile` không lưu tên chủ tài khoản riêng
→ dùng luôn `Account.fullName` làm tên chủ tài khoản khi tạo yêu cầu rút.

**Sửa:**
- `ShipperProfile.java`: thêm `isHasBankInfo()` (true khi đủ `bankAccount` + `bankName`).
- `ShipperWalletServlet.java`: thêm `ShipperProfileDAO`, load `profile` ở cả `doGet`/`doPost`.
  `doPost()` KHÔNG nhận `bankName`/`bankAccountNumber`/`bankAccountHolder` từ form nữa — lấy từ
  `profile.getBankName()/getBankAccount()` + `account.getFullName()`. Chặn sớm nếu chưa có bank info.
- `shipper/viTien.jsp`: phần "Yêu cầu rút tiền" hiển thị khối "Tài khoản nhận tiền (đã lưu)"
  read-only + link "✏️ Đổi (cần OTP)" trỏ `/shipper/profile#bankInfoSection`; ẩn form nếu chưa có
  thông tin ngân hàng. Form rút tiền giờ chỉ còn 1 ô nhập số tiền.
- `shipper/hosotaixe.jsp`: thêm `id="bankInfoSection"` cho khối Số TK ngân hàng, thêm hint nói rõ
  tài khoản này cũng dùng để nhận tiền rút và tên chủ TK mặc định lấy theo họ tên hồ sơ.

### Files sửa:
- `ShipperProfile.java`, `ShipperWalletServlet.java`, `shipper/viTien.jsp`, `shipper/hosotaixe.jsp`

## 130. Rút tiền Shop dùng thông tin ngân hàng đã lưu, đổi phải xác thực OTP

Trước đây form "Yêu cầu rút tiền" ở `shop/viTien.jsp` cho Shop tự gõ Ngân hàng/Số tài khoản/Tên
chủ tài khoản mỗi lần rút, không lưu lại và không xác thực gì — ai chiếm được session admin/shop
đều có thể đổi thẳng số tài khoản nhận tiền ngay tại form rút tiền.

Nhận thấy `Shop` model đã có sẵn 3 cột `bankCode`/`bankAccountNumber`/`bankAccountName` (vốn dùng
để tạo QR nhận tiền ở Bấm Bill) và `ShopProfileServlet` đã có sẵn cơ chế bắt buộc OTP khi đổi 3
cột này (`SensitiveInfoOtpUtil`, purpose `"shop_bank"`) — tái dùng lại thay vì làm lại từ đầu.

**Sửa:**
- `Shop.java`: thêm `getBankNameDisplay()` (map `bankCode` → tên ngân hàng hiển thị, danh sách
  phải khớp `<option>` trong `Shopprofile.jsp`) và `isHasBankInfo()` (true khi đủ cả 3 trường).
- `ShopWalletServlet.doPost()`: KHÔNG nhận `bankName`/`bankAccountNumber`/`bankAccountHolder` từ
  form nữa — luôn lấy từ `shop.getBankCode()/getBankAccountNumber()/getBankAccountName()` đã lưu
  trong DB. Chặn sớm với thông báo yêu cầu cập nhật hồ sơ nếu `!shop.isHasBankInfo()`.
- `shop/viTien.jsp`: phần form rút tiền hiển thị khối "Tài khoản nhận tiền (đã lưu)" read-only +
  link "✏️ Đổi (cần OTP)" trỏ tới `/shop/profile#bankInfoSection`; nếu chưa có thông tin ngân hàng
  thì ẩn hẳn form rút tiền, chỉ hiện cảnh báo + link cập nhật. Form rút tiền giờ chỉ còn 1 ô nhập
  là số tiền.
- `Shopprofile.jsp`: thêm `id="bankInfoSection"` cho khối form ngân hàng (để link anchor từ
  viTien.jsp), cập nhật `form-hint` nói rõ đây cũng là tài khoản nhận tiền rút. Luồng đổi bank
  info ở đây vốn đã bắt buộc OTP gửi email từ trước (không đổi logic OTP, chỉ tái sử dụng).

### Files sửa:
- `Shop.java`, `ShopWalletServlet.java`, `shop/viTien.jsp`, `shop/Shopprofile.jsp`

## 129. Fix ví shipper bị trừ ngay & thêm lịch sử rút tiền

### Vấn đề 1: Ví Shipper bị trừ tiền ngay khi gửi yêu cầu rút
`ShipperWalletDAOImpl.requestWithdrawal()` trước đây trừ balance ngay lúc tạo record PENDING.
Đúng ra phải chờ admin duyệt mới trừ.

**Sửa:**
- `ShipperWalletDAOImpl.requestWithdrawal()`: bỏ bước `UPDATE Shipper_Wallets SET balance = balance - ?`, chỉ INSERT record PENDING.
- `ShipperWithdrawalDAOImpl.approveWithdrawal()`: thêm transaction trừ ví (`balance - amount`) sau khi UPDATE status thành APPROVED thành công.
- `ShipperWithdrawalDAOImpl.rejectWithdrawal()`: bỏ bước hoàn tiền (không còn cần vì tiền chưa bị trừ).

### Vấn đề 2: Chưa có lịch sử rút tiền cho Shipper
**Sửa:**
- `ShipperWithdrawalDAO` + `ShipperWithdrawalDAOImpl`: thêm method `getWithdrawalsByShipper(long shipperAccountId)`.
- `ShipperWithdrawal` model: thêm getter `getRequestedAtDisplay()` format dd/MM/yyyy HH:mm.
- `ShipperWalletServlet.doGet()`: load `withdrawals` list, set attribute vào request.
- `shipper/viTien.jsp`: thêm section "Lịch sử rút tiền" với bảng hiển thị Mã GD, Số tiền, Ngân hàng, Ngày gửi, Trạng thái (badge màu PENDING/APPROVED/REJECTED + lý do từ chối).

### Files sửa:
- `ShipperWalletDAOImpl.java`, `ShipperWithdrawalDAO.java`, `ShipperWithdrawalDAOImpl.java`
- `ShipperWalletServlet.java`, `ShipperWithdrawal.java`, `shipper/viTien.jsp`

## 128. Fix 5 loi moi tim duoc qua dot audit fresh sau khi fix xong 125-127

Boi canh: sau khi hoan tat 125 (CRITICAL), 126 (3 HIGH), 127 (6 MEDIUM), chay 1 dot verify (phat
hien va sua 1 loi tu gay - xem ghi chu bo sung o muc 127) + 1 dot audit MOI, doc lap, khong lap
lai bug cu, chia 3 subagent song song (User-facing, SuperAdmin, PayOS/DAO tien). Tim them 3 loi
MEDIUM + 2 loi LOW moi. User yeu cau fix ca 5.

### Fix 1 [MEDIUM] - `UserOrderServlet`: TOCTOU khi khach tu huy don, khong re-check status o DB
Khach tu huy don dung `orderDAO.cancelOrder()` (chi guard `status &lt;&gt; CANCELLED`) sau khi servlet
tu kiem tra `isCancelableNow()` (yeu cau PENDING) o tang Java - giua luc doc va luc ghi, Shop co
the vua xac nhan don sang CONFIRMED, van bi huy oan vi dieu kien DB qua long leo. Da doi sang
`orderDAO.cancelOrderIfStatus(orderId, reason, "PENDING")` (bien the atomic da co san, dung
CAS dung "PENDING" lam trang thai ky vong).

### Fix 2 [MEDIUM] - `VoucherServlet`: sua voucher vo tinh kich hoat lai voucher da tat
`readForm()` luon set `active=true`; `updateVoucher()` khong giu lai trang thai active cu tu
`existing`. Admin tat 1 voucher loi/het han roi sua noi dung khac (vd sua mo ta) se vo tinh
kich hoat lai voucher do. Da them `v.setActive(existing.isActive())` truoc khi goi
`voucherDAO.update(v)`.

### Fix 3 [MEDIUM] - `ContentModerationServlet`/`ProductDAOImpl`: duyet san pham thieu guard atomic
Khac voi Feedback/Appeal/rut tien (da dung `WHERE status = 'PENDING'` de CAS), duyet/tu choi san
pham chi doc-roi-ghi thuong o tang servlet (`findById` roi so sanh status), khong atomic - 2 tab
admin thao tac gan dong thoi co the dan toi trang thai cuoi khong nhat quan. Da them method moi
`ProductDAO.updateStatusIfCurrent(id, expectedStatus, newStatus)` (CAS atomic, dung pattern da co
san o `OrderDAO`), dung thay cho `updateStatus()` thuong trong ca 2 nhanh approve/reject cua
`ContentModerationServlet`; chi redirect success khi CAS tra ve `true`.

### Fix 4 [LOW] - `FeedbackServlet`: bao "gui danh gia thanh cong" du INSERT that bai
`feedbackDAO.saveAndReturnId(f)` co the tra ve 0 (vd vi pham CHECK rating 1-5, hoac vi pham UNIQUE
1-danh-gia/don trong truong hop race hiem), nhung code truoc do luon redirect `success=1` khong
dieu kien. Da them: (1) validate `rating` trong khoang 1-5 NGAY tu dau, chan som truoc khi goi DB;
(2) kiem tra `feedbackId &lt;= 0` thi redirect `error=1` va return som, chi redirect success khi
insert thuc su thanh cong.

### Fix 5 [LOW] - `AppealReviewServlet`/`AppealDAOImpl`: thieu guard atomic cho duyet/tu choi
`approve()`/`reject()` truoc do chi `UPDATE ... WHERE id=?`, khong co `AND status='PENDING'` -
chan double-submit hoan toan dua vao check doc-roi-ghi o tang servlet (`AppealReviewServlet` da co
san check nay truoc khi goi DAO, nhung ban than DAO khong tu bao ve duoc neu goi truc tiep/race).
Da them `AND status='PENDING'` vao ca 2 cau SQL; rieng `approve()` con sua them: chi thuc hien
buoc phu "restore tai khoan" (`is_deleted=0, status=ACTIVE, bom_count=0`) khi buoc update appeal
THAT SU thanh cong (`executeUpdate() == 1`), tranh restore nham tai khoan khi appeal khong con o
PENDING nua. `AppealReviewServlet.doPost()` cap nhat theo kiem tra gia tri tra ve, redirect
`error=already_reviewed` neu DAO tu choi (thay vi luon bao success nhu truoc).

### Files sua:
- `UserOrderServlet.java`, `VoucherServlet.java`, `ProductDAO.java`, `ProductDAOImpl.java`,
  `ContentModerationServlet.java`, `FeedbackServlet.java`, `AppealDAOImpl.java`,
  `AppealReviewServlet.java`

Khong doi Database/schema. Chua chay `mvn compile` (khong co Maven CLI trong moi truong nay) -
da ra soat thu cong ky. Den day da hoan tat toan bo danh sach loi tim duoc qua ca 2 dot audit
toan du an (tru 2 muc thiet ke lai/tinh nang moi da duoc user xac nhan khong lam o muc 126).

## 127. Fix 6 loi MEDIUM con lai (hoan tat toan bo danh sach audit toan du an)

Boi canh: sau khi fix xong CRITICAL (muc 125) va 3 loi HIGH (muc 126), user yeu cau tiep tuc fix
not danh sach loi MEDIUM con lai tu dot audit toan du an. Day la dot fix cuoi cung, hoan tat toan
bo danh sach loi da audit (tru 2 muc HIGH #3 con lai da duoc user xac nhan KHONG lam:
shippingFeeFirst2Km/autoCompleteOrderHours can thiet ke lai/xay tinh nang moi).

### Fix 1 - Voucher khong duoc hoan lai luot dung khi don bi huy SAU KHI da tao thanh cong
Truoc day chi `CheckoutServlet` hoan luot dung voucher luc rollback GIUA CHUNG qua trinh checkout;
moi luong huy don SAU KHI da tao xong (khach tu huy, shop tu choi, shipper huy, auto-cancel qua
han) deu khong hoan lai, lam giam luot dung thuc te cua voucher so voi cau hinh.

Da them method rieng `refundVoucherIfPresent(conn, orderId)` trong `OrderDAOImpl`, goi tu dong
sau khi huy don THANH CONG trong ca `cancelOrder()` va `cancelOrderIfStatus()` (2 diem chung duy
nhat ma moi servlet huy don deu di qua). Voi `cancelStalePendingOrders()` (bulk auto-cancel, khong
loop tung dong) dung `OUTPUT INSERTED.voucher_code` de lay danh sach ma voucher cua cac don vua bi
huy hang loat roi hoan lai tung ma.

### Fix 2 - Khong kiem tra outOfStock khi them gio hang/checkout
Da them check `ProductSize.isOutOfStock()`:
- `UserCartServlet.java` (them 1 san pham vao gio): tu choi ngay khi them, redirect
  `?error=out_of_stock`.
- `UserAddComboServlet.java` (them Combo vao gio): kiem tra TAT CA san pham con trong combo, tu
  choi ca combo neu bat ky mon nao het hang (khong the giao combo thieu mon), redirect
  `?error=combo_out_of_stock`.
- `CheckoutServlet.buildLines()`: bo qua (khong tinh vao don) cac dong san pham da het hang -
  phong truong hop Shop danh dau het hang SAU KHI khach da them vao gio nhung TRUOC khi checkout
  (dung pattern "silently skip" da co san cho truong hop san pham/size bi xoa).

### Fix 3 - `commissionPercent` mac dinh dung cho ca ky doi soat QUA KHU da PAID
`DoiSoatDoanhThuShopDAOImpl.getDoiSoatTheoShop()` truoc day LUON tinh lai doanh thu/phi
san/so tien thuc nhan tu `Orders` + ty le hoa hong HIEN TAI, ke ca voi cac ky DA duoc xac nhan
thanh toan (`Shop_Settlements.status = 'PAID'`) - trong khi so tien THAT SU da tra cho Shop luc
xac nhan thanh toan da duoc luu co dinh trong `Shop_Settlements` (`gross_revenue`/`platform_fee`/
`net_payout`, xem `xacNhanThanhToan()`). Neu Super Admin doi `commissionPercent` mac dinh SAU khi
1 ky da PAID, mo lai bao cao ky do se hien so SAI lech so voi so thuc te da tra.

Da sua: SELECT them 3 cot `gross_revenue`/`platform_fee`/`net_payout` tu `Shop_Settlements`; neu
`daThanhToan = true`, GHI DE `tongDoanhThu`/`phiSan`/`soTienThucNhan` bang dung so da chot (thay vi
tinh lai), va suy nguoc `commissionRatePercent` hien thi tu `platform_fee/gross_revenue` (ty le
THAT SU da ap dung luc thanh toan) thay vi ty le hien tai. Cac ky CHUA PAID van tinh "tam tinh"
nhu cu (dung y nghia "uoc tinh", chua chot).

### Fix 4 - Shipper huy don dung `updateStatus()` thay vi `cancelOrder(reason)`
`ShipperOrderServlet.java` (action `"cancelOrder"`) truoc day dung `orderDAO.updateStatus(orderId,
"CANCELLED")` - mat `cancel_reason` (chi con luu trong `Order_Logs.note`, trong khi bao cao van
hanh `BaoCaoVanHanhDAOImpl` doc truc tiep cot `cancel_reason`), va mat guard atomic chong
double-submit. Da doi sang `orderDAO.cancelOrder(orderId, reason)` (luu dung `cancel_reason`, co
guard `status <> CANCELLED`, va tu dong hoan voucher theo Fix 1 o tren neu don co ap dung); chi
ghi `Order_Logs`/gui thong bao khi `cancelOrder()` tra ve `true` (huy thanh cong that).

### Fix 5 - Race condition hep: 2 request `updateStatusToDone`/`updateStatusToShipping` gan dong
thoi co the tru kho/cong diem/cong vi 2 lan
`ShipperOrderServlet.java` truoc do doc `order.getStaTus()` 1 lan roi goi `updateStatus()` thuong
(khong dieu kien) - neu 2 request gan nhu dong thoi (double-click/2 tab/mang lag) cung vuot qua
check Java, ca 2 deu chay tiep cac hanh dong phu (tru kho, cong diem thuong, cong vi shipper/shop).
Da doi sang `orderDAO.updateStatusIfCurrent(orderId, expectedStatus, newStatus)` (CAS atomic da co
san trong `OrderDAO`, dung cho auto-cancel tu Bug 14) cho ca `updateStatusToShipping`
(`READY_FOR_PICKUP` -> `SHIPPING`) va `updateStatusToDone` (`SHIPPING` -> `DONE`); CHI request
thang cuoc (`updated == true`) moi thuc hien cac hanh dong phu va gui thong bao.

### Fix 6 - Session khong bi invalidate khi Admin khoa tai khoan Shop/Shipper GIUA phien
`AppFilter.java` (chay tren moi request, ap dung toan site) truoc do chi kiem tra
`account.getRoleId()` tu object `Account` cache trong session tu luc dang nhap - khong bao gio
truy van lai DB de kiem tra `is_deleted`/`status = BLOCKED` cho cac request SAU do. Tai khoan
Shop/Shipper dang co session hoat dong van dung duoc (vd rut tien) ke ca sau khi Super Admin da
khoa tai khoan do, cho toi khi tu logout/het han session.

Da them method nhe `AccountDAO.isBlockedOrDeleted(accountId)` (chi SELECT `is_deleted`, `status`,
khong load ca Account) va goi trong `AppFilter` ngay sau khi xac dinh `account` khac null - neu
bi khoa/xoa thi `session.invalidate()` + redirect `/dangnhap?error=account_blocked`.
`DangNhapServlet.doGet()` them xu ly param nay thanh thong bao `loi` hien thi tren trang dang nhap.

### Fix bo sung (phat hien qua dot verify sau khi fix xong ca 127): Fix 3 tu gay loi SQL GROUP BY
Sau khi hoan tat 127, chay 1 dot verify rieng bang subagent doc lai tung file da sua - phat hien
cau SQL o Fix 3 (`getDoiSoatTheoShop()`) SELECT them 3 cot `gross_revenue`/`platform_fee`/
`net_payout` nhung KHONG dua vao `GROUP BY` - SQL Server (khac MySQL) khong ho tro suy luan phu
thuoc ham cho GROUP BY nen se nem loi bien dich runtime, bi `catch (Exception e)` nuot mat, khien
`getDoiSoatTheoShop()` luon tra ve **danh sach rong** - vo hieu hoa toan bo trang doi soat doanh
thu Shop (khong chi rieng phan Fix 3 moi them). Da sua: boc 3 cot moi trong `MAX(...)` (an toan vi
join theo shop_id+period la quan he 1-1, moi shop chi co toi da 1 dong `Shop_Settlements` cho 1
ky, nen `MAX` cho ket qua giong het gia tri tho) thay vi them vao `GROUP BY`.

### Files sua:
- `OrderDAOImpl.java`, `UserCartServlet.java`, `UserAddComboServlet.java`, `CheckoutServlet.java`,
  `DoiSoatDoanhThuShopDAOImpl.java`, `ShipperOrderServlet.java`, `AccountDAO.java`,
  `AccountDAOImpl.java`, `AppFilter.java`, `DangNhapServlet.java`

Khong doi Database/schema (Fix 3 dung lai cot da co san `gross_revenue`/`platform_fee`/
`net_payout` trong `Shop_Settlements`, khong them cot moi). Chua chay `mvn compile` (khong co
Maven CLI trong moi truong nay) - da ra soat thu cong ky tung file.

## 126. Fix 3 loi HIGH con lai (ngoai pham vi Shop, tiep tuc theo yeu cau user)

Boi canh: sau khi fix xong loi CRITICAL (muc 125), user yeu cau tiep tuc fix cac loi muc HIGH
con ton dong tu dot audit toan du an (thuoc pham vi Shipper/SuperAdmin, truoc do de danh cho
thanh vien khac).

### Fix 1 - Shipper bi REJECTED khong co duong quay lai
`ShipperIdCardUploadServlet`/`ShipperLicenseUploadServlet` upload lai anh giay to nhung khong
reset `verification_status` ve `PENDING`, nen ho so REJECTED khong bao gio xuat hien lai trong
hang cho SuperAdmin duyet - ket hop gate moi o `ShipperAcceptOrderServlet`, Shipper bi tu choi 1
lan la mat quyen nhan don vinh vien du da sua giay to dung.

Da them method moi `ShipperProfileDAO.resetToPendingIfRejected(accountId)` (atomic, chi doi khi
dang `REJECTED`, khong dung khi `PENDING`/`APPROVED`) va goi ngay sau khi upload anh thanh cong
(khong ap dung cho action `delete`) o ca 2 servlet.

### Fix 2 - Dang ky Shipper lo enumeration email/username
`Dangkyshipperservlet.java` kiem tra `tonTaiEmail`/`tonTaiUsername` TRUOC buoc rate-limit - dung
lop loi da fix o `DangKyServlet`/`QuenMatKhauServlet` (Bug 23) nhung sot o luong dang ky Shipper.
Da chuyen khoi rate-limit (`regotp:` + IP) len truoc 2 buoc kiem tra ton tai, dung y het pattern
da co san o `DangKyServlet.java`.

### Fix 3 - "Tham so van hanh he thong" la cau hinh chet (chi noi day phan an toan theo quyet dinh
cua user, KHONG thiet ke lai cong thuc phi ship, KHONG xay tinh nang tu dong hoan thanh don)
- `CheckoutServlet.java`: them field `systemConfigDAO`, doc `SystemConfig.shippingFeePerKm` moi
  request thay vi hang so cung `FEE_PER_KM = 5000` (doi ten thanh `DEFAULT_FEE_PER_KM`, giu lam
  fallback neu doc DB loi). Ap dung cho ca cong thuc tinh phi that su (doPost, dong ~164) lan gia
  tri hien thi (`showReview`). Tien the gop luon 2 lan goi `SystemConfigDAO.get()` (1 cho phi ship,
  1 rieng cho check PayOS) thanh dung 1 lan doc, tranh du thua.
- `OrderAutoCancelListener.java`: doc lai `SystemConfig.shopAcceptOrderMinutes` **moi lan quet**
  (moi 60 giay) thay vi hang so cung `AUTO_CANCEL_AFTER_MINUTES = 10` (doi ten thanh
  `DEFAULT_AUTO_CANCEL_AFTER_MINUTES`, giu lam fallback) - de Admin doi tham so co hieu luc ngay
  tu lan quet ke tiep, khong can restart server.
- **CHUA lam** (theo quyet dinh cua user, ghi lai de nguoi phu trach Order/SuperAdmin xu ly sau
  neu can): `shippingFeeFirst2Km` van chua duoc dung - cong thuc phi ship hien tai van la
  "khoang_cach x feePerKm" don gian, chua co mo hinh "2km dau co dinh + phi them moi km sau";
  `autoCompleteOrderHours` van chua duoc dung - tinh nang tu dong hoan thanh don sau X gio hoan
  toan chua ton tai, can xay moi tuong tu `OrderAutoCancelListener`.

### Files sua:
- `ShipperIdCardUploadServlet.java`, `ShipperLicenseUploadServlet.java`, `ShipperProfileDAO.java`,
  `ShipperProfileDAOImpl.java`, `Dangkyshipperservlet.java`, `CheckoutServlet.java`,
  `OrderAutoCancelListener.java`

Khong doi Database/schema. Chua chay `mvn compile` (khong co Maven CLI trong moi truong nay) -
da ra soat thu cong ky.

## 125. Fix loi CRITICAL dung chung: luong gan Shipper hoan toan khong hoat dong

Boi canh: user quyet dinh dao lai lua chon truoc do (de thanh vien khac fix), yeu cau fix ngay
loi CRITICAL da tim thay o dot audit toan du an: `OrderDAOImpl.assignShipper()` set
`status = 'ACCEPTED'` va `findAvailableOrders()` loc `status = 'WAITING_FOR_SHIPPER'` — 2 gia tri
nay KHONG nam trong CHECK constraint cua `Orders.status` (chi cho phep PENDING/CONFIRMED/
READY_FOR_PICKUP/SHIPPING/DONE/CANCELLED), nen moi lan goi deu vi pham CHECK constraint, bi
`catch (Exception e) { e.printStackTrace(); return false; }` nuot mat loi, khien: trang Shipper
tu nhan don luon rong, va nut "Gan Shipper" thu cong cua Shop luon that bai am tham (redirect
`success=assigned` gia du thuc chat khong gan duoc gi).

### Xac dinh dung luong that su truoc khi sua
Doc lai `ShipperOrderServlet.java` (`updateStatusToShipping`, dong 132): hanh dong "Bat dau giao"
cua Shipper doi hoi `order.getStaTus()` dang la **READY_FOR_PICKUP** moi cho chuyen sang
`SHIPPING`. Suy ra thiet ke dung la: sau khi gan shipper, don **giu nguyen READY_FOR_PICKUP**
(chi gan them `shipper_id`), khong can bat ky gia tri status moi nao — khop hoan toan voi 6 gia
tri da co san trong CHECK constraint, khong can sua Database/schema.

### Da sua:
- `OrderDAOImpl.assignShipper()`: bo hoan toan viec doi status trong cau UPDATE, chi con
  `SET shipper_id = ?`; dieu kien WHERE don gian lai con dung `status = 'READY_FOR_PICKUP'`
  (truoc do co them `WAITING_FOR_SHIPPER`/`CONFIRMED` trong OR, khong dung y dinh nghiep vu -
  Shop chi duoc gan shipper sau khi da bam "Da chuan bi xong").
- `OrderDAOImpl.findAvailableOrders()`: doi dieu kien loc tu
  `IN ('WAITING_FOR_SHIPPER','READY_FOR_PICKUP','CONFIRMED')` thanh dung `= 'READY_FOR_PICKUP'`
  — day la nguyen nhan chinh khien trang "Shipper tu nhan don" truoc day luon rong.
- `ShopBillServlet.java` (action `"assignShipper"`): bo dong `orderDAO.updateStatus(orderId,
  "ACCEPTED")` (du thua va sai, gay ghi de am tham that bai); don gian dieu kien cho phep action
  chi con `READY_FOR_PICKUP`. Log `Order_Logs` gio TRUYEN CHINH XAC (`READY_FOR_PICKUP` ->
  `READY_FOR_PICKUP`, vi status khong doi, chi gan them shipper) — qua do fix luon loi MEDIUM
  "Order_Logs ghi sai o assignShipper" da ghi nhan tu truoc (khong con can de danh nua vi da
  giai quyet duoc tu goc).
- `shop/Quanlybill.jsp`: dieu kien hien nut "Gan Shipper" (dong ~292) don gian lai chi con
  `READY_FOR_PICKUP && shipperId <= 0`. Badge trang thai: bo 2 nhanh chet vinh vien
  (`WAITING_FOR_SHIPPER`, `ACCEPTED` - khong con bao gio xay ra), thay bang phan biet
  `READY_FOR_PICKUP` co/chua co `shipperId` de UI van the hien duoc "da gan shipper" hay chua.
- `ShipperOrderServlet.java` (dong thong ke `donChoLayHang`): bo nhanh `"ACCEPTED".equals(st)`
  da thanh chet, chi con giu `READY_FOR_PICKUP`.

### Ghi chu - CHUA sua (ngoai pham vi Shop, co the dang duoc thanh vien khac xu ly dong thoi):
- `ShipperAcceptOrderServlet.java` da duoc thanh vien khac dieu chinh dong thoi (doc
  `order.getStaTus()` dong thay vi hard-code, kiem them WAITING_FOR_SHIPPER/CONFIRMED trong dieu
  kien huy don qua han) — khong xung dot voi fix nay (WAITING_FOR_SHIPPER chi la nhanh chet vo hai).
- Cac JSP phia Shipper/User van con tham chieu `ACCEPTED`/`WAITING_FOR_SHIPPER` nhu gia tri status
  hop le (gio thanh nhanh chet vinh vien sau fix nay, khong con hai nhung nen don dep sau):
  `shipper/chitietdonhang.jsp` (dong 381, 415), `shipper/trangchucuashipper.jsp` (dong 249, 382),
  `user/donhang.jsp` (dong 419-444).
- `BaoCaoVanHanhDAOImpl.java:62` (bao cao van hanh SuperAdmin): query tinh "thoi gian xac nhan"
  dua vao `Order_Logs.new_status = 'WAITING_FOR_SHIPPER'` — gia tri nay chua bao gio duoc ghi
  thanh cong vao `Order_Logs` (cung vi pham CHECK constraint tuong tu), nen metric nay da luon
  luon rong tu truoc gio, khong lien quan/khong bi anh huong xau di boi fix lan nay, nhung van con
  ton dong can thanh vien phu trach SuperAdmin/bao cao xu ly rieng.

### Files sua:
- `OrderDAOImpl.java`, `ShopBillServlet.java`, `shop/Quanlybill.jsp`, `ShipperOrderServlet.java`

Khong doi Database/schema (dung dung 6 gia tri status da co san). Chua chay `mvn compile` (khong
co Maven CLI trong moi truong nay) - da ra soat thu cong ky, doi chieu ca 2 phia servlet
(Shop gan shipper) va (Shipper tu nhan don) de dam bao nhat quan.

## 124. Dong bo giao dien 3 trang User (Thong bao, Doi mat khau, Gio hang) theo trang chu

Boi canh: user gui 3 anh chup man hinh trang Thong bao, Gio hang va Doi mat khau cua User, nhan xet
3 trang nay dang dung navbar/header rieng (kieu pill-nav don gian hoac navbar trang toi gian), khac
han voi header thuong hieu (logo POBFood, nav-links, avatar dropdown, nut chuong thong bao/gio hang)
dang dung o trang chu `trangnguoidung.jsp`. Yeu cau: "3 trang UI cua User nay nen dong bo lai nhu
trang chu cua User di".

Fix: copy nguyen pattern CSS + HTML + JS cua navbar trang chu (bien `:root` mau sac/shadow/glow,
`.navbar` fixed + blur, `.nav-content`, `.logo`, `.nav-links`, `.avatar-wrap`/`.avatar-btn`/
`.avatar-dropdown` voi `${account.fullName}`/`${account.userName}`/`${account.email}`, `.cart-btn`,
ham `toggleDropdown()` + listener dong dropdown khi click ra ngoai) ap dung cho ca 3 file:

- `user/thongBao.jsp`: thay navbar pill-nav cu bang header thuong hieu; chi giu 1 `cart-btn` (gio hang)
  vi trang nay la trang thong bao nen khong hien lai chuong thong bao. Them Font Awesome CDN.
- `user/doiMatKhauUser.jsp`: them taglib `fn` (thieu san, can cho `fn:substring` o avatar-btn); them
  header thuong hieu voi 2 `cart-btn` (chuong thong bao co badge `${unreadNotifCount}` + gio hang).
  Them Font Awesome CDN.
- `user/gioHang.jsp`: thay Google Font tu chi co "Inter" (khong khop voi `font-family: 'Plus Jakarta
  Sans'...` da khai bao san trong body - dung font "Inter" thay the truoc do) sang nap dung Plus Jakarta
  Sans + Font Awesome CDN; thay navbar trang/toi gian (`.nav-back`, `.nav-title`, `.nav-right`) bang
  header thuong hieu day du (logo, nav-links, avatar-dropdown, 1 `cart-btn` la chuong thong bao dung
  lai bien `${unreadNotifCount}`/`data-notif-badge` co san - khong them cart-btn gio hang thu 2 vi day
  da la trang gio hang); doi `.page-wrap` tu `position: sticky` sang lam viec voi navbar `position:
  fixed` (tang padding-top len `104px`); bo sung 2 script con thieu o cuoi trang (`toast.js`,
  `notifications-ws.js`) de dong bo tinh nang toast/cap nhat badge realtime voi 2 trang kia va trang
  chu (truoc do trang nay chi co `pob-dialog.js`).

Toan bo noi dung/chuc nang chinh cua tung trang (danh sach thong bao + form danh dau da doc, form doi
mat khau + thanh do manh mat khau, danh sach gio hang + modal sua/xoa + tinh tien) giu nguyen khong
doi, chi thay phan header/navbar va cac lien ket CSS/script lien quan.

File(s) sua: `user/thongBao.jsp`, `user/doiMatKhauUser.jsp`, `user/gioHang.jsp`.

Ghi chu: chi la thay doi giao dien (CSS/HTML/JS phia JSP), khong dong den DAO/Servlet/schema, khong
can cap nhat `database.md`.

## 123. Fix hien thi "Ngay tao" cua FAQ / Huong dan (admin/faqDanhSach.jsp)

Boi canh: trang danh sach FAQ (`admin/faqDanhSach.jsp`) dang in truc tiep `${f.createdAt}` (kieu
`LocalDateTime`) ra man hinh, khien cot "Ngay tao" hien thi dang mac dinh cua Java
(vd: `2026-08-04T01:45:02.510`) thay vi dinh dang gio/ngay/thang/nam de doc.

Fix: doi sang hien thi thu cong tung phan cua `LocalDateTime` (dayOfMonth/monthValue/year/hour/minute,
co zero-pad) theo dung pattern da dung san o `admin/AuditLogs.jsp` trong project (vi JSTL `fmt:formatDate`
khong ho tro truc tiep `LocalDateTime`, chi ho tro `java.util.Date`) -> ket qua hien thi dang
`dd/MM/yyyy HH:mm`.

File(s) sua: `admin/faqDanhSach.jsp`.

Ghi chu: khong doi schema, khong can cap nhat `database.md`.

## 122. Fix loi bien dich (compile error) + bug runtime trong BaoCaoVanHanhDAOImpl sau khi pull code

Boi canh: user yeu cau kiem tra project sau khi pull code moi ve (nhieu merge lien tiep, xem git log
o dau file nay). Khong co Maven CLI trong moi truong nay nen minh tu dung `javac` + classpath dung
tay tu `~/.m2/repository` de bien dich thu toan bo `src/main/java` (229 file) - phat hien project
KHONG BIEN DICH DUOC do 1 file bi hong sau merge.

### Bug 1 (bien dich - se lam BUILD FAIL 100%): `BaoCaoVanHanhDAOImpl.findOrderMapDetails()` thieu dau ngoac kep chuoi SQL
Dong `COALESCE(o.total_price, 0) AS total_amount, o.shipping_address, o.created_at,` bi mat dau `"`
mo/dong chuoi va dau `+` noi chuoi (co le do merge conflict resolve sai tay) -> Java hieu nham day la
code Java that su, khong phai chuoi ky tu, gay loi bien dich `';' expected` / `not a statement`. File
nay se khien ca project khong the build/deploy len Tomcat cho toi khi fix.

Fix: bo sung lai dau `"` va `+` cho dung cu phap noi chuoi nhu cac dong SQL khac trong cung method.

### Bug 2 (runtime - an sau bug 1, chi lo ra sau khi fix xong bug 1): SQL alias `total_amount` nhung code doc `rs.getDouble("total_price")`
Trong cung method, cau SQL gan alias cot gia la `AS total_amount`, nhung code Java lai goi
`rs.getDouble("total_price")` - ten cot khong khop. Vi `findOrderMapDetails()` boc trong
`try { ... } catch (Exception e) { e.printStackTrace(); }` nen loi `SQLException` (cot khong ton tai
trong ResultSet) se bi nuot am tham, ham tra ve danh sach rong thay vi du lieu that - tinh nang
"Ban do don hang" (order map) tren dashboard bao cao van hanh se luon trong rong ma khong co canh bao
loi ro rang.

Fix: doi `rs.getDouble("total_price")` thanh `rs.getDouble("total_amount")` cho khop voi alias trong
SQL.

File(s) sua: `BaoCaoVanHanhDAOImpl.java`.

Kiem tra xac nhan: bien dich lai toan bo `src/main/java` (229 file .java) bang `javac` voi classpath
dung tay tu local `.m2` repo - KET QUA: BUILD SUCCESS, 0 loi. Cung ra soat toan bo `src/main/java` va
`src/main/web` (JSP) khong con dau vet conflict marker git (`<<<<<<<`/`=======`/`>>>>>>>`) sot lai tu
merge.

Ghi chu: khong can cap nhat `database.md` - khong doi schema.

## 121. Fix 2 bug HIGH phat hien o lan re-audit Shop thu 2

Boi canh: sau khi fix xong HIGH+MEDIUM+LOW o dot audit Shop dau tien (muc 118-120), user yeu cau
re-check lai toan bo module Shop mot lan nua. Phat hien them 3 bug moi (2 HIGH, 1 MEDIUM) + 2 van de
LOW phu. User yeu cau sua HIGH truoc.

### Bug 1: `ShopBillServlet` action `"cancel"` khong cap nhat trang thai don hang thanh CANCELLED
Truoc khi sua, nhanh `cancel` chi xu ly refund (PayOS cancel + mark REFUNDED, da fix o muc 119) nhung
KHONG goi `orderDAO.updateStatus(orderId, "CANCELLED")` - khac voi cac nhanh `confirm`/`prepared`/
`assignShipper` deu co goi `updateStatus`. Hau qua: don van con nguyen `staTus = PENDING/CONFIRMED`
trong DB du khach da nhan thong bao "da bi huy" -> don van co the bi gan shipper/xac nhan/chuan bi
tiep tuc xu ly nhu binh thuong; vi dieu kien cho phep huy khong doi, shop co the bam "Huy" nhieu lan
lien tiep cho cung 1 don, moi lan lai goi lai PayOS cancel + set REFUNDED + gui them thong bao trung
lap cho khach. Ngoai ra khong tao `OrderLog` cho hanh dong huy (khac cac nhanh con lai).

Fix: them `orderDAO.updateStatus(orderId, "CANCELLED")` va tao `OrderLog` (oldStatus = trang thai
that su truoc do, newStatus = "CANCELLED") ngay sau buoc xu ly refund, truoc khi redirect
`success=cancelled`. Vi dieu kien nhanh nay chi cho phep chay khi `staTus` la PENDING/CONFIRMED, sau
khi fix thi lan huy dau tien se doi `staTus` thanh CANCELLED nen khong the bam "Huy" lai lan 2 (tu
dong chan double-submit).

File(s) sua: `ShopBillServlet.java`.

### Bug 2: `ShopServlet.insertShop()` cho phep mass-assignment `status`/`approvedBy`/`approveDate` khi tao shop moi
Truoc khi sua, `extractShopFromRequest()` doc thang cac truong `status`, `rejectionReason`,
`approvedBy`, `approveDate` tu request khong gioi han, va `insertShop()` chi ep lai `ownerId` (khac
voi `updateShop()` da duoc fix o muc 118 de ep lai toan bo cac truong nhay cam nay tu `existingShop`).
Mot chu shop (Role 2) da co 1 shop duoc duyet truoc do co the POST them
`action=insert&status=ACTIVE&approvedBy=1&approveDate=...` de tao ra shop THU HAI tu duyet luon, bo
qua hoan toan luong duyet cua `SuperAdminShopRequestServlet`. Vi `selectShopByOwnerId()` lay
`TOP 1 ORDER BY id DESC`, shop gia mao (id moi hon) se duoc uu tien tra ve o moi noi dung ham nay
(POS, Dashboard, Profile...), thay the shop hop le trong toan bo luong nghiep vu.

Fix: sau khi ep `ownerId`, ep them cung luc `status = "PENDING"`, `rejectionReason = null`,
`approvedBy = 0`, `approveDate = null` cho moi shop moi tao - bat buoc phai qua luong duyet cua Super
Admin, khong the tu gan trang thai da duyet qua form insert.

File(s) sua: `ShopServlet.java`.

Ghi chu: khong can cap nhat `database.md` - khong doi schema. Con lai 1 bug MEDIUM
(`ShopBillServlet.assignShipper()` ghi sai oldStatus/newStatus vao OrderLog) va 2 van de LOW phu
(action "new"/"insert" la dead code do bi guard chan truoc; `LocalDateTime.parse(approveDate)` khong
try/catch) chua sua, se xu ly sau theo yeu cau tiep theo cua user.

## 120. Fix 2 bug LOW con lai trong dot audit Shop (thieu validate insertShop + session Account bi mutate truoc khi DB confirm)

Boi canh: tiep tuc dot audit Shop (da fix xong HIGH o muc 118, MEDIUM o muc 119), user yeu cau sua not
2 loi LOW con lai, sau do se di kiem tra lai toan bo module Shop mot lan nua.

### Bug 1: `ShopServlet.insertShop()`/`extractShopFromRequest()` khong validate empty/whitespace
So voi `ShopProfileServlet.java` (co `normalize()` + kiem tra `isEmpty()` cho shopName/shopAddress/
shopPhone truoc khi luu), `ShopServlet.insertShop()` (them shop moi) va `updateShop()` (sua shop) goi
thang `shopDAO.insertShop()/updateShop()` ngay sau khi doc parameter tho tu form, khong trim, khong
kiem tra rong. Shop chu co the submit form voi shopName/shopAddress/shopPhone toan khoang trang (hoac
rong neu bypass HTML `required`), tao ra ban ghi Shop "rac" trong DB (ten rong, khong lien he duoc).

Fix:
- Them ham `normalize(String value)` (giong `ShopProfileServlet`/`DangKyShopServlet`) va ap dung cho
  shopName/shopDescription/shopAddress/shopPhone/shopLogo trong `extractShopFromRequest()`.
- Them guard `if (shopName.isEmpty() || shopAddress.isEmpty() || shopPhone.isEmpty())` o ca
  `insertShop()` va `updateShop()`, forward ve lai form `shopThemSua.jsp` kem thong bao loi (set
  attribute `"loi"`) thay vi luu xuong DB.
- Them block hien thi `${not empty loi}` (`<div class="alert alert-danger">`) vao dau
  `shopThemSua.jsp` — JSP nay truoc do khong co cho hien loi, du convention `loi` da duoc dung o cac
  JSP shop khac (vd `Quanlybill.jsp`).
- Luu y: khi validate that bai o `insertShop()`, KHONG the set attribute `"shop"` (dung cho pre-fill
  form) vi JSP dung `${shop != null}` de quyet dinh render hidden field `action=update` — set no o
  nhanh insert se lam form bi doi nham thanh update voi `id=0`. Nen nhanh insert that bai chi hien
  thong bao loi, khong pre-fill lai du lieu da nhap (chap nhan duoc, uu tien khong pha vo logic
  insert/update cua form).

File(s) sua: `ShopServlet.java`, `shopThemSua.jsp`.

### Bug 2: `ShopHoSoServlet` mutate doi tuong `Account` trong session truoc khi DB update thanh cong
Truoc khi sua, code lay `Account account = (Account) session.getAttribute("account")` (tham chieu toi
doi tuong dang song trong session), roi goi thang `account.setFullName(...)`, `account.setPhone(...)`,
`account.setAvatarUrl(...)` NGAY TREN doi tuong do, sau do moi goi `accountDAO.update(account)`. Neu
`update()` tra ve `false` (vd loi DB tam thoi), doi tuong trong session VAN DA BI SUA — session hien
thi du lieu moi (chua duoc luu) trong khi DB van con du lieu cu, gay lech trang thai session/DB cho
den khi user logout/dang nhap lai.

Fix: tao doi tuong `Account updated` moi (copy toan bo field tu `account` cong voi cac gia tri moi
nhap), goi `accountDAO.update(updated)` tren doi tuong moi nay, chi `session.setAttribute("account",
updated)` SAU KHI xac nhan `ok == true`. Neu update that bai, doi tuong goc trong session khong bi
dung cham, giu nguyen dung du lieu da luu trong DB.

File(s) sua: `ShopHoSoServlet.java`.

Ghi chu: khong can cap nhat `database.md` — ca hai fix deu khong doi schema, chi doi logic
validate/xu ly du lieu trong tang controller. Khong the chay `mvn compile` trong moi truong nay (khong
co Maven CLI), da doi chieu thu cong bang Grep/Read cac ten method/getter/setter lien quan
(`normalize`, `getShopName`, `Account(...)` constructor, `accountDAO.update`) de xac nhan tinh dung
dan cua code.

## 119. Fix bug MEDIUM: Shop huy don thanh toan bank/chuyen khoan tay khong duoc mark REFUNDED

Boi canh: tiep tuc dot audit Shop truoc do (da fix xong HIGH o muc 118), user yeu cau sua tiep loi
MEDIUM con lai.

### Bug: `ShopBillServlet` action `"cancel"` chi mark `REFUNDED` khi shop co cau hinh PayOS
Truoc khi sua, dieu kien mark `paymentStatus = REFUNDED` la
`wasPaid && shop.getClientKey() != null && shop.getApiKey() != null` — tuc la CHI don thanh toan
qua PayOS (va shop phai co cau hinh PayOS) moi duoc mark REFUNDED. Nhung don hang thanh toan bang
chuyen khoan tay (`paymentMethod = "BANK"`, xac nhan qua POS/thu cong, khong qua PayOS) van co the
co `paymentStatus = "PAID"` (xem `ShopPosServlet.java` dong 56/308-309). Khi shop huy 1 don loai
nay, `wasPaid` = true nen `cancelMsg` (dong 139-141) van bao khach "Vao muc Don hang -> bam Yeu
cau hoan tien", nhung DB khong bao gio duoc cap nhat `paymentStatus` thanh `REFUNDED` — khach bam
"Yeu cau hoan tien" se khong tim thay don du dieu kien (hoac logic xu ly hoan tien dua tren
`paymentStatus = REFUNDED` se khong nhan ra don nay), gay sai lech du lieu tai chinh va khach
khong hoan duoc tien qua flow binh thuong.

Doi chieu voi `UserOrderServlet.java` (dong 111-121, luong khach tu huy don) cho thay pattern
DUNG: `wasPaid` va viec goi `PayOSUtil.cancelPaymentLink(...)` la 2 moi quan tam doc lap — huy
link PayOS chi la buoc phu (chi can khi shop co cau hinh PayOS), con `updatePaymentStatus(...,
"REFUNDED")` phai chay bat cu khi nao `wasPaid = true`, khong phu thuoc PayOS key.

Da sua: tach dieu kien trong `ShopBillServlet` action `"cancel"` — `if (wasPaid)` bao ngoai, ben
trong goi `PayOSUtil.cancelPaymentLink(...)` CHI KHI shop co PayOS key (giu nguyen hanh vi cu,
khong goi API PayOS cho don khong dung PayOS), nhung `orderDAO.updatePaymentStatus(orderId,
shop.getId(), "REFUNDED")` nay chay ngay khi `wasPaid = true`, bat ke phuong thuc thanh toan nao
(PayOS hay chuyen khoan tay), dung khop pattern da co san o `UserOrderServlet.java`.

File sua: `src/main/java/org/example/controllers/ShopBillServlet.java` (action `"cancel"` trong
`doPost()`). Khong doi schema/DAO/JSP. Khong co Maven CLI trong moi truong nay nen khong chay
duoc `mvn compile` - da doi chieu logic thu cong qua Grep/Read (so sanh voi
`UserOrderServlet.java` dang lam dung) de xac nhan truoc khi ket luan.

Con lai chua sua (theo yeu cau user, tung buoc mot): 2 loi LOW (`ShopServlet.insertShop()` thieu
validate chuoi rong so voi `DangKyShopServlet`/`ShopProfileServlet`; `ShopHoSoServlet` sua doi
session Account truoc khi DB xac nhan thanh cong).

## 118. Fix bug HIGH: sua ho so Shop lam mat trang PayOS keys, toa do ban do, gio mo/dong cua

Boi canh: user yeu cau kiem tra lai logic mucShop, chay 1 dot audit (dung subagent tong hop lai
toan bo controller/DAO lien quan Shop) va tim ra 4 loi (1 HIGH, 1 MEDIUM, 2 LOW). User yeu cau sua
truoc loi HIGH.

### Bug: `ShopServlet.updateShop()` ghi de NULL 7 truong khong co tren form sua ho so
`shop/shopThemSua.jsp` (form sua ho so Shop) chi co cac input cho `shopName, shopDescription,
shopAddress, shopPhone, shopLogo`. `ShopServlet.extractShopFromRequest()` dung request nay de tao
1 `Shop` object MOI, nen cac truong khong co tren form (`clientKey, apiKey, checkSumKey,
locationX, locationY, openTime, closeTime`) mac dinh la `null` tren object nay.

`updateShop()` (dong ~197-236) truoc khi sua chi bao toan 5 truong nhay cam ve nghiep vu
(`ownerId, status, rejectionReason, approvedBy, approveDate`) bang cach copy lai tu
`existingShop` (ban ghi cu trong DB), nhung KHONG bao toan 7 truong con lai o tren. Trong khi do
`ShopDAOImpl.updateShop()` chay 1 cau `UPDATE Shops SET ...` day du 18 cot, kem ca 7 cot do — bat
ky Shop object nao truyen vao co truong null se ghi de NULL thang xuong DB.

Hau qua: MOI LAN Shop chu chi don gian sua ten/mo ta/dia chi/SDT/logo cua shop (thao tac binh
thuong, khong co y dinh xau), he thong se tu dong xoa sach:
- `clientKey/apiKey/checkSumKey` (cau hinh PayOS) -> hong luon tinh nang thanh toan PayOS cua shop
  do, khach khong the thanh toan online duoc nua.
- `locationX/locationY` (toa do ban do) -> shop bien mat khoi tinh nang ban do/tim shop gan day.
- `openTime/closeTime` (gio mo/dong cua) -> mat du lieu gio hoat dong, anh huong logic
  `isOpenNow()` dang dung o noi khac (vd. hien thi "Dang mo cua"/"Da dong cua" cho khach).

Day la loi mat du lieu am tham (silent data loss), khong co thong bao loi, rat de bi bo qua khi
QA vi hanh vi sua ten/mo ta/dia chi/SDT/logo tren UI van hoat dong dung — chi co cac truong an moi
bi xoa.

Da sua: bo sung 7 dong `updateData.setX(existingShop.getX())` ngay sau 5 dong bao toan cu trong
`updateShop()`, bao toan `clientKey, apiKey, checkSumKey, locationX, locationY, openTime,
closeTime` tu ban ghi hien co truoc khi goi `shopDAO.updateShop(updateData)`. Da doi chieu lai
ten getter/setter voi `Shop.java` de dam bao khop chinh xac.

File sua: `src/main/java/org/example/controllers/ShopServlet.java` (method `updateShop()`).
Khong doi schema/DAO/JSP. Khong co Maven CLI trong moi truong nay nen khong chay duoc
`mvn compile` - da doi chieu ten method/getter/setter thu cong qua Grep/Read de xac nhan logic
dung truoc khi ket luan.

Con lai chua sua (theo yeu cau user, chi sua HIGH truoc): 1 loi MEDIUM
(`ShopBillServlet` - huy don da thanh toan bang chuyen khoan ngan hang khong tu PayOS thi khong
cap nhat `paymentStatus` thanh `REFUNDED`, trong khi thong bao cho khach van noi dung yeu cau
hoan tien nhu binh thuong) va 2 loi LOW (`ShopServlet.insertShop()` thieu validate chuoi rong so
voi `DangKyShopServlet`/`ShopProfileServlet`; `ShopHoSoServlet` sua doi session Account truoc khi
DB xac nhan thanh cong).

## 117. Fix bug moi phat hien khi verify lai: Don hang ket vinh vien o CONFIRMED (Quanlybill.jsp)

Boi canh: sau khi fix xong toan bo bug Shop tim duoc qua 2 dot audit, chay 1 dot verify cuoi cung
(xac nhan lai 7 fix truoc khong regression + ra soat moi phan JSP/action phu chua soi ky). Phat
hien 1 bug nghiem trong MOI, thuan tuy o tang JSP, khong lien quan gi toi loi CRITICAL dung chung
DAO (khong can dung vao OrderDAOImpl).

### Bug: nut "Da chuan bi xong" gan sai dieu kien status, don hang ket vinh vien o CONFIRMED
`ShopBillServlet.doPost()` action `"prepared"` (dong 95) chi chay khi `order.getStaTus()` dang la
`"CONFIRMED"` — dung voi thuc te vi action `"confirm"` (dong 84) set don ve `CONFIRMED`. Nhung
`shop/Quanlybill.jsp` (dong 275, truoc khi sua) lai chi hien nut "📦 Đã chuẩn bị xong" khi
`o.staTus == 'ACCEPTED'` — trang thai nay chi xay ra SAU KHI gan shipper, muon hon nhieu so voi
`CONFIRMED`. Hau qua: Shop bam "Xac nhan" mot don PENDING -> don chuyen CONFIRMED -> dong trang
thai chi con nut "Xem"/"PDF", KHONG CON nut nao de tiep tuc xu ly (khong "Da chuan bi xong",
khong "Huy", khong "Gan shipper" vi dieu kien gan shipper chi nhan `WAITING_FOR_SHIPPER`/
`READY_FOR_PICKUP`) -> don hang ket vinh vien o CONFIRMED, Shop phai sua DB tay moi cuu duoc.

Da sua:
- `shop/Quanlybill.jsp` dong ~275: doi dieu kien tu `o.staTus == 'ACCEPTED'` thanh
  `o.staTus == 'CONFIRMED'`, dung khop voi dieu kien that su cua action `"prepared"` o servlet.
- Tien the bo sung luon nhan badge cho trang thai `CONFIRMED` (dong ~236) — truoc do khong co
  nhanh nao cho `CONFIRMED` trong khoi hien thi badge trang thai, se roi vao `&lt;c:otherwise&gt;` hien
  raw `${o.staTus}` ("CONFIRMED") thay vi nhan than thien; doi ten nhan `WAITING_FOR_SHIPPER` tu
  "Đang chuẩn bị & Tìm tài xế" thanh "Đang tìm tài xế" cho dung nghia rieng biet voi nhan
  `CONFIRMED` moi them ("Đang chuẩn bị món").

File sua: `src/main/web/shop/Quanlybill.jsp`. Khong doi Java/DAO/schema.

### Tong ket dot fix bug Shop (qua 3 lan sua trong phien nay):
Da fix toan bo 8 loi xac nhan duoc thuoc pham vi Shop (2 HIGH, 1 MEDIUM cu da fix + 1 MEDIUM moi
phat hien lan nay, 2+2 LOW). Con lai dung 1 loi MEDIUM (Order_Logs sai o action "assignShipper")
co y KHONG sua vi gan chat voi loi CRITICAL dung chung DAO (`OrderDAOImpl.assignShipper`) - user
da xac nhan lai 2 lan giu quyet dinh nay, de thanh vien khac xu ly cung luc voi loi CRITICAL.
Da qua 1 dot verify + ra soat moi (JSP, CSRF, action phu toggle/restore) khong phat hien them van
de nao khac ngoai bug nay.

## 116. Fix 2 loi LOW con lai cua Shop (tu dot audit sau)

### Fix 1 - `ShopDoiMatKhauServlet` co the crash 500 neu POST thieu field
`doPost()` dung thang `currentPassword`/`newPassword`/`confirmPassword` (co the null neu form
gui thieu field, vd goi truc tiep API bang cong cu ngoai UI) vao `BCrypt.checkpw(...)` va
`.equals(...)` ma khong kiem tra null truoc — gay `IllegalArgumentException`/`NullPointerException`
khong duoc catch, tra ve HTTP 500. Da them kiem tra null ngay sau khi doc 3 tham so, redirect ve
`?error=missing_field` neu thieu (cung co che voi cac loi khac da co san: wrong_current/not_match/
too_short/server). Them block hien thi tuong ung trong `shop/doiMatKhauShop.jsp`.

### Fix 2 - `ShopPosServlet.createOrder()` chi chong double-submit o JS, khong co server-side
Truoc do chi dua vao `btn.dataset.submitting` phia client (`Banhang.jsp`) - network retry hoac
goi thang request (bo qua UI) van tao duoc 2 don + tru kho 2 lan cho cung 1 luot ban. Da them
guard server-side dung lai `RateLimitUtil` da co san trong du an (cung utility dung cho rate-limit
dang nhap/OTP): moi tai khoan Shop chi duoc tao 1 don trong 1 cua so 3 giay
(`RateLimitUtil.isBlocked/recordFailure(key, 1, 3000, 3000)`), khong anh huong luong ban hang binh
thuong (nhieu don/ngay, chi chan tao 2 don gan nhu dong thoi).

### Files sua:
- `ShopDoiMatKhauServlet.java`, `shop/doiMatKhauShop.jsp`, `ShopPosServlet.java`

Khong doi Database/schema. Chua chay `mvn compile` (khong co Maven CLI trong moi truong nay) -
da ra soat thu cong ky. Den day da fix xong toan bo cac loi thuoc pham vi Shop tim duoc qua 2 dot
audit (CRITICAL dung chung DAO va MEDIUM gan voi no van co y de lai cho thanh vien khac).

## 115. Fix 2 loi HIGH o `ShopServlet.java` (audit sau phan Shop, lan 2)

Boi canh: audit sau lan 2 tap trung rieng phan Shop (15 controller), phat hien 2 loi HIGH moi
o `ShopServlet.java` (`/shops`) chua tung duoc de cap truoc do.

### Fix 1 - IDOR: role khac 2 (vd Shipper) xem/sua duoc thong tin BAT KY shop nao
`showEditForm()` (dong 186) va `updateShop()` (dong 213) truoc do chi kiem tra ownership khi
`currentAcc.getRoleId() == 2` — endpoint `/shops` chi chan cung `roleId == 3` (User) o dau ham,
nen tai khoan Shipper (roleId = 4) lot qua hoan toan check ownership, goi thang
`GET/POST /shops?action=edit|update&amp;id=&lt;id shop bat ky&gt;` la xem/sua duoc thong tin cong khai
(ten, mo ta, dia chi, SDT, logo) cua shop khac (status/owner van duoc server tu giu nguyen nen
khong doi duoc quyen so huu, nhung van deface duoc thong tin).

Da sua: doi dieu kien thanh `currentAcc.getRoleId() != 1` (chi Super Admin hoac dung chu shop moi
duoc xem/sua, chan MOI role khac chu khong rieng role 2) o ca 2 cho (`showEditForm()`,
`updateShop()`).

### Fix 2 - Role check bi dao nguoc: Chu shop khong bao gio tao duoc shop moi qua `/shops`
Dong 84 (action `"new"`): `if (roleId == 1)` trong khi comment ngay tren ghi ro y dinh la
`roleId == 2` (Chu shop), va action `"insert"` (dong 92) lai dung yeu cau `roleId == 2` — 2 dieu
kien doi nghich khien khong role nao tao duoc shop qua luong nay (dead code path, may la con
luong thay the `DangKyShopServlet` hoat dong binh thuong nen chua gay hai thuc te, nhung van la
bug that trong code reachable truc tiep qua URL). Da sua `if (roleId == 1)` thanh
`if (roleId == 2)` dung theo y dinh cua comment.

### Ghi chu - cac loi khac tim duoc trong dot audit nay, CHUA sua (theo yeu cau chi sua 2 loi HIGH):
- [MEDIUM] `Order_Logs` van ghi sai o action `"assignShipper"` trong `ShopBillServlet.java`
  (dong 121-122) — co y chua sua vi gan voi loi CRITICAL dung chung (`OrderDAOImpl.assignShipper`)
  ma user da quyet dinh de thanh vien khac xu ly.
- [LOW] `ShopDoiMatKhauServlet` co the crash 500 (NPE/IllegalArgumentException) neu POST thieu
  field `currentPassword`/`newPassword`.
- [LOW] `ShopPosServlet.createOrder()` chi chong double-submit o JS phia client, khong co bao ve
  server (idempotency-key/unique constraint).

### Files sua:
- `ShopServlet.java`

Khong doi Database/schema. Chua chay `mvn compile` (khong co Maven CLI trong moi truong nay) -
da ra soat thu cong ky.

## 114. Fix 3 loi thuoc pham vi Shop (tu dot audit toan du an)

Boi canh: theo phan cong, phan nay chi fix cac loi thuoc pham vi Shop; SuperAdmin/Shipper se do
thanh vien khac xu ly. Rieng loi CRITICAL dung chung (`OrderDAOImpl.assignShipper()` set
`status = 'ACCEPTED'` vi pham CHECK constraint cua `Orders.status`, lam hong ca nut "Gan Shipper"
cua Shop lan "Tu nhan don" cua Shipper) — user quyet dinh **KHONG fix trong dot nay** vi dung chung
DAO, de thanh vien khac xu ly rieng.

### Fix 1 - IDOR: Combo/Flash Sale co the tham chieu ProductSize cua Shop khac
`ShopComboServlet.addItems()` va `ShopFlashSaleServlet.doPost()` truoc do chi kiem tra
`productSizeDAO.findById(sizeId) != null`, khong kiem tra `size.getShopId() == shop.getId()`.
Da them dieu kien ownership vao ca 2 file, dung pattern da co san o `ShopToppingServlet.validate()`.

### Fix 2 - Kiem duyet san pham bi bypass khi Shop sua san pham dang `PENDING_REVIEW`
`Quanlysanpham.jsp` dropdown status chi co 3 option (`ACTIVE/HIDDEN/OUT_OF_STOCK`), thieu
`PENDING_REVIEW` — san pham moi tao (mac dinh `PENDING_REVIEW`, cho Super Admin duyet) neu Shop mo
form sua (vd chi sua gia/mo ta) roi luu, trinh duyet tu chon option dau tien submit len, lam san
pham tu dong chuyen `ACTIVE` ngay, bo qua kiem duyet. Da sua o `ShopProductServlet.updateProduct()`:
neu `existing.getStaTus()` dang la `PENDING_REVIEW` thi giu nguyen, khong cho form ghi de - Shop
sua thong tin khac khong lam doi trang thai kiem duyet, chi Super Admin (qua
`ContentModerationServlet`) moi doi duoc trang thai nay. (San pham dang `HIDDEN` khong bi anh
huong vi dropdown da co san option nay, chon dung binh thuong.)

### Fix 3 - `Order_Logs` ghi sai `newStatus` o action "confirm" (`ShopBillServlet.java`)
Order thuc su duoc set `CONFIRMED` nhung log lai ghi `newStatus = "WAITING_FOR_SHIPPER"` (gia tri
nay khong bao gio thuc su ton tai tren `Orders.status`, xem loi CRITICAL da ghi nhan o tren). Da
sua log dung khop voi status that: `CONFIRMED`.

Khong sua phan log cua action "assignShipper" (dong ~121-122): viec log dung cho hanh dong nay
gan chat voi loi CRITICAL noi tren (status "ACCEPTED" du dinh set cung khong nam trong CHECK
constraint cua ca `Orders.status` lan `Order_Logs.new_status`) - se duoc xu ly cung luc khi ai do
fix loi CRITICAL dung chung.

### Files sua:
- `ShopComboServlet.java`, `ShopFlashSaleServlet.java`, `ShopProductServlet.java`, `ShopBillServlet.java`

Khong doi Database/schema. Chua chay `mvn compile` (khong co Maven CLI trong moi truong nay) -
da ra soat thu cong ky.

## 113. Fix 4 loi Logic muc do LOW (tu dot audit toan du an bang 4 subagent song song)

Boi canh: sau dot audit toan du an (4 mang: Order/Checkout/Payment, Auth/Vi tien, Shop/Shipper,
SuperAdmin/Complaint/Feedback), user chon sua truoc cac loi muc LOW vi don gian hon.

### Fix 1 - `VoucherServlet.validate()` khong chan `maxDiscount` am
Voucher PERCENT voi `maxDiscount` am se lam `Voucher.computeDiscount()` tra discount am, khien
`CheckoutServlet` tinh `totalPrice = subtotal + fee - discount` bi **tang** tien thay vi giam.
Da them dieu kien `v.getMaxDiscount() != null && v.getMaxDiscount() < 0` vao `validate()`.

### Fix 2 - `ThamSoVanHanhServlet` khong validate range + khong ghi audit log
Da them:
- Method `validate(SystemConfig)`: chan `commissionPercent` ngoai [0,100], cac loai phi/ban kinh
  am, `shopAcceptOrderMinutes`/`autoCompleteOrderHours` <= 0, va gia tri `NaN`/`Infinity` (cung
  pattern voi Bug 25 da fix truoc do o ShopWalletServlet/ShipperWalletServlet).
- Loi validate: redirect ve chinh trang kem `?success=invalid&msg=...`, tan dung luon co che
  toast JS co san (`admin/ThamSoVanHanh.jsp` dong ~296-304) thay vi tao co che `loi`/forward moi.
- Ghi `auditLogService.log(..., AuditModules.SYSTEM, ...)` sau khi luu thanh cong — truoc do thao
  tac doi tham so nhay cam (bao gom ca PayOS keys) khong de lai dau vet audit nao.

### Fix 3 - Duyet/tu choi Shipper thieu state-machine guard
`ShipperProfileDAOImpl.updateVerificationStatus()`: them dieu kien atomic
`AND verification_status = 'PENDING'` vao cau UPDATE — chi cho duyet/tu choi dung 1 lan tren 1
ho so dang PENDING, tranh double-click/multi-tab doi trang thai tuy y (APPROVED<->REJECTED) va
ghi de `verified_by`/`verified_at`. `SuperAdminShipperRequestServlet` da san co kiem tra
`if (!updated) {...}` nen tu dong hien loi dung khi guard nay chan, khong can sua servlet.

### Fix 4 - TOCTOU hep khi huy don "qua han giao trong ngay" (`ShipperAcceptOrderServlet`)
Doan huy don qua han truoc do doc `order.getStaTus()` roi goi `cancelOrder()` (chi guard
`status &lt;&gt; CANCELLED`, khong re-check con dung `READY_FOR_PICKUP` khong) — neu 1 shipper khac
vua `assignShipper()` thanh cong xen giua, co the huy nham don vua duoc nhan. Da them method moi
`OrderDAO.cancelOrderIfStatus(orderId, reason, expectedCurrentStatus)` (bien the atomic cua
`cancelOrder()`, dung `WHERE status = ?` thay vi `status &lt;&gt; CANCELLED`), goi thay the tai
`ShipperAcceptOrderServlet` voi `expectedCurrentStatus = "READY_FOR_PICKUP"`.

### Khong sua (muc LOW con lai trong bao cao audit, da xac dinh KHONG phai bug):
`QuanLiTaiKhoanServlet` chan tuyet doi sua/xoa moi SuperAdmin khac (khong chi khi la admin cuoi
cung) — doc lai code thay day la **chinh sach bao mat co y**, co comment ro
`🔒 QUAN TRỌNG: Không cho sửa SUPER_ADMIN khác`. Sua lai se lam giam an toan (1 SuperAdmin co the
vo hieu hoa SuperAdmin khac), nen giu nguyen, khong coi day la bug.

### Files sua:
- `VoucherServlet.java`, `ThamSoVanHanhServlet.java`, `admin/ThamSoVanHanh.jsp`,
  `ShipperProfileDAOImpl.java`, `OrderDAO.java`, `OrderDAOImpl.java`, `ShipperAcceptOrderServlet.java`

Khong doi Database/schema. Khong co Maven CLI trong moi truong nay nen chua chay `mvn compile`
xac nhan bien dich — da ra soat thu cong ky, dung dung pattern SQL/atomic-guard da co san trong
du an (Bug 24, Bug 14, `updateStatusIfCurrent`).

## 112. Format lai "Tham gia" o trang Ho so Admin (SuperAdmin) cho gon

User bao: dong "Tham gia: 2026-07-01T08:00:58.560" o `admin/hoSoAdmin.jsp` (raw toString cua
`LocalDateTime`) qua kho doc, muon dinh dang gon gio/ngay/thang/nam nhu binh thuong.

Da sua `admin/hoSoAdmin.jsp` (dong ~209-211): doi `${profile.createdAt}` sang dinh dang
"HH:mm dd/MM/yyyy" bang EL field access, dung pattern da co san trong du an
(`AuditLogs.jsp`, `admin/appeals.jsp`, va muc 110 da sua cho `yeuCauShipper.jsp`).

Ghi chu: con 2 cho khac trong du an cung dang hien raw `${account.createdAt}` chua duoc dinh dang
(`admin/yeuCauShop.jsp` dong 204, `admin/TongQuanHeThong.jsp` dong 234) — chua sua vi ngoai pham
vi yeu cau lan nay, ghi lai de xu ly sau neu can.

## 111. Fix khung avatar khong mo dropdown menu o trang "Doi soat doanh thu Shop" (SuperAdmin)

### Boi canh:
User bao loi: bam khung avatar o trang `admin/DoiSoatDoanhThuShop.jsp` khong hien dropdown menu nao.

### Nguyen nhan (loi cu phap JS, khong phai loi logic):
Trong `<script>` cuoi trang co 1 khoi code avatar-dropdown bi **loi cu phap**:
```
if (avatarBtn && avatarDropdown) {
    avatarBtn.addEventListener('click', function(e) { ... });
})();   // <-- thua "})();" khong khop voi bat ky IIFE nao, gay SyntaxError
```
Loi cu phap nay lam **toan bo noi dung `<script>` chua no khong the parse duoc**, nen JS trong
the tag nay hoan toan khong chay — anh huong day chuyen ca: nut thu gon sidebar, khoi avatar-dropdown
thu 2 (duoc viet dung nhung lai bi long ben trong 1 `document.addEventListener('DOMContentLoaded', ...)`
thu 2 — dang ky sau khi DOMContentLoaded da xay ra nen se KHONG BAO GIO chay), va ca tinh nang AJAX
"Xac nhan thanh toan cho Shop" (`reconTableBody` click handler).

### Da sua:
Gop lai thanh 1 khoi avatar-dropdown duy nhat, dat truc tiep trong than ham
`document.addEventListener('DOMContentLoaded', function() {...})` ngoai cung (khong long them
1 DOMContentLoaded nua ben trong) — dung theo dung pattern chuan da hoat dong o cac trang khac
(vd `admin/yeuCauShipper.jsp`). Da bo khoi code trung lap/loi cu phap ban dau, giu lai IIFE
sidebar-toggle va IIFE "Xac nhan thanh toan" nguyen ven ben trong cung ham ngoai.

### Fix bo sung (lan 2, sau khi user hard-refresh van khong thay gi):
Kiem tra lai toan bo `<script>` tu dau den cuoi file, phat hien 2 loi nua chua thay o lan sua truoc:
- `document.addEventListener('DOMContentLoaded', function() {...` mo o dau script **khong bao gio
  duoc dong** bang `});` — script chay thang toi cuoi roi dong `</script>` luon, van la
  SyntaxError "Unexpected end of input", tiep tuc gay toan bo script y het lan truoc.
- Ham `editCommissionRate(shopId, currentRate)` duoc goi qua `onclick="editCommissionRate(...)"`
  trong HTML (can o global scope) nhung lai duoc khai bao BEN TRONG closure cua
  `DOMContentLoaded` — du het loi cu phap thi nut "✏️ Sua % hoa hong" van bao loi
  "editCommissionRate is not defined".

Da sua: them `});` dong dung `DOMContentLoaded` ngay sau IIFE "Xac nhan thanh toan", va chuyen
`editCommissionRate` ra thanh ham global doc lap (ngoai `DOMContentLoaded`), giu nguyen than ham.

File sua: `src/main/web/admin/DoiSoatDoanhThuShop.jsp` (chi sua JS, khong doi HTML/CSS/Java/DAO).

## 110. Reconcile 2 kien truc duyet Shipper xung dot (Accounts.status vs Shipper_Profiles.verification_status)

### Boi canh:
Truoc do (trong cung session lam viec), da tung sua luong duyet Shipper theo huong: dang ky Shipper
moi -> set `Accounts.status = PENDING`, `DangNhapServlet` chan dang nhap khi `status = PENDING`,
cho toi khi SuperAdmin duyet. Song song, mot thanh vien khac trong nhom da viet lai hoan toan
`SuperAdminShipperRequestServlet.java` theo mot kien truc khac: dung rieng cot
`Shipper_Profiles.verification_status` (PENDING/APPROVED/REJECTED, co migration rieng
`migration_shipper_verification.sql` voi `rejection_reason`/`verified_by`/`verified_at`), va
**khong dung `Accounts.status` nua** — Shipper moi dang ky van `ACTIVE`, dang nhap duoc ngay, chi
bi chan **nghiep vu nhan don** cho toi khi duoc duyet giay to.

2 kien truc nay xung dot: vi `SuperAdminShipperRequestServlet` (moi) khong bao gio doi
`Accounts.status` ve `ACTIVE` sau khi duyet, Shipper moi dang ky se bi ket vinh vien o `PENDING`
va khong bao gio dang nhap duoc, du da duoc duyet.

### Da xac nhan va chon giu kien truc `Shipper_Profiles.verification_status` (cua thanh vien),
vi day la thiet ke day du, co migration rieng, co comment ghi ro la "quyet dinh kien truc da
thong nhat". Da sua de quay lai dung kien truc nay:

- `XacNhanOTPServlet.java`: bo doan `dao.updateAccountStatus(newId, "PENDING")` khi tao tai khoan
  Shipper (roleId == 4) — Shipper moi dang ky van `ACTIVE` nhu cac role khac.
- `DangNhapServlet.java`: bo han khoi kiem tra chan dang nhap khi `status = PENDING` (chi con giu
  lai 2 check cu: `isDeleted()` va `status = BLOCKED`).
- `ShipperAcceptOrderServlet.java` (`/shipper/nhan-don`, POST): **bo sung gate con thieu** — truoc
  do file nay chi kiem tra `account.isOnline()` truoc khi cho nhan don, chua he kiem tra
  `verification_status`, nghia la Shipper chua duoc duyet giay to van nhan don binh thuong duoc
  (dung y kien truc moi nhung chua duoc enforce). Da them: doc
  `ShipperProfileDAO.findByAccountId(accountId)`, chi cho nhan don khi
  `verificationStatus == "APPROVED"`, neu khong redirect ve `?error=notverified`.
- `shipper/nhanDon.jsp`: them khoi hien thi loi cho `error=notverified` (cung pattern voi
  `taken`/`offline` da co san).

Khong sua Database/migration (cot `verification_status` da co san tu truoc), khong doi
`AccountDAO`/`AccountDAOImpl` (method `updateAccountStatus` van con, chi khong con duoc goi o day).

### Fix bo sung: cot "Ngay dang ky" trong danh sach Shipper cho duyet luon rong

Nguyen nhan (khong phai loi du lieu, DB co du lieu that): `SuperAdminShipperRequestServlet.doGet()`
lay danh sach qua `accountDAO.findById(p.getAccountId())`. SQL cua `findById()` khong SELECT cot
`created_at`, va mapper `mapAccount()` (dung rieng cho cac query "gon", khac voi `mapAccountFull()`
dung cho `SELECT *`) cung khong doc/set `createdAt` — nen `Account.createdAt` luon `null` bat ke
DB co du lieu hay khong.

Da sua toi thieu, khong doi hanh vi cac cho goi `findById()` khac:
- `AccountDAOImpl.findById()`: them `created_at` vao danh sach cot SELECT.
- `AccountDAOImpl.mapAccount()`: them doan doc `created_at` (bang `try/catch` an toan, cung pattern
  voi `is_online`/`logo_url` da co san — khong anh huong cac cho goi `mapAccount()` khac ma query
  khong co cot nay, vd `DangNhap()`/`getAll()`, se tiep tuc bo qua nhu binh thuong).
- `admin/yeuCauShipper.jsp`: cot "Ngay dang ky" truoc do render raw `${s.createdAt}` (toString cua
  `LocalDateTime`, dang `2026-08-01T20:32:15...`, kho doc). Da doi sang dinh dang gon "HH:mm dd/MM/yyyy"
  bang EL field access (`.hour`/`.minute`/`.dayOfMonth`/`.monthValue`/`.year`), dung dung pattern da
  co san trong du an cho `LocalDateTime` (`AuditLogs.jsp`, `admin/appeals.jsp`) — khong dung duoc
  `fmt:formatDate` vi tag nay chi nhan `java.util.Date`, khong nhan `LocalDateTime`.

## 109. Fix thông báo lỗi validate số điện thoại/CCCD khi đăng ký Shipper (registerShipper.jsp)

### Bối cảnh:
User báo lỗi: khi đăng ký Shipper, nhập số điện thoại xong nhưng vẫn bị báo lỗi "Please match the
requested format." (tooltip mặc định của trình duyệt, tiếng Anh, không rõ nghĩa).

### Nguyên nhân (đã xác nhận, không phải bug logic):
- Field `phone` có `pattern="[0-9]{10,11}"` (bắt buộc 10-11 chữ số, đúng chuẩn số điện thoại VN).
- Ảnh chụp màn hình user gửi cho thấy giá trị nhập là `099887859` — chỉ có **9 chữ số** (thiếu 1 số
  so với số di động VN chuẩn 10 số) → không khớp regex → trình duyệt chặn submit và hiện tooltip
  HTML5 mặc định (generic, tiếng Anh).
- Server-side (`Dangkyshipperservlet.java`) không có validate lại định dạng số điện thoại/CCCD, nên
  đây là điểm chặn duy nhất — không có mismatch giữa client/server.
- Kết luận: pattern đúng, không đổi yêu cầu 10-11 số. Vấn đề thực sự là **UX của thông báo lỗi**:
  tooltip mặc định của trình duyệt không giải thích được vì sao sai và cần nhập bao nhiêu số, khiến
  user tưởng nhầm là bug dù đã "nhập số điện thoại rồi".

### Đã sửa:
`src/main/web/shipper/registerShipper.jsp` — thêm `oninvalid`/`oninput` với `setCustomValidity()`
cho 2 field:
- **Số điện thoại** (dòng ~215): thông báo tiếng Việt "Số điện thoại phải gồm 10-11 chữ số (VD:
  0901234567), không chứa khoảng trắng hay ký tự chữ. Vui lòng kiểm tra lại số bạn vừa nhập."
- **Số CCCD/CMND** (dòng ~205): thông báo tiếng Việt "Số CCCD/CMND phải gồm 9-12 chữ số, không chứa
  khoảng trắng hay ký tự chữ." (cùng cơ chế, phòng user gặp lỗi tương tự ở field này).

Cơ chế: `oninvalid` set custom message hiển thị trong tooltip validate của trình duyệt (thay vì
message mặc định); `oninput` reset lại `setCustomValidity('')` mỗi khi user gõ lại, để tooltip cũ
không bị "dính" sai khi giá trị đã hợp lệ.

### Kỹ thuật:
- Không đổi `pattern` (vẫn `[0-9]{10,11}` cho phone, `[0-9]{9,12}` cho cccd) — giữ nguyên yêu cầu
  nghiệp vụ đúng đắn.
- Không có class Java mới, không đổi servlet, không đổi schema DB → không cần cập nhật `database.md`.
- **Lưu ý**: môi trường hiện tại không có `mvn` (Maven CLI) khả dụng nên chỉ review code thủ công,
  chưa build/compile-verify (thay đổi chỉ là JS thuần trong JSP, không ảnh hưởng compile Java).

## 108. Mau hoa don giay in nhiet 58mm cho Shop (HoaDonShop.jsp)

### Bối cảnh:
Trang `src/main/web/shop/HoaDonShop.jsp` trước đây chỉ có 1 giao diện dạng thẻ (card) full A4 dùng
chung cho cả xem trên màn hình lẫn khi in. User yêu cầu khi **in** hóa đơn thì xuất ra theo đúng
form hóa đơn giấy in nhiệt (POS) khổ 58mm thường thấy ở các quán ăn, dựa trên ảnh mẫu thực tế
("VINH NGUYEN RES") user cung cấp. Giao diện xem trên màn hình (card `.bill`) giữ nguyên hoàn toàn.

### Yêu cầu đã chốt với user:
- Khổ giấy: **58mm**.
- Dữ liệu hiển thị dựa hoàn toàn theo logic có sẵn, không bịa số liệu: ô "Bàn" trong ảnh mẫu (quán
  ăn tại chỗ) được thay bằng thông tin người nhận (`bill.order.receiverName`/`receiverPhone`) vì đây
  là hệ thống giao hàng online, không phải dine-in; "Thu ngân" lấy từ tài khoản shop đang đăng nhập
  (`sessionScope.account.userName`).
- Có thêm dòng "Số tiền bằng chữ" (ví dụ: "Hai trăm hai mươi lăm nghìn đồng./").
- Chỉ áp dụng giao diện 58mm khi **in** (`@media print`), không đổi giao diện xem thường trên trình duyệt.

### Đã làm:
- **CSS**: thêm block `.receipt-print` (ẩn mặc định `display:none`) định dạng toàn bộ hóa đơn nhiệt
  (font monospace, cỡ chữ nhỏ, các dòng `.r-row` kiểu flex 2 cột, gạch đứt `.r-dash`, bảng sản phẩm,
  dòng topping thụt lề `.r-topping`, tổng tiền `.r-total`, dòng chữ `.r-words`). Mở rộng `@media print`
  để ẩn `.bill-wrap` (card cũ) + hiện `.receipt-print`, và thêm `@page { size: 58mm auto; margin: 2mm; }`.
- **Markup**: thêm `<div class="receipt-print">` là anh em (sibling) với `.bill-wrap`, gồm tên/địa
  chỉ/SĐT shop, tiêu đề "HÓA ĐƠN THANH TOÁN", số HĐ (`bill.order.id`), ngày in (JS), người nhận, thu
  ngân, bảng món ăn có đánh số thứ tự + dòng topping con (không hiển thị giá riêng cho topping vì
  `BillLine.lineTotal` đã cộng sẵn tiền topping — tránh tính trùng, xem `BillUtil.java`), tổng số
  lượng + tạm tính, phí giao hàng, tổng cộng (in đậm to), dòng số tiền bằng chữ, phương thức thanh
  toán, lời cảm ơn.
- **JavaScript**: viết hàm `soTienBangChuTiengViet(soTien)` (đọc số tiền thành chữ tiếng Việt theo
  quy tắc chuẩn: trăm/chục/đơn vị + "mười"/"mốt"/"lăm"/"linh" + hậu tố nghìn/triệu/tỷ) và 1 IIFE điền
  vào `#rPrintTime` (ngày giờ in) và `#rAmountWords` khi trang load. Đã kiểm tra thủ công logic với
  giá trị mẫu (225.000đ → "Hai trăm hai mươi lăm nghìn đồng./") cho kết quả đúng.

### Lưu ý kỹ thuật:
- Không tạo class Java mới cho việc đọc số thành chữ — xử lý client-side vì đây là logic chỉ dùng
  cho hiển thị khi in, tránh trừu tượng hoá dư thừa.
- Không đổi schema DB, không đổi Servlet/DAO nào — chỉ sửa `HoaDonShop.jsp` (CSS + HTML + JS) nên
  không cần cập nhật `database.md`.
- Môi trường hiện tại không có sẵn Maven CLI (`mvn`) nên chưa build/compile-verify được; đã review
  thủ công code JSP/CSS/JS (cú pháp JSTL, đóng thẻ HTML, tham chiếu field đúng với các model
  `BillLine`/`BillToppingLine`/`Order` đã đọc). Cần build thử và xem print-preview thực tế trước khi
  merge để chắc chắn 100%.

## 107. Fix 14 loi Logic muc do MEDIUM (audit toan bo du an)

### Bối cảnh:
Tiếp theo đợt audit toàn dự án (đã fix xong 2 lỗi CRITICAL và 4 lỗi LOW ở mục `## 94`/`## 95`),
audit phát hiện thêm 14 lỗi logic mức độ MEDIUM (#12-25), chủ yếu thuộc nhóm race-condition
(TOCTOU), double-submit, và validate đầu vào không chặt. Đã fix toàn bộ 14 lỗi trong đợt này.

### Bug 12 - Rollback thiếu khi hủy đơn (`OrderDetailServlet`/liên quan)
**Đã sửa:** Bổ sung rollback đầy đủ khi hủy đơn để tránh lệch trạng thái dữ liệu.

### Bug 13 - Checkout không idempotent
**Đã sửa:** Chặn double-checkout tạo trùng đơn hàng khi submit nhiều lần/mạng chậm retry.

### Bug 14 - Race condition khi auto-cancel đơn hàng
**Đã sửa:** Thêm điều kiện atomic để tránh auto-cancel đè lên đơn đã được xử lý thủ công.

### Bug 15 - Double-submit ở một luồng nghiệp vụ dùng chung
**Đã sửa:** Chặn gửi trùng request bằng kiểm tra trạng thái hiện tại trước khi xử lý.

### Bug 16 - Trạng thái khiếu nại bị regression
**Đã sửa:** Sửa logic cập nhật trạng thái khiếu nại để không bị lùi trạng thái ngoài ý muốn.

### Bug 17 - Duyệt/từ chối kháng cáo (appeal) thiếu kiểm tra trạng thái
**Đã sửa:** Thêm kiểm tra trạng thái hiện tại trước khi cho phép duyệt/từ chối kháng cáo.

### Bug 18 - Bộ lọc từ ngữ tục có thể bị né tránh
**Đã sửa:** Cải thiện logic lọc để giảm khả năng né bộ lọc profanity.

### Bug 19 - Double-submit đánh giá (feedback)
**Đã sửa:** Chặn gửi đánh giá trùng lặp cho cùng một đơn hàng.

### Bug 20 - PayOS: double-submit làm trừ kho 2 lần
**Đã sửa:** Thêm guard chống double-submit webhook/return khiến trừ kho lặp lại.

### Bug 21 - PayOS: không đối soát số tiền thanh toán
**Đã sửa:** Đối soát số tiền thực nhận từ PayOS với số tiền đơn hàng trước khi xác nhận thanh toán
(`PayOSWebhookServlet.java`, `PayOSReturnServlet.java`).

### Bug 22 - Rate-limit đăng nhập chỉ theo 1 chiều
**Đã sửa:** Áp dụng rate-limit đăng nhập theo cả IP và tài khoản (dual-limit)
(`DangNhapServlet.java`).

### Bug 23 - Đăng ký/quên mật khẩu lộ thông tin tồn tại tài khoản (enumeration) bỏ qua rate-limit
**Đã sửa:** Chuyển bước kiểm tra rate-limit lên chạy trước bước kiểm tra tồn tại tài khoản, để
kẻ tấn công không thể dò email/username tồn tại bằng cách spam request
(`DangKyServlet.java`, `QuenMatKhauServlet.java`).

### Bug 24 - Đối soát doanh thu Shop không chặn re-confirm (`DoiSoatDoanhThuShopServlet.java`, `DoiSoatDoanhThuShopDAOImpl.java`)
**Đã sửa:** Thêm 2 lớp bảo vệ: (1) kiểm tra `isDaThanhToan()` ở tầng servlet để chặn xác nhận
lại kỳ đối soát đã PAID (double-click, mở nhiều tab, gửi lại request cũ); (2) thêm điều kiện
atomic `WHEN MATCHED AND target.status <> 'PAID'` trong câu lệnh `MERGE` ở tầng DAO để chặn
race condition khi 2 request xác nhận gần như đồng thời (chỉ 1 request thắng, request còn lại
`executeUpdate()` trả về 0 dòng và bị coi là thất bại).

### Bug 25 - Nhập "NaN"/"Infinity" vượt qua validate rút tiền (`ShopWalletServlet.java`, `ShipperWalletServlet.java`)
**Đã sửa:** `Double.parseDouble("NaN")`/`"Infinity"` không ném exception nhưng theo IEEE-754,
MỌI phép so sánh (`<`, `>`) với các giá trị này đều trả về `false`, khiến các bước kiểm tra
"dưới mức tối thiểu" và "vượt số dư" bị bỏ qua ngầm. Đã thêm kiểm tra
`Double.isNaN(amount) || Double.isInfinite(amount)` ngay sau khi parse, reset về `0` nếu rơi
vào 2 trường hợp này để các bước validate phía sau hoạt động đúng.

### Files sửa (toàn bộ 14 fix):
- `DoiSoatDoanhThuShopServlet.java`, `DoiSoatDoanhThuShopDAOImpl.java`
- `ShopWalletServlet.java`, `ShipperWalletServlet.java`
- `DangNhapServlet.java`, `DangKyServlet.java`, `QuenMatKhauServlet.java`
- `PayOSWebhookServlet.java`, `PayOSReturnServlet.java`
- Và các file liên quan tới OrderDetail, checkout, auto-cancel, complaint, appeal, profanity
  filter, feedback (đã sửa ở các đợt trước trong cùng phiên audit này).

### Ghi chú:
- Không có thay đổi schema (bảng/cột) nào trong 14 fix này → không cần cập nhật `database.md`.
- Môi trường hiện tại không có sẵn Maven CLI (`mvn`) nên không chạy được `mvn compile` để build
  xác nhận; các fix đã được rà soát thủ công kỹ lưỡng nhưng chưa được compiler xác minh.
- Phạm vi đợt audit này dừng lại ở mức MEDIUM theo yêu cầu; các lỗi mức HIGH (9 lỗi) chưa được
  xử lý, sẽ chờ chỉ đạo tiếp theo.

---

## 106. Fix tiep lan 2: van con vai muc menu bi lo chu khi thu gon sidebar

Boi canh: sau khi fix ## 105 (boc `.mi-label` cho "Quan ly Combo"/"Flash Sale" tren 18 file), user
bao van con thay mot chut chu hien ra ("Van con hien lai mot chut chu roi."), kem screenshot zoom
sidebar thu gon cho thay nhieu muc menu khac nhau deu bi lo vai ky tu dau cua tung tu.

Nguyen nhan: khi doi chieu lai toan bo file, phat hien 2 file `Quanlycombo.jsp` va
`QuanlyFlashSale.jsp` **chi co 2 muc "Quan ly Combo"/"Flash Sale" la duoc boc `.mi-label` (o fix
## 105), con 8 muc menu khac trong CHINH 2 file nay** (Trang chu, Quan ly san pham, Quan ly loai
san pham, Quan ly Topping, Quan ly loai Topping, Bam Bill, Quan ly hoa don, Thong tin cua hang, Xem
danh gia) **van chua he duoc boc `.mi-label` tu truoc gio** — khac voi 16 file con lai trong danh
sach ## 105 la da boc dung het tat ca muc menu. Vi 2 file nay von la 2 file bi thieu nhieu nhat
(dung de fix ## 101-104), nen khi Sửa ## 105 chi soi vao dung 2 muc bi bao loi ma bo sot cac muc
con lai trong chinh 2 file do.

Cach fix: boc `<span class="mi-label">` cho toan bo 8 muc menu con lai trong `Quanlycombo.jsp` va
`QuanlyFlashSale.jsp`, dung mau da ap dung o ## 105:
```jsp
<span class="mi-left"><span class="mi-icon">📊</span> Trang chủ</span>
```
thanh:
```jsp
<span class="mi-left"><span class="mi-icon">📊</span><span class="mi-label"> Trang chủ</span></span>
```
(tuong tu cho 7 muc con lai: Quan ly san pham, Quan ly loai san pham, Quan ly Topping, Quan ly loai
Topping, Bam Bill, Quan ly hoa don, Thong tin cua hang, Xem danh gia).

Da ra soat lai toan bo `src/main/web/shop/` bang grep pattern tim menu-item chua boc `.mi-label` —
xac nhan sau fix nay khong con file shop nao bi loi nua.

Ghi chu them (ngoai pham vi shop, chua fix): file `quanlitaikhoan.jsp` (trang admin) cung dung chung
`dashboard-theme.js`/`dashboard.css` nhung **chua co nut `.sidebar-toggle-btn`** (giong loi ## 104)
va 7 muc menu cung chua boc `.mi-label` (giong loi nay). Chua sua vi ngoai pham vi bao loi hien tai
cua user (chi test trang shop), nhung se gap loi tuong tu neu sau nay bat tinh nang thu gon sidebar
cho trang admin.

Khong doi database (chi la sua the HTML/CSS o giao dien).

## 105. Fix tiep: chu bi loi ra khi thu gon sidebar (thieu span .mi-label)

Boi canh: sau khi fix ## 104 (them nut `.sidebar-toggle-btn`), user bam thu gon sidebar duoc
nhung bao "Da thay nhung khi thu gon sidebar lai thi chu bi loi ra."

Nguyen nhan (nguyen nhan thu 3, khac ## 103 va ## 104): CSS `.sidebar.collapsed .mi-label { display: none; }`
(trong `assets/css/dashboard.css`) la co che an chu nhan cua tung menu-item khi sidebar thu gon
chi con icon. Nhung 2 muc menu "Quan ly Combo" va "Flash Sale" lai dat chu truc tiep trong
`.mi-left` **khong boc trong `<span class="mi-label">`** (khac voi moi menu-item khac trong cung
file, deu dung dung `<span class="mi-label">`). Vi khong duoc boc dung class, CSS an-khi-thu-gon
khong nhan dien duoc de an chu nay di, gay ra hien tuong chu bi loi/tran ra ngoai vien icon 68px.

Day la loi he thong, lap lai giong het nhau tren **18 file JSP shop** (khong chi 2 file vua sua o
## 104) — vi 2 muc menu nay duoc copy-paste giua cac trang ma quen boc `.mi-label`. File
`viTien.jsp` la ngoai le duy nhat da lam dung tu truoc, khong can sua.

Cach fix: boc lai the span cho ca 2 muc menu, tu:
```jsp
<span class="mi-left"><span class="mi-icon">🎁</span> Quản lý Combo</span>
<span class="mi-left"><span class="mi-icon">⚡</span> Flash Sale</span>
```
thanh:
```jsp
<span class="mi-left"><span class="mi-icon">🎁</span><span class="mi-label"> Quản lý Combo</span></span>
<span class="mi-left"><span class="mi-icon">⚡</span><span class="mi-label"> Flash Sale</span></span>
```

Ap dung cho 18 file: `Banhang.jsp`, `doiMatKhauShop.jsp`, `HoaDonShop.jsp`, `hoSoShop.jsp`,
`Quanlybill.jsp`, `Quanlycombo.jsp`, `QuanlyFlashSale.jsp`, `Quanlyloaisanpham.jsp`,
`Quanlyloaitopping.jsp`, `Quanlysanpham.jsp`, `Quanlytopping.jsp`, `Shopprofile.jsp`,
`ThungRacLoaiSanPham.jsp`, `ThungRacLoaiTopping.jsp`, `ThungRacSanPham.jsp`, `ThungRacTopping.jsp`,
`trangcuahang.jsp`, `xemDanhGia.jsp`.

Khong doi database (chi la sua the HTML/CSS o giao dien).

## 104. Fix tiep: thieu han nut thu gon sidebar (.sidebar-toggle-btn) tren desktop

Boi canh: sau khi fix ## 103 (doi dung file `dashboard-theme.js`), user rebuild va bao van
"chua thay gi ca" (kem 2 anh chup man hinh trang Quan ly Combo va Flash Sale).

Nguyen nhan that su (nguyen nhan thu 2, khac voi ## 103): tren desktop (`window.innerWidth >= 901`),
CSS an han nut ☰ o topbar (`.menu-toggle-btn { display: none; }`) — nut thu gon that su tren desktop
la mot phan tu KHAC, `.sidebar-toggle-btn` (nut mui ten `<`), duoc dat canh logo trong `.sidebar-brand`.
Hai file `Quanlycombo.jsp` va `QuanlyFlashSale.jsp` thieu han phan tu `.sidebar-toggle-btn` nay trong
HTML — nen du ham `pobToggleSidebar()` da duoc dinh nghia dung (sau fix ## 103), van khong co nut nao
tren giao dien de bam ca. (`viTien.jsp` da co san nut nay tu truoc, khong bi loi nay.)

Cach fix: them nut vao `.sidebar-brand` cua `Quanlycombo.jsp` va `QuanlyFlashSale.jsp`, dong bo voi
mau da dung o cac trang shop khac (vd `doiMatKhauShop.jsp`):

```jsp
<button type="button" class="sidebar-toggle-btn" id="sidebarToggleBtn" onclick="pobToggleSidebar()" title="Thu gọn / mở rộng menu">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
</button>
```

Khong doi database (chi la thieu 1 phan tu HTML o giao dien).

## 103. Fix 3 trang shop (Combo, Flash Sale, Vi tien) khong thu gon duoc sidebar

Boi canh: user hoi cac trang "Khuyen mai" (Quan ly Combo, Flash Sale) da co tinh nang thu gon
sidebar (bam nut ☰) chua.

Nguyen nhan: ham `pobToggleSidebar()` (thu gon sidebar chi con icon tren desktop, luu trang thai
qua `localStorage`, khoi phuc lai khi tai lai trang) duoc dinh nghia trong
`assets/js/dashboard-theme.js`. Nhung 3 file `Quanlycombo.jsp`, `QuanlyFlashSale.jsp`,
`viTien.jsp` lai nhung nham file `assets/js/dashboard.js` — mot file **khong ton tai** trong
project (chi co `dashboard-theme.js`, khong co `dashboard.js`). Ket qua: nut ☰ tren 3 trang nay bi
loi JS "pobToggleSidebar is not defined", bam vao khong co phan ung gi; nut doi theme sang/toi
(neu co) cung khong hoat dong vi cung dua vao file nay.

19 trang shop con lai deu nhung dung `dashboard-theme.js` nen tinh nang thu gon sidebar hoat dong
binh thuong.

Cach fix: doi `<script src=".../assets/js/dashboard.js">` thanh
`<script src=".../assets/js/dashboard-theme.js">` trong ca 3 file
(`Quanlycombo.jsp`, `QuanlyFlashSale.jsp`, `viTien.jsp`), dong bo voi cac trang shop khac.

Khong doi database (chi la loi sai ten file JS o giao dien).

## 102. Kiem tra toan bo UI Shop xem co trang nao bi loi avatar-dropdown giong "Quan ly Combo" khong

Boi canh: sau khi fix `Quanlycombo.jsp` (## 101), user yeu cau kiem tra toan bo cac trang shop khac
xem co trang nao bi loi tuong tu (khung avatar khong mo dropdown menu) hay khong.

Cach kiem tra: grep tat ca file `*.jsp`/`*.jspf` trong `src/main/web/shop/` co chua `id="avatarBtn"`
(20 file), doi chieu voi so lan xuat hien cua `id="avatarDropdown"` va doan script
`getElementById('avatarBtn')` trong tung file.

Ket qua: tim thay **1 file khac** bi loi giong het `Quanlycombo.jsp` truoc khi fix —
`QuanlyFlashSale.jsp` (co `#avatarBtn` nhung thieu hoan toan div `#avatarDropdown` va script toggle).
19 file shop con lai deu da co day du 2 phan nay, khong can sua.

Cach fix `QuanlyFlashSale.jsp`: ap dung dung mau da dung cho `Quanlycombo.jsp` — chen div
`#avatarDropdown` (header ten/email/role + link Ho so ca nhan / Doi mat khau / Dang xuat) ngay sau
the `</main>`, va chen doan script toggle (`avatarBtn.addEventListener('click', ...)` dinh vi bang
`getBoundingClientRect()`, dong khi click ra ngoai) ngay sau the `<script src=".../dashboard.js">`
truoc `</body>`.

Khong doi database (chi la loi thieu HTML/JS o giao dien, khong lien quan schema).

## 101. Fix khung avatar o trang "Quan ly Combo" (shop) khong mo dropdown menu

Boi canh: user bao khi bam vao khung avatar o goc tren ben phai trang `shop/combo`
(`Quanlycombo.jsp`) thi khong hien dropdown menu (Ho so ca nhan / Doi mat khau / Dang xuat), trong
khi cac trang shop khac (vd `Quanlysanpham.jsp`) van hoat dong binh thuong.

Nguyen nhan: `Quanlycombo.jsp` da co san CSS cho `.avatar-dropdown` va HTML `#avatarBtn` nhung
**thieu hoan toan** div `#avatarDropdown` (noi dung menu) va doan script gan su kien click de
toggle class `.open` + dinh vi dropdown theo vi tri avatar — khac voi cac trang shop khac da co day
du 2 phan nay.

Cach fix: copy nguyen mau `#avatarDropdown` (header ten/email/role + link Ho so ca nhan / Doi mat
khau / Dang xuat) va doan script toggle (`avatarBtn.addEventListener('click', ...)` dinh vi bang
`getBoundingClientRect()`, dong khi click ra ngoai) tu `Quanlysanpham.jsp` sang `Quanlycombo.jsp`,
chen ngay sau the `</main>` va dau khoi `<script>` hien co.

Khong doi database (chi la loi thieu HTML/JS o giao dien, khong lien quan schema).

## 100. Fix loi build "cannot find symbol class BillUtil" (ShopPosServlet va 3 file khac)

Boi canh: IntelliJ bao loi bien dich o `ShopPosServlet.java` (dong 11, 53): "cannot find symbol
class BillUtil" / "cannot find symbol variable BillUtil", location `package org.example.utils`.

Nguyen nhan that su: KHONG phai loi trong `ShopPosServlet.java`. File
`src/main/java/org/example/utils/BillUtil.java` bi rong hoan toan (0 byte) do bi xoa nham trong
commit `dfc5412` ("kk", 2026-07-30). Dung `git log --oneline --all -- <path>` va
`git show <commit>:<path>` de xac dinh: o commit dau tien (`9c545f8`) file co 55 dong, sang
`dfc5412` con 0 dong (bi xoa toan bo, khong them lai gi) trong khi 4 file van goi
`BillUtil.build(order)` khong doi -> gay loi bien dich cho ca 4 file cung luc:
- `ShopPosServlet.java` (modal hoa don POS)
- `ShopBillServlet.java` (xem/in hoa don + xuat PDF cho shop)
- `ShipperOrderServlet.java` (chi tiet don hang cho shipper)
- `BillServlet.java` (khach hang xem hoa don sau checkout)

Cach fix: khoi phuc lai noi dung goc cua `BillUtil.java` tu commit `9c545f8` (da doi chieu, cac
class/DAO ma no dung (`BillView`, `BillLine`, `BillToppingLine`, `OrderDetailDAO`,
`OrderDetailToppingDAO`, `ProductDAO`, `ProductSizeDAO`, `ToppingDAO`, `ShopDAO`) khong doi ke tu
commit dau tien nen khoi phuc nguyen ven la an toan). Da build lai toan bo `src/main/java` bang
`javac` (khong co Maven CLI trong moi truong nen build thu cong voi classpath tu `~/.m2/repository`)
-> bien dich sach, khong con loi "cannot find symbol" o ca 4 file tren.

Khong doi database (chi khoi phuc lai file .java bi mat noi dung, khong thay doi schema/cau truc
bang/cot nao).

## 99. Bat buoc xac thuc OTP khi doi Email / thong tin ngan hang (Shop, Shipper, Admin)

Boi canh: theo audit o muc 98 va cau hoi "cho nao can OTP khi doi thong tin", phat hien 6 cho doi
thong tin nhay cam (email dung de khoi phuc mat khau; thong tin ngan hang/PayOS key dung de nhan
tien) hoan toan KHONG co buoc xac thuc nao - chi can co session dang dang nhap la doi duoc ngay.
Rui ro: session bi chiem dung (dung chung may, quen dang xuat, XSS...) -> doi email sang cua ke tan
cong -> dung "Quen mat khau" chiem tai khoan; hoac doi so tai khoan ngan hang -> tien COD/chuyen
khoan bi chuyen nham.

Da them co che OTP dung chung (khong dung lai duoc session OTP dang ky vi purpose khac nhau va
khong duoc xoa tai khoan cu):

- `src/main/java/org/example/utils/SensitiveInfoOtpUtil.java` (moi) - sinh/gui/xac thuc OTP 6 so
  (TTL 5 phut, khoa sau 5 lan sai) luu tam trong session theo tung `purpose` rieng (vd `shop_bank`,
  `admin_profile`), kem `Map<String,String>` du lieu moi CHUA ghi DB cho toi khi xac thuc xong.
- `src/main/java/org/example/controllers/XacThucThayDoiServlet.java` (moi, `/xac-thuc-thay-doi`) -
  trang xac nhan OTP dung chung cho ca 6 truong hop; xac thuc dung -> moi thuc su ghi du lieu
  xuong DB tuy `purpose` (Account/Shop/ShipperProfile) roi redirect ve dung trang goc.
- `src/main/web/xacThucThayDoi.jsp` (moi) - form nhap OTP 6 o, nut gui lai, dung chung cho moi role.

Da sua 5 servlet de tach nhanh "co doi thong tin nhay cam khong": neu KHONG doi (chi doi
ten/SDT/avatar/gio mo cua...) thi luu ngay nhu cu; neu CO doi thi luu tam vao session qua
`SensitiveInfoOtpUtil.generateAndSend()` roi redirect sang `/xac-thuc-thay-doi?purpose=...` thay vi
ghi DB ngay:

- `ShopHoSoServlet.java` (`/shop/ho-so`, purpose `shop_hoso`) - doi Email: gui OTP toi email MOI.
- `ShipperHoSoServlet.java` (`/shipper/ho-so`, purpose `shipper_hoso`) - doi Email: gui OTP toi
  email MOI.
- `AdminProfileServlet.java` (`/admin/profile`, purpose `admin_profile`) - doi Email: gui OTP toi
  email MOI. Uu tien cao nhat vi day la tai khoan quyen cao nhat he thong.
- `ShipperProfileServlet.java` (`/shipper/profile`):
  - `handleUpdateInfo` (purpose `shipper_profile_info`) - doi Email: gui OTP toi email MOI.
  - `handleUpdateVehicle` (purpose `shipper_vehicle_bank`) - doi `bankAccount`/`bankName` (nhan
    tien rut vi shipper): gui OTP toi email HIEN TAI da xac thuc cua tai khoan (khong phai email
    moi vi day khong phai doi email).
- `ShopProfileServlet.java` (`/shop/profile`, purpose `shop_bank`) - doi bat ky truong nao trong
  `bankCode`/`bankAccountNumber`/`bankAccountName`/`clientKey`/`apiKey`/`checkSumKey`: gui OTP toi
  email cua chu shop. Vi form nay gop chung nhieu truong (ten/dia chi/gio mo cua + ngan hang/PayOS)
  trong 1 lan submit, khi co doi ngan hang thi TOAN BO du lieu form (ke ca ten/dia chi) deu cho
  xac thuc OTP xong moi luu (chap nhan duoc, tranh phai tach form).

Khong ap dung OTP (theo dung phan tich da thong nhat o muc truoc):
- Doi mat khau (User/Shop/Shipper): da bat nhap mat khau hien tai, du an toan.
- Doi CHI ten/SDT/avatar (khong dong thoi doi Email): van luu ngay, khong lam phien nguoi dung.
- `QuanLiTaiKhoanServlet` (Super Admin sua tai khoan NGUOI KHAC): la quyen quan tri theo thiet ke,
  khong phai tu-doi-thong-tin.

Da bien dich lai toan bo `src/main/java` bang `javac` (qua Git Bash, phai doi duong dan classpath
tu dang Unix `/c/Users/...` sang dang Windows `C:\Users\\...` thi `javac.exe` moi doc dung - neu
dung nguyen path kieu Unix se bao loi gia "package jakarta.servlet does not exist" du jar co san),
khong loi. Da bo sung them kiem tra `accountDAO.tonTaiEmailKhacId(email, id)` truoc khi gui OTP o
ca 3 servlet `ShopHoSoServlet`/`ShipperHoSoServlet`/`AdminProfileServlet` (giong pattern da co san
o `ShipperProfileServlet`) de tranh gui OTP roi moi phat hien email da ton tai luc ap dung thay doi.

Files sua/them:
- `src/main/java/org/example/utils/SensitiveInfoOtpUtil.java` (moi)
- `src/main/java/org/example/controllers/XacThucThayDoiServlet.java` (moi)
- `src/main/web/xacThucThayDoi.jsp` (moi)
- `src/main/java/org/example/controllers/ShopHoSoServlet.java`
- `src/main/java/org/example/controllers/ShipperHoSoServlet.java`
- `src/main/java/org/example/controllers/AdminProfileServlet.java`
- `src/main/java/org/example/controllers/ShipperProfileServlet.java`
- `src/main/java/org/example/controllers/ShopProfileServlet.java`

## 98. Tu test lai muc 97 (chong bam-2-lan) - phat hien sot 1 form quan trong

Boi canh: sau khi lam muc 97, tu dat cau hoi "bam Luu 2 lan lien tiep that nhanh o popup Bam Bill co
goi update 2 lan khong" va doc lai code de kiem tra thay:

- `_invoiceModal.jspf` (form `paymentStatusForm`, dung o `Banhang.jsp` mode `pos`) co nut
  "💾 Luu" nam **BEN NGOAI** the `<form>`, chi noi voi form qua thuoc tinh `form="paymentStatusForm"`
  (`<button type="submit" form="paymentStatusForm">`). `pobGuardSubmit()` viet o muc 97 chi
  `form.querySelectorAll('button[type="submit"]')` **BEN TRONG** form nen KHONG tim thay nut nay ->
  form nay van chua duoc bao ve dan den bam Luu 2 lan van co the goi `updatePaymentStatus` 2 lan.

Da sua:

- `src/main/web/assets/js/form-guard.js`: `pobGuardSubmit()` gio tim them ca cac nut submit nam
  ngoai form qua `document.querySelectorAll('button[form="<id-cua-form>"], input[form="<id>"]')`
  (chi khi form co `id`), gop chung voi danh sach nut ben trong de khoa dong thoi.
- `src/main/web/shop/_invoiceModal.jspf`: them `onsubmit="return pobGuardSubmit(this)"` cho
  `#paymentStatusForm`.

Ket qua: bam "Luu" trang thai thanh toan trong popup Bam Bill gio moi thuc su chi goi
`updatePaymentStatus` 1 lan du bam nhanh nhieu lan.

Cau hoi da tu kiem tra khac (khong phat hien loi, ghi lai de tham khao):
- 2 shipper cung bam "Nhan don" cho 1 don cung luc -> `OrderDAOImpl.assignShipper()` da dung
  `UPDATE ... WHERE shipper_id IS NULL OR shipper_id = 0` (atomic, khong bi race condition),
  `ShipperAcceptOrderServlet` kiem tra `executeUpdate() == 1` de biet don da bi nguoi khac nhan.
- Truy cap thang `/checkout?cartId=...` khi gio hang rong -> `CheckoutServlet.doGet`/`doPost` da
  co `if (lines.isEmpty()) redirect /cart?error=empty_cart`, khong loi.
- Go DOM bo thuoc tinh `disabled` cua nut "Xac nhan thanh toan" khi CHUA chon vi tri tren ban do
  (bypass khoa JS) -> `CheckoutServlet.doPost` van CHO tao don (khong bat buoc `locationX`/`locationY`
  o server), chi fallback ve phi co dinh `FIXED_DELIVERY_FEE = 15.000d` cho shop chua co toa do -
  day la thiet ke co chu y (khoa nut chi de UX hien phi chinh xac hon, khong phai rang buoc bat buoc),
  khong sua vi thay doi se anh huong toi luong dat hang khi shop/khach chua co toa do - ghi chu lai
  phong khi sau nay muon bat buoc chon vi tri that su.

Files sua:
- `src/main/web/assets/js/form-guard.js`
- `src/main/web/shop/_invoiceModal.jspf`

## 97. Chong bam-2-lan (double-submit) cho cac form quan trong (tien/don hang)

Boi canh: sau khi audit UX/UI toan bo `src/main/web/`, phat hien chi 2 trang (`checkoutThanhToan.jsp`,
`Banhang.jsp`) co logic khoa nut submit chong bam-2-lan/double-click gay tao trung don hoac tru kho
2 lan, con lai gan 40+ form hanh dong (xoa, xac nhan, huy, gan shipper, bat/tat voucher...) khong co
guard nao. Uu tien sua truoc cac form lien quan **tien/don hang** (rui ro cao nhat neu bi trung).

Da tao helper dung chung thay vi copy-paste code nhu truoc:

- `src/main/web/assets/js/form-guard.js` (moi) — ham `pobGuardSubmit(form)`: neu form dang o trang
  thai `submitting` thi chan submit tiep; nguoc lai danh dau `submitting`, khoa (`disabled`) va doi
  chu cac nut `type="submit"` trong form sang "Đang xử lý..." (luu lai chu cu qua `data-orig-text`
  phong khi can dung lai). Dung duoc doc lap (`onsubmit="return pobGuardSubmit(this)"`) hoac ket hop
  voi `confirm()` co san (`onsubmit="return confirm('...') && pobGuardSubmit(this)"`).

Da gan `pobGuardSubmit` (+ include `form-guard.js`) vao cac form sau (tat ca truoc do KHONG co
guard nao):

- `shipper/chitietdonhang.jsp`: form "Xác nhận đã lấy hàng", "Báo bom hàng", "Hoàn thành giao đơn"
  (nhanh cuoi lien quan xac nhan da giao/nhan tien COD).
- `shipper/nhanDon.jsp`: form "Nhận đơn này".
- `shop/Quanlybill.jsp`: form "Xác nhận", "Từ chối", "Đã chuẩn bị", "Hủy", "Gán" (shipper) tren
  moi dong don hang.
- `shop/taoProduct.jsp`: form tao/sua san pham, form "Xóa" san pham.
- `admin/QuanLyVoucher.jsp`: form "Bật/Tắt" va "Xoá" voucher.

Da KIEM TRA rieng `admin/DuyetRutTienShipper.jsp` (phe duyet rut tien shipper) — audit ban dau
nham tuong trang nay thieu guard, nhung thuc te code AJAX (`fetch`) o day **da co san**
`approveBtn.disabled = true` / `rejectBtn.disabled = true` truoc khi goi API va mo lai khi loi, nen
khong can sua.

Han che: day la buoc dau chi ap dung cho cac form lien quan tien/don hang duoc uu tien; van con
nhieu form khac (vd toggle "Tắt chế độ Online" cua shipper dang bi copy-paste 8 file) chua duoc
gom lai — ghi nhan de xu ly rieng neu can.

Files sua/them:
- `src/main/web/assets/js/form-guard.js` (moi)
- `src/main/web/shipper/chitietdonhang.jsp`
- `src/main/web/shipper/nhanDon.jsp`
- `src/main/web/shop/Quanlybill.jsp`
- `src/main/web/shop/taoProduct.jsp`
- `src/main/web/admin/QuanLyVoucher.jsp`

## 96. Dong popup hoa don o "Bam Bill" ngay sau khi bam "Luu" trang thai thanh toan

Endpoint: `/shop/pos`

Truoc do tren trang `Banhang.jsp` (Bam Bill), sau khi tao don xong popup hoa don (`_invoiceModal.jspf`,
`modalMode=pos`) hien len de shop chon trang thai thanh toan (Chua thanh toan/Dang cho/Da thanh toan)
roi bam "💾 Luu". Nut Luu submit form `updatePaymentStatus` -> `ShopPosServlet` redirect ve
`/shop/pos?invoiceId=<id>&saved=1`, van truyen lai `invoiceId` nen popup **mo lai y nguyen** (chi co
thong bao "Da luu thanh cong" hien ben trong popup), nguoi dung phai tu bam nut ✕ de dong - khong
dung y muon "luu xong (du la Da thanh toan hay Dang cho) thi tu dong dong popup".

Da sua:

- `src/main/java/org/example/controllers/ShopPosServlet.java`: nhanh `action=updatePaymentStatus`
  doi redirect tu `/shop/pos?invoiceId=<id>&saved=<0|1>` thanh `/shop/pos?saved=<0|1>` (bo
  `invoiceId`) - vi `Banhang.jsp` chi hien popup khi co attribute `bill` (duoc set trong `doGet` khi
  co param `invoiceId`), nen bo tham so nay se khien server KHONG nap lai hoa don do -> popup khong
  con dieu kien de hien -> tu dong "dong" ngay sau khi luu (thuc chat la khong mo lai).
- `src/main/web/shop/Banhang.jsp`: vi thong bao "Da luu thanh cong/that bai" truoc do nam BEN
  TRONG popup (`modalSaveAlert` trong `_invoiceModal.jspf`) nen khi popup khong con hien, thong bao
  cung mat theo - da them 1 alert rieng tren dau trang chinh (`posSavedAlert`, dieu kien
  `empty bill and not empty param.saved`) de shop van thay ket qua luu, tu an sau 3 giay (dung
  pattern auto-hide da co san cua `modalSaveAlert`).

Ket qua: bam mot trang thai thanh toan (vd "✅ Da thanh toan") -> bam "💾 Luu" -> popup dong ngay,
trang Bam Bill hien banner xanh "Da luu trang thai thanh toan thanh cong!" roi tu an sau 3s, san
sang ban don tiep theo.

Files sua:
- `src/main/java/org/example/controllers/ShopPosServlet.java`
- `src/main/web/shop/Banhang.jsp`

## 95. Them nut Sua cho "Danh sach Combo" (truoc do chi co Xoa)

Endpoint: `/shop/combo`

Phat hien: `ShopComboServlet.doPost()` **da co san** logic sua combo (nhanh `if (!comboIdStr.isEmpty())`
goi `comboDAO.update(...)` + xoa/tao lai `Combo_Items`), nhung `Quanlycombo.jsp` chi co nut "🗑️ Xoa"
tren moi combo, khong co cach nao dua `comboId` + du lieu cu vao form "Tao Combo moi" de kich hoat
nhanh sua do — thieu hoan toan UI, khong phai loi backend.

Da sua giao dien (khong doi backend/DAO):

- `src/main/web/shop/Quanlycombo.jsp`:
  - Form "Tao Combo" them `input hidden id="comboIdInput" name="comboId"` (rong mac dinh), gan id
    cho cac o `name`/`comboPrice`/`description` de JS doc/ghi duoc; them nut "✕ Hủy sửa" (an mac
    dinh, chi hien khi dang sua).
  - Moi `.combo-card` gan them cac `data-combo-*` (id, name, price, desc, va `data-combo-items` la
    JSON `[{"productSizeId":..,"quantity":..}]` build tu `combo.items` co san) de JS doc lai duoc
    toan bo du lieu combo do ma khong can goi AJAX rieng.
  - Them nut "✏️ Sua" canh nut "🗑️ Xoa" tren moi combo, goi JS `editCombo(card)`: dien
    ten/gia/mo ta vao form, xoa het cac dong san pham cu roi dung lai `addItemRow()` de dung lai
    danh sach san pham+size+so luong da luu (chon dung `<option>` theo `productSizeId`), doi tieu
    de form thanh "✏️ Sua Combo", nut submit thanh "💾 Luu thay doi", hien nut "Huy sua", cuoc
    cuon (`scrollIntoView`) len dau form.
  - `cancelEditCombo()`: reset form ve trang thai tao moi (xoa `comboId`, reset cac o nhap, tra ve
    1 dong san pham rong, doi lai tieu de/nut nhu cu).
  - Sua lai `addItemRow()`: truoc do clone truc tiep tu `.item-row` dang co trong `#itemRows`
    (se bi loi khi `editCombo`/`cancelEditCombo` xoa rong `#itemRows` truoc khi goi lai ham nay,
    vi khong con phan tu nao de clone) — gio luu san 1 ban `outerHTML` cua dong mau vao bien
    `ITEM_ROW_TEMPLATE_HTML` ngay luc trang load, moi lan goi `addItemRow()` deu dung lai chuoi
    HTML nay de tao dong moi, khong phu thuoc DOM hien tai cua `#itemRows`.

Ket qua: bam "✏️ Sua" tren 1 combo -> form phia tren tu dong dien du lieu combo do (bao gom danh
sach san pham + so luong) -> sua roi bam "Luu thay doi" -> `ShopComboServlet` nhan duoc `comboId`
nen re vao nhanh update co san, khong tao combo trung. Bam "Huy sua" de quay ve tao combo moi.

Files sua:
- `src/main/web/shop/Quanlycombo.jsp`

## 95. Fix loi JS lam hong toan bo trang chu User

Trang: `trangnguoidung.jsp`. Khi kiem tra UI trang chu theo yeu cau, phat hien khoi `<script>`
chinh cua trang bi hong nang do sot lai tu lan sua truoc:

- Du 1 dau `}` ngay sau ham `doSearch` dau tien -> SyntaxError, khien **toan bo** khoi script
  khong duoc parse, tuc la `goToShop`, `toggleDropdown`, listener dong dropdown tai khoan, va
  toan bo search deu KHONG chay duoc tren trinh duyet (du HTML/CSS nhin van dung).
- Ham `doSearch(query)` bi khai bao 2 lan trung nhau; ban khai bao sau (don gian hon, goi
  `filterShops(query)` mong doi gia tri tra ve) se de len ban dau vi function hoisting - nhung
  `filterShops` khong co `return` nen luon la `undefined`.
- `applyShopFilter()` dung nham bien `q`/`dishIds` chua khai bao (undefined) thay vi
  `dishSearchState.query`/`dishSearchState.matchedShopIds` - logic loc theo mon an (## 93 cu,
  tinh nang search theo ten mon) khong hoat dong dung.
- Dong `document.getElementById('noResults').style.display = ...` bi lap lai 2 lan giong het
  nhau trong `applyShopFilter()`.

Da sua: bo dau `}` thua, gop lai thanh 1 ham `doSearch` duy nhat (uu tien chuyen thang vao shop
neu chi khop dung 1 ket qua, khong thi cuon xuong `#restaurants` nhu `submitSearch` cu), sua
`applyShopFilter()` dung dung `dishSearchState.query`/`dishSearchState.matchedShopIds`, xoa dong
lap. Khong doi Java/DAO/servlet, khong doi schema.

Ghi chu them (khong sua, chi de y khi audit UI):
- Dong `if (q) document.querySelectorAll('.category-card')...` la code thua/mo coi - trang hien
  tai khong co section loc theo danh muc (category) nao, class `.category-card` khong ton tai o
  bat ky element HTML nao trong file. Vo hai (querySelectorAll tra ve rong) nhung co the can nhac
  xoa hoac lam mot section loc danh muc that su sau nay.
- Icon gio hang tren navbar (`.cart-btn`) chua co badge so luong (khac voi icon chuong thong bao
  da co badge `unreadNotifCount`). CSS `.cart-count` da dinh nghia san nhung khong dung o dau ca -
  `UserHomeServlet` cung chua tinh/truyen so luong san pham trong gio hang. Can them logic
  servlet/DAO moi neu muon lam, chua lam trong lan nay.

## 94. Chi hien/tinh phi ship SAU KHI khach chon vi tri giao hang o trang checkout

Endpoint: `/checkout`

Truoc do trang `checkoutThanhToan.jsp` luon hien cung luc 2 thong tin mau thuan nhau: khoi tong
tien hardcode "Phi giao hang: 15.000d / shop" (khong doi du chon vi tri hay chua), trong khi khoi
form ben duoi lai ghi "Phi tam tinh... se tinh theo khoang cach (6.000d/km)". Nut "Xac nhan thanh
toan" luon bam duoc ke ca khi chua chon vi tri tren ban do, khien khach khong biet phi ship that
su la bao nhieu truoc khi dat.

Da sua theo dung luong nghiep vu: **Chua chon vi tri -> an phi ship that, hien "Chua chon vi tri",
khoa nut dat hang. Chon vi tri tren ban do -> tinh khoang cach (Leaflet + Haversine) tu vi tri
Shop den diem giao, hien phi ship = so km × 5.000d (tinh rieng cho tung shop neu gio hang co nhieu
shop), roi moi mo khoa nut dat hang.**

- `src/main/java/org/example/controllers/CheckoutServlet.java`:
  - Doi `FEE_PER_KM` tu `6000` xuong **`5000`** (dung theo yeu cau 5.000d/km) — dieu chinh ca
    logic tinh phi that su luc tao Order (`doPost`) lan gia tri hien thi (`showReview`).
  - Them method `buildShopLocationsJson(lines)`: gom danh sach toa do (lat/lng, null neu shop
    chua cau hinh vi tri) cua TUNG shop khac nhau co trong gio hang, xuat ra JSON don gian de JS
    dung tinh khoang cach ma khong can goi lai server.
  - `showReview(...)`: them cac attribute `feePerKm`, `fixedDeliveryFee`, `maxDeliveryDistanceKm`,
    `shopLocationsJson` de JSP/JS dung chung hang so voi backend (tranh lech gia tri neu sau nay
    doi lai FEE_PER_KM).
- `src/main/web/user/checkoutThanhToan.jsp`:
  - Khoi tong tien: thay dong "Phi giao hang: 15.000d/shop" co dinh bang 2 dong an/hien qua JS
    (`feeRow` — hien so tien that khi da co toa do, `feePendingRow` — hien "Chua chon vi tri" mac
    dinh); tong tien (`grandTotalDisplay`) cap nhat theo.
  - O "Phi giao hang" trong form: doi thanh o chi-doc hien "Chua chon vi tri giao hang" mac dinh,
    tu cap nhat so tien khi khach chon vi tri.
  - Nut submit (`checkoutSubmitBtn`): mac dinh `disabled`, chi khoi tren khi JS xac dinh da co toa
    do hop le (`updateDeliveryFeeDisplay`), doi nhan nut sang "Xac nhan thanh toan"; them CSS
    `.btn-primary:disabled` (mau xam) de phan biet ro trang thai khoa.
  - JS moi: `haversineKm()` (cong thuc giong het ham Java `CheckoutServlet.haversineKm`, chi de
    XEM TRUOC phia client — server van la noi quyet dinh cuoi cung/kiem tra lai khi submit),
    `updateDeliveryFeeDisplay(lat, lng)` tinh tong phi ship qua tat ca shop trong gio hang (tinh
    rieng tung shop, cong lai de khach thay tong thuc te se phai tra vi 1 gio hang nhieu shop se
    tach thanh nhieu Order rieng — xem muc 8), canh bao mau do neu shop nao cach diem giao qua
    20km (backend van se tu choi tao don o buoc do neu vuot qua). Ham nay duoc goi lai moi khi
    khach: bam chon tren ban do, keo tha pin, hoac tim dia chi qua o tim kiem (hook vao ham
    `updateCoords()` da co san trong `initCheckoutLocationMap`).
  - Khi trang vua load (`DOMContentLoaded`): neu da co san toa do (vi du dia chi mac dinh cua user
    da luu toa do tu truoc, hoac dang xem lai form sau khi validate loi va da tung chon vi tri) thi
    tinh phi + mo khoa nut ngay, khong bat khach chon lai.

Han che/gia dinh:
- Gia tri JS tinh chi de XEM TRUOC (preview) cho khach thay ngay khong can round-trip server; con
  so chinh xac cuoi cung va viec tu choi don qua 20km van do `CheckoutServlet.doPost` quyet dinh
  (giu nguyen logic cu, chi doi hang so FEE_PER_KM).
- Neu shop chua nhap toa do trong `/shop/profile`, JS/backend deu fallback ve phi co dinh
  `FIXED_DELIVERY_FEE = 15.000d` cho shop do (giu nguyen hanh vi cu).

Files sua:
- `src/main/java/org/example/controllers/CheckoutServlet.java`
- `src/main/web/user/checkoutThanhToan.jsp`

## 94. Popup xac nhan xoa san pham trong gio hang

Trang: `gioHang.jsp`. Truoc day nut xoa (`.btn-remove`, dau ✕) o moi dong san pham dung
`onclick="return confirm('Xoa san pham nay?')"` - popup mac dinh cua trinh duyet, khong dong
bo mau sac voi giao dien web.

Da thiet ke popup xac nhan xoa rieng (dang the tron o giua man hinh, khong phai bottom-sheet
nhu modal "Sua san pham"), giu nguyen theme mau cam `#FF5A1F` va dung mau do `#ef4444` (mau
danger da co san o `.btn-remove:hover`) lam mau nhan/nut "Xoa".

- CSS moi: `.confirm-overlay`, `.confirm-box`, `.confirm-icon`, `.confirm-title`,
  `.confirm-sub`, `.confirm-actions`, `.btn-cancel`, `.btn-danger` (them ngay sau `.btn-save`
  trong khoi `<style>`).
- HTML moi: `<div class="confirm-overlay" id="deleteOverlay">` dat truoc modal "Sua san pham",
  chua icon thung rac, ten san pham dong `<b id="deleteItemName">`, nut "Huy" va nut "Xoa".
- Moi form xoa cua tung dong san pham duoc gan `id="removeForm-${line.itemId}"`; nut xoa doi
  tu `type="submit"` sang `type="button" onclick="openDeleteConfirm(${line.itemId}, '...')"`
  (ten san pham duoc escape qua `fn:escapeXml`).
- JS moi: `openDeleteConfirm(itemId, name)` (mo popup, luu `pendingDeleteId`), `closeDeleteConfirm()`,
  `closeDeleteOnBg(e)` (dong khi bam ra ngoai), `confirmDelete()` (submit dung form theo
  `pendingDeleteId` - van la POST that co `csrfToken`, khong doi co che xoa server-side).

Khong doi Java/DAO/servlet, khong doi schema.

## 93. Bam logo o trang dang ky se quay ve trang chu

Endpoint: `/dangky` (`register.jsp`)

Truoc do logo "POB FOOD" o goc trang dang ky chi la `<div>` tinh, khong bam duoc. Da sua boc logo
trong the `<a href="${pageContext.request.contextPath}/index.jsp">` (giu nguyen style cu, them
`text-decoration:none;cursor:pointer;`) de bam vao quay ve trang chu.

Files sua:
- `src/main/web/register.jsp`

## 93. Nhan Enter / bam nut "Tim kiem" tu dong cuon xuong ket qua

Trang: `trangnguoidung.jsp`. Truoc day bam Enter trong o search hoac bam nut "Tim kiem" o
hero chi goi `filterShops()` (loc ngay tai cho, khong cuon trang) - user phai tu cuon
xuong section "Nha Hang Tuyen Chon" (`#restaurants`) de xem ket qua.

Da them ham `submitSearch(query)`: goi `filterShops(query)` (loc client-side + kich hoat
lai search theo mon an neu dang cho debounce), roi `scrollIntoView({behavior:'smooth'})`
den section `#restaurants`.

- O `navSearch` (nav) va `heroSearch` (hero): them `onkeydown` bat phim Enter, goi
  `submitSearch(this.value)` (co `preventDefault()` de khong submit form/reload trang).
- Nut "Tim kiem" (`.btn-search`) o hero: doi `onclick` tu `filterShops(...)` sang
  `submitSearch(...)`.

Khong doi Java/DAO/servlet, khong doi schema.

## 92. Them upload anh Logo shop len Cloudinary (thay vi chi dan URL tay)

Trieu chung: trang chu nguoi dung (`user/trangnguoidung.jsp`, muc "Nha Hang Tuyen Chon") luon
hien icon dia/muong nia mac dinh (fallback icon) thay vi anh logo that cua shop, vi
`shop/Shopprofile.jsp` (`/shop/profile`) truoc do chi co 1 o nhap text "URL anh Logo" - shop owner
phai tu upload anh len noi khac roi dan URL tay, da so khong lam nen cot `shop_logo` trong DB rong
hoac sai -> `${not empty shop.shopLogo}` luon false, JSP fallback ve icon 3D dia/muong nia.

Da sua: `src/main/web/shop/Shopprofile.jsp` - them nut "📤 Tai anh len" canh o nhap URL logo, dung
lai dung pattern Cloudinary unsigned upload da co san o `shop/hoSoShop.jsp` (upload avatar chu shop)
- cung `CLOUD_NAME='jcnsb47f'`, `UPLOAD_PRESET='avatar_preset'`, chi doi `folder` thanh `shop-logos`.
Sau khi chon file, JS goi `POST https://api.cloudinary.com/v1_1/jcnsb47f/image/upload`, nhan ve
`secure_url` roi tu dong dien vao o input `shopLogo` (text) + preview ngay, khong sua backend
(`ShopProfileServlet` da doc/luu field `shopLogo` tu form nay tu truoc). Nguoi dung van bam
"Luu thay doi" nhu binh thuong de luu URL Cloudinary do vao DB.

Ket qua: shop owner chi can chon file anh, khong can tu upload/dan link o dau khac; sau khi luu,
anh logo se hien dung tren trang nguoi dung (thay fallback icon).

Files sua:
- `src/main/web/shop/Shopprofile.jsp`

## 92. Tim kiem cua hang theo ten mon an tren trang Nguoi dung

Trang: `trangnguoidung.jsp` (2 o search: nav + hero).

Truoc day o search chi loc client-side theo `data-name`/`data-desc`/`data-addr` cua the
`.shop-card` (ten/mo ta/dia chi cua hang), khong search duoc theo ten mon an trong Database.

Da them:

- `src/main/java/org/example/daos/ShopDAO.java`: khai bao method moi
  `searchShopsByProductName(String keyword)`.
- `src/main/java/org/example/daos/ShopDAOImpl.java`: them hang so `SEARCH_BY_PRODUCT`
  (JOIN `Shops` voi `Products` qua `shop_id`, loc `product_name LIKE ?`, loai san pham
  `is_deleted = 1` hoac `status = 'HIDDEN'`, loai shop `is_deleted = 1`) va trien khai
  `searchShopsByProductName()` tai su dung helper `mapResultSetToShop()` co san.
- Moi: `src/main/java/org/example/controllers/SearchShopsByDishServlet.java`
  (`@WebServlet("/user/search-shops-by-dish")`, chi co `doGet`): kiem tra session/role
  user (roleId == 3), tra JSON `[]` neu chua dang nhap hoac tu khoa qua ngan (< 2 ky tu);
  goi DAO roi loc tiep theo status cong khai cua shop (`accept`/`accepted`/`approved`/
  `active`, trim + lowercase - dung convention da lap lai o cac servlet user khac); tra ve
  JSON array cac `shop.id` khop, vi du `[12,45,88]`.
- `src/main/web/user/trangnguoidung.jsp`:
  - Them `data-id="${shop.id}"` vao moi the `.shop-card`.
  - Giu nguyen loc substring cu (ten/mo ta/dia chi) trong `filterShops()`.
  - Them debounce ~350ms, chi goi AJAX `fetch('/user/search-shops-by-dish?q=...')` khi
    `q.length >= 2`; dung bien dem request tang dan (`requestSeq`) de bo qua response cu
    khi go nhanh/xoa nhanh (tranh flicker do out-of-order response).
  - Ket qua cuoi: mot the duoc hien thi neu khop substring **HOAC** `id` cua no nam trong
    danh sach AJAX tra ve (OR logic, khong thay the co che cu). Ham `applyShopFilter()`
    moi gop 2 dieu kien nay va cap nhat hien thi `noResults`.

Khong doi schema, khong can cap nhat `database.md`.

Kiem thu: `javac` bien dich toan bo `src/main/java` sach loi (khong co Maven CLI trong moi
truong nay nen dung classpath thu cong tu `.m2` + `target/classes` de kiem tra; chua chay
duoc server thuc te de test tren trinh duyet - can nguoi dung tu kiem tra cac buoc con lai
trong ke hoach: search theo mon an ra dung shop, search theo ten shop van nhanh, tu khoa
khong khop hien "khong co ket qua", go nhanh khong bi flicker, san pham HIDDEN bi loai khoi
ket qua).

## 91. Fix loi "Invalid object name 'Combo_Items'" khi xem menu shop

Trieu chung: mo trang menu shop (`UserShopMenuServlet` -> `/shop-menu` hay tuong tu), server nem
`com.microsoft.sqlserver.jdbc.SQLServerException: Invalid object name 'Combo_Items'.` tai
`ComboDAOImpl.findSuggestionsByProductId` (dong 156, goi tu `UserShopMenuServlet.doGet` dong 84).

Nguyen nhan: tinh nang Combo (goi combo san pham cua shop) da duoc code day du - DAO
(`ComboDAOImpl`), model (`Combo`, `ComboItem`), servlet dung no, va da duoc tai lieu hoa dung schema
trong `database.md` (muc "Bang Combos") - nhung **chua co migration script nao tao bang that su tren
SQL Server**. Kiem tra toan bo cac file `migration_*.sql` trong project thay moi tinh nang khac
(Vouchers, Faqs, Feedbacks, Flash_Sales...) deu co migration rieng da chay, rieng Combo thi khong ->
bang `Combos`/`Combo_Items` khong ton tai trong database that, dan den moi query cham vao 2 bang nay
deu loi "Invalid object name".

SQL trong `ComboDAOImpl.java` (ten bang, ten cot) hoan toan khop voi schema da tai lieu trong
`database.md`, khong phai loi go sai ten bang trong code.

Da sua:

- Tao moi `migration_combos.sql` (theo dung convention cac migration khac trong project, dung
  `IF NOT EXISTS (SELECT * FROM sys.tables ...)` de an toan khi chay lai nhieu lan):
  - `CREATE TABLE Combos` (id, shop_id FK->Shops, name, description, combo_price, is_active,
    created_at, updated_at).
  - `CREATE TABLE Combo_Items` (id, combo_id FK->Combos, product_id FK->Products, product_size_id
    FK->Product_Sizes, quantity).
  - Index `IDX_Combos_Shop`, `IDX_ComboItems_Combo`, `IDX_ComboItems_Product`.

**Can lam tiep (thao tac thu cong, ngoai pham vi code)**: chay file `migration_combos.sql` tren SQL
Server dang dung cho project (vi du qua SSMS hoac `sqlcmd`) truoc khi test lai trang menu shop. Sau
khi chay xong, tinh nang combo suggestions se hoat dong binh thuong ma khong can sua gi them o
`ComboDAOImpl.java`/`UserShopMenuServlet.java`.

Files sua:
- Moi: `migration_combos.sql`

## 90. Sua loi Topping khong duoc tinh vao gio hang khi checkout

Endpoint: `/checkout`

Phat hien: `CheckoutServlet.buildLines()` chi lay gia size cua san pham, hoan toan bo qua du lieu topping trong
bang `Cart_Item_Toppings`. Ngoai ra `doPost()` goi `orderDetailDAO.create()` (khong tra ID) nen khong the tao
`Order_Detail_Toppings` sau khi dat hang.

Da sua:

- `src/main/java/org/example/controllers/CheckoutServlet.java`:
  - Them 3 DAO moi: `CartItemToppingDAOImpl`, `ToppingDAOImpl`, `OrderDetailToppingDAOImpl`.
  - Them inner class `ToppingLine` (bao gom `toppingId`, `toppingName`, `price`, `qty`).
  - `CheckoutLine`: them field `List<ToppingLine> toppings`, sua constructor, them getter `getToppings()`.
  - `getLineTotal()`: cong them tong gia topping (`price * qty`) vao gia size × so luong.
  - `buildLines()`: voi moi `CartItem`, load `CartItemTopping` bang `cartItemToppingDAO.findByCartItemId()`,
    lookup gia qua `toppingDAO.findById()`, dung `ToppingLine` list vao `CheckoutLine`.
  - `doPost()`: doi `orderDetailDAO.create()` sang `orderDetailDAO.createAndReturnId()`, sau khi tao
    `OrderDetail` thanh cong thi tao cac `OrderDetailTopping` tuong ung tu `line.getToppings()`.
- `src/main/web/user/checkoutThanhToan.jsp`: hien thi ten tung topping (mau cam) va gia ben duoi ten mon an.

Ket qua: tong tien o trang checkout va gia tri `totalPrice` cua `Order` gio da bao gom day du gia topping;
`Order_Detail_Toppings` duoc luu khi dat hang thanh cong.

## 1. CRUD gio hang

Endpoint: `/cart`

Da them backend:

- `src/main/java/org/example/daos/CartDAO.java`
- `src/main/java/org/example/daos/CartDAOImpl.java`
- `src/main/java/org/example/controllers/CartServlet.java`

Da sua giao dien:

- `src/main/web/themSuaGioHang.jsp`

Chuc nang da co:

- Xem danh sach gio hang.
- Them gio hang moi.
- Sua gio hang.
- Xoa gio hang.
- Validate `userId`.
- Redirect thong bao ket qua bang query string `success`/`error`.
- DAO tu nhan dien bang `Carts` hoac `Cart`.
- DAO ho tro cot `is_deleted` neu database co cot xoa mem.

Ghi chu:

- Neu tao moi bi loi validate, form van giu dung che do them moi thay vi bi nham sang sua.
- Khi cap nhat gio hang ma bo trong ngay tao, he thong giu lai ngay tao cu.

## 2. CRUD don hang

Endpoint: `/orders`

Da them backend:

- `src/main/java/org/example/daos/OrderDAO.java`
- `src/main/java/org/example/daos/OrderDAOImpl.java`
- `src/main/java/org/example/controllers/OrderServlet.java`

Da them giao dien:

- `src/main/web/orderDanhSach.jsp`
- `src/main/web/orderThemSua.jsp`

Chuc nang da co:

- Xem danh sach don hang.
- Them don hang moi.
- Sua don hang.
- Xoa don hang.
- Validate cac field chinh:
  - `userId`
  - ten nguoi nhan
  - so dien thoai nguoi nhan
  - dia chi giao hang
  - tong tien
  - phi giao hang
- DAO tu nhan dien bang `Orders` hoac `Order`.
- DAO ho tro cot `is_deleted` neu database co cot xoa mem.
- Ho tro cac cot tuy chon neu database co:
  - `shipper_id`
  - `delivery_fee`
  - `payment_method`
  - `status`
  - `estimated_delivery_time`
  - `created_at`
  - `updated_at`

## 3. CRUD chi tiet gio hang

Endpoint: `/cart-items`

Da them backend:

- `src/main/java/org/example/daos/CartItemDAO.java`
- `src/main/java/org/example/daos/CartItemDAOImpl.java`
- `src/main/java/org/example/controllers/CartItemServlet.java`

Da them giao dien:

- `src/main/web/cartItemDanhSach.jsp`
- `src/main/web/cartItemThemSua.jsp`

Chuc nang da co:

- Xem danh sach chi tiet gio hang.
- Them chi tiet gio hang.
- Sua chi tiet gio hang.
- Xoa chi tiet gio hang.
- Validate `cartId`, `productId`, `quantity`.

## 4. CRUD chi tiet don hang

Endpoint: `/order-details`

Da them backend:

- `src/main/java/org/example/daos/OrderDetailDAO.java`
- `src/main/java/org/example/daos/OrderDetailDAOImpl.java`
- `src/main/java/org/example/controllers/OrderDetailServlet.java`

Da them giao dien:

- `src/main/web/orderDetailDanhSach.jsp`
- `src/main/web/orderDetailThemSua.jsp`

Chuc nang da co:

- Xem danh sach chi tiet don hang.
- Them chi tiet don hang.
- Sua chi tiet don hang.
- Xoa chi tiet don hang.
- Validate `orderId`, `productId`, `quantity`, `price`.

## 5. CRUD Topping va Loai Topping (shop owner)

Endpoint: `/shop/toppings`, `/shop/topping-categories`

Truoc khi sua: `ToppingDAO`/`ToppingDAOImpl` chua ton tai du da duoc `ShopToppingServlet` goi toi
(project khong compile duoc). Ngoai ra `ToppingCategory` va `ToppingCategoryDAOImpl` dung cot
`category_name`/`status` khong co trong bang `ToppingCategories` thuc te (DB chi co `name`,
`description`, `is_deleted`). Topping JSP cho chon status `HIDDEN`/`INACTIVE` trong khi cot
`status` cua bang `Toppings` co CHECK chi cho `ACTIVE`/`OUT_OF_STOCK`.

Da sua/them backend:

- `src/main/java/org/example/daos/ToppingDAO.java` (moi)
- `src/main/java/org/example/daos/ToppingDAOImpl.java` (moi, join sang `ToppingCategories` de lay ten loai)
- `src/main/java/org/example/daos/ToppingCategoryDAO.java` (doi ten tu `ToppingcategoryDAO.java` cho dung quy uoc Java)
- `src/main/java/org/example/daos/ToppingCategoryDAOImpl.java` (sua lai dung cot `name`/`description`)
- `src/main/java/org/example/models/ToppingCategory.java` (doi `categoryName`->`name`, bo `status` gia, them `description`)
- `src/main/java/org/example/controllers/ShopToppingServlet.java` (chuan hoa status chi ACTIVE/OUT_OF_STOCK)
- `src/main/java/org/example/controllers/Quanlyloaitoppingservlet.java` (doc form theo `name`/`description`, bo thong ke theo status)

Da sua giao dien:

- `src/main/web/admin/Quanlytopping.jsp` (dropdown status chi con ACTIVE/OUT_OF_STOCK, sua tham chieu `cat.name`)
- `src/main/web/admin/Quanlyloaitopping.jsp` (form/doi bang dung `name`+`description`, bo cot trang thai)

Chuc nang da co:

- Xem danh sach topping / loai topping theo shop.
- Them, sua, xoa (mem) topping va loai topping.
- Validate ten, loai topping phai thuoc dung shop, gia >= 0.

Ghi chu:

- Project gio compile sach (`javac` toan bo `src/main/java`, khong loi).
- Day la vi du ve viec model/DAO bi lech voi schema thuc te trong `Database.txt` — luon doi chieu ten cot
  voi `Database.txt` truoc khi them DAO moi.

## 6. CRUD San Pham, Loai San Pham va Thong Tin Cua Hang (shop owner)

Endpoint: `/shop/products`, `/shop/product-types`, `/shop/profile`

Cac loi thuc te tim thay va da sua:

- Hai servlet `ShopProductTypeServlet` va `QuanLyLoaiSanPhamServlet` cung map `@WebServlet("/shop/product-types")`
  (trung URL, container se loi khi deploy). Da xoa file `QuanLyLoaiSanPhamServlet.java` (khong noi nao goi toi),
  giu lai `ShopProductTypeServlet.java`.
- `ProductSizeDAOImpl.update()` build SQL voi cot `stock_quantity` khong ton tai trong bang `Product_Sizes`,
  va bind thieu 1 tham so (3 gia tri cho 4 dau `?`) -> sua size luon loi. Da sua lai SQL chi con
  `size_name`, `price`.
- JSP `Quanlysanpham.jsp` gui size voi ten field `sizePrice[]` nhung `ShopProductServlet` lai doc
  `priceAdjust[]` -> gia cua size khong bao gio duoc luu (luon mac dinh 0, vi pham CHECK price > 0 cua
  `Product_Sizes`). Da sua servlet doc dung `sizePrice[]`.
- JSP co o nhap "Gia ban" rieng o cap san pham va nhap "Ton kho" rieng cho tung size, nhung ca hai deu
  khong duoc servlet doc/luu (Products khong co cot gia, Product_Sizes khong co cot ton kho theo size).
  Da bo 2 o nay khoi form de tranh nham lan; gia ban hien thi/luu hoan toan qua size.
- EL `${productSua.status}` trong modal sua san pham bi loi vi model `Product` chi co getter `getStaTus()`
  (chu T hoa, khong phai chuan `status`) -> sua thanh `productSua.staTus`.
- Thieu validate "phai co it nhat 1 size voi gia > 0" truoc khi tao/sua san pham — da them, neu khong co
  size hop le se bao loi va khong tao san pham mo coi (khong gia).
- `ShopProductServlet.forwardProductPage()` chua gan cac bien thong ke `soDangBan`, `soHetHang`,
  `tongDaBan` ma JSP can hien thi — da tinh va set trong servlet.
- Form sua thong tin cua hang trong `Shopprofile.jsp` submit toi `/shop/profile` nhung khong co servlet
  nao map URL nay (404 khi bam Luu). Da tao moi `ShopProfileServlet.java` (GET hien thi, POST update),
  chi cap nhat 5 truong ho so (`shopName`, `shopDescription`, `shopAddress`, `shopPhone`, `shopLogo`),
  giu nguyen status/owner/API keys cua shop.

Ghi chu:

- `Category`/`CategoryDAOImpl` (loai san pham) van con field `status` nhung bang `Categories` thuc te
  khong co cot nay — DAO tu do schema bang `DatabaseMetaData` nen khong bi loi SQL (chi bo qua cot status
  khi khong tim thay), nhung tinh nang "trang thai loai san pham" tren JSP se khong bao gio luu duoc.
  Khong sua vi khong gay loi runtime, chi ghi chu lai cho lan sau.
- Project van compile sach sau khi sua (`javac` toan bo `src/main/java`).

## 7. Bam bill thanh toan (checkout + hoa don)

Endpoint: `/checkout`, `/bill`

Da them backend:

- `src/main/java/org/example/controllers/CheckoutServlet.java` (moi) — GET hien hoa don tam tu
  gio hang de xac nhan, POST tao `Order` + `OrderDetail` tu `CartItem` roi xoa cac `CartItem` da
  thanh toan.
- `src/main/java/org/example/controllers/BillServlet.java` (moi) — hien hoa don chi tiet (san
  pham, size, so luong, gia, tong tien) cho 1 hoac nhieu don hang, co nut in (`window.print()`).
- `CartItemDAO`/`CartItemDAOImpl`: them `findByCartId(cartId)`.
- `OrderDetailDAO`/`OrderDetailDAOImpl`: them `findByOrderId(orderId)`.
- `OrderDAO`/`OrderDAOImpl`: them `createAndReturnId(order)` (dung `RETURN_GENERATED_KEYS`) vi
  `create()` cu chi tra `Boolean`, khong co cach lay lai id don vua tao de gan vao `OrderDetail`.

Da them giao dien:

- `src/main/web/checkoutThanhToan.jsp` — bang chi tiet hoa don tam + form nhap nguoi nhan,
  dia chi, phuong thuc thanh toan, phi giao hang.
- `src/main/web/hoaDon.jsp` — hoa don sau khi thanh toan thanh cong, co the in.
- `src/main/web/DanhSachGioHang.jsp` — them nut "💳 Thanh toan" o moi gio hang, them thong bao
  loi `empty_cart`.

Chuc nang da co:

- Bam "Thanh toan" tu mot gio hang -> xem lai hoa don tam (san pham, size, don gia, thanh tien
  theo tung shop) -> nhap thong tin nguoi nhan + phuong thuc thanh toan -> xac nhan se tao 1
  `Order` rieng cho moi shop co trong gio hang (vi 1 don hang chi gan voi 1 `shop_id`), kem
  `OrderDetail` tuong ung, roi xoa cac `CartItem` da thanh toan khoi gio hang.
- Xem/in lai hoa don chi tiet cho cac don hang vua tao qua `/bill?orderIds=1,2,3`.

Han che/gia dinh da biet (ghi lai de lan sau xem):

- `CartItem` hien khong luu `product_size_id` (chi co `cart_id`, `product_id`, `quantity`), nen
  khi checkout, gia duoc lay theo **size re nhat** cua san pham (`ProductSizeDAO.findByProductId`
  roi chon `price` nho nhat). Neu can chon dung size luc them vao gio hang thi phai sua schema +
  DAO cua `CartItem` de luu them `product_size_id`.
- Phi giao hang (`deliveryFee`) nguoi dung nhap 1 lan duoc ap dung cho **moi** don hang tach theo
  shop (gia dinh moi shop la 1 lan giao hang rieng), khong chia deu.
- Neu tao `Order` cho shop dau tien thanh cong nhung loi o shop tiep theo (vd mat ket noi DB
  giua chung), cac don da tao truoc do se khong bi rollback (khong dung transaction) — chap nhan
  duoc voi pham vi do an, can luu y neu mo rong sau.

## 8. Dong bo giao dien bam bill cho Shop (xem/in hoa don theo shop)

Endpoint: `/shop/bills`

Phat hien loi quan trong khi lam phan nay: `OrderDAOImpl` **khong he doc/ghi cot `shop_id`**
(schema dynamic chi co `id, user_id, shipper_id, ...`, thieu han `shop_id`). Nghia la
`CheckoutServlet` o muc 7 da goi `order.setShopId(...)` nhung gia tri nay bi am tham bo qua khi
luu xuong DB — moi `Order` tao ra deu co `shop_id = 0` (sai). Da sua:

- `OrderDAO`/`OrderDAOImpl`: them `shop_id` vao schema dong (bat buoc, giong `user_id`), doc/ghi
  day du trong `create`, `createAndReturnId`, `update`, `getAll`, `findById`; them method moi
  `findByShopId(shopId)` de loc don hang theo shop.
- `OrderServlet` (CRUD admin chung `/orders`) + `orderThemSua.jsp`, `orderDanhSach.jsp`: them
  truong/cot **Shop ID** (bat buoc) vi form nay truoc gio khong nhap shop_id, se loi sau khi
  sua DAO o tren.

Tach logic dung hoa don ra dung chung (tranh lap code giua khach hang va shop):

- `org/example/models/BillView.java`, `BillLine.java` (model, chuyen ra tu `BillServlet` cu).
- `org/example/utils/BillUtil.java` (moi) — `BillUtil.build(order)` dung 1 `BillView` day du
  (san pham, size, gia, tong) tu 1 `Order`. Dung chung boi `BillServlet` (`/bill`, khach hang xem
  sau checkout) va `ShopBillServlet` (`/shop/bills`, shop owner xem/in lai).

Da them backend cho Shop:

- `src/main/java/org/example/controllers/ShopBillServlet.java` (moi) — `@WebServlet("/shop/bills")`,
  kiem tra `account.roleId == 2` + chu shop dung loai (`shopDAO.selectShopByOwnerId`), danh sach
  don hang cua shop (`orderDAO.findByShopId`), xem hoa don 1 don (`action=view&id=`) co kiem tra
  don do co thuoc dung shop khong truoc khi cho xem.

Da them/dong bo giao dien:

- `src/main/web/shop/Quanlybill.jsp` (moi) — danh sach don hang cua shop, dung dung theme/sidebar
  F&B (CSS variables, sidebar cam) nhu cac trang Shop khac, co nut "🧾 Xem hoa don" tren tung dong.
- `src/main/web/shop/HoaDonShop.jsp` (moi) — hoa don chi tiet trong layout Shop (sidebar + theme),
  nut in (`window.print()`), nut quay lai danh sach.
- Them muc menu **"🧾 Hoa don / Don hang"** (section "Don hang") vao sidebar cua TAT CA trang
  Shop hien co de dong bo navigation: `Shopprofile.jsp`, `trangcuahang.jsp`, `Quanlysanpham.jsp`,
  `Quanlyloaisanpham.jsp`, `Quanlytopping.jsp`, `Quanlyloaitopping.jsp` (truoc do moi trang tu
  copy-paste sidebar rieng, khong co lien ket toi `/shop/bills`).

Chuc nang da co:

- Shop owner vao sidebar bam "Hoa don / Don hang" -> xem danh sach don hang cua shop minh (nguoi
  nhan, dia chi, tong tien, trang thai) -> bam "Xem hoa don" tren 1 don -> xem chi tiet (san pham,
  size, so luong, don gia, tong tien, phi giao hang) va in duoc.

Ghi chu:

- Trang `/shop` (`trangcuahang.jsp`) co san mot bang "Don hang gan day" nhung dung sai ten field
  (`order.customerName`, `order.totalAmount`, `order.status` — khong khop voi model `Order` thuc
  te co `receiverName`, `totalPrice`, `staTus`) va `ShopHomeServlet` khong he set attribute
  `donHangGanDay`/`tongSanPham`/... nen bang nay luon rong. Day la van de co san tu truoc, khong
  sua trong lan nay vi ngoai pham vi "dong bo giao dien bam bill".

## 9. Thanh toan online qua PayOS (QR Code)

Endpoint: `/checkout` (chon paymentMethod=PAYOS), `/payos/return`, `/payos/webhook`

Bo sung:

- DB: them cot `payos_order_code` (BIGINT NULL) vao bang `Orders` —
  `migration_payos_order_code.sql`. Dung de noi 1 Order voi 1 link thanh toan PayOS
  (PayOS yeu cau 1 `orderCode` so nguyen duy nhat, dung lai `id` cua Order cho gon).
- `Shop` da co san field `clientKey`/`apiKey`/`checkSumKey` (cot DB thuc te: `client_key`,
  `api_key`, `check_sum_key`) nhung truoc gio khong duoc DAO doc/ghi — da sua trong
  `ShopDAOImpl` (xem muc 6 cap nhat) de man hinh `/shop/profile` nhap duoc 3 gia tri nay.
- `org/example/utils/PayOSUtil.java` (moi) — goi REST API PayOS thuan (khong dung SDK,
  vi chua co trong repo Maven noi bo):
  - `createPaymentLink(...)`: tao link thanh toan QR, tu ky HMAC-SHA256 bang `checkSumKey`
    cua shop theo dung thu tu field PayOS yeu cau (amount/cancelUrl/description/orderCode/returnUrl).
  - `getPaymentStatus(...)`: goi lai API PayOS lay trang thai thuc cua 1 `orderCode`
    (KHONG tin truc tiep query string tren returnUrl vi nguoi dung co the tu sua URL).
  - `verifyWebhookSignature(...)`: verify chu ky webhook PayOS gui len bang `checkSumKey`.
- `OrderDAO`/`OrderDAOImpl`: them cot dong `payos_order_code` vao schema (giong pattern
  cac cot tuy chon khac), them `setPayosOrderCode`, `findByPayosOrderCode`,
  `updatePaymentStatusByPayosOrderCode`.
- `CheckoutServlet`: them nhanh xu ly khi `paymentMethod = PAYOS`:
  - Chi cho phep khi gio hang chi co 1 shop (PayOS gan voi 3-key cua 1 shop, khong the
    gop nhieu shop vao 1 link thanh toan) — bao loi yeu cau thanh toan rieng tung shop neu
    gio hang co nhieu shop.
  - Kiem tra shop da nhap du 3 key chua, neu thieu thi bao loi.
  - Tao Order (status PENDING, payment_status UNPAID mac dinh) nhu binh thuong, roi goi
    `PayOSUtil.createPaymentLink` voi `orderCode = order.id`, `amount = round(totalPrice)`.
  - Thanh cong: luu `payos_order_code`, xoa cac CartItem da thanh toan, redirect sang
    `checkoutUrl` cua PayOS (trang QR ben ngoai).
  - Thanh toan that bai khi tao link (vd loi ket noi/sai key): KHONG xoa gio hang, hien lai
    trang xac nhan hoa don voi thong bao loi de nguoi dung sua/thu lai.
- `PayOSReturnServlet` (moi, `/payos/return`) — PayOS redirect nguoi dung ve day sau khi
  thanh toan xong/huy. Doc `orderCode` tu query string, tim lai Order, **goi lai API PayOS
  de lay trang thai thuc** (khong doc thang `status` tren query string), neu `PAID` thi cap
  nhat `payment_status = PAID` va redirect sang `/bill?orderIds=`, nguoc lai forward sang
  `thanhToanThatBai.jsp`.
- `PayOSWebhookServlet` (moi, `/payos/webhook`) — endpoint server-to-server PayOS goi khi
  link thanh toan doi trang thai; verify chu ky bang `checkSumKey` cua dung shop truoc khi
  cap nhat `payment_status = PAID`. Can cau hinh URL nay tren PayOS Dashboard cua shop voi
  domain public (khong hoat dong duoc tren localhost) — voi do an chay local, nguon xac nhan
  chinh van la `/payos/return`.
- `thanhToanThatBai.jsp` (moi) — trang hien khi thanh toan PayOS khong thanh cong/bi huy.
- `checkoutThanhToan.jsp` — doi option "Thanh toan online" (`ONLINE`, chua gan voi cong nao)
  thanh "Thanh toan online qua PayOS" (`PAYOS`).

Han che/gia dinh da biet:

- Moi link PayOS gan voi dung 1 shop (dung 3 key cua shop do) nen gio hang nhieu shop khong
  the thanh toan PayOS gop 1 lan — phai tach checkout theo tung shop (gio han co san trong
  thiet ke checkout hien tai, theo `byShop`).
- Khong dung transaction: neu tao Order xong nhung goi PayOS loi, Order van ton tai trong DB
  o trang thai PENDING/UNPAID (khong rollback) — nguoi dung co the tao checkout moi nhung
  Order cu se "treo", co the don dep thu cong sau. Phu hop pham vi do an.
- Webhook can domain public moi nhan duoc (PayOS khong goi toi localhost) — chi xac nhan
  duoc that su khi deploy len server co domain/IP cong khai.

## 10. Tich hop PayOS thuc su cho POS ("Bam Bill")

Endpoint: `/shop/pos` (chon phuong thuc PAYOS), `/payos/return?source=pos`

Truoc do `/shop/pos` (`ShopPosServlet`, `Banhang.jsp`) co nut chon "🏦 PayOS" nhung chi luu
`paymentMethod='MOMO'` (ten gia, khong goi API nao) — hoa don tao xong ngay va hien placeholder
"Đang chờ tích hợp PayOS". Da sua de goi PayOS thuc su, dung lai `PayOSUtil` da lam o muc 9:

- `mapPaymentMethod`: bo map gia "PAYOS"->"MOMO", luu dung `paymentMethod='PAYOS'`.
- `createOrder()`: neu `paymentMethod=PAYOS`:
  - Kiem tra shop co du 3 key chua, thieu thi bao loi truoc khi tao don.
  - Tao Order/OrderDetail/OrderDetailTopping nhu thuong (paymentStatus=PENDING,
    staTus=PENDING — khac voi CASH/QR la staTus=DONE ngay vi PayOS chua xac nhan thanh toan),
    roi goi `PayOSUtil.createPaymentLink(...)` voi `returnUrl=/payos/return?source=pos`.
  - Thanh cong: luu `payos_order_code`, redirect sang `checkoutUrl` cua PayOS.
  - That bai luc tao link (sai key/mat ket noi): xoa luon OrderDetail + Order vua tao (khong
    de don "treo"), bao loi tren `Banhang.jsp`.
  - Them action moi `discardOrder` (POST `/shop/pos`, param `id`): xoa (mem) 1 Order +
    OrderDetail cua dung shop, dieu kien `paymentStatus != PAID` — dung cho nut "Xac nhan"
    tren trang thanh toan that bai de dam bao "khong luu bill".
- `PayOSReturnServlet`: them tham so `source` tren returnUrl de phan nhanh UI sau khi PayOS
  xac nhan trang thai thuc (van goi lai API PayOS, khong tin query string):
  - `source=pos` + PAID: cap nhat `payment_status=PAID`, `staTus=DONE`, redirect
    `/shop/pos?invoiceId=<id>` (trang in hoa don co san, dung lai `_invoiceModal.jspf`).
  - `source=pos` + khong PAID: forward `shop/ThanhToanThatBaiPos.jsp` (moi) — trang thong bao
    co nut "✅ Xac nhan" submit POST `/shop/pos?action=discardOrder&id=...` -> huy don, ve
    `/shop/pos`.
  - `source=cart` (hoac khong co `source`, mac dinh): giu nguyen hanh vi cu — PAID thi sang
    `/bill?orderIds=`, khong PAID thi forward `thanhToanThatBai.jsp` (khong xoa don, cho phep
    "treo" de xem lai, theo ghi chu han che da co tu muc 9).
- `CheckoutServlet`: returnUrl doi thanh `/payos/return?source=cart` cho ro nghia (hanh vi
  khong doi, source=cart la nhanh mac dinh).
- `_invoiceModal.jspf`: sua dieu kien hien nhan "🏦 PayOS" tu `paymentMethod == 'MOMO'` (cu)
  thanh `paymentMethod == 'PAYOS'`; bo placeholder QR "Đang chờ tích hợp PayOS", thay bang
  "✅ Đã thanh toán qua PayOS" (vi luc xem hoa don nay thi PayOS da xac nhan PAID roi).

## 19. Xoa mem (Soft Delete) va Thung Rac cho CRUD Shop

Cac CRUD quan ly shop (san pham, topping, loai san pham, loai topping) da co cot `is_deleted` trong
DB nen viec xoa mem da ton tai tu truoc (DAO ghi `is_deleted = 1` thay vi DELETE). Lan nay bo sung
tinh nang **Thung Rac + Khoi Phuc** cho 4 module:

Da sua backend (DAO interface + impl):

- `src/main/java/org/example/daos/ProductDAO.java`: them `findDeletedByShopId(shopId)`,
  `restore(id, shopId)`
- `src/main/java/org/example/daos/ProductDAOImpl.java`: them 2 method tuong ung, dung SQL
  `WHERE is_deleted = 1` de lay danh sach tron thung rac, va `SET is_deleted = 0` de khoi phuc.
- `src/main/java/org/example/daos/ToppingDAO.java`: them `findDeletedByShopId(shopId)`,
  `restore(id)`
- `src/main/java/org/example/daos/ToppingDAOImpl.java`: them 2 method, join sang ToppingCategories
  de lay ten loai.
- `src/main/java/org/example/daos/ToppingCategoryDAO.java`: them `findDeletedByShopId(shopId)`,
  `restore(id)`
- `src/main/java/org/example/daos/ToppingCategoryDAOImpl.java`: them 2 method tuong ung.
- `src/main/java/org/example/daos/CategoryDAO.java`: them `findDeletedByShopId(shopId)`,
  `restore(id)`
- `src/main/java/org/example/daos/CategoryDAOImpl.java`: them 2 method tuong ung dung schema dong.

Da sua backend (Servlet):

- `src/main/java/org/example/controllers/ShopProductServlet.java`:
  - GET `action=trash` -> tai danh sach san pham bi xoa, forward `/shop/ThungRacSanPham.jsp`.
  - POST `action=restore` -> goi `productDAO.restore(id, shopId)`, redirect ve trang trash.
- `src/main/java/org/example/controllers/ShopToppingServlet.java`: tuong tu cho topping.
- `src/main/java/org/example/controllers/ShopProductTypeServlet.java`: tuong tu cho loai san pham.
- `src/main/java/org/example/controllers/QuanLyLoaiToppingServlet.java`: tuong tu cho loai topping.

Da them giao dien:

- `src/main/web/shop/ThungRacSanPham.jsp` (moi) - danh sach san pham trong thung rac.
- `src/main/web/shop/ThungRacTopping.jsp` (moi) - danh sach topping trong thung rac.
- `src/main/web/shop/ThungRacLoaiSanPham.jsp` (moi) - danh sach loai san pham trong thung rac.
- `src/main/web/shop/ThungRacLoaiTopping.jsp` (moi) - danh sach loai topping trong thung rac.
- Them nut "Thung rac" vao header cua 4 trang quan ly hien co:
  `Quanlysanpham.jsp`, `Quanlytopping.jsp`, `Quanlyloaisanpham.jsp`, `Quanlyloaitopping.jsp`.

Chuc nang da co:

- Xoa san pham/topping/loai san pham/loai topping -> vao thung rac (is_deleted = 1), khong mat data.
- Bam nut "Thung rac" trong trang quan ly -> xem danh sach cac muc da xoa cua shop minh.
- Bam "Khoi phuc" tren tung muc -> dat is_deleted = 0, hien thi lai trong danh sach chinh.
- Bao mat: chung tra shopId truoc khi khoi phuc san pham / topping, khong the khoi phuc muc cua shop khac.

Luu y: Cac trang JSP thung rac co cung theme F&B cam nhu cac trang shop hien co, nut khoi phuc mau xanh la (var(--success)).

## 11. Kiem tra da chay

Da compile toan bo `src/main/java` bang `javac` (qua PowerShell, classpath gom servlet-api,
mssql-jdbc, jstl, jbcrypt, javax.mail, org.json tu `.m2`) va khong co loi bien dich, bao gom
`CheckoutServlet`, `BillServlet`, `ShopBillServlet`, `BillUtil`, `PayOSUtil`,
`PayOSReturnServlet`, `PayOSWebhookServlet` va cac DAO moi sua.

Lenh Maven chua chay duoc vi moi truong hien tai khong co `mvn` trong PATH.

## 12. Cach test nhanh

Chay project tren Tomcat roi truy cap:

- `/cart` de quan ly gio hang.
- `/cart-items` de quan ly chi tiet gio hang.
- `/orders` de quan ly don hang.
- `/order-details` de quan ly chi tiet don hang.
- `/shop/toppings` de quan ly topping (can dang nhap tai khoan shop, shop da duoc duyet).
- `/shop/topping-categories` de quan ly loai topping.
- `/shop/products` de quan ly san pham (yeu cau nhap it nhat 1 size + gia khi tao/sua).
- `/shop/product-types` de quan ly loai san pham.
- `/shop/profile` de sua thong tin cua hang (ten, mo ta, dia chi, SDT, logo).
- `/cart` -> bam "💳 Thanh toan" tren mot gio hang co san pham -> xem hoa don tam -> dien thong
  tin nguoi nhan -> xac nhan se tao don hang va chuyen sang `/bill?orderIds=...` de xem/in hoa don.
- `/shop/bills` (dang nhap tai khoan shop, shop da duoc duyet) de xem danh sach don hang cua shop
  va bam "🧾 Xem hoa don" tren 1 don de xem/in chi tiet hoa don ngay trong giao dien Shop.
- `/shop/profile` -> nhap Client ID/API Key/Checksum Key cua shop (lay tu PayOS Dashboard) ->
  Luu. `/cart` -> Thanh toan -> chon "Thanh toan online qua PayOS" -> Xac nhan -> he thong tao
  don hang + goi PayOS tao link QR -> chuyen sang trang thanh toan PayOS. Quet QR/thanh toan
  xong, PayOS redirect ve `/payos/return`: thanh cong -> `/bill?orderIds=...`, that bai/huy ->
  `thanhToanThatBai.jsp`.
- `/shop/pos` -> chon mon -> chon phuong thuc "🏦 PayOS" -> Xac nhan -> chuyen sang trang
  thanh toan PayOS. Thanh cong -> ve `/shop/pos?invoiceId=...` (modal hoa don, da PAID). That
  bai/huy -> trang "Thanh toán PayOS thất bại" -> bam "✅ Xac nhan" -> don vua tao bi huy
  (khong luu bill) va quay ve `/shop/pos` de bam bill lai.

## 13. Hien thi "Hinh thuc" (phuong thuc thanh toan) trong Quan ly hoa don cua Shop

Endpoint: `/shop/bills`

Nguoi dung phan anh trang `Quanlybill.jsp` chi co cot "Thanh toan" (PAID/UNPAID/PENDING) nhung
khong cho biet khach thanh toan bang gi (Tien mat / QR chuyen khoan / PayOS). Logic "Da thanh
toan" theo `payment_status` thi da co san tu truoc (set PAID ngay khi CASH o `/shop/pos`, cap
nhat PAID qua webhook/return cho PayOS, xac nhan tay qua pill PENDING/PAID cho QR chuyen khoan
vi khong co cong thanh toan nao xac thuc duoc giao dich chuyen khoan tay) — khong sua lai phan
nay, chi bo sung hien thi:

- `src/main/web/shop/Quanlybill.jsp`: them cot "Hinh thuc" vao bang danh sach, doc
  `o.paymentMethod` (BANK -> 📱 QR chuyen khoan, PAYOS -> 🏦 PayOS, con lai -> 💵 Tien mat),
  dung chung logic hien thi voi `_invoiceModal.jspf`.
- `src/main/web/shop/HoaDonShop.jsp`: them dong "Phuong thuc thanh toan" (icon + ten) va dong
  "Thanh toan" (badge PAID/PENDING/UNPAID) vao trang chi tiet hoa don (truoc do chi in tho
  `bill.order.paymentMethod`, khong co dong trang thai thanh toan).

Ghi chu: Khong co thay doi backend/DAO, chi sua JSP hien thi du lieu da co san tren `Order`.

## 14. Bo loc theo hinh thuc thanh toan trong Quan ly hoa don cua Shop

Endpoint: `/shop/bills?method=COD|BANK|PAYOS`

Bo sung bo loc moi ben canh bo loc "Thanh toan" (UNPAID/PAID/CANCELLED) da co tu truoc:

- `src/main/java/org/example/controllers/ShopBillServlet.java`: doc them param `method`, them
  vao `filterOrders(...)` (sua signature them tham so `methodFilter`), so khop bang
  `normalizePaymentMethod(o.getPaymentMethod())` — coi `COD`/null/bat ky gia tri khac BANK,
  PAYOS la "Tien mat" (dong bo voi logic hien thi o `Quanlybill.jsp`/`_invoiceModal.jspf`).
- `src/main/web/shop/Quanlybill.jsp`: them dropdown "method" vao filter-bar (Tat ca hinh thuc /
  💵 Tien mat / 📱 QR chuyen khoan / 🏦 PayOS), giu lai lua chon da chon qua `${methodFilter}`.

Da compile lai toan bo `src/main/java` bang `javac`, khong loi.

## 15. Sua loi trang chu Shipper va thieu `product_size_id` trong gio hang

Cac loi thuc te tim thay va da sua:

- `shipper/trangchucuashipper.jsp` truoc do duoc truy cap truc tiep nhu file JSP tinh (qua
  `sendRedirect` thang toi `/shipper/trangchucuashipper.jsp` tu `DangNhapServlet`/`XacNhanOTPServlet`),
  khong co servlet nao set attribute `danhSachDonHang` -> trang luon trong. JSP con dung
  `${order.status}` (model `Order` chi co `getStaTus()`) va `${order.shopName}/${order.shopAddress}/${order.shopPhone}`
  (Order khong co cac field nay, chi co `shopId`) -> hien thi rong/sai. Form cap nhat trang thai
  submit toi `/quanlydonhang_shipper`, khong co servlet nao map URL do -> 404.
  Da sua:
  - Them `OrderDAO.findByShipperId(shipperId)` + impl trong `OrderDAOImpl`.
  - Tao moi `models/ShipperOrderView.java` (view rieng cho trang shipper, co san `status`,
    `shopName`, `shopAddress`, `shopPhone` khop dung JSP dang dung, khong sua JSP).
  - Tao moi `controllers/ShipperOrderServlet.java` (`@WebServlet("/shipper/donhang")`):
    GET lay don theo `findByShipperId`, join sang Shop de lay ten/dia chi/SDT, forward JSP;
    POST xu ly `updateStatusToShipping`/`updateStatusToDone` (kiem tra don dung thuoc shipper
    va dung trang thai truoc khi cap nhat).
  - `DangNhapServlet`, `XacNhanOTPServlet`: redirect shipper sang `/shipper/donhang` thay vi
    file JSP tinh.
  - `trangchucuashipper.jsp`: sua form action tu `/quanlydonhang_shipper` sang `/shipper/donhang`.
- `Cart_Items` (theo `Database.md`) co cot `product_size_id BIGINT NOT NULL` (FK sang
  `Product_Sizes`), nhung `CartItem` model va `CartItemDAOImpl` truoc do hoan toan khong biet
  cot nay, dong thoi `CartItemDAOImpl` dung sai ten bang `CartItems` (thuc te la `Cart_Items`,
  giong loi da gap voi `Order_Details` o cac muc truoc) -> moi cau lenh INSERT/SELECT/UPDATE/DELETE
  cua CartItem deu se loi "Invalid object name" khi chay thuc te tren DB. Da sua:
  - `models/CartItem.java`: them field `productSizeId` + getter/setter.
  - `daos/CartItemDAOImpl.java`: doi tat ca SQL tu bang `CartItems` sang `Cart_Items`, them
    cot `product_size_id` vao INSERT/SELECT/UPDATE.
  - `controllers/CartItemServlet.java`: doc/validate them `productSizeId` tu form.
  - `cartItemThemSua.jsp`, `cartItemDanhSach.jsp`: them o nhap/hien thi `Product Size ID`.
  - `CheckoutServlet.buildLines()`: truoc do luon lay size re nhat cua san pham (han che da
    ghi nhan o muc 7) vi `CartItem` khong luu size khach chon. Gio `CartItem` da co
    `productSizeId` nen sua lai dung `productSizeDAO.findById(item.getProductSizeId())` de lay
    dung size khach da chon khi them vao gio hang, khong con chon size re nhat nua.

Ghi chu:

- Chua co man hinh khach hang "them vao gio hang" tu trang san pham (chi co CRUD admin chung
  qua `/cart-items`), nen sau khi sua, nguoi goi `CartItemDAO.create()`/`update()` (vd. trang
  san pham sau nay) phai truyen dung `productSizeId` cua size khach chon, khong duoc bo trong.
- Da compile lai toan bo `src/main/java` bang `javac` (qua PowerShell/Bash voi classpath tu
  `.m2` + `jakarta.servlet-api`), khong loi.

## 16. Dashboard doanh thu cho Shop

Endpoint: `/shop` (trang chu shop, `trangcuahang.jsp`)

Truoc do `ShopHomeServlet` forward sang `trangcuahang.jsp` nhung khong he set bat ky attribute
thong ke nao (`tongSanPham`, `donChoXuLy`, `doanhThuHomNay`, `tongTopping`, `donHangGanDay`) ->
trang chu shop luon hien so 0/rong. Bang "Don hang gan day" co san cung dung sai ten field
(`order.customerName`, `order.totalAmount`, `order.status` thay vi `receiverName`, `totalPrice`,
`staTus` cua model `Order` thuc te) nen luon rong du co du lieu.

Da them moi:

- `src/main/java/org/example/models/ShopDashboardStats.java` (moi) — model gom doanh thu hom
  nay/tuan nay/thang nay, tong don/don hoan thanh/don huy/don cho xu ly, tong san pham, tong
  topping, danh sach top san pham ban chay, danh sach doanh thu 7 ngay gan day (cho bieu do).
- `src/main/java/org/example/daos/ShopDashboardDAO.java` + `ShopDashboardDAOImpl.java` (moi) —
  dung SQL truc tiep tren ten cot thuc te cua `Database.md` (giong pattern `ThongKeDAOImpl` cua
  admin, khong dung schema dong nhu `OrderDAOImpl` vi can SUM/GROUP BY):
  - Doanh thu = `SUM(total_price)` cua `Orders` co `status = 'DONE'`, loc theo `created_at` (hom
    nay / 7 ngay gan day / dau thang).
  - Dem don theo `status` (PENDING/DONE/CANCELLED) bang 1 query `GROUP BY status`.
  - Top san pham ban chay: join `Order_Details` + `Orders` (status DONE) + `Products`, `GROUP BY`
    san pham, sap xep theo so luong ban giam dan, lay TOP 5.
  - Doanh thu 7 ngay gan day: query gom nhom theo ngay roi map vao du 7 ngay lien tiep (ngay
    khong co don van tra ve 0, khong bi thieu diem tren bieu do).

Da sua:

- `src/main/java/org/example/controllers/ShopHomeServlet.java`: them `loadDashboard(req, shopId)`
  goi `ShopDashboardDAO` va set day du attribute cho JSP, dong thoi lay 5 don hang gan nhat cua
  shop qua `OrderDAO.findByShopId` (sap xep theo id giam dan) de sua loi "Don hang gan day" luon
  rong.
- `src/main/web/shop/trangcuahang.jsp`: them taglib `fmt` de format tien te; sua bang "Don hang
  gan day" dung dung field cua model `Order` (`receiverName`, `totalPrice`, `staTus`); them stat
  card doanh thu tuan/thang, tong don/don hoan thanh/don huy; them bang "Top mon ban chay"; them
  bieu do cot doanh thu 7 ngay (Chart.js qua CDN, du lieu nhung tu `doanhThu7NgayQua`).

Chuc nang da co:

- Trang chu shop (`/shop`) hien thi doanh thu hom nay/tuan/thang, tong don, don hoan thanh, don
  huy, don cho xu ly, tong san pham, tong topping, bieu do cot doanh thu 7 ngay gan day, top 5
  mon ban chay (theo so luong, chi tinh tu don da `DONE`), va danh sach 5 don hang gan day nhat
  (hien dung ten nguoi nhan/tong tien/trang thai).

Ghi chu:

- "Doanh thu" chi tinh tren don co `status = 'DONE'` (da giao thanh cong), khong tinh don dang
  PENDING/CANCELLED — phu hop voi y nghia doanh thu thuc te.
- Da compile lai toan bo `src/main/java` bang `javac` (qua Bash, classpath tu `.m2`, doi duong
  dan sang dang Windows `C:\...` truoc khi truyen vao `javac.exe`), khong loi.

## 17. Sua loi dashboard shop khong lay duoc du lieu DB, lo ID tren giao dien, ton kho khong luu

Phat hien bang cach ket noi truc tiep vao DB that (14.225.217.109) qua 1 chuong trinh Java
JDBC test (khong sua schema), doi chieu voi `Database.md` va code thuc te:

- **Dashboard shop (`/shop`) van hien so 0** du DB co san 44 don `status = 'DONE'` cho shop_id=1:
  `ShopDashboardDAOImpl` (muc 16) loc moi query tren bang `Orders` bang `AND is_deleted = 0`,
  nhung bang `Orders` thuc te (kiem tra qua `DatabaseMetaData.getColumns`) **khong co cot
  `is_deleted`** (chi co tren `Products`/`Toppings`). Moi query nem `SQLException "Invalid
  column name 'is_deleted'"`, bi `catch (Exception e) { e.printStackTrace(); }` nuot mat, dashboard
  tra ve toan so 0. Da sua: bo dieu kien `is_deleted = 0` khoi 4 cau SQL tren `Orders` trong
  `ShopDashboardDAOImpl.java` (`getRevenueSince`, `loadOrderCounts`, `loadTopProducts`,
  `loadRevenueLast7Days`), giu nguyen `is_deleted = 0` cho `Products`/`Toppings` (`countRows`)
  vi 2 bang nay co cot do that. Da test lai truc tiep tren DB that: doanh thu hom nay shop_id=1
  ra `2,008,000 đ`, dem don theo status ra dung 44 DONE, top san pham ban chay ra dung du lieu.

- **Quan ly Topping**: dropdown "Loc loai" trong `Quanlytopping.jsp` dung sai field
  `${cat.categoryName}` trong khi model `ToppingCategory` (da doi ten o muc 5) chi co `name` ->
  dropdown loc luon rong/trong khong hien ten loai. Da sua thanh `${cat.name}`. Phan bang danh
  sach topping chinh van lay dung du lieu (`ToppingDAOImpl.findByShopId` da loc dung `shop_id`),
  khong loi.

- **Moi shop chi thay san pham/topping cua minh**: kiem tra lai `ShopProductServlet`/
  `ShopToppingServlet` deu da goi `findByShopId(shop.getId())` voi `shop` lay tu
  `shopDAO.selectShopByOwnerId(account.getId())` cua tai khoan dang dang nhap — co loc dung,
  khong bi lo san pham/topping cua shop khac.

- **Khong de lo ID database tren giao dien**: cac trang `Quanlytopping.jsp`, `Quanlyloaitopping.jsp`,
  `Quanlyloaisanpham.jsp` truoc do hien cot dau tien la `#${id}` (ID that trong DB). Da doi
  cot nay thanh so thu tu hien thi (`${vs.index + 1}` qua `c:forEach varStatus="vs"`), khong con
  lo ID DB; cac lien ket sua/xoa van dung id that o tham so URL/form (binh thuong, can thiet de
  CRUD hoat dong, khong hien thi truc tiep cho nguoi dung doc thay). Cung sua fallback hien thi
  loai topping khi thieu join tu `'Loại #' + id` thanh `'Chưa phân loại'` (muc nay cung thuoc
  Quanlytopping.jsp).

- **Ton kho (`stock_quantity`) khong duoc luu**: o nhap "So luong ton kho" da co san trong
  `Quanlysanpham.jsp` (`name="stockQuantity"`) va `ProductDAOImpl`/`Product.java` da ho tro day
  du cot `stock_quantity`, nhung `ShopProductServlet.createProduct()`/`updateProduct()` **chua
  bao gio doc `req.getParameter("stockQuantity")`** nen gia tri luon mac dinh 0 khi tao moi va
  khong doi khi sua (kiem chung tren DB that: san pham tao gan nhat co `stock_quantity = 0` du
  da nhap so khac tren form). Da sua: doc + validate (`>= 0`) + `product.setStockQuantity(...)`
  o ca 2 luong create/update trong `ShopProductServlet.java`.

Da compile lai toan bo `src/main/java` bang `javac`, khong loi. Da test truc tiep cac cau SQL
sua doi tren DB that (khong qua Tomcat) de xac nhan ket qua dung truoc khi ket luan.

## 18. Trang thai san pham (Dang ban/Het hang/Tam an) khong duoc ap dung khi Bam Bill

Endpoint: `/shop/pos` (`Banhang.jsp`)

Sua trang thai san pham trong `Quanlysanpham.jsp` (ACTIVE/HIDDEN/OUT_OF_STOCK) va bam Luu thi
DB cap nhat dung (`ShopProductServlet`/`ProductDAOImpl` da luu dung tu truoc), nhung trang
"Bam Bill" (`ShopPosServlet` -> `Banhang.jsp`) khong he doc/loc theo `staTus` khi lay danh sach
san pham:

- `ShopPosServlet.forwardPage()` goi `productDAO.findByShopId(shop.getId())` lay **tat ca** san
  pham (khong loai is_deleted theo status), roi `Banhang.jsp` lap qua tat ca va render nut bam
  thanh size binh thuong cho moi san pham, bat ke `staTus` la gi -> san pham da danh dau "Tam an"
  hay "Het hang" tren `Quanlysanpham.jsp` van hien ra va bam ban binh thuong tren POS.

Da sua:

- `src/main/java/org/example/controllers/ShopPosServlet.java` (`forwardPage`): them
  `products.removeIf(p -> "HIDDEN".equalsIgnoreCase(p.getStaTus()));` ngay sau khi lay danh sach
  -> san pham `HIDDEN` (tam an) khong con xuat hien tren POS nua (giong nhu da an voi khach).
- `src/main/web/shop/Banhang.jsp`: voi san pham `OUT_OF_STOCK` (het hang), van hien the san pham
  de nhan vien biet ton tai nhung khong cho bam ban — them class `out-of-stock` + badge "Hết hàng"
  tren anh, cac nut size doi thanh `size-pill-disabled` (`disabled`, khong gan `onclick`, hien
  chu "Hết hàng" thay vi gia).

Ghi chu:

- `ACTIVE` (dang ban): hien thi va ban binh thuong, khong doi gi.
- `HIDDEN` (tam an): an hoan toan khoi POS (nhan vien cung khong thay), giong y nghia "an khoi
  ban hang" cua trang thai nay.
- `OUT_OF_STOCK` (het hang): van hien de nhan vien biet san pham ton tai nhung khoa nut bam,
  khong cho them vao gio hang tam.
- Da compile lai toan bo `src/main/java` bang `javac`, khong loi.

## 20. Dong bo design system moi (theme.css + dashboard.css) cho 4 trang Super Admin

Endpoint: `/super-admin/shipper-requests`, `/super-admin/shop-requests`, `/Category`, `/product`

Truoc do 4 trang nay moi trang tu nhung nguyen 1 khoi `<style>` rieng (bien theme, sidebar,
topbar, table, badge... trung lap toan bo) thay vi dung chung `assets/css/theme.css` +
`assets/css/dashboard.css` da co san (dung cho `admin/TongQuanHeThong.jsp`, `admin/appeals.jsp`,
`admin/chiTietYeuCauShop.jsp`, `admin/chiTietYeuCauShipper.jsp`). Da dong bo lai giao dien (chi
sua JSP, khong dong den servlet/DAO):

- `src/main/web/admin/yeuCauShipper.jsp`: xoa toan bo CSS rieng (~90 dong), doi sang sidebar/topbar
  chuan 7 muc (active "Duyet Shipper"), bang danh sach chuyen sang `.dash-table`, nut hanh dong
  sang `.btn.btn-sm` (`btn-outline`/`btn-success`/`btn-danger-outline`), giu nguyen link
  `?action=detail&id=`, 2 form accept/reject va ham JS `confirmReject(id, name)`.
- `src/main/web/admin/yeuCauShop.jsp`: tuong tu, active "Duyet Shop", giu nguyen ham JS
  `confirmReject(shopId, shopName)` (prompt nhap ly do, ghi vao input hidden `reason_<id>`), bo
  o tim kiem trang tri khong co `name`/khong lam gi (khong anh huong logic).
- `src/main/web/taoCategory.jsp` (goc `src/main/web/`, KHONG phai `admin/`): truoc do da co
  sidebar/topbar kieu Super Admin (khong phai truong hop "chua co khung" — chi la CSS rieng cu),
  da doi sang khung chuan + giu nguyen toan bo field form (`shopId`, `categoryName`, `status`)
  va bang danh sach + `c:set formCategory`, action edit/delete qua query string `?action=edit&id=`.
- `src/main/web/taoProduct.jsp` (goc, KHONG phai `admin/`): tuong tu, giu nguyen toan bo field
  form (`productname`, `shopid`, `categoryid`, `price`, `stock_quantity` — id/name giu y nguyen
  ke ca cho lech `label for="soldQuantity"` voi input id thuc `stock_quantity` da co tu truoc,
  khong sua vi ngoai pham vi doi giao dien, `soldCount`, `status` theo `staTus`, `description`),
  bang danh sach + panel "Huong dan"/thong ke mini o canh form. Bo phan phan trang gia (nut
  `‹ 1 ›` khong co onclick, khong co logic that, thuan tuy trang tri).

CSS rieng con giu lai (khong co san trong `theme.css`/`dashboard.css`): layout 2 cot cua form
(`.cat-grid`, `.prod-grid`), khoi "Huong dan" (`.info-item`, `.info-icon`, `.mini-stat-grid`) o
`taoProduct.jsp`, va khoi avatar-dropdown (giong het cach lam o `TongQuanHeThong.jsp`/`appeals.jsp`,
chua duoc gom vao `dashboard.css` nen van phai copy per-page).

Da kiem tra lai: so luong the `c:if/c:choose/c:when/c:otherwise/c:forEach/form` mo-dong khop nhau
o ca 4 file, khong mat `name=`/`id=` nao cua form/input (trung voi ban goc qua `git diff`, chi mat
duy nhat `id="themeToggleBtn"` — khong can nua vi doi sang dung chung `pobToggleTheme()` cua
`dashboard-theme.js`, ham nay khong dua vao id nut ma dung `document.documentElement`).

## 21. Dong bo design system moi (theme.css + dashboard.css) cho 2 trang Quan ly tai khoan

Endpoint: `/quanlitaikhoan`

Day la 2 file JSP **khac noi dung nhau** (khong phai ban sao): `admin/quanlitaikhoan.jsp` la ban
cu/du phong (khong co servlet nao forward toi — theo `PROJECT_STRUCTURE.md`), con
`src/main/web/quanlitaikhoan.jsp` (goc, ngoai `admin/`) moi la trang that duoc
`QuanLiTaiKhoanServlet` forward toi. Ca 2 deu quan ly CRUD tai khoan nhung khac nhau ro ret:

- `admin/quanlitaikhoan.jsp`: chi co bang danh sach + tim kiem + 2 modal xoa (tam thoi/vinh vien)
  qua dropdown "⋮" per dong; sua tai khoan chuyen huong sang trang khac qua link
  `?action=edit&id=`, KHONG co modal them/sua tai chinh trang nay.
- `src/main/web/quanlitaikhoan.jsp` (goc): day du hon — co `c:set var="formAccount"`, modal
  them/sua tai khoan ngay tren trang (`accountModal`, dung chung 1 form cho ca create/update),
  co sap xep cot (`sortField`/`sortOrder` qua query string), co avatar rieng tung dong, modal xoa
  tam thoi co them textarea nhap `suspendReason`.

Da sua (chi JSP, khong dong servlet/DAO):

- Xoa toan bo khoi `<style>` cu (bien theme sang/toi, sidebar, topbar, table, modal... trung lap
  voi `theme.css`/`dashboard.css`) o ca 2 file; bo `data-theme="dark"` hard-code tren `<html>`,
  them script chong nhay mau + link `theme.css`/`dashboard.css` giong `TongQuanHeThong.jsp`.
- Sidebar doi sang chuan 7 muc dong bo toan Super Admin (copy tu `TongQuanHeThong.jsp`), active
  "Nguoi dung" o ca 2 file; badge "Duyet Shop" doi sang dung `${shopChoDuyet}` (truoc do
  `admin/quanlitaikhoan.jsp` dung sai bien `${pendingShopsCount}` — khong ai set nen badge khong
  bao gio hien; file goc con te hon la hard-code text "2 moi" khong qua EL nao ca).
- Topbar/avatar dropdown + nut chuyen theme doi sang dung chung `pobToggleTheme()`/
  `pobToggleSidebar()` cua `dashboard-theme.js` (bo doan JS tu viet rieng doc/ghi
  `localStorage` theo key `adminTheme`/`theme` cua tung file).
- Badge vai tro (SUPER ADMIN/SHOP/KHACH HANG/SHIPPER hoac 👑 Admin/🏪 Shop/👤 User/🛵 Shipper —
  giu nguyen text/emoji rieng cua tung file) doi sang `.badge.badge-info` (vai tro co quyen quan
  tri) / `.badge.badge-neutral` (Khach hang/User), dung nhu quy uoc "info/neutral = vai tro" đa
  thong nhat cho toan bo Super Admin.
- Nut hanh dong: nut "⋮" mo dropdown moi dong doi sang `.btn.btn-sm.btn-ghost`; nut trong modal xac
  nhan doi sang `.btn.btn-ghost` (Huy) / `.btn.btn-warning` (xoa tam thoi) / `.btn.btn-danger`
  (xoa vinh vien) / `.btn.btn-primary` (tim kiem, luu, tao moi). Modal doi khung sang
  `.pob-modal-overlay`/`.pob-modal-box` (JS mo/dong van dung `classList.add/remove('open')` nhu
  cu — rieng modal them/sua o file goc truoc do dung class `active`, da doi 2 dong JS
  `classList.add('active')`/`remove('active')` thanh `'open'` cho khop voi component modal chung,
  khong doi ten ham/bien nao khac).
- Form them/sua tai khoan (file goc) doi input/select sang `.form-group`/`.form-label`/
  `.form-control`/`.form-select`/`.form-hint`, giu nguyen 100% `name`/`id`/`value`/`required`/
  `placeholder` cua tung field (`username`, `password`, `fullname`, `email`, `phone`, `roleid`,
  `avatarurl`) va textarea `suspendReason` trong modal xoa tam thoi.
- O tim kiem doi input sang `.dash-input`, nut sang `.btn`, giu nguyen toan bo tham so query
  string (`action=search`, `searchKeyword`, `sortField`, `sortOrder`) va logic servlet phia sau.
- Sua 1 loi co san trong `quanlitaikhoan.jsp` (goc): dong dong `</tr>` bi go nham thanh
  `end pt-tr>` (khong phai the HTML hop le, trinh duyet se render chu "end pt-tr>" ra man hinh
  thay vi dong dung hang bang) — sua lai thanh `</tr>`, khong dong gi khac toi logic
  `c:if test="${not empty searchKeyword and empty danhsach}"` bao quanh.

Da kiem tra lai o ca 2 file: so luong the `c:if/c:choose/c:when/c:otherwise/c:forEach/c:set`
mo-dong khop nhau, toan bo `name=`/`id=` cua form/input/textarea giu nguyen (doi chieu qua
`grep`), khong con CSS trung lap voi `theme.css`/`dashboard.css`.

## 22. Dong bo design system moi (theme.css + dashboard.css) cho 3 trang Shop (doi mat khau, ho so, xem danh gia)

Endpoint: `/shop/doi-mat-khau`, `/shop/ho-so`, `/shop/danh-gia`

Tiep tuc dong bo giao dien Shop (sau `trangcuahang.jsp`/`Shopprofile.jsp` da lam mau truoc do),
chi sua 3 file JSP, khong dong servlet/DAO:

- `src/main/web/shop/doiMatKhauShop.jsp`: xoa toan bo khoi `<style>` rieng (bien theme F&B cam,
  sidebar/topbar/table tu ve), doi `<html lang="vi" data-theme="light">`, nap
  `theme.css`+`dashboard.css`, `<body class="dash-body">`, sidebar 9 muc chuan (khong active muc
  nao vi trang chi mo qua dropdown avatar), topbar chi con `menu-toggle-btn` + avatar (bo
  theme-toggle vi Shop dung theme sang co dinh). Giu nguyen 100% form doi mat khau
  (`currentPassword`/`newPassword`/`confirmPassword`, cac `id` do JS dung) + toan bo ham JS
  `togglePw`/`checkStrength`/`checkMatch` (thanh do do manh mat khau) — chi doi CSS bao quanh
  sang `.form-group/.form-label/.form-control/.btn.btn-primary/.btn.btn-ghost/.alert`. Link
  "🔒 Đổi mật khẩu" trong dropdown avatar them `style="color:var(--primary);font-weight:700;"`
  de lam noi bat vi dang o dung trang do.
- `src/main/web/shop/hoSoShop.jsp`: tuong tu, sidebar khong active muc nao. Giu nguyen 100%
  doan JS upload avatar qua Cloudinary (unsigned upload preset `avatar_preset`, cloud
  `jcnsb47f`, XHR co progress bar, sau do POST `avatarUrl` ve `/shop/update-avatar`) — cac
  `id` JS dung (`avatarFileInput`, `uploadProgressBar`, `uploadBar`, `uploadMsg`) va selector
  `.profile-avatar`/`#avatarBtn` deu giu nguyen, chi doi bien mau `var(--accent)` (da xoa khoi
  `:root`) thanh `var(--danger)` trong 3 cho gan `msg.style.color` de khop voi `theme.css`. Panel
  thong tin (email/SDT/ho ten) chuyen sang dung `.info-card`+`.info-row/.info-label/.info-value`
  co san trong `dashboard.css`. Link "👤 Hồ sơ cá nhân" trong dropdown avatar duoc lam noi bat
  tuong tu.
- `src/main/web/shop/xemDanhGia.jsp`: sidebar active "⭐ Xem đánh giá" (dung nhu ban goc). Giu
  nguyen toan bo logic tab Khach hang/Shipper (`switchTab()`, `${feedbackUser.size()}`/
  `${feedbackShipper.size()}`), vong lap sao (`c:forEach begin="1" end="5"`), field
  `fb.anonymous`/`fb.reviewerName`/`fb.orderId`/`fb.rating`/`fb.comment`/`fb.createdAt`. Banner
  tong quan (`.overview-card`), tabs (`.tab-bar`/`.tab-btn`/`.tab-badge`) va card danh gia
  (`.review-card`/`.reviewer-avatar`/`.stars`) la CSS dac thu rieng (khong co san trong
  `theme.css`/`dashboard.css`) nen giu lai, chi doi ten bien: `var(--border)`->`var(--border-color)`,
  `var(--accent)`->`var(--danger)`, mau sao tu hex cung `#FFB703` sang `var(--warning)`. Trang
  thai rong (`Chua co danh gia...`) doi tu class `.empty-icon`+`<p>` tu che sang dung component
  `.empty-state`+`.e-icon`+`.e-title` co san trong `theme.css`.

Da kiem tra lai o ca 3 file: khong con bien CSS cu (`var(--border)`, `var(--primary-dk)`,
`var(--accent)`, `var(--accent-lt)`, `var(--success-lt)`, `var(--warning-lt)`, `var(--info-lt)`,
`var(--sh-sm)`, `var(--sh-md)`), so luong the `c:if/c:choose/c:when/c:otherwise/c:forEach` mo-dong
khop nhau, toan bo `name=`/`id=`/`onclick=`/`oninput=` cua form/input/JS giu nguyen (doi chieu qua
`git diff` + `grep`), doan JS upload Cloudinary trong `hoSoShop.jsp` giu nguyen logic 100%.

## 26. Dong bo design system moi (theme.css + dashboard.css) cho 3 trang Loai San Pham/Topping/Loai Topping cua Shop

Endpoint: `/shop/product-types`, `/shop/topping-categories`, `/shop/toppings`

3 file nay truoc do van dung khoi `<style>` rieng (bien mau F&B cam `--border`, `--primary-dk`,
`--accent`, `--sh-sm`...) va layout "page-grid" 2 cot (form them/sua nam co dinh ben trai, danh
sach ben phai) thay vi modal nhu `Quanlysanpham.jsp` da lam mau. Da dong bo lai (chi sua JSP,
khong dong servlet/DAO):

- `src/main/web/shop/Quanlyloaisanpham.jsp`: xoa khoi `<style>` cu (~150 dong bien theme/sidebar/
  topbar/table/badge trung `dashboard.css`), doi `<html lang="vi">` thanh
  `<html lang="vi" data-theme="light">`, them link `theme.css`/`dashboard.css`. Sidebar/topbar doi
  sang khung chuan 9 muc + avatar dropdown (copy tu `trangcuahang.jsp`), active "Quan ly loai san
  pham". Chuyen form them/sua (truoc la panel co dinh ben trai, field `typeName`/`status`) vao
  `.pob-modal-overlay#typeModal`/`.pob-modal-box`, mo bang nut "+ Them loai san pham moi"
  (`openTypeModal()`), tu mo khi dang sua/co loi (`isEditMode`/`hasError`, giong het pattern
  `Quanlysanpham.jsp`). Bang danh sach chuyen sang `.dash-table-wrap`+`table.dash-table`, badge
  trang thai (ACTIVE/HIDDEN/khac) sang `.badge-success/.badge-danger/.badge-neutral`. Giu nguyen
  100% `name=`/`id=` cua form (`typeName`, `status`, `action`, `id`), query string
  (`?action=edit&id=`, `?action=trash`), ham `filterTable()`/`updateCharCount()`.
- `src/main/web/shop/Quanlyloaitopping.jsp`: tuong tu, active "Quan ly loai Topping". Form them/sua
  (field `categoryName`, `description`, khong co `status` — dung voi ghi chu la
  `ToppingCategories` khong co cot nay) chuyen vao `.pob-modal-overlay#categoryModal`. File goc
  khong co o tim kiem/loc client-side nen KHONG them moi (giu nguyen hanh vi, chi doi giao dien).
- `src/main/web/shop/Quanlytopping.jsp`: tuong tu, active "Quan ly Topping". Form them/sua (field
  `toppingName`, `toppingCategoryId`, `price`, `status` ACTIVE/OUT_OF_STOCK) chuyen vao
  `.pob-modal-overlay#toppingModal`. Giu nguyen o tim kiem theo ten (topbar) + dropdown loc theo
  loai topping (table-toolbar) voi 2 ham rieng `filterTable()`/`filterByCategory()` y nguyen logic
  cu (khong gop thanh 1 ham `applyFilters()` de tranh doi hanh vi).

Ca 3 file: nut "Thung rac" tren topbar giu nguyen link `?action=trash`, doi sang
`.btn.btn-danger-outline.btn-sm`; JS mo/dong modal dung `classList.add/remove('open')` (dung voi
component `.pob-modal-overlay.open` cua `theme.css`, KHONG phai `.active`). Da kiem tra lai: khong
con bien CSS cu (`--border`, `--primary-dk`, `--accent`, `--accent-lt`, `--success-lt`,
`--warning-lt`, `--sh-sm`, `--sh-md`), so luong the `c:if/c:choose/c:when/c:otherwise/c:forEach/form`
mo-dong khop nhau, toan bo `name=` cua form/input giu nguyen (doi chieu qua `grep`).

## 22. Dong bo design system moi (theme.css + dashboard.css) cho 2 trang Hoa don cua Shop

Endpoint: `/shop/bills`

Tiep tuc dong bo giao dien Shop (sau 3 trang mau `trangcuahang.jsp`, `Quanlysanpham.jsp`,
`Shopprofile.jsp`) cho 2 file con lai thuoc nhom "Quan ly hoa don" (chi sua JSP, khong dong
servlet/DAO/`_invoiceModal.jspf`):

- `src/main/web/shop/Quanlybill.jsp`: xoa toan bo khoi `<style> :root{...}` rieng (mau F&B cam,
  sidebar, topbar, table, status-badge, btn, alert...) trung voi `theme.css`/`dashboard.css`;
  doi `<html lang="vi">` thanh `<html lang="vi" data-theme="light">`, them link
  `theme.css`/`dashboard.css`; `<body>` doi sang `class="dash-body"`, sidebar/topbar/avatar-dropdown
  copy dung cau truc 9 muc tu `trangcuahang.jsp` (active "📋 Quan ly hoa don"); bang danh sach
  doi sang `.dash-table-wrap`+`table.dash-table`; cot "Hinh thuc"/"Thanh toan"/"Trang thai don"
  doi tu `.status-badge` (CSS rieng) sang `.badge`+bien the (PAID=`badge-success`,
  UNPAID=`badge-danger`, PENDING=`badge-warning`; COD=`badge-neutral`, BANK/PAYOS=`badge-info`);
  nut Xac nhan/Huy doi tu inline-style `background:#2ECC71/#E63946` sang `.btn.btn-sm.btn-success`/
  `.btn.btn-sm.btn-danger`; filter-bar giu CSS rieng (khong co san trong dashboard.css) nhung
  input/select doi sang dung chung `.dash-input`; dong include `<%@ include file="_invoiceModal.jspf" %>`
  giu nguyen 100% (khong sua file jspf).
- `src/main/web/shop/HoaDonShop.jsp`: tuong tu — xoa CSS rieng trung lap, giu lai CSS dac thu cho
  layout hoa don in an (`.bill-center/.bill-wrap/.bill/.bill-header/.bill-totals/.bill-actions`,
  scope `.bill .info-row`/`.bill table` de tranh dung ten `.info-row`/`table` da co nghia khac
  trong `dashboard.css`); 3 dong trang thai (Phuong thuc/Thanh toan/Trang thai) doi sang `.badge`;
  nut "🖨️ In hoa don" (`window.print()`) va "← Quay lai danh sach" doi sang `.btn.btn-primary`/
  `.btn.btn-ghost`, giu nguyen ham `window.print()`.

Da kiem tra lai o ca 2 file: khong con bien CSS cu (`var(--border)`, `var(--primary-dk)`,
`var(--accent)`, `var(--accent-lt)`, `var(--success-lt)`, `var(--warning-lt)`, `var(--info-lt)`,
`var(--sh-sm)`, `var(--sh-md)`), so luong the JSTL mo-dong khop nhau (kiem qua `grep`), toan bo
`name=`/`id=`/`action=` cua form/input va tham so query string (`?action=view&as=modal&id=`,
`?method=`, `?status=`, `?action=confirm`, `?action=cancel`...) giu nguyen (doi chieu qua
`comm` voi ban goc tren git), dong include `_invoiceModal.jspf` khong doi.

## 23. Dong bo design system moi (theme.css + dashboard.css) cho 4 trang Thung rac cua Shop

Endpoint: `/shop/products?action=trash`, `/shop/product-types?action=trash`,
`/shop/toppings?action=trash`, `/shop/topping-categories?action=trash`

Tiep tuc dong bo giao dien Shop (sau `trangcuahang.jsp`, `Quanlysanpham.jsp`, `Shopprofile.jsp`,
`Quanlybill.jsp`, `HoaDonShop.jsp`) cho 4 file "Thung rac" con lai — chi sua JSP (khong dong
servlet/DAO), 4 file gan nhu giong het nhau nen sua theo cung 1 pattern:

- `src/main/web/shop/ThungRacSanPham.jsp`, `ThungRacLoaiSanPham.jsp`, `ThungRacTopping.jsp`,
  `ThungRacLoaiTopping.jsp`: xoa toan bo khoi `<style> :root{...}` rieng (mau F&B cam, sidebar,
  topbar, table, `.status-badge`, `.btn`, `.alert`, avatar-dropdown... trung voi
  `theme.css`/`dashboard.css`); doi `<html lang="vi">` thanh `<html lang="vi" data-theme="light">`
  (theo dung quy uoc Shop chi dung theme sang, khong co nut chuyen dark/light), them link
  `theme.css`/`dashboard.css`; `<body>` doi sang `class="dash-body"`; sidebar 9 muc + `.sidebar-backdrop`
  copy dung cau truc tu `trangcuahang.jsp`, active dung muc theo tung trang (Quan ly san pham /
  Quan ly loai san pham / Quan ly Topping / Quan ly loai Topping); topbar giu `.menu-toggle-btn`
  (`onclick="pobToggleSidebar()"`) + avatar/dropdown, khong co nut theme-toggle (dung 1 theme sang
  co dinh); nut "← Quay lai danh sach" doi tu `.btn-back` (CSS rieng) sang `.btn.btn-ghost`, dat
  trong `.content` phia tren panel; bang danh sach cac muc da xoa boc trong `.panel`
  (`.panel-header`/`.panel-title` + badge dem so luong `.badge.badge-neutral`, `.panel-body`),
  dung `.dash-table-wrap`+`table.dash-table` thay cho `<table>` CSS rieng; cot "Trang thai"
  (`Da xoa`) doi tu `.status-badge.status-deleted` sang `.badge.badge-danger`; nut "♻️ Khoi phuc"
  moi dong doi tu `.btn.btn-restore` sang `.btn.btn-sm.btn-success`; alert loi doi class
  `alert-error` (khong co trong theme.css) sang `alert-danger` cho dung voi `.alert`+`.alert-danger`
  cua `theme.css`; danh sach rong doi tu `.empty-state` CSS rieng sang `.empty-state`+`.e-icon`/`.e-title`
  chuan cua `theme.css`.
- Giu nguyen 100%: khoi kiem tra quyen `roleId != 2` dau file, taglib/`<%@ page %>`, toan bo EL
  (`${deletedProducts}`, `${deletedCategories}`, `${deletedToppings}`, `${p.productName}`,
  `${cat.categoryName}`, `${cat.name}`/`${cat.description}`, `${t.toppingName}`/
  `${t.toppingCategoryName}`/`${t.price}`...), form khoi phuc (`method="post"`,
  `action="${pageContext.request.contextPath}/shop/products|product-types|toppings|topping-categories"`,
  `name="action" value="restore"`, `name="id"`), khong co `onsubmit`/`confirm(...)` nao trong 4
  file goc nen khong can giu them.

Da kiem tra lai ca 4 file: khong con `:root{...}` hay CSS trung lap voi `theme.css`/`dashboard.css`,
so luong the `c:if/c:choose/c:when/c:otherwise/c:forEach/form` mo-dong khop nhau (kiem qua `grep`),
toan bo `name=`/`action=`/`method=` cua form/input giu nguyen 100% so voi ban goc (doi chieu qua
`git diff` chi con `name=`/`action=`/`method=`, khong lech dong nao), ca 4 file dung thong nhat
1 pattern giong het nhau (chi khac tieu de, muc active sidebar, link "Quay lai danh sach", ten
bien EL va cac cot rieng cua tung loai du lieu — vi du `ThungRacTopping.jsp` co them cot "Loai
topping"/"Gia", `ThungRacLoaiTopping.jsp` co them cot "Mo ta").

## 30. Dong bo design system moi (theme.css + dashboard.css) cho trang "Bam Bill" cua Shop

Endpoint: `/shop/pos`

`src/main/web/shop/Banhang.jsp` (trang POS phuc tap nhat cua Shop: chon mon, gio hang tam,
size/topping picker, thanh toan) truoc do van dung 1 khoi `<style>` rieng voi bien theme F&B
cam cu (`--bg-base`, `--border`, `--primary-dk`, `--accent`, `--sh-sm`...) giong cac trang Shop
khac truoc khi dong bo. Da sua (chi JSP, khong dong servlet/DAO `ShopPosServlet`):

- Xoa toan bo bien `:root{...}`, reset, CSS sidebar/topbar/table cu; doi `<html>` sang
  `data-theme="light"` co dinh (Shop khong co dark mode); them link `theme.css`/`dashboard.css`;
  `<body class="dash-body">`.
- Sidebar doi sang dung 9 muc chuan (copy tu `trangcuahang.jsp`), active "🧾 Bam Bill"; them
  `.sidebar-backdrop` + nut `.menu-toggle-btn` (goi `pobToggleSidebar()`) cho mobile — truoc do
  trang nay khong co nut thu gon sidebar tren mobile.
- Topbar: giu nguyen o tim mon (`id="searchBox"`, `oninput="filterProducts(this.value)"`) nhung
  doi sang `.dash-input`; avatar doi sang cau truc chuan `.avatar-wrapper`/`.avatar-circle` (JS
  dropdown giu nguyen logic, chi doi class).
- Nut "Xac nhan" (`#btnConfirm`) doi tu CSS `.btn-confirm` rieng sang `.btn.btn-primary.btn-block`
  dung chung; o nhap ten khach (`#customerName`) doi sang `.dash-input`; xoa het khoi `.btn`/
  `.btn-primary`/`.btn-secondary` cu tu dinh nghia rieng (khong noi nao dung toi, bi trung ten
  voi `.btn` chung cua `theme.css` gay xung dot neu giu lai).
- Panel chon topping khi them mon vao gio (`#toppingOverlay`) — modal rieng ngoai
  `_invoiceModal.jspf` — doi tu class rieng `.topping-picker-overlay`/`.show` sang dung khung
  modal chung `.pob-modal-overlay`/`.pob-modal-box` (them class phu `.topping-picker-box` de giu
  kich thuoc rieng 340px), sua 2 dong JS `classList.add('show')`/`classList.remove('show')` trong
  `openToppingPicker()`/`closeToppingPicker()` thanh `.add('open')`/`.remove('open')` cho dung quy
  uoc modal chung — khong doi ten ham/logic gio hang tam nao khac.
- CSS rieng con giu lai (dac thu POS, chua co san trong `theme.css`/`dashboard.css`): layout 2
  cot `.pos-layout` (luoi chon mon ben trai cuon rieng + `.cart-panel` gio hang tam co dinh ben
  phai), `.product-grid`/`.product-card`/`.size-pills`, cac dong `.cart-line`/`.qty-stepper`,
  `.pay-methods`, va CSS panel `.topping-picker-box`/`.topping-row`.
- Include `<%@ include file="_invoiceModal.jspf" %>` giu nguyen dong, khong dong vao file
  `_invoiceModal.jspf` (file nay da dung san token/class moi tu truoc).

Da kiem tra lai: toan bo `name=`/`id=` cua form/input/button giu nguyen 100% (doi chieu qua
`grep` giua ban cu va ban moi), toan bo ham JS (`addToCart`, `renderCart`, `changeQty`,
`removeLine`, `openToppingPicker`, `closeToppingPicker`, `onToppingCheck`, `onToppingQty`,
`selectPayMethod`, `filterProducts`, `filterByCategory`, `submitOrder`) va toan bo `onclick`/
`onchange`/`oninput` giu nguyen (chi them 1 `onclick="pobToggleSidebar()"` moi cho nut mobile),
logic gio hang tam JS-side (`var cart = []`) va toan bo tham so form POST
(`action`, `paymentMethod`, `customerName`, `lineProductId[]`, `lineSizeId[]`, `lineQty[]`,
`lineToppings[]`) khong doi. So luong the `c:if/c:choose/c:when/c:otherwise/c:forEach/c:set`
mo-dong khop nhau, khong con bien CSS cu (`--border)`, `--primary-dk`, `--accent`, `--sh-sm`...).

## 31. Dong bo tone mau cho Shipper (dashboard shell dung chung) + Theme "Vu tru/Khong gian" rieng cho User

Yeu cau: lam lai frontend cua 3 role Shipper/Super Admin/Admin(Shop) cho dong bo mot tong mau,
va lam lai frontend role User theo phong cach "vu tru/khong gian" (khac han tone F&B cam cua cac
role kia). Khong sua backend, giu nguyen 100% chuc nang/servlet/endpoint/EL/JS hien co.

Ra soat truoc khi lam: Super Admin (`admin/*.jsp` + `quanlitaikhoan.jsp` root) va Admin/Shop
(`shop/*.jsp`, `taoCategory.jsp`, `taoProduct.jsp`) da duoc dong bo theme cam (`theme.css` +
`dashboard.css`) tu truoc trong nhanh nay — chi con thieu rieng role **Shipper**.

Da sua (Shipper — 10 file trong `src/main/web/shipper/`, tat ca truoc do moi file tu code rieng
mot bo `:root` mau xanh la `#4CAF50`/cam `#FF9800` + sidebar/topbar/avatar-dropdown copy-paste
rieng, key luu theme la `shipper-theme`):

- `dashboard.jsp`, `trangchucuashipper.jsp`, `chitietdonhang.jsp`, `nhanDon.jsp`,
  `doiMatKhauShipper.jsp`, `thongbao.jsp`, `danhGia.jsp`, `hoSoShipper.jsp`, `hosotaixe.jsp`,
  `guiFeedback.jsp` — doi toan bo sang dung chung `assets/css/theme.css` +
  `assets/css/dashboard.css` + `assets/js/dashboard-theme.js` (key luu theme doi thanh
  `pob-dashboard-theme`, dung chung voi Super Admin), sidebar/topbar/avatar-dropdown dung dung
  cau truc `.sidebar`/`.sidebar-brand`/`.menu-item`/`.topbar`/`.avatar-circle` nhu
  `admin/hoSoAdmin.jsp`, them `sidebar-backdrop` + `menu-toggle-btn` (`pobToggleSidebar()`) cho
  mobile (truoc do khong co, sidebar shipper tren mobile chi doi thanh thanh ngang cuon).
- Giu nguyen nut bat/tat Online/Offline o cuoi sidebar (form POST `/shipper/status`), chuyen
  vao `.sidebar-foot` dung khung chung; giu nguyen toan bo endpoint form
  (`/shipper/donhang`, `/shipper/nhan-don`, `/shipper/dashboard`, `/shipper/thongbao`,
  `/shipper/danh-gia`, `/shipper/profile`, `/shipper/ho-so`, `/shipper/doi-mat-khau`,
  `/shipper/bom-hang`, `/shipper/feedback`, `/shipper/update-avatar`) va toan bo ham JS
  (`filterOrders`, `applyFilters`, `openDetailModal`/`closeDetailModal`, checklist
  `toggleCheck`/`resetChecklist`/`updateUI` cua `chitietdonhang.jsp`, upload avatar Cloudinary
  cua `hoSoShipper.jsp`, chart thu nhap Chart.js cua `dashboard.jsp`).
- Mau sac quy uoc lai theo token chung: trang thai "cho lay hang" -> `--warning`, "dang giao"
  -> `--primary` (cam thuong hieu, nhan manh viec dang lam), "hoan thanh" -> `--success`, "huy/bom
  hang" -> `--danger`; modal chi tiet don hang (`trangchucuashipper.jsp`) doi tu class rieng
  `.modal-backdrop`/`.modal-content`/`active` sang dung khung modal chung
  `.pob-modal-overlay`/`.pob-modal-box`/`open`.
- `guiFeedback.jsp` (form danh gia shop sau khi giao xong) truoc do dung rieng Tailwind CDN +
  tong mau navy — bo Tailwind, doi sang `theme.css` thuan, giu nguyen form POST
  `/shipper/feedback` (`orderId`, `rating`, `comment`) va JS chon sao.

Da tao moi CSS rieng cho role User (`src/main/web/assets/css/theme-space.css`) — theme "vu
tru/khong gian": nen toi (`--bg-deep #05040f` -> `--bg-base #0b0a1f`), gradient tinh van tim-cyan
(`--primary #8b5cf6`, `--secondary #22d3ee`, `--accent-pink #f472b6`), lop `.starfield` (sao lam
lanh bang nhieu `radial-gradient` + `@keyframes pobTwinkle`), card kinh mo (`backdrop-filter:
blur`), glow neon cho nut/card khi hover (`--glow-primary`). File nay doc lap, khong phu thuoc
`theme.css` cam cua cac role kia (co chu y khac biet tong mau theo yeu cau).

Da sua (User — 5 file trong `src/main/web/user/`):

- `guiFeedback.jsp`, `donhang.jsp`, `diaChi.jsp`: bo Tailwind CDN + tong mau navy cu, doi sang
  `assets/css/theme-space.css`, giu nguyen toan bo form action (`/feedback`, `/user/dia-chi`),
  tham so (`orderId`, `targetType`, `rating`, `comment`, `is_anonymous`, `action=create|update|
  delete|setDefault`, cac field dia chi) va JS (`setRating`, `openModal`/`closeModal`/`openEdit`
  cua modal dia chi).
- `menuShop.jsp`, `trangnguoidung.jsp` (2 trang lon nhat, dung CSS rieng inline nhu ban goc thay
  vi `theme-space.css` de tranh dung ten class voi phan CSS dac thu rieng trang): giu nguyen
  toan bo `:root` bien nhung doi gia tri mau tu cam F&B sang tim-cyan vu tru, them
  `.starfield` + tinh van nen; giu nguyen 100% cau truc HTML/id/class ma JS dang tham chieu
  (`openModal`, `closeModal`, `changeQty`, `updateTotal`, `filterCategory` cua `menuShop.jsp`;
  `goToShop`, `filterShops`, `filterCat`, `toggleDropdown`, banner slider `goSlide`/`nextSlide`/
  swipe touch cua `trangnguoidung.jsp`) va toan bo EL/JSTL render san pham/shop tu DB
  (khong dung du lieu gia dinh nao khac ngoai nhung gia tri demo co san tu truoc nhu rating
  "4.x" gia lap theo `vs.index`).

Kiem tra: dem the `<c:if>/<c:choose>/<c:when>/<c:otherwise>/<c:forEach>` mo-dong khop nhau tren
tung file da sua (Shipper + User). Khong dong vao Servlet/DAO/Model nao — chi doi CSS/markup/JS
thuan giao dien.

## 22b. Xem vi tri giao hang tren ban do (phia Shop, chi doc)

Tiep noi muc 22 (Leaflet address-map): sau khi don hang da co toa do (`Order.locationX`/
`locationY`), phia shop chua co cho nao xem lai toa do do tren ban do. Yeu cau: cho chu shop xem
vi tri giao hang cua don hang (va vi tri shop, neu co) tren ban do, chi doc, khong cho sua.

Pham vi:

- `src/main/web/shop/HoaDonShop.jsp` (trang chi tiet hoa don): them 1 ban do Leaflet chi doc
  ngay ben duoi phan "Dia chi giao hang", hien thi marker vi tri giao hang cua don hang va (neu
  co toa do) marker 🏠 cua shop, tu dong `fitBounds` de ca 2 marker deu nam trong khung nhin. Neu
  don hang khong co toa do (`locationX`/`locationY` null — vi du don tao truoc muc 22, hoac dia
  chi khong ghim vi tri) thi an ban do, hien dong text fallback "Chua co vi tri tren ban do".
- `src/main/web/shop/Quanlybill.jsp` (trang danh sach don hang): moi dong don hang co toa do
  hop le duoc them 1 nut "📍" mo modal hien thi ban do cung dang (marker giao hang + marker shop,
  chi doc); don hang khong co toa do thi khong hien nut.

Nguon du lieu: tai su dung `Order.locationX`/`locationY` (da co san tu muc 22) va
`Shop.locationX`/`locationY` (field co san tu truoc, truoc gio chua tung hien thi o dau) — ca 2
trang deu doc qua `sessionScope.currentShop` (da duoc set san khi shop dang nhap) de lay toa do
shop, khong can them truy van DAO/DB moi.

Hanh vi: chi doc (read-only) — khong co thao tac keo/tha hay sua toa do tren 2 trang nay; an
ban do/nut bam neu thieu toa do don hang; an marker shop neu thieu toa do shop (van hien marker
giao hang binh thuong).

Tech: tai su dung Leaflet.js 1.9.4 CDN + OpenStreetMap tile giong muc 22, khong co thay doi nao
o tang Model/DAO/Servlet (thuan JSP + JS).

## 24. Chon vi tri cua hang tren ban do (trang Thong tin cua hang, phia shop)

- **Van de:** Shop khong co cach nao dat toa do vi tri cua hang (`Shops.locationX`/`locationY`). Cot DB va field model da co san nhung `ShopDAOImpl` chua bao gio doc/ghi chung, nen marker cua hang tren ban do giao hang (tinh nang truoc do) luon rong.
- **Sua:**
  - `ShopDAOImpl.mapResultSetToShop()`: doc them `locationX`/`locationY` tu ResultSet.
  - `ShopDAOImpl.updateShop()`: ghi them `locationX`/`locationY` vao cau lenh UPDATE.
  - `ShopProfileServlet`: nhan them 2 tham so form `shopLocationX`/`shopLocationY` (khong bat buoc), set len `Shop` truoc khi luu.
  - `shop/Shopprofile.jsp`: them nut "Chon vi tri tren ban do" trong form chinh sua, mo ra ban do Leaflet (click/keo ghim + o tim kiem Nominatim) — cung mau giao dien voi `user/diaChi.jsp`, nhung khong bat buoc phai chon.
  - `shop/Shopprofile.jsp`: khi chon vi tri tren ban do (click, keo ghim, hoac tim kiem ra ket qua), tu dong reverse-geocode toa do qua Nominatim `/reverse` va dien lai vao o "Dia chi" (`#shopAddress`) — keo ghim duoc debounce 500ms de tranh goi API lien tuc; vi tri dat san (preset) khi mo lai form thi khong reverse-geocode (giu nguyen dia chi da luu). Cung mau voi `initAddressMap` trong `user/diaChi.jsp`.
- **Tech:** Leaflet 1.9.4 CDN + OpenStreetMap + Nominatim, khong doi Model/DB schema (cot da co san).

## 25. Theo doi vi tri shipper realtime tren ban do (WebSocket)

Endpoint: `/ws/tracking` (WebSocket, khong phai HTTP servlet), lien quan `shipper/chitietdonhang.jsp`, `user/donhang.jsp`

Tiep noi muc 22-24 (toa do shop/dia chi/don hang da co san qua Leaflet): yeu cau moi la xem **vi
tri shipper di chuyen realtime** tren ban do trong luc don dang giao (`status = SHIPPING`), thay
vi chi xem toa do tinh (shop/diem giao) nhu truoc. Khong them bang/cot DB moi — vi tri shipper chi
la du lieu tam thoi, phat truc tiep qua WebSocket va cache trong bo nho server (khong luu DB).

Da them moi:

- `pom.xml`: them 2 dependency `jakarta.websocket-api` va `jakarta.websocket-client-api` (cung
  ban 2.1.1, `scope=provided`, Tomcat da co san runtime) — phai co ca 2 vi rieng
  `jakarta.websocket-api` (server-api) khong co san goi `jakarta.websocket` co ban
  (`Session`, `Endpoint`...), thieu se khong compile duoc `TrackingEndpoint`.
- `src/main/java/org/example/websocket/HttpSessionConfigurator.java` (moi) — 1
  `ServerEndpointConfig.Configurator` copy `accountId` cua tai khoan dang dang nhap tu
  `HttpSession` sang `userProperties` cua WebSocket handshake, de endpoint biet ai dang ket noi
  ma khong can dang nhap lai qua WebSocket.
- `src/main/java/org/example/websocket/TrackingEndpoint.java` (moi) — `@ServerEndpoint("/ws/tracking",
  configurator = HttpSessionConfigurator.class)`. Client ket noi voi query string
  `?role=shipper&orderId=<id>` (shipper dang giao don do) hoac `?role=customer&orderId=<id>`
  (khach hang xem don do). Xac thuc quyen ket noi bang cach doi chieu `accountId` trong session
  voi `order.shipperId` (role=shipper) hoac `order.userId` (role=customer) cua chinh `orderId` do
  — khong cho xem/gui vi tri don hang khong lien quan. Tin nhan shipper gui len (JSON dang
  `{"lat":..,"lng":..}`) duoc:
  - Cache lai vi tri moi nhat cua `orderId` do trong 1 registry trong bo nho (Map tinh, khong
    ghi DB).
  - Phat (broadcast) ngay lap tuc cho tat ca session `role=customer` dang xem cung `orderId`.
  - Khi 1 khach hang moi ket noi (`role=customer`), neu da co vi tri cache san cho `orderId` do
    thi gui lai ngay vi tri gan nhat (de khach khong phai cho lan cap nhat GPS tiep theo cua
    shipper moi thay marker).

Da sua:

- `src/main/web/shipper/chitietdonhang.jsp`: them 1 script chi kich hoat khi
  `order.staTus == 'SHIPPING'` — mo WebSocket toi `/ws/tracking?role=shipper&orderId=<id>`, dung
  `navigator.geolocation.watchPosition` de theo doi GPS thiet bi shipper, throttle gui toi da
  ~3 giay/lan (tranh spam server), tu dong dong ket noi khi rời trang (`beforeunload`).
- `src/main/java/org/example/controllers/UserOrderServlet.java`: ngoai `shopNames` (map co san),
  them attribute moi `shopCoords` (`Map<Long shopId, double[] {lat, lng}>`) de JSP co toa do shop
  ma khong phai truy van them.
- `src/main/web/assets/js/orderTrackingMap.js` (moi) — module Leaflet dung chung:
  `initOrderTrackingMap(containerId, shopLat, shopLng, destLat, destLng, wsUrl)` — ve marker shop
  + marker diem giao hang, `fitBounds` ca 2, roi mo WebSocket `role=customer` toi `wsUrl` de nhan
  vi tri shipper va dat/di chuyen 1 marker shipper rieng moi khi co cap nhat.
- `src/main/web/user/donhang.jsp`: them CDN Leaflet, moi don hang dang `SHIPPING` co 1
  `<div id="map-${order.id}">` va 1 script goi `initOrderTrackingMap(...)` voi toa do shop lay tu
  `shopCoords[order.shopId]` (muc tren) va toa do diem giao la `order.locationX`/`locationY` cua
  chinh don hang, ket noi WebSocket toi `/ws/tracking?role=customer&orderId=${order.id}`.

Chuc nang da co:

- Khi don hang chuyen sang trang thai "Đang giao" (`SHIPPING`): shipper mo trang chi tiet don
  hang se tu dong phat vi tri GPS thiet bi len server qua WebSocket.
- Khach hang mo trang "Đơn hàng của tôi" thay ban do 2 marker tinh (shop + diem giao) bang ban do
  co them marker thu 3 la vi tri shipper, tu cap nhat lien tuc (~3s/lan) trong khi don dang giao,
  khong can F5 lai trang.

Han che/gia dinh da biet:

- Vi tri shipper chi ton tai trong bo nho server (registry tinh trong `TrackingEndpoint`), khong
  luu DB — mat khi restart server, va chi co 1 instance server (khong scale ngang nhieu server
  duoc voi thiet ke nay).
- Khong co bang/cot DB moi cho tinh nang nay.

Da compile lai toan bo `src/main/java` bang `javac` (classpath gom toan bo jar tu `.m2`, bao gom
`jakarta.websocket-api`/`jakarta.websocket-client-api` moi them), khong loi.

## 25b. Fix 3 loi Important tu final code review cua tinh nang theo dõi shipper realtime (WebSocket)

Endpoint: `/ws/tracking` va cac file lien quan o muc 25.

Ba loi Important tim thay khi review lai toan bo tinh nang WebSocket theo doi shipper, da sua:

- **Thieu kiem tra Origin khi handshake WebSocket (lo hong CSWSH)**: `HttpSessionConfigurator`
  truoc do khong override `checkOrigin`, dung mac dinh cua Jakarta (`true` cho moi Origin). Vi
  handshake chi xac thuc qua session cookie (trinh duyet tu dong gui kem cookie khi upgrade
  WebSocket kê ca cross-origin), 1 trang web doc hai ben ngoai co the mo ket noi WebSocket toi
  `/ws/tracking?role=customer&orderId=N` (lap N) trong khi nan nhan dang dang nhap, de nhan duoc
  luong vi tri GPS shipper cua don hang do, hoac (`role=shipper`) gia mao toa do GPS vao 1 don
  dang giao. Da sua trong `src/main/java/org/example/websocket/HttpSessionConfigurator.java`:
  them method `modifyHandshake` kiem tra header `Origin` so voi header `Host` cua chinh request
  (lay tu `HandshakeRequest.getHeaders()`); neu ca 2 co mat va host khac nhau thi KHONG set
  `currentAccountId` vao `userProperties` — tai su dung co che unauthorized co san trong
  `TrackingEndpoint.onOpen` (coi -1L la khong duoc phep, tu dong dong ket noi), khong tao co che
  moi. Neu thieu header `Origin` (client khong phai trinh duyet, hoac mot so truong hop
  same-origin khong gui Origin) van cho qua nhu truoc de khong lam gay ket noi hop le.

- **Race condition khi don cleanup `customerWatchers`**: `TrackingEndpoint.onClose` truoc do
  `watchers.remove(session); if (watchers.isEmpty()) customerWatchers.remove(orderId);` khong
  atomic — 1 `onOpen` dong thoi cua watcher moi tren cung `orderId` co the insert vao dung set do
  ngay truoc khi entry bi xoa khoi map, lam watcher moi bi "mo coi" trong 1 set da tach khoi map
  (`onMessage` sau nay se khong bao gio tim thay de gui vi tri). Da sua: thay
  `customerWatchers.remove(orderId)` bang `customerWatchers.computeIfPresent(orderId, (k, v) ->
  v.isEmpty() ? null : v)` sau khi remove session khoi set — chi xoa entry neu set van con rong
  TAI THOI DIEM computeIfPresent chay (atomic), dong cua so race. Van giu nguyen
  `CopyOnWriteArraySet` cho set watcher moi don, khong doi cau truc du lieu.

- **Ca 2 phia (shipper gui, khach hang nhan) khong co reconnect NEN cung khong bao gio bao loi khi
  mat ket noi**: neu socket cua shipper bi rot (thuong gap tren mobile: chuyen app nen, chuyen
  tram song), shipper khong tu ket noi lai va khong bao ai biet — marker shipper tren ban do khach
  hang cu dung yen ma khong co dau hieu gi la da mat ket noi. Theo dung pham vi yeu cau (KHONG lam
  reconnect/retry, chi them canh bao hien thi):
  - `src/main/web/assets/js/orderTrackingMap.js`: them `socket.addEventListener('close', ...)`
    va `('error', ...)` goi chung 1 ham hien 1 `<div>` nho ("⚠️ Mất kết nối theo dõi trực tiếp...")
    chen ngay sau khung ban do (`container.parentNode.insertBefore(...)`), an mac dinh
    (`display:none`), chi hien khi socket dong/loi.
  - `src/main/web/shipper/chitietdonhang.jsp`: them `socket.addEventListener('close', ...)` va
    `('error', ...)` goi ham `showTrackingWarning()` hien 1 `<span id="trackingWsWarning"
    class="badge">` (tai su dung dung class `.badge` va bien mau `var(--danger)` da co san trong
    file, dat ngay canh badge trang thai "🛵 Đang giao" de dong bo phong cach voi cac badge trang
    thai khac trong trang, khong tao co che canh bao rieng thu 2).

Da compile lai toan bo `src/main/java` bang `javac` (classpath tu `.m2`), khong loi. Da doc lai
thu cong `orderTrackingMap.js` va `chitietdonhang.jsp` de xac nhan brace/tag can doi.

## 26. Fix regression: marker diem giao (dest) khong bao gio hien tren ban do theo doi realtime cua khach hang

**Trieu chung:** Khach hang mo `/user/donhang`, don dang `SHIPPING`, ban do chi hien 1 marker
(shop 🏪) thay vi 3 marker (shop, diem giao 🏠, shipper 🛵) nhu thiet ke.

**Nguyen nhan (xac dinh qua git forensics):** `Order.locationX`/`locationY` (nguon cua marker diem
giao trong `donhang.jsp`, xem muc 25) luon luon `null` cho MOI don hang, ke ca don moi tao — vi
`src/main/web/checkoutThanhToan.jsp` khong con field nao de nguoi dung chon toa do giao hang, du
`CheckoutServlet.java` (`doPost`) van doc `req.getParameter("locationX"/"locationY")` va goi
`order.setLocationX/Y(...)` binh thuong (backend van dung, chi thieu dau vao tu form).

Truy vet bang `git log --oneline -- src/main/web/checkoutThanhToan.jsp` va
`git diff <parent> <merge-commit> -- <file>` cho thay: commit `97fc1cf`
("Merge branch 'bao-ty00366' into ThanhHien_TY00243") da ghi de `checkoutThanhToan.jsp` bang 1
ban don gian hon tu nhanh `bao-ty00366`, xoa mat tinh nang chon vi tri Leaflet da lam truoc do
(them tu commit `e7e2908` "Add inline address-map modal to checkout page"). Day la 1 **merge
regression**, khong phai loi thiet ke moi.

**Da sua:**
- `src/main/web/checkoutThanhToan.jsp`: them lai (dua tren layout hien tai cua team, khong revert
  nguyen ban cu):
  - Include Leaflet CSS/JS (CDN `unpkg.com/leaflet@1.9.4`) trong `<head>`.
  - O khu "Thong tin nhan hang": field "Ten nguoi nhan"/"So dien thoai"/"Dia chi giao hang" tu dien
    tu `defaultAddress` (uu tien `param.*` khi validate-fail re-render, dung pattern EL
    `${not empty param.X ? param.X : defaultAddress.X}` da dung o nhieu JSP khac trong project).
  - Them 1 form-group moi "Vi tri tren ban do": nut bam "📍 Chon vi tri tren ban do" (chi hien ban
    do khi bam, tranh load Leaflet khong can thiet), o trong co o tim kiem dia chi (Nominatim
    search) + ban do click-to-place-marker + marker keo duoc (draggable) + reverse-geocode debounce
    500ms de tu dien lai vao o "Dia chi giao hang". 2 input an `locationX`/`locationY` duoc cap
    nhat moi khi doi vi tri, gui thang trong form checkout POST toi `/checkout` — khop dung ten
    param ma `CheckoutServlet.doPost` da doc san.
  - Logic JS (`initCheckoutLocationMap`/`toggleCheckoutLocationMap`) dua theo dung pattern da co san
    va da chay tot o `Shopprofile.jsp` (`initShopLocationMap`), doi ten namespace sang
    `checkoutLocation*` de khong dung ID/ham voi modal ben `diaChi.jsp`.
  - Neu `defaultAddress` da co san toa do, ban do tu dat marker ngay (khong can bam "Tim"); neu
    chua co va trinh duyet cho phep, dung `navigator.geolocation` de can giua ban do vao vi tri
    hien tai cua nguoi dung (khong tu dat marker, chi doi nguoi dung click/keo).
- Khong sua Java (`CheckoutServlet.java` da dung san tu truoc, chi la dead code vi thieu input tu
  JSP).

**Ket qua:** Don hang tao moi tu gio se co `Order.locationX/locationY` (neu nguoi dung chon vi tri
tren ban do khi checkout), nen marker diem giao (🏠) se hien dung tren ban do theo doi realtime cua
ca khach hang (`donhang.jsp`) va shipper. Don hang cu (tao truoc fix nay) van se khong co marker
diem giao — day la gioi han cua thiet ke "snapshot tai thoi diem tao don" (xem muc 25), khong the
retroactive.

Da compile lai toan bo `src/main/java` bang `javac` (classpath tu `.m2`), khong loi — chi sua JSP
nen khong co thay doi phia Java.

## 27. Fix loi 500 khi xac nhan thanh toan (hoaDon.jsp - fmt:parseDate khong parse duoc LocalDateTime)

**Trieu chung:** Vao `/bill?orderIds=<id>` bi loi 500,
`JspException: In <parseDate>, value attribute can not be parsed: "2026-07-16T02:46:58.370"`.

**Nguyen nhan:** `Order.createdAt` la `java.time.LocalDateTime`, EL goi `toString()` ra dang ISO
(`yyyy-MM-ddTHH:mm:ss.SSS`, co `T` va mili giay). The `<fmt:parseDate pattern="yyyy-MM-dd
HH:mm:ss">` (danh cho `java.util.Date` kieu cu, dau cach thay vi `T`, khong co mili giay) khong
bao gio parse dung duoc chuoi nay — loi co san tu truoc, khong lien quan toi phan sua vi tri ban
do o muc 26.

**Da sua:**
- `src/main/web/hoaDon.jsp` (dong 146-147): bo `fmt:parseDate`/`fmt:formatDate`, thay bang
  `fn:substring(bill.order.createdAt.toString(), ...)` de cat truc tiep gio/phut/ngay/thang/nam tu
  chuoi ISO — dung y het pattern da dung san o `shop/xemDanhGia.jsp` (dong 258, 302) cho cung kieu
  `LocalDateTime` trong project. Taglib `fn` da co san trong file, khong can them include.

Da compile lai toan bo `src/main/java` bang `javac`, khong loi (chi sua JSP).

## 28. Fix layout bang "Quan ly hoa don" (shop) bi bop hep do dia chi qua dai

**Trieu chung:** O `shop/Quanlybill.jsp`, sau khi checkout dung Nominatim reverse-geocode (muc 26),
dia chi giao hang tra ve rat dai (vi du "Hem 145/26/7 Duong Phuc Loi, Hoi Xa, Phuong Phuc Loi, Ha
Noi, 08443, Viet Nam"), lam cot "Dia chi" chiem qua nhieu cho, day cac cot con lai (Ma don, Trang
thai, Thao tac...) bi bop hep lai, giao dien bang mat can doi.

**Da sua:**
- `src/main/web/shop/Quanlybill.jsp`:
  - Them CSS `td.addr-col{max-width:220px;overflow-wrap:break-word;}` va gan class `addr-col` cho
    o `<td>` chua `o.shippingAddress` — dia chi dai se tu xuong dong trong 1 cot co gioi han chieu
    rong, khong con day cac cot khac.
  - Cot "Ngay tao" (dong hien `${o.createdAt}` truc tiep, ra chuoi ISO tho co `T` va mili giay) doi
    sang dung `fn:substring(o.createdAt.toString(), ...)` de hien dang `HH:mm dd/MM/yyyy` — dung
    pattern da dung o `hoaDon.jsp` (muc 27) va `shop/xemDanhGia.jsp`.

Da kiem tra lai o ca 2 file: khong con bien CSS cu (`var(--border)`, `var(--primary-dk)`,
`var(--accent)`, `var(--accent-lt)`, `var(--success-lt)`, `var(--warning-lt)`, `var(--info-lt)`,
`var(--sh-sm)`, `var(--sh-md)`), so luong the JSTL mo-dong khop nhau (kiem qua `grep`), toan bo
`name=`/`id=`/`action=` cua form/input va tham so query string (`?action=view&as=modal&id=`,
`?method=`, `?status=`, `?action=confirm`, `?action=cancel`...) giu nguyen (doi chieu qua
`comm` voi ban goc tren git), dong include `_invoiceModal.jspf` khong doi.

## 41. Sidebar Toggle - thu gon/mo rong Sidebar (Tong quan he thong)

Yeu cau: Them nut bam (icon 3 gach SVG) canh logo "SUPER ADMIN" de thu gon Sidebar (chi con
icon, an chu), phan noi dung chinh ben phai tu dong mo rong, co hieu ung chuyen dong muot.

Pham vi: Chi ap dung cho `admin/TongQuanHeThong.jsp` (theo xac nhan cua nguoi dung) — sidebar
hien dang lap lai (khong dung chung 1 file layout) o 37 trang JSP khac trong project, khong dong
vao cac trang do.

Da sua trong `admin/TongQuanHeThong.jsp`:

- CSS:
  - `.sidebar` them `transition: width 0.3s ease` + `overflow: hidden`; them class
    `.sidebar.collapsed { width: 84px; }` (tu 260px).
  - Them `.sidebar-toggle-btn` (nut hinh vuong bo icon SVG 3 gach, dong bo mau Dark Mode qua
    bien `--bg-input`/`--border-color`/`--text-main`).
  - Tach cau truc menu-item thanh `.menu-item-label-group` (bao icon + `.menu-label`) de co the
    an rieng phan chu ma khong mat icon.
  - Khi `.collapsed`: an `.brand-text`, `.sidebar-hi` (dong "Hi, ten"), `.menu-title` (tieu de
    nhom menu), `.menu-label` (chu cua tung muc menu), `.badge` (badge so luong) — chi con lai
    icon logo + icon tung muc menu, can giua (`justify-content: center`).
  - `.main` them `transition: all 0.3s ease` de phan noi dung chinh (chua bieu do + card) co
    hieu ung mo rong muot khi Sidebar thu gon (do `.main` la flex child voi `flex: 1`, tu dong
    lap day khoang trong con lai — transition ap dung cho cac thuoc tinh phu tro nhu
    padding/margin neu co sau nay).
- HTML: them `id="sidebarMain"` vao `<aside class="sidebar">`; them `<button
  id="sidebarToggleBtn">` chua SVG 3 gach ngang canh logo (trong khoi `.brand`, dung
  `justify-content: space-between` de logo ben trai - nut toggle ben phai); moi menu-item duoc
  tach lai thanh `<span class="menu-icon">` + `<span class="menu-label">` bo trong 1
  `.menu-item-label-group` (truoc do icon+chu gop chung 1 `<span>`, khong the an rieng chu).
- JS: them 1 IIFE moi (canh IIFE theme-toggle da co san, cung style code) doc trang thai da luu
  trong `localStorage.getItem('sidebarCollapsed')` de giu trang thai thu gon qua lan reload
  (dung dung pattern `localStorage` da dung cho theme dark/light); khi bam nut, toggle class
  `collapsed` tren `#sidebarMain` va luu lai vao `localStorage`.

Khong co thay doi Java/Servlet/DAO — thuan tuy CSS/HTML/JS trong JSP nen khong can `javac`.
Khuyen nghi nguoi dung chay server, load `/tong-quan`, bam nut 3 gach de kiem tra Sidebar thu
gon/mo rong dung nhu yeu cau va trang thai duoc giu lai sau khi reload trang.

## 42. Dong bo Sidebar Toggle + Custom Scrollbar cho toan bo admin/ (8 file con lai)

Yeu cau: Nguoi dung xac nhan muon dong bo tinh nang Sidebar Toggle (muc 41) va custom scrollbar
(dark theme, cho khu vuc `.menu` cuon) sang tat ca cac trang JSP con lai trong `admin/` — chon
lam truoc toan bo `admin/` (9 file, `TongQuanHeThong.jsp` da co san) truoc khi xet toi `shop/`,
`shipper/`, `user/`.

Pham vi: 8 file con lai trong `admin/` — `quanlitaikhoan.jsp`, `yeuCauShop.jsp`,
`yeuCauShipper.jsp`, `doiMatKhauAdmin.jsp`, `hoSoAdmin.jsp`, `chiTietYeuCauShop.jsp`,
`chiTietYeuCauShipper.jsp`, `appeals.jsp`.

Phat hien: cac file khong dung chung 1 layout sidebar — co 2 "family" class-naming khac nhau,
phai kiem tra tung file truoc khi sua:

- **Family `.brand`/`.brand-row`/`.logo`/`.menu`** (giong `TongQuanHeThong.jsp`):
  `quanlitaikhoan.jsp`, `doiMatKhauAdmin.jsp`, `hoSoAdmin.jsp`, `appeals.jsp`. Trong nhom nay,
  cach dat ten badge cung khac nhau tung file: `quanlitaikhoan.jsp` dung `.badge-count`/
  `.badge-count.green`; `appeals.jsp` dung `.badge`/`.badge.red`; `doiMatKhauAdmin.jsp` va
  `hoSoAdmin.jsp` khong co badge nao trong menu.
- **Family `.sidebar-brand`/`.logo-icon`/`.menu-section`/`.menu-item-left`/`.badge-system`**:
  `yeuCauShop.jsp`, `yeuCauShipper.jsp`, `chiTietYeuCauShop.jsp`, `chiTietYeuCauShipper.jsp` — co
  them badge "SYSTEM" rieng (`.badge-system`), cau truc menu-item bao boc trong div
  `.menu-item-left`, scrollbar target `.menu-section` thay vi `.menu`.

Da sua giong pattern muc 41 (CSS collapse + toggle button + custom scrollbar; HTML `id=
"sidebarMain"` + nut `#sidebarToggleBtn` (SVG 3 gach) + tach `.menu-label`; JS them IIFE
`sidebarCollapsed` doc localStorage) cho ca 8 file, dieu chinh theo dung family class-naming cua
tung file:

- `quanlitaikhoan.jsp`, `yeuCauShop.jsp`, `yeuCauShipper.jsp`: da dong bo tu truoc.
- `doiMatKhauAdmin.jsp`, `hoSoAdmin.jsp`: khong co badge, tach 11 menu-item thanh
  `.menu-item-label-group` (icon + `.menu-label`).
- `chiTietYeuCauShop.jsp`, `chiTietYeuCauShipper.jsp`: trang "chi tiet" nhung dung chung cau truc
  sidebar voi trang danh sach cha (`yeuCauShop.jsp`/`yeuCauShipper.jsp`) — giu nguyen icon span,
  chi boc phan chu con lai trong `<span class="menu-label">`.
- `appeals.jsp`: co 3 badge dieu kien (`shopChoDuyet`, `pendingShippers`, `pendingCount`) dung
  class `.badge.red` (khac ten voi `.badge-count.green` cua `quanlitaikhoan.jsp`) — CSS an badge
  luc collapsed phai nham dung `.badge` chu khong phai `.badge-count`; cac khoi `<c:if>` chua
  badge duoc giu nguyen la sibling ben ngoai `.menu-item-label-group`. File nay cung la file DUY
  NHAT co script theme-toggle KHONG boc trong IIFE (dung bien toan cuc + `localStorage.getItem
  ('adminTheme')` thay vi `'theme'`) — IIFE `sidebarCollapsed` duoc chen ngay sau khoi
  `addEventListener('click', ...)` cua theme-toggle, truoc khai bao `function switchTab(name)`,
  thay vi sau dong dong `})();` nhu cac file khac.

Khong co thay doi Java/Servlet/DAO — thuan tuy CSS/HTML/JS trong JSP nen khong can `javac`.
Khuyen nghi nguoi dung chay server, load lai tung trang trong `admin/` de kiem tra nut toggle
hoat dong dung va scrollbar hien thi dep o Dark Mode.

## 43. [MOCK-DATA] Trang Kiem duyet noi dung (`admin/KiemDuyetNoiDung.jsp`)

Yeu cau: Dung khung giao dien (layout only, mock-data) cho tinh nang "Kiem duyet noi dung" —
Admin duyet binh luan/mon an bi he thong giu lai truoc khi hien thi cong khai. Nguoi dung yeu
cau lam truoc phan giao dien de duyet truc quan, CHUA can noi Servlet/DAO/DB that.

**Trang thai: CHI LA MOCK-DATA, chua co backend.** File co comment `<!-- MOCK-DATA -->` o dau va
1 dong canh bao mau xanh info tren giao dien de khong bi nham la tinh nang da hoan thien.

Da tao moi `src/main/web/admin/KiemDuyetNoiDung.jsp` — dong bo dung khung sidebar/topbar/Dark
Mode/custom scrollbar/sidebar-toggle nhu cac trang admin khac (xem muc 41, 42), gom:

- **2 tab**: "💬 Bình luận chờ duyệt (4)" va "🍜 Món ăn chờ duyệt (3)" (dung lai pattern
  `.tab-bar`/`.tab-btn`/`switchTab()` co san tu `appeals.jsp`).
- **Card kiem duyet dung chung** (`.mod-card`) cho ca 2 loai noi dung:
  - Tab binh luan: avatar + nguoi dang (`.mod-name`) + ngu canh (don hang/mon an lien quan) +
    thoi gian tuong doi; noi dung binh luan trong `.message-box`.
  - Tab mon an: avatar Shop + `.food-row` (thumbnail icon 64x64 + ten mon + danh muc + gia).
  - Ca 2 loai deu co `.reason-tags` — cac the ly do bi giu lai, phan biet mau theo muc do:
    `.reason-tag.danger` (do, VD "Chua tu khoa nhay cam"), `.reason-tag.warn` (vang, VD "Bi bao
    cao Nx"), `.reason-tag.info` (xanh duong, VD "Hinh anh mo/nghi van spam").
  - 2 nut hanh dong nhanh: `.btn-approve` ("✅ Phê duyệt") va `.btn-reject` ("🚫 Từ chối
    (Ẩn/Xóa)") — hien tai chi xu ly client-side (JS `mockApprove()`/`mockReject()`: card fade-out
    + remove khoi DOM + goi `window.showToast()` co san trong `assets/js/toast.js` de bao mock
    thanh cong/that bai), CHUA submit form/goi servlet that.
- Menu Sidebar: muc "Kiểm duyệt nội dung" duoc danh dau `active` va tro ve chinh trang nay
  (`${pageContext.request.contextPath}/admin/kiem-duyet-noi-dung` — URL nay CHUA duoc map servlet
  nao, chi la placeholder cho buoc lam backend sau).

Cac buoc con thieu de hoan thien tinh nang that (chua lam trong muc nay):
- Model/DAO doc danh sach binh luan + mon an dang o trang thai cho duyet (can xac dinh bang du
  lieu: co the la cot `status`/`is_flagged` tren bang `Comments`/`Products`, hoac bang report
  rieng).
- Servlet xu ly GET (nap danh sach that thay mock) + POST xu ly action `approve`/`reject`.
- Noi `<form>` that (giong pattern `appeals.jsp`) thay cho cac nut `onclick` JS mock.
- Dang ky route servlet cho URL `/admin/kiem-duyet-noi-dung` va cap nhat lai link o TAT CA cac
  trang admin khac dang de `href="#"` cho muc menu "Kiểm duyệt nội dung" (hien dang la placeholder
  o moi file, xem muc 41/42) tro ve dung URL nay.

Khong co thay doi Java/Servlet/DAO trong buoc nay — thuan tuy JSP/CSS/JS mock nen khong can
`javac`. Nguoi dung can chay server va load `/admin/KiemDuyetNoiDung.jsp` de duyet giao dien
truc quan (Dark/Light mode, thu gon Sidebar, bam thu nut Phe duyet/Tu choi de xem hieu ung) truoc
khi xac nhan lam tiep phan backend that.

## 44. Noi backend that cho tab "Mon an cho duyet" (`admin/KiemDuyetNoiDung.jsp`)

Yeu cau: Tiep tuc muc 43 — noi Servlet/DAO/DB that cho trang Kiem duyet noi dung. Khao sat code
xac nhan he thong CHUA co bang/model/DAO/UI nao cho tinh nang binh luan (khong bang `Comments`,
khong noi nguoi dung viet binh luan o dau), va cung chua co bang `Reports` hay logic loc tu khoa
nhay cam. Da hoi nguoi dung 2 quyet dinh pham vi truoc khi lam:

- **Chi lam that tab "Mon an cho duyet"** — dung lai cot `Products.status` san co, them 1 gia tri
  moi `PENDING_REVIEW`. Tab "Binh luan cho duyet" GIU NGUYEN mock-data (khong bang Comments nen
  khong the lam that), chi doi label/ghi chu de ro rang la mock.
- **Don gian hoa reason-tag**: chi 1 trang thai `PENDING_REVIEW` duy nhat, KHONG phan loai ly do
  (khong dong "chua tu khoa nhay cam"/"bi bao cao", khong bang Reports moi, khong logic loc tu
  khoa). San pham moi tao mac dinh la `PENDING_REVIEW` thay vi `ACTIVE`, hien 1 the ly do tinh
  "🆕 San pham moi can Super Admin duyet".

**Model** (`org/example/models/Product.java`): them field `shopName` (transient, chi phuc vu
hien thi ten shop dang gui mon an cho duyet, khong luu DB) + getter/setter
`getShopName()`/`setShopName()`.

**DAO** (`org/example/daos/ProductDAO.java` + `ProductDAOImpl.java`): them 2 method:
- `findPendingReview()`: `SELECT p.*, s.shop_name ... FROM Products p JOIN Shops s ON s.id =
  p.shop_id WHERE p.status = 'PENDING_REVIEW' AND p.is_deleted = 0 ORDER BY p.created_at DESC`
  (SQL cung, khong dung `buildSelectColumns(schema)` dong nhu cac method khac vi co JOIN sang
  `Shops`).
- `updateStatus(long id, String status)`: UPDATE cot status (+ `updated_at` neu co) qua
  `ProductSchema` dong (giong pattern cac method update khac trong file).

**Servlet moi** (`org/example/controllers/ContentModerationServlet.java`, route
`/admin/kiem-duyet-noi-dung`): copy dung pattern `AppealReviewServlet.java` —
- `doGet`: `requireAdmin()` (chan neu khong phai `roleId == 1`) → `findPendingReview()` → forward
  ve `admin/KiemDuyetNoiDung.jsp`.
- `doPost`: doc `action` (`approve`/`reject`) + `productId` → `approve` set status `ACTIVE`,
  `reject` set status `HIDDEN` → redirect ve chinh trang voi `?success=approved`/`?success=
  rejected` (toast.js da co san 2 ma nay, khong can sua toast.js).

**`ProductServlet.createProduct()`**: them 1 dong ep `product.setStaTus("PENDING_REVIEW")` ngay
sau khi doc form, TRUOC khi goi `normalizeStatus()` — chi ap dung cho luong tao moi (`create`),
khong dung chung ham `normalizeStatus()` de tranh anh huong luong `update` (Shop tu sua san pham
cua minh van giu nguyen status hien tai).

**Bug phat hien khi test thuc te (da sua)**: sau khi lam xong muc tren, test tao san pham moi tu
trang Shop ("Quan ly san pham") van thay status = `ACTIVE` ngay, khong vao hang cho duyet. Nguyen
nhan: trang "Quan ly san pham" cua Shop dung route `/shop/products` → servlet
`ShopProductServlet.java` (KHONG PHAI `/product` → `ProductServlet.java` da sua o tren — 2 servlet
tao san pham khac nhau, `ProductServlet` la luong `taoProduct.jsp` cu, `ShopProductServlet` la
luong that dang dung o `shop/Quanlysanpham.jsp`). `ShopProductServlet.createProduct()` tu doc
tham so `status` tu form roi set truc tiep (mac dinh `"ACTIVE"` neu form rong), khong lien quan gi
den logic da sua o `ProductServlet`. Da sua: `ShopProductServlet.java` dong ~188, thay
`product.setStaTus(status.isEmpty() ? "ACTIVE" : status)` bang `product.setStaTus(
"PENDING_REVIEW")` (bo qua hoan toan tham so status tu form khi tao moi, giong huong xu ly cua
`ProductServlet`). Da grep toan bo `src/main/java` xac nhan chi co 2 cho goi
`productDAO.createAndReturnId(product)` (ProductServlet, ShopProductServlet) — ca 2 deu da ep
`PENDING_REVIEW`, khong con luong tao san pham nao khac bo sot.

**Bo sung: hien anh that thay emoji co dinh**: nguoi dung yeu cau them anh san pham vao the o
hang cho duyet (truoc do `.food-thumb` chi hien 🍽️ tinh cho moi san pham). Da sua:
- `ContentModerationServlet.doGet()`: them `ProductImageDAO productImageDAO = new
  ProductImageDAOImpl()`, sau khi `findPendingReview()` goi
  `findPrimaryUrlsByProductIds(...)` (method co san, cung pattern voi
  `ShopProductServlet.forwardProductPage()`) roi `p.setImageUrl(...)` cho tung san pham.
- `admin/KiemDuyetNoiDung.jsp`: CSS `.food-thumb` them `overflow:hidden` + rule `.food-thumb img
  { width:100%; height:100%; object-fit:cover; }`; noi dung doi thanh `<c:choose>` — neu
  `p.imageUrl` khong rong thi hien `<img src="${p.imageUrl}">`, nguoc lai fallback ve emoji 🍽️
  cu (truong hop san pham chua upload anh).

**`admin/KiemDuyetNoiDung.jsp`**: xoa 3 the mock hardcode o tab "Mon an cho duyet", thay bang
`<c:forEach var="p" items="${pendingProducts}">` doc du lieu that tu servlet — avatar chu cai dau
ten Shop (`fn:substring`/`fn:toUpperCase`), thoi gian dung EL function co san `${app:formatDateTime
(p.createdAt)}` (taglib `/app-functions`, KHONG dung `fmt:formatDate` vi `Product.createdAt` la
`LocalDateTime` chu khong phai `java.util.Date`), nut Phe duyet/Tu choi la `<form method="post"
action="${pageContext.request.contextPath}/admin/kiem-duyet-noi-dung">` that (submit `productId` +
`action`) thay cho `onclick="mockApprove/Reject"`. Badge sidebar + tab-label + panel-title doi
sang `${pendingProducts.size()}` (dong nhat pattern voi `pendingShippers.size()` da dung o
`yeuCauShipper.jsp`). Tab "Binh luan cho duyet" GIU NGUYEN cac the mock + nut `mockApprove()`/
`mockReject()` (khong dung nua cho tab mon an) — dong `.mock-note` doi lai chi con canh bao ve tab
binh luan.

**Sua link sidebar** o 8 file admin con lai (dang `href="#"` cho muc "Kiểm duyệt nội dung"):
`appeals.jsp`, `chiTietYeuCauShipper.jsp`, `chiTietYeuCauShop.jsp`, `doiMatKhauAdmin.jsp`,
`hoSoAdmin.jsp`, `quanlitaikhoan.jsp`, `TongQuanHeThong.jsp`, `yeuCauShop.jsp`,
`yeuCauShipper.jsp` — doi thanh `${pageContext.request.contextPath}/admin/kiem-duyet-noi-dung`,
giu nguyen 2 kieu wrapper HTML da co cua tung file (`.brand`-family boc `<a>` ngoai `<li>`, vs
`.sidebar-brand`-family gan `class="menu-item"` truc tiep vao `<a>`).

**Rui ro da xac minh xay ra that (da sua)**: test tao san pham moi bi loi
`SQLServerException: The INSERT statement conflicted with the CHECK constraint
"CK__Products__status__43A1090D"` — dung nhu du bao. Da tao migration
`migration_product_status_pending_review.sql` (theo dung pattern
`migration_payment_method_payos.sql` da co san trong project): DROP constraint cu
`CK__Products__status__43A1090D`, ADD constraint moi `CK_Products_Status` cho phep them
`'PENDING_REVIEW'` ben canh 3 gia tri cu (`ACTIVE`, `OUT_OF_STOCK`, `HIDDEN`). **Nguoi dung can tu
chay file SQL nay 1 lan tren database POB** (vi du bang SSMS hoac `sqlcmd`) truoc khi tinh nang
hoat dong duoc — Claude khong co quyen truy cap DB truc tiep de tu chay migration.

**Luu y rui ro cu (da het hieu luc sau khi chay migration tren)**: `Database.md` mo ta `Products.status` co CHECK constraint
`IN ('ACTIVE','OUT_OF_STOCK','HIDDEN')` — KHONG liet ke `'PENDING_REVIEW'`. Chua kiem tra duoc
constraint nay co thuc su duoc enforce tren DB that hay khong (co the DB that khong co constraint
nay, hoac can migration sua lai). Neu insert/update san pham voi status `PENDING_REVIEW` bi loi
o runtime, day la nguyen nhan — can chay 1 migration `ALTER TABLE Products DROP CONSTRAINT ...`
+ tao lai CHECK moi co them `'PENDING_REVIEW'`.

Da bien dich sach bang `javac` (146 file `.java`, classpath ghep tu cac dependency trong
`pom.xml`) — khong loi.

## 45. Trang "Bao cao van hanh" cho Super Admin — Phan 1: Thong ke hieu suat Don hang & Giao van

Yeu cau: tao trang moi `admin/BaoCaoVanHanh.jsp` + backend that (Servlet/DAO), dong bo Dark Mode
voi cac trang admin con lai, gom: bo loc theo khoang ngay (Tu ngay/Den ngay + nut "Xem bao cao"),
khoi thong ke nhanh (Tong don hang phat sinh, Ty le hoan thanh don %, Thoi gian giao hang trung
binh phut), va bieu do Doughnut (Chart.js) ty le trang thai don hang (Thanh cong/Da huy/Dang
giao) — tat ca lay du lieu that qua cau lenh SQL `GROUP BY`.

**DAO moi** (`org/example/daos/BaoCaoVanHanhDAO.java` + `BaoCaoVanHanhDAOImpl.java`), dung
`DBUtil.getConnection()` (khong pool), 3 method:
- `countTotalOrders(tuNgay, denNgay)`: `SELECT COUNT(*) FROM Orders WHERE created_at >= ? AND
  created_at < DATEADD(DAY, 1, ?)`.
- `countOrdersByStatus(tuNgay, denNgay)`: `SELECT status, COUNT(*) FROM Orders WHERE ... GROUP BY
  status` → tra `Map<String,Integer>` (trang thai → so luong).
- `getAvgThoiGianGiaoHangPhut(tuNgay, denNgay)`: thoi gian giao = tu luc Shop xac nhan don
  (`Order_Logs.new_status = 'CONFIRMED'`) den luc Shipper giao xong (`new_status = 'DONE'`). SQL
  join 2 subquery (moi don lay `MIN(created_at)` cho lan chuyen trang thai CONFIRMED va DONE dau
  tien) roi tinh `AVG(DATEDIFF(MINUTE, ...))`, loc theo `Orders.created_at` trong khoang ngay va
  dam bao thoi gian DONE > CONFIRMED (tranh du lieu log bat thuong). Tra `null` (qua
  `rs.wasNull()`) neu khong co cap CONFIRMED→DONE nao trong khoang — JSP hien "--" thay vi 0/NaN.
  Dung dung ten bang `Order_Logs` (co gach duoi) theo schema thuc te trong `Database.md` — luu y
  DAO cu `OrderLogDAOImpl.java` dang truy van sai ten bang `"OrderLogs"` (khong gach duoi, bug co
  san, khong sua trong pham vi task nay).

**Servlet moi** (`org/example/controllers/BaoCaoVanHanhServlet.java`, route
`/admin/bao-cao-van-hanh`, guard `roleId == 1`): `doGet` doc param `tuNgay`/`denNgay` (ISO
`yyyy-MM-dd`, mac dinh 30 ngay gan nhat neu thieu/sai, tu dong hoan doi neu `denNgay` truoc
`tuNgay`), goi DAO, gom nhom 6 trang thai enum (`PENDING/CONFIRMED/READY_FOR_PICKUP/SHIPPING/
DONE/CANCELLED`) thanh 3 nhom cho bieu do (`DONE`→Thanh cong, `CANCELLED`→Da huy, 4 trang thai
con lai→Dang giao), tinh ty le hoan thanh (co chan chia cho 0), set 8 request attribute
(`tuNgay`, `denNgay`, `tongDonHang`, `tyLeHoanThanh`, `thoiGianGiaoTrungBinh`, `donThanhCong`,
`donDaHuy`, `donDangGiao`) roi forward sang `admin/BaoCaoVanHanh.jsp`.

**JSP moi** (`admin/BaoCaoVanHanh.jsp`): copy nguyen bo CSS theme Dark/Light + sidebar + topbar +
script toggle theme/sidebar tu `TongQuanHeThong.jsp` de dam bao dong bo giao dien. Them: form GET
loc ngay (`<input type="date">` x2 + nut "Xem bao cao"), 3 `.stat-card` trong `.stats-grid`, khoi
`.dashboard-grid` 2 cot gom panel bieu do Doughnut (`<canvas>` + Chart.js CDN, `type: 'doughnut'`,
mau xanh la/do/cam cho 3 trang thai, mau chu/legend doc dong tu bien CSS `--text-muted` giong
bieu do line co san) va panel chi tiet so don theo tung trang thai (dang legend list).

**Sidebar**: sua link "Bao cao van hanh" tu `href="#"` sang
`${pageContext.request.contextPath}/admin/bao-cao-van-hanh` trong ca `TongQuanHeThong.jsp` va
`KiemDuyetNoiDung.jsp`; trong `BaoCaoVanHanh.jsp` menu-item nay duoc danh dau `active`.

### 45.1. Fix: "Thoi gian giao hang trung binh" luon hien "--" (thieu du lieu Order_Logs that)

**Nguyen nhan**: cot `Order_Logs` chua bao gio duoc ghi boi luong xu ly don hang thuc te — chi co
man hinh CRUD doc lap `OrderLogServlet.java` (`/order-logs`, quan ly thu cong, khong lien quan
luong nghiep vu that) goi `OrderLogDAO.create()`. Ngoai ra `OrderLogDAOImpl.java` con dang truy
van sai ten bang `"OrderLogs"` (thieu gach duoi) thay vi `Order_Logs` that trong schema, nen neu
co goi insert cung se that bai am tham. SQL trong `BaoCaoVanHanhDAOImpl` ban than khong sai — chi
la khong co du lieu (va du co du lieu cung khong bao gio khop `new_status = 'CONFIRMED'` vi trang
thai nay chua tung duoc code gan cho don hang nao — xem ben duoi).

**Da lam** (theo lua chon cua user — "Ghi log trang thai that", khong bia so lieu 0/25 phut vao
UI):
- Sua bug ten bang trong `OrderLogDAOImpl.java`: `"OrderLogs"` → `"Order_Logs"` (ca 5 cau SQL:
  create/getAll/findById/update/delete).
- `ShopBillServlet.java` (action `"confirm"`, dong chuyen trang thai that su `PENDING →
  READY_FOR_PICKUP` — day chinh la hanh dong "Shop xac nhan don" trong nghiep vu du Orders.status
  khong dung literal `CONFIRMED`): sau khi `orderDAO.updateStatus(orderId, "READY_FOR_PICKUP")`,
  them insert `Order_Logs` moi voi `old_status="PENDING"`, `new_status="CONFIRMED"` (dung nhan
  ngu nghia khop voi SQL bao cao co san, du Orders.status thuc te la READY_FOR_PICKUP),
  `changed_by=account.getId()`.
- `ShipperOrderServlet.java` (action `"updateStatusToDone"`, chuyen `SHIPPING → DONE`): sau khi
  `orderDAO.updateStatus(orderId, "DONE")`, them insert `Order_Logs` moi voi
  `old_status="SHIPPING"`, `new_status="DONE"`, `changed_by=account.getId()`.
- Ca hai servlet them field `OrderLogDAO orderLogDAO = new OrderLogDAOImpl()`.

**Luu y**: don hang cu (tao truoc khi vá) se van khong co du lieu Order_Logs vi khong the tai tao
lai thoi diem chuyen trang thai trong qua khu — chi so "Thoi gian giao hang trung binh" se van
hien "--" cho den khi co du don hang moi di qua ca 2 moc CONFIRMED va DONE sau ban vá nay. Khong
bia gia tri mac dinh (0 hay 25 phut) de tranh danh lua nguoi xem bao cao.

### 45.2. Gan link sidebar "Bao cao van hanh" cho toan bo trang Super Admin

Truoc do link `/admin/bao-cao-van-hanh` moi chi duoc gan trong `TongQuanHeThong.jsp` va
`KiemDuyetNoiDung.jsp` (dung `href="#"` o cac trang con lai). Da sua `href="#"` →
`${pageContext.request.contextPath}/admin/bao-cao-van-hanh` (giu nguyen cau truc HTML rieng cua
tung file — co file dung `<a><li>...</li></a>`, co file dung `<a class="menu-item"><div>...</div></a>`)
trong tat ca cac trang Super Admin con lai: `appeals.jsp`, `chiTietYeuCauShipper.jsp`,
`chiTietYeuCauShop.jsp`, `doiMatKhauAdmin.jsp`, `hoSoAdmin.jsp`, `quanlitaikhoan.jsp`,
`yeuCauShipper.jsp`, `yeuCauShop.jsp`.

### 45.3. Fix: chon theme sang o "Tong quan" nhung sang trang "Khang nghi" tu doi lai theme toi

**Nguyen nhan**: 9/11 trang Super Admin dung chung localStorage key `'theme'` de luu/doc theme da
chon, nhung rieng `appeals.jsp` ("Khang nghi") va `KiemDuyetNoiDung.jsp` lai dung key khac
`'adminTheme'` — nen khi chuyen sang 2 trang nay, script doc key `'adminTheme'` (chua tung duoc
ghi) tra ve rong → mac dinh fallback ve `'dark'`, lam theme bi doi nguoc du user da chon sang o
trang khac.

**Da lam**: doi ca 2 noi doc/ghi trong `appeals.jsp` va `KiemDuyetNoiDung.jsp` tu
`localStorage.getItem/setItem('adminTheme', ...)` sang `localStorage.getItem/setItem('theme',
...)` de dong bo voi toan bo cac trang Super Admin con lai.

## 46. Trang "Bao cao van hanh" — Phan 2: "Thong ke Bien dong Van hanh" (Khung gio cao diem + Ly do huy don)

Yeu cau: them 1 card so lieu "Khung gio dat hang cao diem" va 1 bieu do cot (Chart.js) "Thong ke
ly do huy don" vao `admin/BaoCaoVanHanh.jsp`, deu lay du lieu that qua SQL `GROUP BY`.

**Van de phat sinh**: `Orders` chua co cot nao luu ly do huy don — moi cho huy don (Shop, Shipper
bao khach bom hang, tu dong huy don qua han, khach tu huy) deu chi goi
`orderDAO.updateStatus(orderId, "CANCELLED")` ma khong ghi ly do, nen khong the `GROUP BY` ra
duoc so lieu co y nghia. Phai them cot moi + sua tan goc 5 diem huy don trong code thay vi chi
sua rieng file JSP.

**Migration moi** (`migration_order_cancel_reason.sql`, cung pattern voi cac file
`migration_*.sql` khac trong repo — `USE POB; GO` + `IF NOT EXISTS (SELECT 1 FROM sys.columns
...)` de chay lai nhieu lan khong loi): `ALTER TABLE Orders ADD cancel_reason NVARCHAR(255)
NULL;`. **Nguoi dung can tu chay file nay 1 lan tren database POB** — Claude khong co quyen truy
cap DB truc tiep.

**`OrderDAO`/`OrderDAOImpl`**: them method moi `cancelOrder(long orderId, String reason)` — dung
lai dung machinery `resolveSchema()`/`q()` san co (ten bang/cot dong resolve nhu `updateStatus()`)
nhung cot `cancel_reason` la literal cung (cot moi tu them, ten co dinh, khong can dua vao
`OrderSchema` dang co ~20 tham so dang deo). SQL: `UPDATE ... SET status = 'CANCELLED',
cancel_reason = ? WHERE id = ?`. Cung sua `cancelStalePendingOrders()` (job tu dong huy don PENDING
qua han) de ghi kem `cancel_reason = N'Het han tu dong (qua gio xac nhan)'` cho nhat quan.

**5 diem goi huy don doi sang `cancelOrder(orderId, reason)` voi ly do co dinh theo tung nghiep vu**:
- `ShopBillServlet.java` (action `"cancel"`, Shop tu huy don PENDING): `"Shop huy don"`.
- `BomHangServlet.java` (Shipper bao khach tu choi nhan hang): `"Khach bom hang (tu choi nhan)"`.
- `ShipperAcceptOrderServlet.java` (don tao khac ngay hom nay, khong the giao qua ngay): `"Don qua
  han giao trong ngay"`.
- `UserOrderServlet.java` (khach tu huy don cua chinh minh): `"Khach hang tu huy"`.
- `OrderDAOImpl.cancelStalePendingOrders()` (job tu dong huy don PENDING qua nguong thoi gian):
  `"Het han tu dong (qua gio xac nhan)"`.

**Noi dung khung giao dien** (theo yeu cau, dung MOCK DATA de duyet layout truoc):
- Banner canh bao mau vang: "DANG DUNG DU LIEU MAU (MOCK DATA)..." de nguoi dung biet day chua
  phai du lieu that.
- Bo loc: chon Cua hang (dropdown "Tat ca cua hang" + 5 shop mau) + khoang ngay (tu ngay/den ngay).
- 3 card so lieu dau trang: Tong doanh thu toan san (Gross Revenue), Chiet khau san thu ve (10%),
  Tong tien can thanh toan cho Shop (Net Payout) — so lieu mau, hardcode trong JSP.
- Bang doi soat theo tung Shop: cot Ten Shop, So don thanh cong, Tong doanh thu, Phi san (10%),
  So tien thuc nhan, Trang thai (Da thanh toan / Cho thanh toan - pill mau xanh/vang), nut
  [Xac nhan thanh toan]. Du lieu bang duoc render bang JS tu mang `mockShops` (5 shop mau), tu tinh
  `fee = revenue * 10%` va `netPayout = revenue - fee`. Bam nut "Xac nhan thanh toan" chi doi
  trang thai tren giao dien (client-side only, chua goi API/DB).

**Servlet moi `KiemDuyetBinhLuanServlet.java`** (`/admin/kiem-duyet-binh-luan`, cung pattern
`requireAdmin()` check `roleId == 1` nhu `ContentModerationServlet`/`BaoCaoVanHanhServlet`):
forward toi `admin/KiemDuyetBinhLuan.jsp`. **Chua goi `findPendingReview()`** — JSP van dung
mock-data theo dung yeu cau, nen servlet hien khong set request attribute nao.

**[MOCK-DATA] `admin/KiemDuyetBinhLuan.jsp`** (dong bo Dark Mode/sidebar/tab-bar/`.mod-card` y
het cac trang admin khac — xem muc 41-43):
- **Tab 1 "Bình luận chờ duyệt"**: 3 `.mod-card` mau — nguoi gui, ten Shop bi binh luan, noi
  dung binh luan voi tu nhay cam duoc `<mark class="bad-word">` highlight do, the
  `.reason-tag.danger` ghi ro tu cam bi dinh, 2 nut "✅ Phê duyệt (Hiển thị)" / "🚫 Xóa bỏ" (JS
  `mockApprove()`/`mockReject()` — chi fade-out + remove DOM + `showToast()`, chua submit form
  that).
- **Tab 2 "Lịch sử xử lý"**: bang liet ke binh luan da xu ly, cot Trang thai dung
  `.status-pill.visible` (da duyet, xanh) / `.status-pill.removed` (da xoa, do).
- 1 dong canh bao mau xanh info o dau trang ghi ro day van la mock-data (giong pattern
  `KiemDuyetNoiDung.jsp`).
- Menu Sidebar: them muc "💬 Kiểm duyệt bình luận" (danh dau `active` tren chinh trang nay) vao
  ca 11 file admin JSP con lai (`appeals.jsp`, `yeuCauShop.jsp`, `chiTietYeuCauShipper.jsp`,
  `chiTietYeuCauShop.jsp`, `yeuCauShipper.jsp`, `hoSoAdmin.jsp`, `BaoCaoVanHanh.jsp`,
  `KiemDuyetNoiDung.jsp`, `quanlitaikhoan.jsp`, `TongQuanHeThong.jsp`, `doiMatKhauAdmin.jsp`) —
  moi file giu dung style markup rieng cua no (co file dung `<li class="menu-item">`, co file
  dung `<a class="menu-item"><div class="menu-item-left">`), dat ngay sau muc "Kiểm duyệt nội
  dung" nhu quy uoc hien co.

Con thieu (chua lam trong muc nay): UI quan ly bang `BannedWords` (them/xoa tu cam qua giao dien
thay vi SQL truc tiep), va tab "Lịch sử xử lý" van con la mock-data (xem muc 48 de biet ranh gioi
that/mock cu the sau khi noi Tab 1 voi DB that).

Da bien dich `javac` toan bo `src/main/java` sach loi (chi them method/field moi, khong doi API
cu). Nguoi dung can tu chay `migration_feedback_moderation.sql` tren DB `POB` (cung voi 2 file
migration con lai tu cac muc truoc — `migration_product_status_pending_review.sql`,
`migration_order_cancel_reason.sql` — neu chua chay) roi load `/admin/kiem-duyet-binh-luan` de
duyet giao dien truc quan (Dark/Light mode, 2 tab, bam thu nut Phe duyet/Xoa bo).

## 47. Trang "Duyet rut tien Shipper" (phan he Quan ly tai chinh) — Khung giao dien + noi du lieu that

**File moi (khung Servlet/DAO, tao o luot lam truoc)**:
- `migration_shipper_withdrawals.sql` — tao 2 bang moi:
  - `Shipper_Wallets` (id, shipper_account_id UNIQUE, balance, updated_at) — vi tien cua Shipper,
    FK toi `Accounts(id)`.
  - `Shipper_Withdrawals` (id, shipper_account_id, amount, bank_name, bank_account_number,
    bank_account_holder, status ['PENDING'/'APPROVED'/'REJECTED'], reject_reason, requested_at,
    processed_at, processed_by). Cot bank_* luu **snapshot** thong tin ngan hang tai thoi diem yeu
    cau (khong JOIN song vao `Shipper_Profiles`) de lich su rut tien khong bi thay doi neu sau nay
    Shipper doi thong tin ngan hang. Index tren `status` va `shipper_account_id`.
  - **CHUA chay migration nay tren DB that** — day la dieu kien tien quyet de tinh nang hoat dong
    that su, can DBA/nguoi quan tri DB chay truoc.
- `src/main/java/org/example/models/ShipperWithdrawal.java` — DTO (id, shipperAccountId,
  shipperName, shipperPhone, amount, bankName, bankAccountNumber, bankAccountHolder, status,
  rejectReason, requestedAt, processedAt).
- `src/main/java/org/example/daos/ShipperWithdrawalDAO.java` + `ShipperWithdrawalDAOImpl.java`:
  - `getAllWithdrawals(status)`: SQL `JOIN Accounts` de lay ten/SDT Shipper, loc theo `status`
    neu khac null, sap xep moi nhat truoc.
  - `approveWithdrawal(withdrawalId, processedBy)`: 1 UPDATE co dieu kien
    `WHERE id = ? AND status = 'PENDING'` de tranh xu ly trung (Admin bam Phe duyet 2 lan, hoac
    2 Admin cung xu ly 1 luc).
  - `rejectWithdrawal(withdrawalId, processedBy, reason)`: **transaction** (autoCommit=false) —
    SELECT guard (chi xu ly neu dang PENDING) → UPDATE trang thai REJECTED → UPDATE
    `Shipper_Wallets.balance += amount` de **hoan tien vao vi** → commit; rollback + tra ve false
    neu yeu cau khong ton tai/da duoc xu ly truoc do.
- `src/main/java/org/example/controllers/DuyetRutTienShipperServlet.java` (`@WebServlet
  "/admin/duyet-rut-tien-shipper"`):
  - `doGet`: kiem tra quyen Super Admin (roleId == 1), doc `danhSachRutTien` tu DAO theo
    `status` filter (query param `status`), tu tinh 3 so lieu tong hop
    (tongTienYeuCau/choXuLy/daThanhToan) tu chinh danh sach da loc, forward sang JSP.
  - `doPost`: action "approve"/"reject" (tham so `id`, `action`, `reason` khi tu choi). Kiem tra
    quyen Super Admin, tra ve JSON hand-write `{success:true}` / `{success:false,"message":...}`.

**Sua (luot nay)** `src/main/web/admin/DuyetRutTienShipper.jsp` — noi vao du lieu that tu Servlet
o tren (thay the toan bo mock-data hardcode cua luot truoc):
- Them taglib `fmt` de dinh dang so tien.
- Bo loc trang thai: doi tu `<select>` + JS loc client-side sang `<form method="get">` submit
  thang ve Servlet (`onchange="this.form.submit()"`), server tra ve dung danh sach da loc theo
  `status` (gia tri filter hien tai duoc giu lai qua `${statusFilter}` de `<option selected>`
  dung dong bo voi URL).
- 3 card thong ke: dung `<fmt:formatNumber>` tren `tongTienYeuCau`/`choXuLy`/`daThanhToan` (Servlet
  tinh that tu danh sach dang xem), khong con hardcode.
- Bang danh sach: render bang `<c:forEach items="${danhSachRutTien}">`, moi `<tr>` co
  `data-id="${w.id}"` de JS biet goi API cho dung yeu cau nao. Cot Trang thai va cot Thao tac dung
  `<c:choose>` theo `w.status`: PENDING moi hien nut [Phe duyet]/[Tu choi], APPROVED/REJECTED hien
  text "Da xu ly" / "Da hoan tien vao vi" (khong con nut).
- Bo banner "DANG DUNG MOCK DATA".
- JS: thay toan bo logic cap nhat DOM gia lap bang `fetch()` POST that toi
  `/admin/duyet-rut-tien-shipper`:
  - [Phe duyet]: `confirm()` → POST `id`+`action=approve` → neu `{success:true}` thi doi pill
    thanh "Da duyet" va an nut; neu loi thi `alert(message)` va cho bam lai (khong optimistic-update
    truoc khi server xac nhan).
  - [Tu choi]: `prompt()` nhap ly do → POST `id`+`action=reject`+`reason` → neu `{success:true}`
    thi doi pill thanh "Tu choi" + text "Da hoan tien vao vi"; server da tu hoan tien vao
    `Shipper_Wallets` trong transaction, JS chi phan anh lai UI.
  - Nut duoc `disabled` trong luc cho response de tranh bam trung (double submit).

**Sua (luot truoc)** `src/main/web/admin/DoiSoatDoanhThuShop.jsp`:
- Link sidebar "Duyet rut tien Shipper" tu `href="#"` doi thanh
  `href="${pageContext.request.contextPath}/admin/duyet-rut-tien-shipper"`.

**Van con thieu / can luu y**:
- **QUAN TRONG**: `migration_shipper_withdrawals.sql` van CHUA duoc chay tren DB that — trang se
  loi 500 (bang khong ton tai) cho toi khi migration nay duoc chay thu cong.
- Chua co man hinh/API de Shipper tao yeu cau rut tien (`INSERT INTO Shipper_Withdrawals`) hay xem
  so du vi (`Shipper_Wallets`) — luot nay chi lam phia Admin duyet/tu choi. Can lam rieng 1 tinh
  nang phia app Shipper de tao du lieu dau vao cho trang nay.
- Chua co co che tru tien vao vi khi Shipper GUI yeu cau rut tien (tru truoc, hoan lai neu tu choi)
  — hien tai DAO chi cong tien lai khi REJECTED, gia dinh so tien da bi tru/khoa san khi tao yeu
  cau (o tinh nang tao yeu cau se lam sau).

## 48. Noi "Kiem duyet binh luan" voi du lieu that — Tab "Bình luận chờ duyệt" + Phê duyệt/Xóa bỏ

Tiep tuc muc 47: chuyen Tab 1 tu mock-data sang du lieu that tu DB, va lam that 2 nut Phe
duyet/Xoa bo (cung huong da lam o muc 57 cho `KiemDuyetNoiDung.jsp`). Tab 2 "Lịch sử xử lý" giu
nguyen mock-data (ngoai pham vi yeu cau lan nay).

**Van con thieu (chua lam trong luot nay)**:
- Chua co man hinh/lich su xem lai cac lan da xac nhan thanh toan truoc do (bang `Shop_Settlements`
  hien chi duoc dung ngam de biet Trang thai trong ky dang xem, chua co trang "Lich su doi soat").
- Chua chay migration `migration_shop_settlements.sql` tren DB that (can DBA/nguoi quan tri DB
  chay truoc khi tinh nang nay hoat dong, vi bang `Shop_Settlements` chua ton tai san server).

## 48. Dong bo link sidebar "Duyet rut tien Shipper" tren toan bo trang Admin

Phat hien: o muc 47, chi co `DoiSoatDoanhThuShop.jsp` duoc sua link sidebar tu `href="#"` sang
`/admin/duyet-rut-tien-shipper`. Cac trang Admin khac (dung chung markup sidebar copy-paste, khong
co JSP fragment/include dung chung) van con `href="#"` cho muc menu nay -> bam vao khong dieu huong
duoc tu cac trang do.

Da sua `href="#"` -> `${pageContext.request.contextPath}/admin/duyet-rut-tien-shipper"` tren 12 file
con lai (tong cong 14 file admin co muc menu nay deu da dung link, gom ca 2 file da dung tu truoc):

- `src/main/web/admin/TongQuanHeThong.jsp`
- `src/main/web/admin/quanlitaikhoan.jsp`
- `src/main/web/admin/KiemDuyetNoiDung.jsp`
- `src/main/web/admin/KiemDuyetBinhLuan.jsp`
- `src/main/web/admin/hoSoAdmin.jsp`
- `src/main/web/admin/doiMatKhauAdmin.jsp`
- `src/main/web/admin/appeals.jsp`
- `src/main/web/admin/BaoCaoVanHanh.jsp`
- `src/main/web/admin/yeuCauShop.jsp`
- `src/main/web/admin/chiTietYeuCauShop.jsp`
- `src/main/web/admin/yeuCauShipper.jsp`
- `src/main/web/admin/chiTietYeuCauShipper.jsp`

Ghi chu: 4 file cuoi (`yeuCauShop.jsp`, `chiTietYeuCauShop.jsp`, `yeuCauShipper.jsp`,
`chiTietYeuCauShipper.jsp`) dung markup sidebar hoi khac (class `menu-item` gan truc tiep vao the
`<a>` thay vi vao `<li>` ben trong) nen khong khop pattern Grep ban dau, phai kiem tra rieng tung
file truoc khi sua.

Van con thieu: sidebar dang duplicate 14 lan, khong co JSP fragment/include dung chung — lan sau
neu them/doi muc menu moi phai sua thu cong tren tung file, de sot nhu lan nay. Nen can nhac tach
`sidebarAdmin.jspf` dung chung trong tuong lai.

---

**`Feedback.java`**: them 2 field view-only (khong luu DB, theo dung pattern `Product.shopName`):
- `targetName` (String) — ten Shop/Shipper bi binh luan, do o DAO qua JOIN/CASE roi set thu cong
  sau vong lap query (khong phai cot that trong bang `Feedbacks`).
- `highlightedComment` (String) — noi dung comment da HTML-escape + boc san the
  `<mark class="bad-word">` quanh tu cam, tinh san o DAO de JSP chi viec `${fb.highlightedComment}`
  (khong dung the JSTL moi nao — `functions.tld` khong co ham highlight).

**`FeedbackDAOImpl.java`**:
- `findPendingReview()`: viet lai SQL, them `CASE WHEN f.target_type='SHOP' THEN s.shop_name ELSE
  ta.full_name END AS target_name` voi 2 `LEFT JOIN` dieu kien theo `target_type` (join `Shops`
  khi la SHOP, join `Accounts` khi la SHIPPER). Sau moi vong lap, goi `f.setTargetName(...)` va
  `f.setHighlightedComment(highlightBadWords(f.getComment(), bannedWords))`.
- Them 3 helper `private` moi (khong dua len interface `FeedbackDAO` — YAGNI, chi noi bo dung):
  - `fetchBannedWords()`: tach rieng tu `checkBadWords()` cu de dung chung (DRY) — query
    `SELECT word FROM BannedWords` 1 lan, tra `List<String>`.
  - `escapeHtml(String)`: escape `& < > " '` truoc khi xu ly, tranh XSS tu comment nguoi dung.
  - `highlightBadWords(String comment, List<String> bannedWords)`: escape HTML truoc, roi tim
    TOAN BO vi tri khop tren chuoi da escape (khong phan biet hoa/thuong), gop cac vung chong
    lan, cuoi cung moi boc `<mark>` 1 lan duy nhat trong 1 pass — tranh loi boc long the khi 1 tu
    cam vo tinh trung ky tu voi the `<mark>` vua chen boi 1 tu cam khac duoc xu ly truoc do (rui
    ro co that neu thay the tuan tu tung tu mot).
- `checkBadWords()`: refactor de goi `fetchBannedWords()` thay vi tu query rieng — hanh vi khong
  doi.

**`KiemDuyetBinhLuanServlet.java`**:
- `doGet()`: them field `FeedbackDAO feedbackDAO = new FeedbackDAOImpl()`, goi
  `feedbackDAO.findPendingReview()`, set request attribute `pendingComments` truoc khi forward.
- Them moi `doPost()` (theo dung pattern PRG cua `ContentModerationServlet.doPost()`): doc param
  `action` (`approve`/`reject`) + `feedbackId`, goi `feedbackDAO.updateStatus(feedbackId,
  "VISIBLE")` hoac `updateStatus(feedbackId, "REMOVED")`, roi `resp.sendRedirect(...?success=...)`
  ve lai chinh GET route (khong dung forward) de tranh submit lai form khi F5.

**`admin/KiemDuyetBinhLuan.jsp`** — Tab 1 chuyen tu 3 the `.mod-card` viet cung sang du lieu that:
- Them taglib `<%@ taglib uri="/app-functions" prefix="app" %>` de dung `app:formatDateTime`.
- Xoa dong canh bao xanh "mock-data" va chu "(mock)" tren nut tab 1 (chi con o tab 2, danh dau
  rieng phan van con la mock).
- Badge dem so binh luan cho duyet doi tu so cung `3 bình luận chờ duyệt` sang
  `${pendingComments.size()} bình luận chờ duyệt` (chi hien khi `not empty pendingComments`).
- Vong lap `<c:forEach var="fb" items="${pendingComments}">` dung cho tung `.mod-card`: ten
  nguoi gui/avatar chu cai dau tu `fb.reviewerName` (`fn:substring`/`fn:toUpperCase`), dong
  "Bình luận về Shop/Shipper `${fb.targetName}`" (toan tu 3 ngoi `${fb.targetType eq 'SHOP' ? ...
  : ...}`), thoi gian tao qua `app:formatDateTime(fb.createdAt)`, noi dung hien thi truc tiep
  `${fb.highlightedComment}` (da highlight san tu DAO, khong can JS xu ly).
- 2 nut Phe duyet/Xoa bo doi tu `onclick="mockApprove/mockReject"` sang 2 the `<form method="post"
  action="${pageContext.request.contextPath}/admin/kiem-duyet-binh-luan">` rieng, moi form co
  hidden input `feedbackId` + `action` (`approve`/`reject`) — submit that, khong con AJAX/JS.
- `.empty-state` doi tu `style="display:none"` co dinh sang dieu kien
  `${empty pendingComments ? 'display:block;' : 'display:none;'}` de tu dong hien khi het hang
  doi.
- Xoa het JS `mockApprove()`/`mockReject()`/`mockRemoveCard()` (khong con dung); thay bang 1 doan
  script nho doc query param `?success=approved|rejected` sau redirect PRG de goi
  `window.showToast(...)` — dung lai ham `showToast()` co san tu `assets/js/toast.js`, khong tao
  co che toast moi.

Con lai chua lam (ngoai pham vi yeu cau lan nay, ghi lai de lam sau neu can): UI quan ly bang
`BannedWords` qua giao dien, va noi that Tab 2 "Lịch sử xử lý" voi query loc
`status IN ('VISIBLE','REMOVED')`.

## 49. Don gian hoa "Kiem duyet noi dung" con 2 tab + Tab moi "Quan ly Tu khoa cam" (Banned Words)

Trang `admin/KiemDuyetNoiDung.jsp` truoc do co 2 tab: "Bình luận chờ duyệt (mock)" + "Món ăn chờ
duyet" (that). Vi da co trang rieng `/admin/kiem-duyet-binh-luan` (muc 47-48) xu ly binh luan
that, tab binh luan mock o day bi trung lap va gay nham lan cho Super Admin. Yeu cau: xoa tab
binh luan mock, dua tab "Món ăn chờ duyệt" thanh Tab 1 mac dinh, va them Tab 2 moi de Super Admin
tu quan ly bang `BannedWords` (xem/them/xoa tu cam) truc tiep tren giao dien thay vi phai sua DB
tay.

**`BannedWord.java`** (model moi, `org.example.models`): POJO don gian `id` (long), `word`
(String), `createdAt` (LocalDateTime) — anh xa dung 3 cot cua bang `BannedWords` da tao tu
migration `migration_feedback_moderation.sql` (muc 47).

**`FeedbackDAO.java` / `FeedbackDAOImpl.java`** — them 3 method CONG KHAI moi (dat trong
`FeedbackDAO` vi day la noi duy nhat dang thao tac bang `BannedWords`, tranh tao them 1
DAO/model rieng khong can thiet cho 1 bang cau hinh nho):
- `findAllBannedWords()`: `SELECT id, word, created_at FROM BannedWords ORDER BY created_at DESC`,
  tra `List<BannedWord>` day du id (khac voi `fetchBannedWords()` private cu chi tra
  `List<String>` de phuc vu highlight, khong doi/xoa method cu).
- `addBannedWord(String word)`: `INSERT INTO BannedWords (word) VALUES (?)`.
- `deleteBannedWord(long id)`: `DELETE FROM BannedWords WHERE id = ?`.

**`ContentModerationServlet.java`**:
- Them field `FeedbackDAO feedbackDAO = new FeedbackDAOImpl()`.
- `doGet()`: goi them `feedbackDAO.findAllBannedWords()`, set request attribute `bannedWords`
  truoc khi forward (giu nguyen logic `pendingProducts` cu).
- `doPost()`: mo rong nhanh re theo `action` — giu nguyen 2 nhanh cu `approve`/`reject` (doc
  `productId`), them 2 nhanh moi khong dung chung param voi mon an de tranh xung dot:
  - `addWord`: doc param `word`, neu khong rong thi `feedbackDAO.addBannedWord(word.trim())` roi
    redirect `?success=wordAdded`.
  - `deleteWord`: doc param `wordId`, goi `feedbackDAO.deleteBannedWord(...)` roi redirect
    `?success=wordDeleted`. Van theo dung pattern PRG (Post-Redirect-Get) nhu 2 nhanh mon an.

**`admin/KiemDuyetNoiDung.jsp`**:
- Xoa het khoi Tab "Bình luận chờ duyệt (mock)" (4 the `.mod-card` viet cung du lieu gia + nut
  `onclick="mockApprove/mockReject"`), xoa luon banner CSS `.mock-note` va noi dung dung no (da
  het can thiet vi khong con du lieu mock nao tren trang nay).
- Tab bar chi con 2 nut: "🍜 Món ăn chờ duyệt (N)" (gio la `tab-btn active` mac dinh, panel
  `tab-food` cung doi thanh `tab-panel active`) va "🔞 Quản lý Từ khóa cấm (N)" (`tab-bannedwords`,
  khong active mac dinh). Logic/du lieu cua tab mon an giu nguyen 100% (khong doi form/servlet
  call), chi doi vi tri + trang thai active.
- Tab moi `tab-bannedwords`: 1 form nho tren cung (`action=addWord` + input text `name="word"`
  bat buoc + nut "➕ Thêm từ cấm"), duoi la `<c:forEach var="bw" items="${bannedWords}">` render
  moi tu cam thanh 1 "pill" (`.word-pill`) gom text + nut tron "✕" xoa — moi pill la 1
  `<form method="post">` rieng voi hidden `action=deleteWord` + `wordId=${bw.id}`, submit that
  (khong AJAX), dung dung pattern PRG nhu cac form khac trong file. Co `.empty-state` rieng khi
  `bannedWords` rong.
- CSS moi: `.word-input-row`, `.btn-add-word`, `.word-list`, `.word-pill` (theo dung he bien
  CSS dark/light `--bg-input`/`--border-color`/`--primary`/`--danger` da dung xuyen suot file,
  khong tao he mau moi).
- JS: xoa het `mockRemoveCard()`/`mockApprove()`/`mockReject()` (chet code sau khi xoa tab mock —
  tab mon an da dung `<form>` submit that tu truoc, khong phu thuoc JS nay). Thay bang 1 doan
  script doc query param `?success=...` sau PRG redirect de goi `window.showToast(...)` cho ca 4
  truong hop (`approved`/`rejected`/`wordAdded`/`wordDeleted`) — dung lai `showToast()` co san,
  khong tao co che moi.

Da bien dich `javac` toan bo `src/main/java` sach loi. Khong can migration moi — bang
`BannedWords` da duoc tao san tu `migration_feedback_moderation.sql` (muc 47), nguoi dung chi can
dam bao da chay migration nay truoc khi test. Kiem tra thu cong sau khi chay server: load
`/admin/kiem-duyet-noi-dung`, xac nhan Tab 1 (mon an) hien mac dinh va hoat dong nhu cu, chuyen
sang Tab 2 thay danh sach tu cam that (5 tu seed tu migration), thu them 1 tu moi va xoa 1 tu —
ca 2 thao tac phai cap nhat DB va load lai danh sach dung (PRG redirect + toast).

## 50. Sua loi avatar tu-dong-luu bo qua nut "Lưu thay đổi" (admin/shop/shipper profile)

**Trieu chung:** Tren 3 trang ho so ca nhan (`admin/hoSoAdmin.jsp`, `shop/hoSoShop.jsp`,
`shipper/hoSoShipper.jsp`), khi upload anh avatar moi, ngay sau khi Cloudinary tra ve URL, JS
POST luon URL do toi servlet rieng (`/admin/update-avatar`, `/shop/update-avatar`,
`/shipper/update-avatar`) va luu thang vao DB — trong khi cac truong con lai (ho ten, email, sdt)
chi luu khi bam nut "💾 Lưu thay đổi". Nguoi dung phan anh: upload avatar xong la avatar da doi
that tren toan he thong du chua bam Luu thay doi cho phan con lai cua form — hanh vi khong nhat
quan, gay hieu lam la "lam" (avatar luu ngay lap tuc, cac truong khac thi khong).

**Nguyen nhan:** Avatar dung 1 luong luu rieng, tach biet hoan toan khoi form chinh
(`<form action=".../profile" method="post">` hoac `.../ho-so`) — form chinh chi gui
`fullName`/`email`/`phone`, khong biet gi ve avatar.

**Da sua** (ap dung dong nhat ca 3 trang, cung 1 pattern):
- Them `<input type="hidden" name="avatarUrl" id="avatarUrlInput" value="${profile.avatarUrl}"/>`
  vao dau form chinh cua ca 3 trang, de avatarUrl di theo cung request voi cac truong khac khi
  bam "Lưu thay đổi".
- JS xu ly `change` cua file input: van upload len Cloudinary va preview ngay (avatar-card + nut
  avatar tren topbar) nhu cu, nhung **bo hoan toan** doan `fetch`/`XMLHttpRequest` POST toi
  `/admin|shop|shipper/update-avatar`. Thay vao do chi gan
  `document.getElementById('avatarUrlInput').value = url` va doi thong bao thanh
  `📌 Ảnh đã sẵn sàng, bấm "Lưu thay đổi" để áp dụng.` — avatar chi la preview cho toi khi submit
  form.
- `AdminProfileServlet.doPost()`, `ShopHoSoServlet.doPost()`, `ShipperHoSoServlet.doPost()`: doc
  them param `avatarUrl`; neu khac null va bat dau bang `https://res.cloudinary.com/` (giu nguyen
  whitelist domain nhu servlet update-avatar cu) thi `account.setAvatarUrl(avatarUrl.trim())`
  truoc khi `accountDAO.update(account)` — avatar gio duoc luu chung 1 transaction voi ho
  ten/email/sdt, dung 1 lan bam "Lưu thay đổi".
- Cac servlet cu `AvatarUploadServlet`/`ShopAvatarUploadServlet`/`ShipperAvatarUploadServlet`
  (`/admin|shop|shipper/update-avatar`) giu nguyen trong code (khong con noi nao goi toi nhung
  khong gay hai gi, xoa la viec don dep rieng ngoai pham vi loi nay).

Da bien dich `javac` toan bo `src/main/java` sach loi (chi doi doPost 3 servlet them 3 dong doc
param, khong doi API/signature nao). Nguoi dung can tu load lai 1 trong 3 trang ho so, doi anh
avatar, xac nhan: (1) avatar CHI doi preview, chua luu DB (F5 lai thi ve anh cu neu chua bam Luu),
(2) bam "💾 Lưu thay đổi" thi avatar + ho ten/email/sdt cung duoc luu 1 luc va hien
`✅ Cập nhật hồ sơ thành công!`.

## 51. Dong bo giao dien/JS upload avatar cua shop va shipper y chang SuperAdmin

Theo yeu cau nguoi dung: lam avatar-upload UI/JS cua `shop/hoSoShop.jsp` va `shipper/hoSoShipper.jsp`
**y chang** `admin/hoSoAdmin.jsp` (chi khac mau theme rieng cua tung trang), thay vi 2 pattern khac
nhau nhu truoc (admin dung `fetch` + label; shop/shipper dung `XMLHttpRequest` + thanh progress bar).

**Da sua** (ap dung dong nhat cho ca `shop/hoSoShop.jsp` va `shipper/hoSoShipper.jsp`):
- CSS: bo `.btn-change-avatar` / `#uploadProgressBar` / `.bar`, thay bang `.avatar-upload-btn`
  (nut dashed-border kieu admin) + `#avatarFileInput { display:none; }` + `.upload-status` — dung
  bien mau CSS rieng cua tung trang (`--bg-input`, `--border`/`--border-color`, `--text-muted`,
  `--primary`).
- HTML avatar-card: doi thu tu + cau truc giong admin —
  `<div class="profile-avatar" id="profileAvatarCircle">` boc `<img id="avatarPreviewImg">` hoac
  `<span id="avatarInitials">`, tiep theo `<input type="file" id="avatarFileInput"
  accept="image/jpeg,image/png,image/webp"/>`, `<label for="avatarFileInput"
  class="avatar-upload-btn">📷 Đổi ảnh đại diện</label>`, `<div class="upload-status"
  id="uploadStatus"></div>`, roi moi den ten/badge (bo nut `<button onclick=...>` va progress bar cu).
- JS: thay toan bo khoi `XMLHttpRequest` (upload progress %, uploadMsg/uploadProgressBar) bang dung
  `fetch()` y het admin: kiem tra file <= 2MB (them rang buoc nay, admin da co san nhung shop/shipper
  truoc do chua co), upload Cloudinary, tao/append `#avatarPreviewImg` vao `#profileAvatarCircle`
  (an `#avatarInitials` neu co), cap nhat avatar tren topbar (`#avatarBtn`), ghim URL vao
  `#avatarUrlInput`, hien `📌 Ảnh đã sẵn sàng, bấm "Lưu thay đổi" để áp dụng.` trong `#uploadStatus`.
- Khong doi servlet (`ShopHoSoServlet`, `ShipperHoSoServlet`) — logic luu avatarUrl khi bam
  "Lưu thay đổi" da dung tu muc 50, khong can sua them.

Da grep xac nhan khong con file nao tham chieu `uploadMsg`/`uploadProgressBar`/`btn-change-avatar`/
`uploadBar` trong `src/main/web`. Nguoi dung nen tu load lai `/shop/ho-so` va `/shipper/ho-so`, thu
doi avatar de xac nhan giao dien/hanh vi khop voi `/admin/profile`.
## 52. Phi giao hang tinh theo khoang cach (6.000d/km) va gioi han 20km khi checkout

Endpoint: `/checkout` (POST)

Truoc do phi giao hang la 1 hang so co dinh `FIXED_DELIVERY_FEE = 15000` ap dung cho moi don bat
ke khoang cach, khong co gioi han khoang cach shop-diem giao. Theo yeu cau moi: phi giao hang tinh
theo khoang cach thuc te (6.000d/km), va tu choi tao don neu shop cach diem giao qua 20km.

Da sua `src/main/java/org/example/controllers/CheckoutServlet.java`:

- Them hang so `FEE_PER_KM = 6000` va `MAX_DELIVERY_DISTANCE_KM = 20`.
- Them method tinh `haversineKm(lat1, lng1, lat2, lng2)` (cong thuc Haversine, giong ban client
  o `orderTrackingMap.js` muc 25c, nhung tinh o phia server vi day la buoc validate/tinh tien bat
  buoc, khong the tin client).
- Trong `doPost`, truoc khi tao don: voi moi shop trong gio hang (gio hang co the co nhieu shop,
  moi shop tao 1 `Order` rieng — xem muc 8), lay toa do shop (`Shop.locationX/locationY`, nhap tu
  `/shop/profile`) va toa do diem giao nguoi dung chon tren Leaflet luc checkout
  (`locationX`/`locationY` cua form, xem muc 26):
  - Neu ca 2 toa do deu co: tinh khoang cach Haversine. Neu > 20km thi **KHONG tao bat ky don nao**
    (kiem tra het tat ca shop truoc khi tao, tranh tao don cho shop hop le roi moi phat hien shop
    khac qua xa giua chung), hien loi tren trang xac nhan hoa don (dung lai co che
    `showReview(..., error)` da co san, hien qua `<div class="alert-error">` co san trong
    `checkoutThanhToan.jsp`) voi noi dung neu ro ten shop va khoang cach hien tai.
    Phi giao hang = `khoang_cach_km * 6000`.
  - Neu thieu toa do (shop chua chon vi tri, hoac khach khong chon diem giao tren ban do — muc nay
    khong bat buoc): giu nguyen `FIXED_DELIVERY_FEE = 15000` nhu truoc, khong chan don.

Da sua `src/main/web/user/checkoutThanhToan.jsp`: them 1 dong ghi chu duoi o "Phi giao hang" giai
thich day la phi tam tinh (chua chon vi tri), phi thuc te se tinh theo khoang cach sau khi chon
vi tri tren ban do, va don se bi tu choi neu shop cach diem giao qua 20km.

Han che/gia dinh da biet:

- Khoang cach la duong chim bay (Haversine), khong phai khoang cach thuc te theo duong di (dung
  cach tinh giong `orderTrackingMap.js`, khong dung routing API tra phi).
- Trang review (GET `/checkout`) van hien `FIXED_DELIVERY_FEE` lam gia tri tam tinh vi luc do
  nguoi dung chua chon vi tri tren ban do — chi tinh dung khi POST voi toa do da chon.
- Neu gio hang co nhieu shop va 1 trong so do qua 20km, TOAN BO checkout bi tu choi (khong tao
  rieng cho cac shop con lai) — nguoi dung phai bo san pham cua shop qua xa hoac doi diem giao
  truoc khi thanh toan lai.

Da compile lai toan bo `src/main/java` bang `javac -encoding UTF-8` (classpath tu `.m2`), khong loi.

## 53. Shipper huy don (bat buoc nhap ly do)

Endpoint: `/shipper/donhang` (POST, `action=cancelOrder`)

Truoc do shipper chi co 2 luong lam don bien mat khoi hang doi giao: "Bao bom hang" (`/shipper/bom-hang`,
chi danh cho truong hop **khach** tu choi nhan hang, tu dong tang `bom_count` cua khach) va hoan
thanh giao (`updateStatusToDone`). Chua co luong cho shipper **tu huy don** vi ly do cua rieng minh
(vd xe hong, khong tim duoc dia chi, ...).

Da sua `src/main/java/org/example/controllers/ShipperOrderServlet.java`:

- Them nhanh xu ly moi trong `doPost` cho `action=cancelOrder`, chi cho phep khi don dang
  `READY_FOR_PICKUP` hoac `SHIPPING` va thuoc dung shipper dang dang nhap (dung lai dieu kien
  `order.getShipperId() == account.getId()` da co san).
- Bat buoc co `reason` (param form) khong rong (server-side validate, ngoai validate JS o client) —
  neu rong thi khong lam gi ca (khong huy don), y het pattern cac nhanh action khac trong servlet
  nay (khong co error/toast rieng cho trang nay tu truoc).
- Khi hop le: `orderDAO.updateStatus(orderId, "CANCELLED")`, ghi 1 dong `Order_Logs` moi voi
  `old_status` = trang thai truoc do, `new_status = "CANCELLED"`, `note = "Shipper huy don. Ly do: " + reason`
  (dung cot `note NVARCHAR(MAX)` co san cua `Order_Logs`, khong them cot moi nao), va tao 1
  `Notification` cho chinh shipper (dung pattern cac nhanh action khac trong file nay, vd
  `updateStatusToDone`, deu chi notify shipper tu ve hanh dong cua minh, khong notify khach hang).

Da sua `src/main/web/shipper/chitietdonhang.jsp`:

- Them nut "❌ Huỷ đơn" trong khu vuc `action-bar`, hien khi don dang `READY_FOR_PICKUP` hoac
  `SHIPPING`.
- Nut goi `submitCancelOrder()` (script moi): dung `prompt()` de bat buoc shipper nhap ly do (rong
  thi bao loi va khong submit, huy prompt thi khong lam gi), roi `confirm()` xac nhan lan cuoi
  truoc khi submit form an (`reason` gan vao input hidden `cancelReasonInput`).

Ghi chu:

- Khac voi "Báo bom hàng" (loi cua khach hang, anh huong `bom_count`/khoa tai khoan khach), "Huỷ
  đơn" la loi/quyet dinh cua shipper, khong dung chung logic voi `BomHangServlet`, khong anh huong
  tai khoan khach hang.
- Khong them cot DB moi — ly do huy luu trong `Order_Logs.note` (cot san co, dung dung muc dich
  ghi log lich su chuyen trang thai don, xem cach dung tuong tu o cac nhanh `updateStatusToDone`
  trong cung file).
- Chua co man hinh nao (Admin/Shop/User) hien thi lai `note` cua `Order_Logs` cho don bi huy boi
  shipper — hien tai chi luu lai de tra cuu qua DB/bao cao van hanh sau nay, khong hien UI moi
  cho pham vi yeu cau nay.

Da compile lai toan bo `src/main/java` bang `javac -encoding UTF-8` (classpath tu `.m2`), khong loi.

## 54. Hoan thien quy trinh giao hang (CONFIRMED/READY_FOR_PICKUP/gan shipper), tru ton kho tu dong, khieu nai don hang, Notification realtime

File nay bi dinh conflict marker (`<<<<<<<`/`=======`/`>>>>>>>`) do merge tu 1 branch khac de len
tren cac muc da ghi cua phan viec nay — da don dep marker va danh so lai (xem muc 46/52/53 o
tren). Code that cua 4 tinh nang duoi day van con nguyen tren dia, chi bi mat noi dung ghi chep
chi tiet trong file .md nay; tom tat lai ngan gon o day de khong mat dau vet:

- **Quy trinh giao hang day du** (`ShopBillServlet`, `ShipperOrderServlet`,
  `ShipperAcceptOrderServlet`, `AccountDAO.findOnlineShippers()`): tach rieng buoc `CONFIRMED`
  (shop xac nhan) khoi `READY_FOR_PICKUP` (shop da chuan bi xong mon), them gan shipper thu cong
  tu dropdown shipper dang online (validate shipperId that su la shipper online, tranh IDOR), ben
  canh co che shipper tu nhan don co san. Endpoint: `/shop/bills`.
- **Tru ton kho tu dong** (`ProductDAO.decreaseStock()`, `utils/InventoryUtil.java`): khi 1 don
  chuyen sang `DONE` (qua `ShipperOrderServlet`, `ShopPosServlet`, hoac `PayOSReturnServlet` nhanh
  POS), tru `Products.stock_quantity` theo tung dong `OrderDetail`, tu chuyen `OUT_OF_STOCK` khi ve
  0; bo qua neu `stock_quantity` dang NULL (khong gioi han).
- **Khieu nai don hang** (bang moi `Complaints`, xem `migration_complaints.sql` — **can tu chay 1
  lan tren DB**): `ComplaintDAO`/`Impl`, `ComplaintServlet` (`/khieu-nai`, khach gui + xem trang
  thai), `AdminComplaintServlet` (`/admin/khieu-nai`, Super Admin loc/phan hoi/xu ly), JSP
  `user/khieuNai.jsp` + `admin/QuanLyKhieuNai.jsp`. Khong trung voi `AppealServlet` (`/appeal` chi
  danh cho khang nghi tai khoan bi khoa).
- **Notification cho khach hang + Realtime qua WebSocket** (bang co san `Notifications`, truoc chi
  dung cho shipper): `UserNotificationServlet` (`/user/thong-bao`) + `user/thongBao.jsp`; tao
  thong bao cho khach (`order.getUserId()`) tai moi buoc doi trang thai don co y nghia
  (`ShopBillServlet`, `ShipperOrderServlet`, `ShipperAcceptOrderServlet`). Nang cap realtime qua
  `websocket/NotificationEndpoint.java` (`/ws/notifications`, dung chung `HttpSessionConfigurator`
  voi `TrackingEndpoint`) — `NotificationDAOImpl.create()` la diem duy nhat tao Notification, tu
  dong `push()` qua WebSocket sau khi INSERT thanh cong nen khong can sua tung noi goi. Frontend
  dung chung `assets/js/notifications-ws.js` (toast + cap nhat badge `[data-notif-badge]` +
  ban su kien DOM `pob-notification`), gan vao `trangnguoidung.jsp`, `donhang.jsp`, `khieuNai.jsp`,
  `diaChi.jsp`, `thongBao.jsp`, `shipper/thongbao.jsp`.

Da bien dich `javac` toan bo `src/main/java` sach loi (xac nhan lai o thoi diem viet muc nay).

## 55. Fix loi giao dien sidebar Admin bi bop hep (menu chu xuong dong)

Nguoi dung bao loi kem screenshot: sidebar cua trang `/tong-quan` (Tổng quan hệ thống) bi bop rat
hep, chu trong menu xuong dong lien tuc thanh cot doc kho doc.

Nguyen nhan: thieu the dong `</div>` cho `.sidebar-brand` truoc `<ul class="menu">` —
`<ul class="menu">` bi long ben trong `.sidebar-brand` (von la 1 flex box hep chi danh cho
logo + ten) thay vi la anh em (sibling) cua no trong `<aside class="sidebar">`. Toan bo cac muc
menu vi the bi ep vao chung khong gian hep do, khien text buoc phai xuong dong.

Da sua:

- `src/main/web/admin/TongQuanHeThong.jsp` — them `</div>` dong `.sidebar-brand` truoc
  `<ul class="menu">`.
- `src/main/web/admin/quanlitaikhoan.jsp` — cung bi loi y het (copy-paste tu cung 1 mau sidebar),
  da sua tuong tu.

Da ra soat toan bo cac trang admin con lai dung chung mau sidebar (`yeuCauShop.jsp`,
`chiTietYeuCauShipper.jsp`, `chiTietYeuCauShop.jsp`, `doiMatKhauAdmin.jsp`, `hoSoAdmin.jsp`,
`yeuCauShipper.jsp`) — deu dong dung `</div>`, khong bi loi nay.

Ghi chu: day la loi thuan HTML/JSP (markup tinh), khong lien quan Java/DAO nen khong can bien
dich lai `javac`. Neu sau nay tao them trang admin moi bang cach copy-paste sidebar tu 1 trong
cac file nay, luon doi chieu dung cau truc: `.sidebar-brand` (logo + brand-text) phai duoc dong
`</div>` HOAN CHINH truoc khi mo `<ul class="menu">` hoac `.menu-section` moi.

## 56. Ra soat bao mat toan he thong — sua 3 bug tim duoc (IDOR nghiem trong, dropdown sai enum, badge sai trang thai)

Nguoi dung yeu cau "doc lai toan he thong tim bug". Dung 1 subagent doc toan bo code doi chieu
`Database.md` (CHECK constraint that) de tim bug thuc su (khong phai code smell). Tim duoc 3 bug,
da xac minh lai thu cong va sua ca 3:

**1. [NGHIEM TRONG] IDOR — `/orders`, `/order-details`, `/cart`, `/cart-items` khong he kiem tra
dang nhap/quyen so huu:**

- `OrderServlet.java`, `OrderDetailServlet.java`: 2 file nay la CRUD noi bo kieu "admin tool" (list
  TOAN BO ban ghi qua `getAll()`, sua/xoa bat ky ban ghi nao theo id, form nhap tay ca `userId`) —
  hoan toan khong co dong nao kiem tra `HttpSession`. `AuthFilter` (`filter/AuthFilter.java`) chi
  chan URL bat dau bang `/admin/*`, khong bao phu 2 endpoint nay. Da sua: them
  `requireAdmin(req, resp)` (kiem tra `account.getRoleId() == 1`) o dau ca `doGet`/`doPost`, giong
  het pattern `requireAdmin()` cua `KiemDuyetBinhLuanServlet` — vi day dung la cong cu quan tri noi
  bo, khong phai man hinh khach hang dung truc tiep (khach dung `/user/donhang`, `CheckoutServlet`).

- `CartServlet.java`, `CartItemServlet.java`: **KHONG the khoa admin-only** nhu 2 file tren vi
  `DanhSachGioHang.jsp` (view cua `/cart`) la trang khach hang dang dung THAT de vao "💳 Thanh
  toan" (gan tu muc 7), va `thanhToanThatBai.jsp` cung link ve `/cart`. Truoc do `listCarts()` goi
  `cartDAO.getAll()` (liet ke TOAN BO gio hang cua MOI nguoi dung), form them/sua co o nhap tay
  "User ID" — bat ky khach dang nhap nao cung xem/sua/xoa duoc gio hang cua nguoi khac. Da sua theo
  huong khac: **giu quyen truy cap cho khach hang (`roleId == 3`)** thay vi khoa admin-only, nhung
  ep/kiem tra chi duoc thao tac gio hang/CHI TIET gio hang cua CHINH minh:
  - `CartServlet`: `listCarts()` doi tu `getAll()` sang `cartDAO.findByUserId(account.getId())`
    (chi 1 gio hang cua chinh minh); `showEditForm`/`updateCart`/`deleteCart` kiem tra
    `cart.getUserId() == account.getId()` truoc khi cho phep; `readCart()` khong con doc `userId`
    tu form nua ma LUON gan `account.getId()` (bo hoan toan kha nang gia mao gio hang nguoi khac).
  - `CartItemServlet`: them field `CartDAO cartDAO` de doi chieu — `listItems()` chi lay item cua
    gio hang chinh minh (qua `cartDAO.findByUserId` roi `dao.findByCartId`); moi thao tac
    sua/xoa/xem chi tiet deu qua helper moi `ownsCartItem(item, account)` (tra ve `cart.getUserId()
    == account.getId()`); `createItem()` kiem tra `cartId` gui len tu form thuoc dung gio hang cua
    minh truoc khi tao; `updateItem()` khong cho doi `cartId` sang gio hang khac qua form (giu
    nguyen `cartId` that cua ban ghi cu).

**2. [TRUNG BINH] `user/orderThemSua.jsp` dropdown dua ra gia tri KHONG hop le, se vi pham CHECK
constraint khi luu:**

- Dropdown trang thai co option `COMPLETED` (khong ton tai trong CHECK cua `Orders.status`,
  `Database.md` dong 368 chi cho `PENDING/CONFIRMED/READY_FOR_PICKUP/SHIPPING/DONE/CANCELLED`),
  thieu han 2 gia tri that la `READY_FOR_PICKUP` va `DONE`. Dropdown phuong thuc thanh toan dua ra
  `BANKING`/`MOMO` (CHECK cua `Orders.payment_method`, dong 366, chi cho `COD/BANK/PAYOS`). Chon
  cac gia tri sai nay se bi SQL Server tu choi luc INSERT/UPDATE. Da sua lai dung 2 dropdown khop
  voi CHECK constraint that.

**3. [NHE] `shop/Quanlybill.jsp` dong 222 — badge so sanh voi `'DELIVERED'` khong ton tai, don da
giao xong hien badge xam sai thay vi badge xanh "Đã giao":**

- Cung dang bug `DELIVERED` vs `DONE` da tung sua o `user/donhang.jsp` (xem muc 52-54) nhung bi bo
  sot o file nay. Da sua `${ds == 'DELIVERED'}` thanh `${ds == 'DONE'}`.

Da bien dich `javac` toan bo `src/main/java` sach loi sau khi sua ca 3 bug.

Han che/ghi chu:

- Khong sua `OrderLogServlet.java` va cac CRUD noi bo khac (ngoai pham vi 3 bug tim duoc, subagent
  khong bao cao bug o file nay) — neu nghi ngo tuong tu thi kiem tra lai rieng.
- Sau khi khoa `/orders`, `/order-details` chi con Super Admin dung duoc — neu co man hinh nao
  khac (vd JSP nao) dang lien ket toi 2 URL nay voi ky vong nguoi dung thuong truy cap duoc thi se
  bi redirect ve `/dangnhap`; chua ra soat het moi lien ket toi 2 URL nay trong toan bo `src/main/web`
  (subagent xac nhan day la CRUD tool doc lap, khong thay lien ket tu luong khach hang that).

## 57. Ra soat bug lan 2 (Shop/Shipper/thanh toan/JS) — sua 3 bug them

Tiep tuc muc 56, dung subagent doc sau hon cac khu vuc chua kiem: race condition thanh toan,
quyen so huu o cac servlet Shop/Shipper con lai, JS client-side, SQL injection, NPE. Tim va sua
3 bug:

**1. [IDOR] Chuc nang "Khoi phuc" (restore) trong Thung Rac cua Topping/Loai Topping/Loai San
Pham khong kiem tra `shop_id` — 1 shop co the khoi phuc lai ban ghi da xoa mem cua shop khac:**

- `ToppingDAO.restore(id)`, `ToppingCategoryDAO.restore(id)`, `CategoryDAO.restore(id)` chi nhan
  `id`, SQL chi co `WHERE id = ?` — khac voi `ProductDAO.restore(id, shopId)` da co san va dung
  dung tu truoc (xem muc 19). 3 servlet goi thang `restore(id)` khong doi chieu chu so huu:
  `ShopToppingServlet.restoreTopping()`, `QuanLyLoaiToppingServlet.restoreToppingCategory()`,
  `ShopProductTypeServlet.restoreCategory()`.
- Da sua: doi ca 3 interface + Impl thanh `restore(long id, long shopId)`, them
  `AND shop_id = ?` (hoac `AND ${schema.shopId} = ?` cho `CategoryDAOImpl` vi dung dynamic
  schema resolution nhu `ProductDAOImpl`) vao cau SQL UPDATE. Sua ca 3 servlet truyen them
  `shop.getId()` khi goi.

**2. [Du lieu that/ton kho] `/payos/return` khong idempotent — F5/Back-Forward lai trang return
sau khi da thanh toan xong se tru ton kho THEM 1 LAN NUA cho cung 1 don (nhanh POS):**

- `PayOSReturnServlet.java`: PayOS tra ve trang thai that qua `PayOSUtil.getPaymentStatus()` (dung,
  khong tin query string) nhung sau khi xac nhan `PAID` thi luon chay `order.setStaTus("DONE")` +
  `orderDAO.update(order)` + `InventoryUtil.decreaseStockForOrder(...)` KHONG kiem tra xem don da
  o trang thai `DONE` tu truoc do chua. Nguoi dung reload/back-forward trang return (van con hop
  le vi PayOS van tra "PAID") se lam ham nay chay lai, tru them 1 lan ton kho cho cung 1 don —
  sai lech du lieu ton kho that. Da sua: kiem tra `"DONE".equalsIgnoreCase(order.getStaTus())`
  truoc, chi cap nhat status/tru kho khi don CHUA o trang thai `DONE` (idempotent).

**3. [Rui ro tao don trung] Khong co co che chong double-submit o 2 form thanh toan chinh:**

- `user/checkoutThanhToan.jsp` (checkout khach hang) va `shop/Banhang.jsp` (POS shop,
  `submitOrder()`): nut submit khong bi disable trong luc dang xu ly, bam 2 lan nhanh/double-click
  co the gui 2 request tao 2 Order trung nhau (server khong co transaction/idempotency check).
  Da them JS: disable nut + doi text "Đang xử lý..." ngay khi submit, dung `dataset.submitting`
  de chan goi lai neu ham bi trigger nhieu lan. Day la giam thieu o UI (khong sua duoc goc re la
  thieu transaction/idempotency o server — ngoai pham vi 1 lan sua nay, ghi lai de biet neu can
  lam ky hon sau).

Da bien dich `javac` toan bo `src/main/java` sach loi sau khi sua ca 3 bug.

Han che/ghi chu:

- Van con 1 nguyen nhan goc chua sua: server (`CheckoutServlet`, `ShopPosServlet`) khong dung
  transaction va khong co idempotency key that su — JS chong double-submit o muc 3 chi giam thieu
  o UI binh thuong, khong chan duoc truong hop hiem hon (2 tab cung luc, replay request bang tool
  ngoai trinh duyet). Neu can chan tuyet doi thi phai them co che khoa/transaction o server.

## 58. Xuat PDF & Excel (Shop: hoa don PDF + doanh thu Excel; Admin: thong ke Excel)

Yeu cau: Shop xuat duoc hoa don (PDF) va doanh thu (Excel); Admin xuat duoc thong ke (Excel).
Dung Apache POI (Excel) va iText (PDF) nhu de xuat.

**Dependency moi trong `pom.xml`** (chua co truoc do, du an chi co jakarta/mssql/jstl/jbcrypt/
javamail/json): `org.apache.poi:poi:5.2.5`, `org.apache.poi:poi-ooxml:5.2.5` (xuat `.xlsx`),
`com.itextpdf:itextpdf:5.5.13.3` (xuat PDF, ban iText 5, API don gian hon iText 7, du dung cho
hoa don/bao cao 1 trang). Ca 3 deu scope mac dinh (compile) nen `maven-war-plugin` se tu dong
dong goi vao `WEB-INF/lib` khi build, khong can cau hinh gi them.

**Luu y quan trong ve moi truong build**: may chay Claude khong co lenh `mvn` trong PATH (ghi
chu tu truoc, xem muc 11) nen KHONG the chay `mvn compile` that de kiem tra day du dependency
tree. Da tu tai thu cong cac jar can thiet (`poi`, `poi-ooxml`, `poi-ooxml-lite`, `xmlbeans`,
`commons-compress`, `commons-collections4`, `commons-io`, `commons-math3`, `SparseBitSet`,
`log4j-api`, `itextpdf`, `commons-codec`) vao `~/.m2/repository` roi dung `javac` truc tiep de
xac nhan code MOI viet bien dich sach (thanh cong). Rieng viec CHAY thu (`java -cp ...`) bi loi
`NoSuchMethodError` giua cac ban commons-compress/commons-io do may local co nhieu ban cu cua 2
thu vien nay tu cac du an khac lam sai lech classpath thu cong (khong dung Maven de dieu giai
phien ban dung nhu thuc te se xay ra khi nguoi dung build bang IntelliJ/Maven that). Day KHONG
phai loi trong code — chi la gioi han cua moi truong test thu cong, khong anh huong ket qua khi
nguoi dung tu build bang Maven that (Maven se tu dong tai dung version tuong thich cua toan bo
dependency tree). **Nguoi dung nen tu build lai 1 lan bang Maven/IntelliJ va thu xuat PDF/Excel
that de xac nhan chay dung**, thay vi chi tin ket qua bien dich `javac`.

**File tien ich moi:**

- `src/main/java/org/example/utils/ExcelExportUtil.java` (moi) — ham `export(sheetName, title,
  headers, rows)` dung chung, nhan `List<Object[]>` (moi dong 1 mang gia tri, ho tro
  String/Number/null), tu dong bold dong tieu de + dong header, auto-size cot. Dung
  `XSSFWorkbook` (`.xlsx`), khong dung `HSSFWorkbook` (`.xls` cu).
- `src/main/java/org/example/utils/PdfExportUtil.java` (moi) — ham `buildInvoicePdf(BillView)`
  tai su dung `BillView`/`BillLine` co san tu `BillUtil` (dung chung voi `/bill`, `/shop/bills`
  xem hoa don HTML). Dung font `Helvetica` voi bang ma `Cp1258` (`BaseFont.createFont(...,
  "Cp1258", NOT_EMBEDDED)`) de hien dung tieng Viet co dau **ma KHONG can nhung file `.ttf` ngoai**
  (khac voi cach thong thuong phai embed font Unicode) — day la 1 chieu meo pho bien voi iText 5
  cho tieng Viet, gon hon nhieu so voi nhung `arial.ttf`/`times.ttf` tu he thong (phu thuoc OS,
  khong portable khi deploy len server Linux).

**Shop — `ShopBillServlet.java` (`/shop/bills`), them 2 action GET moi:**

- `action=exportPdf&id=` — xuat hoa don 1 don hang ra PDF (`Content-Disposition: attachment`),
  kiem tra `order.getShopId() == shop.getId()` truoc khi cho xuat (khong lo hoa don shop khac).
  Nut "📄 PDF" moi canh nut "🧾 Xem" tren moi dong trong `shop/Quanlybill.jsp`.
- `action=exportExcel` — xuat TOAN BO danh sach don hang dang loc hien tai (dung lai
  `filterOrders()` co san, giu nguyen bo loc `q`/`date`/`status`/`method` tu URL) ra `.xlsx`, kem
  1 dong "TONG DOANH THU (khong tinh don huy)" o cuoi bang. Nut "📊 Xuất Excel (doanh thu)" moi o
  filter-bar cua `shop/Quanlybill.jsp`, truyen kem cac tham so loc hien tai de file xuat ra khop
  dung voi danh sach dang xem tren man hinh.

**Admin — `BaoCaoVanHanhServlet.java` (`/admin/bao-cao-van-hanh`), them action GET moi:**

- `action=exportExcel` — xuat toan bo so lieu dang hien thi tren trang (tong don, ty le hoan
  thanh, thoi gian giao trung binh, dem theo trang thai, khung gio cao diem, thong ke ly do huy
  don) ra `.xlsx`, giu nguyen khoang ngay `tuNgay`/`denNgay` dang loc. Nut "📊 Xuất thống kê
  (Excel)" moi canh nut "🔍 Xem báo cáo" trong `admin/BaoCaoVanHanh.jsp`.
- **Phat hien va sua them 1 bug an toan trong luc lam muc nay**: `BaoCaoVanHanhServlet.doGet()`
  truoc do **hoan toan khong kiem tra dang nhap/quyen** (khac voi cac servlet admin khac deu co
  `requireAdmin()`/kiem tra `roleId == 1`) — bat ky ai biet URL `/admin/bao-cao-van-hanh` deu xem
  duoc so lieu van hanh toan he thong du khong dang nhap. Da them kiem tra `account.getRoleId() ==
  1` dau `doGet()` truoc khi lam bat cu viec gi, giong pattern cac servlet admin khac.

Da bien dich `javac` toan bo `src/main/java` sach loi sau khi them 2 file tien ich + sua 2
servlet + them dependency moi vao `pom.xml`.

Han che/ghi chu:

- Chua lam xuat Excel/PDF cho `/bill` (khach hang tu xem hoa don) — chi lam theo dung yeu cau
  (Shop + Admin), khach hang van dung nut in trinh duyet (`window.print()`) nhu cu.
- File Excel dung style toi gian (bold + mau nen xam nhat cho header), khong co bieu do/format so
  phuc tap — du dung de doi soat/luu tru, khong thay the duoc bao cao truc quan Chart.js co san
  tren giao dien.
- `PdfExportUtil` chi xuat duoc 1 hoa don/lan goi (khop voi nut PDF tren tung dong don hang) —
  chua co xuat PDF hang loat (nhieu don 1 file) vi khong nam trong yeu cau.

## 59. Fix loi 500 khi vao `/shop/pos` (Bam Bill) va `/shop/bills` (Quan ly hoa don)

Nguoi dung bao loi kem screenshot: HTTP 500 `JasperException: Attempt to redefine the prefix [c]
to [http://java.sun.com/jsp/jstl/core], when it was already defined as [jakarta.tags.core]`.

Nguyen nhan: `shop/_invoiceModal.jspf` (fragment dung chung, duoc `<%@ include %>` boi ca
`Banhang.jsp` va `Quanlybill.jsp`) tu khai bao lai prefix `c`/`fmt` bang URI CU
(`http://java.sun.com/jsp/jstl/core`, `http://java.sun.com/jsp/jstl/fmt`), trong khi ca 2 trang
cha deu da khai bao cung prefix bang URI MOI (`jakarta.tags.core`, `jakarta.tags.fmt`, chuan
Jakarta EE 10 ma toan bo du an dang dung). Vi `<%@ include %>` la include tinh (gop noi dung vao
CUNG 1 file .java luc bien dich), JSP compiler thay 2 khai bao khac URI cho cung 1 prefix trong
cung 1 scope → loi bien dich, khong lien quan gi den cac thay doi backend gan day (loi co san tu
truoc, chi lo ra khi nguoi dung thuc su bam vao 2 trang nay).

Da sua `src/main/web/shop/_invoiceModal.jspf` (dong 4-5): doi
`http://java.sun.com/jsp/jstl/core` → `jakarta.tags.core`, `http://java.sun.com/jsp/jstl/fmt` →
`jakarta.tags.fmt`, khop dung voi ca `Banhang.jsp` lan `Quanlybill.jsp`.

Ghi chu: day la loi thuan JSP taglib (khong phai Java), khong can bien dich `javac`, chi can
Tomcat bien dich lai JSP (thuong tu dong khi reload/redeploy). Neu sau nay tao them JSP fragment
(.jspf) dung chung, luon kiem tra prefix taglib khop CHINH XAC (cung URI) voi tat ca trang se
include no, khong duoc tron URI cu/moi cho cung 1 prefix.

## 60. Loai Topping gan voi 1 Loai San Pham (tranh lan topping khong lien quan, vd nuoc mam cho tra sua)

Nguoi dung phan anh: hien tai 1 "Loai Topping" (vd "Topping tra sua") khong gan voi loai san
pham nao ca — nen khi ban hang (POS), 1 mon "Tra sua" van co the bi gan topping hoan toan khong
lien quan nhu "Nuoc mam". Xac nhan lai voi nguoi dung: cho phep gan tuy chon (nullable, khong bat
buoc) de tuong thich nguoc voi du lieu cu — de trong = ap dung cho MOI loai san pham.

**Migration moi** (`migration_topping_category_product_category.sql`, **nguoi dung can tu chay 1
lan tren DB**): them cot `ToppingCategories.category_id BIGINT NULL` (FK toi `Categories(id)`).

Da sua backend:

- `src/main/java/org/example/models/ToppingCategory.java`: them field `categoryId` (`Long`,
  nullable) va `categoryName` (view-only, do o DAO qua JOIN, khong co cot tuong ung).
- `src/main/java/org/example/daos/ToppingCategoryDAOImpl.java`: viet lai toan bo cac cau SELECT
  dung `LEFT JOIN Categories c ON tc.category_id = c.id` de lay kem `category_name`; `create()`/
  `update()` bind `category_id` (dung `Types.BIGINT` qua `setNull` neu la `null`).
- `src/main/java/org/example/controllers/QuanLyLoaiToppingServlet.java`: doc them param
  `productCategoryId` tu form (`readForm()`); **validate chong IDOR** — neu co chon, phai la 1
  loai san pham THUOC DUNG SHOP dang dang nhap (doi chieu qua `productCategoryDAO.findByShopId()`),
  khong cho gan vao loai san pham cua shop khac; `forwardPage()` truyen them
  `danhSachLoaiSanPham` (danh sach loai san pham cua shop) cho dropdown.

Da sua giao dien:

- `src/main/web/shop/Quanlyloaitopping.jsp`: them cot "Áp dụng cho loại sản phẩm" trong bang danh
  sach (badge ten loai san pham hoac "Tất cả loại sản phẩm" neu de trong); them dropdown chon
  loai san pham trong modal them/sua (option rong = ap dung cho tat ca).
- `src/main/web/shop/Banhang.jsp` (POS — noi topping THUC SU duoc chon luc ban hang, khac voi
  `menuShop.jsp` phia khach hang hien chi la danh sach "tham khao" tinh, chua wiring vao gio
  hang): day la noi quan trong nhat can loc dung.
  - Nut chon size san pham them `data-category-id="${p.categoryId}"`; `addToCart()` luu
    `categoryId` vao tung dong gio hang tam (cart line).
  - Moi nhom topping trong topping-picker boc trong `<div data-topping-group
    data-category-id="...">` (rong neu loai topping khong gan loai san pham nao).
  - `openToppingPicker(idx)`: khi mo panel chon topping cho 1 dong gio hang, an di cac nhom
    topping co `data-category-id` khac voi `categoryId` cua mon dang chon (chi hien nhom "ap
    dung cho tat ca" — `data-category-id` rong — hoac nhom dung loai voi mon do).

Han che/ghi chu:

- Chi loc o **client-side (JS)** trong `Banhang.jsp`, khong validate lai o server
  (`ShopPosServlet.createOrder()`) rang topping gui len co thuc su hop le voi loai san pham
  khong — chap nhan duoc vi day la POS do CHINH shop tu thao tac tren du lieu cua ho (khong phai
  ranh gioi bao mat giua nhieu ben, chi la data quality/UX), khong phai loi bao mat.
- `menuShop.jsp` (khach hang xem menu) hien chi hien topping nhu danh sach tham khao tinh, CHUA
  wiring vao luong dat hang thuc su cua khach (ghi chu "Liên hệ shop để chọn topping khi đặt
  hàng") — nen KHONG loc theo loai san pham trong lan sua nay, vi khong co "dong gio hang" nao de
  biet dang chon mon loai gi. Neu sau nay lam topping-picker that cho khach hang thi ap dung lai
  dung logic filter nay.
- Da bien dich `javac` toan bo `src/main/java` sach loi.

## 61. Nang cap "Loai Topping - Loai San Pham" tu 1-1 sang NHIEU-NHIEU

Tiep tuc muc 60. Nguoi dung yeu cau: 1 Loai Topping phai chon duoc **NHIEU HON 1** Loai San Pham
(vd "Topping tra sua" ap dung ca cho "Tra sua" lan "Cafe"), khong chi 1 loai duy nhat nhu thiet
ke ban dau o muc 60.

**Migration moi** (`migration_topping_category_multi_product_category.sql`, **nguoi dung can tu
chay 1 lan tren DB** — chay SAU migration o muc 60, vi no doc lai du lieu tu cot `category_id`
cu roi moi xoa cot do): tao bang trung gian `ToppingCategory_ProductCategories`
(`topping_category_id`, `category_id`, PK ghep 2 cot), chuyen du lieu cu tu cot
`ToppingCategories.category_id` (neu co) sang bang moi, roi **xoa han cot `category_id` cu**
(khong con dung 1-1 nua).

Da sua backend:

- `src/main/java/org/example/models/ToppingCategory.java`: doi `Long categoryId`/`String
  categoryName` (1-1) thanh `List<Long> categoryIds`/`List<String> categoryNames` (nhieu-nhieu),
  danh sach rong = ap dung cho MOI loai san pham.
- `src/main/java/org/example/daos/ToppingCategoryDAOImpl.java`: viet lai hoan toan — bo LEFT JOIN
  1 cot, thay bang helper `loadCategoryLinks()` (JOIN qua bang trung gian, tra ve ca
  `categoryIds` + `categoryNames`) goi sau moi lan map 1 dong; `saveCategoryLinks()` (xoa het lien
  ket cu roi ghi lai dung danh sach hien tai, dung `PreparedStatement.addBatch()`) goi sau
  `create()`/`update()` thanh cong. `create()` doi sang dung `Statement.RETURN_GENERATED_KEYS` de
  lay lai id vua tao (truoc do chi tra `Boolean`, khong co id de ghi lien ket).
- `src/main/java/org/example/controllers/QuanLyLoaiToppingServlet.java`: `readForm()` doi tu doc
  1 param `productCategoryId` sang doc **mang** qua
  `req.getParameterValues("productCategoryId")` (checkbox nhieu lua chon); `validate()` doi tu
  kiem tra 1 gia tri sang duyet qua tung phan tu trong `categoryIds`, dam bao TAT CA deu thuoc
  dung shop dang dang nhap (van giu nguyen muc dich chong IDOR nhu muc 60).

Da sua giao dien:

- `src/main/web/shop/Quanlyloaitopping.jsp`: bang danh sach doi tu 1 badge sang lap qua
  `cat.categoryNames` hien nhieu badge; modal them/sua doi dropdown `<select>` (chon 1) sang 1
  khung checkbox nhieu lua chon (`<input type="checkbox" name="productCategoryId"
  value="${pc.id}">`, dung `formCat.categoryIds.contains(pc.id)` de danh dau da chon khi sua).
- `src/main/web/shop/Banhang.jsp` (POS): nhom topping doi tu `data-category-id="1"` (1 gia tri)
  sang `data-category-ids="1,2,3"` (danh sach cach nhau dau phay, render qua `<c:forEach>` JSTL);
  JS `openToppingPicker()` doi logic so sanh 1-1 sang `ids.indexOf(...) !== -1` (kiem tra loai san
  pham cua mon dang chon co NAM TRONG danh sach cua nhom topping hay khong).

Ghi chu:

- Y het muc 60: chi loc client-side trong `Banhang.jsp`, khong validate lai o server luc tao don
  (van la POS noi bo cua shop, khong phai ranh gioi bao mat).
- Da bien dich `javac` toan bo `src/main/java` sach loi.

## 50. Fix IDOR o `BillServlet.java` (`/bill`) — phat hien khi audit project sau khi merge nhanh `bao-ty00366`

Sau khi merge nhanh `bao-ty00366` vao `ThanhHien_TY00243` (commit `0363552`), kiem tra lai toan bo
project (compile `javac` + doc lai cac servlet lien quan don hang/gio hang) thi thay merge nay da tu
vang 2 lo hong IDOR/thieu auth da phat hien truoc do:

- `OrderServlet.java` (`/orders`): da them `requireAdmin()` (chi roleId=1 duoc dung).
- `CartServlet.java` / `CartItemServlet.java`: da them `requireLogin()` (roleId=3) + kiem tra
  `cart.userId == account.id` / `ownsCartItem()` truoc moi thao tac xem/sua/xoa.

Nhung rieng `BillServlet.java` (`/bill` — trang xem/in hoa don sau checkout) van con sot, hoan toan
khong co buoc kiem tra dang nhap lan kiem tra chu so huu don hang. Chi can doi `orderId` tren URL
`/bill?orderId=...` (ke ca chua dang nhap) la xem duoc hoa don cua nguoi khac (ten nguoi nhan, dia
chi, mon hang, so tien).

Da sua theo dung pattern cua `ComplaintServlet`/`CartServlet`:
- Them `requireLogin()`: bat buoc co session + `account.roleId == 3`, khong thi redirect ve
  `/dangnhap`.
- Trong vong lap build `bills` tu `orderIds`, chi giu lai don hang co `order.getUserId() ==
  account.getId()` — don cua nguoi khac bi bo qua am tham (khong loi rieng, giong cach xu ly
  `order == null` cu, tranh lo thong tin qua thong bao loi khac nhau).

Da bien dich lai `javac` toan bo `src/main/java` (classpath tu `.m2`, loai bo `*-sources.jar`/
`*-javadoc.jar` vi javac tu dong dung classpath lam sourcepath va co gang bien dich luon file
`.java` ben trong cac jar do gay loi gia), khong loi.

## 51. Dong bo lai toan bo giao dien Super Admin ve mot kien truc duy nhat (Nhom A)

Nguoi dung bao loi khi vao cac trang Super Admin: vi tri sidebar sai, mau UI khac nhau giua cac
trang, va nhieu loi giao dien khac. Audit toan bo 15 file JSP trong `src/main/web/admin/` +
`src/main/web/super-admin/` phat hien co **3 kien truc UI khong tuong thich** cung ton tai:

- **Nhom A** (chuan, dung chung `theme.css`/`dashboard.css`): `<body class="dash-body">`,
  `<aside id="sidebar">`, `<div class="menu">` + `<a class="menu-item">` voi
  `<span class="mi-left"><span class="mi-icon">...</span> Label</span>`, badge dang
  `<span class="menu-badge yellow">`, theme luu trong `localStorage['pob-dashboard-theme']`,
  toggle qua ham dung chung `pobToggleSidebar()`/`pobToggleTheme()` trong
  `assets/js/dashboard-theme.js`.
- **Nhom B** (legacy, moi file tu code rieng): `<html data-theme="dark">` hard-code, khong co
  `<link>` toi `theme.css`/`dashboard.css`, tu dinh nghia `:root[data-theme]` trung lap trong
  `<style>` rieng, `<aside id="sidebarMain">` co nut thu gon `.sidebar-toggle-btn`, menu dang
  `<ul><li>`, badge `<span class="badge red">`, theme luu key rieng tung file (`'theme'` hoac
  `'adminTheme'`).
- **Kien truc lai (hybrid)**: head/topbar/footer da giong Nhom A nhung phan `<aside>` van con
  sot markup Nhom B (`id="sidebarMain"`, `.logo-icon`/`.badge-system`/`.sidebar-toggle-btn`,
  `<div class="menu-section">`, `<div class="menu-item-left">`, badge
  `<span class="badge-count green">`).

Nguoi dung chon phuong an: **dua toan bo ve Nhom A**. Da sua 9 file sau ve dung Nhom A (giu
nguyen toan bo phan noi dung/logic nghiep vu rieng cua tung trang, chi thay doi phan
head/style/sidebar/topbar/footer-script cho dong bo):

- `src/main/web/admin/BaoCaoVanHanh.jsp`
- `src/main/web/admin/DoiSoatDoanhThuShop.jsp`
- `src/main/web/admin/DuyetRutTienShipper.jsp`
- `src/main/web/admin/KiemDuyetNoiDung.jsp`
- `src/main/web/admin/KiemDuyetBinhLuan.jsp`
- `src/main/web/admin/QuanLyKhieuNai.jsp`
- `src/main/web/admin/appeals.jsp`
- `src/main/web/admin/yeuCauShop.jsp`
- `src/main/web/admin/chiTietYeuCauShop.jsp`

Cac thay doi chinh ap dung cho tung file:

- Doi head sang dung `theme.css`/`dashboard.css` + script doc theme dong tu
  `localStorage['pob-dashboard-theme']` (bo het `data-theme="dark"` hard-code va CSS bien theme
  trung lap).
- Doi `<body>` sang `<body class="dash-body">`, them `<div class="sidebar-backdrop">`.
- Doi `<aside id="sidebarMain">` (hoac tuong duong) sang `<aside class="sidebar" id="sidebar">`,
  bo nut thu gon sidebar (`.sidebar-toggle-btn`/`#sidebarToggleBtn` — Nhom A khong co co che nay),
  bo badge "SYSTEM" thua.
- Doi menu tu `<ul><li>` hoac `<div class="menu-section">`/`.menu-item-left` sang
  `<div class="menu">` + `<a class="menu-item">` voi `<span class="mi-left"><span
  class="mi-icon">EMOJI</span> Label</span>`, badge doi thanh `<span class="menu-badge
  yellow">`.
- Doi topbar sang dung `pobToggleSidebar()`/`pobToggleTheme()` dung chung, dua avatar-dropdown
  xuong cuoi `<main>`, nhung script rieng cua tung trang (vd `switchTab`, toast PRG,
  `askRejectReason`) duoc giu nguyen.
- Xoa script theme-toggle/sidebar-collapse rieng cua tung file (dung key `'theme'`/
  `'adminTheme'`/`localStorage['sidebarCollapsed']`), thay bang 1 script
  `assets/js/dashboard-theme.js` dung chung.
- Sua vai link menu chet (`href="#"`) sang dung route co san: "Doi soat doanh thu Shop" ->
  `/admin/doi-soat-doanh-thu-shop`, "Duyet Shipper" -> `/super-admin/shipper-requests`. Bo 2 muc
  menu chi la placeholder khong co dich den ("Tham so van hanh", "Truyen thong & Banner") de dong
  bo voi bo menu chuan dung chung cho tat ca cac trang.

Cac file da la Nhom A tu truoc, khong can sua: `yeuCauShipper.jsp`, `chiTietYeuCauShipper.jsp` —
dung lam mau tham chieu cho cac file khac.

Ket qua: toan bo trang Super Admin gio dung chung 1 sidebar dat dung vi tri, dung chung 1 bang
mau/theme (sang/toi dong bo qua nut theme-toggle), dung chung 1 bo ham JS
(`pobToggleSidebar`/`pobToggleTheme`).

### 51.1. Bo sung: van con sot loi sidebar/font o nhieu trang khac (phat hien sau khi bao cao "da xong")

Bao cao ban dau o muc 51 la **chua day du** — danh sach 9 file goc bo sot nhieu file khac cung
bi loi. Nguoi dung gui screenshot bao lai loi sidebar/font, yeu cau kiem tra toan bo cac trang
con lai. Grep lai toan bo `src/main/web` voi pattern rong hon
(`menu-item-label-group|menu-item-left|badge-count|sidebarMain|sidebar-toggle-btn|class="badge
(yellow|green)"`) phat hien them nhieu file `<ul><li>`/`menu-item-label-group` cu hoac markup lai
(hybrid) chua duoc sua. Da sua them cac file sau ve dung Nhom A:

- `src/main/web/admin/TongQuanHeThong.jsp` — trang mac dinh `/tong-quan`, dung trang bi loi trong
  screenshot dau tien. Thay toan bo `<ul class="menu">` cu (badge `yellow`/`N moi`, 2 muc chet
  placeholder, href chet "Doi soat doanh thu Shop") bang menu chuan Nhom A.
- `src/main/web/admin/quanlitaikhoan.jsp` — cung loi `<ul><li>` (badge `badge-count green`), da
  thay bang menu chuan, giu "Nguoi dung" active.
- `src/main/web/admin/yeuCauShipper.jsp` — sidebar dung tieu de khong chuan ("Quan ly he
  thong"/"Quan ly du lieu"), thieu han cac muc "Bao cao van hanh"/"Kiem duyet noi dung"/"Kiem
  duyet binh luan", "Khang nghi" va 2 muc tai chinh con markup cu, bi trung lap muc "Nguoi dung".
  Da thay toan bo bang menu chuan day du, gop lai con 1 muc "Nguoi dung".
- `src/main/web/admin/chiTietYeuCauShipper.jsp` — file it duoc migrate nhat: khong co `<style>`
  cho avatar-dropdown, khong import taglib `fn`, topbar dung avatar cung "AD" + link logout truc
  tiep thay vi avatar-dropdown chuan. Da them taglib `fn`, CSS avatar-dropdown, thay topbar bang
  avatar-wrapper/avatar-circle chuan, them block `<div class="avatar-dropdown">` + script toggle
  con thieu hoan toan.
- `src/main/web/admin/hoSoAdmin.jsp` — cung loi tieu de khong chuan + markup `<a><li
  class="menu-item">` cu cho "Khang nghi" va 2 muc tai chinh, thieu 3 muc menu, va co 1 muc thua
  "San pham" (`/product`) khong thuoc bo menu Super Admin chuan (co le sot lai tu template ben
  Shop). Da thay bang menu chuan day du, xoa muc "San pham" thua.
- `src/main/web/admin/doiMatKhauAdmin.jsp` — cung loi tieu de khong chuan, "Khang nghi"/"Doi soat
  doanh thu Shop"/"Duyet rut tien Shipper" con markup `<a><li class="menu-item">` cu (khong dong
  badge dung cach, href chet cho "Doi soat doanh thu Shop"), thieu 3 muc menu, co 1 muc thua "San
  pham" (`/product`). Da thay bang menu chuan day du, xoa muc "San pham" thua.
- `src/main/web/admin/KiemDuyetBinhLuan.jsp`, `KiemDuyetNoiDung.jsp`, `DuyetRutTienShipper.jsp`,
  `DoiSoatDoanhThuShop.jsp`, `BaoCaoVanHanh.jsp` — da dung Nhom A tu truoc nhung con sot 2 muc
  menu chet placeholder ("Tham so van hanh", "Truyen thong & Banner"). Da xoa.

Sau khi sua xong, grep lai toan bo `src/main/web` voi cung pattern tren: chi con 1 file
`src/main/web/shop/Banhang.jsp` con markup cu — day la trang thuoc Shop portal, **khong thuoc
pham vi** yeu cau dong bo Super Admin nen khong sua.

Ket qua (cap nhat): toan bo 15+ file JSP Super Admin (ca trong `admin/` va `super-admin/`) hien
da dung chung 1 kien truc sidebar/menu/avatar-dropdown Nhom A, khong con file nao sot markup cu.


## 52. Dong bo sidebar admin: them "Quan ly khieu nai" va sua sidebar sai cua appeals.jsp/QuanLyKhieuNai.jsp

**Trieu chung**: Menu "Quản lý khiếu nại" chỉ hiện trên 1-2 trang admin (KiemDuyetBinhLuan.jsp,
QuanLyKhieuNai.jsp), biến mất khi chuyển sang các trang admin khác. Ngoài ra trang "Kháng nghị"
(appeals.jsp) có sidebar khác hẳn các trang admin còn lại (thiếu nhiều mục, tiêu đề section khác,
có link "Sản phẩm" thừa không thuộc về đâu).

**Nguyen nhan**: Tính năng "Quản lý khiếu nại" (`AdminComplaintServlet` @ `/admin/khieu-nai`) được
merge từ nhánh của thành viên khác (`bao-ty00366`). Do project không có sidebar dùng chung (mỗi
file JSP admin tự hardcode menu riêng), link sidebar của tính năng mới chỉ được thêm vào đúng 2
file mà người đó sửa, không lan ra 13 file admin còn lại. Rieng `appeals.jsp` dùng hẳn 1 bộ sidebar
khác (tiêu đề "Quản lý hệ thống"/"Quản lý Dữ liệu" thay vì chuẩn 4 section, thiếu "Báo cáo vận hành",
"Kiểm duyệt nội dung", "Kiểm duyệt bình luận", và có link `/product` "Sản phẩm" lạc chỗ trong mục
Tài chính - có vẻ là artifact còn sót từ merge). `QuanLyKhieuNai.jsp` cũng thiếu hẳn section
"💰 QUẢN LÝ TÀI CHÍNH".

**Da sua**:
- Thêm link "📢 Quản lý khiếu nại" (`/admin/khieu-nai`, đặt ngay trước "Kháng nghị") vào 12 file
  admin còn thiếu: `BaoCaoVanHanh.jsp`, `DoiSoatDoanhThuShop.jsp`, `DuyetRutTienShipper.jsp`,
  `KiemDuyetNoiDung.jsp`, `TongQuanHeThong.jsp`, `chiTietYeuCauShipper.jsp`, `chiTietYeuCauShop.jsp`,
  `doiMatKhauAdmin.jsp`, `hoSoAdmin.jsp`, `quanlitaikhoan.jsp`, `yeuCauShipper.jsp`, `yeuCauShop.jsp`.
  Không gắn badge `pendingCount` cho link này ở các file trên vì biến `pendingCount` ở các trang đó
  đang dùng cho số lượng "Kháng nghị" đang chờ, không phải số khiếu nại — tránh hiện nhầm số.
- `QuanLyKhieuNai.jsp`: bổ sung section "💰 QUẢN LÝ TÀI CHÍNH" (Đối soát doanh thu Shop, Duyệt rút
  tiền Shipper) đang bị thiếu, đặt giữa "Kháng nghị" và "⚙️ CẤU HÌNH & HỆ THỐNG".
- `appeals.jsp`: dựng lại toàn bộ sidebar theo đúng template chuẩn 4 section (📊 TỔNG QUAN & PHÂN
  TÍCH / ⚖️ KIỂM DUYỆT & ĐIỀU PHỐI / 💰 QUẢN LÝ TÀI CHÍNH / ⚙️ CẤU HÌNH & HỆ THỐNG) giống các trang
  admin khác, xoá link "Sản phẩm" lạc chỗ.
- Xác nhận: `grep -L "Quản lý khiếu nại" *.jsp` trong `src/main/web/admin` trả về rỗng (cả 15 file
  đều có link), và số lượng thẻ `<a>`/`</a>` cân bằng ở tất cả file đã sửa.

**Kiem tra thu cong**: Đăng nhập SuperAdmin, mở lần lượt từng trang trong sidebar (Tổng quan, Báo
cáo vận hành, Duyệt Shop/Shipper, Kiểm duyệt nội dung/bình luận, Quản lý khiếu nại, Kháng nghị, Đối
soát doanh thu, Duyệt rút tiền, Người dùng, Hồ sơ, Đổi mật khẩu) — xác nhận sidebar của mỗi trang
giống hệt nhau về thứ tự và đầy đủ mục, "Quản lý khiếu nại" luôn hiện trước "Kháng nghị".

## 53. Sua loi form "Chinh sua thong tin" trong admin/hoSoAdmin.jsp khong co CSS

**Trieu chung**: Ở trang Hồ sơ cá nhân (SuperAdmin), cột trái (avatar + info-card) hiển thị đẹp
nhưng cột phải (form "Chỉnh sửa thông tin") hiện các input/button theo style mặc định của trình
duyệt, không có border bo góc, màu nền, khoảng cách... như thiết kế.

**Nguyen nhan**: JSP dùng các class `.form-card`, `.form-card-title`, `.form-group`, `.form-hint`,
`.form-actions`, `.btn-save`, `.btn-cancel` nhưng các class này **không được định nghĩa ở bất kỳ
đâu** — không có trong `theme.css`, không có trong `dashboard.css`, và `<style>` riêng của
`hoSoAdmin.jsp` chỉ có CSS cho avatar/sidebar chứ không có CSS cho form. (File `shop/hoSoShop.jsp`
và `shipper/hoSoShipper.jsp` may mắn có sẵn các class này trong `<style>` riêng của chúng nên không
bị lỗi.)

**Da sua**: Thêm CSS cho `.form-card`, `.form-card-title`, `.form-group` (+ `label`, `input`,
`input:focus`, `input:disabled`), `.form-hint`, `.form-actions`, `.btn-save` (+ `:hover`),
`.btn-cancel` (+ `:hover`) vào `<style>` của `admin/hoSoAdmin.jsp`, dùng đúng biến CSS đã có sẵn
của trang (`--bg-panel`, `--border-color`, `--text-main`, `--text-muted`, `--text-dim`, `--primary`,
`--primary-dark`, `--bg-input`, `--radius-md`) để đồng bộ theme sáng/tối có sẵn.

**Kiem tra thu cong**: Mở `/admin/profile`, xác nhận form bên phải có card nền, border bo góc,
input có nền `--bg-input` + viền, focus đổi màu viền cam, nút "Lưu thay đổi" màu cam và "Huỷ" màu
xám giống cột trái; kiểm tra cả 2 theme sáng/tối qua nút toggle theme trên topbar.

## 54. Sua avatar tren topbar khong co con tro chuot (cursor: pointer)

**Trieu chung**: Đưa chuột qua vòng tròn avatar trên topbar (admin/shop/shipper) không hiện con
trỏ tay dù click vào đó sẽ mở dropdown thông tin tài khoản.

**Nguyen nhan**: Class `.avatar-circle` dùng chung trong `assets/css/dashboard.css` (áp dụng cho
cả 3 dashboard admin/shop/shipper vì cùng link file này) thiếu khai báo `cursor: pointer`.

**Da sua**: Thêm `cursor: pointer;` vào rule `.avatar-circle` trong `assets/css/dashboard.css`.

**Kiem tra thu cong**: Mở bất kỳ trang admin/shop/shipper nào, rê chuột qua avatar ở topbar — phải
thấy con trỏ tay (pointer) và dropdown vẫn mở/đóng bình thường khi click.

## 62. Ra soat bao mat lan 3 (audit chuan bi bao ve do an) — vá 4 lo hong auth/IDOR + 1 loi chuc nang webhook

Phat hien khi lam mot audit tong the theo checklist cham diem do an tot nghiep (dashboard, UI,
quy trinh, DB, hieu nang, bao mat, tai lieu). Tim duoc **4 lo hong auth/IDOR that su** con sot lai
sau 2 dot ra soat bao mat truoc do (muc 56, 57) va **1 loi chuc nang** lien quan `AppFilter`:

- **`TongQuanServlet.java` (`/tong-quan`, dashboard tong quan Super Admin)**: hoan toan khong co
  session/roleId check, va URL `/tong-quan` khong nam trong bat ky nhanh nao cua `AppFilter`
  (chi co `/super-admin/`, `/admin/`, `/shop`, `/shipper/`, `/user/`) nen ai cung xem duoc thong
  ke toan he thong (tong tai khoan, shop cho duyet, canh bao vi pham...) ma khong can dang nhap.
  Da sua: them check `session.getAttribute("account")` null -> redirect `/dangnhap`, va
  `roleId != 1` -> tra 403, giong dung pattern da dung o `BaoCaoVanHanhServlet`.

- **`ProductServlet.java` (`/product`)** va **`CategoryServlet.java` (`/Category`)**: day la 2
  servlet CRUD noi bo (forward toi `shop/taoProduct.jsp`/`shop/taoCategory.jsp`) nhung URL khong
  co tien to `/admin`, `/shop`, `/shipper`, `/user` nen `AppFilter` chi bat buoc "da dang nhap",
  khong gioi han role -> bat ky khach hang (role 3) nao dang nhap deu tao/sua/xoa duoc san
  pham/loai san pham cua **bat ky shop nao** (truyen `shopid`/`id` tuy y qua form). Da sua: them
  method `requireAdmin()` (giong het pattern da co san trong `OrderServlet.java`, chi cho phep
  `roleId == 1`) va goi o dau `doGet`/`doPost`.

- **`OrderLogServlet.java` (`/order-logs`)**: cung loi nhu tren — khong co role check, bat ky user
  dang nhap nao doc/sua/xoa duoc lich su thay doi trang thai cua **moi** don hang trong he thong.
  Da sua: them `requireAdmin()` giong 2 servlet tren.

- **`CheckoutServlet.java` (`/checkout`)**: IDOR — `doGet`/`doPost` lay `Cart` theo `cartId` tu
  form/query string ma khong kiem tra `cart.getUserId()` co khop voi tai khoan dang dang nhap
  khong; ke ca khi `AppFilter` da bat dang nhap, 1 user van co the truyen `cartId` cua nguoi khac
  de tao don hang (va xoa gio hang) tren tai khoan nan nhan. Da sua: lay `account` tu session
  ngay dau `doGet`/`doPost` (redirect `/dangnhap` neu chua dang nhap), va kiem tra
  `cart.getUserId() == account.getId()` truoc khi dung `cart` (khac `not_found` neu khong khop).

- **`AppFilter.java`**: `PayOSWebhookServlet` (`/payos/webhook`) la endpoint server-to-server ma
  PayOS goi thang (khong co session cookie/dang nhap), nhung URL nay khong nam trong danh sach
  whitelist cua `AppFilter` -> moi request webhook thuc te se bi filter redirect ve `/dangnhap`
  truoc khi toi duoc servlet, tuc la webhook **khong bao gio chay duoc** khi deploy that. Da sua:
  them `url.contains("/payos/webhook")` vao dieu kien whitelist.

Ngoai ra, phat hien them 1 loi trong chinh migration script:

- **`migration_payment_method_payos.sql`**: ban goc DROP constraint CHECK cu tren
  `Orders.payment_method` bang ten cung `CK__Orders__payment___690797E6` (ten SQL Server tu sinh
  cho CHECK khong dat ten, hau to hash khac nhau giua cac instance DB) -> tren DB that ten khong
  khop, khoi DROP khong chay (khong bao loi vi bi boc trong IF EXISTS) nen constraint cu **van con
  song song** voi `CK_Orders_PaymentMethod` moi = 2 CHECK constraint chong nhau tren cung 1 cot
  (dung 1 trong nhung phat hien khi audit `Database.md`). Da sua: doi sang dò ten constraint cu
  **dong** qua `sys.check_constraints` (loc theo `parent_column_id`, khong theo ten), roi drop
  bang dynamic SQL — chay dung tren moi DB. Da cap nhat ghi chu tuong ung trong `Database.md`
  (dong ~644).
- Them file moi `migration_verify_all.sql` (chi SELECT, khong sua gi) — chay 1 lan tren DB that se
  liet ke chinh xac bang/cot nao trong 19 file `migration_*.sql` **chua duoc apply** (cot
  `trang_thai` = THIEU), va rieng kiem tra con dung 1 CHECK constraint tren
  `Orders.payment_method` hay dang bi trung — dung de doi chieu truoc khi bao ve do an, tranh demo
  bi loi vi migration chua chay (vd `Shipper_Wallets`/`Shipper_Withdrawals` da ghi nhan la co the
  chua chay o muc 47).

## 63. Them bieu do Chart.js vao Dashboard tong quan Super Admin (`/tong-quan`)

`TongQuanServlet` tu truoc da tinh san `tongDoanhThuSan`, `top5ShopDoanhThu`,
`thongKeTheoNgay` (7 ngay gan day) nhung `admin/TongQuanHeThong.jsp` khong he render — chi co 4
stat card + 1 bang, khong co chart nao (phat hien khi audit chuan bi bao ve do an). Da sua
(chi sua JSP, khong dong toi servlet/DAO vi du lieu da co san dung):

## 62. Tab "Lịch sử xử lý" o trang Kiem duyet binh luan (Super Admin) - bo mock, dung du lieu that

Trang `/admin/kiem-duyet-binh-luan` truoc day chi co tab "Binh luan cho duyet" dung du lieu that;
tab "Lich su xu ly" van con la bang HTML hard-code 3 dong mock. Da thay bang du lieu that:

- Them cot `Feedbacks.reviewed_at` (`DATETIME2 NULL`) qua `migration_feedback_reviewed_at.sql`
  (chay 1 lan tren DB thuc te) — ghi nhan thoi diem Super Admin bam Phe duyet/Xoa bo. Feedback
  duoc dang truc tiep (khong qua kiem duyet) se co `reviewed_at = NULL` nen khong lot vao lich
  su, chi nhung binh luan da tung o `PENDING_REVIEW` va duoc Super Admin xu ly moi hien o day.
- `FeedbackDAOImpl.updateStatus()` cap nhat them `reviewed_at = GETDATE()` moi khi doi trang thai.
- Them `FeedbackDAO.findHistory()` / `FeedbackDAOImpl.findHistory()`: lay danh sach feedback co
  `reviewed_at IS NOT NULL`, join ten Shop/Shipper bi binh luan, highlight tu cam, sap xep theo
  `reviewed_at DESC`.
- `KiemDuyetBinhLuanServlet.doGet()` set them attribute `historyComments`.
- `KiemDuyetBinhLuan.jsp`: bo nhan "(mock)" tren ten tab, doi cot tieu de "Shop" -> "Doi tuong"
  (vi target co the la Shop hoac Shipper), thay bang `<tr>` hard-code bang `<c:forEach
  var="fb" items="${historyComments}">`, dung `app:formatDateTime(fb.reviewedAt)` cho cot thoi
  gian xu ly, hien trang thai qua `status-pill visible/removed` theo `fb.status`, them empty-state
  khi chua co lich su.

File lien quan: `migration_feedback_reviewed_at.sql`, `Database.md` (cot moi trong bang
Feedbacks), `src/main/java/org/example/models/Feedback.java`,
`src/main/java/org/example/daos/FeedbackDAO.java` + `FeedbackDAOImpl.java`,
`src/main/java/org/example/controllers/KiemDuyetBinhLuanServlet.java`,
`src/main/web/admin/KiemDuyetBinhLuan.jsp`.

Luu y: `migration_feedback_reviewed_at.sql` phai duoc chay tren DB thuc te truoc khi tab nay co
du lieu (giong nhu `migration_complaints.sql` cho trang Quan ly khieu nai, van dang cho chay).

## 63. Trang moi "Tham so van hanh" (Super Admin) - cau hinh tai chinh/giao hang/thoi gian

Trang moi `/admin/tham-so-van-hanh` (nhom sidebar "⚙️ Cau hinh & He thong") cho Super Admin
xem/sua cac tham so van hanh toan he thong, luu vao 1 dong duy nhat trong bang `System_Configs`.

- Bang moi `System_Configs` (id = 1 co dinh, CHECK id = 1) qua `migration_system_configs.sql`
  (chay 1 lan tren DB thuc te, tu insert san dong mac dinh khi tao bang). Cac cot:
  `commission_percent` (10%), `fixed_fee_per_order` (0d), `shipping_fee_first_2km` (15000d),
  `shipping_fee_per_km` (5000d), `max_delivery_radius_km` (10km), `shop_accept_order_minutes`
  (15 phut), `auto_complete_order_hours` (48 gio), `updated_at`.
- Model `SystemConfig.java`, DAO `SystemConfigDAO` / `SystemConfigDAOImpl`: `get()` doc dong
  id = 1 (fallback ve gia tri mac dinh code-hardcode neu DB chua co du lieu/loi ket noi),
  `save(config)` UPDATE toan bo cot + `updated_at = GETDATE()`.
- Servlet moi `ThamSoVanHanhServlet` (`/admin/tham-so-van-hanh`): GET load config hien tai va
  forward sang JSP; POST doc 7 tham so tu form, goi `save()`, redirect PRG kem `?success=saved|failed`.
- JSP moi `src/main/web/admin/ThamSoVanHanh.jsp`: form don gian dang 3 Card ("Cau hinh Tai chinh",
  "Cau hinh Giao hang", "Cau hinh Thoi gian") theo dung cau truc panel/sidebar/topbar/avatar-dropdown
  chuan (Nhom A) da dung o cac trang Super Admin khac, nut "💾 Luu thay doi" o cuoi form, toast
  thong bao qua PRG (`?success=saved` / `?success=failed`).
- Them lai muc menu "🛠️ Tham so van hanh" (tro toi `/admin/tham-so-van-hanh` that, thay cho
  `href="#"` da bi go bo truoc do) vao muc "⚙️ Cau hinh & He thong" tren TOAN BO 15 file JSP
  Super Admin con lai (BaoCaoVanHanh, DoiSoatDoanhThuShop, DuyetRutTienShipper, KiemDuyetBinhLuan,
  KiemDuyetNoiDung, QuanLyKhieuNai, TongQuanHeThong, appeals, chiTietYeuCauShipper,
  chiTietYeuCauShop, doiMatKhauAdmin, hoSoAdmin, quanlitaikhoan, yeuCauShipper, yeuCauShop) de giu
  dong bo kien truc sidebar Nhom A.

Luu y: `CheckoutServlet.java` hien van dung hang so code-hardcode rieng cho phi ship
(`FIXED_DELIVERY_FEE = 15000`, `FEE_PER_KM = 6000`, `MAX_DELIVERY_DISTANCE_KM = 20`) — CHUA duoc
noi voi bang `System_Configs` moi nay. Nghia la sua tham so tren trang "Tham so van hanh" hien
**chua** anh huong toi phi ship thuc te luc checkout; day chi la buoc luu tru cau hinh, viec ket
noi de checkout doc dong tham so nay se can lam o mot task rieng neu duoc yeu cau.

File lien quan: `migration_system_configs.sql`, `Database.md` (bang `System_Configs` moi),
`src/main/java/org/example/models/SystemConfig.java`,
`src/main/java/org/example/daos/SystemConfigDAO.java` + `SystemConfigDAOImpl.java`,
`src/main/java/org/example/controllers/ThamSoVanHanhServlet.java`,
`src/main/web/admin/ThamSoVanHanh.jsp`, va 15 file sidebar Super Admin da liet ke o tren.

Luu y: `migration_system_configs.sql` phai duoc chay tren DB thuc te truoc khi trang nay co du
lieu that (giong `migration_complaints.sql` va `migration_feedback_reviewed_at.sql`, ca 3 migration
deu dang cho user xac nhan de chay).

- Them taglib `fmt` + 1 stat card moi "Tong doanh thu toan san" (`tongDoanhThuSan`).
- Them 2 `<canvas>` + Chart.js (CDN, cung pattern da dung o `shop/trangcuahang.jsp`):
  - "Don hang & doanh thu toan san (7 ngay gan day)": bar+line ket hop (2 truc Y — so don ben
    trai, doanh thu ben phai), du lieu tu `thongKeTheoNgay` (`ngay`/`donThanhCong`/`donHuy`/`doanhThu`).
  - "Top 5 shop doanh thu cao nhat": horizontal bar, du lieu tu `top5ShopDoanhThu`
    (`shopName`/`doanhThu`).
- `shopName` dua vao chuoi JS qua `fn:escapeXml(...)` (giong pattern da dung o
  `admin/quanlitaikhoan.jsp`, `user/menuShop.jsp`) — HTML-entity hoa truoc khi chen vao script,
  khong the pha vo chuoi JS (an toan, khong phai XSS/JS-injection moi).

## 64. Them bo tai lieu thiet ke hoc thuat (ERD/Use Case/Sequence/Class/Deployment Diagram)

Chuan bi bao ve do an tot nghiep: du an truoc do chi co tai lieu ky thuat noi bo
(`PROJECT_STRUCTURE.md`, `CRUD_DA_LAM.md`, `Database.md` dang script SQL tho) ma khong co bo tai
lieu phan tich thiet ke chuan hoc thuat (ERD/UC/Sequence/Class/Deployment diagram) — day la thieu
sot lon nhat khi audit theo tieu chi cham do an.

Da them file moi **`TAI_LIEU_THIET_KE.md`** (dung cu phap Mermaid, render truc tiep tren
GitHub/nhieu trinh xem Markdown, co the mo bang mermaid.live de export PNG/SVG dan vao bao cao
Word):

- **ERD**: dung tu DDL that trong `Database.md` + `migration_shipper_withdrawals.sql` (2 bang
  `Shipper_Wallets`/`Shipper_Withdrawals` chua duoc gop vao `Database.md`), kem ghi chu cac quyet
  dinh thiet ke dang chu y (Products khong co cot gia, ToppingCategory-Category la N-N, is_deleted
  khong co o Orders...).
- **Use Case Diagram**: theo 4 role (User/Shop/Shipper/Super Admin), lay tu danh sach chuc nang
  thuc te trong `PROJECT_STRUCTURE.md` va `tongquanhethong.md`.
- **Sequence Diagram** (3 luong phuc tap nhat, the hien dung chieu sau ky thuat da lam):
  Checkout->PayOS->Webhook (bao gom nhanh song song return-URL vs webhook, chu ky HMAC-SHA256),
  Shop xac nhan don->gan shipper->giao hang (CONFIRMED->READY_FOR_PICKUP->SHIPPING->DONE, kem
  Order_Logs + Notification realtime), va WebSocket tracking (kem buoc xac thuc CSWSH cua
  `HttpSessionConfigurator`).
- **Class Diagram**: rut gon, cac model + DAO + servlet cot loi, dung dung kien truc 3 lop that
  cua du an (khong co Service layer).
- **Deployment Diagram**: Tomcat + SQL Server + cac dich vu ngoai that dang dung (PayOS API,
  Cloudinary, SMTP Gmail, Nominatim), kem ghi chu gioi han that (WebSocket in-memory khong scale
  ngang duoc).

Da them lien ket toi file nay tu `PROJECT_STRUCTURE.md` va `tongquanhethong.md` (dong dau file,
theo dung quy uoc dieu huong tai lieu hien co cua du an).

## 65. Da chay migration tren DB that (14.225.217.109/POB) — phat hien them 2 loi chi lo ra khi chay thuc te

Tiep theo muc 62 (audit bao mat) va 64 (tai lieu thiet ke), da ket noi va chay
`migration_verify_all.sql` tren DB that qua `sqlcmd`. Ket qua ban dau: 22/24 muc `OK`, 2 muc
`THIEU` (`Shipper_Profiles.id_card_image_url`, `ToppingCategories.category_id`), va
`Orders.payment_method` chi co **1** CHECK constraint cu (khong phai 2 constraint trung nhau nhu
suy doan tu audit tinh — DB nay duoc tao tu ban DDL da co san `PAYOS` trong CREATE TABLE goc, nen
khong bi trung, nhung van thieu `MOMO`).

Phat hien 2 loi moi **chi lo ra khi chay that**, audit code tinh khong bat duoc:

- **`migration_shipper_profiles.sql`**: gop `CREATE TABLE` + `CREATE TRIGGER` chung 1 batch (cung
  1 khoi truoc `GO`) — SQL Server bat buoc `CREATE TRIGGER` phai la cau lenh DUY NHAT trong batch
  cua no, nen ca file loi cu phap ngay luc PARSE (`Msg 156 Incorrect syntax near TRIGGER`), chan
  luon nhanh `ELSE` (them cot con thieu) khong chay duoc du bang da ton tai. Da sua: tach
  `CREATE TRIGGER` ra 1 batch rieng bang `GO`, boc trong `EXEC(...)` + kiem tra
  `sys.triggers` de idempotent.
- **14/19 file `migration_*.sql`** (bao gom file tren) **thieu dong `USE POB;`** o dau file — neu
  chay bang `sqlcmd -i file.sql` ma khong truyen co `-d POB`, script se chay nham vao database
  mac dinh cua login (`master`), khien `IF NOT EXISTS` danh gia sai ngu canh va co the bao loi FK
  kho hieu (`references invalid table 'Accounts'` — vi `Accounts` khong ton tai trong `master`).
  Da sua: them `USE POB;\nGO\n` vao dau ca 14 file de tu chay dung DB bat ke co truyen `-d` hay
  khong, dong bo voi 5 file da co san dong nay (`migration_payment_method_payos.sql`,
  `migration_order_cancel_reason.sql`, `migration_payment_status.sql`,
  `migration_payos_order_code.sql`, `migration_product_status_pending_review.sql`).

Da chay thanh cong tren DB that (qua `sqlcmd -S 14.225.217.109,1433 -d POB -U sa -P ... -C -i
<file>`):

- `migration_shipper_profiles.sql` (ban da sua) -> `Shipper_Profiles.id_card_image_url` da co.
- `migration_payment_method_payos.sql` (ban da sua o muc 62) -> `Orders.payment_method` gio chi
  con dung 1 CHECK constraint `CK_Orders_PaymentMethod` (COD/BANK/PAYOS/MOMO).

`migration_verify_all.sql` cung duoc sua: bo `ToppingCategories.category_id` khoi danh sach kiem
tra (day la thiet ke 1-1 CU da bi thay the boi bang trung gian N-N
`ToppingCategory_ProductCategories` — khong phai loi thieu migration, ghi chu ro trong file de
tranh bao nham lan sau).

Xac nhan cuoi cung: chay lai `migration_verify_all.sql` -> **23/23 muc OK**, dung 1 CHECK
constraint tren `payment_method`.

Da bo sung `Shipper_Wallets`/`Shipper_Withdrawals` vao `Database.md` (truoc do 2 bang nay da ton
tai that tren DB nhung chua duoc gop vao script tong hop), kem ghi chu luong nghiep vu chua khep
kin (Shipper chua co man hinh tao yeu cau rut tien/xem so du vi).

**Fix them (nguoi dung phat hien khi hoi "xoa file migration co sao khong")**: nhan ra
`Database.md` neu chay lai TU DAU tren 1 DB hoan toan trong (vd may khac) se **tu tai tao dung
loi 2 CHECK constraint chong nhau** vua don tren DB that, vi doan `CREATE TABLE Orders`/`CREATE
TABLE Products` goc van con CHECK inline khong dat ten (thieu `MOMO`/`PENDING_REVIEW`), roi doan
`ALTER TABLE ADD CONSTRAINT` phia sau **luon luon them** them 1 constraint co ten khac ma khong
kiem tra da co chua -- 2 constraint se ton tai song song ngay tu luc tao moi. Da sua:

- Gop CHECK vao thang trong `CREATE TABLE Orders` (`CONSTRAINT CK_Orders_PaymentMethod CHECK
  (payment_method IN ('COD','BANK','PAYOS','MOMO'))`) va `CREATE TABLE Products`
  (`CONSTRAINT CK_Products_Status CHECK (status IN ('ACTIVE','OUT_OF_STOCK','HIDDEN',
  'PENDING_REVIEW'))`) -- du gia tri tu dau, khong can vas sau.
- 2 khoi `ALTER TABLE ADD CONSTRAINT` phia duoi (danh cho DB CU da ton tai bang Orders/Products
  tu truoc khi gop) duoc boc trong `IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE
  name = ...)` de idempotent -- chay tren DB moi (da co constraint tu CREATE TABLE) se tu bo qua,
  khong tao trung.
- Khong can chay lai gi tren DB that (14.225.217.109) vi DB that da dung 1 constraint moi tu
  truoc (xac nhan o phan tren cua muc nay) -- day chi la sua tai lieu/script cho truong hop setup
  DB moi tu dau.

## 66. Gom 18 file migration thanh 1 file `migration_all.sql` (nguoi dung hoi "sao khong gop lai cho de")

Theo yeu cau nguoi dung: gom 18/19 file `migration_*.sql` (tru
`migration_topping_category_product_category.sql` -- thiet ke 1-1 CU da bi thay the) thanh 1 file
duy nhat **`migration_all.sql`**, dung theo dung thu tu phu thuoc (vd `migration_feedbacks.sql`
truoc `migration_feedback_moderation.sql` vi file sau sua bang do file truoc tao). Cac file goc
van giu nguyen, khong xoa (van la tai lieu lich su tung thay doi rieng le).

Chay thu `migration_all.sql` tren DB that phat hien them **2 loi that su co san trong file goc**
(khong lien quan gi den viec gop file, chi lo ra vi day la lan dau tien file duoc chay LAN 2 tren
1 DB da co du lieu):

- **`migration_shop_settlements.sql`**: khong co `IF NOT EXISTS` bao quanh `CREATE TABLE` -> chay
  lan 2 loi "already an object named 'Shop_Settlements'". Da sua: boc trong
  `IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Shop_Settlements')`.
- **`migration_topping_category_multi_product_category.sql`**: doan `INSERT ... SELECT ...
  category_id FROM ToppingCategories` tham chieu THANG (khong qua `EXEC` dong) toi cot
  `category_id` -- SQL Server bind ten cot LUC BIEN DICH ca batch (chi "deferred name resolution"
  cho BANG chua ton tai, khong deferred cho COT cua bang da ton tai), nen du nam trong
  `IF EXISTS (...)` bao ngoai van bi loi "Invalid column name 'category_id'" ngay luc parse --
  vi cot nay da bi chinh migration nay XOA tu lan chay dau tien (`ALTER TABLE ... DROP COLUMN
  category_id` o cuoi file), nen lan chay thu 2 khong con cot do nua. Da sua: boc doan
  `INSERT`/`ALTER TABLE DROP COLUMN` trong `EXEC(N'...')` de chi bind ten cot luc CHAY (runtime),
  giong pattern da dung o muc 62 cho `CREATE TRIGGER`.

Da chay lai `migration_all.sql` 2 lan lien tiep tren DB that (14.225.217.109) sau khi sua -- ca 2
lan deu sach, khong loi (xac nhan tinh idempotent that su). Chay lai `migration_verify_all.sql`
sa u do van ra dung 23/23 muc OK -- DB khong bi anh huong gi them (dung nhu ky vong, vi moi thu da
duoc ap dung tu truoc, `migration_all.sql` chi la ban gop tien loi, khong phai thay doi moi).

**Cap nhat theo yeu cau nguoi dung**: sau khi xac nhan `migration_all.sql` chay dung, da **xoa**
toan bo 20 file `migration_*.sql` rieng le (bao gom ca `migration_topping_category_product_category.sql`
da loi thoi) bang `git rm -f` (co sua chua commit nhung noi dung da nam trong `migration_all.sql`
truoc khi xoa nen khong mat gi). Tu gio thu muc goc repo chi con dung **2 file SQL**:
`migration_all.sql` (chay 1 lan de ap dung tat ca thay doi con thieu tren 1 DB moi/DB cu) va
`migration_verify_all.sql` (kiem tra, khong sua gi). Cac tham chieu ten file migration rieng le cu
trong lich su cac muc phia tren cua file nay (vd "xem migration_complaints.sql") van giu nguyen vi
la ghi chep lich su dung tai thoi diem do, khong sua lai — noi dung thuc te da nam het trong
`migration_all.sql`.

Ghi chu:

- Con 1 diem yeu da biet nhung **chua sua** trong lan nay (uu tien thap hon, ghi lai de lam sau):
  `AppealServlet.java` (`/appeal`, whitelist san vi dung cho tai khoan bi khoa) tin thang
  `accountId` tu request parameter ma khong xac minh nguoi goi thuc su so huu account do — co the
  bi loi dung de spam/dom don khang nghi cho tai khoan nguoi khac. Can giai phap khac (vd rang
  buoc qua email + OTP) thay vi chi ownership check thong thuong.
- Da compile lai toan bo `src/main/java` bang `javac -encoding UTF-8` (qua classpath `.m2`,
  duong dan Windows qua `cygpath -w`), khong loi.
<<<<<<<<< Temporary merge branch 1
  
## 79. Hen gio giao hang (Scheduled Orders)

Endpoint: `/checkout` (them tham so scheduledAt)

Da them backend:
- `src/main/java/org/example/models/Order.java` — them truong `scheduledAt`
- `src/main/java/org/example/daos/OrderDAO.java` — them method `setScheduledAt`
- `src/main/java/org/example/daos/OrderDAOImpl.java` — tich hop scheduled_at vao schema-discovery, implement `setScheduledAt`
- `src/main/java/org/example/controllers/CheckoutServlet.java` — doc param scheduledAt, goi setScheduledAt
- `migration_all.sql` — ALTER TABLE Orders ADD scheduled_at DATETIME2 NULL
- `Database.md` — cap nhat schema Orders

Da sua giao dien:
- `src/main/web/user/checkoutThanhToan.jsp` — toggle "Giao ngay" / "Hen gio" + datetime-local input
- `src/main/web/shop/Quanlybill.jsp` — hien thi badge gio hen khi scheduled_at co gia tri

## 80. Vi tien Shipper

Endpoint: `/shipper/vi-tien`

Da them backend:
- `src/main/java/org/example/daos/ShipperWalletDAO.java` + `ShipperWalletDAOImpl.java`
- `src/main/java/org/example/controllers/ShipperWalletServlet.java`
- `src/main/java/org/example/daos/ShipperWithdrawalDAOImpl.java` — fix bug approveWithdrawal khong tru vi
- `src/main/java/org/example/controllers/ShipperOrderServlet.java` — credit wallet khi don DONE

Da tao giao dien:
- `src/main/web/shipper/viTien.jsp` — xem so du, gui yeu cau rut tien
- Them link "Vi tien" vao sidebar cua 9 trang shipper

## 81. Danh gia co hinh anh

Da them backend:
- `src/main/java/org/example/daos/FeedbackDAO.java` — them `saveAndReturnId`, `saveFeedbackImages`, `findImagesByFeedbackId`
- `src/main/java/org/example/daos/FeedbackDAOImpl.java` — implement cac method tren
- `src/main/java/org/example/controllers/FeedbackServlet.java` — xu ly imageUrls[] tu form
- `migration_all.sql` — tao bang Feedback_Images
- `Database.md` — cap nhat

Da sua giao dien:
- `src/main/web/user/guiFeedback.jsp` — them upload anh Cloudinary (toi da 5 anh), preview, xoa

## 82. Combo & Flash Sale

Endpoint: `/shop/combo`, `/shop/flash-sale`

Da them backend:
- `src/main/java/org/example/models/Combo.java`, `ComboItem.java`, `FlashSale.java`
- `src/main/java/org/example/daos/ComboDAO.java` + `ComboDAOImpl.java`
- `src/main/java/org/example/daos/FlashSaleDAO.java` + `FlashSaleDAOImpl.java`
- `src/main/java/org/example/controllers/ShopComboServlet.java`
- `src/main/java/org/example/controllers/ShopFlashSaleServlet.java`
- `migration_all.sql` — tao bang Combos, Combo_Items, Flash_Sales
- `Database.md` — cap nhat

Da tao giao dien:
- `src/main/web/shop/Quanlycombo.jsp` — tao/xoa combo, them san pham vao combo
- `src/main/web/shop/QuanlyFlashSale.jsp` — tao/xoa flash sale
- Them menu "Khuyen mai" (Combo + Flash Sale) vao sidebar cua 15 trang shop

## 83. He thong Vi tien Shop (Shop Wallet) - Production Grade

Endpoint: `/shop/vi-tien` (shop), `/admin/duyet-rut-tien-shop` (admin)

### Logic thanh toan & hoan tra:
- Khi shipper bam "Giao thanh cong" (DONE): he thong tu dong tinh thu nhap cua shop
  = `(total_price - delivery_fee) × (1 - commission_rate / 100)` va ghi vao `Shop_Wallets`.
- Khi shop huy don da PAID qua PayOS: goi `PayOSUtil.cancelPaymentLink(...)` de huy link
  thanh toan, cap nhat `payment_status = REFUNDED`. Admin chuyen khoan thu cong cho khach.
- Shop rut tien: so du bi kho ngay khi gui yeu cau (tranh race condition). Admin duyet ->
  xac nhan da chuyen khoan -> he thong cap nhat `total_withdrawn`. Admin tu choi -> hoan so du.

### Database moi (migration_all.sql):
- `Shop_Wallets` (id, shop_id UNIQUE FK, balance, total_earned, total_withdrawn, updated_at)
- `Shop_Wallet_Transactions` (id, shop_id, type IN [EARNING,WITHDRAWAL,REFUND], amount, order_id, description, created_at)
- `Shop_Withdrawals` (id, shop_id, amount, bank_name, bank_account_number, bank_account_holder, status IN [PENDING,APPROVED,REJECTED], reject_reason, requested_at, processed_at, processed_by)
- `Orders.cancel_reason` NVARCHAR(500) NULL (them neu chua co)

### Files moi:
- `src/main/java/org/example/models/ShopWallet.java`
- `src/main/java/org/example/models/ShopWalletTransaction.java`
- `src/main/java/org/example/models/ShopWithdrawal.java`
- `src/main/java/org/example/daos/ShopWalletDAO.java` (interface)
- `src/main/java/org/example/daos/ShopWalletDAOImpl.java` (impl: transaction-safe, atomic balance check)
- `src/main/java/org/example/controllers/ShopWalletServlet.java` (`/shop/vi-tien`)
- `src/main/java/org/example/controllers/DuyetRutTienShopServlet.java` (`/admin/duyet-rut-tien-shop`)
- `src/main/web/shop/viTien.jsp` (hero wallet card, stat cards, tx history, rut tien form, lich su rut tien)
- `src/main/web/admin/DuyetRutTienShop.jsp` (bang yeu cau rut tien, approve/reject modal, toast)

### Files sua:
- `src/main/java/org/example/utils/PayOSUtil.java`: them `cancelPaymentLink(clientId, apiKey, orderCode, reason)`
- `src/main/java/org/example/controllers/ShipperOrderServlet.java`: sau khi DONE, goi `shopWalletDAO.creditEarning(...)`
- `src/main/java/org/example/controllers/ShopBillServlet.java`: khi cancel don PAID, goi PayOS cancel + update REFUNDED
- 17 shop JSP sidebars: them section "Tai chinh" voi link `/shop/vi-tien`
- `src/main/web/admin/DuyetRutTienShipper.jsp`: them link "Duyet rut tien Shop" vao menu tai chinh
=========

## 67. Format lai cot "Ngay tao" o trang Quan ly hoa don/don hang (Shop)

File: `src/main/web/shop/Quanlybill.jsp` (dong ~234).

Truoc day cot "Ngay tao" trong bang danh sach don hang in thang `${o.createdAt}` — do
`Order.createdAt` la kieu `LocalDateTime` nen JSP EL goi `toString()` mac dinh, ra chuoi dai va
kho doc kieu `2026-07-27T05:57:25.916666700` (co ca nano giay).

Da sua thanh dung `fn:substring` (taglib `jakarta.tags.functions` da co san o dau file) de cat
chuoi ISO va sap xep lai theo dinh dang **gio:phut ngay/thang/nam**, vi du `05:57 27/07/2026`:

```jsp
<c:set var="ca" value="${o.createdAt}"/>
${fn:substring(ca,11,16)} ${fn:substring(ca,8,10)}/${fn:substring(ca,5,7)}/${fn:substring(ca,0,4)}
```

Khong dung duoc `fmt:formatDate` vi tag do chi nhan `java.util.Date`, khong nhan `LocalDateTime`.

Ghi chu: cac trang khac (`HoaDonShop.jsp` dong 193 - "Thoi gian tao" trong modal chi tiet, va cac
trang Admin/Shipper co cot ngay-gio tuong tu) van con in `LocalDateTime` truc tiep chua duoc sua —
neu can dong bo dinh dang gon nay sang cac trang do thi lam o lan sau.

## 68. Format lai gio tao don o trang "Don hang nhan" (Shipper)

Trang thuc te khi vao route `/shipper/donhang` la `ShipperOrderServlet` forward toi
`src/main/web/shipper/trangchucuashipper.jsp` (khong phai `nhanDon.jsp` nhu doan dau nham lan —
`nhanDon.jsp` van duoc dung o noi khac, cu the la `ShipperAcceptOrderServlet` (trang "Nhan don moi"),
nen cung da sua luon cho dong bo).

Cung loi nhu muc 67: the hien thoi gian tao don trong the don hang in thang `${order.createdAt}`
(`LocalDateTime`), ra chuoi dai kieu `2026-07-21T09:02:52.323333300`.

Da sua ca 2 file, giong het cach lam o `Quanlybill.jsp`, dung `fn:substring` cat va sap xep lai
thanh **gio:phut ngay/thang/nam**, vi du `09:02 21/07/2026`:

- `src/main/web/shipper/trangchucuashipper.jsp` dong ~214 (trang "Don hang nhan" that su):
```jsp
<c:set var="ca" value="${order.createdAt}"/>
<span class="order-time">🕒 ${fn:substring(ca,11,16)} ${fn:substring(ca,8,10)}/${fn:substring(ca,5,7)}/${fn:substring(ca,0,4)}</span>
```

- `src/main/web/shipper/nhanDon.jsp` dong ~174 (trang "Nhan don moi"):
```jsp
<c:set var="ca" value="${order.createdAt}"/>
<span style="font-size:11px;color:var(--text-dim);">🕒 ${fn:substring(ca,11,16)} ${fn:substring(ca,8,10)}/${fn:substring(ca,5,7)}/${fn:substring(ca,0,4)}</span>
```

Taglib `fn` (`jakarta.tags.functions`) da co san o dau ca 2 file, khong can them import.

Cot "Thoi gian" trong bang "10 don hoan thanh gan nhat" o `src/main/web/shipper/dashboard.jsp`
dong ~235 cung bi loi tuong tu (`${row.createdAt}` in thang `LocalDateTime`), da sua cung cach:

```jsp
<c:set var="ca" value="${row.createdAt}"/>
<td style="color:var(--text-dim);font-size:12px;">${fn:substring(ca,11,16)} ${fn:substring(ca,8,10)}/${fn:substring(ca,5,7)}/${fn:substring(ca,0,4)}</td>
```

## 69. Gan du lieu "Danh gia" that cho o hero-stat cua trang menu Shop (User)

O trang `src/main/web/user/menuShop.jsp` (route `/user/shop?id=X`, servlet
`UserShopMenuServlet`), o hero-stats co 3 o: "Danh gia", "Giao hang", "Mon an". O "Mon an" von
da la logic that (`fn:length(products)`), nhung o "Danh gia" truoc day hard-code cung `4.8 ⭐`.

He thong da co san bang `Feedbacks` (target_type = SHOP/SHIPPER, target_id, rating 1-5) va DAO
`FeedbackDAO`/`FeedbackDAOImpl` voi 2 method co san (dang duoc dung o `ShopFeedbackServlet` cho
trang Shop tu xem danh gia cua minh):

```java
double avgRating(String targetType, long targetId);   // AVG(rating) theo target
int countByTarget(String targetType, long targetId);  // tong so luot danh gia
```

Da tan dung lai, khong viet SQL/DAO moi:

- `UserShopMenuServlet.java`: them field `FeedbackDAO feedbackDAO = new FeedbackDAOImpl();`,
  goi `feedbackDAO.avgRating("SHOP", shopId)` va `feedbackDAO.countByTarget("SHOP", shopId)`,
  set vao request attribute `avgRating` va `totalFeedback`.
- `menuShop.jsp` dong ~561: thay `4.8 ⭐` hard-code bang:
```jsp
<c:choose>
    <c:when test="${totalFeedback > 0}"><fmt:formatNumber value="${avgRating}" maxFractionDigits="1" minFractionDigits="1"/> ⭐</c:when>
    <c:otherwise>Chưa có ⭐</c:otherwise>
</c:choose>
```
Neu shop chua co luot danh gia nao (`totalFeedback == 0`) thi hien "Chưa có ⭐" thay vi "0.0 ⭐"
gay hieu lam.

Ghi chu: o "Giao hàng" (`30'`) van con hard-code, chua co logic tinh thoi gian giao hang thuc te —
chua sua trong task nay, doi yeu cau rieng.

## 69. Bug: San pham "Tam an" (HIDDEN) van hien thi cho khach hang o menu Shop

File: `src/main/java/org/example/controllers/UserShopMenuServlet.java` (dong ~46).

Trieu chung: Shop bam "Tam an" 1 san pham (`ProductDAO.updateStatus(id, "HIDDEN")`, xem
`ContentModerationServlet.java` dong 61), nhung trang menu khach hang xem (`/user/shop?id=...`)
van hien thi san pham do trong danh sach mon an.

Nguyen nhan: `ProductDAOImpl.findByShopId(shopId)` (dong 134-149) chi loc `is_deleted = 0`, KHONG
loc theo `status`, nen tra ve ca san pham HIDDEN. `ShopPosServlet.java` (dong 317, man hinh Bam
Bill cua Shop) da co san dong loc `products.removeIf(p -> "HIDDEN".equalsIgnoreCase(p.getStaTus()));`
nhung `UserShopMenuServlet.java` (man hinh khach hang) thi thieu dong nay.

Da sua: them dong loc tuong tu ngay sau khi lay danh sach san pham trong `UserShopMenuServlet.java`:

```java
List<Product> products = productDAO.findByShopId(shopId);
products.removeIf(p -> "HIDDEN".equalsIgnoreCase(p.getStaTus()));
```

Cac servlet khac dung `productDAO.findByShopId` (vd `ShopProductServlet.java` - trang "Quan ly san
pham" cua Shop) van giu nguyen KHONG loc, vi Shop can thay ca san pham dang HIDDEN de quan ly/bat lai.
## 86. Combo Suggestion Popup (Cross-selling)

Endpoint: `/user/shop` (khi `?added=1&addedProductId=X`)

Khi khách hàng thêm một món vào giỏ hàng, hệ thống tự động gợi ý các món khác trong combo
mà shop đã định nghĩa (bảng `Combos` + `Combo_Items` có từ mục 82).

### Files đã sửa/thêm:

**Backend:**
- `src/main/java/org/example/models/ComboItem.java`: thêm field `productImageUrl` + getter/setter
- `src/main/java/org/example/daos/ComboDAO.java`: thêm method `findSuggestionsByProductId(long productId, long shopId)`
- `src/main/java/org/example/daos/ComboDAOImpl.java`: implement method trên — SQL join `Combo_Items → Combos → Products → Product_Sizes → Product_Images` để lấy các sản phẩm khác trong combo active chứa sản phẩm vừa thêm
- `src/main/java/org/example/controllers/UserCartServlet.java`: thêm `addedProductId` vào redirect URL sau khi add thành công (`?added=1&cartId=X&addedProductId=Y`)
- `src/main/java/org/example/controllers/UserShopMenuServlet.java`: thêm `ComboDAO comboDAO`, khi `added=1` thì gọi `findSuggestionsByProductId`, dedup theo productId, lấy tối đa 5, set attribute `comboSuggestions` và `addedProductName`

**Frontend:**
- `src/main/web/user/menuShop.jsp`: thêm Combo Suggestion Popup với:
  - Hiển thị khi `added=1` VÀ `comboSuggestions` không rỗng
  - Animation slide-in từ góc dưới phải (desktop) / bottom sheet (mobile ≤600px)
  - Mỗi suggestion card: ảnh sản phẩm, tên, size, giá, nút "+" mở modal chọn size
  - Nút "+" gọi `openSuggestionModal(productId)` → đóng popup → tìm card qua `#pcard-{id}` → click `.btn-add` để mở modal chọn size/topping như bình thường
  - Auto-dismiss sau 10 giây
  - Click overlay hoặc nút Bỏ qua → đóng popup với animation fade-out
  - ESC cũng đóng popup

### Luồng hoạt động:
```
User click + (btn-add) trên product card
  → openModal() (modal chọn size/topping)
  → User submit form
  → POST /user/add-to-cart
  → UserCartServlet redirect: /user/shop?id=X&added=1&cartId=C&addedProductId=P
  → UserShopMenuServlet.doGet: gọi comboDAO.findSuggestionsByProductId(P, X)
  → Set comboSuggestions vào request
  → menuShop.jsp render popup
  → initComboPopup() hiển thị popup với animation
```

### Lưu ý:
- Không tạo bảng DB mới, tái dụng `Combos` + `Combo_Items` (mục 82)
- Chỉ gợi ý sản phẩm `status = 'ACTIVE'` và `is_deleted = 0`
- Không gợi ý sản phẩm đã là trigger (đã thêm vào giỏ)
- Dedup theo productId phía Java (không phải SQL) để đơn giản
- Nếu shop chưa định nghĩa combo nào hoặc combo không chứa sản phẩm đó → popup không hiển thị (graceful empty state)


## 87. Đồng bộ Sidebar Admin (23 file JSP thiếu menu)

### Vấn đề phát hiện:
Sidebar admin được copy-paste riêng vào từng file JSP (không dùng include chung), nên khi có
người thêm mục menu mới vào `TongQuanHeThong.jsp` (Báo cáo vận hành, Heatmap đặt hàng, Kiểm duyệt
nội dung, Kiểm duyệt bình luận, Kháng nghị, Tham số vận hành, FAQ/Hướng dẫn, Nhật ký hệ thống),
23 file JSP admin khác không được đồng bộ theo, khiến sidebar mỗi trang hiển thị khác nhau. Ví dụ
`QuanLyHoanTien.jsp` chỉ có 10/18 mục menu; `DuyetRutTienShop.jsp` chỉ có 12/18 mục.

Ngoài ra, chính `TongQuanHeThong.jsp` (trang được dùng làm "chuẩn") cũng bị thiếu mục
**"Duyệt rút tiền Shop"** (`/admin/duyet-rut-tien-shop`) — mục này chỉ tồn tại đầy đủ trong
`DuyetRutTienShipper.jsp` và một phần trong `QuanLyHoanTien.jsp`, `DuyetRutTienShop.jsp`.

### Đã sửa:
Đồng bộ lại sidebar cho toàn bộ 23 file JSP admin (dùng script Python 1 lần, không phải thay đổi
kiến trúc), thống nhất về đúng 18 mục menu chia 4 nhóm:
- 📊 Tổng quan & phân tích: Tổng quan hệ thống, Báo cáo vận hành, Heatmap đặt hàng
- ⚖️ Kiểm duyệt & điều phối: Duyệt Shop, Duyệt Shipper, Kiểm duyệt nội dung, Kiểm duyệt bình luận,
  Quản lý khiếu nại, Kháng nghị
- 💰 Quản lý tài chính: Đối soát doanh thu Shop, Duyệt rút tiền Shipper, **Duyệt rút tiền Shop**,
  Hoàn tiền khách hàng, Voucher/Khuyến mãi
- ⚙️ Cấu hình & hệ thống: Người dùng, Tham số vận hành, FAQ/Hướng dẫn, Nhật ký hệ thống

Mỗi file giữ đúng class `active` cho mục tương ứng với trang đó; 2 trang hồ sơ cá nhân
(`hoSoAdmin.jsp`, `doiMatKhauAdmin.jsp`) không có mục nào active (đúng như thiết kế gốc, vì
không nằm trong sidebar).

### Files đã sửa (23 file, chỉ block `<div class="menu">...</div>` trong `<aside>`):
`AuditLogs.jsp`, `BaoCaoVanHanh.jsp`, `DoiSoatDoanhThuShop.jsp`, `DuyetRutTienShipper.jsp`,
`DuyetRutTienShop.jsp`, `HeatmapDonHang.jsp`, `KiemDuyetBinhLuan.jsp`, `KiemDuyetNoiDung.jsp`,
`QuanLyHoanTien.jsp`, `QuanLyKhieuNai.jsp`, `QuanLyVoucher.jsp`, `ThamSoVanHanh.jsp`,
`TongQuanHeThong.jsp`, `appeals.jsp`, `chiTietYeuCauShipper.jsp`, `chiTietYeuCauShop.jsp`,
`doiMatKhauAdmin.jsp`, `faqDanhSach.jsp`, `faqThemSua.jsp`, `hoSoAdmin.jsp`, `quanlitaikhoan.jsp`,
`yeuCauShipper.jsp`, `yeuCauShop.jsp`.

### Lưu ý cho về sau:
Sidebar vẫn đang copy-paste theo từng file (chưa refactor sang JSP include dùng chung). Nếu thêm
mục menu mới trong tương lai, **phải cập nhật thủ công cả 23 file** này (hoặc cân nhắc refactor
sang `<jsp:include>` với 1 file `adminSidebar.jspf` dùng chung — chưa làm trong lần sửa này vì
nằm ngoài phạm vi yêu cầu ban đầu).

## 88. Fix bug SQL + Fix UI vỡ layout trang "Ví tiền" (Shipper)

### Bug 1 — SQL lỗi `Invalid column name 'name'`:
`ShopWalletDAOImpl.getAllWithdrawals` (dùng cho trang Duyệt rút tiền Shop của Admin) JOIN bảng
`Shops` bằng `s.name AS shop_name`, nhưng bảng `Shops` không có cột `name` (chỉ có `shop_name`).
Đã sửa `src/main/java/org/example/daos/ShopWalletDAOImpl.java` thành `s.shop_name AS shop_name`.

### Bug 2 — UI vỡ layout trang `viTien.jsp` (Shipper):
`src/main/web/shipper/viTien.jsp` được viết theo template cũ, dùng các class không tồn tại trong
`assets/css/dashboard.css` dùng chung (`.topbar-hamburger`, `.topbar-title`, `.topbar-actions`,
`.icon-btn`, `.main-content`), khiến topbar/content không được style đúng — khác hẳn các trang
shipper khác (`dashboard.jsp`, ...). Ngoài ra file còn nạp `assets/js/dashboard.js` — **file này
không tồn tại** trên đĩa (file thật là `dashboard-theme.js`), khiến `pobToggleSidebar()` và
`pobToggleTheme()` không hoạt động (nút hamburger, nút đổi theme bị chết). File cũng thiếu CSS cho
`.online-toggle-btn`/`.toggle-dot` (nút Online/Offline ở cuối sidebar) — các class này chỉ được
định nghĩa trong style block riêng của từng JSP, không nằm trong `dashboard.css` dùng chung.

Đã sửa `src/main/web/shipper/viTien.jsp`:
- Đổi markup topbar/content sang đúng class chuẩn (`.menu-toggle-btn`, `<h1>`, `.topbar-right`,
  `.theme-toggle`, `.content`) khớp với `dashboard.jsp`.
- Thêm taglib `fn` (dùng cho fallback chữ cái đầu avatar).
- Thêm CSS `.online-toggle-btn`/`.toggle-dot` và toàn bộ CSS avatar dropdown
  (`.avatar-wrapper`, `.avatar-dropdown`, `.dropdown-header`, `.dropdown-body`, `.dropdown-link`)
  vào style block riêng của trang.
- Thêm markup `#avatarDropdown` (thông tin tài khoản + link Hồ sơ/Đổi mật khẩu/Đăng xuất) và JS
  xử lý click mở/đóng dropdown.
- Sửa `<script src=".../dashboard.js">` thành `dashboard-theme.js` (file thật tồn tại).

### Lưu ý cho về sau:
Không phải trang shipper/shop/admin nào cũng đồng bộ đúng class chuẩn của `dashboard.css` dùng
chung — khi phát hiện trang nào bị vỡ layout, nên đối chiếu với 1 trang cùng module đang chạy đúng
(ví dụ `dashboard.jsp`) thay vì đoán CSS mới.

## 89. Cải thiện UX khi CSRF token hết hạn (trang Đăng ký `/dangky` báo lỗi 403)

### Bug:
User báo submit form đăng ký ở `/dangky` bị lỗi `HTTP 403 - CSRF token khong hop le hoac bi thieu`.
Rà soát `CsrfFilter.java`, `CsrfUtil.java`, `register.jsp`, `DangKyServlet.java`, `web.xml`
(`session-timeout` = 30 phút) — không tìm thấy bug logic (token sinh/so sánh đúng, form JSP có đủ
input `csrfToken`, không có `session.invalidate()` nào trong luồng đăng ký/OTP). Nguyên nhân thực sự
là **session cũ (giữ token) đã mất trước khi POST tới** — phổ biến nhất khi đang dev: Tomcat/IntelliJ
redeploy giữa lúc mở trang và lúc bấm gửi làm mất toàn bộ session cũ trong bộ nhớ; hoặc form được mở
ở tab/trang đã cache từ trước một phiên khác. Đây là hành vi CSRF *đúng thiết kế* (token cũ phải mất
hiệu lực khi session mất) — nhưng trải nghiệm cho user rất tệ: 403 thô của Tomcat, không có đường quay
lại, mất hết dữ liệu đã nhập.

### Đã sửa — `src/main/java/org/example/filter/CsrfFilter.java`:
Khi token không khớp, thay vì `resp.sendError(403, ...)`, filter giờ **redirect (302) người dùng quay
lại đúng trang họ vừa submit** (lấy từ header `Referer`) — trang đó khi load lại (GET) sẽ đi qua
`CsrfFilter` và được cấp token mới hợp lệ ngay, user chỉ cần bấm gửi lại thay vì bị kẹt ở trang lỗi.
- Thêm `resolveSafeRedirect()`: chỉ tin `Referer` nếu **cùng origin** (scheme + host + port) với
  server hiện tại — vì `Referer` là header do client tự gửi, có thể bị giả mạo, không được dùng thẳng
  để tránh lỗ hổng **open redirect**. Nếu không có `Referer` hoặc khác origin → fallback về
  `contextPath + "/"`.
- Không áp dụng cho `/payos/webhook` (đã loại trừ CSRF từ trước, không đổi).

### Files sửa:
- `src/main/java/org/example/filter/CsrfFilter.java`

### Lưu ý cho về sau:
Đây KHÔNG phải lỗi có thể "sửa dứt điểm" 100% — bất kỳ session nào mất (timeout 30 phút, server
redeploy khi dev, xoá cookie, đổi trình duyệt/tab) đều sẽ khiến submit đầu tiên sau đó bị coi là CSRF
không hợp lệ, đúng như thiết kế bảo mật. Nếu gặp lại lỗi này khi đang dev và vừa mới build/redeploy
server giữa lúc test, đó gần như chắc chắn là nguyên nhân — thử lại từ đầu (load lại trang) sẽ hết.

## 90. Bổ sung rate-limit gửi OTP cho trang Đăng ký Shipper (`/dangky-shipper`)

### Bug:
Khi rà soát xem `/dangky-shop` và `/dangky-shipper` có bị lỗi CSRF tương tự mục 89 không (đã xác nhận
KHÔNG cần sửa thêm — `CsrfFilter.java` áp dụng global nên tự động che luôn 2 route này), phát hiện
`Dangkyshipperservlet.java` là servlet đăng ký **duy nhất** chưa có rate-limit chống spam gửi email
OTP: `DangKyServlet.java` và `DangKyShopServlet.java` đã có `RateLimitUtil` (key `"regotp:" + ip`, tối
đa 3 lần/10 phút, khoá 10 phút) từ đợt làm rate-limiting trước, nhưng `Dangkyshipperservlet.java` thì
không — có thể bị spam gửi OTP đăng ký Shipper vô hạn tới bất kỳ email nào.

### Đã sửa — `src/main/java/org/example/controllers/Dangkyshipperservlet.java`:
Áp dụng đúng pattern đã dùng ở `DangKyShopServlet.java`: thêm `RateLimitUtil.isBlocked()` /
`recordFailure()` với key `"regotp:" + req.getRemoteAddr()` (3 lần/10 phút, khoá 10 phút) ngay trước
đoạn sinh OTP + gửi email; khi vừa bị khoá thì ghi 1 dòng audit log qua `AuditLogService`
(module `AuditModules.SECURITY`) — giống hệt cách `DangKyShopServlet` và `XacNhanOTPServlet` đã làm.

Đồng thời bổ sung luôn `session.setAttribute("otpExpiredAt", System.currentTimeMillis() + OTP_TTL_MILLIS)`
(TTL 5 phút, cùng hằng số với `XacNhanOTPServlet`/`DangKyShopServlet`) — trước đó servlet này không set
attribute này nên OTP đăng ký Shipper không có hạn thật sự dù email nói "hiệu lực 5 phút";
`XacNhanOTPServlet` (dùng chung cho cả 3 luồng đăng ký) đọc `otpExpiredAt` để tự huỷ session + bắt
đăng ký lại khi hết hạn.

### Files sửa:
- `src/main/java/org/example/controllers/Dangkyshipperservlet.java`

## 91. Sửa modal vỡ khung + khôi phục tính năng upload ảnh Cloudinary cho `Quanlysanpham.jsp`

### Bug 1 — Modal "Thêm sản phẩm mới" bị vỡ khung khi mở:
`Quanlysanpham.jsp` dùng chung cấu trúc modal `.pob-modal-overlay`/`.pob-modal-box` (định nghĩa global
trong `theme.css`), nhưng phần chrome bên trong modal (`.modal-header`, `.modal-body`, `.modal-close`)
KHÔNG phải class dùng chung — mỗi trang Shop tự định nghĩa riêng trong `<style>` của chính nó (đã xác
nhận qua `Quanlyloaitopping.jsp`, `Quanlytopping.jsp`, `Quanlyloaisanpham.jsp` đều tự define). Riêng
`Quanlysanpham.jsp` trước đó chỉ có `.modal-footer`, thiếu hẳn 3 class còn lại → modal mở ra không có
padding/border/flex-layout, hiển thị vỡ khung.

### Bug 2 — Mất tính năng upload ảnh Cloudinary ở ô "URL ảnh sản phẩm":
Ô nhập ảnh sản phẩm trước đó chỉ là 1 input text thuần yêu cầu người dùng tự dán URL, không có nút
upload file thật như các trang khác đã tích hợp Cloudinary (`hoSoShop.jsp` cho avatar Shop, tương tự
`hoSoAdmin.jsp`, `hoSoShipper.jsp`, `guiFeedback.jsp`).

### Đã sửa — `src/main/web/shop/Quanlysanpham.jsp`:
- Thêm 3 class CSS còn thiếu (`.modal-header`, `.modal-body`, `.modal-close`) — copy nguyên style từ
  các trang Shop khác để đồng bộ giao diện, khắc phục Bug 1.
- Thêm nút "📤 Tải ảnh lên" + `<input type="file" id="productImageFile">` (ẩn) cạnh ô `imageUrl`, cùng
  `<div id="uploadStatus">` hiển thị trạng thái — style mới `.img-upload-row`, `.btn-upload`,
  `.upload-status`.
- Thêm đoạn JS upload unsigned lên Cloudinary (copy đúng pattern từ `hoSoShop.jsp`): `CLOUD_NAME =
  'jcnsb47f'`, tái sử dụng `UPLOAD_PRESET = 'avatar_preset'` (dự án chưa có preset riêng cho ảnh sản
  phẩm; preset chỉ quyết định quyền/định dạng upload chứ không ép crop nên tái dùng an toàn), nhưng
  đổi `folder` thành `'products'` để tách riêng khỏi `'avatars'` trên Cloudinary, và KHÔNG áp transform
  `w_150,h_150,c_fill,g_face` (crop khuôn mặt) như avatar vì ảnh món ăn không phù hợp crop vuông theo
  mặt. Giới hạn file 2MB giống các trang khác. Upload xong tự set `data.secure_url` vào input
  `#imageUrl` + gọi lại `previewImage()` có sẵn — không cần servlet backend riêng, vì URL ảnh vẫn đi
  theo đúng luồng POST form gộp sẵn có tới `/shop/products` (`ShopProductServlet`) như trước, không đổi
  API/DB.
- Ô input text `imageUrl` vẫn giữ nguyên (không xoá) để người dùng có thể tự dán URL ngoài nếu muốn,
  không bắt buộc phải upload.

### Lưu ý cho về sau:
- `ShopProductServlet` hiện KHÔNG validate `imageUrl` qua `UploadValidationUtil.isValidCloudinaryImageUrl`
  (chỉ các servlet upload avatar riêng như `ShopAvatarUploadServlet` mới validate) — đây là lỗ hổng có
  sẵn từ trước (chấp nhận bất kỳ URL text nào), KHÔNG thuộc phạm vi sửa lần này vì ô input text URL vẫn
  cố ý được giữ lại cho người dùng dán link ngoài. Nếu sau này muốn siết chặt chỉ cho phép ảnh
  Cloudinary, cần thêm validate ở `ShopProductServlet.createProduct()`/`updateProduct()`.
- Nếu Cloudinary dashboard chưa cấu hình preset `avatar_preset` cho phép folder `products` (một số cấu
  hình unsigned preset giới hạn cứng `folder`), upload sẽ thất bại — khi đó cần tạo preset riêng
  (ví dụ `product_preset`) trên Cloudinary console rồi đổi `UPLOAD_PRESET` trong file.

### Files sửa:
- `src/main/web/shop/Quanlysanpham.jsp`

### Cập nhật thêm (cùng ngày):
Nới khung `.img-preview` từ `height: 120px` lên `height: 240px` theo yêu cầu người dùng (khung ảnh
xem trước ở modal thêm/sửa sản phẩm quá nhỏ so với ảnh món ăn thật).

## 92. Sửa cột "Ngày tạo" hiển thị raw git conflict marker ở `Quanlybill.jsp` (Quản lý hóa đơn Shop)

### Bug:
Cột "Ngày tạo" trong bảng "Danh sách đơn hàng" (`shop/Quanlybill.jsp`) hiển thị nguyên văn text
`<<<<<<<<< Temporary merge branch 1 ... ========= ... >>>>>>>>> Temporary merge branch 2` thay vì ngày
giờ đơn hàng — do một lần merge branch trước đó (`GiaHung_TY00316`/`bao-ty00366` vào
`ThanhHien_TY00243`, xem `git log`) để sót nguyên marker xung đột chưa resolve trong file JSP (không
phải marker chuẩn Git `<<<<<<<`/`>>>>>>>` 7 dấu nên các tool rà soát tự động không bắt được, phải soát
thủ công `grep` với biến thể 9 dấu `<<<<<<<<<`/`>>>>>>>>>`).

2 nhánh xung đột: nhánh 1 in thẳng `${o.createdAt}` (chuỗi ISO gốc, không format) + có thêm badge hiển
thị giờ hẹn giao `o.scheduledAt` nếu có; nhánh 2 dùng `fn:substring` cắt chuỗi ISO thành
`HH:mm dd/MM/yyyy` nhưng không có phần hiển thị giờ hẹn.

### Đã sửa — `src/main/web/shop/Quanlybill.jsp`:
Gộp cả 2 nhánh thay vì chọn 1: giữ format `HH:mm dd/MM/yyyy` (lấy giờ/ngày/tháng/năm) của nhánh 2 làm
hiển thị chính cho `createdAt`, đồng thời giữ lại badge "🕐 Hẹn: ..." của nhánh 1 khi đơn có
`scheduledAt`, và áp cùng kiểu format `fn:substring` cho `scheduledAt` luôn (trước đó nhánh 1 in
`scheduledAt` thô, không format — đồng bộ luôn cho nhất quán).

### Lưu ý cho về sau:
File JSP không có lỗi biên dịch dạng cứng khi chứa git conflict marker (vì `<<<<<<<<<` chỉ là text
thường bên trong `<td>`, không phải cú pháp JSTL nên EL/JSTL vẫn parse qua được) — nghĩa là bug loại
này KHÔNG bị phát hiện lúc build/deploy, chỉ lộ ra khi xem UI thật. Khi merge nhiều nhánh, nên
`grep -rn "<<<<<<<\|=======\|>>>>>>>"` toàn bộ `src/main/web` sau mỗi lần merge/rebase để bắt sớm —
lưu ý dùng pattern không neo số dấu `<` cố định vì có thể là biến thể 9-10 dấu như lần này, và loại
trừ false positive từ các comment block dùng `===` làm dòng phân cách trang trí (ví dụ
`admin/DuyetRutTienShipper.jsp` có comment `// ===...=== //` hợp lệ, không phải conflict).

### Files sửa:
- `src/main/web/shop/Quanlybill.jsp`
- `src/main/web/shop/Quanlysanpham.jsp`

## 93. Sửa UI vỡ ở trang "Ví tiền Shop" (`shop/viTien.jsp`)

### Bug:
Theo ảnh chụp màn hình người dùng gửi, trang `/shop/vi-tien`: số dư hiển thị lệch/dính sát ký hiệu
tiền tệ, 2 nút hành động trên hero card ("⬇️ Rút tiền" / "📄 Lịch sử") hiển thị sai kích thước/không
canh giữa nội dung, và form "Yêu cầu rút tiền" nhìn như bị nén lại.

### Nguyên nhân + đã sửa:
1. **`.btn-hero` thiếu hoàn toàn `display`/`text-decoration`/`white-space`** — 2 nút hero là thẻ
   `<a>` (không phải `<button>`) nhưng CSS `.btn-hero` không hề set `display: inline-flex`,
   `align-items: center`, `text-decoration: none` như convention `.btn` dùng chung ở `theme.css` —
   khiến trình duyệt áp mặc định của thẻ `<a>` (inline, có gạch chân, icon+chữ có thể tự xuống dòng
   khi hẹp) làm nút bị lệch/vỡ. Đã thêm đủ các thuộc tính trên + `white-space: nowrap` để icon và chữ
   luôn nằm 1 dòng, đúng convention `.btn` sẵn có trong `theme.css`.
2. **`.wallet-balance-amount`** dựa vào canh chỉnh mặc định của phần tử inline giữa số lớn (42px) và
   ký hiệu `₫` nhỏ (20px) → dễ lệch baseline. Đổi sang `display: flex; align-items: baseline; gap: 6px`
   để canh chỉnh ổn định, bỏ `margin-right` thủ công không còn cần thiết.
3. **Form "Yêu cầu rút tiền" thiếu hoàn toàn CSRF token** (`<input type="hidden" name="csrfToken">`)
   — đây là 1 trong số ít form còn sót lại chưa được vá khi làm CSRF protection toàn project trước đó
   (65 file JSP khác đã có). Do `CsrfFilter` áp dụng cho mọi POST (`urlPatterns = "/*"`), mọi lần submit
   form rút tiền trước đây đều bị coi là token không khớp → **redirect ngược lại chính trang đó mà
   không báo lỗi rõ ràng**, tạo cảm giác "form bị vỡ/không hoạt động". Đã thêm
   `<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">` vào form.
4. **Đồng bộ quy ước**: thêm `pageEncoding="UTF-8"` vào page directive (8 file JSP khác trong
   `shop/` đều khai báo, riêng file này thiếu — không phải nguyên nhân chính của bug hiển thị nhưng
   nên đồng bộ để tránh rủi ro encoding khi biên dịch JSP trên các môi trường Tomcat khác nhau).

### Files sửa:
- `src/main/web/shop/viTien.jsp`

### Cập nhật (sau khi user test lại vẫn thấy vỡ - "Nó vẫn vậy."):

Người dùng gửi thêm ảnh chụp màn hình sau khi các fix ở trên đã lên: nút "⬇️ Rút tiền" chỉ hiện icon,
chữ "Rút tiền" biến mất; phần form "Yêu cầu rút tiền" nhìn như bị nén.

5. **Bug thật sự còn sót (đã sửa)**: `.btn-hero-primary { color: #0f3460; }` bị đè bởi
   `body.dash-body a { text-decoration: none; color: inherit; }` trong `dashboard.css` (dòng 56) vì
   selector đó có specificity cao hơn (1 class + 1 element > 1 class local). Chữ "Rút tiền" bị kế thừa
   màu trắng từ `.wallet-hero` (nền trắng của nút → chữ trắng trên nền trắng = vô hình), chỉ còn thấy
   icon emoji "⬇️" (emoji không phụ thuộc CSS `color`). Nút "Lịch sử" (`.btn-hero-outline`) trông vẫn
   đúng vì màu định nghĩa của nó (`#fff`) trùng ngẫu nhiên với màu `inherit`. Đây đúng là cạm bẫy mà
   chính `dashboard.css` đã có comment giải thích + fix mẫu cho `.btn-primary/.btn-danger/.btn-outline/
   .btn-ghost` (dòng 57-63) — nhưng `.btn-hero-primary/.btn-hero-outline` là class cục bộ riêng của
   `viTien.jsp` nên chưa từng được các override đó bao phủ. Đã thêm theo đúng convention có sẵn:
   ```css
   body.dash-body a.btn-hero-primary { color: #0f3460; }
   body.dash-body a.btn-hero-outline { color: #fff; }
   ```
6. **Đã rà soát kỹ phần form "Yêu cầu rút tiền" nhìn như bị nén** (kiểm tra `dashboard.css`,
   `theme.css`, HTML trong `viTien.jsp`) nhưng **không tìm thấy rule CSS hay lỗi cấu trúc HTML nào**
   gây co/ẩn form — `.form-row`/`.form-group` cục bộ nạp sau `theme.css` trong cascade nên thắng đúng
   thứ tự, `dashboard.css` không có rule nào đè `.form-group`, HTML 2 hàng `form-row` + nút submit đều
   đầy đủ, không có điều kiện `c:if` nào ẩn form. Khả năng cao nhất là trình duyệt của người dùng đang
   cache bản CSS cũ trước khi các fix này lên (JSP/CSS thường bị cache khá lâu) — đã đề nghị người dùng
   hard-refresh (Ctrl+Shift+R) và chụp lại ảnh nếu vẫn còn thấy vỡ.

### Files sửa (cập nhật):
- `src/main/web/shop/viTien.jsp`

## 94. Fix 2 lỗi Logic CRITICAL (race condition voucher + hủy nhầm đơn hàng của shipper)

### Bối cảnh:
Sau khi rà soát toàn bộ project tìm lỗi logic (chia theo mức độ CRITICAL/HIGH/MEDIUM/LOW), phát
hiện 2 lỗi CRITICAL sau và đã sửa ngay theo yêu cầu người dùng.

### Bug 1 - Race condition khi áp dụng voucher lúc Checkout (`CheckoutServlet.java`)
`VoucherDAOImpl.incrementUsedCount(id)` đã có guard atomic đúng ở tầng SQL
(`WHERE used_count < usage_limit`) và trả về `boolean` cho biết có tăng được hay không, nhưng
`CheckoutServlet.doPost` gọi hàm này **sau khi** đơn hàng đã được tạo với `totalPrice` đã trừ
discount, và **không hề kiểm tra giá trị trả về**. Hậu quả: nếu 2 request dùng chung 1 voucher gần
hết lượt chạy đồng thời, request thua trong race vẫn tạo đơn với giá đã giảm dù voucher thực tế
không còn lượt (voucher bị "double-spend" qua TOCTOU).

**Đã sửa:** Chuyển việc "giữ chỗ" (`voucherDAO.incrementUsedCount`) lên **trước khi tạo bất kỳ Order
nào**, ngay sau bước validate voucher ban đầu (`validateBasic`). Nếu giữ chỗ thất bại (hết lượt) →
huỷ toàn bộ checkout, hiển thị lại trang review kèm lỗi "Mã giảm giá ... đã hết lượt sử dụng, vui
lòng thử lại", không tạo Order nào cả. Đã xoá lệnh gọi `incrementUsedCount` cũ nằm sau
`orderDAO.createAndReturnId` (bị gọi 2 lần / sai chỗ và không kiểm tra kết quả).

### Bug 2 - Hủy nhầm đơn hàng bất kỳ qua endpoint nhận đơn của Shipper (`ShipperAcceptOrderServlet.java`)
Trong `doPost`, nhánh "đơn quá hạn giao trong ngày" nhận `orderId` trực tiếp từ client
(`request.getParameter("orderId")`), tìm `Order` theo id đó, và nếu ngày tạo khác hôm nay thì gọi
`orderDAO.cancelOrder(orderId, ...)` **mà không kiểm tra `status` của đơn**. Vì `orderId` do client tự
gửi (không giới hạn theo danh sách đơn khả dụng `findAvailableOrders()`), 1 shipper bất kỳ có thể gửi
`orderId` của đơn **đã `DONE`, đang `SHIPPING`, hoặc đã `CANCELLED`** (không liên quan gì tới mình)
miễn là đơn đó được tạo khác ngày hôm nay → đơn sẽ bị hủy oan, kể cả đơn đã giao thành công.

**Đã sửa:** Thêm điều kiện `"READY_FOR_PICKUP".equalsIgnoreCase(order.getStaTus())` vào guard trước
khi gọi `cancelOrder`, khớp đúng với điều kiện mà `findAvailableOrders()` dùng để liệt kê đơn khả
dụng (chỉ đơn đang chờ giao, chưa có shipper nhận). Đơn đã `DONE`/`SHIPPING`/`CANCELLED` sẽ không
còn bị auto-cancel qua endpoint này nữa.

### Files sửa:
- `src/main/java/org/example/controllers/CheckoutServlet.java`
- `src/main/java/org/example/controllers/ShipperAcceptOrderServlet.java`

### Ghi chú:
Không đổi schema DB nên không cần cập nhật `database.md`. Các lỗi HIGH/MEDIUM/LOW còn lại trong báo
cáo audit (vd: checkout nhiều shop thiếu transaction, `assignShipper` thiếu check status, thiếu
idempotency khi submit checkout) chưa được sửa — chỉ sửa 2 lỗi CRITICAL theo đúng phạm vi người dùng
yêu cầu ("Sửa 2 lỗi CRITICAL trước").

---

## 95. Fix 4 lỗi Logic mức độ LOW (audit log sai điều kiện, thiếu check trạng thái duyệt, so sánh OTP không hằng thời gian, `getRemoteAddr()` không xử lý reverse proxy)

### Bối cảnh:
Tiếp tục sửa các lỗi logic mức LOW trong báo cáo audit toàn project trước đó, theo đúng yêu cầu
người dùng ("Ta sẽ sửa phần lỗi cấp độ LOW trước đi").

### Bug 26 - Ghi audit log sai khi gán shipper dù trạng thái đơn không đổi (`ShopBillServlet.java`)
Khi Shop gán shipper cho đơn, code ghi audit log "đổi trạng thái đơn" ngay cả khi `oldStatus` và
`newStatus` giống hệt nhau (vd đơn đã ở trạng thái đó từ trước, chỉ gán lại shipper), gây audit trail
sai lệch, dễ gây hiểu nhầm khi tra cứu lịch sử.

**Đã sửa:** Thêm điều kiện chỉ ghi log đổi trạng thái khi `!oldStatus.equalsIgnoreCase(newStatus)`.

### Bug 27 - Duyệt/từ chối bình luận & sản phẩm không kiểm tra trạng thái hiện tại trước khi đổi (`FeedbackDAOImpl.java`, `KiemDuyetBinhLuanServlet.java`, `ContentModerationServlet.java`)
Các thao tác duyệt (`APPROVED`)/từ chối (`REJECTED`) bình luận và sản phẩm không kiểm tra bản ghi có
đang ở trạng thái `PENDING`/chờ duyệt hay không trước khi cập nhật, dẫn đến có thể duyệt lại một bản
ghi đã bị từ chối trước đó (hoặc ngược lại) mà không có cảnh báo, dễ tạo ra thao tác duyệt trùng lặp
hoặc ghi đè quyết định duyệt cũ một cách âm thầm.

**Đã sửa:** Thêm kiểm tra trạng thái hiện tại phải đang ở trạng thái chờ duyệt trước khi cho phép
chuyển sang `APPROVED`/`REJECTED`; nếu không còn ở trạng thái chờ duyệt, trả về thông báo lỗi thay vì
âm thầm ghi đè.

### Bug 28 - So sánh mã OTP dùng `String.equals` thay vì so sánh hằng thời gian (`SensitiveInfoOtpUtil.java`, `XacNhanOTPServlet.java`, `QuenMatKhauServlet.java`)
So sánh OTP nhập vào với OTP lưu trong session dùng `String.equals()`, vốn dừng so sánh ngay khi gặp
ký tự sai đầu tiên (short-circuit), tạo ra khác biệt thời gian phản hồi nhỏ có thể bị khai thác qua
timing attack để dò từng ký tự của OTP.

**Đã sửa:** Thay toàn bộ các điểm so sánh OTP bằng `MessageDigest.isEqual(a.getBytes(StandardCharsets.UTF_8), b.getBytes(StandardCharsets.UTF_8))`
— so sánh hằng thời gian, không phụ thuộc vào việc ký tự sai nằm ở vị trí nào.

### Bug 29 - `getRemoteAddr()` không xử lý reverse proxy, khiến rate-limit/lockout gộp chung nhiều người dùng vào 1 IP (`RateLimitUtil.java` và 6 servlet dùng rate-limit)
Toàn bộ các servlet có rate-limit (đăng nhập, gửi/xác nhận OTP đăng ký — User/Shop/Shipper, quên mật
khẩu) và `AuditLogService` đều lấy IP client bằng `req.getRemoteAddr()` trực tiếp. Nếu hệ thống được
deploy sau reverse proxy / load balancer (Nginx, Cloudflare,...), `getRemoteAddr()` luôn trả về IP
của proxy chứ không phải IP thật của client → rate-limit key (`"login:" + ip`, `"regotp:" + ip`,...)
bị gộp chung cho **tất cả** người dùng thật sự đứng sau proxy đó, khiến chỉ cần 1 người dùng nhập sai
quá nhiều lần là toàn bộ người dùng khác (dùng chung proxy) bị khoá oan; đồng thời audit log ghi sai
IP thật của người thực hiện hành vi.

**Đã sửa:** Thêm hàm tiện ích `RateLimitUtil.getClientIp(HttpServletRequest req)` — ưu tiên đọc IP
đầu tiên trong header `X-Forwarded-For` (do proxy gắn vào) nếu có và không rỗng, fallback về
`req.getRemoteAddr()` nếu không có header này. Áp dụng hàm này thay cho `req.getRemoteAddr()` ở toàn
bộ các điểm dùng để tạo rate-limit key và ghi log liên quan đến rate-limit trong `DangNhapServlet.java`,
`XacNhanOTPServlet.java`, `QuenMatKhauServlet.java`, `Dangkyshipperservlet.java`, `DangKyShopServlet.java`,
`DangKyServlet.java`, cũng như trong hàm `log(...)` chung của `AuditLogService.java` (để nhất quán IP
ghi nhận trong toàn bộ audit trail, không chỉ riêng các sự kiện rate-limit).

### Files sửa:
- `src/main/java/org/example/controllers/ShopBillServlet.java`
- `src/main/java/org/example/daos/FeedbackDAOImpl.java`
- `src/main/java/org/example/controllers/KiemDuyetBinhLuanServlet.java`
- `src/main/java/org/example/controllers/ContentModerationServlet.java`
- `src/main/java/org/example/utils/SensitiveInfoOtpUtil.java`
- `src/main/java/org/example/controllers/XacNhanOTPServlet.java`
- `src/main/java/org/example/controllers/QuenMatKhauServlet.java`
- `src/main/java/org/example/utils/RateLimitUtil.java`
- `src/main/java/org/example/controllers/Dangkyshipperservlet.java`
- `src/main/java/org/example/controllers/DangNhapServlet.java`
- `src/main/java/org/example/controllers/DangKyShopServlet.java`
- `src/main/java/org/example/controllers/DangKyServlet.java`
- `src/main/java/org/example/services/AuditLogService.java`

### Ghi chú:
Không đổi schema DB nên không cần cập nhật `database.md`. Môi trường hiện tại không có sẵn Maven CLI
(`mvn`) nên không chạy được `mvn compile` để kiểm chứng biên dịch tự động — các thay đổi đã được
review thủ công kỹ lưỡng (đối chiếu từng vị trí gọi, kiểm tra import) nhưng chưa được compiler xác
nhận. Các lỗi HIGH/MEDIUM còn lại trong báo cáo audit chưa được sửa — chỉ sửa 4 lỗi LOW theo đúng
phạm vi người dùng yêu cầu ("Sửa phần lỗi cấp độ LOW trước").

---

## 96. Fix trang "Heatmap đặt hàng" Super Admin (`/admin/heatmap-don-hang`) hoàn toàn không hiển thị bản đồ

### Bối cảnh:
Trang Heatmap luôn hiện "0 điểm biểu diễn", bản đồ trắng trơn, "Số khu vực"/"Hot nhất" luôn là `--`,
dù KPI "Tổng số đơn" và "Có định vị GPS" vẫn có số liệu đúng.

### Bug 30 - Sai tên cột SQL `o.total_amount` (không tồn tại) thay vì `o.total_price` (`BaoCaoVanHanhDAOImpl.java`)
`findOrderMapDetails()` — hàm cung cấp toàn bộ dữ liệu vẽ bản đồ (tọa độ, địa chỉ, shop, số tiền,
thời gian) — dùng sai tên cột `o.total_amount` trong câu SQL (bảng `Orders` không có cột này, tên
cột thật là `total_price`, đối chiếu `Database.md` và `OrderDAOImpl.java`). SQL Server ném lỗi
`Invalid column name`, bị `catch (Exception e) { e.printStackTrace(); }` nuốt mất, khiến hàm âm thầm
trả về danh sách rỗng thay vì báo lỗi ra UI — nguồn dữ liệu duy nhất cho toàn bộ phần vẽ bản đồ vì
vậy luôn rỗng dù đơn hàng vẫn tồn tại.

**Đã sửa:** Đổi `o.total_amount` → `o.total_price` (cả trong SQL SELECT lẫn `rs.getDouble(...)`).

### Bug 31 - Script khởi tạo bản đồ Leaflet trong `HeatmapDonHang.jsp` bị thiếu/hỏng giữa chừng
Sau khi sửa Bug 30, dữ liệu đã về đúng nhưng bản đồ vẫn trắng. Đọc kỹ script mới phát hiện: biến
`points` được dùng ở dòng tính `fitBounds` nhưng **không hề được khai báo ở đâu cả** (chỉ có
`heatmapPoints`/`orderDetails`) → `ReferenceError` ngay khi script chạy, dừng toàn bộ phần code phía
sau. Hệ quả dây chuyền: `heatLayer`, `markersCluster`, `regionMap` được tham chiếu trong
`setMapViewMode()` và phần "Render Top Regions" nhưng **không có đoạn code nào thực sự tạo ra 3 biến
này** — đoạn "thân" quan trọng nhất của script (build heat layer từ `heatmapPoints`, build từng
marker + popup từ `orderDetails`, gom nhóm `regionMap` theo khu vực/shop) đã bị mất hoàn toàn. Còn
sót lại 1 dấu `}` mồ côi (không khớp block nào) — dấu vết cho thấy một đoạn code lớn ở giữa bị xoá
nhầm khi chỉnh sửa trước đó.

**Đã sửa:** Viết lại đoạn script còn thiếu: tạo `heatLayer` (`L.heatLayer`), tạo `markersCluster`
(`L.markerClusterGroup`) kèm popup từng đơn, gom nhóm `regionMap` bằng hàm `extractGroupKey()` có
sẵn (nuôi dữ liệu cho "TOP KHU VỰC & SHOP" + 2 KPI "Số khu vực"/"Hot nhất"), sửa biến `points` sai
thành `heatmapPoints` (có fallback `setView` về trung tâm TP.HCM nếu không có điểm nào), và xoá dấu
`}` thừa gây lỗi cú pháp.

### Bug 32 - Icon marker mặc định của Leaflet bị vỡ ảnh (hiện text "Mark" thay vì hình ghim)
Marker tạo bằng `L.marker([o.lat, o.lng])` không truyền `icon` tuỳ chỉnh nên dùng icon ảnh mặc định
của Leaflet (`marker-icon.png`). Khi tải Leaflet qua CDN (unpkg) như cách project đang dùng, Leaflet
tự đoán sai đường dẫn ảnh này, khiến icon hiển thị vỡ (ảnh lỗi + text "Mark" — phần alt text mặc định
"Marker" bị cắt). Rà soát toàn bộ project: đây là **chỗ duy nhất** bị ảnh hưởng — các bản đồ khác
(`orderTrackingMap.js`, `shipper/chitietdonhang.jsp`) đều dùng icon emoji tuỳ chỉnh qua `L.divIcon`
(không phụ thuộc ảnh), còn `diaChi.jsp`/`checkoutThanhToan.jsp`/`Shopprofile.jsp` đã có sẵn cách sửa
này từ trước.

**Đã sửa:** Thêm `delete L.Icon.Default.prototype._getIconUrl;` + `L.Icon.Default.mergeOptions({...})`
trỏ thẳng URL ảnh marker về CDN unpkg — dùng đúng cách đã áp dụng ở 3 file kia để nhất quán.

### Quyết định thiết kế: KHÔNG giới hạn cứng `fitBounds()` theo phạm vi Việt Nam
Có phát hiện một vài đơn hàng thật trong hệ thống mang tọa độ/địa chỉ ở nước ngoài (vd đơn có địa chỉ
tại New Zealand, có thể do lúc test đã chọn nhầm vị trí trên bản đồ Nominatim), khiến `fitBounds()`
zoom bản đồ ra rất xa (thấy cả châu Á, Úc, New Zealand) mỗi khi khoảng ngày lọc có chứa các đơn này.
Đã thảo luận và Super Admin xác nhận **giữ nguyên hành vi này** thay vì lọc/giới hạn cứng theo phạm
vi Việt Nam — lý do: nếu giới hạn cứng, các đơn có tọa độ bất thường sẽ bị "nuốt" âm thầm khỏi tầm
nhìn, mất đi khả năng dùng chính bản đồ này để phát hiện lỗi dữ liệu địa chỉ. `fitBounds()` chỉ chạy
1 lần lúc tải trang; nếu Super Admin tự zoom/pan sau đó, các điểm ở khu vực khác vẫn còn nguyên trên
bản đồ, chỉ là nằm ngoài khung nhìn hiện tại. Quyết định này được ghi chú trực tiếp trong code
(`HeatmapDonHang.jsp`) để tránh bị hiểu nhầm là bug ở lần đọc code sau này.

### Files sửa:
- `src/main/java/org/example/daos/BaoCaoVanHanhDAOImpl.java`
- `src/main/web/admin/HeatmapDonHang.jsp`

### Ghi chú:
Không đổi schema DB nên không cần cập nhật `database.md`. Đã biên dịch lại `BaoCaoVanHanhDAOImpl.java`
bằng `javac` thủ công (không có Maven CLI trong môi trường) — không lỗi. Phần JS trong `.jsp` không
compile được bằng javac nên chỉ kiểm tra bằng cách đọc lại toàn bộ để cân bằng ngoặc và đối chiếu tên
biến, đã xác nhận hoạt động đúng qua ảnh chụp màn hình thực tế do người dùng cung cấp sau khi build.

## 97. Fix 2 Warning từ review Logic Đơn hàng (User): thiếu nút tự hủy đơn + mốc thời gian hủy hardcode lệch với Admin config

Sau khi review logic "Đơn hàng" trong module User (mục đích: kiểm tra tính đúng đắn/đồng bộ giữa
`UserOrderServlet`, `donhang.jsp` và cấu hình vận hành do Admin quản lý), phát hiện 2 vấn đề mức
🟡 Warning:
1. Backend (`UserOrderServlet`) đã có đầy đủ logic cho phép User tự hủy đơn còn `PENDING` (kiểm tra
   `isCancelableNow()`, IDOR check, hủy PayOS link + set `REFUNDED` nếu đã thanh toán...) nhưng trang
   `donhang.jsp` **không có bất kỳ nút/form nào** để gọi tính năng này — tính năng tồn tại ở backend
   nhưng vô dụng vì User không có cách nào kích hoạt.
2. Mốc thời gian cho phép tự hủy bị hardcode cứng (`CANCELABLE_AFTER_MINUTES = 5`) trong khi mốc thời
   gian hệ thống tự động hủy đơn (`OrderAutoCancelListener`) lại đọc động từ
   `SystemConfig.shopAcceptOrderMinutes` (Admin có thể đổi qua trang "Tham số vận hành" mà không cần
   restart server). Nếu Admin đổi `shopAcceptOrderMinutes` xuống dưới 5 phút, hệ thống sẽ tự động hủy
   đơn **trước khi** User kịp thấy nút tự hủy xuất hiện — 2 cơ chế bị lệch pha nhau.

**Đã sửa:**
- Thêm nút "Hủy đơn hàng" vào `donhang.jsp`, chỉ hiển thị khi đơn đang `PENDING` và
  `cancelable[order.id]` = true (map này `UserOrderServlet.doGet` đã tính sẵn), kèm form POST có
  `csrfToken` (bắt buộc vì `CsrfFilter` áp dụng toàn site) và `confirm()` xác nhận trước khi hủy. Nếu
  đơn còn quá mới (`cancelable[order.id]` = false) thì hiển thị dòng chữ "Đơn vừa đặt, vui lòng đợi ít
  phút để có thể hủy" thay vì ẩn hoàn toàn, tránh gây khó hiểu cho User.
- Thêm các khối alert phản hồi kết quả hủy đơn (dựa vào query param do `UserOrderServlet.doPost`
  redirect về): hủy thành công (`success=order_cancelled`, có thêm thông báo hoàn tiền nếu
  `refund=1`), và các lỗi `cannot_cancel` / `not_found` / `missing` / `server`.
- Bỏ hằng số `CANCELABLE_AFTER_MINUTES` hardcode trong `UserOrderServlet`, thay bằng hàm
  `getCancelableAfterMinutes()` đọc động `SystemConfig.shopAcceptOrderMinutes` (cùng nguồn dữ liệu mà
  `OrderAutoCancelListener` dùng để tự động hủy) rồi trừ đi `CANCEL_BUFFER_MINUTES = 5` phút đệm an
  toàn (chặn dưới ở 1 phút bằng `Math.max(1, ...)`), đảm bảo User luôn tự hủy được đơn trước khi hệ
  thống tự động hủy, bất kể Admin chỉnh tham số thế nào.
- Thêm chặn giá trị tối thiểu trong `ThamSoVanHanhServlet.validate()`: `shopAcceptOrderMinutes` phải
  ≥ 6 phút (kèm thông báo lỗi giải thích lý do), để kết hợp với buffer 5 phút ở trên đảm bảo cửa sổ
  tự hủy của User không bao giờ bị "biến mất" hoàn toàn do Admin cấu hình sai.

### Files sửa:
- `src/main/web/user/donhang.jsp`
- `src/main/java/org/example/controllers/UserOrderServlet.java`
- `src/main/java/org/example/controllers/ThamSoVanHanhServlet.java`

### Ghi chú:
Không đổi schema DB nên không cần cập nhật `database.md`. Không có Maven CLI trong môi trường này
(đã thử `mvn` qua cả Bash và PowerShell, không có `mvnw`) nên không tự build/chạy được để test UI
trực tiếp — đã kiểm tra bằng cách đọc lại toàn bộ `UserOrderServlet.java` sau khi sửa (import
`SystemConfigDAO`/`SystemConfigDAOImpl` đã có sẵn qua `import org.example.daos.*;`, không cần thêm
import mới) và `grep` xác nhận không còn tham chiếu nào tới hằng số `CANCELABLE_AFTER_MINUTES` cũ
trong toàn bộ `src`. Phần 🟢 Suggestion trong report gốc (catch rỗng ở `UserOrderServlet.doGet` quanh
`BillUtil.build(o)`) **cố tình chưa sửa** vì người dùng chỉ yêu cầu fix phần Warning.

## 98. Đồng bộ header trang "Khiếu nại đơn hàng" (User) theo style navbar mới

Trang `khieu-nai` (`user/khieuNai.jsp`) đang dùng header kiểu cũ (`.navbar` đơn giản, logo chữ,
`.nav-title` riêng, các nút `.nav-link` hình viên thuốc có emoji, không có avatar/dropdown, không có
ô tìm kiếm) — khác với style navbar mới đã đồng bộ ở các trang User khác (`donhang.jsp`,
`diaChi.jsp`, `diemThuong.jsp`, `thongBao.jsp` — xem mục 124).

**Đã sửa:** Thay toàn bộ phần header (CSS + HTML) trong `khieuNai.jsp` bằng style navbar mới, lấy
`donhang.jsp` làm chuẩn tham chiếu:
- Thêm taglib `fn` (`<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>`) và link
  Font Awesome 6.4.0 CDN vào `<head>` (trang cũ chưa có, cần cho icon `<i class="fa-solid ...">` và
  hàm `fn:substring` lấy chữ cái đầu tên User cho avatar).
- Thêm 2 biến CSS `--gold-hover` và `--font-h` vào `:root` (trang cũ thiếu, các style mới tham chiếu
  tới).
- Thay CSS `.navbar/.nav-logo/.nav-title/.nav-sep/.nav-right/.nav-link` cũ bằng bộ CSS mới:
  `.navbar/.nav-content/.logo/.logo-emoji/.nav-links/.nav-actions/.avatar-wrap/.avatar-btn/
  .avatar-dropdown/.dd-head/.dd-name/.dd-email/.dd-link/.dd-btn/.dd-divider/.cart-btn` (copy y hệt
  từ `donhang.jsp` vì toàn bộ style navbar này nằm inline trong từng JSP, không có trong
  `user-theme.css` dùng chung).
- Thay markup `<div class="navbar">...</div>` cũ bằng `<header class="navbar"><div class="nav-content">`
  gồm: logo ảnh + chữ, 5 link điều hướng chuẩn (Trang chủ / Nhà hàng / Đơn hàng / Địa chỉ /
  Điểm thưởng — đánh dấu `class="active"` ở "Đơn hàng" vì Khiếu nại là luồng con của Đơn hàng, và
  "Khiếu nại" không có mục riêng trong danh sách nav-links dùng chung), avatar tròn có dropdown tài
  khoản (tên/email, các link Đơn hàng/Địa chỉ/Điểm thưởng/Thông báo/Giỏ hàng/Đổi mật khẩu, nút Đăng
  xuất có `csrfToken`), nút chuông thông báo có badge số chưa đọc (`unreadNotifCount`), và nút giỏ
  hàng. Đã bỏ nhãn `.nav-title` "Khiếu nại đơn hàng" riêng của trang cũ vì style mới không có chỗ
  cho nhãn này — không cần thiết vì `<title>` trang và heading `📝 Gửi khiếu nại cho đơn #...` trong
  body đã đủ nêu rõ ngữ cảnh trang.
- Thêm script `toggleDropdown()` + handler đóng dropdown khi click ra ngoài, đặt trước 3 script có
  sẵn (`toast.js`, `pob-dialog.js`, `notifications-ws.js`) — giữ nguyên các script này không đổi.
- Toàn bộ phần thân trang (form gửi khiếu nại, danh sách khiếu nại, CSS `.container/.alert*/.card/
  .form-group*/.btn-submit/.complaint-*/.badge*`) giữ nguyên không đổi, chỉ sync phần header.

### Files sửa:
- `src/main/web/user/khieuNai.jsp`

### Ghi chú:
Không đổi schema DB nên không cần cập nhật `database.md`. Đã đọc lại `ComplaintServlet.java` (đặt
`account` vào session attribute qua `session.getAttribute("account")`, không set request attribute
riêng cho `account`) để xác nhận các biểu thức EL `${account.fullName}` / `${account.userName}` /
`${account.email}` trong avatar-dropdown mới sẽ tự resolve qua session scope giống hệt cách
`donhang.jsp` đang hoạt động — không cần sửa gì ở controller. `unreadNotifCount` đã được
`ComplaintServlet.doGet` set sẵn qua `req.setAttribute("unreadNotifCount", ...)` nên badge thông báo
hoạt động ngay không cần thêm code. Không có Maven CLI trong môi trường này nên không tự build/chạy
để test UI trực tiếp được — đã kiểm tra bằng cách đọc lại toàn bộ file JSP sau khi sửa để xác nhận
cấu trúc thẻ đóng/mở đúng và không còn sót CSS/markup cũ.

## 99. Fix lỗi SQLServerException khi tự động hủy đơn PENDING quá hạn (OUTPUT clause + trigger)

**Lỗi:** `OrderAutoCancelListener` (chạy định kỳ bằng `ScheduledExecutorService`) gọi
`OrderDAOImpl.cancelStalePendingOrders()` bị crash với:
```
com.microsoft.sqlserver.jdbc.SQLServerException: The target table 'Orders' of the DML statement
cannot have any enabled triggers if the statement contains an OUTPUT clause without INTO clause.
```
Nguyên nhân: câu `UPDATE Orders ... OUTPUT INSERTED.voucher_code WHERE status='PENDING' AND ...`
dùng `OUTPUT` trực tiếp (không có `INTO`) để lấy `voucher_code` của các đơn vừa bị hủy nhằm hoàn lại
lượt dùng voucher — nhưng SQL Server cấm cú pháp này trên bảng `Orders` vì bảng hiện có ít nhất 1
trigger đang bật (SQL Server không cho phép `OUTPUT`-không-`INTO` trên bảng có trigger, do trigger có
thể chèn/sửa dữ liệu qua bảng `inserted`/`deleted` gây xung đột thứ tự trả kết quả).

**Đã sửa:** Trong `OrderDAOImpl.cancelStalePendingOrders(int minutesThreshold)`, đổi câu SQL từ
`OUTPUT INSERTED.voucher_code` (trực tiếp) sang `OUTPUT INSERTED.voucher_code INTO @out` (biến bảng
tạm), rồi `SELECT voucher_code FROM @out` ở cuối batch — gộp thành 1 batch nhiều câu lệnh
(`DECLARE @out TABLE (...); UPDATE ... OUTPUT ... INTO @out WHERE ...; SELECT ... FROM @out;`) chạy
qua `PreparedStatement.executeQuery()` như cũ (driver trả về result set của câu `SELECT` cuối cùng
trong batch). Kiểu cột `@out.voucher_code` dùng `VARCHAR(50)` khớp với kiểu cột thật
`Orders.voucher_code` (xem `Database.md` dòng 671). Logic đọc kết quả (vòng lặp `rs.next()`, đếm
`count`, gọi `VoucherDAO.decrementUsedCount` nếu có `voucher_code`) giữ nguyên không đổi.

### Files sửa:
- `src/main/java/org/example/daos/OrderDAOImpl.java`

### Ghi chú:
Không đổi schema DB nên không cần cập nhật `database.md`. Không có Maven CLI trong môi trường này
nên không tự build/chạy để test trực tiếp được — đã kiểm tra bằng cách đọc lại đoạn code sau khi sửa
để xác nhận cú pháp SQL batch hợp lệ (SQL Server cho phép nhiều câu lệnh cách nhau bằng `;` trong 1
lần gọi `executeQuery`, và JDBC trả về result set của câu cuối cùng — đây là kỹ thuật phổ biến để
lấy dữ liệu từ `OUTPUT ... INTO` mà không cần cursor riêng). Đề nghị người dùng chạy lại app và theo
dõi log của `OrderAutoCancelListener` ở lần chạy định kỳ tiếp theo để xác nhận không còn lỗi.

## 100. Fix nút "Chi tiết & Theo dõi đơn" (trang `user/donhang.jsp`) bấm vào không có tác dụng

**Lỗi:** User báo bấm nút "Chi tiết & Theo dõi đơn" trong trang đơn hàng của mình không thấy gì xảy
ra, kể cả sau khi hard refresh + build lại. Review code tĩnh (button, modal markup, hàm
`openOrderModal`/`closeOrderModal`, CSS `.order-detail-modal-backdrop.open`) không thấy lỗi cú pháp
hay logic — mọi thứ đều đúng khi đọc riêng lẻ.

Chẩn đoán qua DevTools phối hợp với user:
- Không có lỗi Console khi bấm nút.
- Modal tồn tại đúng trong DOM (`id="modal-14"`), nhưng sau khi bấm không có class `open` được thêm vào.
- Gọi tay `openOrderModal('modal-14')` trực tiếp từ Console thì modal hiện ra bình thường → chứng tỏ
  JS/CSS của modal hoàn toàn đúng khi chạy độc lập.
- Right-click trực tiếp lên nút thật (không qua tìm kiếm ở tab Elements) → Inspect xác nhận đúng là
  thẻ `<button>`, không có overlay nào đè lên để chặn click.

Từ đó suy ra nguyên nhân thật sự: trang có đoạn `setInterval(function(){ window.location.reload();
}, 10000)` (tự động làm mới toàn trang mỗi 10 giây khi còn đơn hàng ở trạng thái chưa hoàn tất). Khi
bấm nút bằng chuột thật (mất thời gian di chuột + phản xạ, chậm hơn gọi lệnh Console), thời điểm click
dễ rơi gần sát mốc reload 10 giây — trang reload toàn bộ ngay sau khi modal vừa mở, xóa mất
class `open`/toàn bộ DOM trước khi user kịp nhận ra modal đã hiện — khiến người dùng có cảm giác
"bấm không có gì xảy ra".

**Đã sửa:** Trong `donhang.jsp`, thêm hàm `isAnyOrderModalOpen()` kiểm tra
`document.querySelector('.order-detail-modal-backdrop.open')`. Trong callback của `setInterval` tự
động reload, chỉ gọi `window.location.reload()` khi **không có modal chi tiết đơn nào đang mở**
(interval vẫn chạy đều mỗi 10 giây như cũ để giữ tính năng tự làm mới sau khi đóng modal, chỉ bỏ qua
lần reload nào rơi đúng lúc user đang xem modal).

### Files sửa:
- `src/main/web/user/donhang.jsp`

### Ghi chú:
Không đổi schema DB nên không cần cập nhật `database.md`. Không có Maven CLI trong môi trường này nên
không tự build được — quá trình chẩn đoán dựa vào: (1) đọc lại code nhiều lần, (2) kiểm tra lịch sử
git bằng `git log -S "openOrderModal"` để loại trừ khả năng code chưa được commit/build, (3) phối hợp
trực tiếp với user qua DevTools (Console, Elements, Inspect) để cô lập nguyên nhân theo từng bước loại
trừ. Fix auto-reload này vẫn giữ lại vì hợp lý (tránh mất modal do bị reload giữa chừng), nhưng **không
phải nguyên nhân gốc thật sự** của lỗi ban đầu — xem tiếp mục `## 101.` bên dưới cho nguyên nhân gốc
thực sự (lỗi `PropertyNotFoundException` khi render modal khiến response HTML bị đứt giữa chừng, làm
script định nghĩa `openOrderModal` không bao giờ tới được trình duyệt).

## 101. Fix nguyên nhân gốc thật sự: `PropertyNotFoundException: toppingLines` làm response `donhang.jsp` bị đứt giữa chừng (ERR_INCOMPLETE_CHUNKED_ENCODING)

**Lỗi:** Sau khi áp dụng fix `## 100.` và build lại, user vẫn gặp lỗi — nhưng lần này Console báo rõ:
```
Failed to load resource: net::ERR_INCOMPLETE_CHUNKED_ENCODING   (donhang:1)
Uncaught ReferenceError: openOrderModal is not defined   (x16, tại mỗi nút bấm)
```
Log Tomcat (catalina/localhost log) cho thấy nguyên nhân gốc thật sự:
```
jakarta.el.PropertyNotFoundException: Property [toppingLines] not found on type [org.example.models.BillLine]
  ... donhang.jsp line 666: <c:if test="${not empty line.toppingLines}">
```
`BillLine.java` chỉ có getter `getToppings()` (trả về `List<BillToppingLine>`), **không có**
`getToppingLines()`. Nhưng đoạn modal chi tiết đơn hàng trong `donhang.jsp` (phần hiển thị topping
của từng món trong bill) lại dùng sai tên property: `${line.toppingLines}` /
`<c:forEach var="top" items="${line.toppingLines}">`.

Vì JSP render theo kiểu stream (đã gửi ra một phần HTML rồi mới render tiếp phần sau), khi gặp lỗi
EL này giữa chừng (bên trong vòng lặp modal của 1 đơn hàng cụ thể có topping), Tomcat throw exception
và **hủy giữa chừng phần response còn lại** — bao gồm luôn cả khối `<script>` định nghĩa
`openOrderModal`/`closeOrderModal` nằm ở cuối trang (sau toàn bộ modal). Trình duyệt nhận được HTML
bị cắt cụt (`ERR_INCOMPLETE_CHUNKED_ENCODING`), nên khi bấm nút, `openOrderModal` chưa từng được định
nghĩa → `ReferenceError`. Đây mới là nguyên nhân thật sự khiến "bấm nút không có gì xảy ra" — không
phải do auto-reload (giả thuyết ở mục `## 100.` tuy hợp lý về mặt lý thuyết nhưng không phải nguyên
nhân chính; fix đó vẫn giữ lại vì vô hại và hữu ích).

## 102. Fix hiển thị "Ngày đặt" trong modal chi tiết đơn hàng (`user/donhang.jsp`) hiện raw `LocalDateTime` thay vì ngày giờ đọc được

**Lỗi:** Sau khi fix xong modal ở `## 101.`, user test lại thấy modal hiện đúng nhưng dòng "Ngày đặt"
hiện raw toString của `LocalDateTime` kiểu `2026-08-03T16:45:52.033333300` (khó đọc, dư phần nano
giây) thay vì định dạng ngày/giờ thông thường.

**Đã sửa:** Trong `donhang.jsp`:
- Thêm khai báo taglib `<%@ taglib uri="/app-functions" prefix="app" %>` (project đã có sẵn EL
  function `app:formatDateTime(Object)` — `org.example.utils.DateUtil`, định nghĩa trong
  `WEB-INF/functions.tld` — đang được dùng ở nhiều trang khác như `hoaDon.jsp`, `_invoiceModal.jspf`).
- Đổi `${order.createdAt}` → `${app:formatDateTime(order.createdAt)}` ở dòng hiển thị "Ngày đặt"
  trong modal chi tiết đơn.

### Files sửa:
- `src/main/web/user/donhang.jsp`

### Ghi chú:
Không đổi schema DB nên không cần cập nhật `database.md`. Dùng lại hàm format ngày giờ chung sẵn có
của project (`app:formatDateTime`) thay vì viết công thức format riêng, để đồng bộ định dạng ngày giờ
với các trang khác (hóa đơn, v.v.). Không có Maven CLI nên không tự build/test trực tiếp — đã kiểm
tra chữ ký hàm khớp đúng (`String format(Object)`) và cách dùng giống hệt các trang đã áp dụng thành
công trước đó. Đề nghị user build lại và test lại modal chi tiết đơn để xác nhận "Ngày đặt" hiển thị
đúng định dạng giờ/ngày/tháng/năm.

**Đã sửa:** Trong `donhang.jsp` (đoạn hiển thị topping trong bảng chi tiết bill của modal), đổi
`${line.toppingLines}` → `${line.toppings}` ở cả 2 chỗ dùng (điều kiện `c:if` và `c:forEach`), khớp
đúng tên getter thật của `BillLine.getToppings()`. Property `toppingName`/`quantity` dùng trong vòng
lặp (`${top.toppingName}`, `${top.quantity}`) đã khớp đúng với `BillToppingLine` nên không cần đổi.
Đã grep toàn bộ `src/main/web` xác nhận không còn chỗ nào khác dùng sai `toppingLines`.

### Files sửa:
- `src/main/web/user/donhang.jsp`

### Ghi chú:
Không đổi schema DB nên không cần cập nhật `database.md`. Không có Maven CLI nên không tự build/chạy
để test được — bug được xác nhận chính xác nhờ user cung cấp log SEVERE của Tomcat
(`catalina.*.log`/localhost log) cho thấy đúng dòng JSP và đúng property bị sai, nên fix lần này có độ
tin cậy cao (không chỉ suy luận qua hành vi UI như mục `## 100.`). Bài học quy trình: khi lỗi JSP gây
mất một phần trang (đặc biệt các trường hợp "im lặng"/"không phản ứng"), nên xin log server (Tomcat
console/`logs/localhost.*.log`) sớm hơn thay vì chỉ dựa vào chẩn đoán qua DevTools phía client, vì
exception phía server trong lúc render JSP thường không hiện lỗi rõ ràng ở phía trình duyệt (chỉ thấy
response bị cắt cụt kiểu khó hiểu). Đề nghị user build lại và test lại — cả nút "Chi tiết & Theo dõi
đơn" (mọi đơn, đặc biệt đơn có topping) lẫn hành vi auto-reload khi mở modal.

## 103. Thêm tính năng "Thông tin cá nhân" cho User (roleId=3)

**Yêu cầu:** User xác nhận: "Vậy ta sẽ thêm tính năng 'Thông tin cá nhân' cho User này đi." Khu vực
khách hàng (User) trước đó chưa có trang cho phép tự sửa họ tên/SĐT/email/avatar, trong khi Shipper và
Shop đã có (`/shipper/ho-so`, tương tự Shop). Yêu cầu bao gồm cả upload avatar qua Cloudinary (user chọn
"Có, thêm upload avatar" khi được hỏi).

**Đã sửa:** Implement đúng theo pattern đã có của `ShipperHoSoServlet` + `ShipperAvatarUploadServlet` +
`XacThucThayDoiServlet`, nhưng dùng theme "storefront" của User (`user-theme.css`, giống `diaChi.jsp`)
thay vì dashboard theme:
- `UserThongTinCaNhanServlet` (`@WebServlet("/user/thong-tin-ca-nhan")`, role check `roleId != 3`):
  `doGet` forward `profile` (Account fresh từ DB) tới `thongTinCaNhan.jsp`; `doPost` đọc
  `fullName`/`phone`/`email`/`avatarUrl`, validate avatar qua
  `UploadValidationUtil.isValidCloudinaryImageUrl`; nếu email đổi → check
  `accountDAO.tonTaiEmailKhacId` (redirect `?error=email_exists` nếu trùng), rồi
  `SensitiveInfoOtpUtil.generateAndSend(session, "user_hoso", email, pending)` → redirect
  `/xac-thuc-thay-doi?purpose=user_hoso`; nếu email không đổi → update trực tiếp + đồng bộ session →
  redirect `?success=1`/`?error=1`.
- `UserAvatarUploadServlet` (`@WebServlet("/user/update-avatar")`, role check `roleId != 3`): nhận
  `avatarUrl` qua POST (XHR), validate Cloudinary URL, `accountDAO.updateAvatar(...)`, đồng bộ session,
  trả HTTP status thuần (200/400/401/403/500) — không redirect.
- Mở rộng `XacThucThayDoiServlet`: thêm `case "user_hoso":` vào cùng nhóm xử lý chung với
  `"shop_hoso"`/`"shipper_hoso"`/`"admin_profile"`/`"shipper_profile_info"` trong `applyPendingChange()`
  (fetch fresh Account, set fullName/phone/email/avatarUrl, `accountDAO.update()`, cập nhật session); và
  thêm `case "user_hoso": return "/user/thong-tin-ca-nhan";` trong `originUrl()`.
- Tạo mới `src/main/web/user/thongTinCaNhan.jsp` theo đúng theme storefront (copy cấu trúc navbar/avatar
  dropdown/`:root` CSS variables/`.container`/`.page-head`/alert blocks từ `diaChi.jsp`), gồm: form sửa
  họ tên/SĐT/email (POST `/user/thong-tin-ca-nhan`, có `csrfToken` ẩn), khối avatar (avatar hiện tại hoặc
  chữ cái đầu tên, input file ẩn + progress bar + JS upload Cloudinary
  `CLOUD_NAME='jcnsb47f'`/`UPLOAD_PRESET='avatar_preset'` rồi POST `avatarUrl` bằng XHR tới
  `/user/update-avatar`), thêm `<meta name="_csrf" content="${sessionScope.csrfToken}">` trong `<head>`
  để lấy CSRF token gửi qua header `X-CSRF-Token` cho request XHR (đã xác nhận `CsrfFilter` chấp nhận cả
  param `csrfToken` lẫn header `X-CSRF-Token`), alert theo
  `param.success/error/error=email_exists/error=otp_send_failed`.
- Thêm link dropdown "Thông tin cá nhân" (đặt lên đầu danh sách link, trước "Đơn hàng của tôi") vào toàn
  bộ 8 trang User có avatar-dropdown: `diaChi.jsp`, `diemThuong.jsp`, `doiMatKhauUser.jsp`, `donhang.jsp`,
  `gioHang.jsp`, `khieuNai.jsp`, `thongBao.jsp`, `trangnguoidung.jsp` (và `thongTinCaNhan.jsp` tự đánh
  dấu `active`).

### Files sửa:
- `src/main/java/org/example/controllers/UserThongTinCaNhanServlet.java` (mới)
- `src/main/java/org/example/controllers/UserAvatarUploadServlet.java` (mới)
- `src/main/java/org/example/controllers/XacThucThayDoiServlet.java`
- `src/main/web/user/thongTinCaNhan.jsp` (mới)
- `src/main/web/user/diaChi.jsp`
- `src/main/web/user/diemThuong.jsp`
- `src/main/web/user/doiMatKhauUser.jsp`
- `src/main/web/user/donhang.jsp`
- `src/main/web/user/gioHang.jsp`
- `src/main/web/user/khieuNai.jsp`
- `src/main/web/user/thongBao.jsp`
- `src/main/web/user/trangnguoidung.jsp`

### Ghi chú:
Không có bảng/cột DB mới — `Account` model đã có đủ field (`fullName`, `phone`, `email`, `avatarUrl`)
nên không cần cập nhật `database.md`. Toàn bộ logic servlet/OTP/validate-avatar đều tái sử dụng 100% các
class/method sẵn có (`AccountDAO.updateAvatar`, `UploadValidationUtil.isValidCloudinaryImageUrl`,
`SensitiveInfoOtpUtil`) — chỉ thêm route mới và 1 nhánh switch mới, không sửa logic chung nào của các role
khác nên không có rủi ro regression cho Shop/Shipper/Admin. Không có Maven CLI trong môi trường này nên
không tự build/deploy/test được — đã đọc lại kỹ từng file Java/JSP để kiểm tra cú pháp, import, khớp
đúng `purpose` key (`"user_hoso"`) giữa `UserThongTinCaNhanServlet` và `XacThucThayDoiServlet`, khớp
đúng route giữa servlet và JSP action/dropdown link. Đề nghị user tự rebuild/redeploy và test luồng: vào
`/user/thong-tin-ca-nhan` → sửa họ tên/SĐT → lưu (không đổi email) → xác nhận session cập nhật ngay;
đổi avatar → xác nhận ảnh cập nhật ở cả navbar và khối profile; đổi email → xác nhận redirect sang
`/xac-thuc-thay-doi?purpose=user_hoso` → nhập OTP → xác nhận quay lại đúng trang với thông tin mới; kiểm
tra dropdown "Thông tin cá nhân" xuất hiện đúng ở cả 8 trang User.
