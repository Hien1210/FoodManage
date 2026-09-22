<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 1}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Quản lý hoàn tiền - Super Admin</title>
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

        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-bottom: 24px; }
        .stat-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; padding: 18px; border-top: 3px solid var(--border-color); }
        .stat-card.pending { border-top-color: var(--warning); }
        .stat-title { font-size: 11px; text-transform: uppercase; color: var(--text-muted); font-weight: 700; margin-bottom: 8px; }
        .stat-value { font-size: 26px; font-weight: 800; color: var(--text-main); }

        .panel { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; }
        .panel-header { padding: 16px 20px; border-bottom: 1px solid var(--border-color); }
        .panel-title { font-size: 14px; font-weight: 700; color: var(--text-main); }
        .table-wrapper { overflow-x: auto; }

        table.rf-table { width: 100%; border-collapse: collapse; font-size: 13px; min-width: 900px; }
        table.rf-table th { text-align: left; color: var(--text-muted); font-size: 11px; text-transform: uppercase; letter-spacing: .5px; padding: 10px 14px; border-bottom: 1px solid var(--border-color); white-space: nowrap; }
        table.rf-table td { padding: 13px 14px; border-bottom: 1px solid var(--border-color); vertical-align: middle; }
        table.rf-table tr:last-child td { border-bottom: none; }
        table.rf-table tr:hover td { background: var(--bg-input); }

        .bank-info { display: flex; flex-direction: column; gap: 2px; }
        .bank-name { font-weight: 600; }
        .bank-acc { font-size: 12px; color: var(--text-muted); font-family: monospace; }
        .bank-holder { font-size: 11px; color: var(--text-dim); }
        .customer-cell { display: flex; flex-direction: column; gap: 2px; }
        .customer-name { font-weight: 600; }
        .customer-email { font-size: 11px; color: var(--text-muted); }

        .status-pill { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; }
        .status-pill.PENDING   { background: var(--warning-light); color: var(--warning); }
        .status-pill.COMPLETED { background: var(--primary-light); color: var(--primary); }
        .status-pill.REJECTED  { background: var(--danger-light);  color: var(--danger); }

        .action-group { display: flex; gap: 8px; }
        .btn-complete { background: var(--primary); color: #fff; border: none; border-radius: 6px; padding: 7px 14px; font-size: 12px; font-weight: 700; cursor: pointer; transition: .18s; }
        .btn-complete:hover { background: var(--primary-dark); }
        .btn-reject { background: transparent; color: var(--danger); border: 1px solid var(--danger); border-radius: 6px; padding: 7px 14px; font-size: 12px; font-weight: 700; cursor: pointer; transition: .18s; }
        .btn-reject:hover { background: var(--danger-light); }
        .action-done { font-size: 12px; color: var(--text-dim); font-style: italic; }

        .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.5); z-index: 1000; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; }
        .modal-box { background: var(--bg-panel); border-radius: 14px; padding: 28px; width: 440px; max-width: 95vw; box-shadow: 0 20px 60px rgba(0,0,0,.3); }
        .modal-title { font-size: 16px; font-weight: 800; margin-bottom: 14px; }
        .modal-label { font-size: 12px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; margin-bottom: 6px; }
        .modal-textarea { width: 100%; padding: 10px 12px; border-radius: 8px; border: 1.5px solid var(--border-color); background: var(--bg-input); color: var(--text-main); font-size: 14px; resize: vertical; min-height: 80px; }
        .modal-textarea:focus { outline: none; border-color: var(--danger); }
        .modal-actions { display: flex; gap: 10px; margin-top: 14px; }
        .modal-btn { flex: 1; padding: 11px; border-radius: 8px; font-size: 14px; font-weight: 700; cursor: pointer; border: none; }
        .modal-btn-cancel { background: var(--bg-input); color: var(--text-muted); }
        .modal-btn-reject { background: var(--danger); color: #fff; }

        .toast { position: fixed; bottom: 24px; right: 24px; padding: 12px 20px; border-radius: 10px; font-size: 14px; font-weight: 700; z-index: 9999; display: none; }
        .toast.success { background: #16a34a; color: #fff; }
        .toast.error   { background: #dc2626; color: #fff; }

        .pager { display: flex; gap: 8px; padding: 16px; justify-content: center; }
        .pager a { padding: 6px 12px; border-radius: 8px; border: 1px solid var(--border-color); color: var(--text-muted); font-size: 13px; font-weight: 600; }
        .pager a.active, .pager a:hover { background: var(--primary); color: #fff; border-color: var(--primary); }
        .empty-state { text-align: center; padding: 40px; color: var(--text-muted); }
        .note-cell { max-width: 180px; font-size: 12px; color: var(--text-muted); }
    </style>
</head>
<body class="dash-body admin-theme">

<c:set var="adminActive" value="/admin/hoan-tien" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">assignment_return</span> Hoàn tiền khách hàng</h1>
        </div>
    </header>
    <div class="content">

        <div class="stat-grid">
            <div class="stat-card pending">
                <div class="stat-title">⏳ Chờ xử lý</div>
                <div class="stat-value">${pendingCount}</div>
            </div>
        </div>

        <form method="get" class="filter-bar">
            <div class="filter-field">
                <label>Trạng thái</label>
                <select name="status" onchange="this.form.submit()">
                    <option value=""        ${statusFilter eq '' ? 'selected' : ''}>Tất cả</option>
                    <option value="PENDING"   ${statusFilter eq 'PENDING'   ? 'selected' : ''}>⏳ Đang chờ</option>
                    <option value="COMPLETED" ${statusFilter eq 'COMPLETED' ? 'selected' : ''}>✅ Đã hoàn</option>
                    <option value="REJECTED"  ${statusFilter eq 'REJECTED'  ? 'selected' : ''}>❌ Từ chối</option>
                </select>
            </div>
        </form>

        <div class="panel">
            <div class="panel-header"><span class="panel-title">Danh sách yêu cầu hoàn tiền</span></div>
            <div class="table-wrapper">
                <c:choose>
                    <c:when test="${empty refunds}">
                        <div class="empty-state">Không có yêu cầu nào</div>
                    </c:when>
                    <c:otherwise>
                    <table class="rf-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Khách hàng</th>
                                <th>Đơn #</th>
                                <th>Số tiền</th>
                                <th>Thông tin ngân hàng</th>
                                <th>Ghi chú</th>
                                <th>Ngày gửi</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${refunds}">
                                <tr id="row-${r.id}">
                                    <td style="color:var(--text-muted);font-size:12px">${r.id}</td>
                                    <td>
                                        <div class="customer-cell">
                                            <span class="customer-name">${r.accountName}</span>
                                            <span class="customer-email">${r.accountEmail}</span>
                                        </div>
                                    </td>
                                    <td><a href="${pageContext.request.contextPath}/shop/bills?action=view&orderId=${r.orderId}" style="color:var(--primary);font-weight:700">#${r.orderId}</a></td>
                                    <td style="font-weight:800;font-size:15px;color:#dc2626">
                                        ₫<fmt:formatNumber value="${r.amount}" pattern="#,##0"/>
                                    </td>
                                    <td>
                                        <div class="bank-info">
                                            <span class="bank-name">${r.bankName}</span>
                                            <span class="bank-acc">${r.bankAccountNumber}</span>
                                            <span class="bank-holder">${r.bankAccountHolder}</span>
                                        </div>
                                    </td>
                                    <td class="note-cell">${r.note}</td>
                                    <td style="font-size:12px;white-space:nowrap">
                                        <fmt:formatDate value="${r.requestedAt}" pattern="dd/MM/yyyy HH:mm" type="both"/>
                                    </td>
                                    <td>
                                        <span class="status-pill ${r.status}" id="status-${r.id}">
                                            <c:choose>
                                                <c:when test="${r.status eq 'PENDING'}">⏳ Đang chờ</c:when>
                                                <c:when test="${r.status eq 'COMPLETED'}">✅ Đã hoàn</c:when>
                                                <c:otherwise>❌ Từ chối</c:otherwise>
                                            </c:choose>
                                        </span>
                                        <c:if test="${not empty r.rejectReason}">
                                            <div style="font-size:11px;color:var(--danger);margin-top:3px">${r.rejectReason}</div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.status eq 'PENDING'}">
                                                <div class="action-group">
                                                    <button class="btn-complete" onclick="doComplete(${r.id}, '${r.accountName}', ${r.amount})">✅ Đã chuyển khoản</button>
                                                    <button class="btn-reject" onclick="openReject(${r.id})">❌ Từ chối</button>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="action-done">${r.processedByName}</span>
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

        <div style="margin-top:16px;background:#fffbeb;border:1px solid #fde68a;border-radius:10px;padding:14px 16px;font-size:13px;color:#92400e">
            <strong>📌 Quy trình:</strong> Khách hàng điền thông tin ngân hàng → Bạn chuyển khoản tay → Bấm <strong>"Đã chuyển khoản"</strong> để xác nhận và thông báo cho khách.
        </div>
    </div>
</main>

<div class="modal-overlay" id="rejectModal">
    <div class="modal-box">
        <div class="modal-title">❌ Từ chối yêu cầu hoàn tiền</div>
        <div class="modal-label">Lý do từ chối *</div>
        <textarea class="modal-textarea" id="rejectReason" placeholder="VD: Thông tin ngân hàng không hợp lệ..."></textarea>
        <div class="modal-actions">
            <button class="modal-btn modal-btn-cancel" onclick="closeModal()">Hủy</button>
            <button class="modal-btn modal-btn-reject" onclick="doReject()">Xác nhận từ chối</button>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>
<script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
<script>
    var rejectId = 0;
    var BASE = '${pageContext.request.contextPath}/admin/hoan-tien';

    function showToast(msg, type) {
        var t = document.getElementById('toast');
        t.textContent = msg;
        t.className = 'toast ' + type;
        t.style.display = 'block';
        setTimeout(function(){ t.style.display = 'none'; }, 3500);
    }

    function doComplete(id, name, amount) {
        pobConfirm('Xác nhận đã chuyển khoản ₫' + amount.toLocaleString('vi-VN') + ' cho ' + name + '?').then(function(ok) {
            if (ok) post(id, 'complete', null);
        });
    }

    function openReject(id) {
        rejectId = id;
        document.getElementById('rejectReason').value = '';
        document.getElementById('rejectModal').classList.add('open');
    }

    function closeModal() { document.getElementById('rejectModal').classList.remove('open'); }

    function doReject() {
        var reason = document.getElementById('rejectReason').value.trim();
        if (!reason) { alert('Vui lòng nhập lý do từ chối'); return; }
        closeModal();
        post(rejectId, 'reject', reason);
    }

    function post(id, action, reason) {
        var fd = new FormData();
        fd.append('csrfToken', '${sessionScope.csrfToken}');
        fd.append('refundId', id);
        fd.append('action', action);
        if (reason) fd.append('reason', reason);
        fetch(BASE, { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function(json){
                if (json.success) {
                    showToast(action === 'complete' ? '✅ Đã xác nhận hoàn tiền!' : '✅ Đã từ chối!', 'success');
                    setTimeout(function(){ location.reload(); }, 1200);
                } else {
                    showToast('⚠️ ' + (json.message || 'Thao tác thất bại'), 'error');
                }
            }).catch(function(){ showToast('⚠️ Lỗi kết nối', 'error'); });
    }

    document.getElementById('rejectModal').addEventListener('click', function(e){ if (e.target === this) closeModal(); });
</script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
</body>
</html>
