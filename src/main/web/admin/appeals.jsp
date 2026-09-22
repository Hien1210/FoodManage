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
    <title>Kháng nghị tài khoản - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        :root { --primary-hover: var(--primary-dark); --purple: #8b5cf6; }

        .badge { font-size: 10px; padding: 3px 8px; border-radius: 10px; background: var(--border-color); color: var(--text-main); }
        .badge.red { background: var(--danger); color: #fff; font-weight: 700; }

        .main { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
        .topbar { background-color: var(--topbar-bg); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); }
        .topbar h1 { color: var(--text-main); font-size: 18px; font-weight: bold; }
        .topbar-right { display: flex; align-items: center; gap: 15px; }
        .theme-toggle { background: var(--bg-input); border: 1px solid var(--border-color); width: 38px; height: 38px; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: center; color: var(--text-main); font-size: 16px; }

        .content { padding: 28px 30px; overflow-y: auto; flex: 1; display: flex; flex-direction: column; gap: 20px; }

        .panel { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; animation: fadeUp 0.35s ease both; padding: 22px; }
        .panel-title { font-size: 14px; font-weight: bold; text-transform: uppercase; border-left: 4px solid var(--primary); padding-left: 10px; color: var(--text-main); margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; }

        /* TABS */
        .tab-bar { display: flex; gap: 4px; border-bottom: 1px solid var(--border-color); margin-bottom: 20px; }
        .tab-btn { padding: 10px 18px; font-size: 13px; font-weight: 600; color: var(--text-muted); background: none; border: none; cursor: pointer; border-bottom: 3px solid transparent; transition: all 0.2s; }
        .tab-btn:hover { color: var(--text-main); }
        .tab-btn.active { color: var(--primary); border-bottom-color: var(--primary); }
        .tab-panel { display: none; }
        .tab-panel.active { display: block; }

        /* APPEAL CARD */
        .appeal-list { display: flex; flex-direction: column; gap: 14px; }
        .appeal-card { background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 10px; animation: fadeUp 0.35s ease both; padding: 18px 20px; }
        .appeal-card.pending { border-left: 4px solid var(--warning); }
        .appeal-card.approved { border-left: 4px solid var(--primary); }
        .appeal-card.rejected { border-left: 4px solid var(--danger); }

        .appeal-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 12px; gap: 12px; }
        .appeal-user { display: flex; align-items: center; gap: 10px; }
        .avatar-sm { width: 36px; height: 36px; border-radius: 50%; background: rgba(250,204,21,0.15); color: var(--warning); display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 14px; flex-shrink: 0; }
        .appeal-name { font-size: 14px; font-weight: 700; color: var(--text-main); }
        .appeal-email { font-size: 12px; color: var(--text-muted); }
        .appeal-time { font-size: 11px; color: var(--text-dim); white-space: nowrap; }

        .label-row { font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-dim); margin-bottom: 5px; letter-spacing: 0.4px; }
        .reason-box { background: rgba(239,68,68,0.07); border: 1px solid rgba(239,68,68,0.2); border-radius: 6px; padding: 9px 12px; font-size: 13px; color: var(--text-muted); margin-bottom: 12px; }
        .message-box { background: var(--bg-hover); border: 1px solid var(--border-color); border-radius: 6px; padding: 10px 14px; font-size: 13px; color: var(--text-main); line-height: 1.6; margin-bottom: 14px; }

        .status-badge { display: inline-flex; align-items: center; gap: 5px; padding: 4px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; }
        .status-pending { background: rgba(250,204,21,0.12); color: var(--warning); }
        .status-approved { background: rgba(32,212,137,0.12); color: var(--primary); }
        .status-rejected { background: rgba(239,68,68,0.1); color: var(--danger); }

        .admin-note-input { width: 100%; background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 6px; padding: 9px 12px; color: var(--text-main); font-size: 13px; font-family: inherit; resize: vertical; outline: none; margin-bottom: 10px; }
        .admin-note-input:focus { border-color: var(--primary); }

        .action-row { display: flex; gap: 10px; }
        .btn-approve { background: rgba(32,212,137,0.12); border: 1.5px solid var(--primary); color: var(--primary); padding: 8px 18px; border-radius: 7px; font-size: 13px; font-weight: 700; cursor: pointer; transition: 0.15s; }
        .btn-approve:hover { background: var(--primary); color: #0f172a; }
        .btn-reject { background: rgba(239,68,68,0.08); border: 1.5px solid var(--danger); color: var(--danger); padding: 8px 18px; border-radius: 7px; font-size: 13px; font-weight: 700; cursor: pointer; transition: 0.15s; }
        .btn-reject:hover { background: var(--danger); color: #fff; }

        .admin-reply { background: rgba(32,212,137,0.06); border: 1px solid rgba(32,212,137,0.2); border-radius: 6px; padding: 9px 12px; font-size: 13px; color: var(--text-muted); margin-top: 10px; }

        .empty-state { text-align: center; padding: 48px 20px; color: var(--text-dim); }
        .empty-state .icon { font-size: 48px; margin-bottom: 12px; }

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
<c:set var="adminActive" value="/admin/appeals" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">gavel</span> Xử lý kháng nghị tài khoản</h1>
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

        <c:if test="${param.success == 'approved'}">
            <div style="background:rgba(32,212,137,0.1);border:1px solid var(--primary);color:var(--primary);padding:12px 16px;border-radius:8px;font-size:13px;font-weight:600;">
                ✅ Đã mở lại tài khoản thành công!
            </div>
        </c:if>
        <c:if test="${param.success == 'rejected'}">
            <div style="background:rgba(239,68,68,0.08);border:1px solid var(--danger);color:var(--danger);padding:12px 16px;border-radius:8px;font-size:13px;font-weight:600;">
                🚫 Đã từ chối kháng nghị.
            </div>
        </c:if>

        <div class="panel">
            <div class="panel-title">
                Danh sách kháng nghị
                <c:if test="${pendingCount > 0}">
                    <span class="badge red">${pendingCount} chờ xử lý</span>
                </c:if>
            </div>

            <div class="tab-bar">
                <button class="tab-btn active" onclick="switchTab('pending')">⏳ Chờ xử lý (${pendingCount})</button>
                <button class="tab-btn" onclick="switchTab('all')">📂 Tất cả (${allAppeals.size()})</button>
            </div>

            <!-- Tab chờ xử lý -->
            <div class="tab-panel active" id="tab-pending">
                <c:choose>
                    <c:when test="${empty pendingAppeals}">
                        <div class="empty-state">
                            <div class="icon">✅</div>
                            <p>Không có kháng nghị nào đang chờ xử lý</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="appeal-list">
                            <c:forEach var="ap" items="${pendingAppeals}">
                                <div class="appeal-card pending">
                                    <div class="appeal-header">
                                        <div class="appeal-user">
                                            <div class="avatar-sm">${fn:toUpperCase(fn:substring(ap.username, 0, 1))}</div>
                                            <div>
                                                <div class="appeal-name">${ap.username}
                                                    <c:if test="${not empty ap.fullName}">
                                                        <span style="font-weight:400;font-size:12px;color:var(--text-muted);">(${ap.fullName})</span>
                                                    </c:if>
                                                </div>
                                                <div class="appeal-email">${ap.email}</div>
                                            </div>
                                        </div>
                                        <div style="display:flex;flex-direction:column;align-items:flex-end;gap:4px;">
                                            <span class="status-badge status-pending">⏳ Chờ xử lý</span>
                                            <span class="appeal-time">
                                                ${ap.createdAt.dayOfMonth}/${ap.createdAt.monthValue}/${ap.createdAt.year}
                                                ${ap.createdAt.hour}:<c:set var="m" value="${ap.createdAt.minute}"/><c:if test="${m < 10}">0</c:if>${m}
                                            </span>
                                        </div>
                                    </div>

                                    <div class="label-row">Lý do bị đình chỉ</div>
                                    <c:choose>
                                        <c:when test="${not empty ap.suspendReason}">
                                            <div class="reason-box">${fn:escapeXml(ap.suspendReason)}</div>
                                        </c:when>
                                        <c:when test="${ap.accountStatus == 'BLOCKED'}">
                                            <div class="reason-box">🚫 Tài khoản bị khoá tự động do bom hàng nhiều lần (quá 6 lần từ chối nhận hàng)</div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="reason-box">Không rõ lý do</div>
                                        </c:otherwise>
                                    </c:choose>

                                    <div class="label-row">Nội dung kháng nghị</div>
                                    <div class="message-box">${fn:escapeXml(ap.message)}</div>

                                    <form method="post" action="${pageContext.request.contextPath}/admin/appeals">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="appealId" value="${ap.id}"/>
                                        <input type="hidden" name="accountId" value="${ap.accountId}"/>
                                        <textarea class="admin-note-input" name="adminNote" rows="2"
                                            placeholder="Ghi chú của Admin (tuỳ chọn)..."></textarea>
                                        <div class="action-row">
                                            <button type="submit" name="action" value="approve" class="btn-approve">
                                                ✅ Mở lại tài khoản
                                            </button>
                                            <button type="submit" name="action" value="reject" class="btn-reject">
                                                🚫 Từ chối kháng nghị
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Tab tất cả -->
            <div class="tab-panel" id="tab-all">
                <c:choose>
                    <c:when test="${empty allAppeals}">
                        <div class="empty-state">
                            <div class="icon">📭</div>
                            <p>Chưa có kháng nghị nào</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="appeal-list">
                            <c:forEach var="ap" items="${allAppeals}">
                                <div class="appeal-card ${fn:toLowerCase(ap.status)}">
                                    <div class="appeal-header">
                                        <div class="appeal-user">
                                            <div class="avatar-sm">${fn:toUpperCase(fn:substring(ap.username, 0, 1))}</div>
                                            <div>
                                                <div class="appeal-name">${ap.username}</div>
                                                <div class="appeal-email">${ap.email}</div>
                                            </div>
                                        </div>
                                        <div style="display:flex;flex-direction:column;align-items:flex-end;gap:4px;">
                                            <c:choose>
                                                <c:when test="${ap.status == 'PENDING'}"><span class="status-badge status-pending">⏳ Chờ xử lý</span></c:when>
                                                <c:when test="${ap.status == 'APPROVED'}"><span class="status-badge status-approved">✅ Đã mở lại</span></c:when>
                                                <c:when test="${ap.status == 'REJECTED'}"><span class="status-badge status-rejected">🚫 Từ chối</span></c:when>
                                            </c:choose>
                                            <span class="appeal-time">
                                                ${ap.createdAt.dayOfMonth}/${ap.createdAt.monthValue}/${ap.createdAt.year}
                                                ${ap.createdAt.hour}:<c:set var="m" value="${ap.createdAt.minute}"/><c:if test="${m < 10}">0</c:if>${m}
                                            </span>
                                        </div>
                                    </div>
                                    <div class="label-row">Nội dung kháng nghị</div>
                                    <div class="message-box">${fn:escapeXml(ap.message)}</div>
                                    <c:if test="${not empty ap.adminNote}">
                                        <div class="label-row">Ghi chú Admin</div>
                                        <div class="admin-reply">${fn:escapeXml(ap.adminNote)}</div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
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
    function switchTab(name) {
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
        document.getElementById('tab-' + name).classList.add('active');
        event.currentTarget.classList.add('active');
    }
        // Avatar dropdown
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
                avatarDropdown.addEventListener('click', function(e) {
                    e.stopPropagation();
                });
                document.addEventListener('click', function() {
                    avatarDropdown.classList.remove('open');
                });
            }
        });    </script>
    <!-- Avatar Dropdown (đặt ngoài topbar để tránh backdrop-filter stacking context) -->
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
</body>
</html>
