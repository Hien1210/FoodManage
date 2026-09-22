<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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
    <title>Quản lý khiếu nại - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        :root { --primary-hover: var(--primary-dark); --purple: #8b5cf6; }

        .panel { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; animation: fadeUp 0.35s ease both; padding: 22px; }
        .panel-title { font-size: 14px; font-weight: bold; text-transform: uppercase; border-left: 4px solid var(--primary); padding-left: 10px; color: var(--text-main); margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; }

        .filter-bar { display: flex; gap: 8px; margin-bottom: 18px; }
        .filter-btn { padding: 8px 16px; border-radius: 20px; border: 1.5px solid var(--border-color); background: var(--bg-input); color: var(--text-muted); font-size: 12.5px; font-weight: 700; cursor: pointer; }
        .filter-btn.active { border-color: var(--primary); color: var(--primary); background: var(--primary-light); }

        .mod-list { display: flex; flex-direction: column; gap: 14px; }
        .mod-card { background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 10px; animation: fadeUp 0.35s ease both; padding: 18px 20px; }
        .mod-card.pending { border-left: 4px solid var(--warning); }
        .mod-card.processing { border-left: 4px solid var(--info); }
        .mod-card.resolved { border-left: 4px solid var(--primary); }
        .mod-card.rejected { border-left: 4px solid var(--danger); }

        .mod-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 12px; gap: 12px; flex-wrap: wrap; }
        .mod-user { display: flex; align-items: center; gap: 10px; }
        .avatar-sm { width: 36px; height: 36px; border-radius: 50%; background: rgba(250,204,21,0.15); color: var(--warning); display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 14px; flex-shrink: 0; }
        .mod-name { font-size: 14px; font-weight: 700; color: var(--text-main); }
        .mod-sub { font-size: 12px; color: var(--text-muted); }
        .mod-time { font-size: 11px; color: var(--text-dim); white-space: nowrap; }

        .label-row { font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-dim); margin-bottom: 6px; letter-spacing: 0.4px; }
        .message-box { background: var(--bg-hover); border: 1px solid var(--border-color); border-radius: 6px; padding: 10px 14px; font-size: 13px; color: var(--text-main); line-height: 1.6; margin-bottom: 14px; white-space: pre-wrap; }
        .reply-box { background: rgba(16,185,129,0.08); border: 1px solid rgba(16,185,129,0.3); border-radius: 6px; padding: 10px 14px; font-size: 13px; color: var(--text-main); line-height: 1.6; margin-bottom: 10px; }

        .status-pill { font-size: 11px; font-weight: 700; padding: 4px 11px; border-radius: 20px; display: inline-block; white-space: nowrap; }
        .status-pill.pending { background: rgba(250,204,21,0.12); border: 1px solid var(--warning); color: var(--warning); }
        .status-pill.processing { background: rgba(59,130,246,0.1); border: 1px solid var(--info); color: var(--info); }
        .status-pill.resolved { background: rgba(16,185,129,0.12); border: 1px solid var(--primary); color: var(--primary); }
        .status-pill.rejected { background: rgba(239,68,68,0.1); border: 1px solid var(--danger); color: var(--danger); }

        .reply-form { display: flex; gap: 8px; margin-top: 10px; }
        .reply-form textarea { flex: 1; min-height: 44px; resize: vertical; padding: 8px 10px; border-radius: 6px; border: 1.5px solid var(--border-color); background: var(--bg-input); color: var(--text-main); font-size: 13px; }
        .reply-actions { display: flex; flex-direction: column; gap: 6px; }
        .btn-approve { background: rgba(32,212,137,0.12); border: 1.5px solid var(--primary); color: var(--primary); padding: 8px 14px; border-radius: 7px; font-size: 12.5px; font-weight: 700; cursor: pointer; transition: 0.15s; white-space: nowrap; }
        .btn-approve:hover { background: var(--primary); color: #ffffff; }
        .btn-reject { background: rgba(239,68,68,0.08); border: 1.5px solid var(--danger); color: var(--danger); padding: 8px 14px; border-radius: 7px; font-size: 12.5px; font-weight: 700; cursor: pointer; transition: 0.15s; white-space: nowrap; }
        .btn-reject:hover { background: var(--danger); color: #fff; }

        .empty-state { text-align: center; padding: 48px 20px; color: var(--text-dim); }
        .empty-state .icon { font-size: 48px; margin-bottom: 12px; }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .avatar-wrapper { position: relative; }
        .avatar-dropdown { display: none; position: fixed; right: auto; top: auto; background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: var(--dash-shadow-md); min-width: 220px; z-index: 500; animation: pobFadeUp 0.2s ease both; }
        .avatar-dropdown.open { display: block; }
        .dropdown-header { padding: 14px 16px; border-bottom: 1px solid var(--border-color); }
        .dropdown-header .d-name { font-size: 14px; font-weight: 700; color: var(--text-main); }
        .dropdown-header .d-email { font-size: 12px; color: var(--text-muted); margin-top: 2px; }
        .dropdown-header .d-role { display: inline-block; margin-top: 6px; font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 4px; background: var(--primary-light); color: var(--primary); border: 1px solid var(--primary); }
        .dropdown-body { padding: 6px 0 8px; }
        .dropdown-link { display: flex; align-items: center; gap: 10px; padding: 10px 16px; font-size: 13px; color: var(--text-muted); cursor: pointer; transition: background 0.15s; text-decoration: none; }
        .dropdown-link:hover { background: var(--bg-input); color: var(--text-main); }
        .dropdown-divider { height: 1px; background: var(--border-color); margin: 4px 0; }
        .dropdown-link.danger { color: var(--danger); }
        .dropdown-link.danger:hover { background: var(--danger-light); color: var(--danger); }
    </style>
</head>
<body class="dash-body admin-theme">
<c:set var="adminActive" value="/admin/khieu-nai" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">campaign</span> Quản lý khiếu nại đơn hàng</h1>
        </div>
        <div class="topbar-right">
            <button type="button" class="theme-toggle" onclick="pobToggleTheme()" title="Chuyển đổi giao diện">
                <span data-theme-icon>🌙</span>
            </button>
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

        <c:if test="${param.success eq 'resolved'}">
            <div class="alert alert-success" style="background:rgba(16,185,129,.12);border:1px solid var(--primary);color:var(--primary);padding:12px 16px;border-radius:8px;font-size:13px;">✅ Đã đánh dấu khiếu nại là đã giải quyết.</div>
        </c:if>
        <c:if test="${param.success eq 'rejected'}">
            <div style="background:rgba(239,68,68,.1);border:1px solid var(--danger);color:var(--danger);padding:12px 16px;border-radius:8px;font-size:13px;">🚫 Đã từ chối khiếu nại.</div>
        </c:if>
        <c:if test="${param.error eq 'empty_reply'}">
            <div style="background:rgba(239,68,68,.1);border:1px solid var(--danger);color:var(--danger);padding:12px 16px;border-radius:8px;font-size:13px;">⚠️ Vui lòng nhập nội dung phản hồi trước khi xử lý.</div>
        </c:if>

        <div class="panel">
            <div class="panel-title">
                Danh sách khiếu nại
                <c:if test="${not empty complaints}">
                    <span class="badge">${complaints.size()} khiếu nại</span>
                </c:if>
            </div>

            <div class="filter-bar">
                <a href="${pageContext.request.contextPath}/admin/khieu-nai" class="filter-btn ${empty statusFilter ? 'active' : ''}">Tất cả</a>
                <a href="${pageContext.request.contextPath}/admin/khieu-nai?status=PENDING" class="filter-btn ${statusFilter eq 'PENDING' ? 'active' : ''}">⏳ Chờ xử lý</a>
                <a href="${pageContext.request.contextPath}/admin/khieu-nai?status=PROCESSING" class="filter-btn ${statusFilter eq 'PROCESSING' ? 'active' : ''}">🔄 Đang xử lý</a>
                <a href="${pageContext.request.contextPath}/admin/khieu-nai?status=RESOLVED" class="filter-btn ${statusFilter eq 'RESOLVED' ? 'active' : ''}">✅ Đã giải quyết</a>
                <a href="${pageContext.request.contextPath}/admin/khieu-nai?status=REJECTED" class="filter-btn ${statusFilter eq 'REJECTED' ? 'active' : ''}">❌ Từ chối</a>
            </div>

            <div class="mod-list">
                <c:forEach var="c" items="${complaints}">
                    <div class="mod-card ${fn:toLowerCase(c.status)}">
                        <div class="mod-header">
                            <div class="mod-user">
                                <div class="avatar-sm">${fn:toUpperCase(fn:substring(empty c.accountName ? '?' : c.accountName, 0, 1))}</div>
                                <div>
                                    <div class="mod-name">${empty c.accountName ? 'Khách hàng' : c.accountName}</div>
                                    <div class="mod-sub">Khiếu nại đơn <strong>#${c.orderId}</strong> — <c:out value="${c.subject}"/></div>
                                </div>
                            </div>
                            <div style="display:flex;align-items:center;gap:8px;">
                                <span class="status-pill ${fn:toLowerCase(c.status)}">
                                    <c:choose>
                                        <c:when test="${c.status eq 'PENDING'}">⏳ Chờ xử lý</c:when>
                                        <c:when test="${c.status eq 'PROCESSING'}">🔄 Đang xử lý</c:when>
                                        <c:when test="${c.status eq 'RESOLVED'}">✅ Đã giải quyết</c:when>
                                        <c:otherwise>❌ Từ chối</c:otherwise>
                                    </c:choose>
                                </span>
                                <div class="mod-time">${app:formatDateTime(c.createdAt)}</div>
                            </div>
                        </div>

                        <div class="label-row">Nội dung khiếu nại</div>
                        <div class="message-box"><c:out value="${c.content}"/></div>

                        <c:if test="${not empty c.adminReply}">
                            <div class="label-row">Phản hồi của Admin</div>
                            <div class="reply-box"><c:out value="${c.adminReply}"/></div>
                        </c:if>

                        <c:if test="${c.status eq 'PENDING' || c.status eq 'PROCESSING'}">
                            <form method="post" action="${pageContext.request.contextPath}/admin/khieu-nai" class="reply-form">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="complaintId" value="${c.id}"/>
                                <textarea name="reply" placeholder="Nhập phản hồi cho khách hàng..." required></textarea>
                                <div class="reply-actions">
                                    <button type="submit" name="action" value="resolve" class="btn-approve">✅ Giải quyết</button>
                                    <button type="submit" name="action" value="reject" class="btn-reject">🚫 Từ chối</button>
                                </div>
                            </form>
                        </c:if>
                    </div>
                </c:forEach>

                <div class="empty-state" style="${empty complaints ? 'display:block;' : 'display:none;'}">
                    <div class="icon">📭</div>
                    <p>Không có khiếu nại nào khớp bộ lọc.</p>
                </div>
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
</body>
</html>
