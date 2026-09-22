<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- BẢO MẬT: KIỂM TRA QUYỀN SUPER ADMIN --%>
<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 1}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="_csrf" content="${sessionScope.csrfToken}">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Duyệt rút tiền Shipper - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        :root { --primary-hover: var(--primary-dark); --purple: #8b5cf6; }

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

        .mock-banner { background: var(--warning-light); border: 1px dashed var(--warning); color: var(--warning); border-radius: 8px; padding: 10px 16px; font-size: 12px; font-weight: 700; text-align: center; letter-spacing: 0.3px; }

        /* FILTER BAR */
        .filter-bar { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; padding: 18px 20px; display: flex; align-items: flex-end; gap: 18px; flex-wrap: wrap; }
        .filter-field { display: flex; flex-direction: column; gap: 6px; }
        .filter-field label { font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; color: var(--text-muted); font-weight: 700; }
        .filter-field select { background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 8px; padding: 9px 12px; color: var(--text-main); font-size: 13px; min-width: 200px; }

        /* CARDS THỐNG KÊ */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; }
        .stat-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 8px; padding: 20px; display: flex; flex-direction: column; border-top: 3px solid var(--border-color); transition: all 0.2s ease;}
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 6px 14px rgba(0,0,0,0.15); }
        .stat-card.total { border-top-color: var(--info); }
        .stat-card.pending { border-top-color: var(--warning); }
        .stat-card.paid { border-top-color: var(--primary); }
        .stat-title { font-size: 12px; text-transform: uppercase; color: var(--text-muted); margin-bottom: 10px; font-weight: bold; }
        .stat-value { font-size: 28px; font-weight: bold; color: var(--text-main); }
        .stat-hint { font-size: 11px; color: var(--text-dim); margin-top: 6px; }

        /* PANEL / TABLE */
        .panel { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; animation: fadeUp 0.35s ease both; padding: 20px; }
        .panel-title { color: var(--warning); font-size: 14px; font-weight: bold; margin-bottom: 20px; text-transform: uppercase; border-left: 4px solid var(--warning); padding-left: 10px; }
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .table-wrapper { overflow-x: auto; }
        table.withdraw-table { width: 100%; border-collapse: collapse; font-size: 13px; min-width: 1000px; }
        table.withdraw-table thead th { text-align: left; color: var(--text-muted); font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; padding: 10px 14px; border-bottom: 1px solid var(--border-color); white-space: nowrap; }
        table.withdraw-table thead th.num { text-align: right; }
        table.withdraw-table tbody td { padding: 14px; border-bottom: 1px solid var(--border-color); color: var(--text-main); vertical-align: middle; }
        table.withdraw-table tbody td.num { text-align: right; font-variant-numeric: tabular-nums; }
        table.withdraw-table tbody tr:last-child td { border-bottom: none; }
        table.withdraw-table tbody tr:hover { background: var(--bg-input); }

        .ma-gd { font-family: 'Courier New', monospace; font-weight: 700; color: var(--info); }

        .shipper-cell { display: flex; align-items: center; gap: 10px; }
        .shipper-avatar { width: 32px; height: 32px; border-radius: 8px; background: linear-gradient(135deg, var(--warning), var(--danger)); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 12px; flex-shrink: 0; }
        .shipper-info { display: flex; flex-direction: column; }
        .shipper-name { font-weight: 600; }
        .shipper-phone { font-size: 11px; color: var(--text-dim); }

        .bank-info { display: flex; flex-direction: column; gap: 2px; }
        .bank-name { font-weight: 600; color: var(--text-main); }
        .bank-account { font-size: 12px; color: var(--text-muted); font-variant-numeric: tabular-nums; }
        .bank-holder { font-size: 11px; color: var(--text-dim); }

        .status-pill { display: inline-flex; align-items: center; gap: 6px; padding: 5px 12px; border-radius: 999px; font-size: 11px; font-weight: 700; white-space: nowrap; }
        .status-pill.approved { background: var(--primary-light); color: var(--primary); }
        .status-pill.pending { background: var(--warning-light); color: var(--warning); }
        .status-pill.rejected { background: var(--danger-light); color: var(--danger); }
        .status-pill .dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }

        .action-group { display: flex; gap: 8px; }
        .btn-approve { background: var(--primary); color: #fff; border: none; border-radius: 6px; padding: 7px 14px; font-size: 12px; font-weight: 700; cursor: pointer; transition: all 0.2s ease; white-space: nowrap; }
        .btn-approve:hover { background: var(--primary-hover); transform: translateY(-1px); }
        .btn-reject { background: transparent; color: var(--danger); border: 1px solid var(--danger); border-radius: 6px; padding: 7px 14px; font-size: 12px; font-weight: 700; cursor: pointer; transition: all 0.2s ease; white-space: nowrap; }
        .btn-reject:hover { background: var(--danger-light); }
        .action-done { font-size: 12px; color: var(--text-dim); font-style: italic; }

        .table-footer-note { font-size: 11px; color: var(--text-dim); margin-top: 14px; }
    </style>
</head>
<body class="dash-body admin-theme">

<c:set var="adminActive" value="/admin/duyet-rut-tien-shipper" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">account_balance_wallet</span> Duyệt rút tiền Shipper</h1>
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
            <!-- BỘ LỌC TRẠNG THÁI -->
            <form class="filter-bar" method="get" action="${pageContext.request.contextPath}/admin/duyet-rut-tien-shipper">
                <div class="filter-field">
                    <label for="statusFilter">Trạng thái</label>
                    <select id="statusFilter" name="status" onchange="this.form.submit()">
                        <option value="all" ${statusFilter == 'all' ? 'selected' : ''}>Tất cả</option>
                        <option value="PENDING" ${statusFilter == 'PENDING' ? 'selected' : ''}>Chờ duyệt</option>
                        <option value="APPROVED" ${statusFilter == 'APPROVED' ? 'selected' : ''}>Đã duyệt</option>
                        <option value="REJECTED" ${statusFilter == 'REJECTED' ? 'selected' : ''}>Từ chối</option>
                    </select>
                </div>
            </form>

            <!-- KHỐI 3 CARD SỐ LIỆU -->
            <div class="stats-grid">
                <div class="stat-card total">
                    <span class="stat-title">Tổng tiền yêu cầu</span>
                    <span class="stat-value" style="color: var(--info);"><fmt:formatNumber value="${tongTienYeuCau}" type="number" groupingUsed="true"/>₫</span>
                    <span class="stat-hint">Tổng cộng ${fn:length(danhSachRutTien)} yêu cầu rút tiền</span>
                </div>
                <div class="stat-card pending">
                    <span class="stat-title">Chờ xử lý</span>
                    <span class="stat-value" style="color: var(--warning);"><fmt:formatNumber value="${choXuLy}" type="number" groupingUsed="true"/>₫</span>
                    <span class="stat-hint">Yêu cầu đang chờ duyệt</span>
                </div>
                <div class="stat-card paid">
                    <span class="stat-title">Đã thanh toán</span>
                    <span class="stat-value" style="color: var(--primary);"><fmt:formatNumber value="${daThanhToan}" type="number" groupingUsed="true"/>₫</span>
                    <span class="stat-hint">Yêu cầu đã duyệt & chi trả</span>
                </div>
            </div>

            <!-- BẢNG DANH SÁCH RÚT TIỀN -->
            <div class="panel">
                <div class="panel-title">■ DANH SÁCH YÊU CẦU RÚT TIỀN</div>
                <div class="table-wrapper">
                    <table class="withdraw-table">
                        <thead>
                            <tr>
                                <th>Mã GD</th>
                                <th>Shipper</th>
                                <th class="num">Số tiền rút</th>
                                <th>Thông tin ngân hàng</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="withdrawTableBody">
                            <c:forEach items="${danhSachRutTien}" var="w">
                                <tr data-status="${w.status}" data-id="${w.id}">
                                    <td class="ma-gd">RUT-<fmt:formatNumber value="${w.id}" pattern="000000"/></td>
                                    <td>
                                        <div class="shipper-cell">
                                            <div class="shipper-avatar">${fn:toUpperCase(fn:substring(w.shipperName, 0, 1))}</div>
                                            <div class="shipper-info">
                                                <span class="shipper-name">${fn:escapeXml(w.shipperName)}</span>
                                                <span class="shipper-phone">${w.shipperPhone}</span>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="num" style="font-weight: 700;
                                        color: ${w.status == 'PENDING' ? 'var(--warning)' : (w.status == 'APPROVED' ? 'var(--primary)' : 'var(--danger)')};">
                                        <fmt:formatNumber value="${w.amount}" type="number" groupingUsed="true"/>₫
                                    </td>
                                    <td>
                                        <div class="bank-info">
                                            <span class="bank-name">${fn:escapeXml(w.bankName)}</span>
                                            <span class="bank-account">${fn:escapeXml(w.bankAccountNumber)}</span>
                                            <span class="bank-holder">${fn:escapeXml(w.bankAccountHolder)}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${w.status == 'PENDING'}">
                                                <span class="status-pill pending"><span class="dot"></span>Chờ duyệt</span>
                                            </c:when>
                                            <c:when test="${w.status == 'APPROVED'}">
                                                <span class="status-pill approved"><span class="dot"></span>Đã duyệt</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-pill rejected"><span class="dot"></span>Từ chối</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${w.status == 'PENDING'}">
                                                <div class="action-group">
                                                    <button type="button" class="btn-approve">✔ Phê duyệt</button>
                                                    <button type="button" class="btn-reject">✘ Từ chối</button>
                                                </div>
                                            </c:when>
                                            <c:when test="${w.status == 'APPROVED'}">
                                                <span class="action-done">Đã xử lý</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="action-done">Đã hoàn tiền vào ví</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty danhSachRutTien}">
                                <tr>
                                    <td colspan="6" style="text-align:center; color: var(--text-dim); padding: 24px;">Không có yêu cầu rút tiền nào.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
                <div class="table-footer-note">
                    * Khi từ chối, số tiền sẽ được hoàn lại vào ví Shipper (xem ShipperWithdrawalDAOImpl#rejectWithdrawal).
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

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pixel-cat.js"></script>
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
<script>
    /* ===================== PHÊ DUYỆT / TỪ CHỐI (dữ liệu thật, gọi AJAX tới Servlet) =====================
           POST tới ${pageContext.request.contextPath}/admin/duyet-rut-tien-shipper
           body: id=<withdrawalId>&action=approve  hoặc  action=reject&reason=<lý do>
           Servlet trả JSON: {"success":true} hoặc {"success":false,"message":"..."}
        ===================================================================================== */
        (function () {
            const tbody = document.getElementById('withdrawTableBody');
            const contextPath = '${pageContext.request.contextPath}';

            function guiYeuCau(id, action, reason) {
                const params = new URLSearchParams();
                params.set('id', id);
                params.set('action', action);
                if (reason) params.set('reason', reason);

                return fetch(contextPath + '/admin/duyet-rut-tien-shipper', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'X-CSRF-Token': document.querySelector('meta[name="_csrf"]').content
                    },
                    body: params.toString()
                }).then(function (res) { return res.json(); });
            }

            tbody.addEventListener('click', function (e) {
                const approveBtn = e.target.closest('.btn-approve');
                const rejectBtn = e.target.closest('.btn-reject');
                if (!approveBtn && !rejectBtn) return;

                const row = (approveBtn || rejectBtn).closest('tr');
                const withdrawalId = row.getAttribute('data-id');
                const maGd = row.querySelector('.ma-gd').textContent;

                if (approveBtn) {
                    pobConfirm('Phê duyệt yêu cầu rút tiền ' + maGd + '?').then(function(ok) {
                        if (!ok) return;
                        approveBtn.disabled = true;
                        guiYeuCau(withdrawalId, 'approve').then(function (data) {
                            if (data.success) {
                                row.setAttribute('data-status', 'APPROVED');
                                row.querySelector('td:nth-child(5)').innerHTML = '<span class="status-pill approved"><span class="dot"></span>Đã duyệt</span>';
                                row.querySelector('td:nth-child(6)').innerHTML = '<span class="action-done">Đã xử lý</span>';
                            } else {
                                alert(data.message || 'Có lỗi xảy ra, vui lòng thử lại.');
                                approveBtn.disabled = false;
                            }
                        }).catch(function () {
                            alert('Không thể kết nối tới server, vui lòng thử lại.');
                            approveBtn.disabled = false;
                        });
                    });
                } else {
                    pobPrompt('Nhập lý do từ chối yêu cầu ' + maGd + ':').then(function(reason) {
                        if (reason === null) return;
                        rejectBtn.disabled = true;
                        guiYeuCau(withdrawalId, 'reject', reason).then(function (data) {
                            if (data.success) {
                            row.setAttribute('data-status', 'REJECTED');
                            row.querySelector('td:nth-child(5)').innerHTML = '<span class="status-pill rejected"><span class="dot"></span>Từ chối</span>';
                            row.querySelector('td:nth-child(6)').innerHTML = '<span class="action-done">Đã hoàn tiền vào ví</span>';
                        } else {
                            alert(data.message || 'Có lỗi xảy ra, vui lòng thử lại.');
                            rejectBtn.disabled = false;
                        }
                        }).catch(function () {
                            alert('Không thể kết nối tới server, vui lòng thử lại.');
                            rejectBtn.disabled = false;
                        });
                    });
                }
            });
        })();
    </script>
</body>
</html>
