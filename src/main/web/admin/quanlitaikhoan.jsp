<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 1}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Quản lý tài khoản - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        /* Avatar dropdown (topbar) */
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

        /* Toolbar tìm kiếm tài khoản */
        .toolbar { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; flex-wrap: wrap; }

        /* Dropdown hành động (⋮) theo từng dòng bảng */
        .action-wrap { position: relative; display: inline-block; }
        .dropdown-menu { display: none; position: absolute; right: 0; top: 36px; background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 8px; box-shadow: var(--dash-shadow-md); min-width: 180px; z-index: 100; overflow: hidden; }
        .dropdown-menu.open { display: block; }
        .dropdown-item { display: flex; align-items: center; gap: 10px; padding: 11px 16px; font-size: 13px; color: var(--text-muted); cursor: pointer; transition: background .15s; border: none; background: none; width: 100%; text-align: left; font-family: var(--font-family); }
        .dropdown-item:hover { background: var(--bg-hover); color: var(--text-main); }
        .dropdown-item.edit:hover { color: var(--info); }
        .dropdown-item.soft-del:hover { color: var(--warning); }
        .dropdown-item.hard-del:hover { color: var(--danger); }

        /* Modal xác nhận xoá tạm thời / vĩnh viễn */
        .modal-icon { font-size: 36px; margin-bottom: 14px; }
        .modal-title { font-size: 17px; font-weight: 700; color: var(--text-main); margin-bottom: 8px; }
        .modal-desc { font-size: 13px; color: var(--text-muted); line-height: 1.6; margin-bottom: 20px; }
        .modal-desc strong { color: var(--danger); }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; }

        /* Toast thông báo kết quả */
        .toast { position: fixed; bottom: 24px; right: 24px; padding: 14px 20px; border-radius: 8px; font-size: 13px; font-weight: 600; box-shadow: var(--dash-shadow-md); z-index: 999; display: none; }
        .toast.success { background: var(--success-light); border: 1px solid var(--success); color: var(--success-dark); }
        .toast.error { background: var(--danger-light); border: 1px solid var(--danger); color: var(--danger-dark); }
    </style>
</head>
<body class="dash-body admin-theme">

<c:set var="adminActive" value="/quanlitaikhoan" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">manage_accounts</span> Quản lý tài khoản</h1>
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

        <%-- THÔNG BÁO --%>
        <c:if test="${not empty loi}">
            <div class="alert alert-danger">⚠️ ${loi}</div>
        </c:if>

        <!-- BẢNG DANH SÁCH TÀI KHOẢN -->
        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">Danh sách tài khoản</div>
            </div>
            <div class="panel-body">

                <!-- Toolbar tìm kiếm + thêm -->
                <div class="toolbar">
                    <form method="post" action="${pageContext.request.contextPath}/quanlitaikhoan" style="display:flex;gap:8px;flex:1;">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="action" value="search"/>
                        <input type="text" class="dash-input" name="searchKeyword"
                               placeholder="🔍 Tìm theo username hoặc email..."
                               value="${searchKeyword}"/>
                        <button type="submit" class="btn btn-primary">Tìm kiếm</button>
                    </form>
                    <a href="${pageContext.request.contextPath}/quanlitaikhoan" class="btn btn-outline">↺ Làm mới</a>
                </div>

                <div class="dash-table-wrap">
                    <table class="dash-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Username</th>
                                <th>Họ tên</th>
                                <th>Email</th>
                                <th>SĐT</th>
                                <th>Vai trò</th>
                                <th style="text-align:center;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty danhsach}">
                                    <tr>
                                        <td colspan="7">
                                            <div class="empty-state">
                                                <div class="e-icon">👤</div>
                                                <div class="e-title">Không có tài khoản nào</div>
                                            </div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="acc" items="${danhsach}">
                                        <tr>
                                            <td style="color:var(--text-dim);">#${acc.id}</td>
                                            <td style="font-weight:600;">${acc.userName}</td>
                                            <td>${acc.fullName}</td>
                                            <td style="color:var(--text-muted);">${acc.email}</td>
                                            <td style="color:var(--text-muted);">${acc.phone}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${acc.roleId == 1}"><span class="badge badge-info">SUPER ADMIN</span></c:when>
                                                    <c:when test="${acc.roleId == 2}"><span class="badge badge-info">SHOP</span></c:when>
                                                    <c:when test="${acc.roleId == 3}"><span class="badge badge-neutral">KHÁCH HÀNG</span></c:when>
                                                    <c:when test="${acc.roleId == 4}"><span class="badge badge-info">SHIPPER</span></c:when>
                                                    <c:otherwise><span class="badge badge-neutral">${acc.roleId}</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align:center;">
                                                <div class="action-wrap">
                                                    <button class="btn btn-sm btn-ghost" onclick="toggleDropdown(this)" title="Tùy chọn">⋮</button>
                                                    <div class="dropdown-menu">
                                                        <button class="dropdown-item view-detail" style="color:var(--primary);"
                                                                onclick="openViewModal(${acc.id}, '${fn:escapeXml(acc.userName)}', '${fn:escapeXml(acc.fullName)}', '${fn:escapeXml(acc.email)}', '${fn:escapeXml(acc.phone)}', '${fn:escapeXml(acc.avatarUrl)}', ${acc.roleId}, ${acc.deleted})">
                                                            👁️ Xem thông tin (Chỉ xem)
                                                        </button>
                                                        <c:if test="${acc.id != sessionScope.account.id && acc.roleId != 1}">
                                                            <button class="dropdown-item soft-del"
                                                                    onclick="openSoftModal(${acc.id}, '${fn:escapeXml(acc.userName)}')">
                                                                🗂️ Xóa tạm thời
                                                            </button>
                                                            <button class="dropdown-item hard-del"
                                                                    onclick="openHardModal(${acc.id}, '${fn:escapeXml(acc.userName)}')">
                                                                🗑️ Xóa vĩnh viễn
                                                            </button>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</main>

