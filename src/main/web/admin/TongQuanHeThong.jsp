<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%-- BẢO MẬT: KIỂM TRA QUYỀN SUPER ADMIN --%>
<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 1}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Tổng quan hệ thống - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-theme.css">
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
        .stat-card.info .stat-icon { background: var(--info-light); color: var(--info); }
        .stat-card.warning .stat-icon { background: var(--warning-light); color: var(--warning-dark); }
        .stat-card.danger .stat-icon { background: var(--danger-light); color: var(--danger); }
    </style>
</head>
<body class="dash-body admin-theme">

<c:set var="adminActive" value="/tong-quan" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">dashboard</span> Tổng quan hệ thống</h1>
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
        <div class="stats-grid">
            <div class="stat-card info">
                <div>
                    <div style="font-size:12px;color:var(--text-dim);font-weight:600;">Tổng tài khoản hệ thống</div>
                    <div class="stat-num">${tongTaiKhoan}</div>
                </div>
                <div class="stat-icon">👥</div>
            </div>
            <div class="stat-card warning">
                <div>
                    <div style="font-size:12px;color:var(--text-dim);font-weight:600;">Shop chờ phê duyệt</div>
                    <div class="stat-num">${shopChoDuyet}</div>
                </div>
                <div class="stat-icon">🏪</div>
            </div>
            <div class="stat-card">
                <div>
                    <div style="font-size:12px;color:var(--text-dim);font-weight:600;">Shipper đang hoạt động</div>
                    <div class="stat-num">${shipperHoatDong}</div>
                </div>
                <div class="stat-icon">🛵</div>
            </div>
            <div class="stat-card danger">
                <div>
                    <div style="font-size:12px;color:var(--text-dim);font-weight:600;">Cảnh báo vi phạm</div>
                    <div class="stat-num">${canhBaoViPham}</div>
                </div>
                <div class="stat-icon">⚠️</div>
            </div>
            <div class="stat-card">
                <div>
                    <div style="font-size:12px;color:var(--text-dim);font-weight:600;">Tổng doanh thu toàn sàn</div>
                    <div class="stat-num"><fmt:formatNumber value="${tongDoanhThuSan}" type="number" groupingUsed="true" maxFractionDigits="0"/> đ</div>
                </div>
                <div class="stat-icon">💰</div>
            </div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">📈 Đơn hàng &amp; doanh thu toàn sàn (7 ngày gần đây)</div>
            </div>
            <div class="panel-body"><canvas id="dailyStatsChart" height="90"></canvas></div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">🏆 Top 5 shop doanh thu cao nhất</div>
            </div>
            <div class="panel-body"><canvas id="topShopChart" height="90"></canvas></div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">📋 Yêu cầu duyệt shop gần đây</div>
            </div>
            <div class="panel-body" style="padding:0;">
                <div class="dash-table-wrap">
                    <table class="dash-table">
                        <thead>
                        <tr>
                            <th>Người đăng ký</th>
                            <th>Email</th>
                            <th>Ngày đăng ký</th>
                            <th>Trạng thái</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="account" items="${top5Shop}">
                            <tr>
                                <td>
                                    <strong style="color: var(--text-main);">${fn:escapeXml(account.fullName)}</strong><br>
                                    <span style="font-size: 12px; color: var(--text-dim);">📞 ${account.phone}</span>
                                </td>
                                <td>${account.email}</td>
                                <td>${account.createdAt}</td>
                                <td><span class="badge badge-warning">⏳ Chờ xử lý</span></td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty top5Shop}">
                            <tr>
                                <td colspan="4">
                                    <div class="empty-state" style="padding:36px 24px;">
                                        <div class="e-icon">🏪</div>
                                        <div class="e-title">Chưa có yêu cầu đăng ký shop nào</div>
                                        <div class="e-sub">Bấm vào menu "Duyệt Shop" để xem toàn bộ danh sách.</div>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>

<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${sessionScope.account.userName}</div>
        <div class="d-email">${sessionScope.account.email}</div>
        <span class="d-role">Super Admin</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/admin/profile" class="dropdown-link">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/admin/change-password" class="dropdown-link">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pixel-cat.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    (function () {
        var dailyLabels = [
            <c:forEach var="d" items="${thongKeTheoNgay}">'${d.ngay}',</c:forEach>
        ];
        var dailyRevenue = [
            <c:forEach var="d" items="${thongKeTheoNgay}">${d.doanhThu},</c:forEach>
        ];
        var dailyDone = [
            <c:forEach var="d" items="${thongKeTheoNgay}">${d.donThanhCong},</c:forEach>
        ];
        var dailyCancelled = [
            <c:forEach var="d" items="${thongKeTheoNgay}">${d.donHuy},</c:forEach>
        ];

        new Chart(document.getElementById('dailyStatsChart'), {
            type: 'bar',
            data: {
                labels: dailyLabels,
                datasets: [
                    { type: 'line', label: 'Doanh thu (đ)', data: dailyRevenue, borderColor: '#FF3B1F', backgroundColor: '#FF3B1F', yAxisID: 'y1', tension: 0.3 },
                    { label: 'Đơn hoàn thành', data: dailyDone, backgroundColor: '#4CAF50', yAxisID: 'y' },
                    { label: 'Đơn hủy', data: dailyCancelled, backgroundColor: '#F44336', yAxisID: 'y' }
                ]
            },
            options: {
                responsive: true,
                interaction: { mode: 'index', intersect: false },
                scales: {
                    y: { type: 'linear', position: 'left', beginAtZero: true, title: { display: true, text: 'Số đơn' } },
                    y1: { type: 'linear', position: 'right', beginAtZero: true, grid: { drawOnChartArea: false }, title: { display: true, text: 'Doanh thu (đ)' } }
                }
            }
        });

        var shopLabels = [
            <c:forEach var="s" items="${top5ShopDoanhThu}">'${fn:escapeXml(s.shopName)}',</c:forEach>
        ];
        var shopRevenue = [
            <c:forEach var="s" items="${top5ShopDoanhThu}">${s.doanhThu},</c:forEach>
        ];

        new Chart(document.getElementById('topShopChart'), {
            type: 'bar',
            data: {
                labels: shopLabels,
                datasets: [{ label: 'Doanh thu (đ)', data: shopRevenue, backgroundColor: '#FF9800', borderRadius: 6 }]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                plugins: { legend: { display: false } },
                scales: { x: { beginAtZero: true } }
            }
        });
    })();

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
