<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
    <title>Đổi mật khẩu - Super Admin</title>
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
        .dropdown-link.active { color: var(--primary); font-weight: 700; }
        .dropdown-divider { height: 1px; background: var(--border-color); margin: 4px 0; }
        .dropdown-link.danger { color: var(--danger); }
        .dropdown-link.danger:hover { background: var(--danger-light); color: var(--danger); }

        /* Đặc thù trang đổi mật khẩu: nút hiện/ẩn mật khẩu + thanh đo độ mạnh */
        .pw-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 36px; width: 100%; max-width: 480px; margin: 0 auto; box-shadow: var(--dash-shadow-sm); }
        .pw-icon { width: 60px; height: 60px; border-radius: var(--radius-md); background: var(--primary-light); border: 1px solid var(--primary); display: flex; align-items: center; justify-content: center; font-size: 28px; margin-bottom: 20px; }
        .pw-title { font-size: 20px; font-weight: 800; color: var(--text-main); margin-bottom: 6px; }
        .pw-desc { font-size: 13px; color: var(--text-muted); margin-bottom: 28px; }
        .input-wrap { position: relative; }
        .input-wrap .form-control { padding-right: 44px; }
        .toggle-pw { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; color: var(--text-dim); font-size: 18px; padding: 0; line-height: 1; }
        .toggle-pw:hover { color: var(--text-main); }
        .strength-bar { height: 4px; border-radius: 2px; background: var(--border-color); margin-top: 8px; overflow: hidden; }
        .strength-fill { height: 100%; border-radius: 2px; transition: width 0.3s, background 0.3s; width: 0; }
        .strength-label { font-size: 11px; margin-top: 4px; }
    </style>
</head>
<body class="dash-body admin-theme">

<c:set var="adminActive" value="" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">lock</span> Đổi mật khẩu</h1>
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
        <div class="pw-card">
            <div class="pw-icon">🔒</div>
            <div class="pw-title">Đổi mật khẩu</div>
            <div class="pw-desc">Mật khẩu mới phải có ít nhất 6 ký tự.</div>

                <c:if test="${param.success == '1'}">
                    <div class="alert alert-success">✅ Đổi mật khẩu thành công!</div>
                </c:if>
                <c:if test="${param.error == 'wrong_current'}">
                    <div class="alert alert-danger">❌ Mật khẩu hiện tại không đúng.</div>
                </c:if>
                <c:if test="${param.error == 'not_match'}">
                    <div class="alert alert-danger">❌ Mật khẩu mới và xác nhận không khớp.</div>
                </c:if>
                <c:if test="${param.error == 'too_short'}">
                    <div class="alert alert-danger">❌ Mật khẩu mới phải có ít nhất 6 ký tự.</div>
                </c:if>
                <c:if test="${param.error == 'server'}">
                    <div class="alert alert-danger">❌ Có lỗi xảy ra, vui lòng thử lại.</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/admin/change-password" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <div class="form-group">
                        <label class="form-label">Mật khẩu hiện tại</label>
                        <div class="input-wrap">
                            <input type="password" class="form-control" name="currentPassword" id="currentPassword" placeholder="Nhập mật khẩu hiện tại..." required/>
                            <button type="button" class="toggle-pw" onclick="togglePw('currentPassword', this)">👁️</button>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Mật khẩu mới</label>
                        <div class="input-wrap">
                            <input type="password" class="form-control" name="newPassword" id="newPassword" placeholder="Nhập mật khẩu mới..." required oninput="checkStrength(this.value)"/>
                            <button type="button" class="toggle-pw" onclick="togglePw('newPassword', this)">👁️</button>
                        </div>
                        <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
                        <div class="strength-label" id="strengthLabel"></div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Xác nhận mật khẩu mới</label>
                        <div class="input-wrap">
                            <input type="password" class="form-control" name="confirmPassword" id="confirmPassword" placeholder="Nhập lại mật khẩu mới..." required oninput="checkMatch()"/>
                            <button type="button" class="toggle-pw" onclick="togglePw('confirmPassword', this)">👁️</button>
                        </div>
                        <div class="strength-label" id="matchLabel"></div>
                    </div>

                    <div class="form-actions" style="display:flex;gap:12px;margin-top:8px;">
                        <button type="submit" class="btn btn-primary">🔒 Đổi mật khẩu</button>
                        <button type="button" class="btn btn-ghost" onclick="history.back()">Huỷ</button>
                    </div>
                </form>
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
        <a href="${pageContext.request.contextPath}/admin/change-password" class="dropdown-link active">🔒 Đổi mật khẩu</a>
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

    function togglePw(id, btn) {
        var input = document.getElementById(id);
        if (input.type === 'password') {
            input.type = 'text';
            btn.textContent = '🙈';
        } else {
            input.type = 'password';
            btn.textContent = '👁️';
        }
    }

    function checkStrength(val) {
        var fill = document.getElementById('strengthFill');
        var label = document.getElementById('strengthLabel');
        var levels = [
            { w: '20%',  color: '#ef4444', text: 'Rất yếu' },
            { w: '40%',  color: '#f97316', text: 'Yếu' },
            { w: '60%',  color: '#f59e0b', text: 'Trung bình' },
            { w: '80%',  color: '#10b981', text: 'Mạnh' },
            { w: '100%', color: '#059669', text: 'Rất mạnh' }
        ];
        if (!val) { fill.style.width = '0'; label.textContent = ''; return; }

        var score = 0;
        if (val.length >= 6)  score++;
        if (val.length >= 8)  score++;
        if (val.length >= 10) score++;
        if (/[A-Z]/.test(val)) score++;
        if (/[0-9]/.test(val)) score++;
        if (/[^A-Za-z0-9]/.test(val)) score++;

        var lvl = score <= 1 ? 0 : score <= 2 ? 1 : score <= 3 ? 2 : score <= 4 ? 3 : 4;
        fill.style.width = levels[lvl].w;
        fill.style.background = levels[lvl].color;
        label.textContent = levels[lvl].text;
        label.style.color = levels[lvl].color;
    }

    function checkMatch() {
        var np = document.getElementById('newPassword').value;
        var cp = document.getElementById('confirmPassword').value;
        var lbl = document.getElementById('matchLabel');
        if (cp.length === 0) { lbl.textContent = ''; return; }
        if (np === cp) {
            lbl.textContent = '✅ Mật khẩu khớp';
            lbl.style.color = '#10b981';
        } else {
            lbl.textContent = '❌ Mật khẩu không khớp';
            lbl.style.color = '#ef4444';
        }
    }
</script>
</body>
</html>
