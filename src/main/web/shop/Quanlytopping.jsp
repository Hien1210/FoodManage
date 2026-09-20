<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
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
    <title>Quản lý Topping - ${not empty currentShop.shopName ? currentShop.shopName : 'Cửa hàng'}</title>
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

        /* Toolbar bảng: filter + đếm kết quả */
        .table-toolbar { padding: 16px 20px; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
        .toolbar-left { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .result-count { font-size: 12px; color: var(--text-dim); }
        .result-count strong { color: var(--text-main); }
        .action-cell { display: flex; gap: 6px; flex-wrap: wrap; justify-content: center; }
        .inline-form { display: inline; }

        /* Topping trong bảng */
        .topping-name { font-weight: 700; color: var(--text-main); }
        .topping-cat { font-size: 11px; color: var(--text-muted); margin-top: 2px; }
        .price-pill { display: inline-block; background: var(--primary-light); color: var(--primary-dark); font-weight: 700; font-size: 13px; padding: 4px 12px; border-radius: 20px; }

        /* Hint text dưới select loại topping */
        .hint { font-size: 11px; color: var(--text-dim); margin-top: 5px; }
        .price-wrap { position: relative; }
        .price-wrap .form-control { padding-right: 44px; }
        .price-unit { position: absolute; right: 14px; top: 50%; transform: translateY(-50%); font-size: 13px; font-weight: 700; color: var(--primary-dark); }

        /* Modal thêm/sửa topping */
        .modal-header { padding: 20px 26px; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; }
        .modal-body { padding: 24px 26px; }
        .modal-close { background: none; border: none; font-size: 18px; cursor: pointer; color: var(--text-dim); }
        .modal-close:hover { color: var(--danger); }
        .modal-footer { padding: 20px 26px; border-top: 1px solid var(--border-color); display: flex; justify-content: flex-end; gap: 12px; }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="/shop/toppings" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">icecream</span> Quản lý Topping</h1>
        </div>
        <div class="topbar-right">
            <input type="text" class="dash-input" style="width:220px;"
                   placeholder="🔍 Tìm tên topping..."
                   oninput="filterTable(this.value)">
            <a href="${pageContext.request.contextPath}/shop/toppings?action=trash" class="btn btn-danger-outline btn-sm">🗑️ Thùng rác</a>
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
            <div class="alert alert-success">✅ Thêm topping thành công!</div>
        </c:if>
        <c:if test="${param.success eq 'update'}">
            <div class="alert alert-success">✅ Cập nhật topping thành công!</div>
        </c:if>
        <c:if test="${param.success eq 'delete'}">
            <div class="alert alert-success">✅ Xóa topping thành công!</div>
        </c:if>
        <c:if test="${not empty loi}">
            <div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div>
        </c:if>

        <%-- Mini Stats --%>
        <div class="stats-grid">
            <div class="stat-card">
                <div><div style="font-size:12px;color:var(--text-dim);font-weight:600;">Tổng topping</div><div class="stat-num">${fn:length(danhsach)}</div></div>
                <div class="stat-icon">🧂</div>
            </div>
            <div class="stat-card">
                <div><div style="font-size:12px;color:var(--text-dim);font-weight:600;">Đang bán</div><div class="stat-num">${soDangBan}</div></div>
                <div class="stat-icon" style="background:var(--success-light);color:var(--success-dark);">✅</div>
            </div>
            <div class="stat-card">
                <div><div style="font-size:12px;color:var(--text-dim);font-weight:600;">Loại topping</div><div class="stat-num">${fn:length(danhsachLoai)}</div></div>
                <div class="stat-icon" style="background:var(--warning-light);color:var(--warning-dark);">🏷️</div>
            </div>
        </div>

        <c:set var="formTop" value="${not empty toppingSua ? toppingSua : toppingForm}"/>

        <div class="panel">
            <div class="table-toolbar">
                <div class="toolbar-left">
                    <select class="dash-input" style="width:auto;" onchange="filterByCategory(this.value)">
                        <option value="">Tất cả loại</option>
                        <c:forEach var="cat" items="${danhsachLoai}">
                            <option value="${cat.id}"><c:out value="${cat.name}"/></option>
                        </c:forEach>
                    </select>
                    <span class="result-count">Tổng: <strong id="visibleCount">${fn:length(danhsach)}</strong> topping</span>
                </div>
                <button type="button" class="btn btn-primary" onclick="openToppingModal()">➕ Thêm topping mới</button>
            </div>

            <c:choose>
                <c:when test="${empty danhsach}">
                    <div class="empty-state">
                        <div class="e-icon">🧂</div>
                        <div class="e-title">Chưa có topping nào.</div>
                        <div class="e-sub"><a href="javascript:void(0)" onclick="openToppingModal()" style="color:var(--primary);font-weight:700;">Thêm topping đầu tiên ngay →</a></div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="dash-table-wrap">
                        <table class="dash-table card-table ct-topping" id="toppingTable">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Topping</th>
                                    <th>Giá</th>
                                    <th>Trạng thái</th>
                                    <th style="text-align:center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="top" items="${danhsach}" varStatus="vs">
                                    <tr data-name="${fn:toLowerCase(top.toppingName)}"
                                        data-cat="${top.toppingCategoryId}">
                                        <td>${vs.index + 1}</td>
                                        <td>
                                            <div class="topping-name"><c:out value="${top.toppingName}"/></div>
                                            <div class="topping-cat">🏷️ ${not empty top.toppingCategoryName ? top.toppingCategoryName : 'Chưa phân loại'}</div>
                                        </td>
                                        <td>
                                            <span class="price-pill">
                                                <c:choose>
                                                    <c:when test="${top.price == 0}">Miễn phí</c:when>
                                                    <c:otherwise><fmt:formatNumber value="${top.price}" pattern="#,##0"/>đ</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${fn:toUpperCase(top.status) == 'ACTIVE'}">
                                                    <span class="badge badge-success">✅ Đang bán</span>
                                                </c:when>
                                                <c:when test="${fn:toUpperCase(top.status) == 'OUT_OF_STOCK'}">
                                                    <span class="badge badge-warning">⛔ Hết hàng</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-neutral"><c:out value="${top.status}"/></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="action-cell">
                                                <a href="${pageContext.request.contextPath}/shop/toppings?action=edit&id=${top.id}"
                                                   class="btn btn-sm btn-outline">✏️ Sửa</a>
                                                <form class="inline-form"
                                                      action="${pageContext.request.contextPath}/shop/toppings"
                                                      method="post"
                                                      onsubmit="return pobConfirmDelete(event, this, 'Bạn có chắc chắn muốn xóa Topping <strong>«${fn:escapeXml(top.toppingName)}»</strong> không?', 'Xóa Topping')">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="${top.id}">
                                                    <button type="submit" class="btn btn-sm btn-danger-outline">🗑️ Xóa</button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<%-- ── MODAL THÊM / SỬA TOPPING ── --%>
<div class="pob-modal-overlay" id="toppingModal">
    <div class="pob-modal-box" style="max-width:480px;">
        <div class="modal-header">
            <div class="panel-title">
                <c:choose>
                    <c:when test="${not empty toppingSua}">✏️ Cập nhật topping</c:when>
                    <c:otherwise>➕ Thêm topping mới</c:otherwise>
                </c:choose>
            </div>
            <button type="button" class="modal-close" onclick="closeToppingModal()">✕</button>
        </div>
        <div class="modal-body">
            <form action="${pageContext.request.contextPath}/shop/toppings" method="post" id="toppingForm">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <c:choose>
                    <c:when test="${not empty toppingSua}">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="id" value="${toppingSua.id}">
                    </c:when>
                    <c:otherwise>
                        <input type="hidden" name="action" value="create">
                    </c:otherwise>
                </c:choose>

                <div class="form-group">
                    <label class="form-label" for="toppingName">Tên topping <span class="required">*</span></label>
                    <input type="text" id="toppingName" name="toppingName" class="form-control"
                           value="${fn:escapeXml(formTop.toppingName)}"
                           placeholder="Ví dụ: Phô mai, Trứng muối, Ớt sa tế..."
                           required autofocus>
                </div>

                <div class="form-group">
                    <label class="form-label" for="toppingCategoryId">Loại topping <span class="required">*</span></label>
                    <select id="toppingCategoryId" name="toppingCategoryId" class="form-select" required>
                        <option value="">-- Chọn loại topping --</option>
                        <c:forEach var="cat" items="${danhsachLoai}">
                            <option value="${cat.id}"
                                ${formTop.toppingCategoryId == cat.id ? 'selected' : ''}>
                                <c:out value="${cat.name}"/>
                            </option>
                        </c:forEach>
                    </select>
                    <p class="hint">
                        Chưa có loại?
                        <a href="${pageContext.request.contextPath}/shop/topping-categories"
                           style="color:var(--primary);font-weight:700;">Tạo loại topping →</a>
                    </p>
                </div>

                <div class="form-group">
                    <label class="form-label" for="price">Giá <span class="required">*</span></label>
                    <div class="price-wrap">
                        <input type="text" id="price" name="price" class="form-control"
                               data-money="true"
                               value="${formTop.price}"
                               placeholder="0" required>
                        <span class="price-unit">đ</span>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="status">Trạng thái</label>
                    <select id="status" name="status" class="form-select">
                        <option value="ACTIVE"      ${fn:toUpperCase(formTop.status) == 'ACTIVE'      ? 'selected' : ''}>✅ Đang bán</option>
                        <option value="OUT_OF_STOCK" ${fn:toUpperCase(formTop.status) == 'OUT_OF_STOCK' ? 'selected' : ''}>⛔ Hết hàng</option>
                    </select>
                </div>

                <c:if test="${not empty loi}">
                    <div class="alert alert-danger" style="margin-top:16px;">⚠️ <c:out value="${loi}"/></div>
                </c:if>
            </form>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-ghost" onclick="closeToppingModal()">Hủy</button>
            <button type="submit" form="toppingForm" class="btn btn-primary">
                <c:choose>
                    <c:when test="${not empty toppingSua}">💾 Lưu thay đổi</c:when>
                    <c:otherwise>➕ Thêm topping</c:otherwise>
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
<script src="${pageContext.request.contextPath}/assets/js/money-format.js"></script>
<script>
    const modal = document.getElementById('toppingModal');
    const isEditMode = ${ not empty toppingSua ? 'true' : 'false' };
    const hasError   = ${ not empty loi ? 'true' : 'false' };

    function openToppingModal() { modal.classList.add('open'); }
    function closeToppingModal() {
        modal.classList.remove('open');
        if (isEditMode) {
            window.location.href = '${pageContext.request.contextPath}/shop/toppings';
        }
    }
    modal.addEventListener('click', e => { if (e.target === modal) closeToppingModal(); });
    document.addEventListener('DOMContentLoaded', () => {
        if (isEditMode || hasError) openToppingModal();
    });

    /* Lọc topping theo tên (client-side) */
    function filterTable(keyword) {
        const rows = document.querySelectorAll('#toppingTable tbody tr');
        const kw = keyword.toLowerCase().trim();
        rows.forEach(row => {
            const name = row.getAttribute('data-name') || '';
            row.style.display = name.includes(kw) ? '' : 'none';
        });
    }

    /* Lọc topping theo loại (client-side) */
    function filterByCategory(catId) {
        const rows = document.querySelectorAll('#toppingTable tbody tr');
        rows.forEach(row => {
            if (!catId) {
                row.style.display = '';
            } else {
                row.style.display = row.getAttribute('data-cat') === catId ? '' : 'none';
            }
        });
    }

    /* Auto-dismiss alerts */
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
