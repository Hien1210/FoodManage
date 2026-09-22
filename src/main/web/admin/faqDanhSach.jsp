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
    <title>FAQ / Hướng dẫn - Super Admin</title>
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
        .toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .cell-question { max-width: 360px; }
        .badge-category { display: inline-block; font-size: 11px; font-weight: 700; padding: 3px 10px; border-radius: 20px; background: var(--primary-light); color: var(--primary); white-space: nowrap; }
    </style>
</head>
<body class="dash-body admin-theme">
<c:set var="adminActive" value="/admin/faq" scope="request"/>
<%@ include file="_adminSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">quiz</span> FAQ / Hướng dẫn</h1>
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

        <c:if test="${param.success == 'insert'}"><div class="alert alert-success">✅ Đã tạo FAQ thành công!</div></c:if>
        <c:if test="${param.success == 'update'}"><div class="alert alert-success">✅ Đã cập nhật FAQ thành công!</div></c:if>
        <c:if test="${param.success == 'delete'}"><div class="alert alert-success">✅ Đã xoá FAQ thành công!</div></c:if>
        <c:if test="${param.error == 'delete'}"><div class="alert alert-danger">⚠️ Xoá FAQ thất bại, vui lòng thử lại.</div></c:if>
        <c:if test="${not empty loi}"><div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div></c:if>

        <div class="toolbar">
            <div style="font-size:13px;color:var(--text-muted);">Tổng số: <strong>${danhSachFaq.size()}</strong> FAQ</div>
            <a href="${pageContext.request.contextPath}/admin/faq?action=new" class="btn btn-primary">+ Thêm FAQ</a>
        </div>

        <div class="panel">
            <div class="panel-title" style="margin-bottom: 16px;">Danh sách FAQ / Hướng dẫn</div>

            <div class="dash-table-wrap">
                <table class="dash-table">
                    <thead>
                        <tr>
                            <th>STT</th>
                            <th>Câu hỏi</th>
                            <th>Danh mục</th>
                            <th>Thứ tự hiển thị</th>
                            <th>Người tạo</th>
                            <th>Ngày tạo</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty danhSachFaq}">
                                <tr><td colspan="7" class="empty-state">Chưa có FAQ nào.</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="f" items="${danhSachFaq}" varStatus="st">
                                    <tr>
                                        <td>${st.index + 1}</td>
                                        <td class="cell-question">${fn:escapeXml(f.question)}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty f.category}"><span class="badge-category">${fn:escapeXml(f.category)}</span></c:when>
                                                <c:otherwise><span style="color:var(--text-dim);">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${f.displayOrder}</td>
                                        <td>${not empty f.createdByName ? fn:escapeXml(f.createdByName) : '—'}</td>
                                        <td style="color:var(--text-muted);font-size:12px;">
                                            <c:if test="${not empty f.createdAt}">
                                                <c:set var="d" value="${f.createdAt.dayOfMonth}"/><c:if test="${d < 10}">0</c:if>${d}/<c:set var="mo" value="${f.createdAt.monthValue}"/><c:if test="${mo < 10}">0</c:if>${mo}/${f.createdAt.year}
                                                <c:set var="h" value="${f.createdAt.hour}"/><c:if test="${h < 10}">0</c:if>${h}:<c:set var="mi" value="${f.createdAt.minute}"/><c:if test="${mi < 10}">0</c:if>${mi}
                                            </c:if>
                                        </td>
                                        <td style="white-space:nowrap;">
                                            <a href="${pageContext.request.contextPath}/admin/faq?action=edit&id=${f.id}" class="btn btn-sm btn-ghost">✏️ Sửa</a>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/faq" style="display:inline;" onsubmit="return confirm('Xoá FAQ này?');">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${f.id}">
                                                <button type="submit" class="btn btn-sm btn-danger">🗑️ Xoá</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
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
