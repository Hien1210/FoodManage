<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<%-- BẢO MẬT: KIỂM TRA QUYỀN SHOP (roleId = 2) --%>
<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 2}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ cửa hàng</title>
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

        /* Đặc thù trang chủ shop: banner chào mừng + biểu đồ */
        .welcome-banner { background: var(--brand-gradient, linear-gradient(120deg, var(--primary) 0%, var(--primary-dark) 100%)); border-radius: var(--radius-lg); padding: 28px 32px; color: #fff; display: flex; align-items: center; justify-content: space-between; box-shadow: var(--dash-shadow-md); }
        .welcome-banner h1 { font-size: 21px; font-weight: 800; margin-bottom: 6px; }
        .welcome-banner p { font-size: 13px; opacity: .92; }
        .welcome-emoji { font-size: 46px; }
        .stat-icon.green { background: var(--success-light); color: var(--success-dark); }
        .stat-icon.red { background: var(--danger-light); color: var(--danger); }
        .stat-icon.yellow { background: var(--warning-light); color: var(--warning-dark); }

        .btn-hero-cta { background: #fff; color: var(--primary-dark); border-radius: 999px; padding: 11px 20px; font-weight: 800; font-size: 13.5px; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 8px 20px rgba(0,0,0,.16); white-space: nowrap; }
        body.dash-body a.btn-hero-cta { color: var(--primary-dark); }
        .btn-hero-cta .material-symbols-outlined { font-size: 19px; }
        .stat-card.stat-alert { border-color: var(--primary); box-shadow: 0 0 0 2px var(--primary-light), var(--dash-shadow-sm); }
        .home-grid { display: grid; grid-template-columns: minmax(0, 1.6fr) minmax(0, 1fr); gap: 24px; align-items: stretch; }
        .chart-box { position: relative; height: 270px; }
        .tb-icon-sm { font-size: 22px; color: var(--primary); }
        .top-row { display: flex; align-items: center; gap: 12px; padding: 12px 0; border-bottom: 1px dashed var(--border-color); }
        .top-row:last-child { border-bottom: none; }
        .top-rank { width: 30px; height: 30px; border-radius: 50%; flex-shrink: 0; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 800; background: var(--bg-input); color: var(--text-muted); }
        .top-rank.r1 { background: var(--brand-gradient); color: #fff; }
        .top-rank.r2 { background: #FFDBCF; color: #802900; }
        .top-rank.r3 { background: #FFDEAC; color: #604100; }
        .top-info { flex: 1; min-width: 0; }
        .top-name { font-weight: 700; color: var(--text-main); font-size: 13.5px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .top-sub { font-size: 12px; color: var(--text-dim); }
        .top-rev { font-weight: 800; color: var(--primary); font-size: 13.5px; white-space: nowrap; }
        @media (max-width: 1100px) { .home-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="/shop" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">dashboard</span> Trang chủ cửa hàng</h1>
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
        <div class="welcome-banner">
            <div>
                <h1>Chào mừng quay lại, <c:out value="${sessionScope.account.fullName != null ? sessionScope.account.fullName : sessionScope.account.userName}"/>! 👋</h1>
                <p>Đây là tổng quan hoạt động kinh doanh của cửa hàng bạn hôm nay.</p>
            </div>
            <a href="${pageContext.request.contextPath}/shop/bills" class="btn btn-hero-cta"><span class="material-symbols-outlined">receipt_long</span> Xem đơn hàng</a>
        </div>

        <%-- Tỷ lệ hoàn thành = đơn hoàn thành / tổng đơn (số liệu thật từ ShopHomeServlet) --%>
        <div class="stats-grid">
            <div class="stat-card">
                <div>
                    <div class="stat-label">Doanh thu hôm nay</div>
                    <div class="stat-num"><fmt:formatNumber value="${doanhThuHomNay}" pattern="#,##0"/> đ</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">payments</span></div>
            </div>
            <div class="stat-card ${donChoXuLy > 0 ? 'stat-alert' : ''}">
                <div>
                    <div class="stat-label">Đơn chờ xử lý</div>
                    <div class="stat-num">${donChoXuLy}</div>
                    <div class="stat-trend"><a href="${pageContext.request.contextPath}/shop/bills" style="color:var(--primary);font-weight:700;">Xử lý ngay →</a></div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">notifications_active</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Tỷ lệ hoàn thành</div>
                    <div class="stat-num"><c:choose>
                        <c:when test="${tongDon > 0}"><fmt:formatNumber value="${donHoanThanh * 100 / tongDon}" maxFractionDigits="1"/>%</c:when>
                        <c:otherwise>—</c:otherwise>
                    </c:choose></div>
                    <div class="stat-trend" style="color:var(--text-dim);">${donHoanThanh} hoàn thành · ${donHuy} đã hủy</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">check_circle</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Tổng đơn hàng</div>
                    <div class="stat-num">${tongDon}</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">inventory_2</span></div>
            </div>
        </div>

        <div class="home-grid">
            <div class="panel">
                <div class="panel-header"><div class="panel-title"><span class="material-symbols-outlined tb-icon-sm">show_chart</span> Doanh thu 7 ngày gần đây</div></div>
                <div class="panel-body"><div class="chart-box"><canvas id="revenueChart"></canvas></div></div>
            </div>

            <div class="panel">
                <div class="panel-header"><div class="panel-title"><span class="material-symbols-outlined tb-icon-sm">local_fire_department</span> Top món bán chạy</div></div>
                <div class="panel-body" style="padding-top:8px;">
                    <c:choose>
                        <c:when test="${empty topSanPhamBanChay}">
                            <div class="empty-state" style="padding:30px 10px;"><div class="e-icon">🍽️</div><div class="e-title">Chưa có dữ liệu bán hàng.</div></div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="sp" items="${topSanPhamBanChay}" varStatus="vs">
                                <div class="top-row">
                                    <span class="top-rank r${vs.index < 3 ? vs.index + 1 : 0}">${vs.index + 1}</span>
                                    <div class="top-info">
                                        <div class="top-name"><c:out value="${sp.productName}"/></div>
                                        <div class="top-sub">${sp.soLuongDaBan} lượt bán</div>
                                    </div>
                                    <div class="top-rev"><fmt:formatNumber value="${sp.doanhThu}" pattern="#,##0"/> đ</div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div>
                    <div class="stat-label">Doanh thu tuần này</div>
                    <div class="stat-num"><fmt:formatNumber value="${doanhThuTuanNay}" pattern="#,##0"/> đ</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">date_range</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Doanh thu tháng này</div>
                    <div class="stat-num"><fmt:formatNumber value="${doanhThuThangNay}" pattern="#,##0"/> đ</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">calendar_month</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Thực đơn</div>
                    <div class="stat-num">${tongSanPham}</div>
                    <div class="stat-trend" style="color:var(--text-dim);">sản phẩm · ${tongTopping} topping</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">menu_book</span></div>
            </div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <div class="panel-title"><span class="material-symbols-outlined tb-icon-sm">receipt_long</span> Đơn hàng gần đây</div>
                <a href="${pageContext.request.contextPath}/shop/bills" class="btn btn-ghost btn-sm">Xem tất cả</a>
            </div>
            <div class="panel-body" style="padding:0;">
                <div class="dash-table-wrap">
                    <table class="dash-table">
                        <thead>
                        <tr><th>Mã đơn</th><th>Khách hàng</th><th>Tổng tiền</th><th>Trạng thái</th><th>Ngày đặt</th></tr>
                        </thead>
                        <tbody>
                        <c:forEach var="order" items="${donHangGanDay}">
                            <tr>
                                <td><strong>#<c:out value="${order.id}"/></strong></td>
                                <td><c:out value="${order.receiverName}"/></td>
                                <td><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/> đ</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${order.staTus == 'DONE'}"><span class="badge badge-success">✓ Hoàn thành</span></c:when>
                                        <c:when test="${order.staTus == 'CANCELLED'}"><span class="badge badge-danger">✕ Đã hủy</span></c:when>
                                        <c:when test="${order.staTus == 'PENDING'}"><span class="badge badge-warning">⏳ Chờ xác nhận</span></c:when>
                                        <c:when test="${order.staTus == 'CONFIRMED'}"><span class="badge badge-info">Đang chuẩn bị</span></c:when>
                                        <c:when test="${order.staTus == 'READY_FOR_PICKUP'}"><span class="badge badge-success">Chờ shipper lấy</span></c:when>
                                        <c:when test="${order.staTus == 'SHIPPING'}"><span class="badge badge-warning">🚚 Đang giao</span></c:when>
                                        <c:otherwise><span class="badge badge-neutral"><c:out value="${order.staTus}"/></span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="white-space:nowrap;">${fn:substring(order.createdAt,11,16)} ${fn:substring(order.createdAt,8,10)}/${fn:substring(order.createdAt,5,7)}/${fn:substring(order.createdAt,0,4)}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty donHangGanDay}">
                            <tr><td colspan="5"><div class="empty-state"><div class="e-icon">📦</div><div class="e-title">Chưa có đơn hàng nào gần đây.</div></div></td></tr>
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
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    const ctx = document.getElementById('revenueChart');
    const labels = [
        <c:forEach var="d" items="${doanhThu7NgayQua}">'${d.ngay}',</c:forEach>
    ];
    const data = [
        <c:forEach var="d" items="${doanhThu7NgayQua}">${d.doanhThu},</c:forEach>
    ];
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Doanh thu (đ)',
                data: data,
                backgroundColor: '#E3250A',
                borderRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true } }
        }
    });

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
