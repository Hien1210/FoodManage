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
    <title>Quản lý Loại Topping - ${not empty currentShop.shopName ? currentShop.shopName : 'Cửa hàng'}</title>
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

        /* Toolbar bảng */
        .table-toolbar { padding: 16px 20px; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
        .action-cell { display: flex; gap: 6px; flex-wrap: wrap; justify-content: center; }
        .inline-form { display: inline; }

        /* Modal thêm/sửa loại topping */
        .modal-header { padding: 20px 26px; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; }
        .modal-body { padding: 24px 26px; }
        .modal-close { background: none; border: none; font-size: 18px; cursor: pointer; color: var(--text-dim); }
        .modal-close:hover { color: var(--danger); }
        .modal-footer { padding: 20px 26px; border-top: 1px solid var(--border-color); display: flex; justify-content: flex-end; gap: 12px; }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="/shop/topping-categories" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">sell</span> Quản lý loại Topping</h1>
        </div>
        <div class="topbar-right">
            <a href="${pageContext.request.contextPath}/shop/topping-categories?action=trash" class="btn btn-danger-outline btn-sm">🗑️ Thùng rác</a>
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
            <div class="alert alert-success">✅ Tạo loại topping thành công!</div>
        </c:if>
        <c:if test="${param.success eq 'update'}">
            <div class="alert alert-success">✅ Cập nhật loại topping thành công!</div>
        </c:if>
        <c:if test="${param.success eq 'delete'}">
            <div class="alert alert-success">✅ Xóa loại topping thành công!</div>
        </c:if>
        <c:if test="${not empty loi}">
            <div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div>
        </c:if>

        <%-- Mini Stats --%>
        <div class="stats-grid">
            <div class="stat-card">
                <div><div style="font-size:12px;color:var(--text-dim);font-weight:600;">Tổng loại topping</div><div class="stat-num">${fn:length(danhsach)}</div></div>
                <div class="stat-icon">🏷️</div>
            </div>
        </div>

        <c:set var="formCat" value="${not empty categorySua ? categorySua : categoryForm}"/>

        <div class="panel">
            <div class="table-toolbar">
                <div class="panel-title" style="margin:0;">Danh sách loại topping</div>
                <button type="button" class="btn btn-primary" onclick="openCategoryModal()">➕ Thêm loại topping mới</button>
            </div>

            <c:choose>
                <c:when test="${empty danhsach}">
                    <div class="empty-state">
                        <div class="e-icon">🏷️</div>
                        <div class="e-title">Chưa có loại topping nào.</div>
                        <div class="e-sub"><a href="javascript:void(0)" onclick="openCategoryModal()" style="color:var(--primary);font-weight:700;">Thêm loại topping đầu tiên ngay →</a></div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="dash-table-wrap">
                        <table class="dash-table card-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Tên loại topping</th>
                                    <th>Áp dụng cho loại sản phẩm</th>
                                    <th>Mô tả</th>
                                    <th style="text-align:center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="cat" items="${danhsach}" varStatus="vs">
                                    <tr>
                                        <td>${vs.index + 1}</td>
                                        <td>
                                            <strong><c:out value="${cat.name}"/></strong>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty cat.categoryNames}">
                                                    <c:forEach var="cn" items="${cat.categoryNames}">
                                                        <span class="badge badge-info" style="margin:2px;"><c:out value="${cn}"/></span>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-neutral">Tất cả loại sản phẩm</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:out value="${cat.description}" default="—"/>
                                        </td>
                                        <td>
                                            <div class="action-cell">
                                                <a href="${pageContext.request.contextPath}/shop/topping-categories?action=edit&id=${cat.id}"
                                                   class="btn btn-sm btn-outline">✏️ Sửa</a>
                                                <form class="inline-form"
                                                      action="${pageContext.request.contextPath}/shop/topping-categories"
                                                      method="post"
                                                      onsubmit="return pobConfirmDelete(event, this, 'Bạn có chắc chắn muốn xóa loại Topping <strong>«${fn:escapeXml(cat.name)}»</strong> không?', 'Xóa loại Topping')">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="${cat.id}">
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

