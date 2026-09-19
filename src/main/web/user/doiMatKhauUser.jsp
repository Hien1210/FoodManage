<%@ page pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi mật khẩu - FOOD MANAGE</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user-theme.css">
    <style>
        :root {
            --bg:         #FFF9F2;
            --surface:    #FFFFFF;
            --surface-lt: #FFF4EC;
            --gold:       #FF3B1F;
            --gold-hover: #E02A10;
            --text:       #2D2421;
            --muted:      #635752;
            --border:     #F1E4D6;
            --font-h: 'Quicksand', 'Plus Jakarta Sans', sans-serif;
            --font-b:  'Plus Jakarta Sans', sans-serif;
            --tr: all .25s ease;
            --shadow: 0 14px 36px rgba(99,44,20,.14);
            --glow:   0 8px 22px rgba(255,59,31,.3);
        }
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: var(--font-b); background: var(--bg); color: var(--text); min-height: 100vh; }
        a { text-decoration: none; color: inherit; transition: var(--tr); }

        /* NAVBAR (dong bo voi trang chu) */
        .navbar {
            position: fixed; top: 0; left: 0; width: 100%; z-index: 1000;
            background: rgba(255,249,242,.92); backdrop-filter: blur(14px);
            border-bottom: 1px solid var(--border);
        }
        .nav-content { max-width: 1180px; margin: 0 auto; padding: 0 20px; display: flex; justify-content: space-between; align-items: center; height: 76px; gap: 16px; }
        .logo { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
        .logo h1 { font-family: var(--font-h); white-space: nowrap; font-size: 1.55rem; font-weight: 800; letter-spacing: -.5px; }
        .logo span { color: var(--gold); }
        .nav-links { display: flex; gap: 20px; align-items: center; }
        .nav-links a { font-size: .85rem; font-weight: 600; color: var(--muted); white-space: nowrap; }
        .nav-links a:hover, .nav-links a.active { color: var(--gold); }
        .nav-actions { display: flex; align-items: center; gap: 14px; }

        .avatar-wrap { position: relative; }
        .avatar-btn {
            width: 40px; height: 40px; border-radius: 50%;
            background: linear-gradient(135deg, var(--gold), var(--gold-hover));
            color: #FFF; font-size: 15px; font-weight: 800;
            border: none; cursor: pointer; font-family: var(--font-b);
            display: flex; align-items: center; justify-content: center; box-shadow: var(--glow);
        }
        .avatar-dropdown {
            position: absolute; top: calc(100% + 12px); right: 0;
            background: var(--surface); border: 1px solid var(--border); border-radius: 16px;
            min-width: 220px; z-index: 200; display: none; box-shadow: var(--shadow); overflow: hidden;
        }
        .avatar-dropdown.open { display: block; }
        .dd-head { padding: 16px 18px; border-bottom: 1px solid var(--border); background: var(--surface-lt); }
        .dd-name { font-size: 14px; font-weight: 700; color: var(--text); }
        .dd-email { font-size: 11.5px; color: var(--muted); margin-top: 3px; }
        .dd-link, .dd-btn {
            display: flex; align-items: center; gap: 10px; width: 100%; padding: 12px 18px;
            font-size: 13px; font-weight: 600; color: var(--muted); background: none; border: none;
            cursor: pointer; font-family: var(--font-b); transition: var(--tr); text-align: left;
        }
        .dd-link i, .dd-btn i { color: var(--gold); width: 14px; }
        .dd-link:hover, .dd-btn:hover { color: var(--gold); background: var(--surface-lt); }
        .dd-divider { height: 1px; background: var(--border); margin: 4px 0; }

        .cart-btn {
            background: var(--surface-lt); border: 1.5px solid var(--border); border-radius: 50%;
            width: 42px; height: 42px; color: var(--text); font-size: 1.05rem; cursor: pointer;
            position: relative; transition: var(--tr); display: flex; align-items: center; justify-content: center;
        }
        .cart-btn:hover { color: var(--gold); border-color: var(--gold); }
        .cart-count { position: absolute; top: -4px; right: -4px; background: #ef4444; color: #fff; border-radius: 999px; font-size: 10px; min-width: 16px; height: 16px; line-height: 16px; text-align: center; padding: 0 3px; font-weight: 700; }

        .container { max-width: 480px; margin: 0 auto; padding: 110px 20px 80px; }

        .alert { display: flex; align-items: center; gap: 10px; padding: 14px 18px; margin-bottom: 20px; border-radius: 14px; border: 1px solid; font-size: .9rem; font-weight: 600; }
        .alert-success { background: #EAFBF1; border-color: #BBF0CF; color: #15803D; }
        .alert-danger  { background: #FEECEF; border-color: #FBD0D8; color: #E11D48; }

        .pw-card { background: var(--surface); border: 1px solid var(--border); border-radius: 20px; box-shadow: 0 4px 18px rgba(99,44,20,.06); padding: 32px; }
        .pw-icon { width: 56px; height: 56px; border-radius: 16px; background: var(--surface-lt); border: 1px solid var(--gold); display: flex; align-items: center; justify-content: center; font-size: 26px; margin-bottom: 18px; }
        .pw-title { font-family: var(--font-h); font-size: 19px; font-weight: 800; color: var(--text); margin-bottom: 4px; }
        .pw-desc { font-size: 13px; color: var(--muted); margin-bottom: 24px; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-size: 13px; font-weight: 700; color: var(--text); margin-bottom: 6px; }
        .input-wrap { position: relative; }
        .input-wrap input { width: 100%; padding: 11px 44px 11px 14px; border-radius: 10px; border: 1.5px solid var(--border); background: var(--surface-lt); color: var(--text); font-size: 13.5px; font-family: var(--font-b); }
        .input-wrap input:focus { outline: none; border-color: var(--gold); background: var(--surface); }
        .toggle-pw { position: absolute; right: 10px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; color: var(--muted); font-size: 17px; padding: 0; line-height: 1; }
        .toggle-pw:hover { color: var(--text); }
        .strength-bar { height: 4px; border-radius: 2px; background: var(--border); margin-top: 8px; overflow: hidden; }
        .strength-fill { height: 100%; border-radius: 2px; transition: width .3s, background .3s; width: 0; }
        .strength-label { font-size: 11px; margin-top: 4px; }
        .match-msg { font-size: 12px; margin-top: 5px; }
        .match-ok { color: #15803D; }
        .match-err { color: #E11D48; }
        .form-actions { display: flex; gap: 10px; margin-top: 8px; }
        .btn-submit { padding: 11px 24px; border-radius: 50px; border: none; background: linear-gradient(135deg, var(--gold), #E02A10); color: #fff; font-weight: 700; font-size: 13.5px; cursor: pointer; box-shadow: 0 8px 22px rgba(255,59,31,.32); }
        .btn-submit:hover { filter: brightness(1.05); }
        .btn-cancel { padding: 11px 24px; border-radius: 50px; border: 1.5px solid var(--border); background: var(--surface); color: var(--muted); font-weight: 700; font-size: 13.5px; cursor: pointer; }
        .btn-cancel:hover { color: var(--gold); border-color: var(--gold); background: var(--surface-lt); }
    </style>
</head>
<body>

<header class="navbar">
    <div class="nav-content">
        <a class="logo" href="${pageContext.request.contextPath}/user/home" style="text-decoration:none;color:inherit;">
            <img class="logo-emoji" src="https://cdn.jsdelivr.net/gh/microsoft/fluentui-emoji@main/assets/Steaming%20bowl/3D/steaming_bowl_3d.png" alt="" style="width:30px;height:30px;">
            <h1>FOOD MANAGE<span>.</span></h1>
        </a>
        <nav class="nav-links">
            <a href="${pageContext.request.contextPath}/user/home">Trang chủ</a>
            <a href="${pageContext.request.contextPath}/user/donhang">Đơn hàng</a>
            <a href="${pageContext.request.contextPath}/user/dia-chi">Địa chỉ</a>
            <a href="${pageContext.request.contextPath}/user/diem-thuong">Điểm thưởng</a>
        </nav>
        <div class="nav-actions">
            <div class="avatar-wrap" id="avatarWrap">
                <button class="avatar-btn" onclick="toggleDropdown()" aria-label="Tài khoản">
                    <c:choose>
                        <c:when test="${not empty account.avatarUrl}">
                            <img src="${account.avatarUrl}" alt="Avatar" style="width:100%;height:100%;object-fit:cover;border-radius:50%;">
                        </c:when>
                        <c:otherwise>${fn:substring(not empty account.fullName ? account.fullName : account.userName, 0, 1)}</c:otherwise>
                    </c:choose>
                </button>
                <div class="avatar-dropdown" id="accountDropdown">
                    <div class="dd-head">
                        <div class="dd-name">${not empty account.fullName ? account.fullName : account.userName}</div>
                        <c:if test="${not empty account.email}"><div class="dd-email">${account.email}</div></c:if>
                    </div>
                    <a href="${pageContext.request.contextPath}/user/thong-tin-ca-nhan" class="dd-link"><i class="fa-solid fa-user"></i> Thông tin cá nhân</a>
                    <a href="${pageContext.request.contextPath}/user/donhang" class="dd-link"><i class="fa-solid fa-box"></i> Đơn hàng của tôi</a>
                    <a href="${pageContext.request.contextPath}/user/dia-chi" class="dd-link"><i class="fa-solid fa-location-dot"></i> Địa chỉ giao hàng</a>
                    <a href="${pageContext.request.contextPath}/user/diem-thuong" class="dd-link"><i class="fa-solid fa-star"></i> Điểm thưởng & Voucher</a>
                    <a href="${pageContext.request.contextPath}/user/thong-bao" class="dd-link"><i class="fa-solid fa-bell"></i> Thông báo</a>
                    <a href="${pageContext.request.contextPath}/user/cart" class="dd-link"><i class="fa-solid fa-cart-shopping"></i> Giỏ hàng</a>
                    <a href="${pageContext.request.contextPath}/user/doi-mat-khau" class="dd-link"><i class="fa-solid fa-lock"></i> Đổi mật khẩu</a>
                    <div class="dd-divider"></div>
                    <form action="${pageContext.request.contextPath}/logout" method="post">
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <button type="submit" class="dd-btn"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</button>
                    </form>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/user/thong-bao" class="cart-btn" aria-label="Thông báo">
                <i class="fa-solid fa-bell"></i>
                <span class="cart-count" data-notif-badge style="display:${unreadNotifCount > 0 ? 'inline-block' : 'none'};">${unreadNotifCount}</span>
            </a>
            <a href="${pageContext.request.contextPath}/user/cart" class="cart-btn" aria-label="Giỏ hàng">
                <i class="fa-solid fa-bag-shopping"></i>
            </a>
        </div>
    </div>
</header>

<div class="container">
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

        <form action="${pageContext.request.contextPath}/user/doi-mat-khau" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <div class="form-group">
                <label>Mật khẩu hiện tại</label>
                <div class="input-wrap">
                    <input type="password" id="currentPassword" name="currentPassword" placeholder="Nhập mật khẩu hiện tại..." required>
                    <button type="button" class="toggle-pw" onclick="togglePw('currentPassword', this)">👁️</button>
                </div>
            </div>
            <div class="form-group">
                <label>Mật khẩu mới</label>
                <div class="input-wrap">
                    <input type="password" id="newPassword" name="newPassword" placeholder="Nhập mật khẩu mới..." required oninput="checkStrength(this.value); checkMatch();">
                    <button type="button" class="toggle-pw" onclick="togglePw('newPassword', this)">👁️</button>
                </div>
                <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
                <div class="strength-label" id="strengthLabel"></div>
            </div>
            <div class="form-group">
                <label>Xác nhận mật khẩu mới</label>
                <div class="input-wrap">
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu mới..." required oninput="checkMatch();">
                    <button type="button" class="toggle-pw" onclick="togglePw('confirmPassword', this)">👁️</button>
                </div>
                <div class="match-msg" id="matchMsg"></div>
            </div>
            <div class="form-actions">
                <button type="submit" class="btn-submit">🔒 Đổi mật khẩu</button>
                <button type="button" class="btn-cancel" onclick="history.back()">Huỷ</button>
            </div>
        </form>
    </div>
</div>

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

function toggleDropdown() {
    document.getElementById('accountDropdown').classList.toggle('open');
}
document.addEventListener('click', function(e) {
    var w = document.getElementById('avatarWrap');
    if (w && !w.contains(e.target)) document.getElementById('accountDropdown').classList.remove('open');
});
</script>
<script>window.POB_CONTEXT_PATH = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/notifications-ws.js"></script>
</body>
</html>
