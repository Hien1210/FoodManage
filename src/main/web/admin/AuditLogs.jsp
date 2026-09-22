<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 1}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Audit Log - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        :root { --primary-hover: var(--primary-dark); --purple: #8b5cf6; }

        .panel { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; animation: fadeUp 0.35s ease both; padding: 22px; margin-bottom: 20px; }
        .panel-title { font-size: 14px; font-weight: bold; text-transform: uppercase; border-left: 4px solid var(--primary); padding-left: 10px; color: var(--text-main); margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; }

        /* FILTER FORM */
        .filter-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px 18px; align-items: end; }
        .filter-field label { display: block; font-size: 12px; font-weight: 700; color: var(--text-muted); margin-bottom: 6px; }
        .filter-field input, .filter-field select {
            width: 100%; padding: 9px 12px; border-radius: 8px; border: 1px solid var(--border-color);
            background: var(--bg-input); color: var(--text-main); font-size: 13px; font-family: inherit;
        }
        .filter-field input:focus, .filter-field select:focus { outline: none; border-color: var(--primary); }
        .filter-actions { display: flex; gap: 10px; }
        .btn-filter { background: var(--primary); color: #ffffff; border: none; padding: 9px 20px; border-radius: 8px; font-size: 13px; font-weight: 800; cursor: pointer; transition: 0.15s; white-space: nowrap; }
        .btn-filter:hover { background: var(--primary-hover); }
        .btn-clear { background: var(--bg-input); color: var(--text-muted); border: 1px solid var(--border-color); padding: 9px 16px; border-radius: 8px; font-size: 13px; font-weight: 700; cursor: pointer; white-space: nowrap; }
        .btn-clear:hover { color: var(--text-main); }

        /* TABLE */
        .audit-table-wrap { overflow-x: auto; }
        .audit-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .audit-table th { text-align: left; padding: 10px 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-dim); border-bottom: 1px solid var(--border-color); white-space: nowrap; }
        .audit-table td { padding: 10px 12px; border-bottom: 1px solid var(--border-color); color: var(--text-main); vertical-align: top; }
        .audit-table tr:hover td { background: var(--bg-hover); }
        .cell-time { white-space: nowrap; color: var(--text-muted); font-size: 12px; }
        .cell-user { white-space: nowrap; }
        .cell-user .name { font-weight: 700; }
        .cell-user .role { font-size: 11px; color: var(--text-muted); }
        .badge-module { display: inline-block; font-size: 11px; font-weight: 700; padding: 3px 10px; border-radius: 20px; background: var(--primary-light); color: var(--primary); white-space: nowrap; }
        .cell-desc { max-width: 420px; }
        .cell-target { font-size: 12px; color: var(--text-muted); white-space: nowrap; }

        .empty-state { text-align: center; padding: 48px 20px; color: var(--text-dim); }
        .empty-state .icon { font-size: 48px; margin-bottom: 12px; }

        /* PAGINATION */
        .pagination { display: flex; align-items: center; justify-content: space-between; margin-top: 18px; flex-wrap: wrap; gap: 10px; }
        .pagination-info { font-size: 12.5px; color: var(--text-muted); }
        .pagination-links { display: flex; gap: 6px; }
        .page-link { display: inline-flex; align-items: center; justify-content: center; min-width: 34px; height: 34px; padding: 0 8px; border-radius: 7px; border: 1px solid var(--border-color); background: var(--bg-input); color: var(--text-main); font-size: 13px; font-weight: 600; text-decoration: none; }
        .page-link:hover { background: var(--bg-hover); }
        .page-link.active { background: var(--primary); border-color: var(--primary); color: #0f172a; }
        .page-link.disabled { opacity: 0.4; pointer-events: none; }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
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
</head>
<body class="dash-body admin-theme">
<c:set var="adminActive" value="/admin/audit-logs" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">history</span> Audit Log - Nhật ký hệ thống</h1>
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
        <div class="panel">
            <div class="panel-title">Bộ lọc tìm kiếm</div>
            <form method="get" action="${pageContext.request.contextPath}/admin/audit-logs">
                <div class="filter-grid">
                    <div class="filter-field">
                        <label>Account ID</label>
                        <input type="number" name="accountId" value="${filterAccountId}" placeholder="VD: 15">
                    </div>
                    <div class="filter-field">
                        <label>Module</label>
                        <select name="module">
                            <option value="">-- Tất cả --</option>
                            <c:forEach var="m" items="${modules}">
                                <option value="${m}" ${m == filterModule ? 'selected' : ''}>${m}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="filter-field">
                        <label>Hành động (action)</label>
                        <input type="text" name="action" value="${filterAction}" placeholder="VD: Duyệt shop">
                    </div>
                    <div class="filter-field">
                        <label>Từ ngày</label>
                        <input type="date" name="fromDate" value="${filterFromDate}">
                    </div>
                    <div class="filter-field">
                        <label>Đến ngày</label>
                        <input type="date" name="toDate" value="${filterToDate}">
                    </div>
                    <div class="filter-field filter-actions">
                        <button type="submit" class="btn-filter">🔍 Tìm kiếm</button>
                        <a href="${pageContext.request.contextPath}/admin/audit-logs" class="btn-clear" style="display:inline-flex;align-items:center;">Xoá lọc</a>
                    </div>
                </div>
            </form>
        </div>

        <div class="panel">
            <div class="panel-title">
                Nhật ký hệ thống
                <span style="font-size:12px;font-weight:600;color:var(--text-muted);text-transform:none;">${totalCount} bản ghi</span>
            </div>

            <c:choose>
                <c:when test="${empty logs}">
                    <div class="empty-state">
                        <div class="icon">📭</div>
                        <p>Không tìm thấy nhật ký nào phù hợp</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="audit-table-wrap">
                        <table class="audit-table">
                            <thead>
                            <tr>
                                <th>Thời gian</th>
                                <th>Tài khoản</th>
                                <th>Module</th>
                                <th>Hành động</th>
                                <th>Mô tả</th>
                                <th>Đối tượng</th>
                                <th>IP</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="log" items="${logs}">
                                <tr>
                                    <td class="cell-time">
                                        <c:if test="${not empty log.createdAt}">
                                            ${log.createdAt.dayOfMonth}/${log.createdAt.monthValue}/${log.createdAt.year}
                                            ${log.createdAt.hour}:<c:set var="m" value="${log.createdAt.minute}"/><c:if test="${m < 10}">0</c:if>${m}
                                        </c:if>
                                    </td>
                                    <td class="cell-user">
                                        <c:choose>
                                            <c:when test="${not empty log.username}">
                                                <div class="name">${log.username}</div>
                                                <div class="role">${not empty log.roleName ? log.roleName : ''} (#${log.accountId})</div>
                                            </c:when>
                                            <c:otherwise><span style="color:var(--text-dim);">Hệ thống</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><span class="badge-module">${log.module}</span></td>
                                    <td>${fn:escapeXml(log.action)}</td>
                                    <td class="cell-desc">${fn:escapeXml(log.description)}</td>
                                    <td class="cell-target">
                                        <c:if test="${not empty log.targetType}">${log.targetType}<c:if test="${not empty log.targetId}"> #${log.targetId}</c:if></c:if>
                                    </td>
                                    <td class="cell-target">${log.ipAddress}</td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <div class="pagination">
                        <div class="pagination-info">Trang ${currentPage} / ${totalPages}</div>
                        <div class="pagination-links">
                            <c:url var="prevUrl" value="/admin/audit-logs">
                                <c:param name="page" value="${currentPage - 1}"/>
                                <c:param name="accountId" value="${filterAccountId}"/>
                                <c:param name="module" value="${filterModule}"/>
                                <c:param name="action" value="${filterAction}"/>
                                <c:param name="fromDate" value="${filterFromDate}"/>
                                <c:param name="toDate" value="${filterToDate}"/>
                            </c:url>
                            <a class="page-link ${currentPage <= 1 ? 'disabled' : ''}" href="${prevUrl}">‹</a>

                            <c:forEach begin="1" end="${totalPages}" var="p">
                                <c:url var="pageUrl" value="/admin/audit-logs">
                                    <c:param name="page" value="${p}"/>
                                    <c:param name="accountId" value="${filterAccountId}"/>
                                    <c:param name="module" value="${filterModule}"/>
                                    <c:param name="action" value="${filterAction}"/>
                                    <c:param name="fromDate" value="${filterFromDate}"/>
                                    <c:param name="toDate" value="${filterToDate}"/>
                                </c:url>
                                <a class="page-link ${p == currentPage ? 'active' : ''}" href="${pageUrl}">${p}</a>
                            </c:forEach>

                            <c:url var="nextUrl" value="/admin/audit-logs">
                                <c:param name="page" value="${currentPage + 1}"/>
                                <c:param name="accountId" value="${filterAccountId}"/>
                                <c:param name="module" value="${filterModule}"/>
                                <c:param name="action" value="${filterAction}"/>
                                <c:param name="fromDate" value="${filterFromDate}"/>
                                <c:param name="toDate" value="${filterToDate}"/>
                            </c:url>
                            <a class="page-link ${currentPage >= totalPages ? 'disabled' : ''}" href="${nextUrl}">›</a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
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
        <a href="${pageContext.request.contextPath}/admin/profile" class="dropdown-link">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/admin/change-password" class="dropdown-link">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
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
<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
</body>
</html>