<!-- MODAL XÓA TẠM THỜI -->
<div class="pob-modal-overlay" id="modalSoft">
    <div class="pob-modal-box">
        <div style="padding:28px;">
            <div class="modal-icon">🗂️</div>
            <div class="modal-title">Xóa tạm thời tài khoản?</div>
            <div class="modal-desc">
                Tài khoản <strong id="softName"></strong> sẽ bị ẩn khỏi hệ thống nhưng vẫn còn trong Database.<br>
                Có thể khôi phục lại sau.
            </div>
            <div class="modal-actions">
                <button type="button" class="btn btn-ghost" onclick="closeModal('modalSoft')">Hủy</button>
                <form method="post" action="${pageContext.request.contextPath}/quanlitaikhoan" style="margin:0">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="delete"/>
                    <input type="hidden" name="deleteType" value="soft"/>
                    <input type="hidden" name="id" id="softId"/>
                    <button type="submit" class="btn btn-warning">🗂️ Xóa tạm thời</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- MODAL XÓA VĨNH VIỄN -->
<div class="pob-modal-overlay" id="modalHard">
    <div class="pob-modal-box">
        <div style="padding:28px;">
            <div class="modal-icon">⚠️</div>
            <div class="modal-title">Xóa vĩnh viễn tài khoản?</div>
            <div class="modal-desc">
                Tài khoản <strong id="hardName"></strong> sẽ bị <strong>xóa hoàn toàn khỏi Database</strong>.<br>
                Hành động này <strong>không thể hoàn tác</strong>. Mọi dữ liệu liên quan sẽ bị mất.
            </div>
            <div class="modal-actions">
                <button type="button" class="btn btn-ghost" onclick="closeModal('modalHard')">Hủy</button>
                <form method="post" action="${pageContext.request.contextPath}/quanlitaikhoan" style="margin:0">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="delete"/>
                    <input type="hidden" name="deleteType" value="hard"/>
                    <input type="hidden" name="id" id="hardId"/>
                    <button type="submit" class="btn btn-danger">🗑️ Xóa vĩnh viễn</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- MODAL SỬA TÀI KHOẢN -->
