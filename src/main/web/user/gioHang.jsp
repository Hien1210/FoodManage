<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ hàng - FOOD MANAGE</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --font-h: 'Quicksand', 'Plus Jakarta Sans', sans-serif; }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Plus Jakarta Sans', -apple-system, sans-serif; background: #FFF9F2; min-height: 100vh; }
        a { text-decoration: none; color: inherit; transition: all .25s ease; }

        /* NAVBAR (dong bo voi trang chu) */
        .navbar {
            position: fixed; top: 0; left: 0; width: 100%; z-index: 1000;
            background: rgba(255,249,242,.92); backdrop-filter: blur(14px);
            border-bottom: 1px solid #F1E4D6;
        }
        .nav-content { max-width: 1180px; margin: 0 auto; padding: 0 20px; display: flex; justify-content: space-between; align-items: center; height: 76px; gap: 16px; }
        .logo { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
        .logo h1 { font-family: var(--font-h); white-space: nowrap; font-size: 1.55rem; font-weight: 800; letter-spacing: -.5px; color: #2D2421; }
        .logo span { color: #FF3B1F; }
        .nav-links { display: flex; gap: 20px; align-items: center; }
        .nav-links a { font-size: .85rem; font-weight: 600; color: #635752; white-space: nowrap; }
        .nav-links a:hover, .nav-links a.active { color: #FF3B1F; }
        .nav-actions { display: flex; align-items: center; gap: 14px; }

        .avatar-wrap { position: relative; }
        .avatar-btn {
            width: 40px; height: 40px; border-radius: 50%;
            background: linear-gradient(135deg, #FF3B1F, #E02A10);
            color: #FFF; font-size: 15px; font-weight: 800;
            border: none; cursor: pointer; font-family: inherit;
            display: flex; align-items: center; justify-content: center; box-shadow: 0 8px 22px rgba(255,59,31,.3);
        }
        .avatar-dropdown {
            position: absolute; top: calc(100% + 12px); right: 0;
            background: #fff; border: 1px solid #F1E4D6; border-radius: 16px;
            min-width: 220px; z-index: 200; display: none; box-shadow: 0 14px 36px rgba(99,44,20,.14); overflow: hidden;
        }
        .avatar-dropdown.open { display: block; }
        .dd-head { padding: 16px 18px; border-bottom: 1px solid #F1E4D6; background: #FFF4EC; }
        .dd-name { font-size: 14px; font-weight: 700; color: #2D2421; }
        .dd-email { font-size: 11.5px; color: #635752; margin-top: 3px; }
        .dd-link, .dd-btn {
            display: flex; align-items: center; gap: 10px; width: 100%; padding: 12px 18px;
            font-size: 13px; font-weight: 600; color: #635752; background: none; border: none;
            cursor: pointer; font-family: inherit; transition: all .25s ease; text-align: left;
        }
        .dd-link i, .dd-btn i { color: #FF3B1F; width: 14px; }
        .dd-link:hover, .dd-btn:hover { color: #FF3B1F; background: #FFF4EC; }
        .dd-divider { height: 1px; background: #F1E4D6; margin: 4px 0; }

        .cart-btn {
            background: #FFF4EC; border: 1.5px solid #F1E4D6; border-radius: 50%;
            width: 42px; height: 42px; color: #2D2421; font-size: 1.05rem; cursor: pointer;
            position: relative; transition: all .25s ease; display: flex; align-items: center; justify-content: center;
        }
        .cart-btn:hover { color: #FF3B1F; border-color: #FF3B1F; }
        .cart-count { position: absolute; top: -4px; right: -4px; background: #ef4444; color: #fff; border-radius: 999px; font-size: 10px; min-width: 16px; height: 16px; line-height: 16px; text-align: center; padding: 0 3px; font-weight: 700; }

        .checkout-stepper { display: flex; align-items: center; gap: 8px; max-width: 860px; margin: 0 auto; padding: 96px 20px 0; font-size: 12px; font-family: var(--font-h); font-weight: 700; flex-wrap: wrap; }
        .step-pill { display: flex; align-items: center; gap: 6px; padding: 6px 14px; border-radius: 50px; white-space: nowrap; }
        .step-pill .num { width: 16px; height: 16px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10px; flex-shrink: 0; }
        .step-pill.done { background: #EAFBF1; color: #15803D; }
        .step-pill.done .num { background: #15803D; color: #fff; }
        .step-pill.current { background: #FFF2F0; color: #FF3B1F; box-shadow: 0 0 0 3px rgba(255,59,31,.1); }
        .step-pill.current .num { background: #FF3B1F; color: #fff; }
        .step-pill.upcoming { background: #F1E4D6; color: #8A7B6C; }
        .step-pill.upcoming .num { background: #E8D7C3; color: #8A7B6C; }
        .step-line { flex: 1; max-width: 28px; height: 2px; background: #F1E4D6; }
        .page-wrap { max-width: 860px; margin: 0 auto; padding: 20px 20px 60px; display: grid; grid-template-columns: 1fr 300px; gap: 20px; align-items: start; }
        .page-wrap > * { min-width: 0; }
        @media (max-width: 680px) { .page-wrap { grid-template-columns: 1fr; } }

        .card { background: #fff; border-radius: 20px; border: 1px solid #F1E4D6; box-shadow: 0 2px 10px rgba(99,44,20,0.06); overflow: hidden; }

        .card-header { padding: 14px 20px; border-bottom: 1px solid #F7EBDD; display: flex; align-items: center; gap: 12px; }
        .select-all-wrap { display: flex; align-items: center; gap: 8px; cursor: pointer; user-select: none; }
        .custom-cb { width: 20px; height: 20px; border-radius: 6px; border: 2px solid #F1E4D6; background: #fff; flex-shrink: 0; display: flex; align-items: center; justify-content: center; transition: all 0.15s; cursor: pointer; position: relative; }
        .custom-cb.checked { background: #FF3B1F; border-color: #FF3B1F; }
        .custom-cb.indeterminate { background: #FFF2F0; border-color: #FF3B1F; }
        .custom-cb.checked::after { content: ''; display: block; width: 5px; height: 9px; border: 2px solid #fff; border-top: none; border-left: none; transform: rotate(45deg) translateY(-1px); }
        .custom-cb.indeterminate::after { content: ''; display: block; width: 10px; height: 2px; background: #FF3B1F; border-radius: 2px; }
        .select-all-label { font-size: 13.5px; font-weight: 700; color: #2D2421; }
        .selected-count { font-size: 12px; color: #635752; font-weight: 500; }
        .card-title-right { margin-left: auto; font-size: 12px; font-weight: 600; background: #F7EBDD; color: #635752; padding: 2px 10px; border-radius: 99px; }

        .cart-item { padding: 14px 20px; border-bottom: 1px solid #FFF4EC; display: flex; align-items: center; gap: 12px; transition: background 0.15s; }
        .cart-item:last-child { border-bottom: none; }
        .cart-item.selected { background: #FFF9F2; }

        .item-cb-wrap { flex-shrink: 0; cursor: pointer; }
        .item-img { width: 60px; height: 60px; border-radius: 12px; background: #F7EBDD; flex-shrink: 0; overflow: hidden; display: flex; align-items: center; justify-content: center; font-size: 26px; }
        .item-img img { width: 100%; height: 100%; object-fit: cover; }

        .item-info { flex: 1; min-width: 0; }
        .item-name { font-size: 13.5px; font-weight: 700; color: #2D2421; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .item-size { font-size: 11.5px; color: #8A7B6C; margin-top: 2px; }
        .item-toppings { margin-top: 4px; display: flex; flex-wrap: wrap; gap: 4px; }
        .topping-tag { font-size: 10.5px; background: #FFF2F0; color: #E02A10; border-radius: 5px; padding: 1px 6px; font-weight: 600; }
        .item-unit-price { font-size: 11.5px; color: #8A7B6C; margin-top: 5px; }

        .item-actions { display: flex; align-items: center; gap: 6px; margin-top: 6px; }
        .btn-edit-item { font-size: 11px; font-weight: 700; color: #FF3B1F; background: #FFF2F0; border: 1px solid #FFC7BE; border-radius: 6px; padding: 3px 10px; cursor: pointer; transition: all 0.15s; }
        .btn-edit-item:hover { background: #FF3B1F; color: #fff; }

        .item-controls { display: flex; flex-direction: column; align-items: flex-end; gap: 7px; flex-shrink: 0; }
        .qty-row { display: flex; align-items: center; gap: 6px; }
        .qty-btn { width: 27px; height: 27px; border-radius: 8px; border: 1.5px solid #F1E4D6; background: #FFF4EC; font-size: 15px; font-weight: 700; display: flex; align-items: center; justify-content: center; cursor: pointer; color: #4A3934; transition: all 0.12s; }
        .qty-btn:hover { border-color: #FF3B1F; color: #FF3B1F; background: #FFF2F0; }
        .qty-num { font-size: 14px; font-weight: 800; color: #2D2421; min-width: 20px; text-align: center; }
        .item-total { font-size: 14px; font-weight: 800; color: #FF3B1F; }
        .btn-remove { background: none; border: none; color: #D9C9BA; cursor: pointer; font-size: 17px; padding: 2px; transition: color 0.15s; }
        .btn-remove:hover { color: #ef4444; }

        /* EMPTY */
        .empty-state { text-align: center; padding: 56px 24px; }
        .empty-icon { margin-bottom: 14px; }
        .empty-icon img { width: 72px; height: 72px; filter: drop-shadow(0 12px 18px rgba(99,44,20,.2)); animation: cart-float 4s ease-in-out infinite; }
        @keyframes cart-float { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }
        .empty-title { font-family: var(--font-h); font-size: 16px; font-weight: 700; color: #635752; margin-bottom: 8px; }
        .empty-sub { font-size: 13px; color: #8A7B6C; }
        .btn-shop { display: inline-block; margin-top: 20px; padding: 10px 24px; border-radius: 12px; background: linear-gradient(135deg,#FF3B1F,#E02A10); color: #fff; font-size: 13.5px; font-weight: 700; text-decoration: none; }

        /* SUMMARY */
        .summary-card { background: #fff; border-radius: 20px; border: 1px solid #F1E4D6; box-shadow: 0 2px 10px rgba(99,44,20,0.06); padding: 22px; position: sticky; top: 76px; }
        .summary-title { font-family: var(--font-h); font-size: 15px; font-weight: 800; color: #2D2421; margin-bottom: 18px; }
        .sum-row { display: flex; justify-content: space-between; font-size: 13.5px; color: #635752; margin-bottom: 8px; }
        .sum-row.grand { font-size: 16px; font-weight: 800; color: #2D2421; padding-top: 12px; margin-top: 6px; border-top: 2px solid #F7EBDD; }
        .sum-row.grand .amt { color: #FF3B1F; }
        .fee-note { font-size: 11px; color: #8A7B6C; margin-top: 3px; margin-bottom: 14px; }
        .sel-summary { font-size: 12px; color: #FF3B1F; font-weight: 600; background: #FFF2F0; border-radius: 8px; padding: 6px 10px; margin-bottom: 12px; display: none; }
        .sel-summary.visible { display: block; }
        .btn-checkout { display: block; width: 100%; padding: 14px; border-radius: 14px; background: linear-gradient(135deg,#FF3B1F,#E02A10); color: #fff; font-size: 14px; font-weight: 700; text-align: center; text-decoration: none; border: none; cursor: pointer; font-family: inherit; box-shadow: 0 4px 16px rgba(255,59,31,0.3); transition: all 0.2s; margin-top: 14px; }
        .btn-checkout:hover { opacity: 0.9; transform: translateY(-1px); }
        .btn-checkout.disabled { opacity: 0.4; cursor: not-allowed; transform: none; pointer-events: none; }

        .alert { display: flex; align-items: center; gap: 10px; border-radius: 12px; padding: 12px 16px; font-size: 13px; font-weight: 500; margin-bottom: 16px; }
        .alert-success { background: #EAFBF1; border: 1px solid #BBF0CF; color: #15803D; }

        /* == MODAL SỬA == */
        .modal-overlay { position: fixed; inset: 0; background: rgba(45,24,16,0.5); display: flex; align-items: flex-end; justify-content: center; z-index: 200; opacity: 0; pointer-events: none; transition: opacity 0.2s; }
        .modal-overlay.open { opacity: 1; pointer-events: all; }
        .modal-box { background: #fff; border-radius: 24px 24px 0 0; padding: 22px 22px 28px; width: 100%; max-width: 480px; transform: translateY(60px); transition: transform 0.25s; max-height: 88vh; overflow-y: auto; }
        .modal-overlay.open .modal-box { transform: translateY(0); }

        .modal-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
        .modal-title { font-family: var(--font-h); font-size: 15px; font-weight: 800; color: #2D2421; }
        .modal-close { background: none; border: none; font-size: 22px; color: #8A7B6C; cursor: pointer; font-weight: 700; }
        .modal-close:hover { color: #2D2421; }

        .section-label { font-size: 11.5px; font-weight: 700; color: #4A3934; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 9px; }
        .req { color: #dc2626; }
        .modal-section { margin-bottom: 16px; }

        .size-radio { display: none; }
        .size-label { display: inline-flex; align-items: center; gap: 5px; padding: 7px 15px; border-radius: 10px; border: 1.5px solid #F1E4D6; font-size: 13px; font-weight: 500; cursor: pointer; transition: all 0.12s; font-family: inherit; margin-right: 6px; margin-bottom: 6px; }
        .size-radio:checked + .size-label { background: #FF3B1F; color: #fff; border-color: #FF3B1F; }

        .topping-row { display: flex; align-items: center; justify-content: space-between; padding: 8px 12px; border-radius: 10px; border: 1.5px solid #F1E4D6; font-size: 13px; margin-bottom: 6px; transition: border-color 0.12s, background 0.12s; }
        .topping-row.active { border-color: #FF3B1F; background: #FFF2F0; }
        .topping-name { flex: 1; color: #2D2421; font-weight: 500; }
        .topping-price { font-size: 12px; color: #FF3B1F; font-weight: 700; margin-right: 10px; }
        .t-qty-wrap { display: flex; align-items: center; gap: 6px; }
        .t-btn { width: 26px; height: 26px; border-radius: 8px; border: 1.5px solid #F1E4D6; background: #FFF4EC; font-size: 15px; font-weight: 700; display: flex; align-items: center; justify-content: center; cursor: pointer; color: #4A3934; transition: all 0.12s; }
        .t-btn:hover { border-color: #FF3B1F; color: #FF3B1F; background: #FFF2F0; }
        .t-qty { font-size: 13px; font-weight: 700; color: #2D2421; min-width: 16px; text-align: center; }

        .modal-qty-row { display: flex; align-items: center; gap: 12px; }
        .modal-qty-btn { width: 34px; height: 34px; border-radius: 10px; border: 1.5px solid #F1E4D6; font-size: 20px; font-weight: 600; display: flex; align-items: center; justify-content: center; background: #FFF4EC; cursor: pointer; transition: all 0.12s; color: #4A3934; }
        .modal-qty-btn:hover { border-color: #FF3B1F; color: #FF3B1F; background: #FFF2F0; }
        .modal-qty-num { font-size: 16px; font-weight: 800; color: #2D2421; min-width: 24px; text-align: center; }

        .modal-price-row { background: #FFF4EC; border-radius: 12px; padding: 12px 14px; display: flex; justify-content: space-between; align-items: center; margin: 14px 0; }
        .modal-price-label { font-size: 13px; color: #635752; }
        .modal-price-val { font-size: 17px; font-weight: 800; color: #FF3B1F; }

        .btn-save { width: 100%; padding: 13px; border-radius: 14px; background: linear-gradient(135deg,#FF3B1F,#E02A10); color: #fff; font-size: 14px; font-weight: 700; border: none; cursor: pointer; font-family: inherit; box-shadow: 0 4px 14px rgba(255,59,31,0.3); }
        .btn-save:hover { opacity: 0.9; }

        /* == MODAL XÓA SẢN PHẨM == */
        .confirm-overlay { position: fixed; inset: 0; background: rgba(45,24,16,0.5); display: flex; align-items: center; justify-content: center; z-index: 300; opacity: 0; pointer-events: none; transition: opacity 0.2s; padding: 20px; }
        .confirm-overlay.open { opacity: 1; pointer-events: all; }
        .confirm-box { background: #fff; border-radius: 20px; padding: 28px 26px 22px; width: 100%; max-width: 340px; text-align: center; transform: scale(.94); transition: transform 0.2s; box-shadow: 0 20px 50px rgba(45,24,16,0.25); }
        .confirm-overlay.open .confirm-box { transform: scale(1); }
        .confirm-icon { width: 56px; height: 56px; border-radius: 50%; background: #FEF2F2; color: #ef4444; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; }
        .confirm-title { font-family: var(--font-h); font-size: 15.5px; font-weight: 800; color: #2D2421; margin-bottom: 6px; }
        .confirm-sub { font-size: 13px; color: #635752; line-height: 1.5; margin-bottom: 22px; }
        .confirm-sub b { color: #2D2421; font-weight: 700; }
        .confirm-actions { display: flex; gap: 10px; }
        .btn-cancel, .btn-danger { flex: 1; padding: 11px; border-radius: 12px; font-size: 13.5px; font-weight: 700; cursor: pointer; font-family: inherit; border: none; transition: all 0.15s; }
        .btn-cancel { background: #F7EBDD; color: #4A3934; }
        .btn-cancel:hover { background: #F1E4D6; }
        .btn-danger { background: #ef4444; color: #fff; box-shadow: 0 4px 14px rgba(239,68,68,0.3); }
        .btn-danger:hover { background: #dc2626; }
    </style>
</head>
<body>

<header class="navbar">
    <div class="nav-content">
        <a href="${pageContext.request.contextPath}/user/home" class="logo">
            <h1>FOOD <span>MANAGE</span></h1>
        </a>
        <nav class="nav-links">
            <a href="${pageContext.request.contextPath}/user/home">Trang chủ</a>
            <a href="${pageContext.request.contextPath}/user/donhang">Đơn hàng</a>
            <a href="${pageContext.request.contextPath}/user/dia-chi">Địa chỉ</a>
            <a href="${pageContext.request.contextPath}/user/diem-thuong">Điểm thưởng</a>
        </nav>
        <div class="nav-actions">
            <a href="${pageContext.request.contextPath}/user/thong-bao" class="cart-btn" title="Thông báo">
                <i class="fa-solid fa-bell"></i>
                <span class="cart-count" data-notif-badge style="display:${unreadNotifCount > 0 ? 'inline-block' : 'none'};">${unreadNotifCount}</span>
            </a>
            <div class="avatar-wrap">
                <button type="button" class="avatar-btn" onclick="toggleDropdown()">
                    <c:choose>
                        <c:when test="${not empty account.avatarUrl}">
                            <img src="${account.avatarUrl}" alt="Avatar" style="width:100%;height:100%;object-fit:cover;border-radius:50%;">
                        </c:when>
                        <c:otherwise>${fn:substring(not empty account.fullName ? account.fullName : account.userName, 0, 1)}</c:otherwise>
                    </c:choose>
                </button>
                <div class="avatar-dropdown" id="avatarDropdown">
                    <div class="dd-head">
                        <div class="dd-name">${account.fullName}</div>
                        <div class="dd-email">${account.email}</div>
                    </div>
                    <a href="${pageContext.request.contextPath}/user/thong-tin-ca-nhan" class="dd-link"><i class="fa-solid fa-user"></i> Thông tin cá nhân</a>
                    <a href="${pageContext.request.contextPath}/user/donhang" class="dd-link"><i class="fa-solid fa-box"></i> Đơn hàng</a>
                    <a href="${pageContext.request.contextPath}/user/dia-chi" class="dd-link"><i class="fa-solid fa-location-dot"></i> Địa chỉ</a>
                    <a href="${pageContext.request.contextPath}/user/diem-thuong" class="dd-link"><i class="fa-solid fa-gift"></i> Điểm thưởng</a>
                    <a href="${pageContext.request.contextPath}/user/thong-bao" class="dd-link"><i class="fa-solid fa-bell"></i> Thông báo</a>
                    <a href="${pageContext.request.contextPath}/user/cart" class="dd-link"><i class="fa-solid fa-cart-shopping"></i> Giỏ hàng</a>
                    <a href="${pageContext.request.contextPath}/user/doi-mat-khau" class="dd-link"><i class="fa-solid fa-key"></i> Đổi mật khẩu</a>
                    <div class="dd-divider"></div>
                    <form action="${pageContext.request.contextPath}/logout" method="post">
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}"/>
                        <button type="submit" class="dd-btn"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</header>

<div class="checkout-stepper">
    <span class="step-pill done"><span class="num">✓</span>Chọn món</span>
    <span class="step-line"></span>
    <span class="step-pill current"><span class="num">2</span>Giỏ hàng &amp; Thanh toán</span>
    <span class="step-line"></span>
    <span class="step-pill upcoming"><span class="num">3</span>Theo dõi giao hàng</span>
</div>

<div class="page-wrap">
    <div>
        <c:if test="${param.removed eq '1'}">
            <div class="alert alert-success">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                Đã xóa sản phẩm khỏi giỏ hàng.
            </div>
        </c:if>

        <div class="card">
            <div class="card-header">
                <label class="select-all-wrap" onclick="toggleSelectAll()">
                    <span class="custom-cb" id="cbAll"></span>
                    <span class="select-all-label">Chọn tất cả</span>
                </label>
                <span class="selected-count" id="selectedCount"></span>
                <span class="card-title-right">${fn:length(cartLines)} sản phẩm</span>
            </div>

            <c:choose>
                <c:when test="${empty cartLines}">
                    <div class="empty-state">
                        <div class="empty-icon"><img src="https://cdn.jsdelivr.net/gh/microsoft/fluentui-emoji@main/assets/Shopping%20cart/3D/shopping_cart_3d.png" alt=""></div>
                        <div class="empty-title">Giỏ hàng trống</div>
                        <div class="empty-sub">Hãy thêm món ngon vào giỏ nhé!</div>
                        <a href="${pageContext.request.contextPath}/user/home" class="btn-shop">Khám phá cửa hàng →</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="line" items="${cartLines}">
                        <div class="cart-item selected" id="item-${line.itemId}"
                             data-id="${line.itemId}"
                             data-size-price="${line.size.price}"
                             data-topping-total="${line.lineTotal - line.size.price * line.quantity}">

                            <div class="item-cb-wrap" onclick="toggleItem(${line.itemId})">
                                <span class="custom-cb checked" id="cb-${line.itemId}"></span>
                            </div>

                            <div class="item-img">
                                <c:choose>
                                    <c:when test="${not empty line.product.imageUrl}">
                                        <img src="${fn:escapeXml(line.product.imageUrl)}"
                                             alt="${fn:escapeXml(line.product.productName)}"
                                             onerror="this.style.visibility='hidden'">
                                    </c:when>
                                    <c:otherwise><svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#8A7B6C" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2M7 2v20M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3zM21 15v7"/></svg></c:otherwise>
                                </c:choose>
                            </div>

                            <div class="item-info">
                                <div class="item-name"><c:out value="${line.product.productName}"/></div>
                                <div class="item-size">Size: <c:out value="${line.size.sizeName}"/></div>
                                <c:if test="${not empty line.toppings}">
                                    <div class="item-toppings">
                                        <c:forEach var="tp" items="${line.toppings}">
                                            <span class="topping-tag">+ <c:out value="${tp.name}"/> x${tp.quantity}</span>
                                        </c:forEach>
                                    </div>
                                </c:if>
                                <div class="item-unit-price">
                                    <c:choose>
                                        <c:when test="${line.size.hasSale}">
                                            <span style="color:#FF3B1F;font-weight:700;"><fmt:formatNumber value="${line.size.price}" type="number" maxFractionDigits="0"/>đ</span>
                                            <del style="color:#8A7B6C;font-size:11px;margin-left:4px;"><fmt:formatNumber value="${line.size.originalPrice}" type="number" maxFractionDigits="0"/>đ</del>
                                            / phần
                                        </c:when>
                                        <c:otherwise>
                                            <fmt:formatNumber value="${line.size.price}" type="number" maxFractionDigits="0"/>đ / phần
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="item-actions">
                                    <button class="btn-edit-item" type="button"
                                            onclick="openEditModal(${line.itemId})" style="display:inline-flex;align-items:center;gap:4px;">
                                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.12 2.12 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                        Sửa</button>
                                </div>
                            </div>

                            <div class="item-controls">
                                <form method="post" action="${pageContext.request.contextPath}/user/cart" style="display:contents" id="removeForm-${line.itemId}">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                    <input type="hidden" name="action" value="remove">
                                    <input type="hidden" name="itemId" value="${line.itemId}">
                                    <button type="button" class="btn-remove" title="Xóa"
                                            onclick="openDeleteConfirm(${line.itemId}, '${fn:escapeXml(line.product.productName)}')">✕</button>
                                </form>

                                <div class="qty-row">
                                    <button class="qty-btn" type="button"
                                            onclick="changeQty(${line.itemId}, -1)">−</button>
                                    <span class="qty-num" id="qty-${line.itemId}">${line.quantity}</span>
                                    <button class="qty-btn" type="button"
                                            onclick="changeQty(${line.itemId}, 1)">+</button>
                                </div>
                                <div class="item-total" id="total-${line.itemId}">
                                    <fmt:formatNumber value="${line.lineTotal}" type="number" maxFractionDigits="0"/>đ
                                </div>
                            </div>

                            <form id="qtyForm-${line.itemId}" method="post"
                                  action="${pageContext.request.contextPath}/user/cart" style="display:none">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="action" value="qty">
                                <input type="hidden" name="itemId" value="${line.itemId}">
                                <input type="hidden" name="qty" id="qtyInput-${line.itemId}" value="${line.quantity}">
                            </form>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- SUMMARY -->
    <div>
        <div class="summary-card">
            <div class="summary-title" style="display:flex;align-items:center;gap:7px;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/></svg>
                Tóm tắt đơn hàng
            </div>
            <div class="sel-summary" id="selSummary"></div>
            <div class="sum-row"><span>Tạm tính</span><span id="subtotalDisplay">0đ</span></div>
            <div class="sum-row"><span>Phí giao hàng</span><span id="shippingFeeDisplay">0đ</span></div>
            <div class="fee-note">* Cố định 15.000đ mỗi shop</div>
            <div class="sum-row grand">
                <span>Tổng cộng</span>
                <span class="amt" id="grandDisplay">0đ</span>
            </div>
            <c:choose>
                <c:when test="${not empty cart and not empty cartLines}">
                    <a href="${pageContext.request.contextPath}/checkout?cartId=${cart.id}"
                       class="btn-checkout" id="btnCheckout">
                        Thanh toán (<span id="btnCount">0</span> món)
                    </a>
                </c:when>
                <c:otherwise>
                    <button class="btn-checkout disabled" disabled>Thanh toán</button>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!--  MODAL XÓA SẢN PHẨM  -->
<div class="confirm-overlay" id="deleteOverlay" onclick="closeDeleteOnBg(event)">
    <div class="confirm-box">
        <div class="confirm-icon">
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
        </div>
        <div class="confirm-title">Xóa sản phẩm khỏi giỏ hàng?</div>
        <div class="confirm-sub">Bạn có chắc muốn xóa <b id="deleteItemName"></b> khỏi giỏ hàng không?</div>
        <div class="confirm-actions">
            <button type="button" class="btn-cancel" onclick="closeDeleteConfirm()">Hủy</button>
            <button type="button" class="btn-danger" onclick="confirmDelete()">Xóa</button>
        </div>
    </div>
</div>

<!--  MODAL SỬA SẢN PHẨM  -->
<div class="modal-overlay" id="editOverlay" onclick="closeEditOnBg(event)">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title" id="editModalTitle">Sửa sản phẩm</span>
            <button class="modal-close" onclick="closeEditModal()">×</button>
        </div>

        <form method="post" action="${pageContext.request.contextPath}/user/cart" id="editForm">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="itemId" id="editItemId">

            <!-- SIZE -->
            <div class="modal-section">
                <div class="section-label">Chọn size <span class="req">*</span></div>
                <div id="editSizeOptions"></div>
            </div>

            <!-- TOPPING -->
            <div class="modal-section" id="editToppingSection">
                <div class="section-label">Chọn topping</div>
                <div id="editToppingOptions"></div>
            </div>

            <!-- SỐ LƯỢNG -->
            <div class="modal-section">
                <div class="section-label">Số lượng</div>
                <div class="modal-qty-row">
                    <button type="button" class="modal-qty-btn" onclick="editChangeQty(-1)">−</button>
                    <span class="modal-qty-num" id="editQtyDisplay">1</span>
                    <button type="button" class="modal-qty-btn" onclick="editChangeQty(1)">+</button>
                    <input type="hidden" name="quantity" id="editQtyInput" value="1">
                </div>
            </div>

            <!-- TỔNG -->
            <div class="modal-price-row">
                <span class="modal-price-label">Tạm tính</span>
                <span class="modal-price-val" id="editTotalDisplay">—</span>
            </div>

            <button type="submit" class="btn-save" id="editSaveBtn" style="display:flex;align-items:center;justify-content:center;gap:7px;">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                Lưu thay đổi
            </button>
        </form>
    </div>
</div>

<%-- ===== JS DATA ===== --%>
<script>
function toggleDropdown() {
    document.getElementById('avatarDropdown').classList.toggle('open');
}
window.addEventListener('click', function(e) {
    var wrap = document.querySelector('.avatar-wrap');
    if (wrap && !wrap.contains(e.target)) {
        document.getElementById('avatarDropdown').classList.remove('open');
    }
});

var itemData = {
    <c:forEach var="line" items="${cartLines}" varStatus="st">
    '${line.itemId}': {
        qty: ${line.quantity},
        sizePrice: ${line.size.price},
        toppingTotal: ${line.lineTotal - line.size.price * line.quantity},
        selected: true,
        productName: "${fn:escapeXml(line.product.productName)}",
        shopId: ${line.product.shopId},
        currentSizeId: ${line.size.id},
        sizes: [<c:forEach var="s" items="${line.productSizes}" varStatus="ss">
            {id:${s.id},name:"${fn:escapeXml(s.sizeName)}",price:${s.price},originalPrice:${s.originalPrice},hasSale:${s.hasSale}}<c:if test="${!ss.last}">,</c:if>
        </c:forEach>],
        currentToppings: {<c:forEach var="entry" items="${line.currentToppingQty}" varStatus="et">
            '${entry.key}':${entry.value}<c:if test="${!et.last}">,</c:if>
        </c:forEach>}
    }<c:if test="${!st.last}">,</c:if>
    </c:forEach>
};

var shopToppings = {
    <c:forEach var="entry" items="${shopToppingsMap}" varStatus="et">
    '${entry.key}': [<c:forEach var="t" items="${entry.value}" varStatus="tt">
        {id:${t.id},name:"${fn:escapeXml(t.toppingName)}",price:${t.price}}<c:if test="${!tt.last}">,</c:if>
    </c:forEach>]<c:if test="${!et.last}">,</c:if>
    </c:forEach>
};

var DELIVERY = 15000;

/*  SELECTION  */
function recalc() {
    var subtotal = 0, count = 0, total = Object.keys(itemData).length;
    var shopIds = {};
    Object.keys(itemData).forEach(function(id) {
        var d = itemData[id];
        if (d.selected) { subtotal += d.sizePrice * d.qty + d.toppingTotal; count++; shopIds[d.shopId] = true; }
    });
    var shippingFee = count > 0 ? DELIVERY * Object.keys(shopIds).length : 0;
    fmt(subtotal, 'subtotalDisplay');
    fmt(shippingFee, 'shippingFeeDisplay');
    fmt(subtotal + shippingFee, 'grandDisplay');
    var bc = document.getElementById('btnCount'); if (bc) bc.textContent = count;
    var btn = document.getElementById('btnCheckout');
    if (btn) { btn.classList.toggle('disabled', count === 0); btn.style.pointerEvents = count === 0 ? 'none' : ''; }
    var cbAll = document.getElementById('cbAll');
    if (cbAll) cbAll.className = 'custom-cb' + (count === 0 ? '' : count === total ? ' checked' : ' indeterminate');
    var sc = document.getElementById('selectedCount');
    if (sc) sc.textContent = count > 0 ? 'Đã chọn ' + count + '/' + total : '';
    var banner = document.getElementById('selSummary');
    if (banner) { banner.classList.toggle('visible', count > 0 && count < total); if (count > 0 && count < total) banner.textContent = '✓ Đang tính cho ' + count + ' sản phẩm đã chọn'; }
}

function fmt(val, elId) {
    var el = document.getElementById(elId);
    if (el) el.textContent = Math.round(val).toLocaleString('vi-VN') + 'đ';
}

function toggleItem(itemId) {
    var d = itemData[itemId]; if (!d) return;
    d.selected = !d.selected;
    document.getElementById('cb-' + itemId).className = 'custom-cb' + (d.selected ? ' checked' : '');
    document.getElementById('item-' + itemId).classList.toggle('selected', d.selected);
    recalc();
}

function toggleSelectAll() {
    var allSel = Object.keys(itemData).every(function(id) { return itemData[id].selected; });
    Object.keys(itemData).forEach(function(id) {
        itemData[id].selected = !allSel;
        document.getElementById('cb-' + id).className = 'custom-cb' + (!allSel ? ' checked' : '');
        document.getElementById('item-' + id).classList.toggle('selected', !allSel);
    });
    recalc();
}

function changeQty(itemId, delta) {
    var d = itemData[itemId]; if (!d) return;
    var nq = Math.max(1, d.qty + delta); if (nq === d.qty) return;
    d.qty = nq;
    document.getElementById('qty-' + itemId).textContent = nq;
    fmt(d.sizePrice * nq + d.toppingTotal, 'total-' + itemId);
    document.getElementById('qtyInput-' + itemId).value = nq;
    recalc();
    document.getElementById('qtyForm-' + itemId).submit();
}

recalc();

/*  EDIT MODAL  */
var editItemId = null, editSizePrice = 0, editQty = 1;

function openEditModal(itemId) {
    var d = itemData[itemId]; if (!d) return;
    editItemId = itemId;
    editQty = d.qty;
    editSizePrice = d.sizePrice;

    document.getElementById('editItemId').value = itemId;
    document.getElementById('editModalTitle').textContent = d.productName;
    document.getElementById('editQtyDisplay').textContent = editQty;
    document.getElementById('editQtyInput').value = editQty;

    // SIZE OPTIONS
    var sizeWrap = document.getElementById('editSizeOptions');
    sizeWrap.innerHTML = '';
    d.sizes.forEach(function(s) {
        var radio = document.createElement('input');
        radio.type = 'radio'; radio.name = 'sizeId'; radio.value = s.id;
        radio.id = 'esize_' + s.id; radio.className = 'size-radio';
        if (s.id === d.currentSizeId) { radio.checked = true; editSizePrice = s.price; }
        radio.addEventListener('change', function() { editSizePrice = s.price; updateEditTotal(); });
        var lbl = document.createElement('label');
        lbl.htmlFor = 'esize_' + s.id; lbl.className = 'size-label';
        if (s.hasSale) {
            lbl.innerHTML = s.name + ' (<span style="color:#FF3B1F;font-weight:700;">' + s.price.toLocaleString('vi-VN') + 'đ</span> <del style="color:#8A7B6C;font-size:11px;">' + s.originalPrice.toLocaleString('vi-VN') + 'đ</del>)';
        } else {
            lbl.textContent = s.name + ' (' + s.price.toLocaleString('vi-VN') + 'đ)';
        }
        sizeWrap.appendChild(radio); sizeWrap.appendChild(lbl);
    });

    // TOPPING OPTIONS
    var toppingWrap = document.getElementById('editToppingOptions');
    toppingWrap.innerHTML = '';
    var toppings = shopToppings[d.shopId] || [];
    var tSec = document.getElementById('editToppingSection');
    tSec.style.display = toppings.length > 0 ? 'block' : 'none';
    toppings.forEach(function(t) {
        var currentQty = d.currentToppings[t.id] || 0;
        var row = document.createElement('div');
        row.className = 'topping-row' + (currentQty > 0 ? ' active' : '');
        row.dataset.toppingId = t.id;
        row.dataset.price = t.price;
        row.innerHTML =
            '<span class="topping-name">' + t.name + '</span>' +
            '<span class="topping-price">+' + t.price.toLocaleString('vi-VN') + 'đ</span>' +
            '<div class="t-qty-wrap">' +
                '<button type="button" class="t-btn" onclick="editChangeToppingQty(this,-1)">−</button>' +
                '<span class="t-qty">' + currentQty + '</span>' +
                '<button type="button" class="t-btn" onclick="editChangeToppingQty(this,1)">+</button>' +
            '</div>';
        toppingWrap.appendChild(row);
    });

    updateEditTotal();
    document.getElementById('editOverlay').classList.add('open');
}

function closeEditModal() { document.getElementById('editOverlay').classList.remove('open'); }
function closeEditOnBg(e) { if (e.target === document.getElementById('editOverlay')) closeEditModal(); }

var pendingDeleteId = null;
function openDeleteConfirm(itemId, name) {
    pendingDeleteId = itemId;
    document.getElementById('deleteItemName').textContent = name;
    document.getElementById('deleteOverlay').classList.add('open');
}
function closeDeleteConfirm() {
    pendingDeleteId = null;
    document.getElementById('deleteOverlay').classList.remove('open');
}
function closeDeleteOnBg(e) { if (e.target === document.getElementById('deleteOverlay')) closeDeleteConfirm(); }
function confirmDelete() {
    if (pendingDeleteId === null) return;
    document.getElementById('removeForm-' + pendingDeleteId).submit();
}

function editChangeQty(delta) {
    editQty = Math.max(1, editQty + delta);
    document.getElementById('editQtyDisplay').textContent = editQty;
    document.getElementById('editQtyInput').value = editQty;
    updateEditTotal();
}

function editChangeToppingQty(btn, delta) {
    var row = btn.closest('.topping-row');
    var qEl = row.querySelector('.t-qty');
    var next = Math.max(0, parseInt(qEl.textContent) + delta);
    qEl.textContent = next;
    row.classList.toggle('active', next > 0);
    updateEditTotal();
}

function updateEditTotal() {
    var toppingSum = 0;
    document.querySelectorAll('#editToppingOptions .topping-row').forEach(function(row) {
        var q = parseInt(row.querySelector('.t-qty').textContent) || 0;
        if (q > 0) toppingSum += parseFloat(row.dataset.price) * q;
    });
    var total = editSizePrice * editQty + toppingSum;
    document.getElementById('editTotalDisplay').textContent = total > 0 ? total.toLocaleString('vi-VN') + 'đ' : '—';
}

document.getElementById('editForm').addEventListener('submit', function() {
    // Inject topping hidden inputs
    document.querySelectorAll('input[name="toppingId"]').forEach(function(el) { el.remove(); });
    document.querySelectorAll('input[name="toppingQty"]').forEach(function(el) { el.remove(); });
    document.querySelectorAll('#editToppingOptions .topping-row').forEach(function(row) {
        var q = parseInt(row.querySelector('.t-qty').textContent) || 0;
        if (q > 0) {
            var h1 = document.createElement('input'); h1.type='hidden'; h1.name='toppingId'; h1.value=row.dataset.toppingId;
            var h2 = document.createElement('input'); h2.type='hidden'; h2.name='toppingQty'; h2.value=q;
            document.getElementById('editForm').appendChild(h1);
            document.getElementById('editForm').appendChild(h2);
        }
    });
    var checked = document.querySelector('#editSizeOptions input[name="sizeId"]:checked');
    if (!checked) { event.preventDefault(); alert('Vui lòng chọn size!'); }
});
</script>
<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/notifications-ws.js"></script>
</body>
</html>
