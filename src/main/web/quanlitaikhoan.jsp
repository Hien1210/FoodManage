<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<%-- BẢO MẬT: KIỂM TRA QUYỀN SUPER ADMIN --%>
<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 1}">
    <c:redirect url="/dangnhap"/>
</c:if>

<c:set var="formAccount" value="${not empty accountSua ? accountSua : accountForm}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Quản lý tài khoản - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
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

        /* Ô tìm kiếm trên topbar */
        .search-form { display: flex; gap: 8px; position: relative; }
        .search-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--text-dim); pointer-events: none; font-size: 13px; }
        .search-box.dash-input { padding-left: 38px; width: 260px; }
        .search-box.dash-input:focus { width: 300px; }

        .panel-title-wrapper { display: flex; flex-direction: column; gap: 4px; }
        .panel-subtitle { font-size: 12px; color: var(--text-muted); }

        /* Sắp xếp cột bảng */
        .sort-link { color: var(--text-muted); text-decoration: none; display: inline-flex; align-items: center; gap: 6px; transition: color .2s; }
        .sort-link:hover { color: var(--primary); }
        .sort-icon { font-size: 11px; }

        .protected-badge { color: var(--text-muted); font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; opacity: .7; }

        /* Dropdown hành động (⋮) theo từng dòng bảng */
        .action-wrap { position: relative; display: inline-block; }
        .dropdown-menu { display: none; position: absolute; right: 0; top: 36px; background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 8px; box-shadow: var(--dash-shadow-md); min-width: 180px; z-index: 50; overflow: hidden; }
        .dropdown-menu.open { display: block; }
        .dropdown-item { display: flex; align-items: center; gap: 10px; padding: 11px 16px; font-size: 13px; color: var(--text-muted); cursor: pointer; transition: background .15s; border: none; background: none; width: 100%; text-align: left; font-family: var(--font-family); }
        .dropdown-item:hover { background: var(--bg-input); color: var(--text-main); }
        .dropdown-item.edit:hover { color: var(--primary); }
        .dropdown-item.soft-del:hover { color: var(--warning); }
        .dropdown-item.hard-del:hover { color: var(--danger); }

        /* MODAL thêm/sửa tài khoản */
        .modal-header { padding: 20px 24px; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; }
        .modal-close { background: transparent; border: none; color: var(--text-muted); font-size: 20px; cursor: pointer; padding: 4px; line-height: 1; border-radius: 6px; transition: .2s; }
        .modal-close:hover { color: var(--text-main); background: var(--bg-input); }
        .modal-body { padding: 24px; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .form-grid .form-group.full-width { grid-column: span 2; }
        .btn-group { display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color); }

        /* MODAL xác nhận xoá tạm thời / vĩnh viễn */
        .confirm-icon { font-size: 36px; margin-bottom: 12px; }
        .confirm-title { font-size: 17px; font-weight: 700; color: var(--text-main); margin-bottom: 8px; }
        .confirm-desc { font-size: 13px; color: var(--text-muted); line-height: 1.65; margin-bottom: 22px; }
        .confirm-actions { display: flex; gap: 10px; justify-content: flex-end; }
    </style>
</head>
<body class="dash-body">

<div class="sidebar-backdrop" id="sidebarBackdrop"></div>
<aside class="sidebar" id="sidebar">
    <div class="sidebar-brand">
        <div class="logo-mark-dash">S</div>
        <div class="brand-text">
            <span class="brand-title">SUPER ADMIN</span>
            <span class="brand-subtitle">👋 ${fn:escapeXml(sessionScope.account.userName)}</span>
        </div>
    </div>
    <div class="menu">
        <div class="menu-title">Quản lý hệ thống</div>
        <a href="${pageContext.request.contextPath}/tong-quan" class="menu-item">
            <span class="mi-left"><span class="mi-icon">⊞</span> Tổng quan hệ thống</span>
        </a>
        <a href="${pageContext.request.contextPath}/super-admin/shop-requests" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🏪</span> Duyệt Shop</span>
            <c:if test="${shopChoDuyet > 0}"><span class="menu-badge yellow">${shopChoDuyet} mới</span></c:if>
        </a>
        <a href="${pageContext.request.contextPath}/super-admin/shipper-requests" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🛵</span> Duyệt Shipper</span>
        </a>

        <div class="menu-title">Quản lý dữ liệu</div>
        <a href="${pageContext.request.contextPath}/quanlitaikhoan" class="menu-item active">
            <span class="mi-left"><span class="mi-icon">👤</span> Người dùng</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/appeals" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📋</span> Kháng nghị</span>
        </a>
        <a href="${pageContext.request.contextPath}/Category" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📂</span> Danh mục món ăn</span>
        </a>
        <a href="${pageContext.request.contextPath}/product" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🍽️</span> Sản phẩm</span>
        </a>
    </div>
