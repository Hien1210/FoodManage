<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 1}">
    <c:redirect url="/dangnhap"/>
</c:if>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Duyệt Shipper - Super Admin</title>
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
    </style>
    <style>
        .approval-modal-box { max-width: 380px; }
        .approval-modal-body { padding: 26px; text-align: center; }
    </style>
</head>
<body class="dash-body admin-theme">

<c:set var="adminActive" value="/super-admin/shipper-requests" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">moped</span> Duyệt yêu cầu Shipper</h1>
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
        <c:if test="${not empty loi}"><div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div></c:if>
        <c:if test="${param.success == 'accepted'}"><div class="alert alert-success">✅ Đã duyệt shipper thành công!</div></c:if>
        <c:if test="${param.success == 'rejected'}"><div class="alert alert-success">✅ Đã từ chối hồ sơ shipper.</div></c:if>

        <!-- Tab navigation -->
        <div style="display:flex;gap:6px;margin-bottom:16px;border-bottom:2px solid var(--border-color);padding-bottom:0;">
            <button type="button" class="tab-btn active" id="tab-pending"  onclick="switchTab('pending')">
                ⏳ Chờ duyệt
                <c:if test="${not empty pendingShippers}"><span class="menu-badge yellow" style="margin-left:6px;">${pendingShippers.size()}</span></c:if>
            </button>
            <button type="button" class="tab-btn" id="tab-approved" onclick="switchTab('approved')">
                ✅ Đã duyệt
                <c:if test="${not empty approvedShippers}"><span class="menu-badge" style="margin-left:6px;background:var(--success);color:#fff;">${approvedShippers.size()}</span></c:if>
            </button>
            <button type="button" class="tab-btn" id="tab-rejected" onclick="switchTab('rejected')">
                ❌ Từ chối
                <c:if test="${not empty rejectedShippers}"><span class="menu-badge" style="margin-left:6px;background:var(--danger);color:#fff;">${rejectedShippers.size()}</span></c:if>
            </button>
        </div>

        <style>
            .tab-btn { background:none; border:none; border-bottom:3px solid transparent; padding:10px 18px; font-size:13px; font-weight:700; color:var(--text-muted); cursor:pointer; margin-bottom:-2px; border-radius:6px 6px 0 0; transition:all .15s; }
            .tab-btn:hover { background:var(--bg-input); color:var(--text-main); }
            .tab-btn.active { border-bottom-color:var(--primary); color:var(--primary); background:var(--primary-light); }
            .tab-panel { display:none; }
            .tab-panel.active { display:block; }
            .status-badge { display:inline-block; padding:3px 10px; border-radius:20px; font-size:11px; font-weight:700; }
            .status-pending  { background:#fef3c7; color:#92400e; }
            .status-approved { background:#dcfce7; color:#166534; }
            .status-rejected { background:#fee2e2; color:#991b1b; }
        </style>

        <!-- TAB 1: Chờ duyệt -->
        <div class="tab-panel active" id="panel-pending">
            <div class="panel">
                <div class="panel-header">
                    <div class="panel-title">⏳ Shipper chờ duyệt hồ sơ</div>
                    <span class="badge badge-warning">${pendingShippers.size()} hồ sơ</span>
                </div>
                <div class="panel-body" style="padding:0;">
                    <c:choose>
                        <c:when test="${empty pendingShippers}">
                            <div class="empty-state">
                                <div class="e-icon">🛵</div>
                                <div class="e-title">Không có hồ sơ nào đang chờ duyệt</div>
                                <div class="e-sub">Hồ sơ có verification_status = PENDING sẽ xuất hiện tại đây.</div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="dash-table-wrap">
                                <table class="dash-table">
                                    <thead><tr>
                                        <th>#</th><th>Họ tên / Username</th><th>Email</th><th>Số điện thoại</th><th>Ngày đăng ký</th><th>Thao tác</th>
                                    </tr></thead>
                                    <tbody>
                                    <c:forEach var="s" items="${pendingShippers}" varStatus="vs">
                                        <tr>
                                            <td>${vs.index + 1}</td>
                                            <td>
                                                <strong style="color:var(--text-main);"><c:out value="${s.fullName}"/></strong><br>
                                                <span style="font-size:12px;color:var(--text-dim);">@<c:out value="${s.userName}"/></span>
                                            </td>
                                            <td><c:out value="${s.email}"/></td>
                                            <td>📞 <c:out value="${s.phone}"/></td>
                                            <td style="white-space:nowrap;font-size:12px;">
                                                <c:if test="${not empty s.createdAt}">
                                                    ${s.createdAt.hour}:<c:set var="m" value="${s.createdAt.minute}"/><c:if test="${m < 10}">0</c:if>${m}
                                                    &nbsp;${s.createdAt.dayOfMonth}/${s.createdAt.monthValue}/${s.createdAt.year}
                                                </c:if>
                                            </td>
                                            <td>
                                                <div style="display:flex;gap:8px;flex-wrap:wrap;">
                                                    <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/super-admin/shipper-requests?action=detail&id=${s.id}">Chi tiết</a>
                                                    <form action="${pageContext.request.contextPath}/super-admin/shipper-requests" method="post" style="margin:0">
                                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="accept">
                                                        <input type="hidden" name="id" value="${s.id}">
                                                        <button type="button" class="btn btn-sm btn-success" onclick="openApprovalModal(this,'accept','${fn:escapeXml(s.userName)}')">✓ Duyệt</button>
                                                    </form>
                                                    <form action="${pageContext.request.contextPath}/super-admin/shipper-requests" method="post" style="margin:0">
                                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="reject">
                                                        <input type="hidden" name="id" value="${s.id}">
                                                        <button type="button" class="btn btn-sm btn-danger-outline" onclick="openApprovalModal(this,'reject','${fn:escapeXml(s.userName)}')">✕ Từ chối</button>
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

        <!-- TAB 2: Đã duyệt -->
        <div class="tab-panel" id="panel-approved">
            <div class="panel">
                <div class="panel-header">
                    <div class="panel-title">✅ Shipper đã được duyệt</div>
                    <span class="badge badge-success">${approvedShippers.size()} tài khoản</span>
                </div>
                <div class="panel-body" style="padding:0;">
                    <c:choose>
                        <c:when test="${empty approvedShippers}">
                            <div class="empty-state">
                                <div class="e-icon">✅</div>
                                <div class="e-title">Chưa có shipper nào được duyệt</div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="dash-table-wrap">
                                <table class="dash-table">
                                    <thead><tr>
                                        <th>#</th><th>Họ tên / Username</th><th>Email</th><th>Số điện thoại</th><th>CCCD</th><th>Trạng thái</th><th>Thao tác</th>
                                    </tr></thead>
                                    <tbody>
                                    <c:forEach var="s" items="${approvedShippers}" varStatus="vs">
                                        <c:set var="prof" value="${profileMap[s.id]}"/>
                                        <tr>
                                            <td>${vs.index + 1}</td>
                                            <td>
                                                <strong style="color:var(--text-main);"><c:out value="${s.fullName}"/></strong><br>
                                                <span style="font-size:12px;color:var(--text-dim);">@<c:out value="${s.userName}"/></span>
                                            </td>
                                            <td><c:out value="${s.email}"/></td>
                                            <td>📞 <c:out value="${s.phone}"/></td>
                                            <td style="font-size:12px;"><c:out value="${prof.cccd}"/></td>
                                            <td><span class="status-badge status-approved">✅ Đã duyệt</span></td>
                                            <td>
                                                <div style="display:flex;gap:8px;flex-wrap:wrap;">
                                                    <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/super-admin/shipper-requests?action=detail&id=${s.id}">Chi tiết</a>
                                                    <form action="${pageContext.request.contextPath}/super-admin/shipper-requests" method="post" style="margin:0">
                                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="reject">
                                                        <input type="hidden" name="id" value="${s.id}">
                                                        <button type="button" class="btn btn-sm btn-danger-outline" onclick="openApprovalModal(this,'reject','${fn:escapeXml(s.userName)}')">✕ Thu hồi</button>
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

        <!-- TAB 3: Từ chối -->
        <div class="tab-panel" id="panel-rejected">
            <div class="panel">
                <div class="panel-header">
                    <div class="panel-title">❌ Shipper bị từ chối hồ sơ</div>
                    <span class="badge badge-danger">${rejectedShippers.size()} hồ sơ</span>
                </div>
                <div class="panel-body" style="padding:0;">
                    <c:choose>
                        <c:when test="${empty rejectedShippers}">
                            <div class="empty-state">
                                <div class="e-icon">❌</div>
                                <div class="e-title">Không có hồ sơ nào bị từ chối</div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="dash-table-wrap">
                                <table class="dash-table">
                                    <thead><tr>
                                        <th>#</th><th>Họ tên / Username</th><th>Email</th><th>Số điện thoại</th><th>Lý do từ chối</th><th>Trạng thái</th><th>Thao tác</th>
                                    </tr></thead>
                                    <tbody>
                                    <c:forEach var="s" items="${rejectedShippers}" varStatus="vs">
                                        <c:set var="prof" value="${profileMap[s.id]}"/>
                                        <tr>
                                            <td>${vs.index + 1}</td>
                                            <td>
                                                <strong style="color:var(--text-main);"><c:out value="${s.fullName}"/></strong><br>
                                                <span style="font-size:12px;color:var(--text-dim);">@<c:out value="${s.userName}"/></span>
                                            </td>
                                            <td><c:out value="${s.email}"/></td>
                                            <td>📞 <c:out value="${s.phone}"/></td>
                                            <td style="font-size:12px;color:var(--danger);max-width:200px;">
                                                <c:choose>
                                                    <c:when test="${not empty prof.rejectionReason}"><c:out value="${prof.rejectionReason}"/></c:when>
                                                    <c:otherwise><span style="color:var(--text-muted)">—</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><span class="status-badge status-rejected">❌ Từ chối</span></td>
                                            <td>
                                                <div style="display:flex;gap:8px;flex-wrap:wrap;">
                                                    <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/super-admin/shipper-requests?action=detail&id=${s.id}">Chi tiết</a>
                                                    <form action="${pageContext.request.contextPath}/super-admin/shipper-requests" method="post" style="margin:0">
                                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="accept">
                                                        <input type="hidden" name="id" value="${s.id}">
                                                        <button type="button" class="btn btn-sm btn-success" onclick="openApprovalModal(this,'accept','${fn:escapeXml(s.userName)}')">✓ Duyệt lại</button>
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

    </div>
</main>

<div class="pob-modal-overlay" id="approvalModal">
    <div class="pob-modal-box approval-modal-box">
        <div class="approval-modal-body">
            <div style="font-size:40px;margin-bottom:8px;" id="approvalModalIcon">✅</div>
            <div style="font-weight:800;font-size:16px;color:#1e293b;margin-bottom:6px;" id="approvalModalTitle">Xác nhận duyệt Shipper?</div>
            <div style="font-size:13px;color:#64748b;margin-bottom:20px;" id="approvalModalDesc"></div>
            <div style="display:flex;gap:10px;justify-content:center;">
                <button type="button" class="btn btn-ghost" onclick="closeApprovalModal()">Huỷ</button>
                <button type="button" class="btn" id="approvalModalConfirmBtn">Xác nhận</button>
            </div>
        </div>
    </div>
</div>

<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${sessionScope.account.userName}</div>
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

    var approvalModal = document.getElementById('approvalModal');
    var pendingApprovalForm = null;
    var confirmBtn = document.getElementById('approvalModalConfirmBtn');

    function openApprovalModal(btn, action, name) {
        pendingApprovalForm = btn.closest('form');

        var icon = document.getElementById('approvalModalIcon');
        var title = document.getElementById('approvalModalTitle');
        var desc = document.getElementById('approvalModalDesc');

        if (action === 'accept') {
            icon.textContent = '✅';
            title.textContent = 'Xác nhận duyệt shipper "' + name + '"?';
            desc.textContent = 'Shipper sẽ được kích hoạt và có thể bắt đầu nhận đơn ngay sau khi duyệt.';
            confirmBtn.className = 'btn btn-success';
        } else {
            icon.textContent = '🚫';
            title.textContent = 'Xác nhận từ chối hồ sơ "' + name + '"?';
            desc.textContent = 'Shipper vẫn đăng nhập được nhưng không thể nhận đơn cho đến khi cập nhật lại giấy tờ.';
            confirmBtn.className = 'btn btn-danger';
        }

        approvalModal.classList.add('open');
    }

    function closeApprovalModal() {
        pendingApprovalForm = null;
        approvalModal.classList.remove('open');
    }

    confirmBtn.addEventListener('click', function () {
        if (pendingApprovalForm) pendingApprovalForm.submit();
    });

    approvalModal.addEventListener('click', function (e) {
        if (e.target === approvalModal) closeApprovalModal();
    });

    function switchTab(name) {
        ['pending','approved','rejected'].forEach(function(t) {
            document.getElementById('tab-' + t).classList.toggle('active', t === name);
            document.getElementById('panel-' + t).classList.toggle('active', t === name);
        });
    }
</script>
</body>
</html>
