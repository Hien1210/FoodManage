<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="currentShop" value="${sessionScope.currentShop}" scope="request"/>

<%-- BẢO MẬT: KIỂM TRA QUYỀN SHOP (roleId = 2) --%>
<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 2}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Loại Sản Phẩm - ${not empty currentShop.shopName ? currentShop.shopName : 'Cửa hàng'}</title>
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

        /* Toolbar bảng: search + đếm kết quả */
        .table-toolbar { padding: 16px 20px; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
        .toolbar-left { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .result-count { font-size: 12px; color: var(--text-dim); }
        .result-count strong { color: var(--text-main); }
        .action-cell { display: flex; gap: 6px; flex-wrap: wrap; justify-content: center; }
        .inline-form { display: inline; }
        .table-footer { padding: 14px 20px; border-top: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; font-size: 12px; color: var(--text-dim); }

        /* Đếm ký tự trong form thêm/sửa */
        .char-count { font-size: 10px; color: var(--text-dim); text-align: right; margin-top: 3px; }

        /* Modal thêm/sửa loại sản phẩm */
        .modal-header { padding: 20px 26px; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; }
        .modal-body { padding: 24px 26px; }
        .modal-close { background: none; border: none; font-size: 18px; cursor: pointer; color: var(--text-dim); }
        .modal-close:hover { color: var(--danger); }
        .modal-footer { padding: 20px 26px; border-top: 1px solid var(--border-color); display: flex; justify-content: flex-end; gap: 12px; }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="/shop/product-types" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">category</span> Quản lý loại sản phẩm</h1>
        </div>
        <div class="topbar-right">
            <a href="${pageContext.request.contextPath}/shop/product-types?action=trash" class="btn btn-danger-outline btn-sm">🗑️ Thùng rác</a>
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
        <%-- Thông báo --%>
        <c:if test="${param.success eq 'create'}">
            <div class="alert alert-success">✅ Tạo loại sản phẩm thành công!</div>
        </c:if>
        <c:if test="${param.success eq 'update'}">
            <div class="alert alert-success">✅ Cập nhật loại sản phẩm thành công!</div>
        </c:if>
        <c:if test="${param.success eq 'delete'}">
            <div class="alert alert-success">✅ Xóa loại sản phẩm thành công!</div>
        </c:if>
        <c:if test="${not empty loi}">
            <div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div>
        </c:if>

        <%-- Mini Stats --%>
        <div class="stats-grid">
            <div class="stat-card">
                <div><div style="font-size:12px;color:var(--text-dim);font-weight:600;">Tổng loại sản phẩm</div><div class="stat-num">${fn:length(danhsach)}</div></div>
                <div class="stat-icon">📂</div>
            </div>
            <div class="stat-card">
                <div><div style="font-size:12px;color:var(--text-dim);font-weight:600;">Đang hiển thị</div><div class="stat-num">${soLoaiDangHoatDong}</div></div>
                <div class="stat-icon" style="background:var(--success-light);color:var(--success-dark);">✅</div>
            </div>
        </div>

        <%-- Xác định form đang hiển thị (sửa hay thêm mới) --%>
        <c:set var="formCat" value="${not empty productTypeSua ? productTypeSua : productTypeForm}"/>

        <div class="panel">
            <div class="table-toolbar">
                <div class="toolbar-left">
                    <input type="text" class="dash-input" style="width:220px;"
                           placeholder="🔍 Tìm loại sản phẩm..."
                           oninput="filterTable(this.value)">
                    <span class="result-count">Tổng: <strong id="visibleCount">${fn:length(danhsach)}</strong> loại</span>
                </div>
                <button type="button" class="btn btn-primary" onclick="openTypeModal()">➕ Thêm loại sản phẩm mới</button>
            </div>

            <c:choose>
                <c:when test="${empty danhsach}">
                    <div class="empty-state">
                        <div class="e-icon">📂</div>
                        <div class="e-title">Chưa có loại sản phẩm nào.</div>
                        <div class="e-sub"><a href="javascript:void(0)" onclick="openTypeModal()" style="color:var(--primary);font-weight:700;">Thêm loại sản phẩm đầu tiên ngay →</a></div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="dash-table-wrap">
                        <table class="dash-table card-table" id="productTypeTable">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Tên loại</th>
                                    <th>Trạng thái</th>
                                    <th style="text-align:center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="cat" items="${danhsach}" varStatus="vs">
                                    <tr data-name="${fn:toLowerCase(cat.categoryName)}">
                                        <td>${vs.index + 1}</td>
                                        <td>
                                            <strong><c:out value="${cat.categoryName}"/></strong>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${empty cat.status || fn:toUpperCase(cat.status) == 'ACTIVE'}">
                                                    <span class="badge badge-success">✅ Hiển thị</span>
                                                </c:when>
                                                <c:when test="${fn:toUpperCase(cat.status) == 'HIDDEN' || fn:toUpperCase(cat.status) == 'INACTIVE'}">
                                                    <span class="badge badge-danger">🙈 Ẩn</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-success">✅ Hiển thị</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="action-cell">
                                                <a href="${pageContext.request.contextPath}/shop/product-types?action=edit&id=${cat.id}"
                                                   class="btn btn-sm btn-outline">✏️ Sửa</a>
                                                <form class="inline-form"
                                                      action="${pageContext.request.contextPath}/shop/product-types"
                                                      method="post"
                                                      onsubmit="return pobConfirmDelete(event, this, 'Bạn có chắc chắn muốn xóa loại sản phẩm <strong>«${fn:escapeXml(cat.categoryName)}»</strong> không?<br><span style=\'font-size:12px;color:var(--text-muted);\'>Các sản phẩm trong loại này sẽ không bị xóa.</span>', 'Xóa loại sản phẩm')">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id"     value="${cat.id}">
                                                    <button type="submit" class="btn btn-sm btn-danger-outline">🗑️ Xóa</button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <div class="table-footer">
                        <span>Hiển thị <strong id="showCount">${fn:length(danhsach)}</strong> loại sản phẩm</span>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<%-- ── MODAL THÊM / SỬA LOẠI SẢN PHẨM ── --%>
<div class="pob-modal-overlay" id="typeModal">
    <div class="pob-modal-box" style="max-width:480px;">
        <div class="modal-header">
            <div class="panel-title">
                <c:choose>
                    <c:when test="${not empty productTypeSua}">✏️ Cập nhật loại sản phẩm</c:when>
                    <c:otherwise>➕ Thêm loại sản phẩm mới</c:otherwise>
                </c:choose>
            </div>
            <button type="button" class="modal-close" onclick="closeTypeModal()">✕</button>
        </div>
        <div class="modal-body">
            <form action="${pageContext.request.contextPath}/shop/product-types" method="post" id="typeForm">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <c:choose>
                    <c:when test="${not empty productTypeSua}">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id"     value="${productTypeSua.id}">
                    </c:when>
                    <c:otherwise>
                        <input type="hidden" name="action" value="create">
                    </c:otherwise>
                </c:choose>

                <%--
                    Field "typeName" → servlet đọc req.getParameter("typeName")
                    và gán vào category.setCategoryName(...)
                --%>
                <div class="form-group">
                    <label class="form-label" for="typeName">
                        Tên loại sản phẩm <span class="required">*</span>
                    </label>
                    <input type="text"
                           id="typeName"
                           name="typeName"
                           class="form-control"
                           value="${fn:escapeXml(formCat.categoryName)}"
                           placeholder="Ví dụ: Cơm, Bún, Đồ uống, Tráng miệng..."
                           maxlength="100"
                           required
                           autofocus
                           oninput="updateCharCount(this,'typeNameCount',100)">
                    <div class="char-count" id="typeNameCount">0 / 100</div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="status">Trạng thái</label>
                    <select id="status" name="status" class="form-select">
                        <option value="ACTIVE"
                            ${fn:toUpperCase(formCat.status) == 'ACTIVE' || empty formCat.status ? 'selected' : ''}>
                            ✅ Hiển thị
                        </option>
                        <option value="HIDDEN"
                            ${fn:toUpperCase(formCat.status) == 'HIDDEN' ? 'selected' : ''}>
                            🙈 Ẩn
                        </option>
                        <option value="INACTIVE"
                            ${fn:toUpperCase(formCat.status) == 'INACTIVE' ? 'selected' : ''}>
                            ⛔ Ngừng dùng
                        </option>
                    </select>
                </div>

                <c:if test="${not empty loi}">
                    <div class="alert alert-danger" style="margin-top:16px;">⚠️ <c:out value="${loi}"/></div>
                </c:if>
            </form>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-ghost" onclick="closeTypeModal()">Hủy</button>
            <button type="submit" form="typeForm" class="btn btn-primary">
                <c:choose>
                    <c:when test="${not empty productTypeSua}">💾 Lưu thay đổi</c:when>
                    <c:otherwise>➕ Thêm loại mới</c:otherwise>
                </c:choose>
            </button>
        </div>
    </div>
</div>

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
<script>
    const modal = document.getElementById('typeModal');
    const isEditMode = ${ not empty productTypeSua ? 'true' : 'false' };
    const hasError   = ${ not empty loi ? 'true' : 'false' };

    function openTypeModal() { modal.classList.add('open'); }
    function closeTypeModal() {
        modal.classList.remove('open');
        if (isEditMode) {
            window.location.href = '${pageContext.request.contextPath}/shop/product-types';
        }
    }
    modal.addEventListener('click', e => { if (e.target === modal) closeTypeModal(); });
    document.addEventListener('DOMContentLoaded', () => {
        if (isEditMode || hasError) openTypeModal();
        const nameEl = document.getElementById('typeName');
        if (nameEl) updateCharCount(nameEl, 'typeNameCount', 100);
    });

    /* Lọc loại sản phẩm theo tên (client-side) */
    function filterTable(keyword) {
        const rows = document.querySelectorAll('#productTypeTable tbody tr');
        const kw = keyword.toLowerCase().trim();
        let visible = 0;
        rows.forEach(row => {
            const name = row.getAttribute('data-name') || '';
            const show = name.includes(kw);
            row.style.display = show ? '' : 'none';
            if (show) visible++;
        });
        const el = document.getElementById('visibleCount');
        if (el) el.textContent = visible;
        const sel = document.getElementById('showCount');
        if (sel) sel.textContent = visible;
    }

    /* Đếm ký tự input */
    function updateCharCount(input, countId, max) {
        const el = document.getElementById(countId);
        if (el) el.textContent = input.value.length + ' / ' + max;
    }

    /* Auto-dismiss alerts sau 4 giây */
    document.querySelectorAll('.alert').forEach(el => {
        setTimeout(() => {
            el.style.transition = 'opacity .5s';
            el.style.opacity = '0';
            setTimeout(() => el.remove(), 500);
        }, 4000);
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
