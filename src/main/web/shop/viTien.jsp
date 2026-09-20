<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="currentShop" value="${shop}" scope="request"/>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 2}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ví tiền - ${not empty shop.shopName ? shop.shopName : 'Cửa hàng'}</title>
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
        .wallet-hero { background: linear-gradient(135deg, #3A1206 0%, #7A1F0A 55%, #B71500 100%); border-radius: 20px; padding: 36px 32px; color: #fff; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 20px; margin-bottom: 24px; position: relative; overflow: hidden; }
        .wallet-hero::before { content: ''; position: absolute; inset: 0; background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.04'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E") repeat; }
        .wallet-balance-section { position: relative; z-index: 1; }
        .wallet-balance-label { font-size: 13px; opacity: .7; margin-bottom: 6px; letter-spacing: .05em; text-transform: uppercase; }
        .wallet-balance-amount { display: flex; align-items: baseline; gap: 6px; font-size: 42px; font-weight: 800; letter-spacing: -1px; line-height: 1; }
        .wallet-balance-amount span { font-size: 20px; font-weight: 600; opacity: .8; }
        .wallet-chip { background: rgba(255,255,255,.12); border: 1px solid rgba(255,255,255,.2); border-radius: 10px; padding: 6px 14px; font-size: 12px; font-weight: 600; letter-spacing: .05em; margin-top: 12px; display: inline-block; }
        .wallet-actions-hero { display: flex; gap: 12px; flex-wrap: wrap; position: relative; z-index: 1; }
        .btn-hero {
            display: inline-flex; align-items: center; justify-content: center; gap: 6px;
            padding: 12px 24px; border-radius: 12px; font-weight: 700; font-size: 14px;
            border: 2px solid; cursor: pointer; transition: .18s;
            text-decoration: none; white-space: nowrap; line-height: 1.2;
        }
        .btn-hero-primary { background: #fff; color: #B71500; border-color: #fff; }
        .btn-hero-primary:hover { background: #e8f0fe; }
        .btn-hero-outline { background: transparent; color: #fff; border-color: rgba(255,255,255,.4); }
        .btn-hero-outline:hover { background: rgba(255,255,255,.1); border-color: #fff; }
        /* body.dash-body a có specificity cao hơn .btn-hero-primary/.btn-hero-outline nên
           "color: inherit" đè mất màu chữ đã định nghĩa ở trên — khai báo lại đúng độ ưu tiên
           ở đây, cùng convention với dashboard.css (xem body.dash-body a.btn-primary/...) */
        body.dash-body a.btn-hero-primary { color: #B71500; }
        body.dash-body a.btn-hero-outline { color: #fff; }

        .stat-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; margin-bottom: 28px; }
        .stat-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 14px; padding: 20px; display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; }
        .stat-card .sc-text { min-width: 0; }
        .stat-card .sc-label { font-size: 12px; color: var(--text-muted); font-weight: 600; text-transform: uppercase; letter-spacing: .06em; margin-bottom: 8px; white-space: nowrap; }
        .stat-card .sc-value { font-size: 22px; font-weight: 800; color: var(--text-main); white-space: nowrap; }
        .stat-card .sc-icon { font-size: 28px; opacity: .35; flex-shrink: 0; line-height: 1; }
        .stat-card.green .sc-value { color: #16a34a; }
        .stat-card.blue .sc-value { color: var(--primary); }
        .stat-card.orange .sc-value { color: #A83900; }

        .section-card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 14px; margin-bottom: 24px; overflow: hidden; }
        .section-card-header { padding: 16px 20px; border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; }
        .section-card-header h3 { font-size: 15px; font-weight: 700; color: var(--text-main); }
        .section-card-body { padding: 0; }

        .tx-table { width: 100%; border-collapse: collapse; font-size: 13.5px; }
        .tx-table th { padding: 10px 14px; text-align: left; font-size: 11px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: .06em; background: var(--bg-input); }
        .tx-table td { padding: 12px 14px; border-bottom: 1px solid var(--border-color); vertical-align: middle; }
        .tx-table tr:last-child td { border-bottom: none; }
        .tx-table tr:hover td { background: var(--bg-input); }
        .tx-type { display: inline-flex; align-items: center; gap: 6px; font-size: 11px; font-weight: 700; padding: 3px 9px; border-radius: 6px; }
        .tx-type.EARNING { background: #dcfce7; color: #15803d; }
        .tx-type.WITHDRAWAL { background: #fef3c7; color: #92400e; }
        .tx-type.REFUND { background: #fee2e2; color: #b91c1c; }
        .tx-amount.positive { color: #16a34a; font-weight: 700; }
        .tx-amount.negative { color: #dc2626; font-weight: 700; }

        .badge-status { display: inline-block; padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 700; }
        .badge-status.PENDING { background: #fef3c7; color: #92400e; }
        .badge-status.APPROVED { background: #dcfce7; color: #15803d; }
        .badge-status.REJECTED { background: #fee2e2; color: #b91c1c; }

        .withdraw-form { padding: 20px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        .form-group { margin-bottom: 14px; }
        .form-group label { font-size: 12px; font-weight: 700; color: var(--text-muted); display: block; margin-bottom: 4px; text-transform: uppercase; letter-spacing: .04em; }
        .form-group input { width: 100%; padding: 10px 12px; border-radius: 8px; border: 1.5px solid var(--border-color); background: var(--bg-input); color: var(--text-main); font-size: 14px; }
        .form-group input:focus { outline: none; border-color: var(--primary); }
        .amount-hint { font-size: 11px; color: var(--text-muted); margin-top: 3px; }
        .submit-btn { width: 100%; padding: 12px; border-radius: 10px; background: var(--primary); color: #fff; font-size: 14px; font-weight: 700; border: none; cursor: pointer; transition: .18s; margin-top: 6px; }
        .submit-btn:hover { background: var(--primary-dark); }

        .pager { display: flex; gap: 8px; justify-content: center; padding: 16px; }
        .pager a { padding: 6px 12px; border-radius: 8px; border: 1px solid var(--border-color); color: var(--text-muted); font-size: 13px; font-weight: 600; }
        .pager a.active, .pager a:hover { background: var(--primary); color: #fff; border-color: var(--primary); }

        .empty-state { text-align: center; padding: 40px 20px; color: var(--text-muted); font-size: 14px; }
        .alert { padding: 12px 16px; border-radius: 10px; margin-bottom: 16px; font-size: 14px; font-weight: 600; }
        .alert-success { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
        .alert-danger  { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }
        .info-box { background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px; padding: 14px 16px; margin-bottom: 20px; font-size: 13px; color: #1d4ed8; }
        .bank-info-saved .info-row { display: flex; justify-content: space-between; font-size: 13px; padding: 5px 0; color: var(--text-muted, #666); }
        .bank-info-saved .info-row strong { color: var(--text-main, #1a1a1a); }

        /* --- Bố cục ví theo bản Stitch: thẻ ví + thẻ ngân hàng; lịch sử + form rút tiền --- */
        .wallet-top { display: grid; grid-template-columns: minmax(0, 1fr) 340px; gap: 24px; align-items: stretch; margin-bottom: 24px; }
        .wallet-hero { flex-direction: column; align-items: stretch; justify-content: flex-start; gap: 24px; padding: 28px 30px; margin-bottom: 0; box-shadow: var(--dash-shadow-md); }
        .wallet-hero-row { display: flex; align-items: center; justify-content: space-between; gap: 16px; flex-wrap: wrap; position: relative; z-index: 1; }
        .btn-hero { border-radius: 999px; }
        .btn-hero .material-symbols-outlined { font-size: 18px; }
        .hero-stats { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; position: relative; z-index: 1; }
        .hero-stat { background: rgba(255,255,255,.1); border: 1px solid rgba(255,255,255,.16); border-radius: 14px; padding: 12px 14px; }
        .hs-label { font-size: 11px; font-weight: 700; letter-spacing: .06em; text-transform: uppercase; opacity: .75; }
        .hs-value { margin-top: 4px; font-family: var(--font-display); font-size: 19px; font-weight: 700; white-space: nowrap; }

        .bank-card { background: linear-gradient(145deg, #FFFFFF, #FBEFE4); border: 1px solid var(--border-color); border-radius: 20px; padding: 22px; box-shadow: var(--dash-shadow-sm); display: flex; flex-direction: column; gap: 6px; }
        .bank-card-head { display: flex; align-items: center; justify-content: space-between; color: var(--text-dim); }
        .bank-card-label { font-size: 11.5px; font-weight: 700; letter-spacing: .06em; text-transform: uppercase; }
        .bank-card-name { font-family: var(--font-display); font-size: 20px; font-weight: 700; color: var(--text-main); margin-top: 10px; }
        .bank-card-number { font-family: 'Courier New', monospace; font-size: 20px; font-weight: 700; letter-spacing: .12em; color: var(--primary-dark); word-break: break-all; }
        .bank-card-holder-label { margin-top: 10px; font-size: 11px; font-weight: 700; letter-spacing: .06em; text-transform: uppercase; color: var(--text-dim); }
        .bank-card-holder { font-weight: 700; color: var(--text-main); text-transform: uppercase; }
        .bank-card-edit { margin-top: auto; padding-top: 12px; font-size: 12.5px; font-weight: 700; color: var(--primary); text-decoration: underline; }
        .bank-card-empty { margin-top: 12px; font-size: 13.5px; color: var(--text-muted); line-height: 1.6; }

        .wallet-grid { display: grid; grid-template-columns: minmax(0, 1fr) 360px; gap: 24px; align-items: start; }
        .wallet-grid .section-card { margin-bottom: 0; }
        .wallet-grid .form-row { grid-template-columns: 1fr; }
        .wallet-grid #withdraw-section { position: sticky; top: 0; }
        .wd-dest { font-size: 12.5px; color: var(--text-muted); background: var(--bg-input); border-radius: 12px; padding: 10px 12px; margin-bottom: 14px; }
        .info-box { background: #FFF6EE; border-color: #F5D9C3; color: #8A4B1F; }
        .tb-icon-sm { font-size: 20px; color: var(--primary); vertical-align: middle; }
        .section-card-header h3 { font-family: var(--font-display); font-size: 16px; }
        @media (max-width: 1180px) {
            .wallet-top, .wallet-grid { grid-template-columns: 1fr; }
            .wallet-grid #withdraw-section { position: static; }
        }
        @media (max-width: 560px) {
            .hero-stats { grid-template-columns: 1fr; }
            .wallet-balance-amount { font-size: 34px; }
        }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="/shop/vi-tien" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">account_balance_wallet</span> Ví tiền Shop</h1>
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

        <c:if test="${param.success eq '1'}">
            <div class="alert alert-success">✅ Yêu cầu rút tiền đã được gửi! Admin sẽ xử lý trong 1-2 ngày làm việc.</div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">⚠️ ${error}</div>
        </c:if>

        <c:set var="pendingTotal" value="0"/>
        <c:forEach var="w" items="${withdrawals}">
            <c:if test="${w.status eq 'PENDING'}">
                <c:set var="pendingTotal" value="${pendingTotal + w.amount}"/>
            </c:if>
        </c:forEach>

        <div class="wallet-top">
            <%-- Thẻ ví: số dư + 3 chỉ số tổng hợp từ ví thật --%>
            <div class="wallet-hero">
                <div class="wallet-hero-row">
                    <div class="wallet-balance-section">
                        <div class="wallet-balance-label">Số dư khả dụng</div>
                        <div class="wallet-balance-amount">
                            <span>₫</span><fmt:formatNumber value="${wallet.balance}" pattern="#,##0"/>
                        </div>
                        <div class="wallet-chip">💳 <c:out value="${shop.shopName}"/></div>
                    </div>
                    <div class="wallet-actions-hero">
                        <a href="#withdraw-section" class="btn-hero btn-hero-primary"><span class="material-symbols-outlined">south</span> Rút tiền</a>
                        <a href="#history-section" class="btn-hero btn-hero-outline"><span class="material-symbols-outlined">history</span> Lịch sử</a>
                    </div>
                </div>
                <div class="hero-stats">
                    <div class="hero-stat">
                        <div class="hs-label">Tổng đã thu về</div>
                        <div class="hs-value">₫<fmt:formatNumber value="${wallet.totalEarned}" pattern="#,##0"/></div>
                    </div>
                    <div class="hero-stat">
                        <div class="hs-label">Tổng đã rút</div>
                        <div class="hs-value">₫<fmt:formatNumber value="${wallet.totalWithdrawn}" pattern="#,##0"/></div>
                    </div>
                    <div class="hero-stat">
                        <div class="hs-label">Đang chờ duyệt</div>
                        <div class="hs-value">₫<fmt:formatNumber value="${pendingTotal}" pattern="#,##0"/></div>
                    </div>
                </div>
            </div>

            <%-- Tài khoản ngân hàng nhận tiền (thông tin đã lưu ở hồ sơ shop) --%>
            <div class="bank-card">
                <div class="bank-card-head">
                    <span class="bank-card-label">Tài khoản nhận tiền</span>
                    <span class="material-symbols-outlined">account_balance</span>
                </div>
                <c:choose>
                    <c:when test="${shop.hasBankInfo}">
                        <div class="bank-card-name"><c:out value="${shop.bankNameDisplay}"/></div>
                        <div class="bank-card-number"><c:out value="${shop.bankAccountNumber}"/></div>
                        <div class="bank-card-holder-label">Chủ tài khoản</div>
                        <div class="bank-card-holder"><c:out value="${shop.bankAccountName}"/></div>
                        <a href="${pageContext.request.contextPath}/shop/profile#bankInfoSection" class="bank-card-edit">Đổi tài khoản (cần OTP)</a>
                    </c:when>
                    <c:otherwise>
                        <div class="bank-card-empty">Bạn chưa cập nhật thông tin ngân hàng nhận tiền.</div>
                        <a href="${pageContext.request.contextPath}/shop/profile#bankInfoSection" class="bank-card-edit">Cập nhật ngay</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="wallet-grid">
        <%-- Transaction History --%>
        <div class="section-card" id="history-section">
            <div class="section-card-header">
                <h3>📄 Lịch sử giao dịch</h3>
                <c:if test="${totalPages > 1}">
                    <span style="font-size:12px;color:var(--text-muted)">Trang ${currentPage}/${totalPages}</span>
                </c:if>
            </div>
            <div class="section-card-body">
                <c:choose>
                    <c:when test="${empty transactions}">
                        <div class="empty-state">Chưa có giao dịch nào</div>
                    </c:when>
                    <c:otherwise>
                        <div style="overflow-x:auto">
                        <table class="tx-table">
                            <thead>
                                <tr>
                                    <th>Loại</th>
                                    <th>Số tiền</th>
                                    <th>Mô tả</th>
                                    <th>Đơn #</th>
                                    <th>Thời gian</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="tx" items="${transactions}">
                                    <tr>
                                        <td>
                                            <span class="tx-type ${tx.type}">
                                                <c:choose>
                                                    <c:when test="${tx.type eq 'EARNING'}">💵 Thu nhập</c:when>
                                                    <c:when test="${tx.type eq 'WITHDRAWAL'}">🏦 Rút tiền</c:when>
                                                    <c:otherwise>↩️ Hoàn tiền</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="tx-amount ${tx.amount >= 0 ? 'positive' : 'negative'}">
                                                ${tx.amount >= 0 ? '+' : ''}₫<fmt:formatNumber value="${tx.amount}" pattern="#,##0"/>
                                            </span>
                                        </td>
                                        <td style="max-width:280px;font-size:12.5px;color:var(--text-muted)">${tx.description}</td>
                                        <td>
                                            <c:if test="${not empty tx.orderId}">
                                                <a href="${pageContext.request.contextPath}/shop/bills?action=view&orderId=${tx.orderId}" style="color:var(--primary);font-weight:700">#${tx.orderId}</a>
                                            </c:if>
                                        </td>
                                        <td style="font-size:12px;color:var(--text-muted);white-space:nowrap">
                                            <c:set var="txCreatedAt" value="${tx.createdAt}"/>
                                            ${fn:substring(txCreatedAt,8,10)}/${fn:substring(txCreatedAt,5,7)}/${fn:substring(txCreatedAt,0,4)} ${fn:substring(txCreatedAt,11,16)}
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                        </div>
                        <c:if test="${totalPages > 1}">
                            <div class="pager">
                                <c:if test="${currentPage > 1}">
                                    <a href="?page=${currentPage - 1}">← Trước</a>
                                </c:if>
                                <c:forEach begin="1" end="${totalPages}" var="p">
                                    <a href="?page=${p}" class="${p eq currentPage ? 'active' : ''}">${p}</a>
                                </c:forEach>
                                <c:if test="${currentPage < totalPages}">
                                    <a href="?page=${currentPage + 1}">Sau →</a>
                                </c:if>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <%-- Withdrawal Form --%>
        <div class="section-card" id="withdraw-section">
            <div class="section-card-header">
                <h3><span class="material-symbols-outlined tb-icon-sm">south</span> Yêu cầu rút tiền</h3>
            </div>
            <div class="withdraw-form">
                <div class="info-box">
                    💡 Tiền sẽ được chuyển khoản đến tài khoản ngân hàng của bạn trong <strong>1-2 ngày làm việc</strong> sau khi admin duyệt. Số tiền rút tối thiểu <strong>100.000đ</strong>.
                </div>

                <c:choose>
                    <c:when test="${not shop.hasBankInfo}">
                        <div class="info-box" style="background:#fff3cd;border-color:#ffc107;color:#856404;">
                            ⚠️ Bạn chưa cập nhật thông tin ngân hàng nhận tiền.
                            <a href="${pageContext.request.contextPath}/shop/profile#bankInfoSection" style="font-weight:700;text-decoration:underline;">Cập nhật ngay</a>
                            để có thể gửi yêu cầu rút tiền.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="wd-dest">Tiền được chuyển đến <strong><c:out value="${shop.bankNameDisplay}"/></strong> · <c:out value="${shop.bankAccountNumber}"/> (<c:out value="${shop.bankAccountName}"/>)</div>

                        <form method="post" action="${pageContext.request.contextPath}/shop/vi-tien">
                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Số tiền muốn rút (VNĐ) *</label>
                                    <input type="text" name="amount" data-money="true"
                                           placeholder="Ví dụ: 500.000" required/>
                                    <div class="amount-hint">Số dư khả dụng: ₫<fmt:formatNumber value="${wallet.balance}" pattern="#,##0"/></div>
                                </div>
                            </div>
                            <button type="submit" class="submit-btn">Gửi yêu cầu rút tiền</button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        </div>

        <%-- Withdrawal History --%>
        <div class="section-card">
            <div class="section-card-header">
                <h3>📊 Lịch sử yêu cầu rút tiền</h3>
            </div>
            <div class="section-card-body">
                <c:choose>
                    <c:when test="${empty withdrawals}">
                        <div class="empty-state">Chưa có yêu cầu rút tiền nào</div>
                    </c:when>
                    <c:otherwise>
                        <div style="overflow-x:auto">
                        <table class="tx-table">
                            <thead>
                                <tr>
                                    <th>Thời gian</th>
                                    <th>Số tiền</th>
                                    <th>Ngân hàng</th>
                                    <th>Số TK</th>
                                    <th>Chủ TK</th>
                                    <th>Trạng thái</th>
                                    <th>Ghi chú</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="wd" items="${withdrawals}">
                                    <tr>
                                        <td style="font-size:12px;white-space:nowrap">
                                            <c:set var="wdRequestedAt" value="${wd.requestedAt}"/>
                                            ${fn:substring(wdRequestedAt,8,10)}/${fn:substring(wdRequestedAt,5,7)}/${fn:substring(wdRequestedAt,0,4)} ${fn:substring(wdRequestedAt,11,16)}
                                        </td>
                                        <td style="font-weight:700;color:#dc2626">-₫<fmt:formatNumber value="${wd.amount}" pattern="#,##0"/></td>
                                        <td>${wd.bankName}</td>
                                        <td style="font-family:monospace">${wd.bankAccountNumber}</td>
                                        <td>${wd.bankAccountHolder}</td>
                                        <td><span class="badge-status ${wd.status}">
                                            <c:choose>
                                                <c:when test="${wd.status eq 'PENDING'}">⏳ Đang duyệt</c:when>
                                                <c:when test="${wd.status eq 'APPROVED'}">✅ Đã duyệt</c:when>
                                                <c:otherwise>❌ Từ chối</c:otherwise>
                                            </c:choose>
                                        </span></td>
                                        <td style="font-size:12px;color:var(--text-muted)">
                                            <c:if test="${not empty wd.rejectReason}">${wd.rejectReason}</c:if>
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
<script src="${pageContext.request.contextPath}/assets/js/money-format.js"></script>
<script>
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
</script>
</body>
</html>
