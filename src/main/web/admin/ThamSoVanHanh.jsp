<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 1}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Tham số vận hành - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        :root { --primary-hover: var(--primary-dark); --purple: #8b5cf6; }

        .panel { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; animation: fadeUp 0.35s ease both; padding: 22px; margin-bottom: 20px; }
        .panel-title { font-size: 14px; font-weight: bold; text-transform: uppercase; border-left: 4px solid var(--primary); padding-left: 10px; color: var(--text-main); margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; }

        .form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 18px 24px; }
        .form-field label { display: block; font-size: 12.5px; font-weight: 700; color: var(--text-muted); margin-bottom: 8px; }
        .form-field .input-wrap { position: relative; }
        .form-field input[type="number"], .form-field input[data-money="true"] {
            width: 100%; padding: 10px 14px; border-radius: 8px; border: 1px solid var(--border-color);
            background: var(--bg-input); color: var(--text-main); font-size: 14px; font-weight: 600;
        }
        .form-field input[type="number"]:focus, .form-field input[data-money="true"]:focus { outline: none; border-color: var(--primary); }
        .form-field .unit { position: absolute; right: 14px; top: 50%; transform: translateY(-50%); font-size: 12px; color: var(--text-dim); font-weight: 700; pointer-events: none; }

        .save-bar { display: flex; justify-content: flex-end; margin-top: 4px; }
        .btn-save { background: var(--primary); color: #ffffff; border: none; padding: 12px 28px; border-radius: 8px; font-size: 14px; font-weight: 800; cursor: pointer; transition: 0.15s; }
        .btn-save:hover { background: var(--primary-hover); }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
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
</head>
<body class="dash-body admin-theme">
<c:set var="adminActive" value="/admin/tham-so-van-hanh" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">tune</span> Tham số vận hành</h1>
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
        <form method="post" action="${pageContext.request.contextPath}/admin/tham-so-van-hanh">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

            <div class="panel">
                <div class="panel-title">💰 Cấu hình Tài chính</div>
                <div class="form-grid">
                    <div class="form-field">
                        <label>Phí hoa hồng thu từ Shop (%)</label>
                        <div class="input-wrap">
                            <input type="number" step="0.01" min="0" max="100" name="commissionPercent" value="${config.commissionPercent}" required>
                            <span class="unit">%</span>
                        </div>
                    </div>
                    <div class="form-field">
                        <label>Phí cố định trên mỗi đơn (đ)</label>
                        <div class="input-wrap">
                            <input type="text" name="fixedFeePerOrder" data-money="true" value="${config.fixedFeePerOrder}" required>
                            <span class="unit">đ</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="panel">
                <div class="panel-title">🛵 Cấu hình Giao hàng</div>
                <div class="form-grid">
                    <div class="form-field">
                        <label>Phí Ship 2km đầu tiên (đ)</label>
                        <div class="input-wrap">
                            <input type="text" name="shippingFeeFirst2Km" data-money="true" value="${config.shippingFeeFirst2Km}" required>
                            <span class="unit">đ</span>
                        </div>
                    </div>
                    <div class="form-field">
                        <label>Phí Ship mỗi km tiếp theo (đ)</label>
                        <div class="input-wrap">
                            <input type="text" name="shippingFeePerKm" data-money="true" value="${config.shippingFeePerKm}" required>
                            <span class="unit">đ</span>
                        </div>
                    </div>
                    <div class="form-field">
                        <label>Bán kính giao hàng tối đa (km)</label>
                        <div class="input-wrap">
                            <input type="number" step="0.1" min="0" name="maxDeliveryRadiusKm" value="${config.maxDeliveryRadiusKm}" required>
                            <span class="unit">km</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="panel">
                <div class="panel-title">⏱️ Cấu hình Thời gian</div>
                <div class="form-grid">
                    <div class="form-field">
                        <label>Thời gian Shop phải nhận đơn (Phút)</label>
                        <div class="input-wrap">
                            <input type="number" step="1" min="1" name="shopAcceptOrderMinutes" value="${config.shopAcceptOrderMinutes}" required>
                            <span class="unit">phút</span>
                        </div>
                    </div>
                    <div class="form-field">
                        <label>Thời gian tự động hoàn thành đơn (Giờ)</label>
                        <div class="input-wrap">
                            <input type="number" step="1" min="1" name="autoCompleteOrderHours" value="${config.autoCompleteOrderHours}" required>
                            <span class="unit">giờ</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PayOS hệ thống (escrow) -->
            <div class="panel" style="margin-top:24px;">
                <div class="panel-title">
                    💳 PayOS Hệ thống (Tài khoản giữ tiền hộ)
                    <span style="font-size:11px;font-weight:400;color:var(--text-muted);">Dùng cho đặt hàng online — tiền khách vào tài khoản này, admin giải ngân cho shop/shipper</span>
                </div>
                <div class="form-grid">
                    <div class="form-field">
                        <label>Client ID</label>
                        <div class="input-wrap">
                            <input type="text" name="payosClientId" value="${config.payosClientId}" placeholder="Nhập Client ID từ PayOS Dashboard" style="width:100%;padding:10px 14px;border:1.5px solid var(--border);border-radius:8px;background:var(--bg-input);color:var(--text-main);font-size:14px;">
                        </div>
                    </div>
                    <div class="form-field">
                        <label>API Key</label>
                        <div class="input-wrap">
                            <input type="text" name="payosApiKey" value="${config.payosApiKey}" placeholder="Nhập API Key từ PayOS Dashboard" style="width:100%;padding:10px 14px;border:1.5px solid var(--border);border-radius:8px;background:var(--bg-input);color:var(--text-main);font-size:14px;">
                        </div>
                    </div>
                    <div class="form-field">
                        <label>Checksum Key</label>
                        <div class="input-wrap">
                            <input type="text" name="payosChecksumKey" value="${config.payosChecksumKey}" placeholder="Nhập Checksum Key từ PayOS Dashboard" style="width:100%;padding:10px 14px;border:1.5px solid var(--border);border-radius:8px;background:var(--bg-input);color:var(--text-main);font-size:14px;">
                        </div>
                    </div>
                </div>
            </div>

            <div class="save-bar">
                <button type="submit" class="btn-save">💾 Lưu thay đổi</button>
            </div>
        </form>
    </div>
</main>

<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${fn:escapeXml(sessionScope.account.userName)}</div>
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
<script src="${pageContext.request.contextPath}/assets/js/money-format.js"></script>
<script>
    (function () {
        const params = new URLSearchParams(window.location.search);
        const success = params.get('success');
        if (!success || !window.showToast) return;
        if (success === 'saved') window.showToast('success', 'Đã lưu tham số vận hành.');
        else if (success === 'failed') window.showToast('error', 'Lưu thất bại, vui lòng thử lại.');
        else if (success === 'invalid') window.showToast('error', params.get('msg') || 'Giá trị nhập không hợp lệ.');
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
<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
</body>
</html>
