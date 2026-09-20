<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="currentShop" value="${sessionScope.currentShop}" scope="request"/>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 2}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Combo - ${not empty currentShop.shopName ? currentShop.shopName : 'Cửa hàng'}</title>
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
        /* Bố cục 2 cột: danh sách combo (trái) + Combo Builder (phải, dính khi cuộn) */
        .combo-layout { display: grid; grid-template-columns: minmax(0, 1fr) 400px; gap: 24px; align-items: start; }
        .combo-builder { position: sticky; top: 0; }
        .combo-list-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
        .combo-list-head h3 { margin: 0; font-size: 18px; font-weight: 700; color: var(--text-main); display: flex; align-items: center; gap: 10px; }
        .combo-count { font-family: var(--font-family); font-size: 12px; font-weight: 700; padding: 2px 10px; border-radius: 999px; background: var(--primary-light); color: var(--primary); }
        .combo-card { display: flex; gap: 18px; background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 16px; padding: 16px; margin-bottom: 16px; box-shadow: var(--dash-shadow-sm); transition: transform .18s, box-shadow .18s; }
        .combo-card:hover { transform: translateY(-3px); box-shadow: var(--dash-shadow-md); }
        .combo-thumb { position: relative; width: 132px; height: 132px; flex-shrink: 0; border-radius: 14px; overflow: hidden; background: var(--bg-input); display: flex; align-items: center; justify-content: center; color: var(--text-dim); }
        .combo-thumb img { width: 100%; height: 100%; object-fit: cover; }
        .combo-thumb .material-symbols-outlined { font-size: 46px; }
        .combo-save-tag { position: absolute; top: 8px; left: 8px; padding: 3px 9px; border-radius: 999px; font-size: 11px; font-weight: 800; color: #fff; background: var(--brand-gradient); }
        .combo-main { flex: 1; min-width: 0; display: flex; flex-direction: column; }
        .combo-title-row { display: flex; align-items: flex-start; justify-content: space-between; gap: 10px; }
        .combo-name { font-family: var(--font-display); font-weight: 700; font-size: 17px; color: var(--text-main); }
        .combo-desc { font-size: 12.5px; color: var(--text-muted); margin-top: 2px; }
        .combo-items-list { list-style: none; margin: 10px 0 0; padding: 10px 12px; background: var(--bg-input); border-radius: 12px; font-size: 13px; color: var(--text-main); display: flex; flex-direction: column; gap: 4px; }
        .combo-item-qty { font-weight: 800; color: var(--primary); }
        .combo-item-size { font-size: 11.5px; color: var(--text-dim); margin-left: 4px; }
        .combo-foot { margin-top: auto; padding-top: 12px; display: flex; align-items: flex-end; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
        .combo-price-wrap { display: flex; align-items: baseline; gap: 8px; flex-wrap: wrap; }
        .combo-price { font-family: var(--font-display); font-weight: 700; font-size: 21px; color: var(--primary); }
        .combo-orig { font-size: 13px; color: var(--text-dim); text-decoration: line-through; }
        .combo-save-text { font-size: 11.5px; font-weight: 700; color: var(--success-dark); background: var(--success-light); padding: 2px 8px; border-radius: 999px; }
        .combo-actions { display: flex; gap: 8px; }
        .combo-actions .btn { gap: 4px; }
        .combo-actions .material-symbols-outlined { font-size: 17px; }
        .tb-icon-sm { font-size: 22px; color: var(--primary); }
        .cb-step { display: flex; align-items: center; gap: 8px; font-weight: 700; font-size: 13.5px; color: var(--text-main); margin: 6px 0 12px; }
        .cb-step:not(.cb-first) { margin-top: 20px; padding-top: 16px; border-top: 1px dashed var(--border-color); }
        .cb-step-num { width: 22px; height: 22px; border-radius: 50%; background: var(--primary); color: #fff; font-size: 12px; font-weight: 800; display: inline-flex; align-items: center; justify-content: center; }
        .combo-summary { background: var(--bg-input); border-radius: 12px; padding: 12px 14px; display: flex; flex-direction: column; gap: 6px; font-size: 13px; color: var(--text-muted); }
        .combo-summary .cs-row { display: flex; justify-content: space-between; gap: 10px; }
        .combo-summary strong { color: var(--text-main); }
        .combo-summary .cs-save strong { color: var(--success-dark); }
        .combo-summary .cs-save.cs-loss strong { color: var(--danger-dark); }
        .combo-form-actions { display: flex; gap: 10px; margin-top: 18px; }
        .combo-form-actions .btn-primary { flex: 1; }
        @media (max-width: 1180px) {
            .combo-layout { grid-template-columns: 1fr; }
            .combo-builder { position: static; order: -1; }
        }
        @media (max-width: 560px) {
            .combo-card { flex-direction: column; }
            .combo-thumb { width: 100%; height: 160px; }
        }
        .form-row { display: flex; gap: 12px; flex-wrap: wrap; }
        .form-row .form-group { flex: 1; min-width: 180px; }
        .item-row { display: flex; gap: 8px; align-items: center; margin-bottom: 8px; }
        .item-row select { flex: 1; }
        .item-row input[type="number"] { width: 70px; }
        .btn-remove-item { background: none; border: none; color: var(--danger); font-size: 18px; cursor: pointer; padding: 0 4px; }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="/shop/combo" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">lunch_dining</span> Quản lý Combo</h1>
        </div>
        <div class="topbar-right">
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
        <c:if test="${param.saved eq '1'}">
            <div class="alert alert-success">✅ Đã lưu combo thành công.</div>
        </c:if>
        <c:if test="${param.deleted eq '1'}">
            <div class="alert alert-danger">🗑️ Đã xóa combo.</div>
        </c:if>
        <c:if test="${param.error eq 'invalid'}">
            <div class="alert alert-danger">⚠️ Thông tin không hợp lệ, vui lòng kiểm tra lại.</div>
        </c:if>

        <%-- Thống kê nhanh: tính từ danh sách combo thật (giá gốc = tổng giá size x số lượng của các món trong combo) --%>
        <c:set var="cmbTotal" value="${fn:length(combos)}"/>
        <c:set var="cmbActive" value="0"/>
        <c:set var="pctSum" value="0"/>
        <c:set var="pctCnt" value="0"/>
        <c:forEach items="${combos}" var="cb">
            <c:if test="${cb.active}"><c:set var="cmbActive" value="${cmbActive + 1}"/></c:if>
            <c:set var="origSum" value="0"/>
            <c:forEach items="${cb.items}" var="it"><c:set var="origSum" value="${origSum + it.sizePrice * it.quantity}"/></c:forEach>
            <c:if test="${origSum > cb.comboPrice and cb.comboPrice > 0}">
                <c:set var="pctSum" value="${pctSum + (origSum - cb.comboPrice) * 100 / origSum}"/>
                <c:set var="pctCnt" value="${pctCnt + 1}"/>
            </c:if>
        </c:forEach>

        <div class="stats-grid">
            <div class="stat-card">
                <div>
                    <div class="stat-label">Tổng combo</div>
                    <div class="stat-num">${cmbTotal}</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">lunch_dining</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Đang bán</div>
                    <div class="stat-num">${cmbActive}</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">storefront</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Tiết kiệm trung bình</div>
                    <div class="stat-num"><c:choose>
                        <c:when test="${pctCnt > 0}"><fmt:formatNumber value="${pctSum / pctCnt}" type="number" maxFractionDigits="1"/>%</c:when>
                        <c:otherwise>—</c:otherwise>
                    </c:choose></div>
                    <div class="stat-trend" style="color:var(--text-dim);">so với mua lẻ từng món</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">percent</span></div>
            </div>
        </div>

        <div class="combo-layout">
            <%-- CỘT TRÁI: danh sách combo --%>
            <section class="combo-list-col">
                <div class="combo-list-head">
                    <h3>Danh sách Combo <span class="combo-count">${cmbTotal}</span></h3>
                </div>
                <c:choose>
                    <c:when test="${empty combos}">
                        <div class="empty-state">
                            <div class="e-icon">🎁</div>
                            <div class="e-title">Chưa có combo nào</div>
                            <div class="e-sub">Tạo combo đầu tiên ở khung "Combo Builder" bên cạnh.</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${combos}" var="combo">
                            <c:set var="orig" value="0"/>
                            <c:set var="thumb" value=""/>
                            <c:forEach items="${combo.items}" var="item">
                                <c:set var="orig" value="${orig + item.sizePrice * item.quantity}"/>
                                <c:if test="${empty thumb and not empty item.productImageUrl}"><c:set var="thumb" value="${item.productImageUrl}"/></c:if>
                            </c:forEach>
                            <div class="combo-card"
                                 data-combo-id="${combo.id}"
                                 data-combo-name="${fn:escapeXml(combo.name)}"
                                 data-combo-price="${combo.comboPrice}"
                                 data-combo-desc="${fn:escapeXml(combo.description)}"
                                 data-combo-items='[<c:forEach items="${combo.items}" var="item" varStatus="is">{"productSizeId":${item.productSizeId},"quantity":${item.quantity}}${is.last ? "" : ","}</c:forEach>]'>
                                <div class="combo-thumb">
                                    <c:choose>
                                        <c:when test="${not empty thumb}"><img src="<c:out value='${thumb}'/>" alt="" loading="lazy"></c:when>
                                        <c:otherwise><span class="material-symbols-outlined">lunch_dining</span></c:otherwise>
                                    </c:choose>
                                    <c:if test="${orig > combo.comboPrice and combo.comboPrice > 0}">
                                        <span class="combo-save-tag">-<fmt:formatNumber value="${(orig - combo.comboPrice) * 100 / orig}" type="number" maxFractionDigits="0"/>%</span>
                                    </c:if>
                                </div>
                                <div class="combo-main">
                                    <div class="combo-title-row">
                                        <div class="combo-name"><c:out value="${combo.name}"/></div>
                                        <c:choose>
                                            <c:when test="${combo.active}"><span class="badge badge-success"><span class="badge-dot"></span>Đang bán</span></c:when>
                                            <c:otherwise><span class="badge badge-neutral">Tạm ngưng</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${not empty combo.description}">
                                        <div class="combo-desc"><c:out value="${combo.description}"/></div>
                                    </c:if>
                                    <c:if test="${not empty combo.items}">
                                        <ul class="combo-items-list">
                                            <c:forEach items="${combo.items}" var="item">
                                                <li><span class="combo-item-qty">${item.quantity}×</span> <c:out value="${item.productName}"/> <span class="combo-item-size"><c:out value="${item.sizeName}"/></span></li>
                                            </c:forEach>
                                        </ul>
                                    </c:if>
                                    <div class="combo-foot">
                                        <div class="combo-price-wrap">
                                            <span class="combo-price"><fmt:formatNumber value="${combo.comboPrice}" type="number" maxFractionDigits="0"/>đ</span>
                                            <c:if test="${orig > combo.comboPrice and combo.comboPrice > 0}">
                                                <span class="combo-orig"><fmt:formatNumber value="${orig}" type="number" maxFractionDigits="0"/>đ</span>
                                                <span class="combo-save-text">Tiết kiệm <fmt:formatNumber value="${orig - combo.comboPrice}" type="number" maxFractionDigits="0"/>đ</span>
                                            </c:if>
                                        </div>
                                        <div class="combo-actions">
                                            <button type="button" class="btn btn-ghost btn-sm" onclick="editCombo(this.closest('.combo-card'))"><span class="material-symbols-outlined">edit</span> Sửa</button>
                                            <form method="post" action="${pageContext.request.contextPath}/shop/combo" style="display:inline"
                                                  onsubmit="return pobConfirmDelete(event, this, 'Bạn có chắc chắn muốn xóa Combo <strong>${fn:escapeXml(combo.name)}</strong> không?', 'Xóa Combo')">
                                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="comboId" value="${combo.id}">
                                                <button type="submit" class="btn btn-danger-outline btn-sm"><span class="material-symbols-outlined">delete</span> Xóa</button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </section>

            <%-- CỘT PHẢI: Combo Builder (tạo / sửa combo) --%>
            <aside class="combo-builder dash-card">
                <div class="dash-card-header"><h3><span class="material-symbols-outlined tb-icon-sm">construction</span> <span id="comboFormTitle">Tạo Combo mới</span></h3></div>
                <div class="dash-card-body">
                    <form method="post" action="${pageContext.request.contextPath}/shop/combo" id="comboForm">
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="comboId" id="comboIdInput" value="">

                        <div class="cb-step cb-first"><span class="cb-step-num">1</span> Thông tin gói combo</div>
                        <div class="form-group">
                            <label class="form-label" for="comboNameInput">Tên combo *</label>
                            <input type="text" class="dash-input" name="name" id="comboNameInput" required placeholder="VD: Combo Đôi">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="comboDescInput">Mô tả</label>
                            <input type="text" class="dash-input" name="description" id="comboDescInput" placeholder="VD: 2 ly cà phê + 1 bánh mì">
                        </div>

                        <div class="cb-step"><span class="cb-step-num">2</span> Món trong combo</div>
                        <div class="form-group">
                            <div id="itemRows">
                                <div class="item-row">
                                    <select name="productSizeId[]" class="dash-input" style="flex:1;">
                                        <option value="" data-price="0">-- Chọn sản phẩm + size --</option>
                                        <c:forEach items="${allSizes}" var="ps">
                                            <option value="${ps.id}" data-price="${ps.price}">${fn:escapeXml(productNameById[ps.productId])} — ${fn:escapeXml(ps.sizeName)} (<fmt:formatNumber value="${ps.price}" type="number" maxFractionDigits="0"/>đ)</option>
                                        </c:forEach>
                                    </select>
                                    <input type="number" name="quantity[]" value="1" min="1" class="dash-input">
                                    <button type="button" class="btn-remove-item" onclick="this.parentElement.remove(); updateComboSummary()">✕</button>
                                </div>
                            </div>
                            <button type="button" class="btn btn-outline btn-sm" style="margin-top:8px;" onclick="addItemRow()">+ Thêm món</button>
                        </div>

                        <div class="cb-step"><span class="cb-step-num">3</span> Định giá</div>
                        <div class="form-group">
                            <label class="form-label" for="comboPriceInput">Giá combo (đ) *</label>
                            <input type="text" class="dash-input" name="comboPrice" id="comboPriceInput" data-money="true" required placeholder="VD: 85.000">
                        </div>
                        <div class="combo-summary" id="comboSummary">
                            <div class="cs-row"><span>Tổng giá gốc các món</span><strong id="csOrig">0đ</strong></div>
                            <div class="cs-row cs-save" id="csSaveRow"><span id="csSaveLabel">Tiết kiệm cho khách</span><strong id="csSave">—</strong></div>
                        </div>

                        <div class="combo-form-actions">
                            <button type="submit" class="btn btn-primary" id="comboSubmitBtn">Tạo Combo</button>
                            <button type="button" class="btn btn-ghost" id="comboCancelEditBtn" style="display:none;" onclick="cancelEditCombo()">Hủy sửa</button>
                        </div>
                    </form>
                </div>
            </aside>
        </div>
    </div>
</main>

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

<script src="${pageContext.request.contextPath}/assets/js/money-format.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script>
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

var ITEM_ROW_TEMPLATE_HTML = document.querySelector('#itemRows .item-row').outerHTML;

function addItemRow(productSizeId, quantity) {
    var wrap = document.createElement('div');
    wrap.innerHTML = ITEM_ROW_TEMPLATE_HTML;
    var row = wrap.firstElementChild;
    row.querySelector('select').value = productSizeId || '';
    row.querySelector('input[type="number"]').value = quantity || '1';
    document.getElementById('itemRows').appendChild(row);
    if (typeof updateComboSummary === 'function') updateComboSummary();
}

function fmtVnd(n) {
    return Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.') + 'đ';
}

// Tổng giá gốc = tổng (giá size x số lượng) các dòng đã chọn; so với giá combo đang nhập
function updateComboSummary() {
    var orig = 0;
    document.querySelectorAll('#itemRows .item-row').forEach(function (row) {
        var opt = row.querySelector('select').selectedOptions[0];
        var price = opt ? parseFloat(opt.getAttribute('data-price')) || 0 : 0;
        var qty = parseInt(row.querySelector('input[type="number"]').value, 10) || 0;
        orig += price * Math.max(qty, 0);
    });
    var comboPrice = parseInt((document.getElementById('comboPriceInput').value || '').replace(/\D/g, ''), 10) || 0;
    document.getElementById('csOrig').textContent = fmtVnd(orig);
    var saveRow = document.getElementById('csSaveRow');
    var label = document.getElementById('csSaveLabel');
    var val = document.getElementById('csSave');
    saveRow.classList.remove('cs-loss');
    if (!orig || !comboPrice) {
        label.textContent = 'Tiết kiệm cho khách';
        val.textContent = '—';
    } else if (comboPrice <= orig) {
        label.textContent = 'Tiết kiệm cho khách';
        val.textContent = fmtVnd(orig - comboPrice) + ' (' + Math.round((orig - comboPrice) * 100 / orig) + '%)';
    } else {
        label.textContent = 'Giá combo cao hơn mua lẻ';
        val.textContent = fmtVnd(comboPrice - orig);
        saveRow.classList.add('cs-loss');
    }
}
document.getElementById('itemRows').addEventListener('input', updateComboSummary);
document.getElementById('itemRows').addEventListener('change', updateComboSummary);
document.getElementById('comboPriceInput').addEventListener('input', updateComboSummary);

function editCombo(card) {
    var comboId = card.dataset.comboId;
    var items = JSON.parse(card.dataset.comboItems || '[]');

    document.getElementById('comboIdInput').value = comboId;
    document.getElementById('comboNameInput').value = card.dataset.comboName || '';
    var price = Math.round(parseFloat(card.dataset.comboPrice) || 0);
    document.getElementById('comboPriceInput').value = price ? String(price).replace(/\B(?=(\d{3})+(?!\d))/g, '.') : '';
    document.getElementById('comboDescInput').value = card.dataset.comboDesc || '';

    var rowsWrap = document.getElementById('itemRows');
    rowsWrap.innerHTML = '';
    if (items.length === 0) {
        addItemRow();
    } else {
        items.forEach(function (item) {
            addItemRow(item.productSizeId, item.quantity);
        });
    }

    document.getElementById('comboFormTitle').textContent = 'Sửa Combo';
    document.getElementById('comboSubmitBtn').textContent = 'Lưu thay đổi';
    document.getElementById('comboCancelEditBtn').style.display = 'inline-flex';
    updateComboSummary();

    document.getElementById('comboForm').scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function cancelEditCombo() {
    document.getElementById('comboIdInput').value = '';
    document.getElementById('comboForm').reset();

    var rowsWrap = document.getElementById('itemRows');
    rowsWrap.innerHTML = '';
    addItemRow();

    document.getElementById('comboFormTitle').textContent = 'Tạo Combo mới';
    document.getElementById('comboSubmitBtn').textContent = 'Tạo Combo';
    document.getElementById('comboCancelEditBtn').style.display = 'none';
    updateComboSummary();
}
</script>
</body>
</html>