<div class="pob-modal-overlay" id="modalEdit">
    <div class="pob-modal-box">
        <div style="padding:28px;">
            <div class="modal-icon">✏️</div>
            <div class="modal-title">Sửa tài khoản</div>
            <form method="post" action="${pageContext.request.contextPath}/quanlitaikhoan">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="update"/>
                <input type="hidden" name="id" id="editId"/>
                <input type="hidden" name="avatarurl" id="editAvatarUrl"/>

                <div class="form-group">
                    <label class="form-label">Username <span class="required">*</span></label>
                    <input type="text" class="form-control" name="username" id="editUsername" required/>
                </div>
                <div class="form-group">
                    <label class="form-label">Họ tên</label>
                    <input type="text" class="form-control" name="fullname" id="editFullname"/>
                </div>
                <div class="form-group">
                    <label class="form-label">Email <span class="required">*</span></label>
                    <input type="email" class="form-control" name="email" id="editEmail" required/>
                </div>
                <div class="form-group">
                    <label class="form-label">Số điện thoại</label>
                    <input type="text" class="form-control" name="phone" id="editPhone"/>
                </div>
                <div class="form-group">
                    <label class="form-label">Vai trò <span class="required">*</span></label>
                    <select class="form-select" name="roleid" id="editRoleId" required>
                        <option value="1">Super Admin</option>
                        <option value="2">Shop</option>
                        <option value="3">Khách hàng</option>
                        <option value="4">Shipper</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Mật khẩu mới</label>
                    <input type="password" class="form-control" name="password" id="editPassword"
                           placeholder="Để trống nếu không đổi mật khẩu" autocomplete="new-password"/>
                </div>

                <div class="modal-actions" style="margin-top:20px;">
                    <button type="button" class="btn btn-ghost" onclick="closeModal('modalEdit')">Hủy</button>
                    <button type="submit" class="btn btn-primary">💾 Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- MODAL XEM THÔNG TIN TÀI KHOẢN (CHỈ XEM / READ-ONLY) -->
<div class="pob-modal-overlay" id="modalViewDetail">
    <div class="pob-modal-box" style="max-width: 660px; max-height: 90vh; overflow-y: auto;">
        <div style="padding:28px;">
            <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:16px;border-bottom:1px solid var(--border-color);padding-bottom:14px;">
                <div style="display:flex;align-items:center;gap:12px;">
                    <div class="modal-icon" style="margin:0;font-size:28px;">👤</div>
                    <div>
                        <div class="modal-title" style="margin:0;">Thông Tin Chi Tiết Tài Khoản</div>
                        <div style="font-size:12px;color:var(--text-muted);margin-top:2px;">
                            <span>Chế độ: </span>
                            <span class="badge badge-neutral" style="font-size:10px;font-weight:800;background:var(--bg-input);">👁️ CHỈ XEM (READ-ONLY)</span>
                        </div>
                    </div>
                </div>
                <button type="button" class="btn btn-ghost" onclick="closeModal('modalViewDetail')" style="font-size:18px;">&times;</button>
            </div>

            <!-- Profile Overview Header Card -->
            <div style="background:var(--bg-input);border:1px solid var(--border-color);border-radius:12px;padding:16px;display:flex;align-items:center;gap:16px;margin-bottom:20px;">
                <div id="viewAvatarCircle" style="width:52px;height:52px;border-radius:50%;background:var(--primary-light);color:var(--primary);font-size:20px;font-weight:800;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                    U
                </div>
                <div style="flex:1;">
                    <div style="font-size:16px;font-weight:800;color:var(--text-main);" id="viewHeaderName">Username</div>
                    <div style="font-size:12.5px;color:var(--text-muted);margin-top:2px;" id="viewHeaderEmail">email@example.com</div>
                </div>
                <div id="viewHeaderRoleBadge">
                    <span class="badge badge-info">ROLE</span>
                </div>
            </div>

            <!-- Details Form (Read-only view fields) -->
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:20px;">
                <div>
                    <label style="font-size:11.5px;font-weight:700;color:var(--text-muted);text-transform:uppercase;">ID Tài Khoản</label>
                    <div class="dash-input" style="background:var(--bg-panel);font-weight:700;" id="viewAccountId">—</div>
                </div>
                <div>
                    <label style="font-size:11.5px;font-weight:700;color:var(--text-muted);text-transform:uppercase;">Tên Đăng Nhập</label>
                    <div class="dash-input" style="background:var(--bg-panel);font-weight:700;" id="viewUsername">—</div>
                </div>
                <div>
                    <label style="font-size:11.5px;font-weight:700;color:var(--text-muted);text-transform:uppercase;">Họ Và Tên</label>
                    <div class="dash-input" style="background:var(--bg-panel);" id="viewFullname">—</div>
                </div>
                <div>
                    <label style="font-size:11.5px;font-weight:700;color:var(--text-muted);text-transform:uppercase;">Email</label>
                    <div class="dash-input" style="background:var(--bg-panel);" id="viewEmail">—</div>
                </div>
                <div>
                    <label style="font-size:11.5px;font-weight:700;color:var(--text-muted);text-transform:uppercase;">Số Điện Thoại</label>
                    <div class="dash-input" style="background:var(--bg-panel);" id="viewPhone">—</div>
                </div>
                <div>
                    <label style="font-size:11.5px;font-weight:700;color:var(--text-muted);text-transform:uppercase;">Trạng Thái Tài Khoản</label>
                    <div class="dash-input" style="background:var(--bg-panel);" id="viewStatus">—</div>
                </div>
            </div>

            <!-- Role-Specific Profile Section (Shop or Shipper) -->
            <div id="viewRoleExtraSection" style="display:none;border-top:1px dashed var(--border-color);padding-top:16px;margin-top:10px;">
                <div style="font-size:13px;font-weight:800;color:var(--primary);margin-bottom:12px;display:flex;align-items:center;gap:6px;" id="viewExtraTitle">
                    ℹ️ Thông tin hồ sơ vai trò
                </div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;" id="viewExtraGrid">
                    <!-- Dynamic role specific info -->
                </div>
            </div>

            <div class="modal-actions" style="margin-top:24px;">
                <button type="button" class="btn btn-primary" onclick="closeModal('modalViewDetail')">Đóng (Chỉ Xem)</button>
            </div>
        </div>
    </div>
