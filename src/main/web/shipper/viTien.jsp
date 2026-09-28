<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Ví tiền - POB Shipper</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <style>
        .wallet-card { background: linear-gradient(135deg, var(--primary), #c0392b); border-radius: var(--radius-md); padding: 28px 28px 24px; color: #fff; margin-bottom: 24px; position: relative; overflow: hidden; }
        .wallet-card::after { content: '💰'; position: absolute; right: 20px; bottom: 10px; font-size: 64px; opacity: .15; }
        .wallet-label { font-size: 13px; font-weight: 600; opacity: .85; margin-bottom: 6px; }
        .wallet-balance { font-size: 36px; font-weight: 800; letter-spacing: -1px; }
        .wallet-note { font-size: 12px; opacity: .7; margin-top: 8px; }

        .form-section { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 24px; box-shadow: var(--dash-shadow-sm); margin-bottom: 20px; }
        .form-section h3 { font-size: 15px; font-weight: 800; color: var(--text-main); margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
        .form-group { margin-bottom: 14px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: var(--text-muted); margin-bottom: 6px; }
        .form-group input { width: 100%; padding: 10px 13px; border: 1.5px solid var(--border-color); border-radius: var(--radius-sm); font-size: 14px; font-family: inherit; background: var(--bg-input); color: var(--text-main); }
        .form-group input:focus { outline: none; border-color: var(--primary); }
        .btn-withdraw { width: 100%; padding: 13px; border: none; border-radius: var(--radius-sm); background: var(--primary); color: #fff; font-size: 15px; font-weight: 700; cursor: pointer; font-family: inherit; }
        .btn-withdraw:hover { opacity: .9; }
        .alert { padding: 12px 16px; border-radius: var(--radius-sm); font-size: 13px; font-weight: 600; margin-bottom: 16px; }
        .alert-error { background: var(--danger-light); color: var(--danger); border: 1px solid var(--danger); }
        .alert-success { background: var(--success-light); color: var(--success-dark); border: 1px solid var(--success); }
        .info-row { display: flex; justify-content: space-between; font-size: 13px; color: var(--text-muted); padding: 8px 0; border-bottom: 1px solid var(--border-color); }
        .info-row:last-child { border: none; }
        .info-row strong { color: var(--text-main); }

        .history-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .history-table th { text-align: left; font-size: 11px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; padding: 8px 10px; border-bottom: 2px solid var(--border-color); }
        .history-table td { padding: 10px 10px; border-bottom: 1px solid var(--border-color); color: var(--text-main); vertical-align: middle; }
        .history-table tr:last-child td { border: none; }
        .badge-pending { background: #fff3cd; color: #856404; border: 1px solid #ffc107; padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 700; }
        .badge-approved { background: var(--success-light); color: var(--success-dark); border: 1px solid var(--success); padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 700; }
        .badge-rejected { background: var(--danger-light); color: var(--danger); border: 1px solid var(--danger); padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 700; }
        .amount-red { color: var(--primary); font-weight: 700; }
        .empty-history { text-align: center; color: var(--text-muted); padding: 24px 0; font-size: 13px; }

        .online-toggle-btn { width: 100%; padding: 12px 16px; border-radius: var(--radius-sm); border: none; cursor: pointer; display: flex; align-items: center; gap: 10px; font-size: 13px; font-weight: 700; }
        .online-toggle-btn.is-online { background: var(--success-light); color: var(--success-dark); border: 1.5px solid var(--success); }
        .online-toggle-btn.is-offline { background: var(--danger-light); color: var(--danger); border: 1.5px solid var(--danger); }
        .toggle-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
        .toggle-dot.online { background: var(--success); animation: pobBlink 1.5s infinite; }
        .toggle-dot.offline { background: var(--danger); }

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
<body class="dash-body">

<div class="sidebar-backdrop" id="sidebarBackdrop"></div>
<aside class="sidebar" id="sidebar">
    <div class="sidebar-brand">
        <div class="logo-mark-dash">🛵</div>
        <div class="brand-text">
            <span class="brand-title">POB SHIPPER</span>
            <c:choose>
                <c:when test="${sessionScope.account.online}">
                    <span class="brand-subtitle" style="color:var(--success);">● Đang hoạt động</span>
                </c:when>
                <c:otherwise>
                    <span class="brand-subtitle" style="color:var(--danger);">● Ngoại tuyến</span>
                </c:otherwise>
            </c:choose>
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
        <a href="${pageContext.request.contextPath}/shipper/vi-tien" class="menu-item active">
            <span class="mi-left"><span class="mi-icon">💰</span><span class="mi-label"> Ví tiền</span></span>
        </a>
    </div>
    <div class="sidebar-foot">
        <form action="${pageContext.request.contextPath}/shipper/status" method="post">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <c:choose>
                <c:when test="${sessionScope.account.online}">
                    <button type="submit" class="online-toggle-btn is-online"
                            onclick="return confirm('Tắt chế độ Online? Bạn sẽ không nhận đơn mới.')">
                        <span class="toggle-dot online"></span><span class="sf-label">Đang Online — Nhấn để Offline</span>
                    </button>
                </c:when>
                <c:otherwise>
                    <button type="submit" class="online-toggle-btn is-offline">
                        <span class="toggle-dot offline"></span><span class="sf-label">Đang Offline — Nhấn để Online</span>
                    </button>
                </c:otherwise>
            </c:choose>
        </form>
    </div>
</aside>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1>💰 Ví tiền</h1>
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
        <div style="max-width:520px;margin:0 auto;width:100%;">

            <c:if test="${param.success eq '1'}">
                <div class="alert alert-success">✅ Yêu cầu rút tiền đã được gửi thành công. Admin sẽ xử lý trong 1-2 ngày làm việc.</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-error">⚠️ <c:out value="${error}"/></div>
            </c:if>

            <div class="wallet-card">
                <div class="wallet-label">Số dư ví hiện tại</div>
                <div class="wallet-balance"><fmt:formatNumber value="${balance}" type="number" maxFractionDigits="0"/>đ</div>
                <div class="wallet-note">Số dư được cộng tự động sau mỗi đơn giao thành công.</div>
            </div>

            <div class="form-section">
                <h3>📋 Thông tin</h3>
                <div class="info-row"><span>Thu nhập từ phí giao</span><strong>Cộng tự động khi đơn DONE</strong></div>
                <div class="info-row"><span>Rút tiền tối thiểu</span><strong>50.000đ</strong></div>
                <div class="info-row"><span>Thời gian xử lý</span><strong>1–2 ngày làm việc</strong></div>
            </div>

            <div class="form-section">
                <h3>🏧 Yêu cầu rút tiền</h3>

                <c:choose>
                    <c:when test="${empty profile || !profile.hasBankInfo}">
                        <div class="alert alert-error" style="background:#fff3cd;color:#856404;border-color:#ffc107;">
                            ⚠️ Bạn chưa cập nhật thông tin ngân hàng nhận tiền.
                            <a href="${pageContext.request.contextPath}/shipper/profile#bankInfoSection" style="font-weight:700;text-decoration:underline;">Cập nhật ngay</a>
                            để có thể gửi yêu cầu rút tiền.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="bank-info-saved" style="background:var(--bg-input);border:1px solid var(--border-color);border-radius:10px;padding:14px 16px;margin-bottom:16px;">
                            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">
                                <strong style="font-size:13px;">🏦 Tài khoản nhận tiền (đã lưu)</strong>
                                <a href="${pageContext.request.contextPath}/shipper/profile#bankInfoSection" style="font-size:12px;font-weight:700;color:var(--primary);text-decoration:underline;">✏️ Đổi (cần OTP)</a>
                            </div>
                            <div class="info-row"><span>Ngân hàng</span><strong>${fn:escapeXml(profile.bankName)}</strong></div>
                            <div class="info-row"><span>Số tài khoản</span><strong>${fn:escapeXml(profile.bankAccount)}</strong></div>
                            <div class="info-row"><span>Chủ tài khoản</span><strong>${fn:escapeXml(profile.bankAccountHolder)}</strong></div>
                        </div>

                        <form method="post" action="${pageContext.request.contextPath}/shipper/vi-tien">
                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                            <div class="form-group">
                                <label>Số tiền muốn rút (đ)</label>
                                <input type="text" id="amountDisplay" autocomplete="off"
                                       placeholder="VD: 200.000" required
                                       style="ime-mode:disabled;"
                                       value="<c:if test='${not empty param.amount}'><fmt:formatNumber value='${param.amount}' type='number' maxFractionDigits='0'/></c:if>">
                                <input type="hidden" name="amount" id="amountHidden"
                                       value="${param.amount}">
                                <div id="amountPreview" style="font-size:12px;color:var(--primary);margin-top:4px;font-weight:700;min-height:18px;"></div>
                            </div>
                            <button type="submit" class="btn-withdraw">Gửi yêu cầu rút tiền</button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="form-section">
                <h3>📜 Lịch sử rút tiền</h3>
                <c:choose>
                    <c:when test="${empty withdrawals}">
                        <div class="empty-history">Chưa có yêu cầu rút tiền nào.</div>
                    </c:when>
                    <c:otherwise>
                        <div style="overflow-x:auto;">
                        <table class="history-table">
                            <thead>
                                <tr>
                                    <th>Mã GD</th>
                                    <th>Số tiền</th>
                                    <th>Ngân hàng</th>
                                    <th>Ngày gửi</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="w" items="${withdrawals}">
                                    <tr>
                                        <td style="font-size:11px;color:var(--text-muted);">RUT-<fmt:formatNumber value="${w.id}" pattern="000000"/></td>
                                        <td class="amount-red"><fmt:formatNumber value="${w.amount}" type="number" maxFractionDigits="0"/>đ</td>
                                        <td>
                                            <div style="font-weight:600;">${fn:escapeXml(w.bankName)}</div>
                                            <div style="font-size:11px;color:var(--text-muted);">${fn:escapeXml(w.bankAccountNumber)}</div>
                                        </td>
                                        <td style="font-size:12px;color:var(--text-muted);">${w.requestedAtDisplay}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${w.status eq 'PENDING'}"><span class="badge-pending">⏳ Chờ duyệt</span></c:when>
                                                <c:when test="${w.status eq 'APPROVED'}"><span class="badge-approved">✅ Đã duyệt</span></c:when>
                                                <c:when test="${w.status eq 'REJECTED'}">
                                                    <span class="badge-rejected">❌ Từ chối</span>
                                                    <c:if test="${not empty w.rejectReason}">
                                                        <div style="font-size:11px;color:var(--danger);margin-top:3px;">${fn:escapeXml(w.rejectReason)}</div>
                                                    </c:if>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

        </div>
    </div>
</main>

<!-- Avatar Dropdown -->
<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${fn:escapeXml(sessionScope.account.userName)}</div>
        <div class="d-email">${fn:escapeXml(sessionScope.account.email)}</div>
        <span class="d-role">🛵 Shipper</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/shipper/ho-so" class="dropdown-link">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/shipper/doi-mat-khau" class="dropdown-link">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script>
(function() {
    var display = document.getElementById('amountDisplay');
    var hidden  = document.getElementById('amountHidden');
    var preview = document.getElementById('amountPreview');

    function formatVND(raw) {
        return raw.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    }

    function update(val) {
        var digits = val.replace(/\D/g, '');
        display.value = digits ? formatVND(digits) : '';
        hidden.value  = digits || '';
        if (digits && parseInt(digits) >= 1000) {
            preview.textContent = '= ' + formatVND(digits) + 'đ';
        } else {
            preview.textContent = '';
        }
    }

    display.addEventListener('input', function() { update(display.value); });

    display.addEventListener('keydown', function(e) {
        // cho phép: số, Backspace, Delete, Tab, mũi tên, Home/End
        if (!/^\d$/.test(e.key) && !['Backspace','Delete','Tab','ArrowLeft','ArrowRight','Home','End'].includes(e.key) && !e.ctrlKey && !e.metaKey) {
            e.preventDefault();
        }
    });

    // init nếu có giá trị sẵn (lỗi redirect)
    if (hidden.value) update(hidden.value);

    // validate trước khi submit
    display.closest('form').addEventListener('submit', function(e) {
        var amt = parseInt(hidden.value || '0');
        if (!amt || amt < 50000) {
            e.preventDefault();
            display.focus();
            preview.textContent = '⚠ Tối thiểu 50.000đ';
            preview.style.color = 'var(--danger)';
        }
    });
})();
</script>
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