</aside>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1>👤 Quản lý tài khoản</h1>
        </div>
        <div class="topbar-right">
            <form action="${pageContext.request.contextPath}/quanlitaikhoan" method="post" class="search-form">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="search">
                <span class="search-icon">🔍</span>
                <input type="text" name="searchKeyword" class="dash-input search-box"
                       placeholder="Tìm kiếm tài khoản, email..."
                       value="${fn:escapeXml(searchKeyword)}">
                <button type="submit" class="btn btn-primary btn-sm">Tìm</button>
            </form>

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
        <c:if test="${param.success == 'create'}">
            <div class="alert alert-success">✅ Tạo tài khoản thành công!</div>
        </c:if>
        <c:if test="${param.success == 'update'}">
            <div class="alert alert-success">✅ Cập nhật tài khoản thành công!</div>
        </c:if>
        <c:if test="${param.success == 'delete'}">
            <div class="alert alert-success">✅ Xóa tài khoản thành công!</div>
        </c:if>

        <div class="panel">
            <div class="panel-header">
                <div class="panel-title-wrapper">
                    <div class="panel-title">Danh sách tài khoản hệ thống</div>
                    <div class="panel-subtitle">Hiển thị danh sách và phân quyền người dùng toàn bộ hệ thống.</div>
                </div>
                <div style="display: flex; gap: 8px;">
                    <c:if test="${not empty searchKeyword}">
                        <a href="${pageContext.request.contextPath}/quanlitaikhoan" class="btn btn-outline btn-sm">🔄 Xóa tìm kiếm</a>
                    </c:if>
                    <button type="button" class="btn btn-primary" onclick="openAccountModal()">➕ Thêm tài khoản mới</button>
                </div>
            </div>

            <div class="panel-body">
                <c:if test="${not empty searchKeyword}">
                    <div class="alert alert-info" style="margin-bottom:16px;">
                        <span>🔍 Kết quả tìm kiếm cho: <strong>"${fn:escapeXml(searchKeyword)}"</strong> (Tìm thấy <strong>${fn:length(danhsach)}</strong> kết quả)</span>
                    </div>
                </c:if>

                <div class="dash-table-wrap">
                    <table class="dash-table">
                        <thead>
                            <tr>
                                <th style="width: 80px;">
                                    <a href="?sortField=id&sortOrder=${currentSortField == 'id' && currentSortOrder == 'ASC' ? 'DESC' : 'ASC'}&searchKeyword=${fn:escapeXml(searchKeyword)}" class="sort-link">
                                        ID <span class="sort-icon">${currentSortField == 'id' && currentSortOrder == 'ASC' ? '▲' : (currentSortField == 'id' && currentSortOrder == 'DESC' ? '▼' : '⇅')}</span>
                                    </a>
                                </th>
                                <th style="width: 70px;">Avatar</th>
                                <th>
                                    <a href="?sortField=username&sortOrder=${currentSortField == 'username' && currentSortOrder == 'ASC' ? 'DESC' : 'ASC'}&searchKeyword=${fn:escapeXml(searchKeyword)}" class="sort-link">
                                        Tài khoản <span class="sort-icon">${currentSortField == 'username' && currentSortOrder == 'ASC' ? '▲' : (currentSortField == 'username' && currentSortOrder == 'DESC' ? '▼' : '⇅')}</span>
                                    </a>
                                </th>
                                <th>
                                    <a href="?sortField=email&sortOrder=${currentSortField == 'email' && currentSortOrder == 'ASC' ? 'DESC' : 'ASC'}&searchKeyword=${fn:escapeXml(searchKeyword)}" class="sort-link">
                                        Liên hệ <span class="sort-icon">${currentSortField == 'email' && currentSortOrder == 'ASC' ? '▲' : (currentSortField == 'email' && currentSortOrder == 'DESC' ? '▼' : '⇅')}</span>
                                    </a>
                                </th>
                                <th style="width: 140px;">
                                    <a href="?sortField=role&sortOrder=${currentSortField == 'role' && currentSortOrder == 'ASC' ? 'DESC' : 'ASC'}&searchKeyword=${fn:escapeXml(searchKeyword)}" class="sort-link">
                                        Vai trò <span class="sort-icon">${currentSortField == 'role' && currentSortOrder == 'ASC' ? '▲' : (currentSortField == 'role' && currentSortOrder == 'DESC' ? '▼' : '⇅')}</span>
                                    </a>
                                </th>
                                <th style="width: 160px; text-align: center;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="acc" items="${danhsach}">
                                <tr>
                                    <td style="font-weight: 700; color: var(--text-dim);">#<c:out value="${acc.id}"/></td>
                                    <td>
                                        <div class="avatar-circle">
                                            <c:choose>
                                                <c:when test="${not empty acc.avatarUrl}">
                                                    <img src="${fn:escapeXml(acc.avatarUrl)}" alt="Avatar" style="width:100%; height:100%; object-fit:cover;">
                                                </c:when>
                                                <c:otherwise>👤</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600;"><c:out value="${acc.userName}"/></div>
                                        <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;"><c:out value="${acc.fullName}"/></div>
                                    </td>
                                    <td>
                                        <div><c:out value="${acc.email}"/></div>
                                        <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;">📞 <c:out value="${acc.phone}"/></div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${acc.roleId == 1}"><span class="badge badge-info">👑 Admin</span></c:when>
                                            <c:when test="${acc.roleId == 2}"><span class="badge badge-info">🏪 Shop</span></c:when>
                                            <c:when test="${acc.roleId == 3}"><span class="badge badge-neutral">👤 User</span></c:when>
                                            <c:when test="${acc.roleId == 4}"><span class="badge badge-info">🛵 Shipper</span></c:when>
                                        </c:choose>
                                    </td>
                                    <td style="text-align:center;">
                                        <c:choose>
                                            <c:when test="${acc.roleId == 1}">
                                                <span class="protected-badge">🔒 Hệ thống bảo vệ</span>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="action-wrap">
                                                    <button class="btn btn-sm btn-ghost" onclick="toggleDropdown(this)" title="Tùy chọn">⋮</button>
                                                    <div class="dropdown-menu">
                                                        <button class="dropdown-item soft-del"
                                                                onclick="openSoftModal(${acc.id}, '${fn:escapeXml(fn:replace(fn:replace(acc.userName,'\\','\\\\'),"'","\\'"))}')">
                                                            🗂️ Xóa tạm thời
                                                        </button>
                                                        <button class="dropdown-item hard-del"
                                                                onclick="openHardModal(${acc.id}, '${fn:escapeXml(fn:replace(fn:replace(acc.userName,'\\','\\\\'),"'","\\'"))}')">
                                                            🗑️ Xóa vĩnh viễn
                                                        </button>
                                                    </div>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${not empty searchKeyword and empty danhsach}">
                                <tr>
                                    <td colspan="6">
                                        <div class="empty-state">
                                            <div class="e-icon">🔍</div>
                                            <div class="e-title">Không tìm thấy tài khoản nào khớp với từ khóa của bạn.</div>
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