</div>

<!-- TOAST -->
<div class="toast success" id="toastEl"></div>

<script>
window.SHOP_PROFILES = {};
window.SHIPPER_PROFILES = {};
window.USER_PROFILES = {};

<c:forEach var="entry" items="${shopProfilesMap}">
window.SHOP_PROFILES[${entry.key}] = {
    shopName: '${fn:escapeXml(entry.value.shopName)}',
    shopAddress: '${fn:escapeXml(entry.value.shopAddress)}',
    shopPhone: '${fn:escapeXml(entry.value.shopPhone)}',
    shopDescription: '${fn:escapeXml(entry.value.shopDescription)}',
    status: '${fn:escapeXml(entry.value.status)}'
};
</c:forEach>

<c:forEach var="entry" items="${shipperProfilesMap}">
window.SHIPPER_PROFILES[${entry.key}] = {
    cccd: '${fn:escapeXml(entry.value.cccd)}',
    licenseNumber: '${fn:escapeXml(entry.value.licenseNumber)}',
    vehiclePlate: '${fn:escapeXml(entry.value.vehiclePlate)}',
    vehicleModel: '${fn:escapeXml(entry.value.vehicleModel)}',
    bankName: '${fn:escapeXml(entry.value.bankName)}',
    bankAccount: '${fn:escapeXml(entry.value.bankAccount)}',
    verificationStatus: '${fn:escapeXml(entry.value.verificationStatus)}',
    idCardFrontUrl: '${fn:escapeXml(entry.value.idCardFrontUrl)}',
    idCardBackUrl: '${fn:escapeXml(entry.value.idCardBackUrl)}',
    licenseFrontUrl: '${fn:escapeXml(entry.value.licenseFrontUrl)}',
    licenseBackUrl: '${fn:escapeXml(entry.value.licenseBackUrl)}'
};
</c:forEach>

