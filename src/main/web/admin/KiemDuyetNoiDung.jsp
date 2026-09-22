<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="/app-functions" prefix="app" %>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 1}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!-- Tab "Mon an cho duyet" va Tab "Quan ly Tu khoa cam" deu da noi Servlet/DAO that.
     Tab binh luan rieng da chuyen sang trang /admin/kiem-duyet-binh-luan. -->

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Kiểm duyệt nội dung - Super Admin</title>
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

        /* TABS */
        .tab-bar { display: flex; gap: 4px; border-bottom: 1px solid var(--border-color); margin-bottom: 20px; }
        .tab-btn { padding: 10px 18px; font-size: 13px; font-weight: 600; color: var(--text-muted); background: none; border: none; cursor: pointer; border-bottom: 3px solid transparent; transition: all 0.2s; }
        .tab-btn:hover { color: var(--text-main); }
        .tab-btn.active { color: var(--primary); border-bottom-color: var(--primary); }
        .tab-panel { display: none; }
        .tab-panel.active { display: block; }

        /* MODERATION CARD (dung chung cho binh luan + mon an) */
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

        /* Content dac thu cho mon an: anh thumbnail + thong tin */
        .food-row { display: flex; gap: 14px; align-items: center; background: var(--bg-hover); border: 1px solid var(--border-color); border-radius: 8px; padding: 12px 14px; margin-bottom: 14px; }
        .food-thumb { width: 64px; height: 64px; border-radius: 8px; flex-shrink: 0; display: flex; align-items: center; justify-content: center; font-size: 28px; background: linear-gradient(135deg, rgba(16,185,129,0.18), rgba(59,130,246,0.18)); border: 1px solid var(--border-color); overflow: hidden; }
        .food-thumb img { width: 100%; height: 100%; object-fit: cover; }
        .food-info .food-name { font-size: 14px; font-weight: 700; color: var(--text-main); margin-bottom: 3px; }
        .food-info .food-shop { font-size: 12px; color: var(--text-muted); }
        .food-info .food-price { font-size: 13px; font-weight: 700; color: var(--primary); margin-top: 4px; }

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

        /* Quan ly Tu khoa cam (Banned Words) */
        .word-input-row { display: flex; gap: 10px; margin-bottom: 20px; }
        .word-input-row input[type="text"] { flex: 1; background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 7px; padding: 10px 14px; font-size: 13px; color: var(--text-main); outline: none; }
        .word-input-row input[type="text"]:focus { border-color: var(--primary); }
        .btn-add-word { background: var(--primary); border: none; color: #0f172a; padding: 0 20px; border-radius: 7px; font-size: 13px; font-weight: 700; cursor: pointer; transition: 0.15s; white-space: nowrap; }
        .btn-add-word:hover { background: var(--primary-hover); }
        .word-list { display: flex; flex-wrap: wrap; gap: 10px; }
        .word-pill { display: flex; align-items: center; gap: 10px; background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 20px; padding: 8px 8px 8px 16px; font-size: 13px; color: var(--text-main); }
        .word-pill .word-text { font-weight: 600; }
        .word-pill .btn-delete-word { background: rgba(239,68,68,0.1); border: 1px solid rgba(239,68,68,0.3); color: var(--danger); width: 24px; height: 24px; border-radius: 50%; cursor: pointer; font-size: 13px; line-height: 1; display: flex; align-items: center; justify-content: center; transition: 0.15s; }
        .word-pill .btn-delete-word:hover { background: var(--danger); color: #fff; }

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
<c:set var="adminActive" value="/admin/kiem-duyet-noi-dung" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">flag</span> Kiểm duyệt nội dung</h1>
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
                Hàng đợi kiểm duyệt
                <c:if test="${not empty pendingProducts}">
                    <span class="badge red">${pendingProducts.size()} món ăn chờ duyệt</span>
                </c:if>
            </div>

            <div class="tab-bar">
                <button class="tab-btn active" onclick="switchTab('food')">🍜 Món ăn chờ duyệt (${pendingProducts.size()})</button>
                <button class="tab-btn" onclick="switchTab('bannedwords')">🔞 Quản lý Từ khóa cấm (${bannedWords.size()})</button>
            </div>

            <!-- Tab: Món ăn chờ duyệt (dữ liệu thật từ bảng Products, status = PENDING_REVIEW) -->
            <div class="tab-panel active" id="tab-food">
                <div class="mod-list" id="list-food">
                    <c:forEach var="p" items="${pendingProducts}">
                        <div class="mod-card pending">
                            <div class="mod-header">
                                <div class="mod-user">
                                    <div class="avatar-sm">${fn:toUpperCase(fn:substring(p.shopName, 0, 1))}</div>
                                    <div>
                                        <div class="mod-name">${p.shopName}</div>
                                        <div class="mod-sub">Đăng món ăn mới</div>
                                    </div>
                                </div>
                                <div class="mod-time">${app:formatDateTime(p.createdAt)}</div>
                            </div>

                            <div class="label-row">Món ăn chờ duyệt</div>
                            <div class="food-row">
                                <div class="food-thumb">
                                    <c:choose>
                                        <c:when test="${not empty p.imageUrl}">
                                            <img src="${p.imageUrl}" alt="${p.productName}"/>
                                        </c:when>
                                        <c:otherwise>🍽️</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="food-info">
                                    <div class="food-name">${p.productName}</div>
                                    <div class="food-shop">${p.description}</div>
                                </div>
                            </div>

                            <div class="reason-tags">
                                <span class="reason-tag info">🆕 Sản phẩm mới cần Super Admin duyệt</span>
                            </div>

                            <form method="post" action="${pageContext.request.contextPath}/admin/kiem-duyet-noi-dung">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="productId" value="${p.id}"/>
                                <div class="action-row">
                                    <button type="submit" name="action" value="approve" class="btn-approve">✅ Phê duyệt (Cho phép hiển thị)</button>
                                    <button type="submit" name="action" value="reject" class="btn-reject">🚫 Từ chối (Ẩn/Xóa)</button>
                                </div>
                            </form>
                        </div>
                    </c:forEach>
                </div>
                <div class="empty-state" id="empty-food" style="${empty pendingProducts ? '' : 'display:none;'}">
                    <div class="icon">✅</div>
                    <p>Không còn món ăn nào đang chờ duyệt</p>
                </div>
            </div>

            <!-- Tab: Quản lý Từ khóa cấm (dữ liệu thật từ bảng BannedWords) -->
            <div class="tab-panel" id="tab-bannedwords">
                <form method="post" action="${pageContext.request.contextPath}/admin/kiem-duyet-noi-dung" class="word-input-row">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="addWord"/>
                    <input type="text" name="word" placeholder="Nhập từ cấm mới..." maxlength="100" required/>
                    <button type="submit" class="btn-add-word">➕ Thêm từ cấm</button>
                </form>

                <div class="word-list" id="list-bannedwords">
                    <c:forEach var="bw" items="${bannedWords}">
                        <div class="word-pill">
                            <span class="word-text">${bw.word}</span>
                            <form method="post" action="${pageContext.request.contextPath}/admin/kiem-duyet-noi-dung" style="display:inline;">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="action" value="deleteWord"/>
                                <input type="hidden" name="wordId" value="${bw.id}"/>
                                <button type="submit" class="btn-delete-word" title="Xóa từ cấm">✕</button>
                            </form>
                        </div>
                    </c:forEach>
                </div>
                <div class="empty-state" id="empty-bannedwords" style="${empty bannedWords ? '' : 'display:none;'}">
                    <div class="icon">🔞</div>
                    <p>Chưa có từ cấm nào trong danh sách</p>
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

    // Toast sau khi PRG redirect ve tu form submit (approve/reject mon an, them/xoa tu cam)
    (function () {
        const params = new URLSearchParams(window.location.search);
        const success = params.get('success');
        if (!success || !window.showToast) return;
        if (success === 'approved') window.showToast('success', 'Đã phê duyệt nội dung.');
        else if (success === 'rejected') window.showToast('error', 'Đã từ chối và ẩn nội dung.');
        else if (success === 'wordAdded') window.showToast('success', 'Đã thêm từ cấm mới.');
        else if (success === 'wordDeleted') window.showToast('error', 'Đã xóa từ cấm.');
    })();

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
    });
</script>
<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
</body>
</html>
