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
    <title>Kiểm duyệt bình luận - Super Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        :root { --primary-hover: var(--primary-dark); --purple: #8b5cf6; }

        .mock-note { background: rgba(59,130,246,0.08); border: 1px solid rgba(59,130,246,0.35); color: var(--info); padding: 11px 16px; border-radius: 8px; font-size: 12.5px; font-weight: 600; display: flex; align-items: center; gap: 8px; }

        .panel { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; animation: fadeUp 0.35s ease both; padding: 22px; }
        .panel-title { font-size: 14px; font-weight: bold; text-transform: uppercase; border-left: 4px solid var(--primary); padding-left: 10px; color: var(--text-main); margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; }

        /* TABS */
        .tab-bar { display: flex; gap: 4px; border-bottom: 1px solid var(--border-color); margin-bottom: 20px; }
        .tab-btn { padding: 10px 18px; font-size: 13px; font-weight: 600; color: var(--text-muted); background: none; border: none; cursor: pointer; border-bottom: 3px solid transparent; transition: all 0.2s; }
        .tab-btn:hover { color: var(--text-main); }
        .tab-btn.active { color: var(--primary); border-bottom-color: var(--primary); }
        .tab-panel { display: none; }
        .tab-panel.active { display: block; }

        /* MODERATION CARD */
        .mod-list { display: flex; flex-direction: column; gap: 14px; }
        .mod-card { background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 10px; animation: fadeUp 0.35s ease both; padding: 18px 20px; transition: opacity 0.25s ease, transform 0.25s ease; }
        .mod-card.pending { border-left: 4px solid var(--warning); }
        .mod-card.removing { opacity: 0; transform: translateX(20px) scale(0.98); }

        .mod-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 12px; gap: 12px; }
        .mod-user { display: flex; align-items: center; gap: 10px; }
        .avatar-sm { width: 36px; height: 36px; border-radius: 50%; background: rgba(250,204,21,0.15); color: var(--warning); display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 14px; flex-shrink: 0; }
        .mod-name { font-size: 14px; font-weight: 700; color: var(--text-main); }
        .mod-sub { font-size: 12px; color: var(--text-muted); }
        .mod-time { font-size: 11px; color: var(--text-dim); white-space: nowrap; }

        .label-row { font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-dim); margin-bottom: 6px; letter-spacing: 0.4px; }
        .message-box { background: var(--bg-hover); border: 1px solid var(--border-color); border-radius: 6px; padding: 10px 14px; font-size: 13px; color: var(--text-main); line-height: 1.6; margin-bottom: 14px; }
        .message-box mark.bad-word { background: rgba(239,68,68,0.25); color: var(--danger); font-weight: 800; padding: 1px 4px; border-radius: 4px; }

        .reason-tags { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 14px; }
        .reason-tag { font-size: 11px; font-weight: 700; padding: 4px 11px; border-radius: 20px; display: flex; align-items: center; gap: 5px; }
        .reason-tag.danger { background: rgba(239,68,68,0.1); border: 1px solid rgba(239,68,68,0.3); color: var(--danger); }
        .reason-tag.warn { background: rgba(250,204,21,0.12); border: 1px solid rgba(250,204,21,0.35); color: var(--warning); }
        .reason-tag.info { background: rgba(59,130,246,0.1); border: 1px solid rgba(59,130,246,0.3); color: var(--info); }

        .action-row { display: flex; gap: 10px; }
        .btn-approve { background: rgba(32,212,137,0.12); border: 1.5px solid var(--primary); color: var(--primary); padding: 8px 18px; border-radius: 7px; font-size: 13px; font-weight: 700; cursor: pointer; transition: 0.15s; }
        .btn-approve:hover { background: var(--primary); color: #ffffff; }
        .btn-reject { background: rgba(239,68,68,0.08); border: 1.5px solid var(--danger); color: var(--danger); padding: 8px 18px; border-radius: 7px; font-size: 13px; font-weight: 700; cursor: pointer; transition: 0.15s; }
        .btn-reject:hover { background: var(--danger); color: #fff; }

        .empty-state { text-align: center; padding: 48px 20px; color: var(--text-dim); }
        .empty-state .icon { font-size: 48px; margin-bottom: 12px; }

        /* LICH SU XU LY */
        .history-table { width: 100%; border-collapse: collapse; }
        .history-table th { text-align: left; font-size: 11px; text-transform: uppercase; letter-spacing: 0.4px; color: var(--text-dim); padding: 10px 12px; border-bottom: 1px solid var(--border-color); }
        .history-table td { padding: 12px; font-size: 13px; color: var(--text-main); border-bottom: 1px solid var(--border-color); vertical-align: top; }
        .history-table tr:last-child td { border-bottom: none; }
        .history-comment { color: var(--text-muted); max-width: 340px; }
        .status-pill { font-size: 11px; font-weight: 700; padding: 4px 11px; border-radius: 20px; display: inline-block; white-space: nowrap; }
        .status-pill.visible { background: rgba(32,212,137,0.12); border: 1px solid var(--primary); color: var(--primary); }
        .status-pill.removed { background: rgba(239,68,68,0.1); border: 1px solid var(--danger); color: var(--danger); }

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
<c:set var="adminActive" value="/admin/kiem-duyet-binh-luan" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">rate_review</span> Kiểm duyệt bình luận</h1>
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
            <div class="panel-title">
                Hàng đợi kiểm duyệt bình luận
                <c:if test="${not empty pendingComments}">
                    <span class="badge red">${pendingComments.size()} bình luận chờ duyệt</span>
                </c:if>
            </div>

            <div class="tab-bar">
                <button class="tab-btn active" onclick="switchTab('pending')">🚩 Bình luận chờ duyệt</button>
                <button class="tab-btn" onclick="switchTab('history')">🗂️ Lịch sử xử lý</button>
            </div>

            <!-- Tab 1: Bình luận chờ duyệt -->
            <div class="tab-panel active" id="tab-pending">
                <div class="mod-list" id="list-pending">
                    <c:forEach var="fb" items="${pendingComments}">
                        <div class="mod-card pending">
                            <div class="mod-header">
                                <div class="mod-user">
                                    <div class="avatar-sm">${fn:toUpperCase(fn:substring(fn:escapeXml(fb.reviewerName), 0, 1))}</div>
                                    <div>
                                        <div class="mod-name">${fn:escapeXml(fb.reviewerName)}</div>
                                        <div class="mod-sub">Bình luận về ${fb.targetType eq 'SHOP' ? 'Shop' : 'Shipper'} <strong>${fn:escapeXml(fb.targetName)}</strong></div>
                                    </div>
                                </div>
                                <div class="mod-time">${app:formatDateTime(fb.createdAt)}</div>
                            </div>

                            <div class="label-row">Nội dung bình luận</div>
                            <div class="message-box">"${fb.highlightedComment}"</div>

                            <div class="reason-tags">
                                <span class="reason-tag danger">🔞 Chứa từ cấm</span>
                            </div>

                            <div class="action-row">
                                <form method="post" action="${pageContext.request.contextPath}/admin/kiem-duyet-binh-luan" style="display:inline;">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                    <input type="hidden" name="feedbackId" value="${fb.id}">
                                    <input type="hidden" name="action" value="approve">
                                    <button type="submit" class="btn-approve">✅ Phê duyệt (Hiển thị)</button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/admin/kiem-duyet-binh-luan" style="display:inline;">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                    <input type="hidden" name="feedbackId" value="${fb.id}">
                                    <input type="hidden" name="action" value="reject">
                                    <button type="submit" class="btn-reject">🚫 Xóa bỏ</button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                <div class="empty-state" id="empty-pending" style="${empty pendingComments ? 'display:block;' : 'display:none;'}">
                    <div class="icon">✅</div>
                    <p>Không còn bình luận nào đang chờ duyệt</p>
                </div>
            </div>

            <!-- Tab 2: Lịch sử xử lý -->
            <div class="tab-panel" id="tab-history">
                <table class="history-table">
                    <thead>
                    <tr>
                        <th>Người gửi</th>
                        <th>Nội dung bình luận</th>
                        <th>Đối tượng</th>
                        <th>Trạng thái</th>
                        <th>Thời gian xử lý</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="fb" items="${historyComments}">
                        <tr>
                            <td><strong style="color: var(--text-main);">${fn:escapeXml(fb.reviewerName)}</strong></td>
                            <td class="history-comment">"${fb.highlightedComment}"</td>
                            <td>${fn:escapeXml(fb.targetName)}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${fb.status == 'VISIBLE'}">
                                        <span class="status-pill visible">✅ Đã phê duyệt</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-pill removed">🚫 Đã xóa bỏ</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${app:formatDateTime(fb.reviewedAt)}</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
                <div class="empty-state" style="${empty historyComments ? 'display:block;' : 'display:none;'}">
                    <div class="icon">🗂️</div>
                    <p>Chưa có bình luận nào được xử lý</p>
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
    function switchTab(name) {
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
        document.getElementById('tab-' + name).classList.add('active');
        event.currentTarget.classList.add('active');
    }

    // Toast thong bao sau khi Phe duyet/Xoa bo (PRG redirect ve voi ?success=...)
    (function () {
        const params = new URLSearchParams(window.location.search);
        const success = params.get('success');
        if (!success || !window.showToast) return;
        if (success === 'approved') window.showToast('success', 'Đã phê duyệt bình luận.');
        else if (success === 'rejected') window.showToast('error', 'Đã xóa bỏ bình luận.');
    })();

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
