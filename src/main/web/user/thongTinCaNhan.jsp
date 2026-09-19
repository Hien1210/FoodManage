<%@ page pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Thông tin cá nhân - FOOD MANAGE</title>
<meta name="_csrf" content="${sessionScope.csrfToken}">
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
    --font-b: 'Plus Jakarta Sans', sans-serif;
    --tr: all 0.3s ease;
    --shadow: 0 14px 34px rgba(99,44,20,.14);
    --glow:   0 8px 20px rgba(255,59,31,.28);
    --success: #15803D; --info: #1D4ED8; --danger: #E11D48;
}
*, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: var(--font-b); background: var(--bg); color: var(--text); min-height: 100vh; }
a { text-decoration: none; color: inherit; transition: var(--tr); }

/* NAVBAR (đồng bộ với trang chủ user/trangnguoidung.jsp) */
.navbar {
    position: sticky; top: 0; left: 0; width: 100%;
    background: rgba(255,251,248,.92);
    backdrop-filter: blur(14px);
    z-index: 1000;
    border-bottom: 1px solid var(--border);
}
.nav-content {
    max-width: 1180px; margin: 0 auto; padding: 0 20px;
    display: flex; justify-content: space-between; align-items: center; height: 76px; gap: 16px;
}
.logo { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
.logo h1 { font-family: var(--font-h); font-size: 1.55rem; letter-spacing: -.5px; }
.logo span { color: var(--gold); }
.logo-emoji { width: 30px; height: 30px; filter: drop-shadow(0 4px 8px rgba(255,59,31,.4)); }
.nav-links { display: flex; gap: 20px; align-items: center; }
.nav-links a { font-size: .86rem; font-weight: 600; color: var(--muted); white-space: nowrap; }
.nav-links a:hover, .nav-links a.active { color: var(--gold); }
.nav-actions { display: flex; align-items: center; gap: 14px; }
.nav-search { position: relative; }
.nav-search input {
    background: var(--surface-lt); border: 1.5px solid var(--border); border-radius: 50px;
    color: var(--text); font-family: var(--font-b); font-size: .85rem;
    padding: 9px 16px 9px 38px; width: 200px; transition: var(--tr);
}
.nav-search input:focus { outline: none; border-color: var(--gold); width: 240px; background: var(--surface); }
.nav-search input::placeholder { color: var(--muted); }
.nav-search i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: .85rem; pointer-events: none; }
.avatar-wrap { position: relative; }
.avatar-btn {
    width: 38px; height: 38px; border-radius: 50%;
    background: linear-gradient(135deg, var(--gold), var(--gold-hover));
    color: #FFF; font-size: 14px; font-weight: 800;
    border: none; cursor: pointer; font-family: var(--font-b);
    display: flex; align-items: center; justify-content: center;
    box-shadow: 0 8px 22px rgba(255,59,31,.3);
    overflow: hidden;
}
.avatar-btn img { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }
.avatar-dropdown {
    position: absolute; top: calc(100% + 12px); right: 0;
    background: var(--surface); border: 1px solid var(--border); border-radius: 16px;
    min-width: 220px; z-index: 200;
    display: none; box-shadow: var(--shadow);
    overflow: hidden;
}
.avatar-dropdown.open { display: block; }
.dd-head { padding: 16px 18px; border-bottom: 1px solid var(--border); background: var(--surface-lt); }
.dd-name { font-size: 14px; font-weight: 700; color: var(--text); }
.dd-email { font-size: 11.5px; color: var(--muted); margin-top: 3px; }
.dd-link, .dd-btn {
    display: flex; align-items: center; gap: 10px;
    width: 100%; padding: 12px 18px;
    font-size: 13px; font-weight: 600; color: var(--muted);
    background: none; border: none; cursor: pointer;
    font-family: var(--font-b); transition: var(--tr); text-align: left;
}
.dd-link i, .dd-btn i { color: var(--gold); width: 14px; }
.dd-link:hover, .dd-btn:hover { background: var(--surface-lt); color: var(--text); }
.dd-link.active { color: var(--gold); background: var(--surface-lt); }
.dd-divider { height: 1px; background: var(--border); margin: 4px 0; }
.cart-btn {
    width: 38px; height: 38px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    background: var(--surface-lt); border: 1.5px solid var(--border); color: var(--text);
    font-size: 15px; transition: var(--tr); flex-shrink: 0; text-decoration: none;
}
.cart-btn:hover { border-color: var(--gold); color: var(--gold); }
@media (max-width: 860px) { .nav-links, .nav-search { display: none; } }

