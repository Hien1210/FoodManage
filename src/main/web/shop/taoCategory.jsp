<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

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
    <title>Quản lý Category - Super Admin</title>
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

        /* Layout riêng của trang: form bên trái + danh sách bên phải (chưa có trong dashboard.css) */
        .cat-grid { display: grid; grid-template-columns: 360px 1fr; gap: 20px; align-items: start; }
        @media (max-width: 992px) { .cat-grid { grid-template-columns: 1fr; } }
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
    <button type="button" class="sidebar-toggle-btn" id="sidebarToggleBtn" onclick="pobToggleSidebar()" title="Thu gọn / mở rộng menu">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
    </button>
    </div>
    <div class="menu">
        <div class="menu-title">Quản lý hệ thống</div>
        <a href="${pageContext.request.contextPath}/tong-quan" class="menu-item">
            <span class="mi-left"><span class="mi-icon">⊞</span><span class="mi-label"> Tổng quan hệ thống</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/super-admin/shop-requests" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🏪</span><span class="mi-label"> Duyệt Shop</span></span>
            <c:if test="${shopChoDuyet > 0}"><span class="menu-badge yellow">${shopChoDuyet} mới</span></c:if>
        </a>
        <a href="${pageContext.request.contextPath}/super-admin/shipper-requests" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🛵</span><span class="mi-label"> Duyệt Shipper</span></span>
        </a>

        <div class="menu-title">Quản lý dữ liệu</div>
        <a href="${pageContext.request.contextPath}/quanlitaikhoan" class="menu-item">
            <span class="mi-left"><span class="mi-icon">👤</span><span class="mi-label"> Người dùng</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/appeals" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📋</span><span class="mi-label"> Kháng nghị</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/Category" class="menu-item active">
            <span class="mi-left"><span class="mi-icon">📂</span><span class="mi-label"> Danh mục món ăn</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/product" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🍽️</span><span class="mi-label"> Sản phẩm</span></span>
        </a>
    </div>
</aside>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1>📂 Quản lý danh mục món ăn</h1>
        </div>
        <div class="topbar-right">
            <button type="button" class="theme-toggle" onclick="pobToggleTheme()" title="Chuyển đổi giao diện"><span data-theme-icon>🌙</span></button>
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
            <div class="alert alert-success">✅ Tạo category thành công!</div>
        </c:if>
        <c:if test="${param.success == 'update'}">
            <div class="alert alert-success">✅ Cập nhật category thành công!</div>
        </c:if>
        <c:if test="${param.success == 'delete'}">
            <div class="alert alert-success">✅ Xóa category thành công!</div>
        </c:if>
        <c:if test="${not empty loi}">
            <div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div>
        </c:if>

        <c:set var="formCategory" value="${not empty categorySua ? categorySua : categoryForm}"/>
        <div class="cat-grid">
            <!-- FORM PANEL -->
            <section class="panel">
                <div class="panel-header">
                    <div class="panel-title">
                        <c:choose>
                            <c:when test="${not empty categorySua}">✏️ Cập nhật Category #${categorySua.id}</c:when>
                            <c:otherwise>➕ Tạo Category mới</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="panel-body">
                    <form action="${pageContext.request.contextPath}/Category" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <c:choose>
                            <c:when test="${not empty categorySua}">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="${categorySua.id}">
                            </c:when>
                            <c:otherwise>
                                <input type="hidden" name="action" value="create">
                            </c:otherwise>
                        </c:choose>

                        <div class="form-group">
                            <label class="form-label" for="shopId">Shop ID <span class="required">*</span></label>
                            <input type="number" id="shopId" name="shopId" class="dash-input" min="1" value="${formCategory.shopId}" required placeholder="Nhập ID của Shop...">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="categoryName">Tên Category <span class="required">*</span></label>
                            <input type="text" id="categoryName" name="categoryName" class="dash-input"
                                   value="${fn:escapeXml(formCategory.categoryName)}" required placeholder="Ví dụ: Đồ ăn nhanh, Đồ uống...">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="status">Trạng thái</label>
                            <select id="status" name="status" class="dash-input">
                                <option value="ACTIVE" ${fn:toUpperCase(formCategory.status) == 'ACTIVE' ? 'selected' : ''}>ACTIVE (Hiển thị)</option>
                                <option value="HIDDEN" ${fn:toUpperCase(formCategory.status) == 'HIDDEN' ? 'selected' : ''}>HIDDEN (Ẩn)</option>
                            </select>
                        </div>

                        <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:20px;">
                            <button type="submit" class="btn btn-primary">
                                <c:choose>
                                    <c:when test="${not empty categorySua}">✓ Cập nhật</c:when>
                                    <c:otherwise>+ Thêm mới</c:otherwise>
                                </c:choose>
                            </button>
                            <c:if test="${not empty categorySua}">
                                <a href="${pageContext.request.contextPath}/Category" class="btn btn-ghost">✕ Hủy</a>
                            </c:if>
                        </div>
                    </form>
                </div>
            </section>

            <!-- LIST PANEL -->
            <section class="panel">
                <div class="panel-header">
                    <div class="panel-title">Danh sách Category (${fn:length(danhsach)})</div>
                </div>
                <div class="panel-body" style="padding: 0;">
                    <c:choose>
                        <c:when test="${empty danhsach}">
                            <div class="empty-state">
                                <div class="e-icon">📂</div>
                                <div class="e-title">Chưa có category nào trong hệ thống</div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="dash-table-wrap">
                                <table class="dash-table">
                                    <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Shop ID</th>
                                        <th>Tên Category</th>
                                        <th>Trạng thái</th>
                                        <th>Thao tác</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="category" items="${danhsach}">
                                        <tr>
                                            <td>#<c:out value="${category.id}"/></td>
                                            <td><c:out value="${category.shopId}"/></td>
                                            <td><strong style="color:var(--text-main);"><c:out value="${category.categoryName}"/></strong></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${fn:toUpperCase(category.status) == 'ACTIVE'}">
                                                        <span class="badge badge-success">ACTIVE</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-neutral"><c:out value="${category.status}"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div style="display:flex;gap:8px;flex-wrap:wrap;">
                                                    <a href="${pageContext.request.contextPath}/Category?action=edit&id=${category.id}" class="btn btn-sm btn-outline">Sửa</a>
                                                    <form style="display:inline;"
                                                          action="${pageContext.request.contextPath}/Category"
                                                          method="post"
                                                          onsubmit="return confirm('Xác nhận XÓA category [${fn:escapeXml(fn:replace(fn:replace(category.categoryName,'\\','\\\\'),"'","\\'"))}]?')">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="id" value="${category.id}">
                                                        <button type="submit" class="btn btn-sm btn-danger-outline">Xóa</button>
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
            </section>
        </div>
    </div>
</main>

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

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
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
