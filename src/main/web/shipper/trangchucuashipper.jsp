<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Tài xế công nghệ - POB Shipper</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
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

        .online-toggle-btn { width: 100%; padding: 12px 16px; border-radius: var(--radius-sm); border: none; cursor: pointer; display: flex; align-items: center; gap: 10px; font-size: 13px; font-weight: 700; }
        .online-toggle-btn.is-online { background: var(--success-light); color: var(--success-dark); border: 1.5px solid var(--success); }
        .online-toggle-btn.is-offline { background: var(--danger-light); color: var(--danger); border: 1.5px solid var(--danger); }
        .toggle-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
        .toggle-dot.online { background: var(--success); animation: pobBlink 1.5s infinite; }
        .toggle-dot.offline { background: var(--danger); }

        .online-badge { display: inline-flex; align-items: center; gap: 6px; padding: 4px 12px; border-radius: var(--radius-pill); font-size: 12px; font-weight: 700; margin-left: 10px; }
        .online-badge.online { background: var(--success-light); color: var(--success-dark); }
        .online-badge.offline { background: var(--danger-light); color: var(--danger); }

        /* Tabs lọc trạng thái */
        .tabs-header { display: flex; gap: 8px; flex-wrap: wrap; }
        .tab-btn { padding: 9px 18px; border: 1.5px solid var(--border-color); background: var(--bg-panel); color: var(--text-muted); font-weight: 700; font-size: 13px; cursor: pointer; border-radius: var(--radius-pill); }
        .tab-btn.active { color: #fff; background: var(--primary); border-color: var(--primary); }

        /* Order cards */
        .order-list { display: flex; flex-direction: column; gap: 14px; }
        .order-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 20px; box-shadow: var(--dash-shadow-sm); position: relative; overflow: hidden; }
        .order-card::before { content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%; background: var(--warning); }
        .order-card.status-shipping::before { background: var(--primary); }
        .order-card.status-done::before { background: var(--success); }
        .order-card.status-done { opacity: .8; }
        .order-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .order-id { font-weight: 700; font-size: 15px; color: var(--text-main); }
        .order-time { font-size: 12px; color: var(--text-dim); }

        .route-timeline { position: relative; padding-left: 24px; margin-bottom: 16px; }
        .route-step { position: relative; margin-bottom: 12px; font-size: 13px; }
        .route-step:last-child { margin-bottom: 0; }
        .route-step::before { content: '•'; position: absolute; left: -18px; top: -2px; font-size: 18px; color: var(--warning); }
        .route-step.dropoff::before { color: var(--primary); }
        .route-label { font-size: 11px; color: var(--text-dim); font-weight: 700; text-transform: uppercase; }
        .route-text { font-weight: 700; margin-top: 2px; color: var(--text-main); }

        .price-tag { font-size: 16px; font-weight: 800; color: var(--primary); display: flex; align-items: center; gap: 4px; justify-content: flex-end; }
        .badge-payos { background: rgba(139,92,246,.14); color: #8b5cf6; }

        .btn-flex-group { display: flex; gap: 8px; justify-content: flex-end; align-items: center; margin-top: 12px; }

        /* Modal chi tiết (dùng chung pob-modal-*) */
        .pob-modal-box .modal-header { padding: 18px 22px; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; }
        .pob-modal-box .modal-body { padding: 22px; display: flex; flex-direction: column; gap: 16px; }
        .modal-close { background: transparent; border: none; color: var(--text-dim); font-size: 20px; cursor: pointer; }
    </style>
</head>
<body class="dash-body">

<div class="sidebar-backdrop" id="sidebarBackdrop"></div>
<aside class="sidebar" id="sidebar">
    <div class="sidebar-brand">
        <div class="logo-mark-dash">🛵</div>
        <div class="brand-text">
            <span class="brand-title">POB SHIPPER</span>
            <c:choose>
                <c:when test="${sessionScope.account.online}">
                    <span class="brand-subtitle" style="color:var(--success);">● Đang hoạt động</span>
                </c:when>
                <c:otherwise>
                    <span class="brand-subtitle" style="color:var(--danger);">● Ngoại tuyến</span>
                </c:otherwise>
            </c:choose>
        </div>
        <button type="button" class="sidebar-toggle-btn" id="sidebarToggleBtn" onclick="pobToggleSidebar()" title="Thu gọn / mở rộng menu">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
        </button>
    </div>
    <div class="menu">
        <div class="menu-title">Công việc</div>
        <a href="${pageContext.request.contextPath}/shipper/donhang" class="menu-item active">
            <span class="mi-left"><span class="mi-icon">📋</span><span class="mi-label"> Đơn hàng nhận</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/nhan-don" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📥</span><span class="mi-label"> Nhận đơn mới</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/dashboard" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📊</span><span class="mi-label"> Dashboard</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/thongbao" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🔔</span><span class="mi-label"> Thông báo</span></span>
        </a>

        <div class="menu-title">Tài khoản</div>
        <a href="${pageContext.request.contextPath}/shipper/profile" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🚙</span><span class="mi-label"> Hồ sơ tài xế</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/danh-gia" class="menu-item">
            <span class="mi-left"><span class="mi-icon">⭐</span><span class="mi-label"> Đánh giá &amp; Báo cáo</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/vi-tien" class="menu-item">
            <span class="mi-left"><span class="mi-icon">💰</span><span class="mi-label"> Ví tiền</span></span>
        </a>
    </div>
    <div class="sidebar-foot">
        <form action="${pageContext.request.contextPath}/shipper/status" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <c:choose>
                <c:when test="${sessionScope.account.online}">
                    <button type="submit" class="online-toggle-btn is-online"
                            onclick="return confirm('Tắt chế độ Online? Bạn sẽ không nhận đơn mới.')">
                        <span class="toggle-dot online"></span><span class="sf-label">Đang Online — Nhấn để Offline
                    </span></button>
                </c:when>
                <c:otherwise>
                    <button type="submit" class="online-toggle-btn is-offline">
                        <span class="toggle-dot offline"></span><span class="sf-label">Đang Offline — Nhấn để Online
                    </span></button>
                </c:otherwise>
            </c:choose>
        </form>
    </div>
</aside>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1>
                Hệ thống điều phối giao hàng
                <c:choose>
                    <c:when test="${sessionScope.account.online}"><span class="online-badge online">● Online</span></c:when>
                    <c:otherwise><span class="online-badge offline">● Offline</span></c:otherwise>
                </c:choose>
            </h1>
        </div>
        <div class="topbar-right">
            <button type="button" class="theme-toggle" id="themeToggleBtn" onclick="pobToggleTheme()" title="Chuyển đổi giao diện"><span data-theme-icon>🌙</span></button>
            <div class="avatar-wrapper" id="avatarWrapper">
                <div class="avatar-circle" id="avatarBtn">
                    <c:choose>
                        <c:when test="${not empty sessionScope.account.avatarUrl}">
                            <img src="${fn:escapeXml(sessionScope.account.avatarUrl)}" alt="avatar"/>
                        </c:when>
                        <c:otherwise>${fn:escapeXml(fn:toUpperCase(fn:substring(sessionScope.account.userName, 0, 2)))}</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </header>

    <div class="content">
        <div class="stats-grid">
            <div class="stat-card">
                <div><div class="stat-label">Hoàn thành hôm nay</div><div class="stat-num">${donHoanThanhHomNay} đơn</div></div>
                <div class="stat-icon" style="background:var(--success-light);color:var(--success-dark);">✓</div>
            </div>
            <div class="stat-card">
                <div><div class="stat-label">Thu nhập hôm nay</div><div class="stat-num" style="color:var(--primary);"><fmt:formatNumber value="${thuNhapHomNay}" type="number" maxFractionDigits="0"/>đ</div></div>
                <div class="stat-icon">💵</div>
            </div>
            <div class="stat-card">
                <div><div class="stat-label">Chờ lấy hàng</div><div class="stat-num" style="color:var(--warning-dark);">${donChoLayHang} đơn</div></div>
                <div class="stat-icon" style="background:var(--warning-light);color:var(--warning-dark);">📦</div>
            </div>
            <div class="stat-card">
                <div><div class="stat-label">Đang giao</div><div class="stat-num" style="color:var(--primary);">${donDangGiao} đơn</div></div>
                <div class="stat-icon">🛵</div>
            </div>
        </div>

        <c:if test="${param.success == 'accepted'}">
            <div id="acceptToast" style="background:var(--success-light);color:var(--success-dark);border:1.5px solid var(--success);border-radius:var(--radius-md);padding:14px 20px;margin-bottom:16px;display:flex;align-items:center;gap:12px;font-weight:700;">
                <span style="font-size:20px;">✅</span>
                <span>Nhận đơn thành công! Đơn hàng đang chờ cửa hàng xác nhận — bạn có thể thấy đơn ở tab <strong>Chờ lấy hàng</strong> bên dưới.</span>
            </div>
        </c:if>

        <div class="panel">
            <div class="panel-header" style="flex-direction:column;align-items:stretch;gap:14px;">
                <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px;">
                    <div class="tabs-header">
                        <button class="tab-btn active" id="tabAll" onclick="filterOrders('ALL', this)">Tất cả đơn</button>
                        <button class="tab-btn" id="tabWaiting" onclick="filterOrders('WAITING', this)">Chờ lấy hàng 🟠</button>
                        <button class="tab-btn" onclick="filterOrders('SHIPPING', this)">Đang giao 🟢</button>
                        <button class="tab-btn" onclick="filterOrders('HISTORY', this)">Lịch sử 📜</button>
                    </div>
                    <div style="display:flex; align-items:center; gap:8px;">
                        <span style="font-size:12px; font-weight:700; color:var(--text-dim);">Hình thức TT:</span>
                        <select id="paymentFilter" class="dash-input" style="width:auto;padding:7px 12px;" onchange="applyFilters()">
                            <option value="ALL">Tất cả</option>
                            <option value="COD">💵 Tiền mặt (COD)</option>
                            <option value="BANK">📱 QR Chuyển khoản</option>
                            <option value="PAYOS">🏦 PayOS</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="panel-body">
                <div class="order-list">
                    <c:forEach var="order" items="${danhSachDonHang}">
                        <div class="order-card ${order.status == 'SHIPPING' ? 'status-shipping' : ''} ${order.status == 'DONE' ? 'status-done' : ''}"
                             data-status="${order.status}"
                             data-payment="${empty order.paymentMethod ? 'COD' : order.paymentMethod}">
                            <div class="order-header">
                                <span class="order-id">Mã đơn: #<c:out value="${order.id}"/></span>
                                <c:set var="ca" value="${order.createdAt}"/>
                                <span class="order-time">🕒 ${fn:substring(ca,11,16)} ${fn:substring(ca,8,10)}/${fn:substring(ca,5,7)}/${fn:substring(ca,0,4)}</span>
                            </div>

                            <div class="route-timeline">
                                <div class="route-step pickup">
                                    <div class="route-label">Lấy hàng tại (Shop):</div>
                                    <div class="route-text"><c:out value="${order.shopName}"/> - <c:out value="${order.shopAddress}"/></div>
                                    <div style="font-size:11px; color: var(--text-dim);">📞 Cửa hàng: <c:out value="${order.shopPhone}"/></div>
                                </div>
                                <div class="route-step dropoff">
                                    <div class="route-label">Giao hàng tới (Khách):</div>
                                    <div class="route-text"><c:out value="${order.shippingAddress}"/></div>
                                    <div style="font-size:11px; color: var(--text-dim);">👤 Người nhận: <c:out value="${order.receiverName}"/> - <c:out value="${order.receiverPhone}"/></div>
                                </div>
                            </div>

                            <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed var(--border-color); padding-top: 12px;">
                                <div>
                                    <div style="font-size: 11px; color: var(--text-dim); font-weight:700;">HÌNH THỨC THANH TOÁN</div>
                                    <div style="font-size: 13px; font-weight:700; color: var(--text-main);">
                                        <c:choose>
                                            <c:when test="${order.paymentMethod == 'PAYOS'}">🏦 PayOS</c:when>
                                            <c:when test="${order.paymentMethod == 'BANK'}">📱 QR Chuyển khoản</c:when>
                                            <c:otherwise>💵 Tiền mặt (COD)</c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <div style="text-align: right;">
                                    <span class="badge ${order.status == 'SHIPPING' ? 'badge-primary' : order.status == 'DONE' ? 'badge-success' : order.status == 'CANCELLED' ? 'badge-danger' : 'badge-warning'}">
                                        <c:choose>
                                            <c:when test="${order.status == 'PENDING'}">⏳ Chờ shop xác nhận</c:when>
                                            <c:when test="${order.status == 'CONFIRMED'}">👨‍🍳 Shop đang chuẩn bị món</c:when>
                                            <c:when test="${order.status == 'READY_FOR_PICKUP'}">📦 Quán đã nấu xong — Đến lấy hàng</c:when>
                                            <c:when test="${order.status == 'SHIPPING'}">🛵 Đang giao hàng</c:when>
                                            <c:when test="${order.status == 'DONE'}">✅ Đã giao xong</c:when>
                                            <c:when test="${order.status == 'CANCELLED'}">🚫 Đã huỷ (bom hàng)</c:when>
                                            <c:otherwise><c:out value="${order.status}"/></c:otherwise>
                                        </c:choose>
                                    </span>
                                    <div class="price-tag" style="margin-top: 4px;"><fmt:formatNumber value="${order.totalPrice}" type="number" maxFractionDigits="0"/>đ</div>
                                </div>
                            </div>

                            <div class="btn-flex-group">
                                <a href="${pageContext.request.contextPath}/shipper/donhang?action=detail&id=${order.id}">
                                    <button type="button" class="btn btn-outline btn-sm">Xem chi tiết</button>
                                </a>

                                <form action="${pageContext.request.contextPath}/shipper/donhang" method="post" style="display:inline;">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                    <input type="hidden" name="orderId" value="${order.id}">
                                    <c:choose>
                                        <c:when test="${order.status == 'READY_FOR_PICKUP'}">
                                            <input type="hidden" name="action" value="updateStatusToShipping">
                                            <button type="submit" class="btn btn-warning btn-sm">Xác nhận đã lấy hàng 📦</button>
                                        </c:when>
                                        <c:when test="${order.status == 'SHIPPING'}">
                                            <input type="hidden" name="action" value="updateStatusToDone">
                                            <button type="button" class="btn btn-primary btn-sm" onclick="openCompleteOrderModal(this)">Hoàn thành giao đơn 🎉</button>
                                        </c:when>
                                    </c:choose>
                                </form>
                            </div>
                        </div>
                    </c:forEach>

                    <c:if test="${empty danhSachDonHang}">
                        <div class="empty-state">
                            <div class="e-icon">📭</div>
                            <div class="e-title">Hiện tại không có đơn hàng nào được phân phối cho bạn</div>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</main>

<div class="pob-modal-overlay" id="detailModal">
    <div class="pob-modal-box">
        <div class="modal-header">
            <h3 style="font-weight: 800; font-size:16px; color:var(--text-main);">Chi tiết lộ trình đơn hàng</h3>
            <button type="button" class="modal-close" onclick="closeDetailModal()">✕</button>
        </div>
        <div class="modal-body">
            <div style="background: var(--bg-base); padding: 14px; border-radius: var(--radius-sm);">
                <div style="font-size: 12px; color: var(--text-dim);">MÃ ĐƠN HÀNG THỰC TẾ</div>
                <div id="modalOrderId" style="font-weight: 800; font-size: 16px; margin-top: 2px; color:var(--text-main);">#0</div>
            </div>
            <div>
                <label style="font-size: 11px; text-transform:uppercase; color: var(--text-dim); font-weight:700;">Địa điểm lấy hàng (Cửa hàng)</label>
                <div id="modalShopName" style="font-weight:700; margin-top:4px; font-size:14px; color:var(--text-main);">Tên cửa hàng</div>
            </div>
            <div>
                <label style="font-size: 11px; text-transform:uppercase; color: var(--text-dim); font-weight:700;">Địa điểm giao hàng (Khách hàng)</label>
                <div id="modalAddress" style="font-weight:700; margin-top:4px; font-size:14px; color:var(--text-main);">Địa chỉ giao hàng</div>
                <div id="modalReceiver" style="font-size:12px; color: var(--text-dim); margin-top:2px;">Người nhận</div>
            </div>
            <div style="border-top: 1px solid var(--border-color); padding-top: 14px; display:flex; justify-content:space-between; align-items:center;">
                <span style="font-weight: 700; font-size:14px; color:var(--text-main);">Tổng tiền cần thu hộ COD:</span>
                <span id="modalPrice" style="font-size: 18px; font-weight:800; color: var(--primary);">0đ</span>
            </div>
            <button type="button" class="btn btn-ghost btn-block" onclick="closeDetailModal()">Đóng cửa sổ</button>
        </div>
    </div>
</div>

<div class="pob-modal-overlay" id="completeOrderModal">
    <div class="pob-modal-box" style="max-width:360px;">
        <div class="modal-body" style="text-align:center;">
            <div style="font-size:40px;margin-bottom:8px;">🎉</div>
            <div style="font-weight:800;font-size:16px;color:#1e293b;margin-bottom:6px;">Xác nhận hoàn thành đơn?</div>
            <div style="font-size:13px;color:#64748b;margin-bottom:20px;">Đơn hàng sẽ chuyển sang trạng thái "Đã giao xong" và ghi nhận đã thu tiền. Thao tác này không thể hoàn tác.</div>
            <div style="display:flex;gap:10px;justify-content:center;">
                <button type="button" class="btn btn-ghost" onclick="closeCompleteOrderModal()">Huỷ</button>
                <button type="button" class="btn btn-primary" id="confirmCompleteBtn">🎉 Hoàn thành</button>
            </div>
        </div>
    </div>
</div>

<!-- Avatar Dropdown -->
<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${fn:escapeXml(sessionScope.account.userName)}</div>
        <div class="d-email">${fn:escapeXml(sessionScope.account.email)}</div>
        <span class="d-role">🛵 Shipper</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/shipper/ho-so" class="dropdown-link">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/shipper/doi-mat-khau" class="dropdown-link">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script>
    // --- LỌC ĐƠN HÀNG THEO TRẠNG THÁI + HÌNH THỨC THANH TOÁN ---
    var currentStatus = 'ALL';

    function filterOrders(status, btn) {
        currentStatus = status;
        var tabs = document.querySelectorAll('.tab-btn');
        tabs.forEach(function (tab) { tab.classList.remove('active'); });
        if (btn) btn.classList.add('active');
        applyFilters();
    }

    function applyFilters() {
        var paymentVal = document.getElementById('paymentFilter').value;
        var cards = document.querySelectorAll('.order-card');
        var visibleCount = 0;

        cards.forEach(function (card) {
            var cardStatus  = card.getAttribute('data-status');
            var cardPayment = card.getAttribute('data-payment') || 'COD';

            var normalizedPayment = (cardPayment === 'PAYOS') ? 'PAYOS'
                                    : (cardPayment === 'BANK')  ? 'BANK'
                                    : 'COD';

            var statusOk = (currentStatus === 'ALL')
                             || (currentStatus === 'HISTORY' ? (cardStatus === 'DONE' || cardStatus === 'CANCELLED')
                             : (currentStatus === 'WAITING' ? (cardStatus === 'PENDING' || cardStatus === 'CONFIRMED' || cardStatus === 'READY_FOR_PICKUP')
                             : cardStatus === currentStatus));

            var paymentOk = (paymentVal === 'ALL') || (normalizedPayment === paymentVal);

            var show = statusOk && paymentOk;
            card.style.display = show ? 'block' : 'none';
            if (show) visibleCount++;
        });

        var emptyMsg = document.getElementById('emptyFilterMsg');
        if (!emptyMsg) {
            emptyMsg = document.createElement('div');
            emptyMsg.id = 'emptyFilterMsg';
            emptyMsg.className = 'empty-state';
            emptyMsg.innerHTML = '<div class="e-icon">🔍</div><div class="e-title">Không có đơn hàng phù hợp với bộ lọc</div>';
            document.querySelector('.order-list').appendChild(emptyMsg);
        }
        emptyMsg.style.display = visibleCount === 0 ? 'block' : 'none';
    }

    // --- POPUP CHI TIẾT ---
    var detailModal = document.getElementById('detailModal');

    function openDetailModal(id, shopName, address, receiver, price, status) {
        document.getElementById('modalOrderId').innerText = '#' + id;
        document.getElementById('modalShopName').innerText = shopName;
        document.getElementById('modalAddress').innerText = address;
        document.getElementById('modalReceiver').innerText = '👤 Khách hàng: ' + receiver;
        document.getElementById('modalPrice').innerText = parseFloat(price).toLocaleString('vi-VN') + 'đ';
        detailModal.classList.add('open');
    }

    function closeDetailModal() {
        detailModal.classList.remove('open');
    }

    detailModal.addEventListener('click', function (e) {
        if (e.target === detailModal) closeDetailModal();
    });

    var completeOrderModal = document.getElementById('completeOrderModal');
    var pendingCompleteForm = null;

    function openCompleteOrderModal(btn) {
        pendingCompleteForm = btn.closest('form');
        completeOrderModal.classList.add('open');
    }

    function closeCompleteOrderModal() {
        pendingCompleteForm = null;
        completeOrderModal.classList.remove('open');
    }

    document.getElementById('confirmCompleteBtn').addEventListener('click', function () {
        if (pendingCompleteForm) pendingCompleteForm.submit();
    });

    completeOrderModal.addEventListener('click', function (e) {
        if (e.target === completeOrderModal) closeCompleteOrderModal();
    });

    document.addEventListener('DOMContentLoaded', function() {
        <c:if test="${param.success == 'accepted'}">
        // Tự động lọc sang tab "Chờ lấy hàng" để shipper thấy đơn vừa nhận
        var waitingTab = document.getElementById('tabWaiting');
        if (waitingTab) waitingTab.click();
        // Tự đóng toast sau 8 giây
        var toast = document.getElementById('acceptToast');
        if (toast) setTimeout(function() { toast.style.display='none'; }, 8000);
        </c:if>

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
</script>
</body>
</html>
