<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="/app-functions" prefix="app" %>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 1}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Duyệt rút tiền Shop - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-theme.css">
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

        /* Tab lọc theo trạng thái, kèm số lượng thật từ DB — thay cho <select> cũ */
        .status-tabs { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 20px; }
        .status-tab { display: inline-flex; align-items: center; gap: 8px; padding: 8px 16px; border-radius: 999px; border: 1px solid var(--border-color); background: var(--bg-panel); color: var(--text-muted); font-size: 13px; font-weight: 700; text-decoration: none; }
        .status-tab:hover { border-color: var(--primary); color: var(--primary); }
        .status-tab.active { background: var(--primary); border-color: var(--primary); color: #fff; box-shadow: var(--cta-shadow, 0 8px 20px rgba(255,59,31,.25)); }
        .status-tab-count { font-size: 11px; font-weight: 800; padding: 1px 8px; border-radius: 999px; background: var(--bg-input); color: var(--text-main); }
        .status-tab.active .status-tab-count { background: rgba(255,255,255,.25); color: #fff; }


        .shop-cell { font-weight: 700; color: var(--text-main); }
        .bank-info { display: flex; flex-direction: column; gap: 2px; }
        .bank-name { font-weight: 600; color: var(--text-main); }
        .bank-account { font-size: 12px; color: var(--text-muted); font-family: 'Courier New', monospace; }
        .bank-holder { font-size: 11px; color: var(--text-dim); text-transform: uppercase; }

        .status-pill { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; white-space: nowrap; }
        .status-pill.PENDING  { background: var(--warning-light); color: var(--warning-dark); }
        .status-pill.APPROVED { background: var(--success-light); color: var(--success-dark); }
        .status-pill.REJECTED { background: var(--danger-light); color: var(--danger-dark); }
        .status-pill .dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }

        .action-group { display: flex; gap: 8px; flex-wrap: wrap; }
        .action-done { font-size: 12px; color: var(--text-dim); font-style: italic; }

        /* Reject modal — dùng lại .pob-modal-overlay/.pob-modal-box chung, chỉ thêm phần thân riêng */
        .modal-icon { font-size: 36px; margin-bottom: 14px; color: var(--danger); }
        .modal-title { font-size: 17px; font-weight: 700; color: var(--text-main); margin-bottom: 16px; }
        .modal-label { font-size: 12px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; margin-bottom: 6px; }
        .modal-textarea { width: 100%; padding: 10px 12px; border-radius: 12px; border: 1.5px solid var(--border-color); background: var(--bg-input); color: var(--text-main); font-size: 14px; resize: vertical; min-height: 90px; }
        .modal-textarea:focus { outline: none; border-color: var(--danger); }
        .modal-actions { display: flex; gap: 10px; margin-top: 16px; }

        .toast { position: fixed; bottom: 24px; right: 24px; padding: 12px 20px; border-radius: 10px; font-size: 14px; font-weight: 700; z-index: 9999; display: none; animation: slideUp .3s ease; }
        .toast.success { background: #16a34a; color: #fff; }
        .toast.error   { background: #dc2626; color: #fff; }
        @keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }

        .pager { display: flex; gap: 8px; padding: 16px; justify-content: center; }
        .pager a { padding: 6px 12px; border-radius: 999px; border: 1px solid var(--border-color); color: var(--text-muted); font-size: 13px; font-weight: 600; }
        .pager a.active, .pager a:hover { background: var(--primary); color: #fff; border-color: var(--primary); }

        .note-box { margin-top: 16px; background: var(--warning-light); border: 1px solid rgba(255,179,0,.35); border-radius: 14px; padding: 14px 16px; font-size: 13px; color: var(--warning-dark); display: flex; gap: 10px; align-items: flex-start; }
        .note-box .material-symbols-outlined { font-size: 20px; flex-shrink: 0; }
    </style>
</head>
<body class="dash-body admin-theme">

<c:set var="adminActive" value="/admin/duyet-rut-tien-shop" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">account_balance</span> Duyệt rút tiền Shop</h1>
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

        <%-- Thống kê thật từ DB, không phải toàn bộ hệ thống rút tiền tự động như mock --%>
        <div class="stats-grid">
            <div class="stat-card${pendingCount > 0 ? ' danger stat-alert' : ''}">
                <div>
                    <div style="font-size:12px;color:var(--text-dim);font-weight:600;">Đang chờ duyệt</div>
                    <div class="stat-num">${pendingCount}</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">hourglass_top</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div style="font-size:12px;color:var(--text-dim);font-weight:600;">Đã duyệt</div>
                    <div class="stat-num">${approvedCount}</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">check_circle</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div style="font-size:12px;color:var(--text-dim);font-weight:600;">Từ chối</div>
                    <div class="stat-num">${rejectedCount}</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">cancel</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div style="font-size:12px;color:var(--text-dim);font-weight:600;">Tổng yêu cầu</div>
                    <div class="stat-num">${totalAll}</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">receipt_long</span></div>
            </div>
        </div>

        <%-- Tab lọc trạng thái (server-side, có phân trang thật nên không lọc phía client) --%>
        <div class="status-tabs">
            <a href="?" class="status-tab${empty statusFilter ? ' active' : ''}">Tất cả <span class="status-tab-count">${totalAll}</span></a>
            <a href="?status=PENDING" class="status-tab${statusFilter eq 'PENDING' ? ' active' : ''}">Đang chờ <span class="status-tab-count">${pendingCount}</span></a>
            <a href="?status=APPROVED" class="status-tab${statusFilter eq 'APPROVED' ? ' active' : ''}">Đã duyệt <span class="status-tab-count">${approvedCount}</span></a>
            <a href="?status=REJECTED" class="status-tab${statusFilter eq 'REJECTED' ? ' active' : ''}">Từ chối <span class="status-tab-count">${rejectedCount}</span></a>
        </div>

        <%-- Table --%>
        <div class="panel">
            <div class="panel-header">
                <div class="panel-title"><span class="material-symbols-outlined tb-icon-sm">account_balance</span> Danh sách yêu cầu rút tiền</div>
            </div>
            <div class="panel-body" style="padding:0;">
                <c:choose>
                    <c:when test="${empty withdrawals}">
                        <div class="empty-state">
                            <div class="e-icon">🏦</div>
                            <div class="e-title">Không có yêu cầu rút tiền nào</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                    <div class="dash-table-wrap">
                    <table class="dash-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Shop</th>
                                <th>Số tiền</th>
                                <th>Ngân hàng nhận</th>
                                <th>Thời gian</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="w" items="${withdrawals}" varStatus="st">
                                <tr id="row-${w.id}">
                                    <td style="font-size:12px;color:var(--text-dim)">#${w.id}</td>
                                    <td class="shop-cell"><c:out value="${w.shopName}"/></td>
                                    <td style="font-weight:800;font-size:14.5px;color:var(--danger)">
                                        -₫<fmt:formatNumber value="${w.amount}" pattern="#,##0"/>
                                    </td>
                                    <td>
                                        <div class="bank-info">
                                            <span class="bank-name"><c:out value="${w.bankName}"/></span>
                                            <span class="bank-account"><c:out value="${w.bankAccountNumber}"/></span>
                                            <span class="bank-holder"><c:out value="${w.bankAccountHolder}"/></span>
                                        </div>
                                    </td>
                                    <td style="font-size:12px;white-space:nowrap">
                                        ${app:formatDateTime(w.requestedAt)}
                                        <c:if test="${not empty w.processedAt}">
                                            <div style="color:var(--text-dim);margin-top:2px">
                                                → ${app:formatDateTime(w.processedAt)}
                                            </div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <span class="status-pill ${w.status}" id="status-${w.id}">
                                            <span class="dot"></span>
                                            <c:choose>
                                                <c:when test="${w.status eq 'PENDING'}">Đang chờ</c:when>
                                                <c:when test="${w.status eq 'APPROVED'}">Đã duyệt</c:when>
                                                <c:otherwise>Từ chối</c:otherwise>
                                            </c:choose>
                                        </span>
                                        <c:if test="${not empty w.rejectReason}">
                                            <div style="font-size:11px;color:var(--danger);margin-top:3px"><c:out value="${w.rejectReason}"/></div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${w.status eq 'PENDING'}">
                                                <div class="action-group">
                                                    <button type="button" class="btn btn-sm btn-primary js-approve" data-id="${w.id}" data-shop="${fn:escapeXml(w.shopName)}" data-amount="${w.amount}"><span class="material-symbols-outlined" style="font-size:15px;">check</span> Duyệt</button>
                                                    <button type="button" class="btn btn-sm btn-danger-outline js-reject" data-id="${w.id}"><span class="material-symbols-outlined" style="font-size:15px;">close</span> Từ chối</button>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="action-done">
                                                    <c:out value="${not empty w.processedByName ? w.processedByName : 'Admin'}"/>
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    </div>
                    </c:otherwise>
                </c:choose>
            </div>
            <c:if test="${totalPages > 1}">
                <div class="pager">
                    <c:if test="${currentPage > 1}"><a href="?status=${statusFilter}&page=${currentPage-1}">← Trước</a></c:if>
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <a href="?status=${statusFilter}&page=${p}" class="${p eq currentPage ? 'active' : ''}">${p}</a>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}"><a href="?status=${statusFilter}&page=${currentPage+1}">Sau →</a></c:if>
                </div>
            </c:if>
        </div>

        <%-- Note about manual transfer --%>
        <div class="note-box">
            <span class="material-symbols-outlined">info</span>
            <div><strong>Lưu ý:</strong> Sau khi duyệt, vui lòng <strong>chuyển khoản thủ công</strong> đến số tài khoản ngân hàng của shop.
            Hệ thống chỉ ghi nhận trạng thái — không tự động chuyển tiền.</div>
        </div>

    </div>
</main>

<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${sessionScope.account.userName}</div>
        <div class="d-email">${sessionScope.account.email}</div>
        <span class="d-role">Super Admin</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/admin/profile" class="dropdown-link"><span class="material-symbols-outlined" style="font-size:16px;">person</span> Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/admin/change-password" class="dropdown-link"><span class="material-symbols-outlined" style="font-size:16px;">lock</span> Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger"><span class="material-symbols-outlined" style="font-size:16px;">logout</span> Đăng xuất</a>
    </div>
</div>

<%-- Reject Modal --%>
<div class="pob-modal-overlay" id="rejectModal">
    <div class="pob-modal-box">
        <div style="padding:28px;">
            <div class="modal-icon">✕</div>
            <div class="modal-title">Từ chối yêu cầu rút tiền</div>
            <div class="modal-label">Lý do từ chối *</div>
            <textarea class="modal-textarea" id="rejectReason" placeholder="Nhập lý do từ chối..."></textarea>
            <div class="modal-actions">
                <button type="button" class="btn btn-ghost" style="flex:1;" onclick="closeRejectModal()">Hủy</button>
                <button type="button" class="btn btn-danger" style="flex:1;" onclick="doReject()">Xác nhận từ chối</button>
            </div>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script>
    var rejectId = 0;
    var BASE = '${pageContext.request.contextPath}/admin/duyet-rut-tien-shop';

    function showToast(msg, type) {
        var t = document.getElementById('toast');
        t.textContent = msg;
        t.className = 'toast ' + type;
        t.style.display = 'block';
        setTimeout(function() { t.style.display = 'none'; }, 3500);
    }

    function doApprove(wdId, shopName, amount) {
        pobConfirm('Xác nhận duyệt ₫' + amount.toLocaleString('vi-VN') + ' cho shop ' + shopName + '?\nHãy chuyển khoản thủ công sau khi duyệt.').then(function(ok) {
            if (ok) postAction(wdId, 'approve', null);
        });
    }

    function openReject(wdId) {
        rejectId = wdId;
        document.getElementById('rejectReason').value = '';
        document.getElementById('rejectModal').classList.add('open');
    }

    function closeRejectModal() {
        document.getElementById('rejectModal').classList.remove('open');
    }

    function doReject() {
        var reason = document.getElementById('rejectReason').value.trim();
        if (!reason) { alert('Vui lòng nhập lý do từ chối'); return; }
        closeRejectModal();
        postAction(rejectId, 'reject', reason);
    }

    function postAction(wdId, action, reason) {
        var fd = new FormData();
        fd.append('csrfToken', '${sessionScope.csrfToken}');
        fd.append('withdrawalId', wdId);
        fd.append('action', action);
        if (reason) fd.append('reason', reason);

        fetch(BASE, { method: 'POST', body: fd, headers: { 'X-CSRF-Token': '${sessionScope.csrfToken}' } })
            .then(function(r){ return r.json(); })
            .then(function(json) {
                if (json.success) {
                    showToast(action === 'approve' ? 'Đã duyệt thành công!' : 'Đã từ chối!', 'success');
                    setTimeout(function(){ location.reload(); }, 1200);
                } else {
                    showToast(json.message || 'Thao tác thất bại', 'error');
                }
            })
            .catch(function(){ showToast('Lỗi kết nối server', 'error'); });
    }

    document.getElementById('rejectModal').addEventListener('click', function(e) {
        if (e.target === this) closeRejectModal();
    });

    // Nút Duyệt/Từ chối dùng data-attribute thay vì nhét tên shop thẳng vào chuỗi JS trong onclick
    // (tên shop có thể chứa dấu nháy đơn và làm vỡ cú pháp JS) — an toàn hơn cách cũ.
    document.querySelectorAll('.js-approve').forEach(function (btn) {
        btn.addEventListener('click', function () {
            doApprove(Number(btn.dataset.id), btn.dataset.shop, Number(btn.dataset.amount));
        });
    });
    document.querySelectorAll('.js-reject').forEach(function (btn) {
        btn.addEventListener('click', function () { openReject(Number(btn.dataset.id)); });
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