<div class="pob-modal-overlay" id="accountModal">
    <div class="pob-modal-box">
        <div class="modal-header">
            <div class="panel-title-wrapper">
                <h3 class="panel-title">
                    <c:choose>
                        <c:when test="${not empty accountSua}">Cập nhật tài khoản</c:when>
                        <c:otherwise>Tạo tài khoản hệ thống mới</c:otherwise>
                    </c:choose>
                </h3>
            </div>
            <button type="button" class="modal-close" onclick="closeAccountModal()">✕</button>
        </div>

        <div class="modal-body">
            <div class="alert alert-info" style="margin-bottom: 20px;">
                💡 <strong>Lưu ý:</strong> Tài khoản loại Khách hàng (User) sẽ tự đăng ký ngoài hệ thống. Tại đây chỉ thao tác tạo lập phân quyền các cấp quản trị: Admin, Shop, Shipper.
            </div>

            <form action="${pageContext.request.contextPath}/quanlitaikhoan" method="post" accept-charset="UTF-8">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <c:choose>
                    <c:when test="${not empty accountSua}">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id" value="${accountSua.id}">
                    </c:when>
                    <c:otherwise>
                        <input type="hidden" name="action" value="create">
                    </c:otherwise>
                </c:choose>

                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label" for="username">Tên đăng nhập (Username) *</label>
                        <input class="form-control" id="username" type="text" name="username" value="${fn:escapeXml(formAccount.userName)}" required placeholder="Ví dụ: admin_store">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="password">Mật khẩu *</label>
                        <c:choose>
                            <c:when test="${empty accountSua}">
                                <input class="form-control" id="password" type="password" name="password" required placeholder="Nhập mật khẩu an toàn">
                            </c:when>
                            <c:otherwise>
                                <input class="form-control" id="password" type="password" name="password" placeholder="••••••••">
                                <span class="form-hint">Để trống nếu giữ nguyên mật khẩu cũ.</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="fullname">Họ và tên</label>
                        <input class="form-control" id="fullname" type="text" name="fullname" value="${fn:escapeXml(formAccount.fullName)}" placeholder="Nguyễn Văn A">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="email">Địa chỉ Email *</label>
                        <input class="form-control" id="email" type="email" name="email" value="${fn:escapeXml(formAccount.email)}" required placeholder="name@example.com">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="phone">Số điện thoại</label>
                        <input class="form-control" id="phone" type="text" name="phone" value="${fn:escapeXml(formAccount.phone)}" placeholder="09xx xxx xxx">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="roleid">Phân quyền (Role) *</label>
                        <select class="form-select" id="roleid" name="roleid" required>
                            <option value="1" ${formAccount.roleId == 1 ? 'selected' : ''}>👑 Admin (Quản trị viên)</option>
                            <option value="2" ${formAccount.roleId == 2 ? 'selected' : ''}>🏪 Shop (Chủ cửa hàng)</option>
                            <option value="4" ${formAccount.roleId == 4 ? 'selected' : ''}>🛵 Shipper (Giao hàng)</option>
                        </select>
                    </div>

                    <div class="form-group full-width">
                        <label class="form-label" for="avatarurl">Đường dẫn ảnh đại diện (Avatar URL)</label>
                        <input class="form-control" id="avatarurl" type="text" name="avatarurl" value="${fn:escapeXml(formAccount.avatarUrl)}" placeholder="https://domain.com/path-to-image.png">
                    </div>
                </div>

                <c:if test="${not empty loi}">
                    <div class="alert alert-danger" style="margin-top:16px;">⚠️ <c:out value="${loi}"/></div>
                </c:if>

                <div class="btn-group">
                    <button type="button" class="btn btn-ghost" onclick="closeAccountModal()">Hủy thao tác</button>
                    <button type="submit" class="btn btn-primary">
                        <c:choose>
                            <c:when test="${not empty accountSua}">💾 Lưu cập nhật</c:when>
                            <c:otherwise>🚀 Tạo ngay</c:otherwise>
                        </c:choose>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- MODAL XÓA TẠM THỜI -->
