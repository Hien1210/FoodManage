<%@ page pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Địa chỉ giao hàng - FOOD MANAGE</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user-theme.css">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
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
.btn-danger { color: var(--danger); border-color: #FBD0D8; background: var(--danger-lt, #FEECEF); }
.btn-danger:hover { background: var(--danger); color: #fff; border-color: var(--danger); }
.btn-default { color: var(--text); border-color: var(--border); }
.btn-default:hover { color: var(--gold); border-color: var(--gold); }

/* EMPTY */
.empty-state {
    text-align: center; padding: 70px 24px; border-radius: 22px;
    background: var(--surface); border: 1px dashed var(--border);
}
.empty-state img { width: 90px; height: 90px; margin-bottom: 18px; filter: drop-shadow(0 12px 18px rgba(99,44,20,.2)); animation: addr-float 4s ease-in-out infinite; }
@keyframes addr-float { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }
.empty-state h3 { font-family: var(--font-h); font-size: 1.3rem; color: var(--text); margin-bottom: 8px; }
.empty-state p { font-size: .9rem; color: var(--muted); }

/* ADDRESS LIST */
.addr-list { display: flex; flex-direction: column; gap: 16px; }
.addr-card {
    background: var(--surface); border: 1.5px solid var(--border); border-radius: 20px;
    padding: 24px; position: relative; transition: var(--tr);
    box-shadow: 0 2px 12px rgba(99,44,20,.05);
}
.addr-card:hover { border-color: var(--gold); box-shadow: var(--shadow); }
.addr-card.is-default { border-color: var(--gold); background: linear-gradient(180deg, var(--surface-lt), var(--surface) 40%); }

.addr-default-badge {
    position: absolute; top: 18px; right: 18px;
    font-size: .7rem; font-weight: 700; letter-spacing: .3px;
    color: #fff; background: linear-gradient(135deg, var(--gold), var(--gold-hover));
    padding: 4px 14px; border-radius: 50px;
}
.addr-label { font-family: var(--font-h); font-size: 1.1rem; margin-bottom: 12px; display: flex; align-items: center; gap: 8px; font-weight: 800; }
.addr-label i { color: var(--gold); font-size: .9rem; }
.addr-meta { display: flex; flex-direction: column; gap: 6px; margin-bottom: 18px; }
.addr-meta-row { display: flex; align-items: center; gap: 8px; font-size: .85rem; color: var(--muted); font-weight: 500; }
.addr-meta-row i { color: var(--gold); width: 14px; font-size: .8rem; }
.addr-actions { display: flex; gap: 10px; flex-wrap: wrap; }

/* MODAL */
.modal-overlay {
    position: fixed; inset: 0; background: rgba(36,20,10,.55);
    backdrop-filter: blur(6px); z-index: 2000;
    display: flex; align-items: center; justify-content: center;
    opacity: 0; visibility: hidden; transition: var(--tr);
}
.modal-overlay.open { opacity: 1; visibility: visible; }
.modal-box {
    background: var(--surface); border: 1px solid var(--border); border-radius: 22px;
    padding: 30px; width: 90%; max-width: 460px;
    max-height: 90vh; overflow-y: auto;
    transform: translateY(20px); transition: transform .3s ease;
    box-shadow: var(--shadow);
}
.modal-overlay.open .modal-box { transform: translateY(0); }
.modal-head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 22px; padding-bottom: 16px; border-bottom: 1px solid var(--border); }
.modal-head h3 { font-family: var(--font-h); font-size: 1.25rem; font-weight: 800; }
.modal-close { background: var(--surface-lt); border: none; width: 32px; height: 32px; border-radius: 50%; color: var(--muted); font-size: 1.1rem; cursor: pointer; transition: var(--tr); }
.modal-close:hover { color: var(--gold); }

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
.form-control::placeholder, .form-textarea::placeholder { color: var(--muted); }
.form-textarea { resize: vertical; min-height: 80px; }
.form-select option { background: var(--surface); color: var(--text); }
.check-wrap { display: flex; align-items: center; gap: 10px; font-size: .85rem; color: var(--muted); cursor: pointer; margin-bottom: 20px; font-weight: 500; }
.check-wrap input { accent-color: var(--gold); width: 16px; height: 16px; }
.modal-actions { display: flex; gap: 12px; }
.modal-actions .btn { flex: 1; justify-content: center; }

/* MAP PICKER */
.btn-map-toggle {
    display: inline-flex; align-items: center; gap: 7px;
    width: 100%; justify-content: center;
    padding: 10px 16px; margin-bottom: 8px;
    background: var(--surface-lt); border: 1.5px dashed var(--border);
    border-radius: 12px; color: var(--gold); font-family: var(--font-b);
    font-size: .85rem; font-weight: 700; cursor: pointer; transition: var(--tr);
}
.btn-map-toggle:hover { border-color: var(--gold); background: var(--primary-light, #FFF2F0); }
.location-map-wrap { margin-bottom: 14px; }
.location-search-row { display: flex; gap: 8px; margin-bottom: 8px; }
.location-search-row input {
    flex: 1; padding: 9px 12px; border: 1.5px solid var(--border); border-radius: 10px;
    font-family: var(--font-b); font-size: .85rem; outline: none; transition: var(--tr);
}
.location-search-row input:focus { border-color: var(--gold); }
.location-search-row button {
    padding: 9px 14px; border: 1.5px solid var(--border); border-radius: 10px;
    background: var(--surface); color: var(--text); font-family: var(--font-b);
    font-size: .82rem; font-weight: 700; cursor: pointer; transition: var(--tr);
    white-space: nowrap;
}
.location-search-row button:hover { border-color: var(--gold); color: var(--gold); }
.location-search-row button.btn-current-loc { border-color: var(--gold); color: var(--gold); background: var(--surface-lt); }
.location-search-row button.btn-current-loc:hover { background: var(--gold); color: #fff; }
.location-map-el { width: 100%; height: 220px; border-radius: 14px; border: 1.5px solid var(--border); }
.location-hint { font-size: .76rem; color: var(--muted); margin-bottom: 16px; line-height: 1.5; }
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
            <a href="${pageContext.request.contextPath}/user/dia-chi" class="active">Địa chỉ</a>
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

    <c:if test="${param.success eq 'created'}">
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Đã thêm địa chỉ mới thành công!</div>
    </c:if>
    <c:if test="${param.success eq 'updated'}">
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Đã cập nhật địa chỉ thành công!</div>
    </c:if>
    <c:if test="${param.success eq 'deleted'}">
        <div class="alert alert-danger"><i class="fa-solid fa-trash"></i> Đã xóa địa chỉ.</div>
    </c:if>
    <c:if test="${param.success eq 'default'}">
        <div class="alert alert-info"><i class="fa-solid fa-star"></i> Đã đặt làm địa chỉ mặc định!</div>
    </c:if>
    <c:if test="${param.error eq 'missing'}">
        <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation"></i> Vui lòng điền đầy đủ thông tin bắt buộc.</div>
    </c:if>

    <div class="page-head">
        <div>
            <h2>Địa Chỉ Của Tôi</h2>
            <p class="sub">Quản lý địa chỉ nhận hàng</p>
        </div>
        <button onclick="openModal('modalCreate')" class="btn btn-gold btn-sm">
            <i class="fa-solid fa-plus"></i> Thêm địa chỉ
        </button>
    </div>

    <c:choose>
        <c:when test="${empty addresses}">
            <div class="empty-state">
                <img src="https://cdn.jsdelivr.net/gh/microsoft/fluentui-emoji@main/assets/Round%20pushpin/3D/round_pushpin_3d.png" alt="">
                <h3>Chưa có địa chỉ nào</h3>
                <p>Thêm địa chỉ để đặt hàng nhanh hơn.</p>
                <button onclick="openModal('modalCreate')" class="btn btn-gold btn-sm" style="margin-top:20px;">
                    <i class="fa-solid fa-plus"></i> Thêm địa chỉ mới
                </button>
            </div>
        </c:when>
        <c:otherwise>
            <div class="addr-list">
                <c:forEach var="addr" items="${addresses}">
                    <div class="addr-card ${addr.isDefault ? 'is-default' : ''}">
                        <c:if test="${addr.isDefault}">
                            <span class="addr-default-badge"><i class="fa-solid fa-star"></i> Mặc định</span>
                        </c:if>
                        <div class="addr-label">
                            <c:choose>
                                <c:when test="${addr.label eq 'Nhà'}"><i class="fa-solid fa-house"></i></c:when>
                                <c:when test="${addr.label eq 'Công ty'}"><i class="fa-solid fa-building"></i></c:when>
                                <c:when test="${addr.label eq 'Trường học'}"><i class="fa-solid fa-graduation-cap"></i></c:when>
                                <c:otherwise><i class="fa-solid fa-location-dot"></i></c:otherwise>
                            </c:choose>
                            ${addr.label}
                        </div>
                        <div class="addr-meta">
                            <div class="addr-meta-row"><i class="fa-solid fa-location-dot"></i> <span>${addr.fullAddress}</span></div>
                            <div class="addr-meta-row"><i class="fa-solid fa-user"></i> <span>${addr.receiverName}</span></div>
                            <div class="addr-meta-row"><i class="fa-solid fa-phone"></i> <span>${addr.receiverPhone}</span></div>
                        </div>
                        <div class="addr-actions">
                            <c:if test="${!addr.isDefault}">
                                <form action="${pageContext.request.contextPath}/user/dia-chi" method="post" style="display:inline;">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                    <input type="hidden" name="action" value="setDefault">
                                    <input type="hidden" name="id" value="${addr.id}">
                                    <button type="submit" class="btn btn-default btn-sm"><i class="fa-regular fa-star"></i> Đặt mặc định</button>
                                </form>
                            </c:if>
                            <button onclick="openEdit(${addr.id}, '${addr.label}', '${fn:escapeXml(addr.fullAddress)}', '${fn:escapeXml(addr.receiverName)}', '${addr.receiverPhone}', '${addr.locationX}', '${addr.locationY}')"
                                    class="btn btn-muted btn-sm"><i class="fa-solid fa-pen"></i> Sửa</button>
                            <c:if test="${!addr.isDefault}">
                                <form action="${pageContext.request.contextPath}/user/dia-chi" method="post" style="display:inline;"
                                      onsubmit="return confirm('Xác nhận xóa địa chỉ này?')">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${addr.id}">
                                    <button type="submit" class="btn btn-danger btn-sm"><i class="fa-solid fa-trash"></i> Xóa</button>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<%-- MODAL THÊM --%>
<div id="modalCreate" class="modal-overlay">
    <div class="modal-box">
        <div class="modal-head">
            <h3>Thêm Địa Chỉ Mới</h3>
            <button onclick="closeModal('modalCreate')" class="modal-close"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/user/dia-chi" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="create">
            <div class="form-group">
                <label class="form-label">Nhãn địa chỉ</label>
                <select name="label" class="form-select">
                    <option value="Nhà">Nhà</option>
                    <option value="Công ty">Công ty</option>
                    <option value="Trường học">Trường học</option>
                    <option value="Khác">Khác</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Địa chỉ đầy đủ <span class="required">*</span></label>
                <textarea class="form-textarea" name="fullAddress" id="fullAddressCreate" rows="2" required placeholder="Số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố"></textarea>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Tên người nhận <span class="required">*</span></label>
                    <input type="text" class="form-control" name="receiverName" required placeholder="Họ và tên">
                </div>
                <div class="form-group">
                    <label class="form-label">Số điện thoại <span class="required">*</span></label>
                    <input type="tel" class="form-control" name="receiverPhone" required placeholder="0xxxxxxxxx">
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Vị trí trên bản đồ <span class="required">*</span></label>
                <button type="button" class="btn-map-toggle" id="mapToggleCreate">
                    <i class="fa-solid fa-map-location-dot"></i> Chọn vị trí trên bản đồ
                </button>
                <div id="mapWrapCreate" class="location-map-wrap" style="display:none;">
                    <div class="location-search-row">
                        <input type="text" id="mapSearchCreate" placeholder="Tìm địa chỉ...">
                        <button type="button" id="mapSearchBtnCreate">Tìm</button>
                        <button type="button" id="mapCurrentLocBtnCreate" class="btn-current-loc">📍 Vị trí hiện tại</button>
                    </div>
                    <div id="mapElCreate" class="location-map-el"></div>
                </div>
                <input type="hidden" name="locationX" id="locationXCreate">
                <input type="hidden" name="locationY" id="locationYCreate">
                <p class="location-hint">Bấm nút trên, sau đó chọn đúng điểm giao hàng trên bản đồ (bắt buộc) để shipper xác định được vị trí.</p>
            </div>
            <label class="check-wrap">
                <input type="checkbox" name="isDefault" value="true">
                Đặt làm địa chỉ mặc định
            </label>
            <div class="modal-actions">
                <button type="button" onclick="closeModal('modalCreate')" class="btn btn-muted">Hủy</button>
                <button type="submit" class="btn btn-gold">Lưu địa chỉ</button>
            </div>
        </form>
    </div>
</div>

<%-- MODAL SỬA --%>
<div id="modalEdit" class="modal-overlay">
    <div class="modal-box">
        <div class="modal-head">
            <h3>Chỉnh Sửa Địa Chỉ</h3>
            <button onclick="closeModal('modalEdit')" class="modal-close"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/user/dia-chi" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="editId">
            <div class="form-group">
                <label class="form-label">Nhãn địa chỉ</label>
                <select name="label" id="editLabel" class="form-select">
                    <option value="Nhà">Nhà</option>
                    <option value="Công ty">Công ty</option>
                    <option value="Trường học">Trường học</option>
                    <option value="Khác">Khác</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Địa chỉ đầy đủ <span class="required">*</span></label>
                <textarea class="form-textarea" name="fullAddress" id="editFullAddress" rows="2" required></textarea>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Tên người nhận <span class="required">*</span></label>
                    <input type="text" class="form-control" name="receiverName" id="editReceiverName" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Số điện thoại <span class="required">*</span></label>
                    <input type="tel" class="form-control" name="receiverPhone" id="editReceiverPhone" required>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Vị trí trên bản đồ <span class="required">*</span></label>
                <button type="button" class="btn-map-toggle" id="mapToggleEdit">
                    <i class="fa-solid fa-map-location-dot"></i> Chọn vị trí trên bản đồ
                </button>
                <div id="mapWrapEdit" class="location-map-wrap" style="display:none;">
                    <div class="location-search-row">
                        <input type="text" id="mapSearchEdit" placeholder="Tìm địa chỉ...">
                        <button type="button" id="mapSearchBtnEdit">Tìm</button>
                        <button type="button" id="mapCurrentLocBtnEdit" class="btn-current-loc">📍 Vị trí hiện tại</button>
                    </div>
                    <div id="mapElEdit" class="location-map-el"></div>
                </div>
                <input type="hidden" name="locationX" id="locationXEdit">
                <input type="hidden" name="locationY" id="locationYEdit">
                <p class="location-hint">Bấm nút trên, sau đó chọn đúng điểm giao hàng trên bản đồ (bắt buộc) để shipper xác định được vị trí.</p>
            </div>
            <div class="modal-actions">
                <button type="button" onclick="closeModal('modalEdit')" class="btn btn-muted">Hủy</button>
                <button type="submit" class="btn btn-gold">Cập nhật</button>
            </div>
        </form>
    </div>
</div>

<script>
function openModal(id) { document.getElementById(id).classList.add('open'); }
function closeModal(id) { document.getElementById(id).classList.remove('open'); }
['modalCreate','modalEdit'].forEach(function(id) {
    document.getElementById(id).addEventListener('click', function(e) {
        if (e.target === this) closeModal(id);
    });
});
function openEdit(id, label, fullAddress, receiverName, receiverPhone, locationX, locationY) {
    document.getElementById('editId').value = id;
    document.getElementById('editFullAddress').value = fullAddress;
    document.getElementById('editReceiverName').value = receiverName;
    document.getElementById('editReceiverPhone').value = receiverPhone;
    var sel = document.getElementById('editLabel');
    for (var i = 0; i < sel.options.length; i++) { sel.options[i].selected = (sel.options[i].value === label); }

    var lat = (locationX && locationX !== 'null') ? parseFloat(locationX) : null;
    var lng = (locationY && locationY !== 'null') ? parseFloat(locationY) : null;
    document.getElementById('locationXEdit').value = lat || '';
    document.getElementById('locationYEdit').value = lng || '';
    document.getElementById('mapToggleEdit').dataset.presetLat = lat || '';
    document.getElementById('mapToggleEdit').dataset.presetLng = lng || '';
    document.getElementById('mapWrapEdit').style.display = 'none';
    var mapElEdit = document.getElementById('mapElEdit');
    if (mapElEdit._leafletMap) { mapElEdit._leafletMap.remove(); mapElEdit._leafletMap = null; }
    mapElEdit.dataset.initialized = 'false';

    openModal('modalEdit');
}

/* ── LEAFLET MAP PICKER (dùng chung cho modal Thêm & Sửa) ── */
function initLocationMap(suffix, addressFieldId, presetLat, presetLng) {
    var mapContainer = document.getElementById('mapEl' + suffix);
    if (mapContainer.dataset.initialized === 'true') {
        var existingMap = mapContainer._leafletMap;
        setTimeout(function () { existingMap.invalidateSize(); }, 50);
        return;
    }
    mapContainer.dataset.initialized = 'true';

    var defaultLat = 21.0285, defaultLng = 105.8542;
    var startLat = presetLat ? parseFloat(presetLat) : defaultLat;
    var startLng = presetLng ? parseFloat(presetLng) : defaultLng;

    var map = L.map(mapContainer).setView([startLat, startLng], 15);
    mapContainer._leafletMap = map;

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors',
        maxZoom: 19
    }).addTo(map);

    var marker = null;
    var reverseGeocodeTimer = null;

    function updateCoords(lat, lng) {
        document.getElementById('locationX' + suffix).value = lat;
        document.getElementById('locationY' + suffix).value = lng;
    }

    function reverseGeocode(lat, lng) {
        fetch('https://nominatim.openstreetmap.org/reverse?format=json&lat=' + lat + '&lon=' + lng)
            .then(function (res) { return res.json(); })
            .then(function (data) {
                if (data && data.display_name) {
                    document.getElementById(addressFieldId).value = data.display_name;
                }
            })
            .catch(function () { console.warn('Khong the lay dia chi tu toa do'); });
    }

    function reverseGeocodeDebounced(lat, lng) {
        clearTimeout(reverseGeocodeTimer);
        reverseGeocodeTimer = setTimeout(function () { reverseGeocode(lat, lng); }, 500);
    }

    delete L.Icon.Default.prototype._getIconUrl;
    L.Icon.Default.mergeOptions({
        iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
        iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
        shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png'
    });

    var pinIcon = L.divIcon({
        className: 'custom-map-pin',
        html: '<div style="font-size:32px;line-height:32px;text-align:center;filter:drop-shadow(0 3px 6px rgba(0,0,0,0.3));cursor:grab;">📍</div>',
        iconSize: [32, 32],
        iconAnchor: [16, 30]
    });

    function placeMarker(lat, lng, doReverseGeocode) {
        if (marker) {
            marker.setLatLng([lat, lng]);
        } else {
            marker = L.marker([lat, lng], { icon: pinIcon, draggable: true }).addTo(map);
            marker.on('dragend', function () {
                var pos = marker.getLatLng();
                updateCoords(pos.lat, pos.lng);
                reverseGeocodeDebounced(pos.lat, pos.lng);
            });
        }
        updateCoords(lat, lng);
        if (doReverseGeocode) reverseGeocode(lat, lng);
    }

    map.on('click', function (e) { placeMarker(e.latlng.lat, e.latlng.lng, true); });

    if (presetLat && presetLng) {
        placeMarker(startLat, startLng, false);
    } else if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            function (pos) { map.setView([pos.coords.latitude, pos.coords.longitude], 15); },
            function () { /* denied - keep default center */ },
            { timeout: 5000 }
        );
    }

    document.getElementById('mapSearchBtn' + suffix).addEventListener('click', function () {
        var query = document.getElementById('mapSearch' + suffix).value.trim();
        if (!query) return;
        fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(query) + '&limit=1')
            .then(function (res) { return res.json(); })
            .then(function (results) {
                if (results && results.length > 0) {
                    var lat = parseFloat(results[0].lat);
                    var lng = parseFloat(results[0].lon);
                    map.setView([lat, lng], 16);
                    placeMarker(lat, lng, true);
                } else {
                    alert('Không tìm thấy địa chỉ, vui lòng thử tên khác');
                }
            })
            .catch(function () { alert('Không tìm được địa chỉ, vui lòng thử lại'); });
    });

    var currentLocBtn = document.getElementById('mapCurrentLocBtn' + suffix);
    if (currentLocBtn) {
        currentLocBtn.addEventListener('click', function () {
            if (!navigator.geolocation) {
                alert('Trình duyệt của bạn không hỗ trợ lấy vị trí GPS.');
                return;
            }
            var originalText = currentLocBtn.innerHTML;
            currentLocBtn.disabled = true;
            currentLocBtn.innerHTML = '⏳ Đang định vị...';
            navigator.geolocation.getCurrentPosition(
                function (pos) {
                    currentLocBtn.disabled = false;
                    currentLocBtn.innerHTML = originalText;
                    var lat = pos.coords.latitude;
                    var lng = pos.coords.longitude;
                    map.setView([lat, lng], 16);
                    placeMarker(lat, lng, true);
                },
                function (err) {
                    currentLocBtn.disabled = false;
                    currentLocBtn.innerHTML = originalText;
                    alert('Không thể lấy vị trí hiện tại. Vui lòng bật GPS và cho phép quyền vị trí trên trình duyệt.');
                },
                { enableHighAccuracy: true, timeout: 10000 }
            );
        });
    }
}

