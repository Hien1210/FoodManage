<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 2}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi mật khẩu - ${sessionScope.account.userName}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-theme.css">
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
        .strength-fill { height: 100%; border-radius: 2px; transition: width .3s, background .3s; width: 0; }
        .strength-label { font-size: 11px; margin-top: 4px; }
        .match-msg { font-size: 12px; margin-top: 5px; }
        .match-ok { color: var(--success); }
        .match-err { color: var(--danger); }
        .pw-rules { list-style: none; margin: 10px 0 0; padding: 0; display: grid; grid-template-columns: 1fr 1fr; gap: 4px 12px; font-size: 12px; color: var(--text-dim); }
        .pw-rules li::before { content: "○"; margin-right: 6px; }
        .pw-rules li.ok { color: var(--success-dark); font-weight: 600; }
        .pw-rules li.ok::before { content: "✓"; }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">lock</span> Đổi mật khẩu</h1>
        </div>
        <div class="topbar-right">
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
            <div class="pw-desc">Nhập mật khẩu hiện tại và mật khẩu mới để cập nhật.</div>

                <c:if test="${param.success == '1'}">
                    <div class="alert alert-success">✅ Đổi mật khẩu thành công!</div>
                </c:if>
                <c:if test="${param.error == 'wrong_current'}">
                    <div class="alert alert-danger">❌ Mật khẩu hiện tại không đúng.</div>
                </c:if>
                <c:if test="${param.error == 'not_match'}">
                    <div class="alert alert-danger">❌ Mật khẩu xác nhận không khớp.</div>
                </c:if>
                <c:if test="${param.error == 'too_short'}">
                    <div class="alert alert-danger">❌ Mật khẩu mới phải có ít nhất 6 ký tự.</div>
                </c:if>
                <c:if test="${param.error == 'server'}">
                    <div class="alert alert-danger">❌ Có lỗi xảy ra, vui lòng thử lại.</div>
                </c:if>
                <c:if test="${param.error == 'missing_field'}">
                    <div class="alert alert-danger">❌ Vui lòng nhập đầy đủ thông tin.</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/shop/doi-mat-khau" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <div class="form-group">
                        <label class="form-label">Mật khẩu hiện tại</label>
                        <div class="input-wrap">
                            <input type="password" class="form-control" id="currentPassword" name="currentPassword" placeholder="Nhập mật khẩu hiện tại..." required/>
                            <button type="button" class="toggle-pw" onclick="togglePw('currentPassword', this)">👁️</button>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Mật khẩu mới</label>
                        <div class="input-wrap">
                            <input type="password" class="form-control" id="newPassword" name="newPassword" placeholder="Nhập mật khẩu mới..." required oninput="checkStrength(this.value); checkMatch();"/>
                            <button type="button" class="toggle-pw" onclick="togglePw('newPassword', this)">👁️</button>
                        </div>
                        <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
                        <div class="strength-label" id="strengthLabel"></div>
                        <ul class="pw-rules" id="pwRules">
                            <li data-rule="len">Ít nhất 6 ký tự (bắt buộc)</li>
                            <li data-rule="alnum">Có cả chữ và số</li>
                            <li data-rule="mixed">Có chữ hoa, chữ thường</li>
                            <li data-rule="special">Có ký tự đặc biệt (!@#$...)</li>
                        </ul>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Xác nhận mật khẩu mới</label>
                        <div class="input-wrap">
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu mới..." required oninput="checkMatch();"/>
                            <button type="button" class="toggle-pw" onclick="togglePw('confirmPassword', this)">👁️</button>
                        </div>
                        <div class="match-msg" id="matchMsg"></div>
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
        <span class="d-role">🏪 Shop Owner</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/shop/ho-so" class="dropdown-link">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/shop/doi-mat-khau" class="dropdown-link" style="color:var(--primary);font-weight:700;">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script>
function togglePw(id, btn) {
    var input = document.getElementById(id);
    input.type = input.type === 'password' ? 'text' : 'password';
    btn.textContent = input.type === 'password' ? '👁️' : '🙈';
}

function checkStrength(val) {
    var fill = document.getElementById('strengthFill');
    var label = document.getElementById('strengthLabel');
    var levels = [
        { min: 0,  w: '20%', color: '#ef4444', text: 'Rất yếu' },
        { min: 4,  w: '40%', color: '#f97316', text: 'Yếu' },
        { min: 6,  w: '60%', color: '#eab308', text: 'Trung bình' },
        { min: 8,  w: '80%', color: '#3b82f6', text: 'Mạnh' },
        { min: 10, w: '100%', color: '#22c55e', text: 'Rất mạnh' }
    ];
    if (!val) { fill.style.width = '0'; label.textContent = ''; return; }
    var score = 0;
    if (val.length >= 6) score++;
    if (val.length >= 8) score++;
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
    var msg = document.getElementById('matchMsg');
    if (!cp) { msg.textContent = ''; return; }
    if (np === cp) { msg.textContent = '✅ Mật khẩu khớp'; msg.className = 'match-msg match-ok'; }
    else { msg.textContent = '❌ Chưa khớp'; msg.className = 'match-msg match-err'; }
}

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
(function () {
    var input = document.getElementById("newPassword");
    var rules = document.getElementById("pwRules");
    if (!input || !rules) return;
    input.addEventListener("input", function () {
        var v = input.value;
        var ok = {
            len: v.length >= 6,
            alnum: /[A-Za-z]/.test(v) && /[0-9]/.test(v),
            mixed: /[a-z]/.test(v) && /[A-Z]/.test(v),
            special: /[^A-Za-z0-9]/.test(v)
        };
        rules.querySelectorAll("li").forEach(function (li) { li.classList.toggle("ok", !!ok[li.getAttribute("data-rule")]); });
    });
})();
</script>
</body>
</html>
