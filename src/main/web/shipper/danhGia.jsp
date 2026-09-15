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
    <title>Đánh giá & Báo cáo - POB Shipper</title>
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

        .order-list { display: flex; flex-direction: column; gap: 14px; }
        .order-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 20px; box-shadow: var(--dash-shadow-sm); position: relative; overflow: hidden; }
        .order-card::before { content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%; background: var(--success); }
        .order-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
        .order-id { font-weight: 700; font-size: 15px; color: var(--text-main); }
        .shop-name { font-size: 13px; color: var(--text-dim); margin-top: 2px; }
        .route-timeline { padding-left: 20px; margin-bottom: 14px; }
        .route-step { margin-bottom: 10px; font-size: 13px; }
        .route-step:last-child { margin-bottom: 0; }
        .route-label { font-size: 11px; color: var(--text-dim); font-weight: 700; text-transform: uppercase; }
        .route-text { font-weight: 700; margin-top: 2px; color: var(--text-main); }
        .price-tag { font-size: 15px; font-weight: 800; color: var(--primary); }
        .btn-flex-group { display: flex; gap: 8px; justify-content: flex-end; align-items: center; margin-top: 14px; flex-wrap: wrap; }
        .btn-feedback { background: var(--warning-light); color: var(--warning-dark); border: 1px solid var(--warning); }
        .btn-feedback:hover { background: var(--warning); color: #3a2a1e; }
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
        <a href="${pageContext.request.contextPath}/shipper/donhang" class="menu-item">
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
        <a href="${pageContext.request.contextPath}/shipper/danh-gia" class="menu-item active">
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
                ⭐ Đánh giá &amp; Báo cáo
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
                            <img src="${sessionScope.account.avatarUrl}" alt="avatar"/>
                        </c:when>
                        <c:otherwise>${fn:toUpperCase(fn:substring(sessionScope.account.userName, 0, 2))}</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </header>

    <div class="content">

        <c:if test="${param.success eq '1'}">
            <div class="alert alert-success">✅ Đánh giá của bạn đã được gửi thành công!</div>
        </c:if>

        <c:choose>
            <c:when test="${empty doneOrders}">
                <div class="empty-state">
                    <div class="e-icon">📭</div>
                    <div class="e-title">Chưa có đơn hàng hoàn thành</div>
                    <div class="e-sub">Sau khi giao xong đơn hàng, bạn có thể đánh giá shop và báo cáo tại đây.</div>
                </div>
            </c:when>
            <c:otherwise>
                <p style="font-size:13px; color:var(--text-dim);">Tổng <strong>${doneOrders.size()}</strong> đơn đã hoàn thành</p>

                <div class="order-list">
                    <c:forEach var="order" items="${doneOrders}">
                        <div class="order-card">
                            <div class="order-header">
                                <div>
                                    <div class="order-id">Đơn #${order.id}</div>
                                    <div class="shop-name">🏪 ${fn:escapeXml(order.shopName)}</div>
                                </div>
                                <span class="badge badge-success">✓ Hoàn thành</span>
                            </div>

                            <div class="route-timeline">
                                <div class="route-step">
                                    <div class="route-label">Địa chỉ giao</div>
                                    <div class="route-text">📍 ${fn:escapeXml(order.shippingAddress)}</div>
                                </div>
                                <div class="route-step">
                                    <div class="route-label">Người nhận</div>
                                    <div class="route-text">👤 ${fn:escapeXml(order.receiverName)} — ${order.receiverPhone}</div>
                                </div>
                            </div>

                            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:4px;">
                                <span class="price-tag">💰 <fmt:formatNumber value="${order.totalPrice}" type="number" groupingUsed="true"/>đ</span>
                            </div>

                            <div class="btn-flex-group">
                                <c:choose>
                                    <c:when test="${order.feedbackShop}">
                                        <span class="badge badge-neutral">✓ Đã đánh giá shop</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/shipper/feedback?orderId=${order.id}">
                                            <button class="btn btn-feedback btn-sm">⭐ Đánh giá Shop</button>
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

    </div>
</main>

<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${fn:escapeXml(sessionScope.account.userName)}</div>
        <div class="d-email">${sessionScope.account.email}</div>
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
</script>
</body>
</html>
