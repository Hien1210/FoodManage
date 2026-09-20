<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="currentShop" value="${sessionScope.currentShop}" scope="request"/>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 2}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flash Sale - ${not empty currentShop.shopName ? currentShop.shopName : 'Cửa hàng'}</title>
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
        .flash-badge { display: inline-flex; align-items: center; gap: 5px; background: #fff3cd; color: #856404; border: 1px solid #ffc107; border-radius: 6px; padding: 2px 10px; font-size: 11.5px; font-weight: 700; }
        .flash-badge.active { background: #d1fae5; color: #065f46; border-color: #10b981; }
        .form-row { display: flex; gap: 12px; flex-wrap: wrap; }
        .form-row .form-group { flex: 1; min-width: 180px; }
        .stat-card.stat-alert { border-color: var(--primary); box-shadow: 0 0 0 2px var(--primary-light), var(--dash-shadow-sm); }
        .fs-layout { display: grid; grid-template-columns: minmax(0, 1fr) 380px; gap: 24px; align-items: start; }
        .fs-builder { position: sticky; top: 0; }
        .fs-list-head { margin-bottom: 14px; }
        .fs-list-head h3 { margin: 0; font-size: 18px; font-weight: 700; color: var(--text-main); display: flex; align-items: center; gap: 10px; }
        .fs-count { font-family: var(--font-family); font-size: 12px; font-weight: 700; padding: 2px 10px; border-radius: 999px; background: var(--primary-light); color: var(--primary); }
        .fs-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-left: 4px solid var(--border-color); border-radius: 16px; padding: 16px 18px; margin-bottom: 14px; box-shadow: var(--dash-shadow-sm); display: flex; flex-direction: column; gap: 12px; transition: transform .18s, box-shadow .18s; }
        .fs-card:hover { transform: translateY(-3px); box-shadow: var(--dash-shadow-md); }
        .fs-card.live { border-left-color: var(--success); }
        .fs-card.soon { border-left-color: var(--warning); }
        .fs-card.ended { opacity: .75; }
        .fs-card-top { display: flex; align-items: flex-start; justify-content: space-between; gap: 10px; }
        .fs-name { font-family: var(--font-display); font-weight: 700; font-size: 16.5px; color: var(--text-main); }
        .fs-size { font-size: 12px; color: var(--text-dim); margin-top: 2px; }
        .fs-price-row { display: flex; align-items: baseline; gap: 10px; flex-wrap: wrap; }
        .fs-sale { font-family: var(--font-display); font-weight: 700; font-size: 24px; color: var(--primary); }
        .fs-orig { font-size: 14px; color: var(--text-dim); text-decoration: line-through; }
        .fs-off { font-size: 12px; font-weight: 800; color: #fff; padding: 2px 9px; border-radius: 999px; background: var(--brand-gradient); }
        .fs-card-foot { display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; padding-top: 10px; border-top: 1px dashed var(--border-color); }
        .fs-time { display: flex; align-items: center; gap: 6px; font-size: 12.5px; color: var(--text-muted); }
        .fs-time .material-symbols-outlined { font-size: 18px; color: var(--text-dim); }
        .fs-card-foot .btn { gap: 4px; }
        .fs-card-foot .material-symbols-outlined { font-size: 17px; }
        .tb-icon-sm { font-size: 22px; color: var(--primary); }
        @media (max-width: 1180px) {
            .fs-layout { grid-template-columns: 1fr; }
            .fs-builder { position: static; order: -1; }
        }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="/shop/flash-sale" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">bolt</span> Flash Sale</h1>
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
        <c:if test="${param.saved eq '1'}">
            <div class="alert alert-success">✅ Đã tạo Flash Sale thành công.</div>
        </c:if>
        <c:if test="${param.deleted eq '1'}">
            <div class="alert alert-danger">🗑️ Đã xóa Flash Sale.</div>
        </c:if>
        <c:if test="${param.error eq 'invalid'}">
            <div class="alert alert-danger">⚠️ Thông tin không hợp lệ (giá bán phải > 0, thời gian kết thúc phải sau thời gian bắt đầu).</div>
        </c:if>

        <%-- Thống kê nhanh theo thời điểm hiện tại (model FlashSale: isCurrentlyActive / isUpcoming / isEnded) --%>
        <c:set var="fsLive" value="0"/><c:set var="fsUpcoming" value="0"/><c:set var="fsEnded" value="0"/>
        <c:forEach items="${flashSales}" var="f0">
            <c:choose>
                <c:when test="${f0.currentlyActive}"><c:set var="fsLive" value="${fsLive + 1}"/></c:when>
                <c:when test="${f0.upcoming}"><c:set var="fsUpcoming" value="${fsUpcoming + 1}"/></c:when>
                <c:when test="${f0.ended}"><c:set var="fsEnded" value="${fsEnded + 1}"/></c:when>
            </c:choose>
        </c:forEach>

        <div class="stats-grid">
            <div class="stat-card ${fsLive > 0 ? 'stat-alert' : ''}">
                <div>
                    <div class="stat-label">Đang diễn ra</div>
                    <div class="stat-num">${fsLive}</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">bolt</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Sắp diễn ra</div>
                    <div class="stat-num">${fsUpcoming}</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">schedule</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Đã kết thúc</div>
                    <div class="stat-num">${fsEnded}</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">event_available</span></div>
            </div>
        </div>

        <div class="fs-layout">
            <%-- Danh sách chương trình --%>
            <section class="fs-list-col">
                <div class="fs-list-head"><h3>Chương trình Flash Sale <span class="fs-count">${fn:length(flashSales)}</span></h3></div>
                <c:choose>
                    <c:when test="${empty flashSales}">
                        <div class="empty-state">
                            <div class="e-icon">⚡</div>
                            <div class="e-title">Chưa có Flash Sale nào</div>
                            <div class="e-sub">Tạo chương trình đầu tiên ở khung bên cạnh.</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${flashSales}" var="fs">
                            <c:set var="stCls" value="${fs.currentlyActive ? 'live' : (fs.upcoming ? 'soon' : 'ended')}"/>
                            <div class="fs-card ${stCls}">
                                <div class="fs-card-top">
                                    <div>
                                        <div class="fs-name"><c:out value="${fs.productName}"/></div>
                                        <div class="fs-size">Size: <c:out value="${fs.sizeName}"/></div>
                                    </div>
                                    <c:choose>
                                        <c:when test="${fs.currentlyActive}"><span class="badge badge-success"><span class="badge-dot pulse"></span>Đang diễn ra</span></c:when>
                                        <c:when test="${fs.upcoming}"><span class="badge badge-warning">Sắp diễn ra</span></c:when>
                                        <c:when test="${fs.ended}"><span class="badge badge-neutral">Đã kết thúc</span></c:when>
                                        <c:otherwise><span class="badge badge-neutral">Không hoạt động</span></c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="fs-price-row">
                                    <span class="fs-sale"><fmt:formatNumber value="${fs.salePrice}" type="number" maxFractionDigits="0"/>đ</span>
                                    <span class="fs-orig"><fmt:formatNumber value="${fs.originalPrice}" type="number" maxFractionDigits="0"/>đ</span>
                                    <c:if test="${fs.originalPrice > fs.salePrice and fs.originalPrice > 0}">
                                        <span class="fs-off">-<fmt:formatNumber value="${(fs.originalPrice - fs.salePrice) * 100 / fs.originalPrice}" type="number" maxFractionDigits="0"/>%</span>
                                    </c:if>
                                </div>
                                <div class="fs-card-foot">
                                    <div class="fs-time">
                                        <span class="material-symbols-outlined">schedule</span>
                                        ${fn:substring(fs.startTime,11,16)} ${fn:substring(fs.startTime,8,10)}/${fn:substring(fs.startTime,5,7)}
                                        →
                                        ${fn:substring(fs.endTime,11,16)} ${fn:substring(fs.endTime,8,10)}/${fn:substring(fs.endTime,5,7)}
                                    </div>
                                    <form method="post" action="${pageContext.request.contextPath}/shop/flash-sale" style="display:inline"
                                          onsubmit="return pobConfirmDelete(event, this, 'Bạn có chắc chắn muốn xóa Flash Sale của <strong>${fn:escapeXml(fs.productName)} (${fn:escapeXml(fs.sizeName)})</strong> không?', 'Xóa Flash Sale')">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="flashSaleId" value="${fs.id}">
                                        <button type="submit" class="btn btn-danger-outline btn-sm"><span class="material-symbols-outlined">delete</span> Xóa</button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </section>

            <%-- Tạo Flash Sale mới --%>
            <aside class="fs-builder dash-card">
                <div class="dash-card-header"><h3><span class="material-symbols-outlined tb-icon-sm">bolt</span> Tạo Flash Sale mới</h3></div>
                <div class="dash-card-body">
                    <form method="post" action="${pageContext.request.contextPath}/shop/flash-sale">
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <div class="form-group">
                            <label class="form-label">Sản phẩm &amp; size *</label>
                            <select name="productSizeId" class="dash-input" required>
                                <option value="">-- Chọn sản phẩm + size --</option>
                                <c:forEach items="${allSizes}" var="ps">
                                    <option value="${ps.id}">${fn:escapeXml(productNameById[ps.productId])} — ${fn:escapeXml(ps.sizeName)} (Giá gốc: <fmt:formatNumber value="${ps.price}" type="number" maxFractionDigits="0"/>đ)</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Giá Flash Sale (đ) *</label>
                            <input type="text" class="dash-input" name="salePrice" data-money="true" required placeholder="VD: 39.000">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Bắt đầu *</label>
                            <input type="datetime-local" class="dash-input" name="startTime" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Kết thúc *</label>
                            <input type="datetime-local" class="dash-input" name="endTime" required>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">Tạo Flash Sale</button>
                    </form>
                </div>
            </aside>
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

<script src="${pageContext.request.contextPath}/assets/js/money-format.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script>
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
</script>
</body>
</html>