<c:forEach var="entry" items="${userProfilesMap}">
window.USER_PROFILES[${entry.key}] = {
    dateOfBirth: '${entry.value.dateOfBirth}',
    gender: '${fn:escapeXml(entry.value.gender)}'
};
</c:forEach>
</script>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pixel-cat.js"></script>
<script>
    // ─── UI helper functions ───────────────────────────────────
    function field(label, val) {
        return '<div><label style="font-size:11px;color:var(--text-muted);font-weight:700;letter-spacing:.5px;">' + label + '</label>'
             + '<div class="dash-input" style="background:var(--bg-panel);margin-top:4px;">' + (val || '\u2014') + '</div></div>';
    }
    function fieldFull(label, val) {
        return '<div style="grid-column:span 2;"><label style="font-size:11px;color:var(--text-muted);font-weight:700;letter-spacing:.5px;">' + label + '</label>'
             + '<div class="dash-input" style="background:var(--bg-panel);margin-top:4px;">' + (val || '\u2014') + '</div></div>';
    }
    function statusBadge(s) {
        if (!s) return '\u2014';
        var cls = (s === 'APPROVED' || s === 'VERIFIED') ? 'badge-success'
                : (s === 'PENDING') ? 'badge-warning'
                : (s === 'REJECTED') ? 'badge-danger' : 'badge-neutral';
        return '<span class="badge ' + cls + '">' + s + '</span>';
    }
    function genderLabel(g) {
        if (!g) return '\u2014';
        if (g === 'MALE') return '\ud83d\udc68 Nam';
        if (g === 'FEMALE') return '\ud83d\udc69 N\u1eef';
        return '\ud83e\uddd1 Kh\u00e1c';
    }
    function imgCard(caption, url) {
        return '<div style="border:1px solid var(--border-color);border-radius:8px;overflow:hidden;background:var(--bg-input);cursor:pointer;" onclick="openLightbox(\'' + url + '\', \'' + caption + '\')" title="Click \u0111\u1ec3 xem to\u00e0n m\u00e0n h\u00ecnh">'
             + '<img src="' + url + '" alt="' + caption + '" style="width:100%;height:120px;object-fit:cover;display:block;" onerror="this.parentElement.innerHTML=\'<div style=padding:20px;text-align:center;color:var(--text-dim);font-size:11px>\u274c Kh\u00f4ng t\u1ea3i \u0111\u01b0\u1ee3c \u1ea3nh</div>\'"/>'
             + '<div style="font-size:10.5px;font-weight:700;color:var(--text-muted);text-align:center;padding:6px 4px;background:var(--bg-panel);border-top:1px solid var(--border-color);">' + caption + ' <span style="opacity:.5;font-size:9px;">\ud83d\udd0d</span></div>'
             + '</div>';
    }
    // ────────────────────────────────────────────────────────────
    // Modal xem thông tin chi tiết (Chỉ xem)
    function openViewModal(id, username, fullname, email, phone, avatarUrl, roleId, isDeleted) {
        document.querySelectorAll('.dropdown-menu.open').forEach(m => m.classList.remove('open'));
        document.getElementById('viewAccountId').innerText = '#' + id;
        document.getElementById('viewUsername').innerText = username || '—';
        document.getElementById('viewFullname').innerText = fullname || '—';
        document.getElementById('viewEmail').innerText = email || '—';
        document.getElementById('viewPhone').innerText = phone || '—';
        document.getElementById('viewHeaderName').innerText = fullname || username;
        document.getElementById('viewHeaderEmail').innerText = email || '—';

        var avatarDiv = document.getElementById('viewAvatarCircle');
        if (avatarUrl) {
            avatarDiv.innerHTML = '<img src="' + avatarUrl + '" style="width:100%;height:100%;border-radius:50%;object-fit:cover;"/>';
        } else {
            avatarDiv.innerText = (username || 'U').substring(0, 2).toUpperCase();
        }

        var roleBadge = document.getElementById('viewHeaderRoleBadge');
        var roleText = '';
        if (roleId == 1) { roleText = '<span class="badge badge-info">SUPER ADMIN</span>'; }
        else if (roleId == 2) { roleText = '<span class="badge badge-info">SHOP</span>'; }
        else if (roleId == 3) { roleText = '<span class="badge badge-neutral">KHÁCH HÀNG</span>'; }
        else if (roleId == 4) { roleText = '<span class="badge badge-info">SHIPPER</span>'; }
        else { roleText = '<span class="badge badge-neutral">Role #' + roleId + '</span>'; }
        roleBadge.innerHTML = roleText;

        var statusDiv = document.getElementById('viewStatus');
        if (isDeleted) {
            statusDiv.innerHTML = '<span style="color:var(--danger);font-weight:700;">🔴 Đã bị khóa / Xóa tạm thời</span>';
        } else {
            statusDiv.innerHTML = '<span style="color:var(--success);font-weight:700;">🟢 Đang hoạt động</span>';
        }

        // Thông tin hồ sơ vai trò đặc thù (Shop / Shipper)
        var extraSection = document.getElementById('viewRoleExtraSection');
        var extraTitle = document.getElementById('viewExtraTitle');
        var extraGrid = document.getElementById('viewExtraGrid');

        if (roleId == 2 && window.SHOP_PROFILES && window.SHOP_PROFILES[id]) {
            var s = window.SHOP_PROFILES[id];
            extraSection.style.display = 'block';
            extraTitle.innerHTML = '🏪 Hồ sơ Cửa Hàng (Quán)';
            extraGrid.innerHTML =
                field('TÊN CỬA HÀNG', s.shopName) +
                field('SĐT CỬA HÀNG', s.shopPhone) +
                fieldFull('ĐỊA CHỈ CỬA HÀNG', s.shopAddress) +
                field('TRẠNG THÁI DUYỆT QUÁN', statusBadge(s.status));
        } else if (roleId == 4 && window.SHIPPER_PROFILES && window.SHIPPER_PROFILES[id]) {
            var sp = window.SHIPPER_PROFILES[id];
            extraSection.style.display = 'block';
            extraTitle.innerHTML = '🛵 Hồ sơ Tài Xế (Shipper)';
            // Fields text
            extraGrid.innerHTML =
                field('SỐ CCCD', sp.cccd) +
                field('BẰNG LÁI XE (GPLX)', sp.licenseNumber) +
                field('BIỂN SỐ XE', sp.vehiclePlate) +
                field('LOẠI XE', sp.vehicleModel) +
                fieldFull('TÀI KHOẢN NGÂN HÀNG', sp.bankName ? (sp.bankName + ' &nbsp;—&nbsp; ' + sp.bankAccount) : '—') +
                fieldFull('TRẠNG THÁI GIẤY TỜ', statusBadge(sp.verificationStatus));
            // Ảnh CCCD và Bằng lái
            var imgs = '';
            if (sp.idCardFrontUrl || sp.idCardBackUrl || sp.licenseFrontUrl || sp.licenseBackUrl) {
                imgs += '<div style="grid-column:span 2;margin-top:10px;">';
                imgs += '<label style="font-size:11px;color:var(--text-muted);font-weight:700;letter-spacing:.5px;display:block;margin-bottom:8px;">📷 ẢNH GIẤY TỜ TÙY THÂN & BẰNG LÁI</label>';
                imgs += '<div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;">';
                if (sp.idCardFrontUrl)
                    imgs += imgCard('CCCD mặt trước', sp.idCardFrontUrl);
                if (sp.idCardBackUrl)
                    imgs += imgCard('CCCD mặt sau', sp.idCardBackUrl);
                if (sp.licenseFrontUrl)
                    imgs += imgCard('Bằng lái mặt trước', sp.licenseFrontUrl);
                if (sp.licenseBackUrl)
                    imgs += imgCard('Bằng lái mặt sau', sp.licenseBackUrl);
                imgs += '</div></div>';
                extraGrid.innerHTML += imgs;
            }
        } else if (roleId == 3) {
            var up = window.USER_PROFILES && window.USER_PROFILES[id];
            extraSection.style.display = 'block';
            extraTitle.innerHTML = '🙍 Hồ sơ Khách Hàng';
            extraGrid.innerHTML =
                field('NGÀY SINH', up && up.dateOfBirth ? up.dateOfBirth : '—') +
                field('GIỚI TÍNH', up && up.gender ? genderLabel(up.gender) : '—');
        } else {
            extraSection.style.display = 'none';
        }

        document.getElementById('modalViewDetail').classList.add('open');
    }

    // Dropdown toggle (hành động theo dòng bảng)
    function toggleDropdown(btn) {
        const menu = btn.nextElementSibling;
        const isOpen = menu.classList.contains('open');
        document.querySelectorAll('.dropdown-menu.open').forEach(m => m.classList.remove('open'));
        if (!isOpen) menu.classList.add('open');
    }
    document.addEventListener('click', e => {
        if (!e.target.closest('.action-wrap')) {
            document.querySelectorAll('.dropdown-menu.open').forEach(m => m.classList.remove('open'));
        }
    });

    // Modal sửa tài khoản
    function openEditModal(id, username, fullname, email, phone, avatarUrl, roleId) {
        document.querySelectorAll('.dropdown-menu.open').forEach(m => m.classList.remove('open'));
        document.getElementById('editId').value = id;
        document.getElementById('editUsername').value = username;
        document.getElementById('editFullname').value = fullname;
        document.getElementById('editEmail').value = email;
        document.getElementById('editPhone').value = phone;
        document.getElementById('editAvatarUrl').value = avatarUrl;
        document.getElementById('editRoleId').value = roleId;
        document.getElementById('editPassword').value = '';
        document.getElementById('modalEdit').classList.add('open');
    }

    // Modal soft delete
    function openSoftModal(id, name) {
        document.querySelectorAll('.dropdown-menu.open').forEach(m => m.classList.remove('open'));
        document.getElementById('softId').value = id;
        document.getElementById('softName').textContent = name;
        document.getElementById('modalSoft').classList.add('open');
    }

    function openHardModal(id, name) {
        document.querySelectorAll('.dropdown-menu.open').forEach(m => m.classList.remove('open'));
        document.getElementById('hardId').value = id;
        document.getElementById('hardName').textContent = name;
        document.getElementById('modalHard').classList.add('open');
    }

    function closeModal(id) {
        document.getElementById(id).classList.remove('open');
    }

    // Đóng modal khi click backdrop
    document.querySelectorAll('.pob-modal-overlay').forEach(el => {
        el.addEventListener('click', e => {
            if (e.target === el) el.classList.remove('open');
        });
    });

    // Toast thông báo kết quả
    const urlParams = new URLSearchParams(window.location.search);
    const successParam = urlParams.get('success');
    if (successParam) {
        const toast = document.getElementById('toastEl');
        const messages = { delete: '✅ Đã xóa tài khoản thành công', create: '✅ Tạo tài khoản thành công', update: '✅ Cập nhật tài khoản thành công' };
        toast.textContent = messages[successParam] || '✅ Thành công';
        toast.style.display = 'block';
        setTimeout(() => toast.style.display = 'none', 3500);
    }

    // Avatar dropdown
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

    // Lightbox viewer cho ảnh CCCD / Bằng lái
    function openLightbox(url, caption) {
        document.getElementById('lightboxImg').src = url;
        document.getElementById('lightboxCaption').textContent = caption;
        document.getElementById('lightboxOverlay').style.display = 'flex';
    }
    function closeLightbox() {
        document.getElementById('lightboxOverlay').style.display = 'none';
        document.getElementById('lightboxImg').src = '';
    }
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeLightbox();
    });
</script>

<!-- Avatar Dropdown (đặt ngoài topbar để tránh backdrop-filter stacking context) -->
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

<!-- LIGHTBOX - Xem ảnh CCCD / Bằng lái toàn màn hình -->
<div id="lightboxOverlay" onclick="closeLightbox()" style="display:none;position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,.88);align-items:center;justify-content:center;flex-direction:column;gap:14px;padding:24px;">
    <button onclick="closeLightbox()" style="position:absolute;top:20px;right:24px;background:rgba(255,255,255,.15);border:none;color:#fff;font-size:22px;width:40px;height:40px;border-radius:50%;cursor:pointer;line-height:1;">&times;</button>
    <img id="lightboxImg" src="" alt="" onclick="event.stopPropagation()" style="max-width:90vw;max-height:80vh;border-radius:10px;box-shadow:0 8px 40px rgba(0,0,0,.6);object-fit:contain;"/>
    <div id="lightboxCaption" style="color:rgba(255,255,255,.85);font-size:13px;font-weight:700;letter-spacing:.5px;text-transform:uppercase;"></div>
    <div style="color:rgba(255,255,255,.45);font-size:11px;">Nhấn ESC hoặc click bên ngoài để đóng</div>
</div>

</body>
</html>
