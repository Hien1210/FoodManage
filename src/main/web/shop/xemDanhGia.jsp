<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 2}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xem đánh giá - POB Shop</title>
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

        /* Đặc thù trang đánh giá: banner tổng quan sao + tabs + card đánh giá */
        .overview-card { background: var(--brand-gradient, linear-gradient(120deg, var(--primary) 0%, var(--danger) 100%)); border-radius: var(--radius-lg); padding: 24px 28px; color: #fff; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; box-shadow: var(--dash-shadow-md); }
        .overview-rating { font-size: 52px; font-weight: 900; line-height: 1; }
        .overview-stars { display: flex; gap: 4px; margin: 6px 0; font-size: 20px; }
        .overview-count { font-size: 13px; opacity: .88; }
        .overview-info h2 { font-size: 20px; font-weight: 800; margin-bottom: 4px; }
        .overview-info p { font-size: 13px; opacity: .88; }
        .overview-emoji { font-size: 52px; }

        .tab-bar { display: flex; border-bottom: 1px solid var(--border-color); }
        .tab-btn { flex: 1; padding: 16px; font-size: 14px; font-weight: 600; color: var(--text-muted); background: none; border: none; cursor: pointer; border-bottom: 3px solid transparent; transition: all .2s; display: flex; align-items: center; justify-content: center; gap: 8px; }
        .tab-btn:hover { color: var(--primary-dark); background: var(--bg-hover); }
        .tab-btn.active { color: var(--primary-dark); border-bottom-color: var(--primary); background: var(--primary-light); font-weight: 700; }
        .tab-badge { font-size: 11px; padding: 2px 8px; border-radius: 12px; font-weight: 700; }
        .tab-badge.blue { background: var(--info-light); color: var(--info-dark); }
        .tab-badge.green { background: var(--success-light); color: var(--success-dark); }

        .tab-panel { display: none; padding: 24px; }
        .tab-panel.active { display: block; }

        /* REVIEW CARD */
        .review-list { display: flex; flex-direction: column; gap: 14px; }
        .review-card { background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 12px; padding: 18px; transition: all .2s; }
        .review-card:hover { background: var(--bg-hover); box-shadow: var(--dash-shadow-sm); }
        .review-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 10px; }
        .reviewer-info { display: flex; align-items: center; gap: 10px; }
        .reviewer-avatar { width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 15px; flex-shrink: 0; }
        .reviewer-avatar.user-type { background: var(--info-light); color: var(--info-dark); }
        .reviewer-avatar.shipper-type { background: var(--success-light); color: var(--success-dark); }
        .reviewer-name { font-size: 14px; font-weight: 700; color: var(--text-main); }
        .reviewer-order { font-size: 12px; color: var(--text-muted); }
        .review-meta { display: flex; align-items: center; gap: 8px; }
        .stars { display: flex; gap: 2px; font-size: 15px; }
        .star-filled { color: var(--warning); }
        .star-empty { color: var(--border-color); }
        .review-date { font-size: 12px; color: var(--text-dim); }
        .review-comment { font-size: 13.5px; color: var(--text-main); line-height: 1.65; padding-top: 4px; }

        /* Bố cục tổng quan theo bản Stitch: điểm uy tín + phân bổ sao + tổng quan phản hồi */
        .rv-top { display: grid; grid-template-columns: 1.1fr 1.4fr 1fr; gap: 20px; }
        .rv-top .panel { padding: 22px; animation: none; }
        .rv-eyebrow { font-size: 11.5px; font-weight: 700; letter-spacing: .06em; text-transform: uppercase; color: var(--text-dim); margin-bottom: 12px; }
        .rv-score-row { display: flex; align-items: baseline; gap: 8px; }
        .rv-score-num { font-family: var(--font-display); font-size: 52px; font-weight: 700; color: var(--primary); line-height: 1; }
        .rv-score-max { font-size: 16px; color: var(--text-dim); font-weight: 600; }
        .rv-score .overview-stars { margin: 8px 0; font-size: 22px; }
        .rv-score-sub { font-size: 13px; color: var(--text-muted); line-height: 1.55; }
        .rv-bar-row { display: flex; align-items: center; gap: 10px; margin-bottom: 9px; font-size: 13px; }
        .rv-bar-label { width: 38px; font-weight: 700; color: var(--text-main); }
        .rv-bar { flex: 1; height: 9px; border-radius: 999px; background: var(--bg-input); overflow: hidden; }
        .rv-bar-fill { height: 100%; border-radius: 999px; background: var(--brand-gradient); }
        .rv-bar-fill.low { background: var(--danger); }
        .rv-bar-count { width: 34px; text-align: right; color: var(--text-muted); font-weight: 700; }
        .rv-sum-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px dashed var(--border-color); font-size: 13.5px; color: var(--text-muted); }
        .rv-sum-row strong { color: var(--text-main); }
        .rv-sum-row.warn strong { color: var(--danger-dark); }
        .rv-sum-hint { margin-top: 10px; font-size: 12.5px; color: var(--text-muted); line-height: 1.55; }
        .rv-filters { display: flex; gap: 8px; flex-wrap: wrap; padding: 16px 24px 0; }
        .rv-chip { display: inline-flex; align-items: center; gap: 8px; padding: 6px 14px; border-radius: 999px; border: 1px solid var(--border-color); background: var(--bg-panel); color: var(--text-muted); font-size: 12.5px; font-weight: 700; cursor: pointer; font-family: inherit; }
        .rv-chip:hover { border-color: var(--primary); color: var(--primary); }
        .rv-chip.active { background: var(--primary); border-color: var(--primary); color: #fff; box-shadow: 0 8px 20px rgba(227, 37, 10, .25); }
        .rv-chip-count { font-size: 11px; font-weight: 800; padding: 1px 8px; border-radius: 999px; background: var(--bg-input); color: var(--text-main); }
        .rv-chip.active .rv-chip-count { background: rgba(255, 255, 255, .25); color: #fff; }
        .review-card { background: var(--bg-panel); border-radius: 16px; }
        .review-card.rv-low { border-left: 4px solid var(--danger); }
        .rv-empty { display: none; text-align: center; padding: 30px 10px; color: var(--text-muted); font-size: 13.5px; }
        @media (max-width: 1100px) { .rv-top { grid-template-columns: 1fr; } }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="/shop/danh-gia" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">rate_review</span> Xem đánh giá</h1>
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

        <%-- Phân bổ sao tính từ danh sách đánh giá thật (khách hàng + shipper) --%>
        <c:set var="cnt1" value="0"/><c:set var="cnt2" value="0"/><c:set var="cnt3" value="0"/><c:set var="cnt4" value="0"/><c:set var="cnt5" value="0"/>
        <c:forEach items="${feedbackUser}" var="x">
            <c:choose>
                <c:when test="${x.rating == 5}"><c:set var="cnt5" value="${cnt5 + 1}"/></c:when>
                <c:when test="${x.rating == 4}"><c:set var="cnt4" value="${cnt4 + 1}"/></c:when>
                <c:when test="${x.rating == 3}"><c:set var="cnt3" value="${cnt3 + 1}"/></c:when>
                <c:when test="${x.rating == 2}"><c:set var="cnt2" value="${cnt2 + 1}"/></c:when>
                <c:when test="${x.rating == 1}"><c:set var="cnt1" value="${cnt1 + 1}"/></c:when>
            </c:choose>
        </c:forEach>
        <c:forEach items="${feedbackShipper}" var="x">
            <c:choose>
                <c:when test="${x.rating == 5}"><c:set var="cnt5" value="${cnt5 + 1}"/></c:when>
                <c:when test="${x.rating == 4}"><c:set var="cnt4" value="${cnt4 + 1}"/></c:when>
                <c:when test="${x.rating == 3}"><c:set var="cnt3" value="${cnt3 + 1}"/></c:when>
                <c:when test="${x.rating == 2}"><c:set var="cnt2" value="${cnt2 + 1}"/></c:when>
                <c:when test="${x.rating == 1}"><c:set var="cnt1" value="${cnt1 + 1}"/></c:when>
            </c:choose>
        </c:forEach>
        <c:set var="rvTotal" value="${cnt1 + cnt2 + cnt3 + cnt4 + cnt5}"/>
        <c:set var="rvLow" value="${cnt1 + cnt2}"/>

        <div class="rv-top">
            <div class="panel rv-score">
                <div class="rv-eyebrow">Chỉ số uy tín cửa hàng</div>
                <div class="rv-score-row">
                    <span class="rv-score-num"><c:choose><c:when test="${rvTotal > 0}"><fmt:formatNumber value="${avgRating}" maxFractionDigits="1"/></c:when><c:otherwise>—</c:otherwise></c:choose></span>
                    <span class="rv-score-max">/ 5.0</span>
                </div>
                <div class="overview-stars">
                    <c:forEach begin="1" end="5" var="i">
                        <span class="${i <= avgRating ? 'star-filled' : 'star-empty'}">★</span>
                    </c:forEach>
                </div>
                <div class="rv-score-sub">${totalFeedback} đánh giá từ khách hàng và shipper của <strong><c:out value="${shop.shopName}"/></strong></div>
            </div>

            <div class="panel rv-dist">
                <div class="rv-eyebrow">Phân bổ sao đánh giá</div>
                <c:forEach begin="1" end="5" var="k">
                    <c:set var="star" value="${6 - k}"/>
                    <c:choose>
                        <c:when test="${star == 5}"><c:set var="sc" value="${cnt5}"/></c:when>
                        <c:when test="${star == 4}"><c:set var="sc" value="${cnt4}"/></c:when>
                        <c:when test="${star == 3}"><c:set var="sc" value="${cnt3}"/></c:when>
                        <c:when test="${star == 2}"><c:set var="sc" value="${cnt2}"/></c:when>
                        <c:otherwise><c:set var="sc" value="${cnt1}"/></c:otherwise>
                    </c:choose>
                    <div class="rv-bar-row">
                        <span class="rv-bar-label">${star} <span class="star-filled">★</span></span>
                        <div class="rv-bar"><div class="rv-bar-fill ${star <= 2 ? 'low' : ''}" style="width:${rvTotal > 0 ? sc * 100 / rvTotal : 0}%;"></div></div>
                        <span class="rv-bar-count">${sc}</span>
                    </div>
                </c:forEach>
            </div>

            <div class="panel rv-summary">
                <div class="rv-eyebrow">Tổng quan phản hồi</div>
                <div class="rv-sum-row"><span>Từ khách hàng</span><strong>${fn:length(feedbackUser)}</strong></div>
                <div class="rv-sum-row"><span>Từ shipper</span><strong>${fn:length(feedbackShipper)}</strong></div>
                <div class="rv-sum-row ${rvLow > 0 ? 'warn' : ''}"><span>Đánh giá 1–2 sao</span><strong>${rvLow}</strong></div>
                <div class="rv-sum-hint"><c:choose>
                    <c:when test="${rvLow > 0}">Có ${rvLow} đánh giá thấp — nên xem lại đơn và phản hồi khách sớm.</c:when>
                    <c:otherwise>Chưa có đánh giá thấp. Hãy tiếp tục giữ chất lượng!</c:otherwise>
                </c:choose></div>
            </div>
        </div>

        <!-- Tab panel -->
        <div class="panel">
            <div class="tab-bar">
                <button class="tab-btn active" onclick="switchTab('user')" id="tab-user">
                    👤 Từ Khách hàng
                    <span class="tab-badge blue">${feedbackUser.size()}</span>
                </button>
                <button class="tab-btn" onclick="switchTab('shipper')" id="tab-shipper">
                    🛵 Từ Shipper
                    <span class="tab-badge green">${feedbackShipper.size()}</span>
                </button>
            </div>

            <div class="rv-filters" id="rvFilters">
                <button type="button" class="rv-chip active" data-rating="">Tất cả <span class="rv-chip-count">${rvTotal}</span></button>
                <button type="button" class="rv-chip" data-rating="5">5 sao <span class="rv-chip-count">${cnt5}</span></button>
                <button type="button" class="rv-chip" data-rating="4">4 sao <span class="rv-chip-count">${cnt4}</span></button>
                <button type="button" class="rv-chip" data-rating="3">3 sao <span class="rv-chip-count">${cnt3}</span></button>
                <button type="button" class="rv-chip" data-rating="2">2 sao <span class="rv-chip-count">${cnt2}</span></button>
                <button type="button" class="rv-chip" data-rating="1">1 sao <span class="rv-chip-count">${cnt1}</span></button>
            </div>

            <!-- Tab User -->
            <div class="tab-panel active" id="panel-user">
                <c:choose>
                    <c:when test="${empty feedbackUser}">
                        <div class="empty-state">
                            <div class="e-icon">💬</div>
                            <div class="e-title">Chưa có đánh giá từ khách hàng</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="review-list">
                            <c:forEach var="fb" items="${feedbackUser}">
                                <div class="review-card ${fb.rating <= 2 ? 'rv-low' : ''}" data-rating="${fb.rating}">
                                    <div class="review-header">
                                        <div class="reviewer-info">
                                            <div class="reviewer-avatar user-type">
                                                ${fb.anonymous ? '?' : fn:toUpperCase(fn:substring(fn:escapeXml(fb.reviewerName), 0, 1))}
                                            </div>
                                            <div>
                                                <div class="reviewer-name">${fb.anonymous ? 'Ẩn danh' : fn:escapeXml(fb.reviewerName)}</div>
                                                <div class="reviewer-order">Đơn #${fb.orderId}</div>
                                            </div>
                                        </div>
                                        <div class="review-meta">
                                            <div class="stars">
                                                <c:forEach begin="1" end="5" var="i">
                                                    <span class="${i <= fb.rating ? 'star-filled' : 'star-empty'}">★</span>
                                                </c:forEach>
                                            </div>
                                            <span class="review-date">
                                                ${fb.createdAt.dayOfMonth}/${fb.createdAt.monthValue}/${fb.createdAt.year}
                                            </span>
                                        </div>
                                    </div>
                                    <c:if test="${not empty fb.comment}">
                                        <div class="review-comment">${fn:escapeXml(fb.comment)}</div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Tab Shipper -->
            <div class="tab-panel" id="panel-shipper">
                <c:choose>
                    <c:when test="${empty feedbackShipper}">
                        <div class="empty-state">
                            <div class="e-icon">🛵</div>
                            <div class="e-title">Chưa có đánh giá từ shipper</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="review-list">
                            <c:forEach var="fb" items="${feedbackShipper}">
                                <div class="review-card ${fb.rating <= 2 ? 'rv-low' : ''}" data-rating="${fb.rating}">
                                    <div class="review-header">
                                        <div class="reviewer-info">
                                            <div class="reviewer-avatar shipper-type">
                                                ${fn:toUpperCase(fn:substring(fn:escapeXml(fb.reviewerName), 0, 1))}
                                            </div>
                                            <div>
                                                <div class="reviewer-name">${fn:escapeXml(fb.reviewerName)}</div>
                                                <div class="reviewer-order">Đơn #${fb.orderId}</div>
                                            </div>
                                        </div>
                                        <div class="review-meta">
                                            <div class="stars">
                                                <c:forEach begin="1" end="5" var="i">
                                                    <span class="${i <= fb.rating ? 'star-filled' : 'star-empty'}">★</span>
                                                </c:forEach>
                                            </div>
                                            <span class="review-date">
                                                ${fb.createdAt.dayOfMonth}/${fb.createdAt.monthValue}/${fb.createdAt.year}
                                            </span>
                                        </div>
                                    </div>
                                    <c:if test="${not empty fb.comment}">
                                        <div class="review-comment">${fn:escapeXml(fb.comment)}</div>
                                    </c:if>
                                </div>
                            </c:forEach>
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
<script>
    function switchTab(tab) {
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
        document.getElementById('tab-' + tab).classList.add('active');
        document.getElementById('panel-' + tab).classList.add('active');
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
        var chips = document.getElementById('rvFilters');
        if (!chips) return;
        chips.addEventListener('click', function (e) {
            var btn = e.target.closest('.rv-chip');
            if (!btn) return;
            chips.querySelectorAll('.rv-chip').forEach(function (b) { b.classList.toggle('active', b === btn); });
            var rating = btn.getAttribute('data-rating');
            document.querySelectorAll('.tab-panel').forEach(function (panel) {
                var cards = panel.querySelectorAll('.review-card');
                var shown = 0;
                cards.forEach(function (c) {
                    var ok = !rating || c.getAttribute('data-rating') === rating;
                    c.style.display = ok ? '' : 'none';
                    if (ok) shown++;
                });
                var note = panel.querySelector('.rv-empty');
                if (!note && cards.length) {
                    note = document.createElement('div');
                    note.className = 'rv-empty';
                    note.textContent = 'Không có đánh giá nào ở mức sao này.';
                    panel.appendChild(note);
                }
                if (note) note.style.display = (cards.length && shown === 0) ? 'block' : 'none';
            });
        });
    })();
</script>
</body>
</html>
