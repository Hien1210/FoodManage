<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="currentShop" value="${sessionScope.currentShop}" scope="request"/>

<%-- BẢO MẬT: KIỂM TRA QUYỀN SHOP (roleId = 2) --%>
<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 2}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hóa đơn #${bill.order.id} - ${not empty currentShop.shopName ? currentShop.shopName : 'Cửa hàng'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        .avatar-wrapper { position: relative; }
        .avatar-dropdown { display: none; position: fixed; background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: var(--dash-shadow-md); min-width: 220px; z-index: 500; }
        .avatar-dropdown.open { display: block; animation: pobFadeUp .18s ease both; }
        .dropdown-header { padding: 14px 16px; border-bottom: 1px solid var(--border-color); }
        .dropdown-header .d-name { font-size: 14px; font-weight: 700; color: var(--text-main); }
        .dropdown-header .d-email { font-size: 12px; color: var(--text-muted); margin-top: 2px; }
        .dropdown-header .d-role { display: inline-block; margin-top: 6px; font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 4px; background: var(--primary-light); color: var(--primary); border: 1px solid var(--primary); }
        .dropdown-body { padding: 6px 0 8px; }
        .dropdown-link { display: flex; align-items: center; gap: 10px; padding: 10px 16px; font-size: 13px; color: var(--text-muted); cursor: pointer; }
        .dropdown-link:hover { background: var(--bg-input); color: var(--text-main); }
        .dropdown-divider { height: 1px; background: var(--border-color); margin: 4px 0; }
        .dropdown-link.danger { color: var(--danger); }
        .dropdown-link.danger:hover { background: var(--danger-light); color: var(--danger); }

        /* Hóa đơn chi tiết / in ấn */
        .bill-center { display: flex; justify-content: center; }
        .bill-wrap { max-width: 680px; width: 100%; }
        .bill { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: var(--radius-lg); box-shadow: var(--dash-shadow-sm); padding: 28px 32px; }
        .bill-header { text-align: center; margin-bottom: 18px; border-bottom: 2px dashed var(--border-color); padding-bottom: 14px; }
        .bill-header h2 { color: var(--primary-dark); font-size: 20px; font-weight: 800; }
        .bill-header .order-id { color: var(--text-dim); font-size: 13px; margin-top: 4px; }

        .bill .info-row { display: flex; justify-content: space-between; font-size: 14px; margin-bottom: 6px; }
        .bill .info-row span:first-child { color: var(--text-dim); }
        .bill .info-row span:last-child { color: var(--text-main); font-weight: 600; }

        .bill table { width: 100%; border-collapse: collapse; margin: 16px 0; }
        .bill th, .bill td { padding: 10px 8px; text-align: left; font-size: 13.5px; border-bottom: 1px solid var(--border-color); color: var(--text-main); }
        .bill th { color: var(--text-dim); text-transform: uppercase; font-size: 11px; font-weight: 700; }
        .bill th.num, .bill td.num { text-align: right; }

        .bill-totals { text-align: right; font-size: 14px; }
        .bill-totals .line { margin-bottom: 6px; color: var(--text-muted); }
        .bill-totals .grand { font-size: 18px; font-weight: 800; color: var(--primary-dark); margin-top: 6px; }

        .bill-actions { text-align: center; margin-top: 18px; display: flex; gap: 10px; justify-content: center; }

        /* Hóa đơn giấy in nhiệt 58mm - chỉ hiện khi in */
        .receipt-print { display: none; }
        .receipt-print { width: 58mm; margin: 0 auto; font-family: 'Courier New', Consolas, monospace; font-size: 11px; line-height: 1.45; color: #000; }
        .receipt-print .r-center { text-align: center; }
        .receipt-print .r-shop-name { font-size: 13px; font-weight: 700; text-transform: uppercase; }
        .receipt-print .r-dash { border-top: 1px dashed #000; margin: 4px 0; }
        .receipt-print .r-title { font-size: 13px; font-weight: 700; text-align: center; margin: 4px 0; letter-spacing: 1px; }
        .receipt-print .r-row { display: flex; justify-content: space-between; gap: 6px; }
        .receipt-print .r-row.bold { font-weight: 700; }
        .receipt-print table { width: 100%; border-collapse: collapse; margin: 4px 0; }
        .receipt-print th, .receipt-print td { padding: 1px 2px; text-align: left; font-size: 10.5px; vertical-align: top; }
        .receipt-print th.num, .receipt-print td.num { text-align: right; }
        .receipt-print .r-topping { font-size: 9.5px; color: #333; padding-left: 8px; }
        .receipt-print .r-total { font-size: 13px; font-weight: 800; text-align: center; margin: 4px 0; }
        .receipt-print .r-words { font-style: italic; font-size: 10px; text-align: center; margin: 2px 0 6px; }
        .receipt-print .r-thanks { text-align: center; font-weight: 700; margin-top: 6px; }

        @media print {
            .sidebar, .topbar, .bill-actions, .sidebar-backdrop, .bill-wrap { display: none; }
            .content { padding: 0; }
            .receipt-print { display: block; }
            @page { size: 58mm auto; margin: 2mm; }
        }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="/shop/bills" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">receipt_long</span> Hóa đơn #${bill.order.id}</h1>
        </div>
        <div class="topbar-right">
            <div class="avatar-wrapper" id="avatarWrapper">
                <div class="avatar-circle" id="avatarBtn">
                    <c:choose>
                        <c:when test="${not empty sessionScope.account.avatarUrl}">
                            <img src="${sessionScope.account.avatarUrl}" alt="avatar"/>
                        </c:when>
                        <c:otherwise>${fn:toUpperCase(fn:substring(sessionScope.account.userName, 0, 2))}</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </header>

    <div class="content">
        <div class="bill-center">
            <div class="bill-wrap">
                <div class="bill">
                    <div class="bill-header">
                        <h2>🧾 HÓA ĐƠN BÁN HÀNG</h2>
                        <div class="order-id">Mã đơn hàng: #${bill.order.id} — <c:out value="${bill.shopName}"/></div>
                    </div>

                    <div class="info-row"><span>Người nhận</span><span><c:out value="${bill.order.receiverName}"/></span></div>
                    <div class="info-row"><span>Số điện thoại</span><span><c:out value="${bill.order.receiverPhone}"/></span></div>
                    <div class="info-row"><span>Địa chỉ giao hàng</span><span><c:out value="${bill.order.shippingAddress}"/></span></div>
                    <div class="info-row"><span>Phương thức thanh toán</span><span>
                        <c:set var="pm" value="${fn:toUpperCase(bill.order.paymentMethod)}"/>
                        <c:choose>
                            <c:when test="${pm == 'BANK'}"><span class="badge badge-info">📱 QR chuyển khoản</span></c:when>
                            <c:when test="${pm == 'PAYOS'}"><span class="badge badge-info">🏦 PayOS</span></c:when>
                            <c:otherwise><span class="badge badge-neutral">💵 Tiền mặt</span></c:otherwise>
                        </c:choose>
                    </span></div>
                    <div class="info-row"><span>Thanh toán</span><span>
                        <c:set var="pst" value="${fn:toUpperCase(bill.order.paymentStatus)}"/>
                        <c:choose>
                            <c:when test="${pst == 'PAID'}"><span class="badge badge-success">✅ Đã thanh toán</span></c:when>
                            <c:when test="${pst == 'PENDING'}"><span class="badge badge-warning">⏳ Đang chờ</span></c:when>
                            <c:otherwise><span class="badge badge-danger">⛔ Chưa thanh toán</span></c:otherwise>
                        </c:choose>
                    </span></div>
                    <div class="info-row"><span>Trạng thái</span><span>
                        <c:set var="st2" value="${fn:toUpperCase(bill.order.staTus)}"/>
                        <c:set var="pst3" value="${fn:toUpperCase(bill.order.paymentStatus)}"/>
                        <c:choose>
                            <c:when test="${st2 == 'CANCELLED'}">
                                <span class="badge badge-danger">🚫 Đã hủy</span>
                            </c:when>
                            <c:when test="${pst3 == 'UNPAID'}">
                                <span class="badge badge-danger">❌ Thất bại</span>
                            </c:when>
                            <c:when test="${pst3 == 'PENDING'}">
                                <span class="badge badge-warning">⏳ Chờ đợi</span>
                            </c:when>
                            <c:when test="${st2 == 'DONE'}">
                                <span class="badge badge-success">✅ Hoàn thành</span>
                            </c:when>
                            <c:when test="${st2 == 'SHIPPING'}">
                                <span class="badge badge-warning">🚚 Đang giao</span>
                            </c:when>
                            <c:when test="${st2 == 'PENDING'}">
                                <span class="badge badge-warning">⏳ Đang xử lý</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-neutral"><c:out value="${bill.order.staTus}"/></span>
                            </c:otherwise>
                        </c:choose>
                    </span></div>
                    <div class="info-row"><span>Thời gian tạo</span><span>${bill.order.createdAt}</span></div>

                    <table>
                        <thead>
                            <tr>
                                <th>Sản phẩm</th>
                                <th>Size</th>
                                <th class="num">SL</th>
                                <th class="num">Đơn giá</th>
                                <th class="num">Thành tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${bill.lines}" var="line">
                                <tr>
                                    <td>
                                        <c:out value="${line.productName}"/>
                                        <c:if test="${not empty line.toppings}">
                                            <div style="font-size:11px;color:var(--text-dim);margin-top:3px;">
                                                <c:forEach items="${line.toppings}" var="top">
                                                    + <c:out value="${top.toppingName}"/> x${top.quantity}<br>
                                                </c:forEach>
                                            </div>
                                        </c:if>
                                    </td>
                                    <td><c:out value="${line.sizeName}"/></td>
                                    <td class="num">${line.quantity}</td>
                                    <td class="num"><fmt:formatNumber value="${line.price}" type="number" maxFractionDigits="0"/> đ</td>
                                    <td class="num"><fmt:formatNumber value="${line.lineTotal}" type="number" maxFractionDigits="0"/> đ</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <div class="bill-totals">
                        <div class="line">Tạm tính: <fmt:formatNumber value="${bill.subtotal}" type="number" maxFractionDigits="0"/> đ</div>
                        <div class="line">Phí giao hàng: <fmt:formatNumber value="${bill.order.deliveryFee}" type="number" maxFractionDigits="0"/> đ</div>
                        <div class="grand">Tổng thanh toán: <fmt:formatNumber value="${bill.order.totalPrice}" type="number" maxFractionDigits="0"/> đ</div>
                    </div>
                </div>

                <div class="bill-actions">
                    <a href="#" class="btn btn-primary" onclick="window.print(); return false;">🖨️ In hóa đơn</a>
                    <a href="${pageContext.request.contextPath}/shop/bills" class="btn btn-ghost">← Quay lại danh sách</a>
                </div>
            </div>

            <%-- Mẫu hóa đơn giấy in nhiệt 58mm - chỉ hiển thị khi in (xem CSS @media print) --%>
            <div class="receipt-print" id="receiptPrint">
                <div class="r-center r-shop-name"><c:out value="${not empty currentShop.shopName ? currentShop.shopName : bill.shopName}"/></div>
                <c:if test="${not empty currentShop.shopAddress}">
                    <div class="r-center"><c:out value="${currentShop.shopAddress}"/></div>
                </c:if>
                <c:if test="${not empty currentShop.shopPhone}">
                    <div class="r-center">ĐT: <c:out value="${currentShop.shopPhone}"/></div>
                </c:if>
                <div class="r-dash"></div>
                <div class="r-title">HÓA ĐƠN THANH TOÁN</div>
                <div class="r-row"><span>Số HĐ:</span><span>#${bill.order.id}</span></div>
                <div class="r-row"><span>Ngày in:</span><span id="rPrintTime"></span></div>
                <div class="r-row"><span>Người nhận:</span><span><c:out value="${bill.order.receiverName}"/></span></div>
                <div class="r-row"><span>SĐT:</span><span><c:out value="${bill.order.receiverPhone}"/></span></div>
                <div class="r-row"><span>Thu ngân:</span><span><c:out value="${sessionScope.account.userName}"/></span></div>
                <div class="r-dash"></div>
                <table>
                    <thead>
                    <tr><th>Tên hàng</th><th class="num">SL</th><th class="num">Đ.Giá</th><th class="num">T.Tiền</th></tr>
                    </thead>
                    <tbody>
                    <c:set var="rTongSL" value="0"/>
                    <c:forEach items="${bill.lines}" var="line" varStatus="rSt">
                        <c:set var="rTongSL" value="${rTongSL + line.quantity}"/>
                        <tr>
                            <td>${rSt.index + 1}) <c:out value="${line.productName}"/><c:if test="${not empty line.sizeName}"> (<c:out value="${line.sizeName}"/>)</c:if></td>
                            <td class="num">${line.quantity}</td>
                            <td class="num"><fmt:formatNumber value="${line.price}" type="number" maxFractionDigits="0"/></td>
                            <td class="num"><fmt:formatNumber value="${line.lineTotal}" type="number" maxFractionDigits="0"/></td>
                        </tr>
                        <c:if test="${not empty line.toppings}">
                            <c:forEach items="${line.toppings}" var="top">
                                <tr>
                                    <td class="r-topping" colspan="4">+ <c:out value="${top.toppingName}"/> x${top.quantity}</td>
                                </tr>
                            </c:forEach>
                        </c:if>
                    </c:forEach>
                    </tbody>
                </table>
                <div class="r-dash"></div>
                <div class="r-row bold"><span>T.Cộng (${rTongSL} món)</span><span><fmt:formatNumber value="${bill.subtotal}" type="number" maxFractionDigits="0"/></span></div>
                <div class="r-row"><span>Phí giao hàng</span><span><fmt:formatNumber value="${bill.order.deliveryFee}" type="number" maxFractionDigits="0"/></span></div>
                <div class="r-dash"></div>
                <div class="r-total">TỔNG CỘNG: <fmt:formatNumber value="${bill.order.totalPrice}" type="number" maxFractionDigits="0"/> đ</div>
                <div class="r-words" id="rAmountWords"></div>
                <c:set var="rpm" value="${fn:toUpperCase(bill.order.paymentMethod)}"/>
                <div class="r-center">Thanh toán:
                    <c:choose>
                        <c:when test="${rpm == 'BANK'}">Chuyển khoản QR</c:when>
                        <c:when test="${rpm == 'PAYOS'}">PayOS</c:when>
                        <c:otherwise>Tiền mặt</c:otherwise>
                    </c:choose>
                </div>
                <div class="r-dash"></div>
                <div class="r-thanks">Cảm ơn Quý khách!<br>Hẹn gặp lại</div>
            </div>
        </div>
    </div>
</main>

<span id="rTotalAmountRaw" style="display:none;">${bill.order.totalPrice}</span>

<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${sessionScope.account.userName}</div>
        <div class="d-email">${sessionScope.account.email}</div>
        <span class="d-role">🏪 Shop Owner</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/shop/ho-so" class="dropdown-link">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/shop/doi-mat-khau" class="dropdown-link">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        var avatarBtn = document.getElementById('avatarBtn');
        var avatarDropdown = document.getElementById('avatarDropdown');
        if (avatarBtn && avatarDropdown) {
            avatarBtn.addEventListener('click', function(e) {
                e.stopPropagation();
                var rect = avatarBtn.getBoundingClientRect();
                avatarDropdown.style.top = (rect.bottom + 10) + 'px';
                avatarDropdown.style.right = (window.innerWidth - rect.right) + 'px';
                avatarDropdown.classList.toggle('open');
            });
            avatarDropdown.addEventListener('click', function(e) { e.stopPropagation(); });
            document.addEventListener('click', function() { avatarDropdown.classList.remove('open'); });
        }
    });

    // Đọc số tiền thành chữ tiếng Việt (dùng cho hóa đơn giấy in nhiệt 58mm)
    function soTienBangChuTiengViet(soTien) {
        var n = Math.round(Number(soTien) || 0);
        if (n <= 0) return "Không đồng./";

        var chuSo = ["không", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"];
        var donViNhom = ["", "nghìn", "triệu", "tỷ"];

        function docBaChuSo(so) {
            var tram = Math.floor(so / 100);
            var chuc = Math.floor((so % 100) / 10);
            var dv = so % 10;
            var out = [];
            if (tram > 0) {
                out.push(chuSo[tram] + " trăm");
                if (chuc === 0 && dv > 0) out.push("linh");
            }
            if (chuc >= 2) {
                out.push(chuSo[chuc] + " mươi");
                if (dv === 1) out.push("mốt");
                else if (dv === 5) out.push("lăm");
                else if (dv > 0) out.push(chuSo[dv]);
            } else if (chuc === 1) {
                out.push("mười");
                if (dv === 1) out.push("mốt");
                else if (dv === 5) out.push("lăm");
                else if (dv > 0) out.push(chuSo[dv]);
            } else if (chuc === 0 && dv > 0) {
                out.push(chuSo[dv]);
            }
            return out.join(" ");
        }

        var nhom = [];
        var t = n;
        while (t > 0) {
            nhom.push(t % 1000);
            t = Math.floor(t / 1000);
        }

        var phan = [];
        for (var i = nhom.length - 1; i >= 0; i--) {
            var g = nhom[i];
            if (g === 0) continue;
            var text = docBaChuSo(g);
            if (i > 0) text += " " + donViNhom[i];
            phan.push(text);
        }

        var ketQua = phan.join(" ");
        ketQua = ketQua.charAt(0).toUpperCase() + ketQua.slice(1);
        return ketQua + " đồng./";
    }

    (function () {
        var rPrintTime = document.getElementById('rPrintTime');
        if (rPrintTime) {
            var now = new Date();
            var pad = function (x) { return x < 10 ? '0' + x : '' + x; };
            rPrintTime.textContent = pad(now.getDate()) + '/' + pad(now.getMonth() + 1) + '/' + now.getFullYear()
                + ' ' + pad(now.getHours()) + ':' + pad(now.getMinutes());
        }

        var rWords = document.getElementById('rAmountWords');
        var rRaw = document.getElementById('rTotalAmountRaw');
        if (rWords && rRaw) {
            rWords.textContent = soTienBangChuTiengViet(rRaw.textContent);
        }
    })();
</script>
</body>
</html>
