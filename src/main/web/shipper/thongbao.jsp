<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Thông báo - POB Shipper</title>
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

        .page-header { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
        .page-title { font-size: 20px; font-weight: 800; color: var(--text-main); display: flex; align-items: center; gap: 10px; }
        .unread-badge { background: var(--warning); color: #3a2a1e; font-size: 12px; font-weight: 700; padding: 2px 10px; border-radius: var(--radius-pill); }

        .notif-list { display: flex; flex-direction: column; gap: 12px; }
        .notif-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 16px 20px; display: flex; gap: 14px; align-items: flex-start; box-shadow: var(--dash-shadow-sm); }
        .notif-card.unread { border-left: 4px solid var(--warning); background: var(--warning-light); }
        .notif-icon { font-size: 24px; flex-shrink: 0; margin-top: 2px; }
        .notif-body { flex: 1; }
        .notif-title { font-size: 15px; font-weight: 700; margin-bottom: 4px; color: var(--text-muted); }
        .notif-card.unread .notif-title { color: var(--text-main); }
        .notif-message { font-size: 13px; color: var(--text-muted); line-height: 1.6; }
        .notif-time { font-size: 11px; color: var(--text-dim); margin-top: 6px; }
        .notif-dot { width: 9px; height: 9px; border-radius: 50%; background: var(--warning); flex-shrink: 0; margin-top: 7px; }
        .notif-read-btn { background: none; border: 1px solid var(--border-color); border-radius: 6px; padding: 4px 10px; font-size: 11px; cursor: pointer; color: var(--text-dim); flex-shrink: 0; margin-top: 4px; }
        .notif-read-btn:hover { background: var(--primary-light); color: var(--primary); border-color: var(--primary); }
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
        <a href="${pageContext.request.contextPath}/shipper/thongbao" class="menu-item active">
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
                Hộp thư thông báo
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
        <div class="page-header">
            <div class="page-title">
                🔔 Thông báo
                <c:if test="${unreadCount > 0}"><span class="unread-badge">${unreadCount} chưa đọc</span></c:if>
            </div>
            <c:if test="${unreadCount > 0}">
                <form action="${pageContext.request.contextPath}/shipper/thongbao" method="post" style="margin:0">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="markAll"/>
                    <button type="submit" class="btn btn-outline btn-sm">✅ Đánh dấu tất cả đã đọc</button>
                </form>
            </c:if>
        </div>

        <c:choose>
            <c:when test="${empty notifications}">
                <div class="empty-state">
                    <div class="e-icon">🔕</div>
                    <div class="e-title">Bạn chưa có thông báo nào</div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="notif-list">
                    <c:forEach var="n" items="${notifications}">
                        <div class="notif-card ${n.read ? '' : 'unread'}">
                            <div class="notif-icon">🔔</div>
                            <div class="notif-body">
                                <div class="notif-title">${fn:escapeXml(n.title)}</div>
                                <div class="notif-message">${fn:escapeXml(n.message)}</div>
                                <div class="notif-time">
                                    <c:if test="${n.createdAt != null}">
                                        ${n.createdAt.hour}:<c:set var="m" value="${n.createdAt.minute}"/><c:if test="${m < 10}">0</c:if>${m}
                                        ${n.createdAt.dayOfMonth}/${n.createdAt.monthValue}/${n.createdAt.year}
                                    </c:if>
                                </div>
                            </div>
                            <c:if test="${!n.read}">
                                <div style="display:flex;flex-direction:column;align-items:flex-end;gap:6px">
                                    <div class="notif-dot"></div>
                                    <form action="${pageContext.request.contextPath}/shipper/thongbao" method="post" style="margin:0">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="id" value="${n.id}"/>
                                        <button type="submit" class="notif-read-btn">Đã đọc</button>
                                    </form>
                                </div>
                            </c:if>
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
<script>window.POB_CONTEXT_PATH = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/notifications-ws.js"></script>
<script>
    document.addEventListener('pob-notification', function () {
        setTimeout(function () { window.location.reload(); }, 1200);
    });
</script>
</body>
</html>