<div class="pob-modal-overlay" id="modalSoft">
    <div class="pob-modal-box">
        <div style="padding:28px;">
            <div class="confirm-icon">🗂️</div>
            <div class="confirm-title">Xóa tạm thời tài khoản?</div>
            <div class="confirm-desc">
                Tài khoản <strong id="softName" style="color:var(--text-main);"></strong> sẽ bị đình chỉ và không thể đăng nhập.<br>Có thể khôi phục lại sau.
            </div>
            <form method="post" action="${pageContext.request.contextPath}/quanlitaikhoan" style="margin:0">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="delete"/>
                <input type="hidden" name="deleteType" value="soft"/>
                <input type="hidden" name="id" id="softId"/>
                <div class="form-group">
                    <label class="form-label">
                        Lý do đình chỉ <span style="color:var(--text-muted);font-weight:400;">(hiển thị cho người dùng)</span>
                    </label>
                    <textarea name="suspendReason" id="suspendReasonInput" rows="3" class="form-control"
                        placeholder="Ví dụ: Vi phạm điều khoản sử dụng, spam đơn hàng..."></textarea>
                </div>
                <div class="confirm-actions">
                    <button type="button" class="btn btn-ghost" onclick="closeConfirm('modalSoft')">Hủy</button>
                    <button type="submit" class="btn btn-warning">🗂️ Xác nhận đình chỉ</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- MODAL XÓA VĨNH VIỄN -->
