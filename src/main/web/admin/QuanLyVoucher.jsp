<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 1}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Quản lý Voucher - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        :root[data-theme="dark"] {
            --bg-base: #0f172a; --bg-sidebar: #1e293b; --bg-panel: #1e293b; --bg-input: #0f172a;
            --bg-hover: #1e293b; --text-main: #f8fafc; --text-muted: #94a3b8; --text-dim: #64748b;
            --border-color: #334155; --topbar-bg: rgba(30, 41, 59, 0.8);
        }
        .avatar-wrapper { position: relative; }
        .avatar-dropdown { display: none; position: fixed; background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: var(--dash-shadow-md); min-width: 220px; z-index: 500; }
        .avatar-dropdown.open { display: block; }
        .dropdown-header { padding: 14px 16px; border-bottom: 1px solid var(--border-color); }
        .dropdown-header .d-name { font-size: 14px; font-weight: 700; color: var(--text-main); }
        .dropdown-header .d-email { font-size: 12px; color: var(--text-muted); margin-top: 2px; }
        .dropdown-body { padding: 6px 0 8px; }
        .dropdown-link { display: flex; align-items: center; gap: 10px; padding: 10px 16px; font-size: 13px; color: var(--text-muted); cursor: pointer; }
        .dropdown-link:hover { background: var(--bg-input); color: var(--text-main); }
        .dropdown-divider { height: 1px; background: var(--border-color); margin: 4px 0; }
        .dropdown-link.danger { color: var(--danger); }

        .toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .voucher-code-pill { font-family: monospace; font-weight: 700; background: var(--bg-input); padding: 3px 8px; border-radius: 6px; border: 1px dashed var(--border-color); }

        /* ══════════ REDESIGNED BEAUTIFUL VOUCHER MODAL ══════════ */
        #voucherModal .pob-modal-box {
            max-width: 620px;
            border-radius: 24px;
            border: 1px solid var(--border-color);
            background: var(--bg-panel);
            box-shadow: 0 25px 60px rgba(0, 0, 0, 0.35);
            overflow: hidden;
        }
        #voucherModal .modal-header {
            padding: 20px 24px;
            background: linear-gradient(135deg, rgba(255,90,31,0.06) 0%, rgba(255,152,0,0.08) 100%);
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        #voucherModal .m-name {
            font-size: 18px;
            font-weight: 800;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        #voucherModal .modal-sub {
            font-size: 12.5px;
            color: var(--text-muted);
            margin-top: 2px;
        }
        #voucherModal .modal-close {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            border: 1px solid var(--border-color);
            background: var(--bg-input);
            color: var(--text-muted);
            font-size: 20px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s;
            line-height: 1;
        }
        #voucherModal .modal-close:hover {
            background: #ef4444;
            color: #fff;
            border-color: #ef4444;
        }
        #voucherModal .modal-body {
            padding: 24px;
            max-height: calc(85vh - 140px);
            overflow-y: auto;
        }
        #voucherModal .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        #voucherModal .form-full {
            grid-column: 1 / -1;
        }
        #voucherModal .form-label {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-main);
            margin-bottom: 6px;
            display: block;
        }
        #voucherModal .form-label .required {
            color: #ef4444;
        }
        #voucherModal .form-control, #voucherModal .form-select {
            width: 100%;
            padding: 11px 14px;
            border-radius: 12px;
            border: 1.5px solid var(--border-color);
            background: var(--bg-input);
            color: var(--text-main);
            font-size: 13.5px;
            font-family: inherit;
            transition: all 0.15s;
        }
        #voucherModal .form-control:focus, #voucherModal .form-select:focus {
            outline: none;
            border-color: #FF5A1F;
            box-shadow: 0 0 0 4px rgba(255,90,31,0.15);
            background: var(--bg-panel);
        }
        #voucherModal .form-hint {
            font-size: 11.5px;
            color: var(--text-dim);
            margin-top: 5px;
        }
        #voucherModal .modal-footer {
            padding: 16px 24px;
            background: var(--bg-panel);
            border-top: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 12px;
        }
        #voucherModal .btn-ghost-modal {
            padding: 11px 22px;
            border-radius: 12px;
            font-size: 13.5px;
            font-weight: 700;
            background: var(--bg-input);
            color: var(--text-muted);
            border: 1px solid var(--border-color);
            cursor: pointer;
            transition: all 0.15s;
        }
        #voucherModal .btn-ghost-modal:hover {
            background: var(--border-color);
            color: var(--text-main);
        }
        #voucherModal .btn-save-modal {
            padding: 11px 26px;
            border-radius: 12px;
            font-size: 13.5px;
            font-weight: 700;
            background: linear-gradient(135deg, #FF5A1F, #E14A0F);
            color: #fff;
            border: none;
            cursor: pointer;
            box-shadow: 0 4px 14px rgba(255,90,31,0.35);
            transition: all 0.15s;
        }
        #voucherModal .btn-save-modal:hover {
            opacity: 0.92;
            transform: translateY(-1px);
        }
    </style>
