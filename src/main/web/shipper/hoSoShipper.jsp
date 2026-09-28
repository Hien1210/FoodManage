<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="_csrf" content="${sessionScope.csrfToken}">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Hồ sơ cá nhân - Shipper</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
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

        /* Profile grid (giống pattern admin/hoSoAdmin.jsp) */
        .profile-grid { display: grid; grid-template-columns: 280px 1fr; gap: 24px; max-width: 960px; }
        @media (max-width: 700px) { .profile-grid { grid-template-columns: 1fr; } }
        .avatar-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 22px; }
        .profile-avatar { width: 100px; height: 100px; border-radius: 50%; margin: 0 auto 16px; background: linear-gradient(135deg, var(--warning), var(--primary)); display: flex; align-items: center; justify-content: center; font-size: 36px; font-weight: 800; color: #fff; box-shadow: 0 8px 24px rgba(255,87,34,.30); overflow: hidden; }
        .profile-avatar img { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }
        .profile-username { font-size: 20px; font-weight: 700; color: var(--text-main); margin-top: 10px; }
        .profile-role-badge { background: var(--primary-light); color: var(--primary); border: 1px solid var(--primary); font-size: 11px; font-weight: 700; padding: 4px 12px; border-radius: 20px; display: inline-block; margin-top: 6px; }

        .form-card { background: var(--bg-card); border: 1px solid var(--border-color); border-radius: 14px; padding: 28px; animation: fadeUp .35s ease .1s both; }
        .form-card-title { font-size: 15px; font-weight: 700; color: var(--text-main); border-left: 4px solid var(--primary); padding-left: 12px; margin-bottom: 24px; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; color: var(--text-muted); margin-bottom: 8px; }
        .form-group input { width: 100%; padding: 11px 14px; background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 8px; font-size: 14px; color: var(--text-main); outline: none; transition: border-color .2s; }
        .form-group input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-light); }
        .form-group input:disabled { opacity: .5; cursor: not-allowed; }
        .form-hint { font-size: 11px; color: var(--text-dim); margin-top: 5px; }
        .form-actions { display: flex; gap: 12px; margin-top: 24px; }
        .btn-save { padding: 11px 24px; background: var(--primary); color: #fff; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: all .2s; }
        .btn-save:hover { background: var(--primary-hover); transform: translateY(-1px); }
        .btn-cancel { padding: 11px 20px; background: var(--bg-input); color: var(--text-muted); border: 1px solid var(--border-color); border-radius: 8px; font-size: 14px; cursor: pointer; }
        .btn-cancel:hover { background: var(--border-color); color: var(--text-main); }

        .alert { padding: 13px 16px; border-radius: 8px; font-size: 13px; font-weight: 600; margin-bottom: 20px; display: flex; align-items: center; gap: 8px; }
        .alert-success { background: var(--primary-light); color: var(--primary); border: 1px solid var(--primary); }
        .alert-error { background: rgba(239,68,68,.1); color: var(--danger); border: 1px solid var(--danger); }

        .btn-change-avatar { display: block; width: fit-content; margin: 10px auto 0; padding: 8px 18px; background: var(--primary-light); color: var(--primary); border: 1px solid var(--primary); border-radius: 8px; font-size: 12px; font-weight: 700; cursor: pointer; transition: all .2s; }
        .btn-change-avatar:hover { background: var(--primary); color: #fff; }
        #uploadProgressBar { display: none; width: 100%; height: 4px; background: var(--border-color); border-radius: 2px; overflow: hidden; margin-top: 8px; }
        #uploadProgressBar .bar { height: 100%; width: 0%; background: var(--primary); transition: width .3s; }
        .form-control:disabled { opacity: .6; cursor: not-allowed; }
    </style>
</head>
<body class="dash-body">

<div class="sidebar-backdrop" id="sidebarBackdrop"></div>
<aside class="sidebar" id="sidebar">
    <div class="sidebar-brand">
        <div class="logo-mark-dash">🛵</div>
        <div class="brand-text">
            <span class="brand-title">POB SHIPPER</span>
            <span class="brand-subtitle">👋 ${fn:escapeXml(sessionScope.account.userName)}</span>
        </div>
        <button type="button" class="sidebar-toggle-btn" id="sidebarToggleBtn" onclick="pobToggleSidebar()" title="Thu gọn / mở rộng menu">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
        </button>
    </div>
    <div class="menu">
        <div class="menu-title">Công việc</div>
        <a href="${pageContext.request.contextPath}/shipper/donhang" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📋</span><span class="mi-label"> Đơn hàng nhận</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/nhan-don" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📥</span><span class="mi-label"> Nhận đơn mới</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/dashboard" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📊</span><span class="mi-label"> Dashboard</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/thongbao" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🔔</span><span class="mi-label"> Thông báo</span></span>
        </a>

        <div class="menu-title">Tài khoản</div>
        <a href="${pageContext.request.contextPath}/shipper/profile" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🚙</span><span class="mi-label"> Hồ sơ tài xế</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/danh-gia" class="menu-item">
            <span class="mi-left"><span class="mi-icon">⭐</span><span class="mi-label"> Đánh giá &amp; Báo cáo</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/vi-tien" class="menu-item">
            <span class="mi-left"><span class="mi-icon">💰</span><span class="mi-label"> Ví tiền</span></span>
        </a>
    </div>
</aside>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1>👤 Hồ sơ cá nhân</h1>
        </div>
        <div class="topbar-right">
            <button type="button" class="theme-toggle" id="themeToggleBtn" onclick="pobToggleTheme()" title="Chuyển đổi giao diện"><span data-theme-icon>🌙</span></button>
            <div class="avatar-wrapper" id="avatarWrapper">
                <div class="avatar-circle" id="avatarBtn">
                    <c:choose>
                        <c:when test="${not empty sessionScope.account.avatarUrl}">
                            <img src="${fn:escapeXml(sessionScope.account.avatarUrl)}" alt="avatar"/>
                        </c:when>
                        <c:otherwise>${fn:escapeXml(fn:toUpperCase(fn:substring(sessionScope.account.userName, 0, 2)))}</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </header>

    <div class="content">
        <c:if test="${param.success == '1'}">
            <div class="alert alert-success">✅ Cập nhật hồ sơ thành công!</div>
        </c:if>
        <c:if test="${param.error == '1'}">
            <div class="alert alert-danger">❌ Có lỗi xảy ra, vui lòng thử lại.</div>
        </c:if>

        <div class="profile-grid">
            <div class="avatar-card">
                <div style="text-align:center;">
                    <div class="profile-avatar">
                        <c:choose>
                            <c:when test="${not empty profile.avatarUrl}">
                                <img src="${fn:escapeXml(profile.avatarUrl)}" alt="Avatar"/>
                            </c:when>
                            <c:otherwise>${fn:escapeXml(fn:toUpperCase(fn:substring(profile.userName,0,2)))}</c:otherwise>
                        </c:choose>
                    </div>
                    <input type="file" id="avatarFileInput" accept="image/jpeg,image/png,image/webp" style="display:none;"/>
                    <label for="avatarFileInput" class="btn-change-avatar">📷 Đổi ảnh đại diện</label>
                    <div id="uploadProgressBar"><div class="bar" id="uploadBar"></div></div>
                    <div id="uploadMsg" style="font-size:12px;color:var(--text-muted);"></div>
                    <div class="profile-username">${fn:escapeXml(profile.userName)}</div>
                    <span class="profile-role-badge">🛵 Shipper</span>
                </div>
                <div style="margin-top:18px;">
                    <div class="info-row"><div class="info-label">📧 Email</div><div class="info-value">${fn:escapeXml(not empty profile.email ? profile.email : 'Chưa cập nhật')}</div></div>
                    <div class="info-row"><div class="info-label">📱 SĐT</div><div class="info-value">${fn:escapeXml(not empty profile.phone ? profile.phone : 'Chưa cập nhật')}</div></div>
                    <div class="info-row"><div class="info-label">🪪 Họ tên</div><div class="info-value">${not empty profile.fullName ? fn:escapeXml(profile.fullName) : 'Chưa cập nhật'}</div></div>
                </div>
            </div>

            <div class="panel">
                <div class="panel-header"><div class="panel-title">📝 Chỉnh sửa thông tin</div></div>
                <div class="panel-body">
                    <form action="${pageContext.request.contextPath}/shipper/ho-so" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <div class="form-group">
                            <label class="form-label">Tên đăng nhập</label>
                            <input type="text" class="form-control" value="${fn:escapeXml(profile.userName)}" disabled/>
                            <div class="form-hint">Tên đăng nhập không thể thay đổi.</div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Họ và tên</label>
                            <input type="text" class="form-control" name="fullName" value="${fn:escapeXml(profile.fullName)}" placeholder="Nhập họ và tên..."/>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Email</label>
                            <input type="email" class="form-control" name="email" value="${fn:escapeXml(profile.email)}" placeholder="Nhập email..."/>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Số điện thoại</label>
                            <input type="tel" class="form-control" name="phone" value="${fn:escapeXml(profile.phone)}" placeholder="Nhập số điện thoại..."/>
                        </div>
                        <div class="form-actions" style="display:flex;gap:12px;margin-top:8px;">
                            <button type="submit" class="btn btn-primary">💾 Lưu thay đổi</button>
                            <button type="button" class="btn btn-ghost" onclick="history.back()">Huỷ</button>
                        </div>
                    </form>
                </div>
            </div>

        </div>
    </div>
</main>

<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${fn:escapeXml(sessionScope.account.userName)}</div>
        <div class="d-email">${fn:escapeXml(sessionScope.account.email)}</div>
        <span class="d-role">🛵 Shipper</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/shipper/ho-so" class="dropdown-link active">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/shipper/doi-mat-khau" class="dropdown-link">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script>
    // Cloudinary avatar upload
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
                    saveXhr.open('POST', '${pageContext.request.contextPath}/shipper/update-avatar', true);
                    saveXhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                    saveXhr.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name="_csrf"]').content);
                    saveXhr.onload = function() {
                        bar.style.width = '100%';
                        if (saveXhr.status === 200) {
                            msg.style.color = 'var(--primary)';
                            msg.textContent = '✅ Cập nhật ảnh đại diện thành công!';

                            document.querySelector('.profile-avatar').innerHTML =
                                '<img src="' + avatarUrl + '" alt="Avatar" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"/>';
                            document.getElementById('avatarBtn').innerHTML =
                                '<img src="' + avatarUrl + '" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"/>';

                            setTimeout(function() {
                                progressBar.style.display = 'none';
                                bar.style.width = '0%';
                                msg.textContent = '';
                            }, 2500);
                        } else {
                            msg.style.color = 'var(--danger)';
                            msg.textContent = '❌ Lưu ảnh thất bại, thử lại.';
                        }
                    };
                    saveXhr.send('avatarUrl=' + encodeURIComponent(avatarUrl));
                } else {
                    msg.style.color = 'var(--danger)';
                    msg.textContent = '❌ Tải ảnh lên thất bại.';
                    bar.style.width = '0%';
                }
            };

            xhr.onerror = function() {
                msg.style.color = 'var(--danger)';
                msg.textContent = '❌ Lỗi kết nối Cloudinary.';
            };

        xhr.onerror = function() {
            msg.style.color = 'var(--danger)';
            msg.textContent = '❌ Lỗi kết nối Cloudinary.';
        };

        xhr.send(formData);
    });

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
