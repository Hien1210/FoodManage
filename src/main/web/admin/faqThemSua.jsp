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
    <title><c:out value="${empty faq ? 'Thêm FAQ' : 'Sửa FAQ'}"/> - Super Admin</title>
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
        .avatar-dropdown.open { display: block; }
        .dropdown-header { padding: 14px 16px; border-bottom: 1px solid var(--border-color); }
        .dropdown-header .d-name { font-size: 14px; font-weight: 700; color: var(--text-main); }
        .dropdown-header .d-email { font-size: 12px; color: var(--text-muted); margin-top: 2px; }
        .dropdown-body { padding: 6px 0 8px; }
        .dropdown-link { display: flex; align-items: center; gap: 10px; padding: 10px 16px; font-size: 13px; color: var(--text-muted); cursor: pointer; }
        .dropdown-link:hover { background: var(--bg-input); color: var(--text-main); }
        .dropdown-divider { height: 1px; background: var(--border-color); margin: 4px 0; }
        .dropdown-link.danger { color: var(--danger); }

        .panel { padding: 22px; margin-bottom: 20px; }
        .form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 18px 24px; }
        .form-field label { display: block; font-size: 12.5px; font-weight: 700; color: var(--text-muted); margin-bottom: 8px; }
        .form-field input[type="number"] {
            width: 100%; padding: 10px 14px; border-radius: 8px; border: 1px solid var(--border-color);
            background: var(--bg-input); color: var(--text-main); font-size: 14px; font-weight: 600; font-family: inherit;
        }
        .form-field input[type="number"]:focus { outline: none; border-color: var(--primary); }
        .form-field input[type="text"],
        .form-field textarea {
            width: 100%; padding: 10px 14px; border-radius: 8px; border: 1px solid var(--border-color);
            background: var(--bg-input); color: var(--text-main); font-size: 14px; font-family: inherit;
        }
        .form-field input[type="text"]:focus,
        .form-field textarea:focus { outline: none; border-color: var(--primary); }
        .form-field textarea { resize: vertical; }
        .form-full { grid-column: 1 / -1; }
        .save-bar { display: flex; justify-content: flex-end; gap: 10px; margin-top: 4px; }
    </style>
</head>
<body class="dash-body admin-theme">
<c:set var="adminActive" value="/admin/faq" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">${empty faq ? 'add_circle' : 'edit'}</span> <c:out value="${empty faq ? 'Thêm FAQ mới' : 'Sửa FAQ'}"/></h1>
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

        <c:if test="${not empty loi}"><div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div></c:if>

        <div class="panel">
            <div class="panel-title">
                <c:choose>
                    <c:when test="${empty faq}">➕ Thêm FAQ mới</c:when>
                    <c:otherwise>✏️ Sửa FAQ #${faq.id}</c:otherwise>
                </c:choose>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/admin/faq">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="${empty faq ? 'insert' : 'update'}">
                <c:if test="${not empty faq}">
                    <input type="hidden" name="id" value="${faq.id}">
                </c:if>

                <div class="form-grid">
                    <div class="form-field form-full">
                        <label>Câu hỏi <span style="color:var(--danger);">*</span></label>
                        <input type="text" name="question" maxlength="500" required
                               value="${fn:escapeXml(not empty param.question ? param.question : faq.question)}">
                    </div>

                    <div class="form-field form-full">
                        <label>Câu trả lời <span style="color:var(--danger);">*</span></label>
                        <textarea name="answer" rows="6" required>${fn:escapeXml(not empty param.answer ? param.answer : faq.answer)}</textarea>
                    </div>

                    <div class="form-field">
                        <label>Danh mục (không bắt buộc)</label>
                        <input type="text" name="category" maxlength="100"
                               value="${fn:escapeXml(not empty param.category ? param.category : faq.category)}">
                    </div>

                    <div class="form-field">
                        <label>Thứ tự hiển thị</label>
                        <input type="number" step="1" name="displayOrder"
                               value="${not empty param.displayOrder ? param.displayOrder : (empty faq ? 0 : faq.displayOrder)}">
                    </div>
                </div>

                <div class="save-bar">
                    <a href="${pageContext.request.contextPath}/admin/faq" class="btn btn-outline">Huỷ</a>
                    <button type="submit" class="btn btn-primary">💾 Lưu</button>
                </div>
            </form>
        </div>

    </div>
</main>

<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${fn:escapeXml(sessionScope.account.userName)}</div>
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