</head>
<body class="dash-body admin-theme">
<c:set var="adminActive" value="/admin/vouchers" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">confirmation_number</span> Quản lý Voucher / Khuyến mãi</h1>
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
        <c:if test="${param.success eq 'create'}"><div class="alert alert-success">✅ Đã tạo voucher!</div></c:if>
        <c:if test="${param.success eq 'update'}"><div class="alert alert-success">✅ Đã cập nhật voucher!</div></c:if>
        <c:if test="${param.success eq 'toggle'}"><div class="alert alert-success">✅ Đã đổi trạng thái voucher!</div></c:if>
        <c:if test="${param.success eq 'delete'}"><div class="alert alert-success">✅ Đã xoá voucher!</div></c:if>
        <c:if test="${not empty loi}"><div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div></c:if>

        <div class="toolbar">
            <div style="font-size:13px;color:var(--text-muted);">Tổng số: <strong>${vouchers.size()}</strong> voucher</div>
            <button type="button" class="btn btn-primary" onclick="openCreateModal()">+ Tạo voucher mới</button>
        </div>

        <div class="panel">
            <div class="panel-body" style="padding:0;">
                <div class="dash-table-wrap">
                    <table class="dash-table">
                        <thead>
                        <tr>
                            <th>Mã</th>
                            <th>Loại</th>
                            <th>Giá trị</th>
                            <th>Đơn tối thiểu</th>
                            <th>Lượt dùng</th>
                            <th>Hiệu lực</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="v" items="${vouchers}">
                            <tr>
                                <td><span class="voucher-code-pill"><c:out value="${v.code}"/></span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${v.voucherType == 'PERCENT'}">Giảm %</c:when>
                                        <c:when test="${v.voucherType == 'FIXED'}">Giảm cố định</c:when>
                                        <c:otherwise>Miễn phí ship</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${v.voucherType == 'PERCENT'}">
                                            ${v.value}%<c:if test="${not empty v.maxDiscount}"> (tối đa <fmt:formatNumber value="${v.maxDiscount}" type="number" maxFractionDigits="0"/>đ)</c:if>
                                        </c:when>
                                        <c:when test="${v.voucherType == 'FIXED'}">
                                            <fmt:formatNumber value="${v.value}" type="number" maxFractionDigits="0"/>đ
                                        </c:when>
                                        <c:otherwise>Toàn bộ phí ship</c:otherwise>
                                    </c:choose>
                                </td>
                                <td><fmt:formatNumber value="${v.minOrderValue}" type="number" maxFractionDigits="0"/>đ</td>
                                <td>${v.usedCount}<c:if test="${not empty v.usageLimit}"> / ${v.usageLimit}</c:if></td>
                                <td style="font-size:11.5px;color:var(--text-dim);">
                                    <c:if test="${not empty v.startDate}">Từ ${v.startDateDisplay}<br></c:if>
                                    <c:if test="${not empty v.endDate}">Đến ${v.endDateDisplay}</c:if>
                                    <c:if test="${empty v.startDate && empty v.endDate}">Không giới hạn</c:if>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${v.active}"><span class="badge badge-success">Đang bật</span></c:when>
                                        <c:otherwise><span class="badge badge-neutral">Đã tắt</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="white-space:nowrap;">
                                    <button type="button" class="btn btn-sm btn-ghost" onclick='openEditModal(${v.id}, "${fn:escapeXml(v.code)}", "${v.voucherType}", ${v.value}, ${v.minOrderValue}, ${not empty v.maxDiscount ? v.maxDiscount : "null"}, ${not empty v.usageLimit ? v.usageLimit : "null"}, "${not empty v.startDate ? v.startDate : ""}", "${not empty v.endDate ? v.endDate : ""}")'>✏️ Sửa</button>
                                    <form method="post" action="${pageContext.request.contextPath}/admin/vouchers" style="display:inline;" onsubmit="return pobGuardSubmit(this)">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="toggle">
                                        <input type="hidden" name="id" value="${v.id}">
                                        <button type="submit" class="btn btn-sm btn-warning">${v.active ? '⏸ Tắt' : '▶ Bật'}</button>
                                    </form>
                                    <form method="post" action="${pageContext.request.contextPath}/admin/vouchers" style="display:inline;" onsubmit="return confirm('Xoá voucher này? Không thể hoàn tác.') && pobGuardSubmit(this)">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="${v.id}">
                                        <button type="submit" class="btn btn-sm btn-danger">🗑 Xoá</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty vouchers}">
                            <tr><td colspan="8" class="empty-state">Chưa có voucher nào.</td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
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

