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
    <title>Duyệt rút tiền Shop - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        .filter-bar { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; padding: 16px 20px; display: flex; align-items: flex-end; gap: 16px; flex-wrap: wrap; margin-bottom: 20px; }
        .filter-field { display: flex; flex-direction: column; gap: 5px; }
        .filter-field label { font-size: 11px; text-transform: uppercase; letter-spacing: .5px; color: var(--text-muted); font-weight: 700; }
        .filter-field select { background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 8px; padding: 9px 12px; color: var(--text-main); font-size: 13px; min-width: 180px; }

        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px; }
        .stat-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; padding: 18px; border-top: 3px solid var(--border-color); }
        .stat-card.pending { border-top-color: var(--warning); }
        .stat-card.approved { border-top-color: var(--primary); }
        .stat-card.rejected { border-top-color: var(--danger); }
        .stat-title { font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; margin-bottom: 8px; }
        .stat-value { font-size: 26px; font-weight: 800; color: var(--text-main); }

        .panel { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; }
        .panel-header { padding: 16px 20px; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; }
        .panel-title { font-size: 14px; font-weight: 700; color: var(--text-main); }

        .table-wrapper { overflow-x: auto; }
        table.wd-table { width: 100%; border-collapse: collapse; font-size: 13px; min-width: 900px; }
        table.wd-table th { text-align: left; color: var(--text-muted); font-size: 11px; text-transform: uppercase; letter-spacing: .5px; padding: 10px 14px; border-bottom: 1px solid var(--border-color); white-space: nowrap; }
        table.wd-table td { padding: 13px 14px; border-bottom: 1px solid var(--border-color); vertical-align: middle; }
        table.wd-table tr:last-child td { border-bottom: none; }
        table.wd-table tr:hover td { background: var(--bg-input); }

        .shop-cell { font-weight: 700; color: var(--text-main); }
        .bank-info { display: flex; flex-direction: column; gap: 2px; }
        .bank-name { font-weight: 600; }
        .bank-account { font-size: 12px; color: var(--text-muted); font-family: monospace; }
        .bank-holder { font-size: 11px; color: var(--text-dim); }

        .status-pill { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; white-space: nowrap; }
        .status-pill.PENDING  { background: var(--warning-light); color: var(--warning); }
        .status-pill.APPROVED { background: var(--primary-light); color: var(--primary); }
        .status-pill.REJECTED { background: var(--danger-light); color: var(--danger); }
        .status-pill .dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }

        .action-group { display: flex; gap: 8px; }
        .btn-approve { background: var(--primary); color: #fff; border: none; border-radius: 6px; padding: 7px 14px; font-size: 12px; font-weight: 700; cursor: pointer; transition: .18s; }
        .btn-approve:hover { background: var(--primary-dark); }
        .btn-reject { background: transparent; color: var(--danger); border: 1px solid var(--danger); border-radius: 6px; padding: 7px 14px; font-size: 12px; font-weight: 700; cursor: pointer; transition: .18s; }
        .btn-reject:hover { background: var(--danger-light); }
        .action-done { font-size: 12px; color: var(--text-dim); font-style: italic; }

        /* Reject modal */
        .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.5); z-index: 1000; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; }
        .modal-box { background: var(--bg-panel); border-radius: 14px; padding: 28px; width: 440px; max-width: 95vw; box-shadow: 0 20px 60px rgba(0,0,0,.3); }
        .modal-title { font-size: 16px; font-weight: 800; color: var(--text-main); margin-bottom: 16px; }
        .modal-label { font-size: 12px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; margin-bottom: 6px; }
        .modal-textarea { width: 100%; padding: 10px 12px; border-radius: 8px; border: 1.5px solid var(--border-color); background: var(--bg-input); color: var(--text-main); font-size: 14px; resize: vertical; min-height: 90px; }
        .modal-textarea:focus { outline: none; border-color: var(--danger); }
        .modal-actions { display: flex; gap: 10px; margin-top: 16px; }
        .modal-btn { flex: 1; padding: 11px; border-radius: 8px; font-size: 14px; font-weight: 700; cursor: pointer; border: none; }
        .modal-btn-cancel { background: var(--bg-input); color: var(--text-muted); }
        .modal-btn-reject { background: var(--danger); color: #fff; }

        .toast { position: fixed; bottom: 24px; right: 24px; padding: 12px 20px; border-radius: 10px; font-size: 14px; font-weight: 700; z-index: 9999; display: none; animation: slideUp .3s ease; }
        .toast.success { background: #16a34a; color: #fff; }
        .toast.error   { background: #dc2626; color: #fff; }
        @keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }

        .pager { display: flex; gap: 8px; padding: 16px; justify-content: center; }
        .pager a { padding: 6px 12px; border-radius: 8px; border: 1px solid var(--border-color); color: var(--text-muted); font-size: 13px; font-weight: 600; }
        .pager a.active, .pager a:hover { background: var(--primary); color: #fff; border-color: var(--primary); }
        .empty-state { text-align: center; padding: 40px; color: var(--text-muted); }
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
    </header>
    <div class="content">

        <%-- Stats --%>
        <div class="stats-grid">
            <div class="stat-card pending">
                <div class="stat-title">⏳ Đang chờ duyệt</div>
                <div class="stat-value">${pendingCount}</div>
            </div>
            <c:set var="totalCount" value="${0}"/>
            <c:forEach var="w" items="${withdrawals}">
                <c:set var="totalCount" value="${totalCount + 1}"/>
            </c:forEach>
        </div>

        <%-- Filter --%>
        <form method="get" action="" class="filter-bar">
            <div class="filter-field">
                <label>Trạng thái</label>
                <select name="status" onchange="this.form.submit()">
                    <option value="" ${statusFilter eq '' ? 'selected' : ''}>Tất cả</option>
                    <option value="PENDING"  ${statusFilter eq 'PENDING'  ? 'selected' : ''}>⏳ Đang chờ</option>
                    <option value="APPROVED" ${statusFilter eq 'APPROVED' ? 'selected' : ''}>✅ Đã duyệt</option>
                    <option value="REJECTED" ${statusFilter eq 'REJECTED' ? 'selected' : ''}>❌ Từ chối</option>
                </select>
            </div>
        </form>

        <%-- Table --%>
        <div class="panel">
            <div class="panel-header">
                <span class="panel-title">Danh sách yêu cầu rút tiền</span>
            </div>
            <div class="table-wrapper">
                <c:choose>
                    <c:when test="${empty withdrawals}">
                        <div class="empty-state">Không có yêu cầu nào</div>
                    </c:when>
                    <c:otherwise>
                    <table class="wd-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Shop</th>
                                <th>Số tiền</th>
                                <th>Ngân hàng</th>
                                <th>Thời gian</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="w" items="${withdrawals}" varStatus="st">
                                <tr id="row-${w.id}">
                                    <td style="font-size:12px;color:var(--text-muted)">${w.id}</td>
                                    <td class="shop-cell">${w.shopName}</td>
                                    <td style="font-weight:800;font-size:15px;color:#dc2626">
                                        -₫<fmt:formatNumber value="${w.amount}" pattern="#,##0"/>
                                    </td>
                                    <td>
                                        <div class="bank-info">
                                            <span class="bank-name">${w.bankName}</span>
                                            <span class="bank-account">${w.bankAccountNumber}</span>
                                            <span class="bank-holder">${w.bankAccountHolder}</span>
                                        </div>
                                    </td>
                                    <td style="font-size:12px;white-space:nowrap">
                                        <c:set var="wReqAt" value="${w.requestedAt}"/>
                                        ${fn:substring(wReqAt,8,10)}/${fn:substring(wReqAt,5,7)}/${fn:substring(wReqAt,0,4)} ${fn:substring(wReqAt,11,16)}
                                        <c:if test="${not empty w.processedAt}">
                                            <c:set var="wProcAt" value="${w.processedAt}"/>
                                            <div style="color:var(--text-dim);margin-top:2px">
                                                → ${fn:substring(wProcAt,8,10)}/${fn:substring(wProcAt,5,7)}/${fn:substring(wProcAt,0,4)} ${fn:substring(wProcAt,11,16)}
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
                                            <div style="font-size:11px;color:var(--danger);margin-top:3px">${w.rejectReason}</div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${w.status eq 'PENDING'}">
                                                <div class="action-group">
                                                    <button class="btn-approve" onclick="doApprove(${w.id}, '${w.shopName}', ${w.amount})">✅ Duyệt</button>
                                                    <button class="btn-reject"  onclick="openReject(${w.id})">❌ Từ chối</button>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="action-done">
                                                    ${w.processedByName != null ? w.processedByName : 'Admin'}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
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
        <div style="margin-top:16px;background:#fffbeb;border:1px solid #fde68a;border-radius:10px;padding:14px 16px;font-size:13px;color:#92400e">
            <strong>📌 Lưu ý:</strong> Sau khi duyệt, vui lòng <strong>chuyển khoản thủ công</strong> đến số tài khoản ngân hàng của shop.
            Hệ thống chỉ ghi nhận trạng thái — không tự động chuyển tiền.
        </div>

    </div>
</main>

<%-- Reject Modal --%>
<div class="modal-overlay" id="rejectModal">
    <div class="modal-box">
        <div class="modal-title">❌ Từ chối yêu cầu rút tiền</div>
        <div class="modal-label">Lý do từ chối *</div>
        <textarea class="modal-textarea" id="rejectReason" placeholder="Nhập lý do từ chối..."></textarea>
        <div class="modal-actions">
            <button class="modal-btn modal-btn-cancel" onclick="closeRejectModal()">Hủy</button>
            <button class="modal-btn modal-btn-reject" onclick="doReject()">Xác nhận từ chối</button>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
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
                    showToast(action === 'approve' ? '✅ Đã duyệt thành công!' : '✅ Đã từ chối!', 'success');
                    setTimeout(function(){ location.reload(); }, 1200);
                } else {
                    showToast('⚠️ ' + (json.message || 'Thao tác thất bại'), 'error');
                }
            })
            .catch(function(){ showToast('⚠️ Lỗi kết nối server', 'error'); });
    }

    document.getElementById('rejectModal').addEventListener('click', function(e) {
        if (e.target === this) closeRejectModal();
    });
</script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
</body>
</html>
