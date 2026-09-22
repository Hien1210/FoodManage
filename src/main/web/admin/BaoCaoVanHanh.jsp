<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="/app-functions" prefix="app" %>

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
    <title>Báo cáo vận hành - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        /* === BIẾN THEME (DARK/LIGHT) === */
        :root[data-theme="dark"] {
            --bg-base: #0f172a;
            --bg-sidebar: #1e293b;
            --bg-panel: #1e293b;
            --bg-input: #0f172a;
            --bg-hover: #1e293b;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --text-dim: #64748b;
            --border-color: #334155;
            --topbar-bg: rgba(30, 41, 59, 0.8);
            --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
        }

        :root { --primary-hover: var(--primary-dark); --purple: #8b5cf6; }

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

        /* FILTER BAR */
        .filter-bar { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; padding: 18px 20px; display: flex; align-items: flex-end; gap: 18px; flex-wrap: wrap; }
        .filter-field { display: flex; flex-direction: column; gap: 6px; }
        .filter-field label { font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; color: var(--text-muted); font-weight: 700; }
        .filter-field input[type="date"] { background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 8px; padding: 9px 12px; color: var(--text-main); font-size: 13px; }
        .filter-field input[type="date"]::-webkit-calendar-picker-indicator { filter: invert(0.6); cursor: pointer; }
        .btn-filter { background: var(--primary); color: #ffffff; border: none; border-radius: 8px; padding: 10px 22px; font-size: 13px; font-weight: 700; cursor: pointer; transition: all 0.2s ease; }
        .btn-filter:hover { background: var(--primary-hover); transform: translateY(-1px); }

        /* CARDS THỐNG KÊ */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; }
        .stat-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 8px; padding: 20px; display: flex; flex-direction: column; border-top: 3px solid var(--border-color); transition: all 0.2s ease;}
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 6px 14px rgba(0,0,0,0.15); }
        .stat-card:nth-child(1) { border-top-color: var(--info); }
        .stat-card:nth-child(2) { border-top-color: var(--primary); }
        .stat-card:nth-child(3) { border-top-color: var(--warning); }
        .stat-card:nth-child(4) { border-top-color: var(--purple); }
        .stat-title { font-size: 12px; text-transform: uppercase; color: var(--text-muted); margin-bottom: 10px; font-weight: bold; }
        .stat-value { font-size: 28px; font-weight: bold; color: var(--text-main); }
        .stat-hint { font-size: 11px; color: var(--text-dim); margin-top: 6px; }

        /* LAYOUT 2 CỘT THÂN DƯỚI */
        .dashboard-grid { display: grid; grid-template-columns: 1.2fr 1fr; gap: 25px; }
        @media (max-width: 1100px) { .dashboard-grid { grid-template-columns: 1fr; } }
        .chart-container { position: relative; height: 340px; }

        .panel { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; animation: fadeUp 0.35s ease both; padding: 20px; }
        .panel-title { color: var(--warning); font-size: 14px; font-weight: bold; margin-bottom: 20px; text-transform: uppercase; border-left: 4px solid var(--warning); padding-left: 10px; }
        .legend-list { display: flex; flex-direction: column; gap: 14px; margin-top: 10px; }
        .legend-row { display: flex; align-items: center; justify-content: space-between; font-size: 13px; color: var(--text-main); }
        .legend-dot { display: inline-block; width: 10px; height: 10px; border-radius: 50%; margin-right: 8px; }
        .legend-count { color: var(--text-muted); font-weight: 600; }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body class="dash-body admin-theme">