<div class="pob-modal-overlay" id="modalHard">
    <div class="pob-modal-box">
        <div style="padding:28px;">
            <div class="confirm-icon">⚠️</div>
            <div class="confirm-title">Xóa vĩnh viễn tài khoản?</div>
            <div class="confirm-desc">
                Tài khoản <strong id="hardName" style="color:var(--text-main);"></strong> sẽ bị <strong style="color:var(--danger);">xóa hoàn toàn khỏi Database</strong>.<br>
                Hành động này <strong style="color:var(--danger);">không thể hoàn tác</strong>. Mọi dữ liệu liên quan sẽ bị mất.
            </div>
            <div class="confirm-actions">
                <button type="button" class="btn btn-ghost" onclick="closeConfirm('modalHard')">Hủy</button>
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

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script>
    const modal = document.getElementById('accountModal');

    // Trạng thái edit từ Server gửi về bằng JSTL
    const isEditMode = ${not empty accountSua ? true : false};
    const hasError = ${not empty loi ? true : false};

    // --- XỬ LÝ POPUP MODAL ---
    function openAccountModal() {
        modal.classList.add('open');
    }

    function closeModalLogic() {
        modal.classList.remove('open');
        if (isEditMode) {
            // Nếu đang ở chế độ Edit từ Backend, khi hủy cần redirect để xóa session/request attribute của accountSua
            window.location.href = '${pageContext.request.contextPath}/quanlitaikhoan';
        }
    }

    function closeAccountModal() {
        closeModalLogic();
    }

    // Đóng popup khi bấm click ra ngoài vùng form
    modal.addEventListener('click', function(e) {
        if (e.target === modal) {
            closeModalLogic();
        }
    });

    // Tự động mở popup nếu có lỗi từ Server hoặc đang ở trạng thái Sửa dữ liệu
    document.addEventListener('DOMContentLoaded', () => {
        if (isEditMode || hasError) {
            openAccountModal();
        }
    });

    // Dropdown ⋮
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

    // Confirm modals
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
    function closeConfirm(id) {
        document.getElementById(id).classList.remove('open');
    }
    document.querySelectorAll('#modalSoft, #modalHard').forEach(el => {
        el.addEventListener('click', e => { if (e.target === el) el.classList.remove('open'); });
    });

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
            avatarDropdown.addEventListener('click', function(e) {
                e.stopPropagation();
            });
            document.addEventListener('click', function() {
                avatarDropdown.classList.remove('open');
            });
        }
    });
</script>

<!-- Avatar Dropdown -->
<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${fn:escapeXml(sessionScope.account.userName)}</div>
        <div class="d-email">${fn:escapeXml(sessionScope.account.email)}</div>
        <span class="d-role">Super Admin</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/admin/profile" class="dropdown-link">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/admin/change-password" class="dropdown-link">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>
</body>
</html>
