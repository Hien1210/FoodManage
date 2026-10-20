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
    <title>Quản lý sản phẩm - Super Admin</title>
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

        /* Layout riêng của trang: form + hướng dẫn (chưa có trong dashboard.css) */
        .prod-grid { display: grid; grid-template-columns: 1fr 320px; gap: 20px; }
        @media (max-width: 992px) { .prod-grid { grid-template-columns: 1fr; } }

        .desc-text { color: var(--text-muted); font-size: 12px; margin-top: 6px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .desc-empty { color: var(--text-dim); font-style: italic; font-size: 12px; margin-top: 6px; }

        .info-item { display: flex; align-items: flex-start; gap: 10px; padding: 8px 0; border-bottom: 1px solid var(--border-color); font-size: 12px; color: var(--text-muted); line-height: 1.5; }
        .info-item:last-child { border-bottom: none; }
        .info-item strong { color: var(--text-main); }
        .info-icon { width: 22px; height: 22px; border-radius: 6px; flex-shrink: 0; display: flex; align-items: center; justify-content: center; font-size: 12px; }
        .info-icon.ok { background: var(--success-light); color: var(--success-dark); }
        .info-icon.warn { background: var(--danger-light); color: var(--danger); }

        .mini-stat-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 16px; padding-top: 16px; border-top: 1px solid var(--border-color); }
        .mini-stat-box { background: var(--bg-input); border-radius: var(--radius-sm); padding: 14px; text-align: center; }
        .mini-stat-num { font-size: 26px; font-weight: 800; color: var(--text-main); }
        .mini-stat-box.gold .mini-stat-num { color: var(--warning-dark); }
        .mini-stat-label { font-size: 10px; font-weight: 700; color: var(--text-dim); text-transform: uppercase; letter-spacing: .4px; margin-top: 2px; }
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
        <a href="${pageContext.request.contextPath}/Category" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📂</span><span class="mi-label"> Danh mục món ăn</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/product" class="menu-item active">
            <span class="mi-left"><span class="mi-icon">🍽️</span><span class="mi-label"> Sản phẩm</span></span>
        </a>
    </div>