<c:set var="adminActive" value="/admin/bao-cao-van-hanh" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">bar_chart</span> Báo cáo vận hành</h1>
        </div>
        <div class="topbar-right">
            <button type="button" class="theme-toggle" onclick="pobToggleTheme()" title="Chuyển đổi giao diện"><span data-theme-icon>🌙</span></button>
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
            <!-- BỘ LỌC NGÀY -->
            <form class="filter-bar" method="get" action="${pageContext.request.contextPath}/admin/bao-cao-van-hanh">
                <div class="filter-field">
                    <label for="tuNgay">Từ ngày</label>
                    <input type="date" id="tuNgay" name="tuNgay" value="${tuNgay}" max="${denNgay}">
                </div>
                <div class="filter-field">
                    <label for="denNgay">Đến ngày</label>
                    <input type="date" id="denNgay" name="denNgay" value="${denNgay}" min="${tuNgay}">
                </div>
                <button type="submit" class="btn-filter">🔍 Xem báo cáo</button>
                <a class="btn-filter" style="background: var(--info, #3b82f6); color: #fff; text-decoration:none; display:inline-block;"
                   href="${pageContext.request.contextPath}/admin/bao-cao-van-hanh?action=exportExcel&tuNgay=${tuNgay}&denNgay=${denNgay}">
                    📊 Xuất thống kê (Excel)
                </a>
            </form>

            <!-- KHỐI THỐNG KÊ NHANH -->
            <div class="stats-grid">
                <div class="stat-card">
                    <span class="stat-title">Tổng Đơn Hàng Phát Sinh</span>
                    <span class="stat-value">${tongDonHang}</span>
                    <span class="stat-hint">Từ ${tuNgay} đến ${denNgay}</span>
                </div>
                <div class="stat-card">
                    <span class="stat-title">Tỷ Lệ Hoàn Thành Đơn</span>
                    <span class="stat-value" style="color: var(--primary);"><fmt:formatNumber value="${tyLeHoanThanh}" pattern="#,##0.0"/>%</span>
                    <span class="stat-hint">${donThanhCong} / ${tongDonHang} đơn thành công</span>
                </div>
                <div class="stat-card">
                    <span class="stat-title">Thời Gian Giao Hàng Trung Bình</span>
                    <c:choose>
                        <c:when test="${not empty thoiGianGiaoTrungBinh}">
                            <span class="stat-value" style="color: var(--warning);"><fmt:formatNumber value="${thoiGianGiaoTrungBinh}" pattern="#,##0.0"/> phút</span>
                        </c:when>
                        <c:otherwise>
                            <span class="stat-value" style="color: var(--warning);">--</span>
                        </c:otherwise>
                    </c:choose>
                    <span class="stat-hint">Từ lúc Shop xác nhận đến khi giao xong</span>
                </div>
                <div class="stat-card">
                    <span class="stat-title">Khung Giờ Đặt Hàng Cao Điểm</span>
                    <c:choose>
                        <c:when test="${not empty khungGioCaoDiem}">
                            <span class="stat-value" style="color: var(--purple);">${khungGioCaoDiem}</span>
                        </c:when>
                        <c:otherwise>
                            <span class="stat-value" style="color: var(--purple);">--</span>
                        </c:otherwise>
                    </c:choose>
                    <span class="stat-hint">Giờ có nhiều đơn phát sinh nhất</span>
                </div>
            </div>

            <!-- BIỂU ĐỒ TRẠNG THÁI ĐƠN HÀNG -->
            <div class="dashboard-grid">
                <div class="panel chart-panel">
                    <div class="panel-title">■ TỶ LỆ TRẠNG THÁI ĐƠN HÀNG</div>
                    <div class="chart-container">
                        <canvas id="orderStatusChart"></canvas>
                    </div>
                </div>

                <div class="panel">
                    <div class="panel-title">■ CHI TIẾT SỐ ĐƠN THEO TRẠNG THÁI</div>
                    <div class="legend-list">
                        <div class="legend-row">
                            <span><span class="legend-dot" style="background: #00ff9d;"></span>Thành công</span>
                            <span class="legend-count">${donThanhCong}</span>
                        </div>
                        <div class="legend-row">
                            <span><span class="legend-dot" style="background: #ff3860;"></span>Đã hủy</span>
                            <span class="legend-count">${donDaHuy}</span>
                        </div>
                        <div class="legend-row">
                            <span><span class="legend-dot" style="background: #ff9100;"></span>Đang giao</span>
                            <span class="legend-count">${donDangGiao}</span>
                        </div>
                    </div>
                    <c:if test="${tongDonHang == 0}">
                        <p style="margin-top: 16px; font-size: 12px; color: var(--text-dim);">
                            📊 Không có đơn hàng nào phát sinh trong khoảng thời gian đã chọn.
                        </p>
                    </c:if>
                </div>
            </div>

            <!-- BIỂU ĐỒ THỐNG KÊ LÝ DO HỦY ĐƠN -->
            <div class="panel">
                <div class="panel-title">■ THỐNG KÊ LÝ DO HỦY ĐƠN</div>
                <c:choose>
                    <c:when test="${not empty lyDoHuyDon}">
                        <div class="chart-container">
                            <canvas id="cancelReasonChart"></canvas>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p style="font-size: 12px; color: var(--text-dim);">
                            📊 Không có đơn hàng nào bị hủy trong khoảng thời gian đã chọn.
                        </p>
                    </c:otherwise>
                </c:choose>
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

    <!-- BIỂU ĐỒ TRÒN TRẠNG THÁI ĐƠN HÀNG (Chart.js) -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        const statusTextColor = getComputedStyle(document.documentElement).getPropertyValue('--text-muted').trim();

        new Chart(document.getElementById('orderStatusChart'), {
            type: 'doughnut',
            data: {
                labels: ['Thành công', 'Đã hủy', 'Đang giao'],
                datasets: [{
                    data: [${donThanhCong}, ${donDaHuy}, ${donDangGiao}],
                    backgroundColor: ['#00ff9d', '#ff3860', '#ff9100'],
                    borderColor: getComputedStyle(document.documentElement).getPropertyValue('--bg-panel').trim(),
                    borderWidth: 3,
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '65%',
                plugins: {
                    legend: { position: 'bottom', labels: { color: statusTextColor, padding: 16 } },
                    tooltip: { backgroundColor: '#1e293b', borderColor: '#334155', borderWidth: 1 }
                }
            }
        });
    </script>

    <!-- BIỂU ĐỒ CỘT LÝ DO HỦY ĐƠN (Chart.js) -->
    <c:if test="${not empty lyDoHuyDon}">
        <script>
            (function () {
                const cancelReasonLabels = [];
                const cancelReasonCounts = [];
                <c:forEach var="entry" items="${lyDoHuyDon}">
                cancelReasonLabels.push("${fn:escapeXml(entry.key)}");
                cancelReasonCounts.push(${entry.value});
                </c:forEach>

                const axisTextColor = getComputedStyle(document.documentElement).getPropertyValue('--text-muted').trim();
                const gridColor = getComputedStyle(document.documentElement).getPropertyValue('--border-color').trim();

                new Chart(document.getElementById('cancelReasonChart'), {
                    type: 'bar',
                    data: {
                        labels: cancelReasonLabels,
                        datasets: [{
                            label: 'Số đơn hủy',
                            data: cancelReasonCounts,
                            backgroundColor: '#ff3860',
                            borderRadius: 6,
                            maxBarThickness: 48
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: { backgroundColor: '#1e293b', borderColor: '#334155', borderWidth: 1 }
                        },
                        scales: {
                            x: { ticks: { color: axisTextColor }, grid: { color: gridColor } },
                            y: { beginAtZero: true, ticks: { color: axisTextColor, precision: 0 }, grid: { color: gridColor } }
                        }
                    }
                });
            })();
        </script>
    </c:if>
</body>
</html>
