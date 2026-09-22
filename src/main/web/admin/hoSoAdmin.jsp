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
    <meta name="_csrf" content="${sessionScope.csrfToken}">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Hồ sơ cá nhân - Super Admin</title>
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

        /* Đặc thù trang hồ sơ: layout 2 cột (avatar + info-card / form) */
        .profile-grid { display: grid; grid-template-columns: 280px 1fr; gap: 24px; max-width: 960px; }
        @media (max-width: 700px) { .profile-grid { grid-template-columns: 1fr; } }
        .profile-avatar { width: 100px; height: 100px; border-radius: 50%; margin: 0 auto 16px; background: linear-gradient(135deg, var(--warning), #f97316); display: flex; align-items: center; justify-content: center; font-size: 36px; font-weight: 800; color: #fff; box-shadow: 0 8px 24px rgba(245,158,11,0.35); overflow: hidden; }
        .profile-avatar img { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }
        #avatarFileInput { display: none; }
        #logoFileInput { display: none; }
        .upload-status { font-size: 12px; color: var(--text-muted); min-height: 18px; margin-top: 8px; }
        .profile-username { font-size: 18px; font-weight: 700; color: var(--text-main); margin-top: 8px; }
        .profile-joined { font-size: 12px; color: var(--text-dim); margin-top: 6px; }
        .form-control:disabled { opacity: 0.6; cursor: not-allowed; }

        .form-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 22px; }
        .form-card-title { font-size: 15px; font-weight: 700; color: var(--text-main); border-left: 4px solid var(--primary); padding-left: 12px; margin-bottom: 20px; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; color: var(--text-muted); margin-bottom: 8px; }
        .form-group input { width: 100%; padding: 11px 14px; background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 8px; font-size: 14px; color: var(--text-main); outline: none; transition: border-color .2s; }
        .form-group input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px var(--primary-light); }
        .form-group input:disabled { opacity: .5; cursor: not-allowed; }
        .form-hint { font-size: 11.5px; color: var(--text-dim); margin-top: 6px; }
        .form-actions { display: flex; gap: 12px; margin-top: 24px; }
        .btn-save { padding: 11px 24px; background: var(--primary); color: #fff; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: all .2s; }
        .btn-save:hover { background: var(--primary-dark); transform: translateY(-1px); }
        .btn-cancel { padding: 11px 20px; background: var(--bg-input); color: var(--text-muted); border: 1px solid var(--border-color); border-radius: 8px; font-size: 14px; cursor: pointer; transition: all .2s; }
        .btn-cancel:hover { background: var(--border-color); color: var(--text-main); }
    </style>
</head>
<body class="dash-body admin-theme">

<c:set var="adminActive" value="" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">person</span> Hồ sơ cá nhân</h1>
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
        <c:if test="${param.success == '1'}">
            <div class="alert alert-success">✅ Cập nhật hồ sơ thành công!</div>
        </c:if>
        <c:if test="${param.error == '1'}">
            <div class="alert alert-danger">❌ Có lỗi xảy ra, vui lòng thử lại.</div>
        </c:if>

        <div class="profile-grid">

            <!-- CỘT TRÁI: Avatar + thông tin tóm tắt -->
            <div class="info-card">
                <div style="text-align:center;">
                    <div class="profile-avatar" id="profileAvatarCircle">
                        <c:choose>
                            <c:when test="${not empty profile.avatarUrl}">
                                <img src="${profile.avatarUrl}" alt="Avatar" id="avatarPreviewImg"/>
                            </c:when>
                            <c:otherwise>
                                <span id="avatarInitials">${fn:toUpperCase(fn:substring(profile.userName, 0, 2))}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <input type="file" id="avatarFileInput" accept="image/jpeg,image/png,image/webp"/>
                    <label for="avatarFileInput" class="btn btn-outline btn-sm">📷 Đổi ảnh đại diện</label>
                    <div class="upload-status" id="uploadStatus"></div>
                    <div class="profile-username">${fn:escapeXml(profile.userName)}</div>
                    <span class="badge badge-primary">⚡ Super Admin</span>
                    <c:if test="${not empty profile.createdAt}">
                        <div class="profile-joined">Tham gia: ${profile.createdAt.hour}:<c:set var="m" value="${profile.createdAt.minute}"/><c:if test="${m < 10}">0</c:if>${m}
                            &nbsp;${profile.createdAt.dayOfMonth}/${profile.createdAt.monthValue}/${profile.createdAt.year}</div>
                    </c:if>
                </div>
                <div style="margin-top:18px;">
                    <div class="info-row"><div class="info-label">📧 Email</div><div class="info-value">${not empty profile.email ? profile.email : 'Chưa cập nhật'}</div></div>
                    <div class="info-row"><div class="info-label">📱 SĐT</div><div class="info-value">${not empty profile.phone ? profile.phone : 'Chưa cập nhật'}</div></div>
                    <div class="info-row"><div class="info-label">🪪 Họ tên</div><div class="info-value">${not empty profile.fullName ? fn:escapeXml(profile.fullName) : 'Chưa cập nhật'}</div></div>
                </div>

                <div style="margin-top:22px; padding-top:18px; border-top:1px solid var(--border-color); text-align:center;">
                    <div style="font-size:12px; font-weight:700; color:var(--text-muted); text-transform:uppercase; letter-spacing:.5px; margin-bottom:10px;">🖼️ Logo tài khoản (hiện ở Sidebar)</div>
                    <div class="profile-avatar" id="profileLogoCircle" style="width:64px; height:64px; margin:0 auto 10px; border-radius:14px;">
                        <c:choose>
                            <c:when test="${not empty profile.logoUrl}">
                                <img src="${profile.logoUrl}" alt="Logo" id="logoPreviewImg" style="width:100%;height:100%;object-fit:cover;border-radius:inherit;"/>
                            </c:when>
                            <c:otherwise>
                                <span id="logoPlaceholder" style="font-size:22px;font-weight:800;">S</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <input type="file" id="logoFileInput" accept="image/jpeg,image/png,image/webp"/>
                    <label for="logoFileInput" class="btn btn-outline btn-sm">🖼️ Đổi logo</label>
                    <div class="upload-status" id="logoUploadStatus"></div>
                </div>
            </div>

            <!-- CỘT PHẢI: Form chỉnh sửa -->
            <div class="panel">
                <div class="panel-header">
                    <div class="panel-title">📝 Chỉnh sửa thông tin</div>
                </div>
                <div class="panel-body">
                    <form action="${pageContext.request.contextPath}/admin/profile" method="post">
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
                            <input type="email" class="form-control" name="email" value="${profile.email}" placeholder="Nhập email..."/>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Số điện thoại</label>
                            <input type="tel" class="form-control" name="phone" value="${profile.phone}" placeholder="Nhập số điện thoại..."/>
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

<!-- Avatar Dropdown (ngoài topbar để tránh backdrop-filter stacking context) -->
<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${fn:escapeXml(sessionScope.account.userName)}</div>
        <div class="d-email">${sessionScope.account.email}</div>
        <span class="d-role">Super Admin</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/admin/profile" class="dropdown-link active">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/admin/change-password" class="dropdown-link">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pixel-cat.js"></script>
<script>
    // Cloudinary unsigned upload
    var CLOUD_NAME = 'jcnsb47f';
    var UPLOAD_PRESET = 'avatar_preset';

    document.getElementById('avatarFileInput').addEventListener('change', function(e) {
        var file = e.target.files[0];
        if (!file) return;
        if (file.size > 2 * 1024 * 1024) {
            document.getElementById('uploadStatus').textContent = '❌ Ảnh tối đa 2MB.';
            return;
        }
        var status = document.getElementById('uploadStatus');
        status.textContent = '⏳ Đang tải lên...';

        var formData = new FormData();
        formData.append('file', file);
        formData.append('upload_preset', UPLOAD_PRESET);
        formData.append('folder', 'avatars');

        fetch('https://api.cloudinary.com/v1_1/' + CLOUD_NAME + '/image/upload', {
            method: 'POST',
            body: formData
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data.secure_url) { status.textContent = '❌ Upload thất bại.'; return; }
            // Chèn transformation vào URL để resize về 150x150
            var url = data.secure_url.replace('/upload/', '/upload/w_150,h_150,c_fill,g_face/');

            // Preview ngay
            var circle = document.getElementById('profileAvatarCircle');
            var initials = document.getElementById('avatarInitials');
            var previewImg = document.getElementById('avatarPreviewImg');
            if (!previewImg) {
                previewImg = document.createElement('img');
                previewImg.id = 'avatarPreviewImg';
                previewImg.style.cssText = 'width:100%;height:100%;object-fit:cover;border-radius:50%;';
                if (initials) initials.style.display = 'none';
                circle.appendChild(previewImg);
            }
            previewImg.src = url;

            // Cập nhật avatar trên topbar
            var avatarTopbar = document.getElementById('avatarBtn');
            if (avatarTopbar) {
                avatarTopbar.innerHTML = '<img src="' + url + '" style="width:100%;height:100%;object-fit:cover;border-radius:50%;" />';
            }

            // Gửi URL lên server
            return fetch('${pageContext.request.contextPath}/admin/update-avatar', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-CSRF-Token': document.querySelector('meta[name="_csrf"]').content
                },
                body: 'avatarUrl=' + encodeURIComponent(url)
            })
                .then(function(r2) {
                    if (r2.ok) { status.textContent = '✅ Cập nhật ảnh đại diện thành công!'; }
                    else { status.textContent = '❌ Lưu thất bại, thử lại.'; }
                });
        })
        .catch(function() { document.getElementById('uploadStatus').textContent = '❌ Lỗi kết nối.'; });
    });

    // Upload Logo tài khoản (tách biệt hoàn toàn với avatar cá nhân ở trên)
    document.getElementById('logoFileInput').addEventListener('change', function(e) {
        var file = e.target.files[0];
        if (!file) return;
        if (file.size > 2 * 1024 * 1024) {
            document.getElementById('logoUploadStatus').textContent = '❌ Ảnh tối đa 2MB.';
            return;
        }
        var status = document.getElementById('logoUploadStatus');
        status.textContent = '⏳ Đang tải lên...';

        var formData = new FormData();
        formData.append('file', file);
        formData.append('upload_preset', UPLOAD_PRESET);
        formData.append('folder', 'logos');

        fetch('https://api.cloudinary.com/v1_1/' + CLOUD_NAME + '/image/upload', {
            method: 'POST',
            body: formData
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data.secure_url) { status.textContent = '❌ Upload thất bại.'; return; }
            var url = data.secure_url.replace('/upload/', '/upload/w_150,h_150,c_fill/');

            // Preview ngay trong trang hồ sơ
            var circle = document.getElementById('profileLogoCircle');
            var placeholder = document.getElementById('logoPlaceholder');
            var previewImg = document.getElementById('logoPreviewImg');
            if (!previewImg) {
                previewImg = document.createElement('img');
                previewImg.id = 'logoPreviewImg';
                previewImg.style.cssText = 'width:100%;height:100%;object-fit:cover;border-radius:inherit;';
                if (placeholder) placeholder.style.display = 'none';
                circle.appendChild(previewImg);
            }
            previewImg.src = url;

            // Cập nhật logo trên sidebar ngay lập tức
            var logoSidebar = document.querySelector('.logo-mark-dash');
            if (logoSidebar) {
                logoSidebar.innerHTML = '<img src="' + url + '" alt="logo" class="logo-mark-img"/>';
            }

            // Gửi URL lên server
            return fetch('${pageContext.request.contextPath}/admin/update-logo', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-CSRF-Token': document.querySelector('meta[name="_csrf"]').content
                },
                body: 'logoUrl=' + encodeURIComponent(url)
            })
                .then(function(r2) {
                    if (r2.ok) { status.textContent = '✅ Cập nhật logo thành công!'; }
                    else { status.textContent = '❌ Lưu thất bại, thử lại.'; }
                });
        })
        .catch(function() { document.getElementById('logoUploadStatus').textContent = '❌ Lỗi kết nối.'; });
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
            avatarDropdown.addEventListener('click', function(e) {
                e.stopPropagation();
            });
            document.addEventListener('click', function() {
                avatarDropdown.classList.remove('open');
            });
        }
    });
</script>
</body>
</html>