function setupMapToggle(suffix, addressFieldId) {
    var toggleBtn = document.getElementById('mapToggle' + suffix);
    var wrap = document.getElementById('mapWrap' + suffix);
    toggleBtn.addEventListener('click', function () {
        wrap.style.display = 'block';
        var presetLat = toggleBtn.dataset.presetLat || null;
        var presetLng = toggleBtn.dataset.presetLng || null;
        setTimeout(function () { initLocationMap(suffix, addressFieldId, presetLat, presetLng); }, 50);
    });
}
setupMapToggle('Create', 'fullAddressCreate');
setupMapToggle('Edit', 'editFullAddress');

/* Validate toạ độ bắt buộc trước khi submit (input hidden không tự validate HTML5) */
document.querySelector('#modalCreate form').addEventListener('submit', function (e) {
    if (!document.getElementById('locationXCreate').value || !document.getElementById('locationYCreate').value) {
        e.preventDefault();
        alert('Vui lòng chọn vị trí trên bản đồ trước khi lưu địa chỉ.');
    }
});
document.querySelector('#modalEdit form').addEventListener('submit', function (e) {
    if (!document.getElementById('locationXEdit').value || !document.getElementById('locationYEdit').value) {
        e.preventDefault();
        alert('Vui lòng chọn vị trí trên bản đồ trước khi cập nhật địa chỉ.');
    }
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