/* CONTAINER */
.container { max-width: 740px; margin: 0 auto; padding: 44px 20px 80px; }

/* ALERTS */
.alert {
    display: flex; align-items: center; gap: 10px;
    padding: 14px 18px; margin-bottom: 20px; border-radius: 14px;
    border: 1px solid; font-size: .9rem; font-weight: 600;
}
.alert-success { background: #EAFBF1; border-color: #BBF0CF; color: #15803D; }
.alert-danger  { background: #FEECEF; border-color: #FBD0D8; color: #E11D48; }
.alert-info    { background: #EAF1FE; border-color: #C4D7FC; color: #1D4ED8; }

/* PAGE HEAD */
.page-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; flex-wrap: wrap; gap: 14px; }
.page-head h2 { font-family: var(--font-h); font-size: 1.9rem; letter-spacing: -.5px; }
.page-head .sub { font-size: .88rem; color: var(--muted); margin-top: 4px; font-weight: 500; }

/* BUTTONS */
.btn {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 10px 22px; font-family: var(--font-b); font-size: .82rem;
    font-weight: 700; cursor: pointer; border: 1.5px solid; border-radius: 50px;
    transition: var(--tr);
    background: transparent;
}
.btn-sm { padding: 8px 16px; font-size: .78rem; }
.btn-gold { color: #fff; border-color: var(--gold); background: linear-gradient(135deg, var(--gold), var(--gold-hover)); box-shadow: var(--glow); }
.btn-gold:hover { transform: translateY(-1px); box-shadow: 0 10px 24px rgba(255,59,31,.36); }
.btn-muted { color: var(--muted); border-color: var(--border); }
.btn-muted:hover { color: var(--text); border-color: var(--text); }
.btn-default { color: var(--text); border-color: var(--border); }
.btn-default:hover { color: var(--gold); border-color: var(--gold); }

/* FORM */
.form-group { margin-bottom: 16px; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.form-label {
    display: block; font-size: .78rem; font-weight: 700;
    text-transform: uppercase; letter-spacing: .06em; color: var(--muted); margin-bottom: 8px;
}
.required { color: var(--danger); }
.form-control, .form-select, .form-textarea {
    width: 100%; padding: 11px 14px;
    background: var(--surface); border: 1.5px solid var(--border); border-radius: 12px;
    color: var(--text); font-family: var(--font-b); font-size: .9rem;
    transition: var(--tr); outline: none;
}
.form-control:focus, .form-select:focus, .form-textarea:focus {
    border-color: var(--gold); box-shadow: 0 0 0 4px var(--primary-light, #FFF2F0);
}
.form-control::placeholder { color: var(--muted); }
.form-control[readonly] { background: var(--surface-lt); color: var(--muted); cursor: not-allowed; }

/* PROFILE CARD */
.profile-card {
    background: var(--surface); border: 1.5px solid var(--border); border-radius: 22px;
    padding: 30px; box-shadow: 0 2px 12px rgba(99,44,20,.05);
}
.profile-avatar-block { display: flex; align-items: center; gap: 22px; margin-bottom: 28px; padding-bottom: 26px; border-bottom: 1px solid var(--border); flex-wrap: wrap; }
.profile-avatar {
    width: 92px; height: 92px; border-radius: 50%; overflow: hidden;
    background: linear-gradient(135deg, var(--gold), var(--gold-hover));
    color: #fff; font-size: 30px; font-weight: 800;
    display: flex; align-items: center; justify-content: center;
    box-shadow: var(--glow); flex-shrink: 0;
}
.profile-avatar img { width: 100%; height: 100%; object-fit: cover; }
.profile-avatar-actions { flex: 1; min-width: 200px; }
.profile-avatar-actions p.hint { font-size: .78rem; color: var(--muted); margin-top: 8px; }
.btn-change-avatar {
    display: inline-flex; align-items: center; gap: 7px;
    padding: 9px 18px; border: 1.5px dashed var(--border); border-radius: 50px;
    color: var(--gold); font-size: .82rem; font-weight: 700; cursor: pointer; transition: var(--tr);
}
.btn-change-avatar:hover { border-color: var(--gold); background: var(--surface-lt); }
.upload-progress-bar { display: none; height: 6px; border-radius: 4px; background: var(--surface-lt); margin-top: 12px; overflow: hidden; max-width: 260px; }
.upload-progress-bar .bar { height: 100%; width: 0; background: linear-gradient(135deg, var(--gold), var(--gold-hover)); transition: width .25s ease; }
.upload-msg { font-size: .78rem; margin-top: 6px; font-weight: 600; }
</style>
</head>
<body>

<header class="navbar">
    <div class="nav-content">
        <a class="logo" href="${pageContext.request.contextPath}/user/home" style="text-decoration:none;color:inherit;">
            <img class="logo-emoji" src="https://cdn.jsdelivr.net/gh/microsoft/fluentui-emoji@main/assets/Steaming%20bowl/3D/steaming_bowl_3d.png" alt="">
            <h1>FOOD MANAGE<span>.</span></h1>
        </a>

        <nav class="nav-links">
            <a href="${pageContext.request.contextPath}/user/home">Trang chủ</a>
            <a href="${pageContext.request.contextPath}/user/home#restaurants">Nhà hàng</a>
            <a href="${pageContext.request.contextPath}/user/donhang">Đơn hàng</a>
            <a href="${pageContext.request.contextPath}/user/dia-chi">Địa chỉ</a>
            <a href="${pageContext.request.contextPath}/user/diem-thuong">Điểm thưởng</a>
        </nav>

        <div class="nav-actions">
            <div class="nav-search">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input id="navSearch" type="text" placeholder="Tìm quán, món ăn..."
                       onkeydown="if(event.key==='Enter'){event.preventDefault();window.location.href='${pageContext.request.contextPath}/user/home#restaurants';}">
            </div>

            <div class="avatar-wrap" id="avatarWrap">
                <button class="avatar-btn" id="avatarBtn" onclick="toggleDropdown()" aria-label="Tài khoản">
                    <c:choose>
                        <c:when test="${not empty profile.avatarUrl}">
                            <img src="${profile.avatarUrl}" alt="Avatar">
                        </c:when>
                        <c:otherwise>${fn:substring(not empty profile.fullName ? profile.fullName : profile.userName, 0, 1)}</c:otherwise>
                    </c:choose>
                </button>
                <div class="avatar-dropdown" id="accountDropdown">
                    <div class="dd-head">
                        <div class="dd-name">${not empty profile.fullName ? profile.fullName : profile.userName}</div>
                        <c:if test="${not empty profile.email}"><div class="dd-email">${profile.email}</div></c:if>
                    </div>
                    <a href="${pageContext.request.contextPath}/user/thong-tin-ca-nhan" class="dd-link active">
                        <i class="fa-solid fa-user"></i> Thông tin cá nhân
                    </a>
                    <a href="${pageContext.request.contextPath}/user/donhang" class="dd-link">
                        <i class="fa-solid fa-box"></i> Đơn hàng của tôi
                    </a>
                    <a href="${pageContext.request.contextPath}/user/dia-chi" class="dd-link">
                        <i class="fa-solid fa-location-dot"></i> Địa chỉ giao hàng
                    </a>
                    <a href="${pageContext.request.contextPath}/user/diem-thuong" class="dd-link">
                        <i class="fa-solid fa-star"></i> Điểm thưởng & Voucher
                    </a>
                    <a href="${pageContext.request.contextPath}/user/thong-bao" class="dd-link">
                        <i class="fa-solid fa-bell"></i> Thông báo
                    </a>
                    <a href="${pageContext.request.contextPath}/user/cart" class="dd-link">
                        <i class="fa-solid fa-cart-shopping"></i> Giỏ hàng
                    </a>
                    <a href="${pageContext.request.contextPath}/user/doi-mat-khau" class="dd-link">
                        <i class="fa-solid fa-lock"></i> Đổi mật khẩu
                    </a>
                    <div class="dd-divider"></div>
                    <form action="${pageContext.request.contextPath}/logout" method="post">
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <button type="submit" class="dd-btn">
                            <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                        </button>
                    </form>
                </div>
            </div>

            <a href="${pageContext.request.contextPath}/user/thong-bao" class="cart-btn" aria-label="Thông báo" style="position:relative;">
                <i class="fa-solid fa-bell"></i>
                <span data-notif-badge style="display:${unreadNotifCount > 0 ? 'inline-block' : 'none'};position:absolute;top:2px;right:2px;background:#ef4444;color:#fff;border-radius:999px;font-size:10px;min-width:16px;height:16px;line-height:16px;text-align:center;padding:0 3px;font-weight:700;">${unreadNotifCount}</span>
            </a>

            <a href="${pageContext.request.contextPath}/user/cart" class="cart-btn" aria-label="Giỏ hàng">
                <i class="fa-solid fa-bag-shopping"></i>
            </a>
        </div>
    </div>
</header>

<div class="container">

    <c:if test="${param.success eq '1'}">
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Đã cập nhật thông tin cá nhân thành công!</div>
    </c:if>
    <c:if test="${param.error eq '1'}">
        <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation"></i> Cập nhật thất bại, vui lòng thử lại.</div>
    </c:if>
    <c:if test="${param.error eq 'email_exists'}">
        <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation"></i> Email này đã được sử dụng bởi tài khoản khác.</div>
    </c:if>
    <c:if test="${param.error eq 'otp_send_failed'}">
        <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation"></i> Gửi mã OTP thất bại, vui lòng thử lại.</div>
    </c:if>

    <div class="page-head">
        <div>
            <h2>Thông Tin Cá Nhân</h2>
            <p class="sub">Cập nhật họ tên, số điện thoại, email và ảnh đại diện</p>
        </div>
    </div>

    <div class="profile-card">
        <div class="profile-avatar-block">
            <div class="profile-avatar">
                <c:choose>
                    <c:when test="${not empty profile.avatarUrl}">
                        <img src="${profile.avatarUrl}" alt="Avatar">
                    </c:when>
                    <c:otherwise>${fn:substring(not empty profile.fullName ? profile.fullName : profile.userName, 0, 1)}</c:otherwise>
                </c:choose>
            </div>
            <div class="profile-avatar-actions">
                <input type="file" id="avatarFileInput" accept="image/jpeg,image/png,image/webp" style="display:none;">
                <label for="avatarFileInput" class="btn-change-avatar"><i class="fa-solid fa-camera"></i> Đổi ảnh đại diện</label>
                <p class="hint">Ảnh JPG, PNG hoặc WEBP.</p>
                <div class="upload-progress-bar" id="uploadProgressBar"><div class="bar" id="uploadBar"></div></div>
                <div class="upload-msg" id="uploadMsg"></div>
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/user/thong-tin-ca-nhan" method="post">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="avatarUrl" id="avatarUrlInput" value="${profile.avatarUrl}">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Họ và tên</label>
                    <input type="text" class="form-control" name="fullName" value="${profile.fullName}" placeholder="Họ và tên">
                </div>
                <div class="form-group">
                    <label class="form-label">Số điện thoại</label>
                    <input type="tel" class="form-control" name="phone" value="${profile.phone}" placeholder="0xxxxxxxxx">
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Tên đăng nhập</label>
                <input type="text" class="form-control" value="${profile.userName}" readonly>
            </div>
            <div class="form-group">
                <label class="form-label">Email</label>
                <input type="email" class="form-control" name="email" value="${profile.email}" placeholder="email@example.com">
                <p class="hint" style="font-size:.78rem;color:var(--muted);margin-top:8px;">Nếu đổi email, hệ thống sẽ gửi mã OTP xác thực đến email mới trước khi lưu.</p>
            </div>
            <div class="modal-actions" style="display:flex;gap:12px;margin-top:8px;">
                <button type="submit" class="btn btn-gold">Lưu thay đổi</button>
            </div>
        </form>
    </div>

</div>

<script>
var CLOUD_NAME = 'jcnsb47f';
var UPLOAD_PRESET = 'avatar_preset';

document.getElementById('avatarFileInput').addEventListener('change', function(e) {
    var file = e.target.files[0];
    if (!file) return;
    var progressBar = document.getElementById('uploadProgressBar');
    var bar = document.getElementById('uploadBar');
    var msg = document.getElementById('uploadMsg');
    progressBar.style.display = 'block';
    bar.style.width = '10%';
    msg.style.color = 'var(--muted)';
    msg.textContent = 'Đang tải ảnh lên...';
    var formData = new FormData();
    formData.append('file', file);
    formData.append('upload_preset', UPLOAD_PRESET);
    formData.append('folder', 'avatars');
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'https://api.cloudinary.com/v1_1/' + CLOUD_NAME + '/image/upload', true);
    xhr.upload.onprogress = function(ev) {
        if (ev.lengthComputable) {
            var pct = Math.round((ev.loaded / ev.total) * 70);
            bar.style.width = (10 + pct) + '%';
        }
    };
    xhr.onload = function() {
        if (xhr.status === 200) {
            var result = JSON.parse(xhr.responseText);
            var rawUrl = result.secure_url;
            var avatarUrl = rawUrl.replace('/upload/', '/upload/w_150,h_150,c_fill,g_face/');
            bar.style.width = '90%';
            msg.textContent = 'Đang lưu...';
            var saveXhr = new XMLHttpRequest();
            saveXhr.open('POST', '${pageContext.request.contextPath}/user/update-avatar', true);
            saveXhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            saveXhr.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name="_csrf"]').content);
            saveXhr.onload = function() {
                bar.style.width = '100%';
                if (saveXhr.status === 200) {
                    msg.style.color = 'var(--success)';
                    msg.textContent = 'Cập nhật ảnh đại diện thành công!';
                    document.getElementById('avatarUrlInput').value = avatarUrl;
                    document.querySelector('.profile-avatar').innerHTML =
                        '<img src="' + avatarUrl + '" alt="Avatar">';
                    document.getElementById('avatarBtn').innerHTML =
                        '<img src="' + avatarUrl + '" alt="Avatar">';
                    setTimeout(function() {
                        progressBar.style.display = 'none';
                        bar.style.width = '0%';
                        msg.textContent = '';
                    }, 2500);
                } else {
                    msg.style.color = 'var(--danger)';
                    msg.textContent = 'Lưu ảnh thất bại, thử lại.';
                }
            };
            saveXhr.send('avatarUrl=' + encodeURIComponent(avatarUrl));
        } else {
            msg.style.color = 'var(--danger)';
            msg.textContent = 'Tải ảnh lên thất bại.';
            bar.style.width = '0%';
        }
    };
    xhr.onerror = function() {
        msg.style.color = 'var(--danger)';
        msg.textContent = 'Lỗi kết nối Cloudinary.';
    };
    xhr.send(formData);
});
</script>
<script>
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