</aside>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1>🍽️ Quản lý sản phẩm</h1>
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
            <div class="alert alert-success">✅ Tạo sản phẩm thành công!</div>
        </c:if>
        <c:if test="${param.success == 'update'}">
            <div class="alert alert-success">✅ Cập nhật sản phẩm thành công!</div>
        </c:if>
        <c:if test="${param.success == 'delete'}">
            <div class="alert alert-success">✅ Xóa sản phẩm thành công!</div>
        </c:if>

        <div class="prod-grid">

            <div class="panel">
                <div class="panel-header">
                    <div class="panel-title">
                        <c:choose>
                            <c:when test="${not empty productSua}">✏️ Cập nhật sản phẩm</c:when>
                            <c:otherwise>➕ Tạo sản phẩm mới</c:otherwise>
                        </c:choose>
                    </div>
                    <c:if test="${not empty productSua}">
                        <a href="${pageContext.request.contextPath}/product" class="btn btn-sm btn-ghost">← Hủy sửa</a>
                    </c:if>
                </div>
                <div class="panel-body">
                    <c:set var="formProduct" value="${not empty productSua ? productSua : productForm}"/>
                    <form action="${pageContext.request.contextPath}/product" method="post" onsubmit="return pobGuardSubmit(this)">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <c:choose>
                            <c:when test="${not empty productSua}">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="${productSua.id}">
                            </c:when>
                            <c:otherwise>
                                <input type="hidden" name="action" value="create">
                            </c:otherwise>
                        </c:choose>

                        <div class="form-group">
                            <label class="form-label" for="productname">Tên sản phẩm <span class="required">*</span></label>
                            <input type="text" id="productname" name="productname" class="dash-input"
                                   value="${fn:escapeXml(formProduct.productName)}"
                                   placeholder="Ví dụ: Cơm tấm sườn bì chả..." required>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="shopid">Shop ID <span class="required">*</span></label>
                                <input type="number" id="shopid" name="shopid" class="dash-input"
                                       value="${formProduct.shopId}"
                                       placeholder="Nhập ID shop..." min="1" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="categoryid">Category ID <span class="required">*</span></label>
                                <input type="number" id="categoryid" name="categoryid" class="dash-input"
                                       value="${formProduct.categoryId}"
                                       placeholder="Nhập ID category..." min="1" required>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="price">Giá bán <span class="required">*</span></label>
                                <input type="text" id="price" name="price" class="dash-input"
                                       data-money="true"
                                       value="${formProduct.price}"
                                       placeholder="0" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="soldQuantity">Số lượng tồn</label>
                                <input type="number" id="stock_quantity" name="stock_quantity" class="dash-input"
                                       value="${formProduct.stockQuantity}"
                                       placeholder="0" min="0">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="soldCount">Đã bán</label>
                                <input type="number" id="soldCount" name="soldCount" class="dash-input"
                                       value="${formProduct.soldCount}"
                                       placeholder="0" min="0">
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="status">Trạng thái</label>
                                <select id="status" name="status" class="dash-input">
                                    <option value="ACTIVE" ${fn:toUpperCase(formProduct.staTus) == 'ACTIVE' ? 'selected' : ''}>Đang bán</option>
                                    <option value="HIDDEN" ${fn:toUpperCase(formProduct.staTus) == 'HIDDEN' ? 'selected' : ''}>Tạm ẩn</option>
                                    <option value="OUT_OF_STOCK" ${fn:toUpperCase(formProduct.staTus) == 'OUT_OF_STOCK' ? 'selected' : ''}>Hết hàng</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="description">Mô tả</label>
                            <textarea id="description" name="description" class="dash-input form-textarea"
                                      placeholder="Mô tả ngắn về sản phẩm..."><c:out value="${formProduct.description}"/></textarea>
                        </div>

                        <c:if test="${not empty loi}">
                            <div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div>
                        </c:if>

                        <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:20px;">
                            <button type="submit" class="btn btn-primary">
                                <c:choose>
                                    <c:when test="${not empty productSua}">💾 Lưu cập nhật</c:when>
                                    <c:otherwise>+ Tạo mới</c:otherwise>
                                </c:choose>
                            </button>
                            <c:if test="${not empty productSua}">
                                <a href="${pageContext.request.contextPath}/product" class="btn btn-ghost">✕ Hủy</a>
                            </c:if>
                        </div>
                    </form>
                </div>
            </div>

            <div class="panel">
                <div class="panel-header">
                    <div class="panel-title">📋 Hướng dẫn</div>
                </div>
                <div class="panel-body">
                    <p style="font-size:13px;color:var(--text-muted);line-height:1.7;margin-bottom:14px;">
                        Sản phẩm gắn với 1 shop và 1 category. Hệ thống sẽ kiểm tra shop/category có tồn tại trước khi lưu.
                    </p>

                    <div class="info-item">
                        <div class="info-icon ok">✓</div>
                        <div>Tên sản phẩm nên <strong>rõ nghĩa</strong> và dễ tìm kiếm</div>
                    </div>
                    <div class="info-item">
                        <div class="info-icon ok">✓</div>
                        <div>Giá bán phải là <strong>số dương</strong></div>
                    </div>
                    <div class="info-item">
                        <div class="info-icon warn">⚠</div>
                        <div>Xóa sản phẩm sẽ <strong>ẩn khỏi danh sách</strong> nếu bảng có cột xóa mềm</div>
                    </div>

                    <div class="mini-stat-grid">
                        <div class="mini-stat-box">
                            <div class="mini-stat-num">${tongSanPham}</div>
                            <div class="mini-stat-label">Tổng sản phẩm</div>
                        </div>
                        <div class="mini-stat-box gold">
                            <div class="mini-stat-num">${sanPhamDangBan}</div>
                            <div class="mini-stat-label">Đang bán</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">Danh sách sản phẩm — ${fn:length(danhsach)} bản ghi</div>
                <a href="${pageContext.request.contextPath}/product" class="btn btn-sm btn-primary">➕ Thêm mới</a>
            </div>
            <div class="panel-body" style="padding:0;">
                <c:choose>
                    <c:when test="${empty danhsach}">
                        <div class="empty-state">
                            <div class="e-icon">🍽️</div>
                            <div class="e-title">Chưa có sản phẩm nào</div>
                            <div class="e-sub">Hãy tạo sản phẩm đầu tiên bằng form bên trên.</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="dash-table-wrap">
                            <table class="dash-table">
                                <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Sản phẩm</th>
                                    <th>Shop ID</th>
                                    <th>Category ID</th>
                                    <th>Giá</th>
                                    <th>Tồn</th>
                                    <th>Đã bán</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="product" items="${danhsach}" varStatus="loop">
                                    <tr>
                                        <td>#<c:out value="${product.id}"/></td>
                                        <td>
                                            <strong style="color:var(--text-main);"><c:out value="${product.productName}"/></strong>
                                            <c:choose>
                                                <c:when test="${not empty product.description}">
                                                    <div class="desc-text"><c:out value="${product.description}"/></div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="desc-empty">Chưa có mô tả</div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><c:out value="${product.shopId}"/></td>
                                        <td><c:out value="${product.categoryId}"/></td>
                                        <td><c:out value="${product.price}"/></td>
                                        <td><c:out value="${product.stockQuantity}"/></td>
                                        <td><c:out value="${product.soldCount}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${fn:toUpperCase(product.staTus) eq 'ACTIVE' || fn:toUpperCase(product.staTus) eq 'AVAILABLE' || fn:toUpperCase(product.staTus) eq 'PUBLISHED'}">
                                                    <span class="badge badge-success">Đang bán</span>
                                                </c:when>
                                                <c:when test="${fn:toUpperCase(product.staTus) eq 'OUT_OF_STOCK'}">
                                                    <span class="badge badge-warning">Hết hàng</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-neutral"><c:out value="${product.staTus}"/></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div style="display:flex;gap:6px;flex-wrap:wrap;">
                                                <a href="${pageContext.request.contextPath}/product?action=edit&id=${product.id}"
                                                   class="btn btn-sm btn-outline" title="Sửa">✏️ Sửa</a>
                                                <form style="display:inline;"
                                                      action="${pageContext.request.contextPath}/product"
                                                      method="post"
                                                      onsubmit="return confirm('Xóa sản phẩm «${fn:escapeXml(fn:replace(fn:replace(product.productName,'\\','\\\\'),"'","\\'"))}»?') && pobGuardSubmit(this)">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="${product.id}">
                                                    <button type="submit" class="btn btn-sm btn-danger-outline" title="Xóa">🗑️ Xóa</button>
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

<script src="${pageContext.request.contextPath}/assets/js/money-format.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/form-guard.js"></script>
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
