<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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
    <title>Chi tiết yêu cầu shop - Super Admin</title>
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
    </style>
    <script>
        function askRejectReason(btn) {
            pobPrompt("Nhập lý do từ chối yêu cầu shop:").then(function(reason) {
                if (reason === null) return;
                if (reason.trim() === "") {
                    showToast("Vui lòng nhập lý do từ chối.", "error");
                    return;
                }
                document.getElementById("rejectionReason").value = reason.trim();
                btn.closest('form').submit();
            });
            return false;
        }
    </script>
</head>
<body class="dash-body admin-theme">

<c:set var="adminActive" value="/super-admin/shop-requests" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">storefront</span> Chi tiết yêu cầu duyệt Shop</h1>
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
        <div>
            <a href="${pageContext.request.contextPath}/super-admin/shop-requests" class="btn btn-ghost">← Quay lại danh sách</a>
        </div>

        <c:if test="${not empty loi}">
            <div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div>
        </c:if>

        <c:if test="${not empty shop}">
            <div>
                <h2 style="font-size:16px;font-weight:800;color:var(--text-main);margin-bottom:4px;">Yêu cầu đăng ký shop — Mã #<c:out value="${shop.id}"/></h2>
                <p style="font-size:13px;color:var(--text-muted);">Xem thông tin chi tiết cửa hàng yêu cầu mở shop.</p>
            </div>

            <div class="info-card" style="max-width:800px;">
                <h3>🏪 Thông tin đăng ký shop</h3>
                <div class="info-row"><div class="info-label">ID</div><div class="info-value"><c:out value="${shop.id}"/></div></div>
                <div class="info-row"><div class="info-label">Tên shop</div><div class="info-value"><c:out value="${shop.shopName}"/></div></div>
                <div class="info-row"><div class="info-label">Mô tả</div><div class="info-value"><c:out value="${shop.shopDescription}"/></div></div>
                <div class="info-row"><div class="info-label">Địa chỉ</div><div class="info-value"><c:out value="${shop.shopAddress}"/></div></div>
                <div class="info-row"><div class="info-label">Số điện thoại</div><div class="info-value"><c:out value="${shop.shopPhone}"/></div></div>
                <div class="info-row"><div class="info-label">Trạng thái</div><div class="info-value"><c:out value="${shop.status}"/></div></div>
                <div class="info-row"><div class="info-label">Ngày tạo</div><div class="info-value"><c:out value="${shop.createdAt}"/></div></div>
            </div>

            <div style="display:flex;gap:14px;flex-wrap:wrap;">
                <form action="${pageContext.request.contextPath}/super-admin/shop-requests" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="accept">
                    <input type="hidden" name="id" value="${shop.id}">
                    <button type="submit" class="btn btn-success" onclick="return confirm('Xác nhận DUYỆT cửa hàng [${shop.shopName}]?')">✓ Chấp nhận</button>
                </form>
                <form action="${pageContext.request.contextPath}/super-admin/shop-requests" method="post" onsubmit="return askRejectReason(this)">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="reject">
                    <input type="hidden" name="id" value="${shop.id}">
                    <input type="hidden" name="rejectionReason" id="rejectionReason">
                    <button type="submit" class="btn btn-danger">✕ Từ chối</button>
                </form>
            </div>
        </c:if>

        <c:if test="${empty shop}">
            <div class="empty-state">
                <div class="e-icon">🏪</div>
                <div class="e-title">Không tìm thấy thông tin yêu cầu mở shop.</div>
            </div>
        </c:if>
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
</body>
</html>