<!-- MODAL TẠO/SỬA VOUCHER -->
<div class="pob-modal-overlay ${not empty loi ? 'open' : ''}" id="voucherModal">
    <div class="pob-modal-box">
        <div class="modal-header">
            <div>
                <div class="m-name" id="modalTitle">🎁 ${formAction == 'update' ? 'Sửa voucher' : 'Tạo voucher mới'}</div>
                <div class="modal-sub">Cấu hình thông tin mã giảm giá cho toàn hệ thống</div>
            </div>
            <button type="button" class="modal-close" onclick="closeModal()" title="Đóng">×</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/admin/vouchers" id="voucherForm">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" id="formAction" value="${not empty formAction ? formAction : 'create'}">
            <input type="hidden" name="id" id="formId" value="${voucherForm.id}">
            <div class="modal-body">
                <div class="form-grid">
                    <div class="form-group form-full">
                        <label class="form-label">Mã voucher <span class="required">*</span></label>
                        <input type="text" name="code" id="fCode" class="form-control" placeholder="VD: SALE50K"
                               value="${fn:escapeXml(voucherForm.code)}" required maxlength="50" style="text-transform:uppercase;font-weight:700;letter-spacing:1px;">
                        <div class="form-hint">Chỉ chữ in hoa, số hoặc gạch ngang (3 - 50 ký tự).</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Loại giảm giá <span class="required">*</span></label>
                        <select name="voucherType" id="fType" class="form-select" onchange="onTypeChange()">
                            <option value="PERCENT" ${empty voucherForm.voucherType || voucherForm.voucherType == 'PERCENT' ? 'selected' : ''}>Giảm theo %</option>
                            <option value="FIXED" ${voucherForm.voucherType == 'FIXED' ? 'selected' : ''}>Giảm số tiền cố định</option>
                            <option value="FREESHIP" ${voucherForm.voucherType == 'FREESHIP' ? 'selected' : ''}>Miễn phí vận chuyển</option>
                        </select>
                    </div>
                    <div class="form-group" id="valueGroup">
                        <label class="form-label" id="valueLabel">Giá trị giảm (%) <span class="required">*</span></label>
                        <input type="number" name="value" id="fValue" class="form-control" min="0" step="1" value="${voucherForm.value}" placeholder="0">
                    </div>
                    <div class="form-group" id="maxDiscountGroup">
                        <label class="form-label">Giảm tối đa (đ, áp dụng cho %)</label>
                        <input type="text" name="maxDiscount" id="fMaxDiscount" class="form-control" data-money="true" value="${voucherForm.maxDiscount}" placeholder="0">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Giá trị đơn tối thiểu (đ)</label>
                        <input type="text" name="minOrderValue" id="fMinOrderValue" class="form-control" data-money="true" value="${not empty voucherForm ? voucherForm.minOrderValue : 0}" placeholder="0">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Giới hạn lượt dùng</label>
                        <input type="number" name="usageLimit" id="fUsageLimit" class="form-control" min="1" step="1" value="${voucherForm.usageLimit}" placeholder="Không giới hạn">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Thời gian bắt đầu</label>
                        <input type="datetime-local" name="startDate" id="fStartDate" class="form-control" value="${voucherForm.startDate}">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Thời gian kết thúc</label>
                        <input type="datetime-local" name="endDate" id="fEndDate" class="form-control" value="${voucherForm.endDate}">
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-ghost-modal" onclick="closeModal()">Hủy bỏ</button>
                <button type="submit" class="btn-save-modal">💾 Lưu voucher</button>
            </div>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/form-guard.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/money-format.js"></script>