<%-- ── MODAL THÊM / SỬA LOẠI TOPPING ── --%>
<div class="pob-modal-overlay" id="categoryModal">
    <div class="pob-modal-box" style="max-width:480px;">
        <div class="modal-header">
            <div class="panel-title">
                <c:choose>
                    <c:when test="${not empty categorySua}">✏️ Cập nhật loại topping</c:when>
                    <c:otherwise>➕ Thêm loại topping mới</c:otherwise>
                </c:choose>
            </div>
            <button type="button" class="modal-close" onclick="closeCategoryModal()">✕</button>
        </div>
        <div class="modal-body">
            <form action="${pageContext.request.contextPath}/shop/topping-categories" method="post" id="categoryForm">
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
                    <label class="form-label" for="categoryName">Tên loại topping <span class="required">*</span></label>
                    <input type="text" id="categoryName" name="categoryName" class="form-control"
                           value="${fn:escapeXml(formCat.name)}"
                           placeholder="Ví dụ: Nước sốt, Phô mai, Rau củ..."
                           required autofocus>
                </div>

                <div class="form-group">
                    <label class="form-label">Áp dụng cho loại sản phẩm</label>
                    <div style="display:flex;flex-wrap:wrap;gap:10px;border:1px solid var(--border-color);border-radius:8px;padding:12px;max-height:160px;overflow-y:auto;">
                        <c:choose>
                            <c:when test="${empty danhSachLoaiSanPham}">
                                <span style="font-size:12.5px;color:var(--text-dim);">Chưa có loại sản phẩm nào — hãy tạo loại sản phẩm trước.</span>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="pc" items="${danhSachLoaiSanPham}">
                                    <label style="display:flex;align-items:center;gap:6px;font-size:13px;font-weight:500;cursor:pointer;">
                                        <input type="checkbox" name="productCategoryId" value="${pc.id}"
                                               ${formCat.categoryIds.contains(pc.id) ? 'checked' : ''}>
                                        <c:out value="${pc.categoryName}"/>
                                    </label>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <p style="font-size:12px;color:var(--text-dim);margin-top:6px;">Không chọn gì nếu topping này dùng chung cho mọi món (VD: đũa/thìa). Chọn 1 hoặc nhiều loại nếu chỉ áp dụng riêng cho món thuộc (các) loại đó (VD: "Topping trà sữa" chỉ hiện khi chọn món loại "Trà sữa"/"Cà phê").</p>
                </div>

                <div class="form-group">
                    <label class="form-label" for="description">Mô tả</label>
                    <textarea id="description" name="description" class="form-control form-textarea" rows="3"
                              placeholder="Mô tả ngắn về loại topping (không bắt buộc)">${fn:escapeXml(formCat.description)}</textarea>
                </div>

                <c:if test="${not empty loi}">
                    <div class="alert alert-danger" style="margin-top:16px;">⚠️ <c:out value="${loi}"/></div>
                </c:if>
            </form>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-ghost" onclick="closeCategoryModal()">Hủy</button>
            <button type="submit" form="categoryForm" class="btn btn-primary">
                <c:choose>
                    <c:when test="${not empty categorySua}">💾 Lưu thay đổi</c:when>
                    <c:otherwise>➕ Thêm mới</c:otherwise>
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
    const modal = document.getElementById('categoryModal');
    const isEditMode = ${ not empty categorySua ? 'true' : 'false' };
    const hasError   = ${ not empty loi ? 'true' : 'false' };

    function openCategoryModal() { modal.classList.add('open'); }
    function closeCategoryModal() {
        modal.classList.remove('open');
        if (isEditMode) {
            window.location.href = '${pageContext.request.contextPath}/shop/topping-categories';
        }
    }
    modal.addEventListener('click', e => { if (e.target === modal) closeCategoryModal(); });
    document.addEventListener('DOMContentLoaded', () => {
        if (isEditMode || hasError) openCategoryModal();
    });

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
