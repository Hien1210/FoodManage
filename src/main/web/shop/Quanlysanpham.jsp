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
    <title>Quản lý Sản Phẩm - ${not empty currentShop.shopName ? currentShop.shopName : 'Cửa hàng'}</title>
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

        /* Toolbar bảng: filter + search + đếm kết quả */
        .table-toolbar { padding: 16px 20px; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
        .toolbar-left { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .result-count { font-size: 12px; color: var(--text-dim); }
        .result-count strong { color: var(--text-main); }

        /* Chip loại sản phẩm */
        .cat-chips { display: flex; gap: 8px; flex-wrap: wrap; padding: 16px 20px 4px; }
        .cat-chip { display: inline-flex; align-items: center; gap: 8px; padding: 7px 15px; border-radius: 999px; border: 1px solid var(--border-color); background: var(--bg-panel); color: var(--text-muted); font-size: 13px; font-weight: 700; cursor: pointer; font-family: inherit; }
        .cat-chip:hover { border-color: var(--primary); color: var(--primary); }
        .cat-chip.active { background: var(--primary); border-color: var(--primary); color: #fff; box-shadow: 0 8px 20px rgba(227, 37, 10, .25); }
        .cat-chip-count { font-size: 11px; font-weight: 800; padding: 1px 8px; border-radius: 999px; background: var(--bg-input); color: var(--text-main); }
        .cat-chip.active .cat-chip-count { background: rgba(255, 255, 255, .25); color: #fff; }

        /* Thẻ món */
        .menu-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(440px, 1fr)); gap: 16px; padding: 16px 20px 20px; }
        .menu-card { display: flex; gap: 16px; padding: 14px; border: 1px solid var(--border-color); border-radius: 16px; background: var(--bg-panel); transition: transform .18s, box-shadow .18s; }
        .menu-card:hover { transform: translateY(-3px); box-shadow: var(--dash-shadow-md); }
        .menu-thumb { position: relative; width: 116px; height: 116px; flex-shrink: 0; border-radius: 14px; overflow: hidden; background: var(--bg-input); display: flex; align-items: center; justify-content: center; }
        .menu-thumb img { width: 100%; height: 100%; object-fit: cover; }
        .menu-thumb-fallback { display: flex; align-items: center; justify-content: center; color: var(--text-dim); width: 100%; height: 100%; }
        .menu-thumb-fallback .material-symbols-outlined { font-size: 42px; }
        .menu-thumb-flag { position: absolute; left: 0; right: 0; bottom: 0; text-align: center; padding: 4px 0; font-size: 11px; font-weight: 800; color: #fff; background: rgba(45, 36, 33, .72); }
        .menu-card.is-oos .menu-thumb img, .menu-card.is-hidden .menu-thumb img { filter: grayscale(1); opacity: .7; }
        .menu-card.is-hidden { background: var(--bg-input); }
        .menu-body { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 6px; }
        .menu-title-row { display: flex; align-items: flex-start; justify-content: space-between; gap: 10px; }
        .product-name { font-family: var(--font-display); font-weight: 700; font-size: 16.5px; color: var(--text-main); }
        .menu-desc { font-size: 12.5px; color: var(--text-muted); display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .menu-meta { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; font-size: 12px; color: var(--text-dim); }
        .menu-meta-item strong { color: var(--text-main); }
        .product-category { font-size: 11px; font-weight: 700; color: var(--text-muted); background: var(--bg-input); padding: 2px 9px; border-radius: 999px; display: inline-block; }
        .menu-price-row { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .price-main { font-family: var(--font-display); font-weight: 700; color: var(--primary); font-size: 18px; }
        .menu-actions { margin-top: auto; display: flex; align-items: center; gap: 8px; }
        .menu-actions .btn { gap: 4px; }
        .menu-actions .material-symbols-outlined { font-size: 17px; }
        @media (max-width: 560px) {
            .menu-grid { grid-template-columns: 1fr; padding: 12px; }
            .menu-card { flex-direction: column; }
            .menu-thumb { width: 100%; height: 170px; }
        }

        /* Size chips */
        .size-list { display: flex; flex-wrap: wrap; gap: 5px; }
        .size-chip { display: inline-flex; align-items: center; gap: 4px; padding: 3px 9px; border-radius: 999px; font-size: 11px; font-weight: 700; background: var(--primary-light); color: var(--primary-dark); border: 1px solid rgba(227,37,10,.22); }
        .size-chip .size-price { color: var(--text-muted); font-weight: 500; }

        .stock-num { font-weight: 700; }
        .stock-num.low { color: var(--danger); }
        .stock-num.ok { color: var(--success-dark); }
        .action-cell { display: flex; gap: 6px; flex-wrap: wrap; justify-content: center; }
        .inline-form { display: inline; }
        .table-footer { padding: 14px 20px; border-top: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; font-size: 12px; color: var(--text-dim); }

        /* Form grid trong modal thêm/sửa sản phẩm */
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .form-full { grid-column: 1 / -1; }

        /* Size section trong modal */
        .size-section { border: 1px solid var(--border-color); border-radius: var(--radius-md); overflow: hidden; }
        .size-section-header { padding: 12px 16px; background: var(--bg-input); display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); }
        .size-section-title { font-size: 12px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: .4px; }
        .size-rows { padding: 12px; }
        .size-row { display: grid; grid-template-columns: 1fr 1fr auto auto; gap: 8px; align-items: center; margin-bottom: 10px; }
        .size-row:last-child { margin-bottom: 0; }
        .size-oos-toggle { display: flex; align-items: center; gap: 4px; font-size: 11px; font-weight: 600; color: var(--danger); white-space: nowrap; cursor: pointer; }
        .size-oos-toggle input { accent-color: var(--danger); cursor: pointer; }
        .btn-remove-size { width: 32px; height: 32px; border-radius: var(--radius-sm); background: var(--danger-light); color: var(--danger); border: 1px solid var(--danger); cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 16px; flex-shrink: 0; }
        .btn-remove-size:hover { background: var(--danger); color: #fff; }
        .btn-add-size { margin-top: 8px; padding: 8px 16px; background: var(--primary-light); color: var(--primary-dark); border: 1px dashed var(--primary); border-radius: var(--radius-sm); font-size: 12px; font-weight: 700; cursor: pointer; width: 100%; }
        .btn-add-size:hover { background: var(--primary); color: #fff; border-style: solid; }

        /* Ảnh preview */
        .img-upload-row { display: flex; gap: 8px; }
        .img-upload-row .form-control { flex: 1; }
        .btn-upload { flex-shrink: 0; padding: 0 16px; background: var(--primary-light); color: var(--primary-dark); border: 1px solid var(--primary); border-radius: var(--radius-sm); font-size: 12px; font-weight: 700; cursor: pointer; white-space: nowrap; }
        .btn-upload:hover { background: var(--primary); color: #fff; }
        .btn-upload:disabled { opacity: .6; cursor: not-allowed; }
        .upload-status { font-size: 12px; color: var(--text-muted); min-height: 16px; margin-top: 6px; }
        .img-preview { width: 100%; height: 240px; border: 2px dashed var(--border-color); border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; margin-top: 8px; overflow: hidden; background: var(--bg-input); }
        .img-preview img { width: 100%; height: 100%; object-fit: cover; }
        .img-preview .placeholder { font-size: 28px; color: var(--text-dim); }
        .modal-header { padding: 20px 26px; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; }
        .modal-body { padding: 24px 26px; }
        .modal-close { background: none; border: none; font-size: 18px; cursor: pointer; color: var(--text-dim); }
        .modal-footer { padding: 20px 26px; border-top: 1px solid var(--border-color); display: flex; justify-content: flex-end; gap: 12px; }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="/shop/products" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">menu_book</span> Quản lý sản phẩm</h1>
        </div>
        <div class="topbar-right">
            <input type="text" class="dash-input" style="width:220px;"
                   placeholder="🔍 Tìm tên sản phẩm..."
                   oninput="filterProducts(this.value)">
            <a href="${pageContext.request.contextPath}/shop/products?action=trash" class="btn btn-danger-outline btn-sm">🗑️ Thùng rác</a>
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
        <c:if test="${param.success eq 'create'}">
            <div class="alert alert-success">✅ Thêm sản phẩm thành công!</div>
        </c:if>
        <c:if test="${param.success eq 'update'}">
            <div class="alert alert-success">✅ Cập nhật sản phẩm thành công!</div>
        </c:if>
        <c:if test="${param.success eq 'delete'}">
            <div class="alert alert-success">✅ Xóa sản phẩm thành công!</div>
        </c:if>
        <c:if test="${not empty loi}">
            <div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div>
        </c:if>

        <div class="stats-grid">
            <div class="stat-card">
                <div><div style="font-size:12px;color:var(--text-dim);font-weight:600;">Tổng sản phẩm</div><div class="stat-num">${fn:length(danhsach)}</div></div>
                <div class="stat-icon">🍽️</div>
            </div>
            <div class="stat-card">
                <div><div style="font-size:12px;color:var(--text-dim);font-weight:600;">Đang bán</div><div class="stat-num">${soDangBan}</div></div>
                <div class="stat-icon" style="background:var(--success-light);color:var(--success-dark);">✅</div>
            </div>
            <div class="stat-card">
                <div><div style="font-size:12px;color:var(--text-dim);font-weight:600;">Hết hàng</div><div class="stat-num">${soHetHang}</div></div>
                <div class="stat-icon" style="background:var(--warning-light);color:var(--warning-dark);">⏸️</div>
            </div>
            <div class="stat-card">
                <div><div style="font-size:12px;color:var(--text-dim);font-weight:600;">Đã bán</div><div class="stat-num">${tongDaBan}</div></div>
                <div class="stat-icon" style="background:var(--danger-light);color:var(--danger);">📈</div>
            </div>
        </div>

        <div class="panel">
            <div class="table-toolbar">
                <div class="toolbar-left">
                    <select class="dash-input" style="width:auto;" onchange="filterByStatus(this.value)">
                        <option value="">Tất cả trạng thái</option>
                        <option value="ACTIVE">✅ Đang bán</option>
                        <option value="HIDDEN">🙈 Tạm ẩn</option>
                        <option value="OUT_OF_STOCK">⏸️ Hết hàng</option>
                    </select>
                    <span class="result-count">Tổng: <strong id="visibleCount">${fn:length(danhsach)}</strong> sản phẩm</span>
                </div>
                <button type="button" class="btn btn-primary" onclick="openProductModal()">➕ Thêm sản phẩm mới</button>
            </div>

            <c:choose>
                <c:when test="${empty danhsach}">
                    <div class="empty-state">
                        <div class="e-icon">🍽️</div>
                        <div class="e-title">Chưa có sản phẩm nào trong cửa hàng.</div>
                        <div class="e-sub"><a href="javascript:void(0)" onclick="openProductModal()" style="color:var(--primary);font-weight:700;">Thêm sản phẩm đầu tiên ngay →</a></div>
                    </div>
                </c:when>
                <c:otherwise>
                    <%-- Chip loại sản phẩm kèm số món (đếm từ danh sách thật) --%>
                    <div class="cat-chips" id="catChips">
                        <button type="button" class="cat-chip active" data-type="">Tất cả <span class="cat-chip-count">${fn:length(danhsach)}</span></button>
                        <c:forEach var="pt" items="${danhsachLoai}">
                            <c:set var="catCnt" value="0"/>
                            <c:forEach var="pp" items="${danhsach}"><c:if test="${pp.categoryId == pt.id}"><c:set var="catCnt" value="${catCnt + 1}"/></c:if></c:forEach>
                            <button type="button" class="cat-chip" data-type="${pt.id}"><c:out value="${pt.categoryName}"/> <span class="cat-chip-count">${catCnt}</span></button>
                        </c:forEach>
                    </div>

                    <div class="menu-grid" id="productList">
                        <c:forEach var="product" items="${danhsach}">
                            <c:set var="pStatus" value="${fn:toUpperCase(product.staTus)}"/>
                            <div class="menu-card ${pStatus == 'HIDDEN' ? 'is-hidden' : ''} ${pStatus == 'OUT_OF_STOCK' ? 'is-oos' : ''}"
                                 data-name="${fn:escapeXml(fn:toLowerCase(product.productName))}"
                                 data-type="${product.categoryId}"
                                 data-status="${pStatus}">
                                <div class="menu-thumb">
                                    <c:choose>
                                        <c:when test="${not empty product.imageUrl && product.imageUrl != 'null'}">
                                            <img src="<c:out value='${product.imageUrl}'/>" alt="<c:out value='${product.productName}'/>" loading="lazy"
                                                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                                            <span class="menu-thumb-fallback" style="display:none"><span class="material-symbols-outlined">restaurant</span></span>
                                        </c:when>
                                        <c:otherwise><span class="menu-thumb-fallback"><span class="material-symbols-outlined">restaurant</span></span></c:otherwise>
                                    </c:choose>
                                    <c:if test="${pStatus == 'OUT_OF_STOCK'}"><span class="menu-thumb-flag">Hết hàng</span></c:if>
                                    <c:if test="${pStatus == 'HIDDEN'}"><span class="menu-thumb-flag">Tạm ẩn</span></c:if>
                                </div>

                                <div class="menu-body">
                                    <div class="menu-title-row">
                                        <div class="product-name"><c:out value="${product.productName}"/></div>
                                        <c:choose>
                                            <c:when test="${pStatus == 'ACTIVE'}"><span class="badge badge-success"><span class="badge-dot"></span>Đang bán</span></c:when>
                                            <c:when test="${pStatus == 'HIDDEN'}"><span class="badge badge-danger">Tạm ẩn</span></c:when>
                                            <c:when test="${pStatus == 'OUT_OF_STOCK'}"><span class="badge badge-warning">Hết hàng</span></c:when>
                                            <c:otherwise><span class="badge badge-neutral"><c:out value="${product.staTus}"/></span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${not empty product.description}">
                                        <div class="menu-desc"><c:out value="${product.description}"/></div>
                                    </c:if>

                                    <div class="menu-meta">
                                        <span class="product-category"><c:out value="${product.categoryName}"/></span>
                                        <span class="menu-meta-item">Tồn kho <strong class="stock-num ${product.stockQuantity <= 5 ? 'low' : 'ok'}">${product.stockQuantity}</strong></span>
                                        <span class="menu-meta-item">Đã bán <strong>${product.soldCount}</strong></span>
                                    </div>

                                    <div class="menu-price-row">
                                        <c:choose>
                                            <c:when test="${not empty product.sizes && product.sizes.size() > 0}">
                                                <span class="price-main"><fmt:formatNumber value="${product.sizes[0].price}" type="number" maxFractionDigits="0"/>đ</span>
                                                <c:if test="${not (product.sizes.size() == 1 and (product.sizes[0].sizeName == 'Mặc định' or product.sizes[0].sizeName == 'Tiêu chuẩn'))}">
                                                    <div class="size-list">
                                                        <c:forEach var="sz" items="${product.sizes}">
                                                            <span class="size-chip">
                                                                <c:out value="${sz.sizeName}"/>
                                                                <span class="size-price"><fmt:formatNumber value="${sz.price}" type="number" maxFractionDigits="0"/>đ</span>
                                                            </span>
                                                        </c:forEach>
                                                    </div>
                                                </c:if>
                                            </c:when>
                                            <c:otherwise><span style="font-size:12.5px;color:var(--text-dim);">Chưa có giá / size</span></c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="menu-actions">
                                        <a href="${pageContext.request.contextPath}/shop/products?action=edit&id=${product.id}"
                                           class="btn btn-sm btn-ghost"><span class="material-symbols-outlined">edit</span> Sửa món</a>
                                        <form class="inline-form"
                                              action="${pageContext.request.contextPath}/shop/products"
                                              method="post"
                                              onsubmit="return pobConfirmDelete(event, this, 'Bạn có chắc chắn muốn xóa sản phẩm <strong>«${fn:escapeXml(product.productName)}»</strong> không?', 'Xóa sản phẩm')">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${product.id}">
                                            <button type="submit" class="btn btn-sm btn-danger-outline"><span class="material-symbols-outlined">delete</span></button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    <div class="empty-state" id="menuFilterEmpty" style="display:none;">
                        <div class="e-icon">🔎</div>
                        <div class="e-title">Không có món nào khớp bộ lọc.</div>
                    </div>
                    <div class="table-footer">
                        <span>Hiển thị <strong id="showCount">${fn:length(danhsach)}</strong> sản phẩm</span>
                        <span style="color:var(--text-dim);font-size:11px;">Bấm "Sửa món" để quản lý các size của từng sản phẩm</span>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<%-- ── MODAL THÊM / SỬA SẢN PHẨM ── --%>
<div class="pob-modal-overlay" id="productModal">
    <div class="pob-modal-box" style="max-width:720px;">
        <div class="modal-header">
            <div class="panel-title">
                <c:choose>
                    <c:when test="${not empty productSua}">✏️ Cập nhật sản phẩm</c:when>
                    <c:otherwise>➕ Thêm sản phẩm mới</c:otherwise>
                </c:choose>
            </div>
            <button type="button" class="modal-close" onclick="closeProductModal()">✕</button>
        </div>
        <div class="modal-body">
            <form action="${pageContext.request.contextPath}/shop/products" method="post" id="productForm">
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

                <div class="form-grid">
                    <div class="form-group form-full">
                        <label class="form-label" for="productName">Tên sản phẩm <span class="required">*</span></label>
                        <input type="text" id="productName" name="productName" class="form-control"
                               value="${fn:escapeXml(productSua.productName)}"
                               placeholder="Ví dụ: Cơm tấm sườn bì chả, Bún bò Huế..."
                               required autofocus>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="productTypeId">Loại sản phẩm <span class="required">*</span></label>
                        <select id="productTypeId" name="productTypeId" class="form-select" required>
                            <option value="">-- Chọn loại --</option>
                            <c:forEach var="pt" items="${danhsachLoai}">
                                <option value="${pt.id}" ${productSua.categoryId == pt.id ? 'selected' : ''}>
                                    <c:out value="${pt.categoryName}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="stockQuantity">Số lượng tồn kho</label>
                        <input type="number" id="stockQuantity" name="stockQuantity" class="form-control"
                               value="${not empty productSua.stockQuantity ? productSua.stockQuantity : 0}"
                               placeholder="0" min="0">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="soldCount">Số đã bán</label>
                        <input type="number" id="soldCount" name="soldCount" class="form-control"
                               value="${not empty productSua.soldCount ? productSua.soldCount : 0}"
                               placeholder="0" min="0">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="status">Trạng thái</label>
                        <select id="status" name="status" class="form-select">
                            <option value="ACTIVE"        ${fn:toUpperCase(productSua.staTus) == 'ACTIVE'        ? 'selected' : ''}>✅ Đang bán</option>
                            <option value="HIDDEN"        ${fn:toUpperCase(productSua.staTus) == 'HIDDEN'        ? 'selected' : ''}>🙈 Tạm ẩn</option>
                            <option value="OUT_OF_STOCK"  ${fn:toUpperCase(productSua.staTus) == 'OUT_OF_STOCK'  ? 'selected' : ''}>⏸️ Hết hàng</option>
                        </select>
                    </div>

                    <div class="form-group form-full">
                        <label class="form-label" for="imageUrl">URL ảnh sản phẩm</label>
                        <div class="img-upload-row">
                            <input type="text" id="imageUrl" name="imageUrl" class="form-control"
                                   value="${fn:escapeXml(productSua.imageUrl)}"
                                   placeholder="https://..."
                                   oninput="previewImage(this.value)">
                            <button type="button" class="btn-upload" onclick="document.getElementById('productImageFile').click()">📤 Tải ảnh lên</button>
                            <input type="file" id="productImageFile" accept="image/*" style="display:none">
                        </div>
                        <div class="upload-status" id="uploadStatus"></div>
                        <div class="img-preview" id="imgPreview">
                            <c:choose>
                                <c:when test="${not empty productSua.imageUrl}"><img src="${productSua.imageUrl}" alt="Preview"></c:when>
                                <c:otherwise><span class="placeholder">🖼️</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="form-group form-full">
                        <label class="form-label" for="description">Mô tả sản phẩm</label>
                        <textarea id="description" name="description" class="form-control form-textarea"
                                  placeholder="Mô tả ngắn về nguyên liệu, hương vị..."><c:out value="${productSua.description}"/></textarea>
                    </div>

                    <div class="form-group form-full">
                        <label class="form-label">Giá & Size / Khẩu phần (tuỳ chọn)</label>
                        <div class="size-section">
                            <div class="size-section-header">
                                <span class="size-section-title">Danh sách size / Giá bán</span>
                                <span style="font-size:11px;color:var(--text-dim);">Nếu không chia size, để trống tên size và chỉ nhập giá.</span>
                            </div>
                            <div class="size-rows" id="sizeRows">
                                <c:choose>
                                    <c:when test="${not empty productSua.sizes}">
                                        <c:forEach var="sz" items="${productSua.sizes}" varStatus="loop">
                                            <div class="size-row">
                                                <input type="text" name="sizeName[]" class="form-control"
                                                       value="${fn:escapeXml(sz.sizeName == 'Mặc định' ? '' : sz.sizeName)}"
                                                       placeholder="Tên size (S, M... - để trống nếu không chia size)"
                                                       oninput="syncOutOfStockCheckboxValue(this)">
                                                <input type="text" name="sizePrice[]" class="form-control" data-money="true"
                                                       value="${sz.price}"
                                                       placeholder="Giá bán (đ)">
                                                <label class="size-oos-toggle" title="Hết hàng tạm thời">
                                                    <input type="checkbox" name="sizeOutOfStockNames" value="${fn:escapeXml(sz.sizeName)}" ${sz.outOfStock ? 'checked' : ''}>
                                                    Hết hàng
                                                </label>
                                                <button type="button" class="btn-remove-size" onclick="removeSize(this)">×</button>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="size-row">
                                            <input type="text" name="sizeName[]" class="form-control" placeholder="Tên size (S, M... - để trống nếu không chia size)"
                                                   oninput="syncOutOfStockCheckboxValue(this)">
                                            <input type="text" name="sizePrice[]" class="form-control" data-money="true" placeholder="Giá bán (đ)">
                                            <label class="size-oos-toggle" title="Hết hàng tạm thời">
                                                <input type="checkbox" name="sizeOutOfStockNames" value="">
                                                Hết hàng
                                            </label>
                                            <button type="button" class="btn-remove-size" onclick="removeSize(this)">×</button>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div style="padding:0 12px 12px;">
                                <button type="button" class="btn-add-size" onclick="addSizeRow()">＋ Thêm size</button>
                            </div>
                        </div>
                    </div>
                </div>

                <c:if test="${not empty loi}">
                    <div class="alert alert-danger" style="margin-top:16px;">⚠️ <c:out value="${loi}"/></div>
                </c:if>
            </form>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-ghost" onclick="closeProductModal()">Hủy</button>
            <button type="submit" form="productForm" class="btn btn-primary">
                <c:choose>
                    <c:when test="${not empty productSua}">💾 Lưu thay đổi</c:when>
                    <c:otherwise>➕ Thêm sản phẩm</c:otherwise>
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
    const modal = document.getElementById('productModal');
    const isEditMode = ${ not empty productSua ? 'true' : 'false' };
    const hasError   = ${ not empty loi ? 'true' : 'false' };

    function openProductModal() { modal.classList.add('open'); }
    function closeProductModal() {
        modal.classList.remove('open');
        if (isEditMode) {
            window.location.href = '${pageContext.request.contextPath}/shop/products';
        }
    }
    modal.addEventListener('click', e => { if (e.target === modal) closeProductModal(); });
    document.addEventListener('DOMContentLoaded', () => {
        if (isEditMode || hasError) openProductModal();
    });

    function addSizeRow() {
        const container = document.getElementById('sizeRows');
        const row = document.createElement('div');
        row.className = 'size-row';
        row.innerHTML = `
            <input type="text"   name="sizeName[]"  class="form-control" placeholder="Tên size (S, M... - để trống nếu không chia size)" oninput="syncOutOfStockCheckboxValue(this)">
            <input type="text"   name="sizePrice[]" class="form-control" data-money="true" placeholder="Giá bán (đ)">
            <label class="size-oos-toggle" title="Hết hàng tạm thời">
                <input type="checkbox" name="sizeOutOfStockNames" value="">
                Hết hàng
            </label>
            <button type="button" class="btn-remove-size" onclick="removeSize(this)">×</button>
        `;
        container.appendChild(row);
        if (window.initMoneyInputs) initMoneyInputs(row);
        row.querySelector('input').focus();
    }
    // Checkbox "Hết hàng" đối chiếu theo TÊN size ở server (xem ShopProductServlet.readSizes),
    // nên phải giữ value của checkbox luôn khớp với ô nhập tên size cùng dòng.
    function syncOutOfStockCheckboxValue(nameInput) {
        const row = nameInput.closest('.size-row');
        const checkbox = row ? row.querySelector('.size-oos-toggle input') : null;
        if (checkbox) checkbox.value = nameInput.value;
    }
    function removeSize(btn) {
        const rows = document.querySelectorAll('.size-row');
        if (rows.length > 1) {
            btn.closest('.size-row').remove();
        } else {
            const row = btn.closest('.size-row');
            row.querySelectorAll('input[type=text], input[type=number]').forEach(i => i.value = '');
            const checkbox = row.querySelector('.size-oos-toggle input');
            if (checkbox) { checkbox.checked = false; checkbox.value = ''; }
        }
    }

    function previewImage(url) {
        const wrap = document.getElementById('imgPreview');
        if (!url) {
            wrap.innerHTML = '<span class="placeholder">🖼️</span>';
            return;
        }
        wrap.innerHTML = '<img src="' + url + '" alt="Preview" onerror="this.parentNode.innerHTML=\'<span class=placeholder>🖼️</span>\'">';
    }

    // Cloudinary unsigned upload
    var CLOUD_NAME = 'jcnsb47f';
    var UPLOAD_PRESET = 'avatar_preset';

    document.getElementById('productImageFile').addEventListener('change', function(e) {
        var file = e.target.files[0];
        if (!file) return;
        if (file.size > 2 * 1024 * 1024) {
            document.getElementById('uploadStatus').textContent = '❌ Ảnh tối đa 2MB.';
            return;
        }
        var status = document.getElementById('uploadStatus');
        status.textContent = '⏳ Đang tải lên...';

        var formData = new FormData();
        formData.append('file', file);
        formData.append('upload_preset', UPLOAD_PRESET);
        formData.append('folder', 'products');

        fetch('https://api.cloudinary.com/v1_1/' + CLOUD_NAME + '/image/upload', {
            method: 'POST',
            body: formData
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data.secure_url) { status.textContent = '❌ Upload thất bại.'; return; }
            document.getElementById('imageUrl').value = data.secure_url;
            previewImage(data.secure_url);
            status.textContent = '✅ Tải ảnh lên thành công!';
        })
        .catch(function() { status.textContent = '❌ Lỗi kết nối.'; });
    });

    function filterProducts(keyword) { applyFilters(); }
    function filterByType(typeId) { applyFilters(); }
    function filterByStatus(status) { applyFilters(); }

    var activeCatType = '';
    var catChips = document.getElementById('catChips');
    if (catChips) {
        catChips.addEventListener('click', function (e) {
            var btn = e.target.closest('.cat-chip');
            if (!btn) return;
            catChips.querySelectorAll('.cat-chip').forEach(function (b) { b.classList.toggle('active', b === btn); });
            activeCatType = btn.getAttribute('data-type') || '';
            applyFilters();
        });
    }

    function applyFilters() {
        const kw     = document.querySelector('.topbar-right .dash-input').value.toLowerCase().trim();
        const statusSel = document.querySelector('.toolbar-left select');
        const status = statusSel ? statusSel.value : '';

        const cards = document.querySelectorAll('#productList .menu-card');
        let visible = 0;
        cards.forEach(card => {
            const name  = (card.getAttribute('data-name')   || '').toLowerCase();
            const rType = card.getAttribute('data-type')    || '';
            const rStat = card.getAttribute('data-status')  || '';
            const show  = (!kw || name.includes(kw))
                       && (!activeCatType || rType === activeCatType)
                       && (!status || rStat === status);
            card.style.display = show ? '' : 'none';
            if (show) visible++;
        });
        const el = document.getElementById('visibleCount');
        if (el) el.textContent = visible;
        const sel = document.getElementById('showCount');
        if (sel) sel.textContent = visible;
        const emptyNote = document.getElementById('menuFilterEmpty');
        if (emptyNote && cards.length) emptyNote.style.display = visible === 0 ? '' : 'none';
    }

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