<script>
function setMoneyField(id, rawVal) {
    var el = document.getElementById(id);
    if (!el) return;
    var digits = String(rawVal || '').replace(/\D/g, '');
    el.value = digits ? digits.replace(/\B(?=(\d{3})+(?!\d))/g, '.') : '';
}
</script>
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

    var modal = document.getElementById('voucherModal');

    function onTypeChange() {
        var type = document.getElementById('fType').value;
        var valueGroup = document.getElementById('valueGroup');
        var maxDiscountGroup = document.getElementById('maxDiscountGroup');
        var valueLabel = document.getElementById('valueLabel');
        if (type === 'FREESHIP') {
            valueGroup.style.display = 'none';
            maxDiscountGroup.style.display = 'none';
        } else {
            valueGroup.style.display = '';
            maxDiscountGroup.style.display = type === 'PERCENT' ? '' : 'none';
            valueLabel.textContent = type === 'PERCENT' ? 'Giá trị giảm (%) *' : 'Số tiền giảm (đ) *';
        }
    }

    function openCreateModal() {
        document.getElementById('modalTitle').textContent = '🎁 Tạo voucher mới';
        document.getElementById('formAction').value = 'create';
        document.getElementById('formId').value = '';
        document.getElementById('voucherForm').reset();
        onTypeChange();
        modal.classList.add('open');
    }

    function openEditModal(id, code, type, value, minOrderValue, maxDiscount, usageLimit, startDate, endDate) {
        document.getElementById('modalTitle').textContent = '✏️ Sửa voucher #' + id;
        document.getElementById('formAction').value = 'update';
        document.getElementById('formId').value = id;
        document.getElementById('fCode').value = code;
        document.getElementById('fType').value = type;
        document.getElementById('fValue').value = value;
        setMoneyField('fMinOrderValue', minOrderValue);
        setMoneyField('fMaxDiscount', maxDiscount === null ? '' : maxDiscount);
        document.getElementById('fUsageLimit').value = usageLimit === null ? '' : usageLimit;
        document.getElementById('fStartDate').value = startDate ? startDate.substring(0, 16) : '';
        document.getElementById('fEndDate').value = endDate ? endDate.substring(0, 16) : '';
        onTypeChange();
        modal.classList.add('open');
    }

    function closeModal() { modal.classList.remove('open'); }
    modal.addEventListener('click', function(e) { if (e.target === modal) closeModal(); });

    <c:if test="${not empty loi}">
        onTypeChange();
    </c:if>
</script>
</body>
</html>
