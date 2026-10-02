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
    <title>Dashboard - POB Shipper</title>
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

        /* Online/Offline toggle ở cuối sidebar */
        .online-toggle-btn { width: 100%; padding: 12px 16px; border-radius: var(--radius-sm); border: none; cursor: pointer; display: flex; align-items: center; gap: 10px; font-size: 13px; font-weight: 700; }
        .online-toggle-btn.is-online { background: var(--success-light); color: var(--success-dark); border: 1.5px solid var(--success); }
        .online-toggle-btn.is-offline { background: var(--danger-light); color: var(--danger); border: 1.5px solid var(--danger); }
        .toggle-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
        .toggle-dot.online { background: var(--success); animation: pobBlink 1.5s infinite; }
        .toggle-dot.offline { background: var(--danger); }

        .section-title { font-size: 13px; font-weight: 800; color: var(--text-dim); text-transform: uppercase; letter-spacing: .5px; margin-bottom: 12px; }
        .badge-payos { background: rgba(139,92,246,.14); color: #8b5cf6; }
    </style>
</head>
<body class="dash-body">

<c:set var="shipperActive" value="/shipper/dashboard" scope="request"/>
<%@ include file="_shipperSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1>📊 Dashboard Thu nhập</h1>
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

        <%-- Stat cards hàng 1: Thu nhập --%>
        <div>
            <div class="section-title">💰 Thu nhập (phí ship)</div>
            <div class="stats-grid">
                <div class="stat-card">
                    <div>
                        <div class="stat-label">Hôm nay</div>
                        <div class="stat-num" style="color:var(--primary);"><fmt:formatNumber value="${thuHomNay}" type="number" maxFractionDigits="0"/>đ</div>
                    </div>
                    <div class="stat-icon">💵</div>
                </div>
                <div class="stat-card">
                    <div>
                        <div class="stat-label">Tuần này</div>
                        <div class="stat-num" style="color:var(--primary);"><fmt:formatNumber value="${thuTuanNay}" type="number" maxFractionDigits="0"/>đ</div>
                    </div>
                    <div class="stat-icon">📅</div>
                </div>
                <div class="stat-card">
                    <div>
                        <div class="stat-label">Tháng này</div>
                        <div class="stat-num" style="color:var(--primary);"><fmt:formatNumber value="${thuThangNay}" type="number" maxFractionDigits="0"/>đ</div>
                    </div>
                    <div class="stat-icon">🗓️</div>
                </div>
            </div>
        </div>

        <%-- Stat cards hàng 2: Đơn hàng --%>
        <div>
            <div class="section-title">📦 Thống kê đơn hàng</div>
            <div class="stats-grid">
                <div class="stat-card">
                    <div><div class="stat-label">Hôm nay</div><div class="stat-num">${donHomNay} đơn</div></div>
                    <div class="stat-icon" style="background:var(--success-light);color:var(--success-dark);">✓</div>
                </div>
                <div class="stat-card">
                    <div><div class="stat-label">Tuần này</div><div class="stat-num">${donTuanNay} đơn</div></div>
                    <div class="stat-icon" style="background:var(--info-light);color:var(--info-dark);">📆</div>
                </div>
                <div class="stat-card">
                    <div><div class="stat-label">Tháng này</div><div class="stat-num">${donThangNay} đơn</div></div>
                    <div class="stat-icon" style="background:rgba(139,92,246,.12);color:#8b5cf6;">🗃️</div>
                </div>
                <div class="stat-card">
                    <div><div class="stat-label">Tổng tất cả</div><div class="stat-num">${tongDon} đơn</div></div>
                    <div class="stat-icon" style="background:var(--warning-light);color:var(--warning-dark);">🏆</div>
                </div>
                <div class="stat-card">
                    <div><div class="stat-label">Chờ lấy hàng</div><div class="stat-num" style="color:var(--warning-dark);">${dangChoLayHang} đơn</div></div>
                    <div class="stat-icon" style="background:var(--warning-light);color:var(--warning-dark);">📦</div>
                </div>
                <div class="stat-card">
                    <div><div class="stat-label">Đang giao</div><div class="stat-num" style="color:var(--primary);">${dangGiao} đơn</div></div>
                    <div class="stat-icon">🛵</div>
                </div>
            </div>
        </div>

        <%-- Biểu đồ thu nhập 7 ngày --%>
        <div class="panel">
            <div class="panel-header"><div class="panel-title">📈 Thu nhập 7 ngày gần đây</div></div>
            <div class="panel-body">
                <canvas id="revenueChart" height="90"></canvas>
            </div>
        </div>

        <%-- Bảng 10 đơn gần nhất --%>
        <div class="panel">
            <div class="panel-header"><div class="panel-title">🕐 10 đơn hoàn thành gần nhất</div></div>
            <div class="panel-body">
                <c:choose>
                    <c:when test="${empty recentDone}">
                        <div class="empty-state">
                            <div class="e-icon">📭</div>
                            <div class="e-title">Chưa có đơn hàng nào hoàn thành</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="dash-table-wrap">
                            <table class="dash-table">
                                <thead>
                                    <tr>
                                        <th>#Mã đơn</th>
                                        <th>Cửa hàng</th>
                                        <th>Người nhận</th>
                                        <th>Tổng đơn</th>
                                        <th>Phí ship</th>
                                        <th>Hình thức TT</th>
                                        <th>Thời gian</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="row" items="${recentDone}">
                                        <tr>
                                            <td style="font-weight:700;">#${row.id}</td>
                                            <td>${fn:escapeXml(row.shopName)}</td>
                                            <td>${fn:escapeXml(row.receiverName)}</td>
                                            <td style="font-weight:700;color:var(--primary);"><fmt:formatNumber value="${row.totalPrice}" type="number" maxFractionDigits="0"/>đ</td>
                                            <td style="font-weight:700;color:var(--warning-dark);"><fmt:formatNumber value="${row.deliveryFee}" type="number" maxFractionDigits="0"/>đ</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${row.paymentMethod == 'PAYOS'}"><span class="badge badge-payos">🏦 PayOS</span></c:when>
                                                    <c:when test="${row.paymentMethod == 'BANK'}"><span class="badge badge-info">📱 QR</span></c:when>
                                                    <c:otherwise><span class="badge badge-warning">💵 COD</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <c:set var="ca" value="${row.createdAt}"/>
                                            <td style="color:var(--text-dim);font-size:12px;">${fn:substring(ca,11,16)} ${fn:substring(ca,8,10)}/${fn:substring(ca,5,7)}/${fn:substring(ca,0,4)}</td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

    </div>
</main>

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

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script>
    // --- CHART ---
    var labels   = ${chartLabels};
    var dataVals = ${chartData};

    var ctx = document.getElementById('revenueChart').getContext('2d');
    var chart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Phí ship (đ)',
                data: dataVals,
                backgroundColor: 'rgba(255,87,34,0.75)',
                borderColor: 'rgba(255,87,34,1)',
                borderWidth: 2,
                borderRadius: 6,
                borderSkipped: false
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: { callbacks: { label: function (c) { return c.parsed.y.toLocaleString('vi-VN') + 'đ'; } } }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function (v) { return v.toLocaleString('vi-VN') + 'đ'; },
                        color: getComputedStyle(document.documentElement).getPropertyValue('--text-muted').trim()
                    },
                    grid: { color: 'rgba(128,128,128,0.15)' }
                },
                x: {
                    ticks: { color: getComputedStyle(document.documentElement).getPropertyValue('--text-muted').trim() },
                    grid: { display: false }
                }
            }
        }
    });

    function updateChartTheme() {
        var muted = getComputedStyle(document.documentElement).getPropertyValue('--text-muted').trim();
        chart.options.scales.y.ticks.color = muted;
        chart.options.scales.x.ticks.color = muted;
        chart.update();
    }
    var themeBtn = document.getElementById('themeToggleBtn');
    if (themeBtn) themeBtn.addEventListener('click', function () { setTimeout(updateChartTheme, 50); });

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
