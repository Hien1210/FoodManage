<%@ page pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib uri="/app-functions" prefix="app" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Đơn hàng của tôi - FOOD MANAGE</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user-theme.css">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/orderTrackingMap.js"></script>
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
    --success: #15803D; --warning: #C2660A; --info: #1D4ED8; --danger: #E11D48;
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
}
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
.container { max-width: 840px; margin: 0 auto; padding: 44px 20px 80px; }

/* ALERTS */
.alert {
    display: flex; align-items: center; gap: 10px;
    padding: 14px 18px; margin-bottom: 20px; border-radius: 14px;
    border: 1px solid; font-size: .9rem; font-weight: 600;
}
.alert-success { background: #EAFBF1; border-color: #BBF0CF; color: #15803D; }
.alert-danger  { background: #FEECEF; border-color: #FBD0D8; color: #E11D48; }

/* SECTION HEADER */
.section-header { margin-bottom: 22px; display: flex; flex-wrap: wrap; justify-content: space-between; align-items: flex-end; gap: 16px; }
.section-header h2 { font-family: var(--font-h); font-size: 1.9rem; color: var(--text); letter-spacing: -.5px; }
.section-header .sub { font-size: .88rem; color: var(--muted); margin-top: 4px; font-weight: 500; }
.stats-row { display: flex; gap: 10px; }
.stat-pill { background: var(--surface); border: 1px solid var(--border); border-radius: 14px; padding: 10px 16px; box-shadow: 0 2px 10px rgba(99,44,20,.05); display: flex; align-items: center; gap: 10px; }
.stat-pill .ic { width: 34px; height: 34px; border-radius: 10px; background: #FFF2F0; color: var(--gold); display: flex; align-items: center; justify-content: center; font-size: .95rem; flex-shrink: 0; }
.stat-pill strong { display: block; font-family: var(--font-h); font-size: 1.15rem; font-weight: 800; color: var(--text); line-height: 1.1; }
.stat-pill span { font-size: .72rem; color: var(--muted); font-weight: 600; }

/* STATUS FILTER TABS */
.filter-tabs { display: flex; gap: 8px; overflow-x: auto; margin-bottom: 22px; padding-bottom: 2px; }
.filter-tab { flex-shrink: 0; display: inline-flex; align-items: center; gap: 6px; padding: 9px 18px; border-radius: 50px; font-size: .82rem; font-weight: 700; color: var(--muted); background: var(--surface); border: 1.5px solid var(--border); cursor: pointer; transition: var(--tr); font-family: var(--font-b); }
.filter-tab:hover { border-color: var(--gold); color: var(--gold); }
.filter-tab.active { background: linear-gradient(135deg, var(--gold), var(--gold-hover)); color: #fff; border-color: transparent; box-shadow: 0 6px 16px rgba(255,59,31,.28); }
.filter-tab .count { font-size: .7rem; background: rgba(0,0,0,.08); padding: 1px 7px; border-radius: 50px; }
.filter-tab.active .count { background: rgba(255,255,255,.25); }

/* EMPTY */
.empty-state {
    text-align: center; padding: 70px 24px; border-radius: 22px;
    background: var(--surface); border: 1px dashed var(--border);
}
.empty-state img { width: 90px; height: 90px; margin-bottom: 18px; filter: drop-shadow(0 12px 18px rgba(99,44,20,.2)); animation: donhang-float 4s ease-in-out infinite; }
@keyframes donhang-float { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }
.empty-state h3 { font-family: var(--font-h); font-size: 1.3rem; color: var(--text); margin-bottom: 8px; }
.empty-state p { font-size: .9rem; color: var(--muted); }
.link-gold { color: var(--gold); font-weight: 700; }
.link-gold:hover { color: var(--gold-hover); text-decoration: underline; }

/* ORDER LIST */
.order-list { display: flex; flex-direction: column; gap: 20px; }
.order-card {
    background: var(--surface); border: 1.5px solid var(--border); border-radius: 20px;
    transition: var(--tr); padding: 24px;
    box-shadow: 0 2px 12px rgba(99,44,20,.05);
}
.order-card:hover { border-color: var(--gold); box-shadow: var(--shadow); transform: translateY(-2px); }

.order-top { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 14px; flex-wrap: wrap; gap: 10px; }
.order-id { font-family: var(--font-h); font-size: 1.15rem; color: var(--text); font-weight: 800; }
.order-shop { font-size: .85rem; color: var(--gold); margin-top: 3px; font-weight: 700; }

/* BADGE */
.badge {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 6px 14px; font-size: .75rem; font-weight: 700; border-radius: 50px;
    letter-spacing: .2px; border: 1px solid;
    font-family: var(--font-b);
}
.badge-pending  { border-color: #FFDCB0; color: #C2660A; background: #FFF3E0; }
.badge-warning  { border-color: #FFDCB0; color: #C2660A; background: #FFF3E0; }
.badge-info     { border-color: #C4D7FC; color: #1D4ED8; background: #EAF1FE; }
.badge-primary  { border-color: #FFC7BE; color: var(--gold); background: #FFF2F0; }
.badge-success  { border-color: #BBF0CF; color: #15803D; background: #EAFBF1; }
.badge-danger   { border-color: #FBD0D8; color: #E11D48; background: #FEECEF; }
.badge-neutral  { border-color: var(--border);  color: var(--muted);   background: var(--surface-lt); }

.order-meta { display: flex; flex-direction: column; gap: 6px; margin-bottom: 16px; }
.order-meta-row { display: flex; align-items: center; gap: 8px; font-size: .85rem; color: var(--muted); font-weight: 500; }
.order-meta-row i { color: var(--gold); width: 14px; font-size: .8rem; }
.order-price { font-size: 1rem; font-weight: 700; color: var(--text); margin-bottom: 18px; }
.order-price span { color: var(--gold); font-family: var(--font-h); font-size: 1.15rem; font-weight: 800; }

.divider { height: 1px; background: var(--border); margin-bottom: 18px; }

/* TRACKING MAP */
.shop-marker-icon { background: none; border: none; font-size: 22px; line-height: 24px; text-align: center; }
.tracking-map-wrap { position: relative; margin-bottom: 18px; border-radius: 18px; overflow: hidden; box-shadow: 0 8px 24px rgba(99,44,20,.12); }
.tracking-map { height: 320px; }
.tracking-gps-badge {
    position: absolute; top: 12px; right: 12px; z-index: 500;
    display: flex; align-items: center; gap: 6px;
    background: rgba(255,255,255,.95); backdrop-filter: blur(6px);
    padding: 6px 12px; border-radius: 50px; box-shadow: 0 4px 14px rgba(99,44,20,.18);
    font-size: .72rem; font-weight: 800; color: var(--gold);
}

/* FEEDBACK BUTTONS */
.fb-row { display: flex; gap: 10px; flex-wrap: wrap; }
.btn-fb {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 9px 18px; font-size: .8rem; font-weight: 700; border-radius: 50px;
    cursor: pointer; border: 1.5px solid; transition: var(--tr);
    font-family: var(--font-b);
    background: transparent; text-decoration: none;
}
.btn-fb-shop    { border-color: #FFDCB0; color: #C2660A; }
.btn-fb-shop:hover    { background: #FFF3E0; }
.btn-fb-shipper { border-color: #C4D7FC; color: #1D4ED8; }
.btn-fb-shipper:hover { background: #EAF1FE; }
.btn-fb-done    { border-color: var(--border); color: var(--muted); cursor: default; background: var(--surface-lt); }

/* TRACKING STEPPER STYLES */
.tracking-stepper-box {
    background: var(--surface-lt); border: 1px solid var(--border);
    border-radius: 16px; padding: 18px 20px; margin: 16px 0;
}
.stepper-title {
    display: flex; justify-content: space-between; align-items: center;
    font-size: 13px; font-weight: 700; color: var(--text); margin-bottom: 16px;
}
.live-pulse { display: inline-flex; align-items: center; gap: 6px; font-size: 11.5px; color: #10B981; font-weight: 700; }
.pulse-dot { width: 8px; height: 8px; border-radius: 50%; background: #10B981; animation: pobPulse 1.5s infinite; }
@keyframes pobPulse { 0% { box-shadow: 0 0 0 0 rgba(16,185,129,.7); } 70% { box-shadow: 0 0 0 8px rgba(16,185,129,0); } 100% { box-shadow: 0 0 0 0 rgba(16,185,129,0); } }

.tracking-stepper {
    display: flex; justify-content: space-between; align-items: flex-start;
    position: relative; padding: 0 4px;
}
.tracking-stepper::before {
    content: ''; position: absolute; top: 16px; left: 24px; right: 24px;
    height: 3px; background: #E5E7EB; z-index: 1;
}
.stepper-progress-bar {
    position: absolute; top: 16px; left: 24px;
    height: 3px; background: linear-gradient(90deg, #FF3B1F, #10B981);
    z-index: 2; transition: width .4s ease;
}
.step-item {
    position: relative; z-index: 3; display: flex; flex-direction: column;
    align-items: center; text-align: center; flex: 1;
}
.step-icon-wrap {
    width: 34px; height: 34px; border-radius: 50%; background: #FFF;
    border: 2px solid #D1D5DB; color: #9CA3AF; display: flex; align-items: center;
    justify-content: center; font-size: 12.5px; font-weight: 800;
    box-shadow: 0 2px 6px rgba(0,0,0,.06); transition: all .3s ease;
}
.step-item.completed .step-icon-wrap {
    background: #10B981; color: #FFF; border-color: #10B981;
}
.step-item.active .step-icon-wrap {
    background: #FF3B1F; color: #FFF; border-color: #FF3B1F;
    box-shadow: 0 0 0 4px rgba(255,59,31,.25); transform: scale(1.12);
}
.step-label {
    font-size: 11px; font-weight: 600; color: #6B7280; margin-top: 8px;
    line-height: 1.25; max-width: 75px;
}
.step-item.active .step-label { color: #FF3B1F; font-weight: 800; }
.step-item.completed .step-label { color: #10B981; font-weight: 700; }

.cancelled-banner {
    background: #FEECEF; border: 1px solid #FBD0D8; color: #E11D48;
    padding: 12px 16px; border-radius: 12px; font-size: 13.5px; font-weight: 700;
    display: flex; align-items: center; gap: 8px; margin: 14px 0;
}

/* CONTACT CARDS GRID */
.contacts-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin: 14px 0; }
@media (max-width: 600px) { .contacts-grid { grid-template-columns: 1fr; } }
.contact-card {
    background: var(--surface); border: 1px solid var(--border); border-radius: 14px;
    padding: 14px 16px; display: flex; flex-direction: column; justify-content: space-between; gap: 8px;
}
.contact-header { display: flex; flex-direction: column; gap: 4px; }
.contact-badge {
    font-size: 10px; font-weight: 800; text-transform: uppercase; letter-spacing: .5px;
    padding: 2px 8px; border-radius: 4px; width: fit-content;
}
.contact-badge.shop { background: #FFF3E0; color: #C2660A; }
.contact-badge.shipper { background: #EAF1FE; color: #1D4ED8; }
.contact-name { font-size: 13.5px; font-weight: 700; color: var(--text); }
.contact-sub { font-size: 11.5px; color: var(--muted); }
.btn-contact-call {
    display: inline-flex; align-items: center; justify-content: center; gap: 6px;
    padding: 7px 12px; font-size: 12px; font-weight: 700; border-radius: 8px;
    background: #15803D; color: #FFF; transition: var(--tr); text-decoration: none;
}
.btn-contact-call:hover { background: #166534; }
.btn-contact-call.shipper { background: #1D4ED8; }
.btn-contact-call.shipper:hover { background: #1E40AF; }

/* MODAL STYLES */
.order-detail-modal-backdrop {
    position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
    background: rgba(0,0,0,.5); backdrop-filter: blur(4px);
    z-index: 2000; display: none; align-items: center; justify-content: center; padding: 20px;
}
.order-detail-modal-backdrop.open { display: flex; animation: pobFadeUp .2s ease; }
@keyframes pobFadeUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
.order-detail-modal {
    background: var(--surface); border-radius: 20px; max-width: 620px; width: 100%;
    max-height: 85vh; overflow-y: auto; box-shadow: var(--shadow); border: 1px solid var(--border);
    display: flex; flex-direction: column;
}
.odm-header {
    padding: 18px 24px; border-bottom: 1px solid var(--border); background: var(--surface-lt);
    display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 10;
}
.odm-header h3 { font-family: var(--font-h); font-size: 1.2rem; color: var(--text); }
.odm-date { font-size: 11.5px; color: var(--muted); }
.odm-close { background: none; border: none; font-size: 24px; color: var(--muted); cursor: pointer; }
.odm-body { padding: 20px 24px; display: flex; flex-direction: column; gap: 20px; }
.odm-section h4 { font-size: 13px; font-weight: 800; color: var(--text); margin-bottom: 10px; display: flex; align-items: center; gap: 8px; }
.odm-section h4 i { color: var(--gold); }
.bill-items-table { border: 1px solid var(--border); border-radius: 12px; overflow: hidden; }
.bill-item-row {
    display: flex; justify-content: space-between; align-items: center;
    padding: 10px 14px; border-bottom: 1px solid var(--border); font-size: 12.5px;
}
.bill-item-row:last-child { border-bottom: none; }
.bir-name { flex: 1; }
.bir-size { font-weight: 600; color: var(--muted); font-size: 11.5px; }
.bir-toppings { font-size: 11px; color: var(--muted); margin-top: 2px; }
.bir-qty { font-weight: 700; color: var(--gold); margin: 0 16px; }
.bir-price { font-weight: 700; color: var(--text); }
.odm-summary-row { display: flex; justify-content: space-between; font-size: 12.5px; color: var(--muted); margin-bottom: 6px; }
.odm-summary-row.total { font-size: 14px; font-weight: 800; color: var(--gold); border-top: 1px dashed var(--border); padding-top: 8px; margin-top: 6px; }
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
            <a href="${pageContext.request.contextPath}/user/donhang" class="active">Đơn hàng</a>
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
                    <a href="${pageContext.request.contextPath}/user/thong-tin-ca-nhan" class="dd-link">
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
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Đánh giá của bạn đã được gửi thành công!</div>
    </c:if>
    <c:if test="${param.error eq '1'}">
        <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation"></i> Không thể gửi đánh giá. Vui lòng thử lại.</div>
    </c:if>

    <c:if test="${param.success eq 'order_cancelled'}">
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Đơn hàng đã được hủy thành công.<c:if test="${param.refund eq '1'}"> Yêu cầu hoàn tiền của bạn sẽ được xử lý sớm.</c:if></div>
    </c:if>
    <c:if test="${param.error eq 'cannot_cancel'}">
        <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation"></i> Đơn hàng này hiện không thể hủy (đã quá thời gian cho phép hoặc đã được xử lý).</div>
    </c:if>
    <c:if test="${param.error eq 'not_found'}">
        <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation"></i> Không tìm thấy đơn hàng.</div>
    </c:if>
    <c:if test="${param.error eq 'missing' or param.error eq 'server'}">
        <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation"></i> Có lỗi xảy ra khi hủy đơn. Vui lòng thử lại.</div>
    </c:if>

    <c:set var="activeOrderCount" value="0"/>
    <c:forEach var="o" items="${orders}">
        <c:if test="${o.staTus ne 'DONE' and o.staTus ne 'CANCELLED'}">
            <c:set var="activeOrderCount" value="${activeOrderCount + 1}"/>
        </c:if>
    </c:forEach>

    <div class="section-header">
        <div>
            <h2>Lịch Sử & Theo Dõi Đơn Hàng</h2>
            <p class="sub">Theo dõi tiến trình trực tiếp và chi tiết đơn hàng đã đặt</p>
        </div>
        <c:if test="${not empty orders}">
            <div class="stats-row">
                <div class="stat-pill"><span class="ic"><i class="fa-solid fa-motorcycle"></i></span><div><strong>${activeOrderCount}</strong><span>Đang thực hiện</span></div></div>
                <div class="stat-pill"><span class="ic"><i class="fa-solid fa-receipt"></i></span><div><strong>${fn:length(orders)}</strong><span>Tổng đơn</span></div></div>
            </div>
        </c:if>
    </div>

    <c:if test="${not empty orders}">
        <div class="filter-tabs" id="orderFilterTabs">
            <button type="button" class="filter-tab active" data-filter="all">Tất cả <span class="count">${fn:length(orders)}</span></button>
            <button type="button" class="filter-tab" data-filter="active">Đang thực hiện <span class="count">${activeOrderCount}</span></button>
            <button type="button" class="filter-tab" data-filter="DONE">Đã giao</button>
            <button type="button" class="filter-tab" data-filter="CANCELLED">Đã hủy</button>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty orders}">
            <div class="empty-state">
                <img src="https://cdn.jsdelivr.net/gh/microsoft/fluentui-emoji@main/assets/Package/3D/package_3d.png" alt="">
                <h3>Chưa có đơn hàng nào</h3>
                <p>Hãy khám phá các nhà hàng và đặt món ngay!</p>
                <a href="${pageContext.request.contextPath}/user/home" class="link-gold" style="display:inline-block;margin-top:16px;">
                    Khám phá ngay <i class="fa-solid fa-arrow-right"></i>
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="order-list">
                <c:forEach var="order" items="${orders}">
                    <div class="order-card" data-status="${order.staTus}">
                        <div class="order-top">
                            <div>
                                <div class="order-id">Đơn #${order.id}</div>
                                <div class="order-shop"><i class="fa-solid fa-store"></i> ${shopNames[order.shopId]}</div>
                            </div>
                            <span class="badge
                                ${order.staTus == 'PENDING' ? 'badge-warning' :
                                  order.staTus == 'WAITING_FOR_SHIPPER' ? 'badge-info' :
                                  order.staTus == 'ACCEPTED' ? 'badge-info' :
                                  order.staTus == 'READY_FOR_PICKUP' ? 'badge-primary' :
                                  order.staTus == 'SHIPPING' ? 'badge-warning' :
                                  order.staTus == 'DONE' ? 'badge-success' :
                                  order.staTus == 'CANCELLED' ? 'badge-danger' : 'badge-neutral'}">
                                <c:choose>
                                    <c:when test="${order.staTus eq 'PENDING'}">⏳ Chờ xác nhận</c:when>
                                    <c:when test="${order.staTus eq 'WAITING_FOR_SHIPPER'}">👨‍🍳 Đang chuẩn bị & Tìm tài xế</c:when>
                                    <c:when test="${order.staTus eq 'ACCEPTED'}">🛵 Tài xế đã nhận (Đang chuẩn bị)</c:when>
                                    <c:when test="${order.staTus eq 'READY_FOR_PICKUP'}">📦 Chờ shipper lấy hàng</c:when>
                                    <c:when test="${order.staTus eq 'SHIPPING'}">🛵 Đang giao</c:when>
                                    <c:when test="${order.staTus eq 'DONE'}">🎉 Đã giao</c:when>
                                    <c:when test="${order.staTus eq 'CANCELLED'}">❌ Đã huỷ</c:when>
                                    <c:otherwise>${order.staTus}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <!-- HỦY ĐƠN: chỉ khi đơn còn PENDING -->
                        <c:if test="${order.staTus eq 'PENDING'}">
                            <c:choose>
                                <c:when test="${cancelable[order.id]}">
                                    <div class="fb-row" style="margin-bottom:10px;">
                                        <form method="post" action="${pageContext.request.contextPath}/user/donhang" style="display:inline;"
                                              onsubmit="return confirm('Bạn chắc chắn muốn hủy đơn hàng này?');">
                                            <input type="hidden" name="action" value="cancel"/>
                                            <input type="hidden" name="orderId" value="${order.id}"/>
                                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}"/>
                                            <button type="submit" class="btn-fb" style="background:rgba(220,38,38,.1);color:#dc2626;border-color:rgba(220,38,38,.3);font-weight:700;">
                                                <i class="fa-solid fa-ban"></i> Hủy đơn hàng
                                            </button>
                                        </form>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="fb-row" style="margin-bottom:10px;">
                                        <span class="btn-fb btn-fb-done"><i class="fa-solid fa-clock"></i> Đơn vừa đặt, vui lòng đợi ít phút để có thể hủy</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:if>

                        <!-- TRACKING PROGRESS STEPPER BAR -->
                        <c:set var="st" value="${order.staTus}"/>
                        <c:set var="stepNum" value="1"/>
                        <c:choose>
                            <c:when test="${st eq 'PENDING'}"><c:set var="stepNum" value="1"/></c:when>
                            <c:when test="${st eq 'CONFIRMED' or st eq 'WAITING_FOR_SHIPPER'}"><c:set var="stepNum" value="2"/></c:when>
                            <c:when test="${st eq 'READY_FOR_PICKUP' or st eq 'ACCEPTED'}"><c:set var="stepNum" value="3"/></c:when>
                            <c:when test="${st eq 'SHIPPING'}"><c:set var="stepNum" value="4"/></c:when>
                            <c:when test="${st eq 'DONE'}"><c:set var="stepNum" value="5"/></c:when>
                            <c:when test="${st eq 'CANCELLED'}"><c:set var="stepNum" value="-1"/></c:when>
                        </c:choose>

                        <c:choose>
                            <c:when test="${stepNum eq -1}">
                                <div class="cancelled-banner">
                                    <i class="fa-solid fa-circle-xmark"></i> Đơn hàng đã bị hủy
                                </div>
                            </c:when>
                            <c:when test="${st eq 'DONE'}">
                                <!-- Đơn đã giao thành công: ẩn thanh tiến trình, không cần theo dõi live nữa -->
                            </c:when>
                            <c:otherwise>
                                <div class="tracking-stepper-box">
                                    <div class="stepper-title">
                                        <span>📍 Tiến trình đơn hàng</span>
                                        <span class="live-pulse"><span class="pulse-dot"></span> Đang cập nhật live</span>
                                    </div>
                                    <div class="tracking-stepper">
                                        <div class="stepper-progress-bar" style="width: ${stepNum eq 1 ? '0%' : stepNum eq 2 ? '25%' : stepNum eq 3 ? '50%' : '75%'};"></div>

                                        <div class="step-item ${stepNum >= 1 ? (stepNum eq 1 ? 'active' : 'completed') : ''}">
                                            <div class="step-icon-wrap">${stepNum > 1 ? '✓' : '1'}</div>
                                            <div class="step-label">Đặt đơn</div>
                                        </div>
                                        <div class="step-item ${stepNum >= 2 ? (stepNum eq 2 ? 'active' : 'completed') : ''}">
                                            <div class="step-icon-wrap">${stepNum > 2 ? '✓' : '2'}</div>
                                            <div class="step-label">Quán nhận</div>
                                        </div>
                                        <div class="step-item ${stepNum >= 3 ? (stepNum eq 3 ? 'active' : 'completed') : ''}">
                                            <div class="step-icon-wrap">${stepNum > 3 ? '✓' : '3'}</div>
                                            <div class="step-label">Chuẩn bị xong</div>
                                        </div>
                                        <div class="step-item ${stepNum >= 4 ? 'active' : ''}">
                                            <div class="step-icon-wrap">4</div>
                                            <div class="step-label">Đang giao</div>
                                        </div>
                                        <div class="step-item">
                                            <div class="step-icon-wrap">5</div>
                                            <div class="step-label">Hoàn thành</div>
                                        </div>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- CONTACT CARDS (SHOP & SHIPPER) -->
                        <div class="contacts-grid">
                            <c:set var="shopObj" value="${shopMap[order.shopId]}"/>
                            <div class="contact-card shop-card">
                                <div class="contact-header">
                                    <span class="contact-badge shop"><i class="fa-solid fa-store"></i> Nhà hàng</span>
                                    <span class="contact-name">${not empty shopObj.shopName ? shopObj.shopName : shopNames[order.shopId]}</span>
                                </div>
                                <c:if test="${not empty shopObj.shopAddress}">
                                    <div class="contact-sub"><i class="fa-solid fa-location-dot"></i> ${shopObj.shopAddress}</div>
                                </c:if>
                                <c:if test="${not empty shopObj.shopPhone}">
                                    <a href="tel:${shopObj.shopPhone}" class="btn-contact-call"><i class="fa-solid fa-phone"></i> Gọi quán</a>
                                </c:if>
                            </div>

                            <c:choose>
                                <c:when test="${order.shipperId > 0}">
                                    <c:set var="shipperAcc" value="${shipperMap[order.shipperId]}"/>
                                    <div class="contact-card shipper-card">
                                        <div class="contact-header">
                                            <span class="contact-badge shipper"><i class="fa-solid fa-motorcycle"></i> Tài xế</span>
                                            <span class="contact-name">${not empty shipperAcc.fullName ? shipperAcc.fullName : (not empty shipperAcc.userName ? shipperAcc.userName : 'Tài xế POB')}</span>
                                        </div>
                                        <c:if test="${not empty shipperAcc.phone}">
                                            <div class="contact-sub"><i class="fa-solid fa-phone"></i> ${shipperAcc.phone}</div>
                                            <a href="tel:${shipperAcc.phone}" class="btn-contact-call shipper"><i class="fa-solid fa-phone"></i> Gọi tài xế</a>
                                        </c:if>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="contact-card shipper-card">
                                        <div class="contact-header">
                                            <span class="contact-badge shipper"><i class="fa-solid fa-motorcycle"></i> Tài xế</span>
                                            <span class="contact-name" style="color:var(--muted);font-style:italic;">Đang phân công tài xế...</span>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="order-meta">
                            <div class="order-meta-row">
                                <i class="fa-solid fa-location-dot"></i>
                                <span>Giao tới: ${order.shippingAddress}</span>
                            </div>
                            <div class="order-meta-row">
                                <i class="fa-solid fa-credit-card"></i>
                                <span>Thanh toán: ${order.paymentMethod} (${not empty order.paymentStatus ? order.paymentStatus : 'Chưa thanh toán'})</span>
                            </div>
                        </div>

                        <div class="order-price">
                            Tổng tiền: <span><fmt:formatNumber value="${order.totalPrice}" type="number" groupingUsed="true"/> đ</span>
                        </div>

                        <c:if test="${order.staTus eq 'SHIPPING'}">
                            <div class="tracking-map-wrap">
                                <div class="tracking-gps-badge"><span class="pulse-dot"></span> GPS Realtime</div>
                                <div id="map-${order.id}" class="tracking-map"></div>
                            </div>
                        </c:if>

                        <div class="fb-row" style="margin-bottom:10px;">
                            <button type="button" class="btn-fb" style="background:linear-gradient(135deg,var(--gold),#e02a10);color:#fff;border:none;font-weight:700;"
                                    onclick="openOrderModal('modal-${order.id}')">
                                <i class="fa-solid fa-receipt"></i> Chi tiết & Theo dõi đơn
                            </button>
                        </div>

                        <!-- Nút đánh giá chỉ khi DONE -->
                        <c:if test="${order.staTus eq 'DONE'}">
                            <div class="fb-row">
                                <c:choose>
                                    <c:when test="${feedbackShop[order.id]}">
                                        <span class="btn-fb btn-fb-done"><i class="fa-solid fa-check"></i> Đã đánh giá Shop</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/feedback?orderId=${order.id}&targetType=SHOP" class="btn-fb btn-fb-shop">
                                            <i class="fa-solid fa-star"></i> Đánh giá Shop
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${order.shipperId != 0}">
                                    <c:choose>
                                        <c:when test="${feedbackShipper[order.id]}">
                                            <span class="btn-fb btn-fb-done"><i class="fa-solid fa-check"></i> Đã đánh giá Shipper</span>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/feedback?orderId=${order.id}&targetType=SHIPPER" class="btn-fb btn-fb-shipper">
                                                <i class="fa-solid fa-motorcycle"></i> Đánh giá Shipper
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </div>
                        </c:if>

                        <!-- Hoàn tiền: chỉ khi đã CANCELLED và đã PAID (payment_status = REFUNDED) -->
                        <c:if test="${order.staTus eq 'CANCELLED' and order.paymentStatus eq 'REFUNDED'}">
                            <div class="fb-row" style="margin-top:6px;">
                                <a href="${pageContext.request.contextPath}/user/yeu-cau-hoan-tien?orderId=${order.id}"
                                   class="btn-fb" style="background:rgba(220,38,38,.1);color:#dc2626;border-color:rgba(220,38,38,.3);font-weight:700;">
                                    ↩️ Yêu cầu hoàn tiền
                                </a>
                            </div>
                        </c:if>

                        <!-- Khiếu nại: cho phép với mọi đơn không phải PENDING (đã có tiến triển thực tế để khiếu nại) -->
                        <c:if test="${order.staTus ne 'PENDING'}">
                            <div class="fb-row" style="margin-top:6px;">
                                <a href="${pageContext.request.contextPath}/khieu-nai?orderId=${order.id}" class="btn-fb" style="background:rgba(248,113,113,.12);color:var(--danger);border-color:rgba(248,113,113,.4);">📢 Khiếu nại đơn này</a>
                            </div>
                        </c:if>
                    </div>
                </c:forEach>

                <!-- MODALS CHI TIẾT & THEO DÕI ĐƠN HÀNG -->
                <c:forEach var="order" items="${orders}">
                    <div id="modal-${order.id}" class="order-detail-modal-backdrop" onclick="closeOrderModal(event, 'modal-${order.id}')">
                        <div class="order-detail-modal" onclick="event.stopPropagation()">
                            <div class="odm-header">
                                <div>
                                    <h3>Chi Tiết Đơn Hàng #${order.id}</h3>
                                    <span class="odm-date">🕒 Ngày đặt: ${app:formatDateTime(order.createdAt)}</span>
                                </div>
                                <button type="button" class="odm-close" onclick="document.getElementById('modal-${order.id}').classList.remove('open')">&times;</button>
                            </div>
                            <div class="odm-body">
                                <div class="odm-section">
                                    <h4><i class="fa-solid fa-utensils"></i> Danh sách món ăn</h4>
                                    <c:set var="billView" value="${billMap[order.id]}"/>
                                    <c:choose>
                                        <c:when test="${not empty billView and not empty billView.lines}">
                                            <div class="bill-items-table">
                                                <c:forEach var="line" items="${billView.lines}">
                                                    <div class="bill-item-row">
                                                        <div class="bir-name">
                                                            <strong>${line.productName}</strong>
                                                            <c:if test="${not empty line.sizeName}"> <span class="bir-size">(${line.sizeName})</span></c:if>
                                                            <c:if test="${not empty line.toppings}">
                                                                <div class="bir-toppings">
                                                                    <c:forEach var="top" items="${line.toppings}">
                                                                        + ${top.toppingName} (x${top.quantity})<br>
                                                                    </c:forEach>
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                        <div class="bir-qty">x${line.quantity}</div>
                                                        <div class="bir-price"><fmt:formatNumber value="${line.lineTotal}" type="number" maxFractionDigits="0"/>đ</div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-muted" style="font-size:13px;padding:8px 0;">Không có chi tiết sản phẩm.</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="odm-section">
                                    <h4><i class="fa-solid fa-file-invoice-dollar"></i> Chi tiết thanh toán</h4>
                                    <div class="odm-summary-row"><span>Tạm tính tiền món:</span> <strong><fmt:formatNumber value="${billView != null ? billView.subtotal : order.totalPrice}" type="number" maxFractionDigits="0"/>đ</strong></div>
                                    <c:if test="${not empty order.deliveryFee and order.deliveryFee > 0}">
                                        <div class="odm-summary-row"><span>Phí giao hàng:</span> <strong><fmt:formatNumber value="${order.deliveryFee}" type="number" maxFractionDigits="0"/>đ</strong></div>
                                    </c:if>
                                    <div class="odm-summary-row total"><span>Tổng thanh toán:</span> <strong><fmt:formatNumber value="${order.totalPrice}" type="number" maxFractionDigits="0"/>đ</strong></div>
                                    <div class="odm-summary-row"><span>Phương thức:</span> <strong>${order.paymentMethod}</strong></div>
                                    <div class="odm-summary-row"><span>Trạng thái:</span> <strong>${not empty order.paymentStatus ? order.paymentStatus : 'UNPAID'}</strong></div>
                                </div>

                                <div class="odm-section">
                                    <h4><i class="fa-solid fa-location-dot"></i> Thông tin giao hàng</h4>
                                    <div class="odm-summary-row"><span>Người nhận:</span> <strong>${order.receiverName}</strong></div>
                                    <div class="odm-summary-row"><span>Số điện thoại:</span> <strong>${order.receiverPhone}</strong></div>
                                    <div class="odm-summary-row"><span>Địa chỉ:</span> <strong>${order.shippingAddress}</strong></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<script>
    function openOrderModal(modalId) {
        var modal = document.getElementById(modalId);
        if (modal) modal.classList.add('open');
    }
    function closeOrderModal(event, modalId) {
        if (event.target === document.getElementById(modalId)) {
            document.getElementById(modalId).classList.remove('open');
        }
    }
    // Tranh bi auto-reload (xem setInterval ben duoi) danh mat modal dang mo:
    // khi co bat ky modal chi tiet don nao dang mo, coi la trang dang "ban" -> khong reload.
    function isAnyOrderModalOpen() {
        return document.querySelector('.order-detail-modal-backdrop.open') !== null;
    }
</script>
<script>
    (function () {
        var protocol = location.protocol === 'https:' ? 'wss://' : 'ws://';
        var contextPath = '${pageContext.request.contextPath}';
        <c:forEach var="order" items="${orders}">
        <c:if test="${order.staTus eq 'SHIPPING'}">
        (function () {
            var shopLat = ${not empty shopCoords[order.shopId] ? shopCoords[order.shopId][0] : 'null'};
            var shopLng = ${not empty shopCoords[order.shopId] ? shopCoords[order.shopId][1] : 'null'};
            var destLat = ${not empty order.locationX ? order.locationX : 'null'};
            var destLng = ${not empty order.locationY ? order.locationY : 'null'};
            var wsUrl = protocol + location.host + contextPath + '/ws/tracking?role=customer&orderId=${order.id}';
            initOrderTrackingMap('map-${order.id}', shopLat, shopLng, destLat, destLng, wsUrl);
        })();
        </c:if>
        </c:forEach>

        // Tự động làm mới trang mỗi 10 giây nếu có đơn hàng đang hoạt động (chưa hoàn thành)
        var hasActive = false;
        <c:forEach var="o" items="${orders}">
            <c:if test="${o.staTus ne 'DONE' and o.staTus ne 'CANCELLED'}">
                hasActive = true;
            </c:if>
        </c:forEach>
        if (hasActive) {
            setInterval(function() {
                if (!isAnyOrderModalOpen()) {
                    window.location.reload();
                }
            }, 10000);
        }
    })();
</script>

<script>
function toggleDropdown() {
    document.getElementById('accountDropdown').classList.toggle('open');
}

(function () {
    var tabsWrap = document.getElementById('orderFilterTabs');
    if (!tabsWrap) return;
    var cards = document.querySelectorAll('.order-card');
    tabsWrap.querySelectorAll('.filter-tab').forEach(function (tab) {
        tab.addEventListener('click', function () {
            tabsWrap.querySelectorAll('.filter-tab').forEach(function (t) { t.classList.remove('active'); });
            tab.classList.add('active');
            var filter = tab.dataset.filter;
            cards.forEach(function (card) {
                var st = card.dataset.status;
                var show = filter === 'all'
                    || (filter === 'active' && st !== 'DONE' && st !== 'CANCELLED')
                    || st === filter;
                card.style.display = show ? '' : 'none';
            });
        });
    });
})();
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
