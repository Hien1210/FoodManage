<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="currentShop" value="${sessionScope.currentShop}" scope="request"/>

<%-- BẢO MẬT: KIỂM TRA QUYỀN SHOP (roleId = 2) --%>
<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 2}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hóa đơn - ${not empty currentShop.shopName ? currentShop.shopName : 'Cửa hàng'}</title>
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

        /* Bộ lọc danh sách hóa đơn */
        .filter-bar { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 18px; align-items: center; }
        .filter-bar input[type="text"] { width: 220px; }
        .filter-bar a.clear { font-size: 12.5px; color: var(--text-dim); font-weight: 600; }
        .action-cell { display: flex; gap: 6px; flex-wrap: wrap; }
        .inline-form { display: inline; }
        /* Tab lọc theo trạng thái đơn (lọc phía client trên danh sách đang hiển thị) */
        .stat-card.stat-alert { border-color: var(--primary); box-shadow: 0 0 0 2px var(--primary-light), var(--dash-shadow-sm); }
        .bill-id { font-weight: 800; color: var(--text-main); font-family: var(--font-display); }
        .bill-date { font-size: 12px; color: var(--text-dim); margin-top: 2px; white-space: nowrap; }
        .col-cust { min-width: 190px; }
        .bill-addr { max-width: 230px; margin-top: 2px; font-size: 12px; color: var(--text-dim); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .bill-total { font-weight: 800; color: var(--primary); font-size: 14.5px; margin-bottom: 4px; white-space: nowrap; }
        table.dash-table td .badge { white-space: normal; text-align: left; }
        .bill-tabs { display: flex; gap: 8px; flex-wrap: wrap; }
        .bill-tab { display: inline-flex; align-items: center; gap: 8px; padding: 8px 16px; border-radius: 999px; border: 1px solid var(--border-color); background: var(--bg-panel); color: var(--text-muted); font-size: 13px; font-weight: 700; cursor: pointer; font-family: inherit; }
        .bill-tab:hover { border-color: var(--primary); color: var(--primary); }
        .bill-tab.active { background: var(--primary); border-color: var(--primary); color: #fff; box-shadow: 0 8px 20px rgba(227, 37, 10, .25); }
        .bill-tab-count { font-size: 11px; font-weight: 800; padding: 1px 8px; border-radius: 999px; background: var(--bg-input); color: var(--text-main); }
        .bill-tab.active .bill-tab-count { background: rgba(255, 255, 255, .25); color: #fff; }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="/shop/bills" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">receipt_long</span> Quản lý hóa đơn / đơn hàng</h1>
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
        <c:if test="${not empty loi}">
            <div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div>
        </c:if>
        <c:if test="${param.error eq 'not_found'}">
            <div class="alert alert-danger">⚠️ Không tìm thấy đơn hàng hoặc đơn không thuộc shop của bạn!</div>
        </c:if>
        <c:if test="${param.success eq 'confirmed'}">
            <div class="alert alert-success">✅ Đã xác nhận đơn hàng! Hãy chuẩn bị món.</div>
        </c:if>
        <c:if test="${param.success eq 'prepared'}">
            <div class="alert alert-success">📦 Đã chuẩn bị xong món! Shipper có thể nhận đơn ngay.</div>
        </c:if>
        <c:if test="${param.success eq 'cancelled'}">
            <div class="alert alert-danger">🚫 Đã hủy đơn hàng.</div>
        </c:if>
        <c:if test="${param.error eq 'already_assigned'}">
            <div class="alert alert-danger">⚠️ Đơn đã có shipper nhận trước đó rồi.</div>
        </c:if>
        <c:if test="${param.error eq 'invalid_shipper'}">
            <div class="alert alert-danger">⚠️ Vui lòng chọn shipper để gán.</div>
        </c:if>

        <form class="filter-bar" method="get" action="${pageContext.request.contextPath}/shop/bills">
            <input type="text" class="dash-input" name="q" placeholder="🔍 Tìm theo mã đơn / tên khách / SĐT..." value="${fn:escapeXml(q)}">
            <input type="date" class="dash-input" name="date" value="${dateFilter}">
            <select class="dash-input" name="status">
                <option value="" ${empty statusFilter ? 'selected' : ''}>Tất cả</option>
                <option value="UNPAID" ${statusFilter == 'UNPAID' ? 'selected' : ''}>Chưa thanh toán</option>
                <option value="PAID" ${statusFilter == 'PAID' ? 'selected' : ''}>Đã thanh toán</option>
                <option value="CANCELLED" ${statusFilter == 'CANCELLED' ? 'selected' : ''}>Hủy</option>
            </select>
            <select class="dash-input" name="method">
                <option value="" ${empty methodFilter ? 'selected' : ''}>Tất cả hình thức</option>
                <option value="COD" ${methodFilter == 'COD' ? 'selected' : ''}>💵 Tiền mặt</option>
                <option value="BANK" ${methodFilter == 'BANK' ? 'selected' : ''}>📱 QR chuyển khoản</option>
                <option value="PAYOS" ${methodFilter == 'PAYOS' ? 'selected' : ''}>🏦 PayOS</option>
            </select>
            <button type="submit" class="btn btn-primary">Lọc</button>
            <a href="${pageContext.request.contextPath}/shop/bills" class="clear">✕ Xóa lọc</a>
            <a class="btn btn-outline"
               href="${pageContext.request.contextPath}/shop/bills?action=exportExcel&q=${fn:escapeXml(q)}&date=${dateFilter}&status=${statusFilter}&method=${methodFilter}">
                📊 Xuất Excel (doanh thu)
            </a>
        </form>

        <%-- Thống kê + tab trạng thái: tính từ chính danh sách đơn đang hiển thị (đã áp bộ lọc phía trên) --%>
        <c:set var="nAll" value="${fn:length(orderList)}"/>
        <c:set var="nPending" value="0"/><c:set var="nConfirmed" value="0"/><c:set var="nReady" value="0"/>
        <c:set var="nShipping" value="0"/><c:set var="nDone" value="0"/><c:set var="nCancelled" value="0"/>
        <c:set var="revenuePaid" value="0"/>
        <c:forEach var="o" items="${orderList}">
            <c:set var="dsK" value="${fn:toUpperCase(o.staTus)}"/>
            <c:choose>
                <c:when test="${dsK == 'PENDING'}"><c:set var="nPending" value="${nPending + 1}"/></c:when>
                <c:when test="${dsK == 'CONFIRMED'}"><c:set var="nConfirmed" value="${nConfirmed + 1}"/></c:when>
                <c:when test="${dsK == 'READY_FOR_PICKUP'}"><c:set var="nReady" value="${nReady + 1}"/></c:when>
                <c:when test="${dsK == 'SHIPPING'}"><c:set var="nShipping" value="${nShipping + 1}"/></c:when>
                <c:when test="${dsK == 'DONE'}"><c:set var="nDone" value="${nDone + 1}"/></c:when>
                <c:when test="${dsK == 'CANCELLED'}"><c:set var="nCancelled" value="${nCancelled + 1}"/></c:when>
            </c:choose>
            <c:if test="${fn:toUpperCase(o.paymentStatus) == 'PAID' and dsK != 'CANCELLED'}">
                <c:set var="revenuePaid" value="${revenuePaid + o.totalPrice}"/>
            </c:if>
        </c:forEach>

        <div class="stats-grid">
            <div class="stat-card">
                <div>
                    <div class="stat-label">Tổng hóa đơn</div>
                    <div class="stat-num">${nAll}</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">receipt_long</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Doanh thu đã thanh toán</div>
                    <div class="stat-num"><fmt:formatNumber value="${revenuePaid}" type="number" maxFractionDigits="0"/>đ</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">payments</span></div>
            </div>
            <div class="stat-card ${nPending > 0 ? 'stat-alert' : ''}">
                <div>
                    <div class="stat-label">Chờ xác nhận</div>
                    <div class="stat-num">${nPending}</div>
                    <div class="stat-trend" style="color:var(--text-dim);">đơn cần shop xác nhận</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">notifications_active</span></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Đã giao</div>
                    <div class="stat-num">${nDone}</div>
                </div>
                <div class="stat-icon"><span class="material-symbols-outlined">check_circle</span></div>
            </div>
        </div>

        <div class="bill-tabs" id="billTabs" role="tablist">
            <button type="button" class="bill-tab active" data-ds="ALL">Tất cả <span class="bill-tab-count">${nAll}</span></button>
            <button type="button" class="bill-tab" data-ds="PENDING">Chờ xác nhận <span class="bill-tab-count">${nPending}</span></button>
            <button type="button" class="bill-tab" data-ds="CONFIRMED">Đang chuẩn bị <span class="bill-tab-count">${nConfirmed}</span></button>
            <button type="button" class="bill-tab" data-ds="READY_FOR_PICKUP">Chờ shipper lấy <span class="bill-tab-count">${nReady}</span></button>
            <button type="button" class="bill-tab" data-ds="SHIPPING">Đang giao <span class="bill-tab-count">${nShipping}</span></button>
            <button type="button" class="bill-tab" data-ds="DONE">Hoàn tất <span class="bill-tab-count">${nDone}</span></button>
            <button type="button" class="bill-tab" data-ds="CANCELLED">Đã hủy <span class="bill-tab-count">${nCancelled}</span></button>
        </div>

        <section class="panel">
            <div class="panel-header">
                <div class="panel-title">📋 Danh sách đơn hàng</div>
            </div>
            <div class="panel-body" style="padding:0;">
                <c:choose>
                    <c:when test="${empty orderList}">
                        <div class="empty-state">
                            <div class="e-icon">🧾</div>
                            <div class="e-title">Không có đơn hàng nào khớp với bộ lọc.</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="dash-table-wrap">
                            <table class="dash-table">
                                <thead>
                                <tr>
                                    <th>Đơn hàng</th>
                                    <th>Khách hàng</th>
                                    <th>Tổng tiền</th>
                                    <th>Thanh toán</th>
                                    <th>Trạng thái đơn</th>
                                    <th>Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="o" items="${orderList}">
                                    <c:set var="rowDs" value="${fn:toUpperCase(o.staTus)}"/>
                                    <tr data-ds="${rowDs}">
                                        <td class="col-id">
                                            <div class="bill-id">#${o.id}</div>
                                            <div class="bill-date">
                                            <c:set var="ca" value="${o.createdAt}"/>
                                            ${fn:substring(ca,11,16)} ${fn:substring(ca,8,10)}/${fn:substring(ca,5,7)}/${fn:substring(ca,0,4)}
                                            <c:if test="${not empty o.scheduledAt}">
                                                <c:set var="sa" value="${o.scheduledAt}"/>
                                                <br><span style="display:inline-block;margin-top:4px;background:#eff6ff;color:#2563eb;border:1px solid #bfdbfe;border-radius:6px;padding:2px 8px;font-size:11px;font-weight:600;">🕐 Hẹn: ${fn:substring(sa,11,16)} ${fn:substring(sa,8,10)}/${fn:substring(sa,5,7)}/${fn:substring(sa,0,4)}</span>
                                            </c:if>
                                            </div>
                                        </td>
                                        <td class="col-cust">
                                            <strong><c:out value="${o.receiverName}"/></strong><br>
                                            <c:out value="${o.receiverPhone}"/>
                                            <div class="bill-addr" title="<c:out value="${o.shippingAddress}"/>"><c:out value="${o.shippingAddress}"/></div>
                                        </td>
                                        <td class="col-total">
                                            <div class="bill-total"><fmt:formatNumber value="${o.totalPrice}" type="number" maxFractionDigits="0"/> đ</div>
                                            <c:set var="pm" value="${fn:toUpperCase(o.paymentMethod)}"/>
                                            <c:choose>
                                                <c:when test="${pm == 'BANK'}"><span class="badge badge-info">📱 QR chuyển khoản</span></c:when>
                                                <c:when test="${pm == 'PAYOS'}"><span class="badge badge-info">🏦 PayOS</span></c:when>
                                                <c:otherwise><span class="badge badge-neutral">💵 Tiền mặt</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:set var="pst" value="${fn:toUpperCase(o.paymentStatus)}"/>
                                            <c:choose>
                                                <c:when test="${pst == 'PAID'}"><span class="badge badge-success">✅ Đã thanh toán</span></c:when>
                                                <c:when test="${pst == 'PENDING'}"><span class="badge badge-warning">⏳ Đang chờ</span></c:when>
                                                <c:otherwise><span class="badge badge-danger">⛔ Chưa thanh toán</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:set var="ds" value="${fn:toUpperCase(o.staTus)}"/>
                                            <c:choose>
                                                <c:when test="${ds == 'PENDING'}"><span class="badge badge-warning">🛵 Shipper đã nhận — Chờ xác nhận</span></c:when>
                                                <c:when test="${ds == 'CONFIRMED'}"><span class="badge badge-info">👨‍🍳 Đang chuẩn bị món</span></c:when>
                                                <c:when test="${ds == 'READY_FOR_PICKUP' && o.shipperId > 0}">
                                                    <span class="badge badge-success">🛵 Shipper đã nhận, chờ lấy hàng</span>
                                                </c:when>
                                                <c:when test="${ds == 'READY_FOR_PICKUP'}">
                                                    <span class="badge badge-success">📦 Đã nấu xong, chờ shipper nhận</span>
                                                </c:when>
                                                <c:when test="${ds == 'SHIPPING'}"><span class="badge badge-warning">🚚 Đang giao</span></c:when>
                                                <c:when test="${ds == 'DONE'}"><span class="badge badge-success">✅ Đã giao</span></c:when>
                                                <c:when test="${ds == 'CANCELLED'}"><span class="badge badge-danger">🚫 Đã hủy</span></c:when>
                                                <c:otherwise><span class="badge badge-neutral">${o.staTus}</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="action-cell">
                                                <a href="${pageContext.request.contextPath}/shop/bills?action=view&as=modal&id=${o.id}" class="btn btn-sm btn-primary">🧾 Xem</a>
                                                <a href="${pageContext.request.contextPath}/shop/bills?action=exportPdf&id=${o.id}" class="btn btn-sm btn-outline">📄 PDF</a>
                                                <c:if test="${fn:toUpperCase(o.staTus) == 'PENDING' && o.shipperId > 0}">
                                                    <form method="post" action="${pageContext.request.contextPath}/shop/bills" class="inline-form"
                                                          onsubmit="return pobGuardSubmit(this)">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="confirm"/>
                                                        <input type="hidden" name="orderId" value="${o.id}"/>
                                                        <button type="submit" class="btn btn-sm btn-success">✅ Xác nhận & Chuẩn bị</button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/shop/bills" class="inline-form"
                                                          onsubmit="return pobConfirmDelete(event, this, 'Bạn có chắc chắn muốn HỦY đơn <strong>#${o.id}</strong> không?', 'Hủy đơn hàng')">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="cancel"/>
                                                        <input type="hidden" name="orderId" value="${o.id}"/>
                                                        <button type="submit" class="btn btn-sm btn-danger">❌ Hủy</button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${fn:toUpperCase(o.staTus) == 'CONFIRMED'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/shop/bills" class="inline-form"
                                                          onsubmit="return pobGuardSubmit(this)">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="prepared"/>
                                                        <input type="hidden" name="orderId" value="${o.id}"/>
                                                        <button type="submit" class="btn btn-sm btn-success">📦 Đã chuẩn bị xong</button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/shop/bills" class="inline-form"
                                                          onsubmit="return pobConfirmDelete(event, this, 'Bạn có chắc chắn muốn HỦY đơn <strong>#${o.id}</strong> không?', 'Hủy đơn hàng')">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="cancel"/>
                                                        <input type="hidden" name="orderId" value="${o.id}"/>
                                                        <button type="submit" class="btn btn-sm btn-danger">❌ Hủy</button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        <div class="empty-state" id="billTabEmpty" style="display:none;">
                            <div class="e-icon">🧾</div>
                            <div class="e-title">Không có đơn hàng ở trạng thái này.</div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </div>
</main>

<%@ include file="_invoiceModal.jspf" %>

<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${sessionScope.account.userName}</div>
        <div class="d-email">${sessionScope.account.email}</div>
        <span class="d-role">🏪 Shop Owner</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/shop/ho-so" class="dropdown-link">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/shop/doi-mat-khau" class="dropdown-link">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/form-guard.js"></script>
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

<script>
    (function () {
        var tabs = document.getElementById('billTabs');
        if (!tabs) return;
        var rows = document.querySelectorAll('table.dash-table tbody tr[data-ds]');
        var emptyNote = document.getElementById('billTabEmpty');
        tabs.addEventListener('click', function (e) {
            var btn = e.target.closest('.bill-tab');
            if (!btn) return;
            tabs.querySelectorAll('.bill-tab').forEach(function (b) { b.classList.toggle('active', b === btn); });
            var ds = btn.getAttribute('data-ds');
            var shown = 0;
            rows.forEach(function (r) {
                var ok = ds === 'ALL' || r.getAttribute('data-ds') === ds;
                r.style.display = ok ? '' : 'none';
                if (ok) shown++;
            });
            if (emptyNote && rows.length) emptyNote.style.display = shown === 0 ? '' : 'none';
        });
    })();
</script>
</body>
</html>
