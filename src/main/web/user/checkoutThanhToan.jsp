<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Plus Jakarta Sans', 'Inter', -apple-system, sans-serif; background: #FFF9F2; min-height: 100vh; }
        .nav-title, .card-title, .total-row.grand, h1, h2, h3 { font-family: 'Quicksand', 'Plus Jakarta Sans', sans-serif; }

        /* NAVBAR */
        .navbar { background: #fff; border-bottom: 1px solid #F1E4D6; box-shadow: 0 1px 6px rgba(99,44,20,0.06); padding: 0 24px; height: 60px; display: flex; align-items: center; gap: 14px; }
        .nav-logo { display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .nav-logo-badge { width: 36px; height: 36px; border-radius: 10px; background: linear-gradient(135deg,#FF3B1F,#E02A10); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 12px; }
        .nav-title { font-size: 16px; font-weight: 800; color: #2D2421; }
        .nav-right { margin-left: auto; display: flex; align-items: center; gap: 16px; }
        .nav-link { font-size: 13px; font-weight: 500; color: #635752; text-decoration: none; transition: color 0.2s; }
        .nav-link:hover { color: #FF3B1F; }

        /* LAYOUT */
        .page-wrap { max-width: 860px; margin: 0 auto; padding: 32px 20px; display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: start; }
        @media (max-width: 700px) { .page-wrap { grid-template-columns: 1fr; } }

        /* CARD */
        .card { background: #fff; border-radius: 20px; border: 1px solid #F1E4D6; box-shadow: 0 2px 10px rgba(99,44,20,0.06); padding: 24px; margin-bottom: 18px; }
        .card:last-child { margin-bottom: 0; }
        .card-title { font-size: 15px; font-weight: 800; color: #2D2421; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }

        /* ALERT */
        .alert { display: flex; align-items: center; gap: 10px; border-radius: 12px; padding: 13px 16px; font-size: 13px; font-weight: 500; margin-bottom: 18px; }
        .alert-error { background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; }

        /* ORDER TABLE */
        .order-table { width: 100%; border-collapse: collapse; }
        .order-table th { font-size: 11px; font-weight: 700; color: #8A7B6C; text-transform: uppercase; letter-spacing: 0.05em; padding: 0 0 10px; text-align: left; border-bottom: 1px solid #F1E4D6; }
        .order-table th.r, .order-table td.r { text-align: right; }
        .order-table td { padding: 11px 0; font-size: 13.5px; color: #4A3934; border-bottom: 1px solid #FFF9F2; }
        .shop-row td { font-weight: 700; color: #2D2421; font-size: 12.5px; padding-top: 14px; }
        .shop-row td span { background: #FFF4EC; padding: 3px 10px; border-radius: 8px; }
        .prod-name { font-weight: 600; color: #2D2421; }
        .size-tag { font-size: 11.5px; color: #8A7B6C; font-weight: 500; }

        .qty-mini { display: inline-flex; align-items: center; gap: 2px; background: #FFF9F2; border: 1px solid #F1E4D6; border-radius: 50px; padding: 2px; }
        .qty-mini-btn { width: 24px; height: 24px; border-radius: 50%; border: none; background: #fff; box-shadow: 0 1px 3px rgba(99,44,20,.12); font-size: 13px; font-weight: 700; display: inline-flex; align-items: center; justify-content: center; cursor: pointer; color: #4A3934; padding: 0; font-family: inherit; transition: all 0.12s; }
        .qty-mini-btn:hover:not(:disabled) { border-color: #FF3B1F; color: #FF3B1F; background: #FFF2F0; }
        .qty-mini-btn:disabled { opacity: .4; cursor: not-allowed; }
        .qty-mini-val { font-size: 13px; font-weight: 700; color: #2D2421; min-width: 16px; text-align: center; display: inline-block; }
        .btn-remove-mini { background: none; border: none; color: #E8D7C3; cursor: pointer; font-size: 15px; padding: 2px 4px; transition: color 0.15s; }
        .btn-remove-mini:hover { color: #ef4444; }

        .total-block { margin-top: 14px; padding-top: 14px; border-top: 2px solid #FFF4EC; }
        .total-row { display: flex; justify-content: space-between; align-items: center; font-size: 13.5px; color: #635752; margin-bottom: 6px; }
        .total-row.grand { font-size: 16px; font-weight: 800; color: #2D2421; margin-top: 8px; }
        .total-row.grand .amt { color: #FF3B1F; }
        .fee-note { font-size: 11.5px; color: #8A7B6C; margin-top: 4px; }

        .form-group { margin-bottom: 14px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: #4A3934; margin-bottom: 6px; }
        .form-group input, .form-group select {
            width: 100%;
            padding: 10px 13px;
            border: 1.5px solid #F1E4D6;
            border-radius: 10px;
            font-size: 13.5px;
            font-family: inherit;
            color: #2D2421;
            transition: border-color 0.2s;
        }
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #FF3B1F;
        }

        .btn {
            display: inline-block;
            padding: 10px 22px;
            border-radius: 10px;
            text-decoration: none;
            font-size: 14px;
            cursor: pointer;
            border: none;
            font-family: inherit;
        }
        .btn-primary {
            background: linear-gradient(135deg,#FF3B1F,#E02A10);
            color: #fff; width: 100%; font-size: 15px; font-weight: 700; padding: 13px;
            display: flex; align-items: center; justify-content: center; gap: 8px;
            box-shadow: 0 4px 12px rgba(255,59,31,0.28);
            transition: transform 0.15s, box-shadow 0.15s;
        }
        .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 6px 16px rgba(255,59,31,0.35); }
        .btn-primary:disabled { background: #E8D7C3; box-shadow: none; cursor: not-allowed; transform: none; }

        .btn-secondary { background: #FFF4EC; color: #4A3934; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; }
        .btn-secondary:hover { background: #F1E4D6; }
        .location-map-wrap { margin-top: 10px; }
        .location-search-row { display: flex; gap: 8px; margin-bottom: 8px; }
        .location-search-row input { flex: 1; }
        #checkoutLocationMap { height: 240px; border-radius: 10px; overflow: hidden; }
        .location-hint { font-size: 11.5px; color: #8A7B6C; margin-top: 6px; }
        .best-voucher-banner { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; background: #fff7ed; border: 1px dashed #f97316; color: #9a3412; border-radius: 8px; padding: 10px 12px; font-size: 12.5px; font-weight: 600; margin-bottom: 8px; }
        .btn-use-voucher { margin-left: auto; background: #f97316; color: #fff; border: none; border-radius: 6px; padding: 6px 12px; font-size: 12px; font-weight: 700; cursor: pointer; }
        .btn-use-voucher:hover { background: #ea580c; }

        /* PAYMENT METHOD CARDS */
        .pay-method-list { display: flex; flex-direction: column; gap: 8px; }
        .pay-method-card { display: flex; align-items: center; gap: 12px; padding: 12px 14px; border: 2px solid #F1E4D6; border-radius: 14px; cursor: pointer; transition: all .15s; background: #fff; }
        .pay-method-card:has(input:checked) { border-color: #FF3B1F; background: #FFF2F0; }
        .pm-icon { width: 34px; height: 34px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .pm-icon-cod { background: #EAFBF1; color: #15803D; }
        .pm-icon-payos { background: #EAF1FE; color: #1D4ED8; }
        .pm-text { flex: 1; display: flex; flex-direction: column; gap: 2px; }
        .pm-text strong { font-size: 13px; color: #2D2421; font-weight: 800; }
        .pm-text span { font-size: 11.5px; color: #8A7B6C; }
        .pay-method-card input[type="radio"] { accent-color: #FF3B1F; width: 17px; height: 17px; cursor: pointer; flex-shrink: 0; }

        /* CHECKOUT STEPPER */
        .checkout-stepper { display: flex; align-items: center; gap: 8px; max-width: 860px; margin: 18px auto 0; padding: 0 20px; font-size: 12px; font-family: 'Quicksand', sans-serif; font-weight: 700; }
        .step-pill { display: flex; align-items: center; gap: 6px; padding: 6px 14px; border-radius: 50px; white-space: nowrap; }
        .step-pill .num { width: 16px; height: 16px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10px; flex-shrink: 0; }
        .step-pill.done { background: #EAFBF1; color: #15803D; }
        .step-pill.done .num { background: #15803D; color: #fff; }
        .step-pill.current { background: #FFF2F0; color: #FF3B1F; box-shadow: 0 0 0 3px rgba(255,59,31,.1); }
        .step-pill.current .num { background: #FF3B1F; color: #fff; }
        .step-pill.upcoming { background: #F1E4D6; color: #8A7B6C; }
        .step-pill.upcoming .num { background: #E8D7C3; color: #8A7B6C; }
        .step-line { flex: 1; max-width: 28px; height: 2px; background: #F1E4D6; }
    </style>
</head>
<body>

<nav class="navbar">
    <a href="${pageContext.request.contextPath}/user/home" class="nav-logo">
        <div class="nav-logo-badge">FM</div>
    </a>
    <span class="nav-title">Thanh toán</span>
    <div class="nav-right">
        <a href="${pageContext.request.contextPath}/user/donhang" class="nav-link" style="display:inline-flex;align-items:center;gap:5px;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
            Đơn hàng
        </a>
        <a href="${pageContext.request.contextPath}/user/home" class="nav-link">← Trang chủ</a>
    </div>
</nav>

<div class="checkout-stepper">
    <span class="step-pill done"><span class="num">✓</span>Chọn món</span>
    <span class="step-line"></span>
    <span class="step-pill current"><span class="num">2</span>Giỏ hàng &amp; Thanh toán</span>
    <span class="step-line"></span>
    <span class="step-pill upcoming"><span class="num">3</span>Theo dõi giao hàng</span>
</div>

<div class="page-wrap">

    <!-- LEFT: order details -->
    <div>
        <c:if test="${not empty error}">
            <div class="alert alert-error"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg> <c:out value="${error}"/></div>
        </c:if>

        <div class="card">
            <div class="card-title">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
                Giỏ hàng #${cart.id}</div>
            <table class="order-table">
                <thead>
                    <tr>
                        <th>Sản phẩm</th>
                        <th class="r">SL</th>
                        <th class="r">Thành tiền</th>
                        <th class="r"></th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${lines}" var="line" varStatus="s">
                        <c:if test="${s.first or line.shopName ne lines[s.index - 1].shopName}">
                            <tr class="shop-row"><td colspan="4"><span style="display:inline-flex;align-items:center;gap:5px;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l1-5h16l1 5M3 9a2 2 0 0 0 4 0m-4 0a2 2 0 0 0 2 2m2-2a2 2 0 0 0 4 0m-4 0a2 2 0 0 0 2 2m2-2a2 2 0 0 0 4 0m-4 0a2 2 0 0 0 2 2m2-2a2 2 0 0 0 4 0m-4 0a2 2 0 0 0 2 2M5 11v9h14v-9"/></svg> <c:out value="${line.shopName}"/></span></td></tr>
                        </c:if>
                        <tr>
                            <td>
                                <div class="prod-name"><c:out value="${line.productName}"/></div>
                                <div class="size-tag"><c:out value="${line.sizeName}"/>
                                    <c:if test="${line.hasSale}">
                                        — <span style="color:#FF3B1F;font-weight:700;"><fmt:formatNumber value="${line.unitPrice}" type="number" maxFractionDigits="0"/>đ</span>
                                        <del style="color:#8A7B6C;"><fmt:formatNumber value="${line.originalPrice}" type="number" maxFractionDigits="0"/>đ</del>
                                        <span style="font-size:10px;background:linear-gradient(135deg,#ff4444,#ff6b35);color:#fff;padding:1px 6px;border-radius:4px;margin-left:3px;">⚡Sale</span>
                                    </c:if>
                                </div>
                                <c:forEach var="tp" items="${line.toppings}">
                                    <div class="size-tag" style="color:#FF3B1F;">
                                        + <c:out value="${tp.toppingName}"/>
                                        (<fmt:formatNumber value="${tp.price}" type="number" maxFractionDigits="0"/>đ
                                        <c:if test="${tp.qty > 1}">× ${tp.qty}</c:if>)
                                    </div>
                                </c:forEach>
                            </td>
                            <td class="r">
                                <div class="qty-mini">
                                    <form method="post" action="${pageContext.request.contextPath}/user/cart" style="display:inline">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="qty">
                                        <input type="hidden" name="itemId" value="${line.itemId}">
                                        <input type="hidden" name="returnTo" value="checkout">
                                        <input type="hidden" name="cartId" value="${cart.id}">
                                        <input type="hidden" name="qty" value="${line.quantity - 1}">
                                        <button type="submit" class="qty-mini-btn" ${line.quantity <= 1 ? 'disabled' : ''}>−</button>
                                    </form>
                                    <span class="qty-mini-val">${line.quantity}</span>
                                    <form method="post" action="${pageContext.request.contextPath}/user/cart" style="display:inline">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="qty">
                                        <input type="hidden" name="itemId" value="${line.itemId}">
                                        <input type="hidden" name="returnTo" value="checkout">
                                        <input type="hidden" name="cartId" value="${cart.id}">
                                        <input type="hidden" name="qty" value="${line.quantity + 1}">
                                        <button type="submit" class="qty-mini-btn">+</button>
                                    </form>
                                </div>
                            </td>
                            <td class="r"><fmt:formatNumber value="${line.lineTotal}" type="number" maxFractionDigits="0"/>đ</td>
                            <td class="r">
                                <form method="post" action="${pageContext.request.contextPath}/user/cart" style="display:inline"
                                      onsubmit="return confirm('Xóa sản phẩm này khỏi giỏ hàng?')">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                    <input type="hidden" name="action" value="remove">
                                    <input type="hidden" name="itemId" value="${line.itemId}">
                                    <input type="hidden" name="returnTo" value="checkout">
                                    <input type="hidden" name="cartId" value="${cart.id}">
                                    <button type="submit" class="btn-remove-mini" title="Xóa">✕</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <div class="total-block">
                <div class="total-row"><span>Tạm tính</span><span><fmt:formatNumber value="${subtotal}" type="number" maxFractionDigits="0"/>đ</span></div>
                <div class="total-row"><span>Khoảng cách</span><span id="distanceDisplay" style="font-weight:600;">--</span></div>
                <div class="total-row"><span>Phí giao hàng</span><span id="feeDisplay" style="font-weight:600;">--</span></div>
                <div class="total-row grand"><span>Tổng thanh toán</span><span class="amt" id="grandTotalDisplay"><fmt:formatNumber value="${subtotal}" type="number" maxFractionDigits="0"/>đ</span></div>
                <div class="fee-note" id="feeNote">* Vui lòng chọn vị trí giao hàng trên bản đồ để xem khoảng cách và phí ship chính xác (5.000đ/km).</div>
            </div>
        </div>
    </div>

    <!-- RIGHT: form + payment -->
    <div class="sidebar">
        <form method="post" action="${pageContext.request.contextPath}/checkout" id="checkoutForm" onsubmit="return submitCheckoutOnce();">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="checkoutToken" value="${checkoutToken}">
            <input type="hidden" name="cartId" value="${cart.id}">

            <div class="card">
                <div class="card-title">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                    Thông tin nhận hàng</div>

            <div class="form-group">
                <label>Tên người nhận</label>
                <input type="text" name="receiverName" value="${not empty param.receiverName ? param.receiverName : defaultAddress.receiverName}" required>
            </div>
            <div class="form-group">
                <label>Số điện thoại</label>
                <input type="text" name="receiverPhone" value="${not empty param.receiverPhone ? param.receiverPhone : defaultAddress.receiverPhone}" required>
            </div>
            <div class="form-group">
                <label>Địa chỉ giao hàng</label>
                <input type="text" id="shippingAddress" name="shippingAddress"
                       value="${fn:escapeXml(not empty param.shippingAddress ? param.shippingAddress : defaultAddress.fullAddress)}" required>
            </div>
            <div class="form-group">
                <label>Vị trí trên bản đồ</label>
                <button type="button" class="btn btn-secondary" id="checkoutLocationToggleBtn"
                        data-preset-lat="${not empty param.locationX ? param.locationX : (defaultAddress.locationX != null ? defaultAddress.locationX : '')}"
                        data-preset-lng="${not empty param.locationY ? param.locationY : (defaultAddress.locationY != null ? defaultAddress.locationY : '')}">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                    Chọn vị trí trên bản đồ</button>
                <div id="checkoutLocationMapWrap" class="location-map-wrap" style="display:none;">
                    <div class="location-search-row">
                        <input type="text" id="checkoutLocationSearchInput" placeholder="Tìm địa chỉ...">
                        <button type="button" id="checkoutLocationSearchBtn" class="btn btn-secondary">Tìm</button>
                        <button type="button" id="checkoutCurrentLocationBtn" class="btn btn-secondary" style="color:#FF3B1F;border-color:#FF3B1F;font-weight:700;white-space:nowrap;">📍 Vị trí hiện tại</button>
                    </div>
                    <div id="checkoutLocationMap"></div>
                </div>
                <input type="hidden" name="locationX" id="checkoutLocationXInput"
                       value="${not empty param.locationX ? param.locationX : (defaultAddress.locationX != null ? defaultAddress.locationX : '')}">
                <input type="hidden" name="locationY" id="checkoutLocationYInput"
                       value="${not empty param.locationY ? param.locationY : (defaultAddress.locationY != null ? defaultAddress.locationY : '')}">
                <p class="location-hint">Không bắt buộc — nhưng nếu chọn, shipper và bạn sẽ thấy đúng điểm giao trên bản đồ theo dõi realtime.</p>
            </div>
            <div class="form-group">
                <label>Phương thức thanh toán</label>
                <div class="pay-method-list">
                    <label class="pay-method-card">
                        <div class="pm-icon pm-icon-cod"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2"/><path d="M6 12h.01M18 12h.01"/></svg></div>
                        <div class="pm-text"><strong>Thanh toán khi nhận hàng</strong><span>Trả tiền mặt trực tiếp cho shipper (COD)</span></div>
                        <input type="radio" name="paymentMethod" value="COD" ${param.paymentMethod eq 'PAYOS' ? '' : 'checked'} required>
                    </label>
                    <label class="pay-method-card">
                        <div class="pm-icon pm-icon-payos"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><path d="M14 14h3v3h-3zM19 14h2v2h-2zM14 19h2v2h-2zM19 19h2v2h-2z"/></svg></div>
                        <div class="pm-text"><strong>Thanh toán online qua PayOS</strong><span>Quét mã QR chuyển khoản, xác nhận tự động</span></div>
                        <input type="radio" name="paymentMethod" value="PAYOS" ${param.paymentMethod eq 'PAYOS' ? 'checked' : ''} required>
                    </label>
                </div>
            </div>
            <div class="form-group">
                <label>Mã giảm giá / Voucher (không bắt buộc)</label>
                <c:if test="${not empty bestVoucher && empty param.voucherCode}">
                    <div class="best-voucher-banner">
                        🎁 Bạn có thể dùng mã <strong><c:out value="${bestVoucher.code}"/></strong> để giảm
                        <fmt:formatNumber value="${bestVoucherDiscount}" type="number" maxFractionDigits="0"/>đ
                        <button type="button" class="btn-use-voucher" onclick="document.getElementById('voucherCodeInput').value='${fn:escapeXml(bestVoucher.code)}'">Dùng ngay</button>
                    </div>
                </c:if>
                <input type="text" name="voucherCode" id="voucherCodeInput" style="text-transform:uppercase;font-weight:700;letter-spacing:.5px;"
                       value="${fn:escapeXml(param.voucherCode)}" placeholder="VD: SALE50K">
                <p class="location-hint">Mã giảm giá tự động áp dụng khi đặt hàng — chỉ áp dụng cho đơn hàng của shop đầu tiên trong giỏ nếu giỏ có nhiều shop. <a href="${pageContext.request.contextPath}/user/diem-thuong" style="color:#FF3B1F;font-weight:700;">Đổi điểm lấy voucher →</a></p>
            </div>
            <div class="form-group">
                <label>Thời gian giao hàng</label>
                <div style="display:flex;gap:8px;margin-bottom:8px;">
                    <button type="button" id="btnDeliveryNow"
                            onclick="setDeliveryMode('now')"
                            style="flex:1;padding:9px;border-radius:10px;border:2px solid #FF3B1F;background:#FFF4EC;color:#FF3B1F;font-weight:700;font-size:13px;cursor:pointer;">
                        🛵 Giao ngay
                    </button>
                    <button type="button" id="btnDeliveryScheduled"
                            onclick="setDeliveryMode('scheduled')"
                            style="flex:1;padding:9px;border-radius:10px;border:2px solid #F1E4D6;background:#FFF9F2;color:#635752;font-weight:700;font-size:13px;cursor:pointer;">
                        🕐 Hẹn giờ
                    </button>
                </div>
                <div id="scheduledAtWrap" style="display:none;">
                    <input type="datetime-local" name="scheduledAt" id="scheduledAtInput"
                           style="width:100%;padding:10px 13px;border:1.5px solid #F1E4D6;border-radius:10px;font-size:13.5px;font-family:inherit;color:#2D2421;">
                    <p class="location-hint" style="margin-top:4px;">Đơn hàng sẽ được gửi đến shipper vào thời điểm bạn chọn.</p>
                </div>
            </div>
            <div class="form-group">
                <label>Phí giao hàng (đ) — áp dụng cho mỗi shop trong đơn</label>
                <input type="text" id="sidebarFeeDisplay" value="Chưa chọn vị trí giao hàng" readonly disabled>
                <p class="location-hint" id="sidebarFeeHint">Chọn vị trí giao hàng trên bản đồ ở trên để tính phí ship theo khoảng cách
                    shop → điểm giao (5.000đ/km). Đơn hàng sẽ bị từ chối nếu shop cách vị trí giao hàng quá 20km.</p>
            </div>

        </div>

        <button type="submit" class="btn btn-primary" id="checkoutSubmitBtn" disabled>
            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            <span id="checkoutSubmitBtnLabel">Vui lòng chọn vị trí giao hàng</span></button>
        <p style="text-align:center;font-size:11px;color:#8A7B6C;margin-top:10px;line-height:1.6;">
            Có sự cố với đơn hàng? Bạn có thể gửi khiếu nại trực tiếp trong mục
            <a href="${pageContext.request.contextPath}/user/donhang" style="color:#FF3B1F;font-weight:700;">Đơn hàng của tôi</a> sau khi đặt.
        </p>
    </form>
</div>
<script>
    function setDeliveryMode(mode) {
        var wrap = document.getElementById('scheduledAtWrap');
        var input = document.getElementById('scheduledAtInput');
        var btnNow = document.getElementById('btnDeliveryNow');
        var btnSch = document.getElementById('btnDeliveryScheduled');
        var activeStyle = 'border:2px solid #FF3B1F;background:#FFF4EC;color:#FF3B1F;';
        var inactiveStyle = 'border:2px solid #F1E4D6;background:#FFF9F2;color:#635752;';
        if (mode === 'now') {
            wrap.style.display = 'none';
            input.name = '';
            btnNow.style.cssText = 'flex:1;padding:9px;border-radius:10px;font-weight:700;font-size:13px;cursor:pointer;' + activeStyle;
            btnSch.style.cssText = 'flex:1;padding:9px;border-radius:10px;font-weight:700;font-size:13px;cursor:pointer;' + inactiveStyle;
        } else {
            wrap.style.display = 'block';
            input.name = 'scheduledAt';
            if (!input.min) {
                var now = new Date(Date.now() + 30 * 60000);
                input.min = now.toISOString().slice(0, 16);
                if (!input.value) input.value = now.toISOString().slice(0, 16);
            }
            btnNow.style.cssText = 'flex:1;padding:9px;border-radius:10px;font-weight:700;font-size:13px;cursor:pointer;' + inactiveStyle;
            btnSch.style.cssText = 'flex:1;padding:9px;border-radius:10px;font-weight:700;font-size:13px;cursor:pointer;' + activeStyle;
        }
    }

    // Chong double-submit (bam 2 lan/double-click) tao trung don hang.
    function submitCheckoutOnce() {
        var btn = document.getElementById('checkoutSubmitBtn');
        if (btn.dataset.submitting === '1') {
            return false;
        }
        btn.dataset.submitting = '1';
        btn.disabled = true;
        btn.textContent = 'Đang xử lý...';
        return true;
    }
</script>

</div>

<script>
    // Tinh phi ship truoc khi dat hang: chi hien phi/cho phep dat hang SAU KHI khach chon vi tri tren ban do.
    var FEE_PER_KM = ${feePerKm};
    var FIXED_DELIVERY_FEE = ${fixedDeliveryFee};
    var MAX_DELIVERY_DISTANCE_KM = ${maxDeliveryDistanceKm};
    var SHOP_LOCATIONS = ${shopLocationsJson};
    var SUBTOTAL = ${subtotal};

    function haversineKm(lat1, lng1, lat2, lng2) {
        var R = 6371;
        var dLat = (lat2 - lat1) * Math.PI / 180;
        var dLng = (lng2 - lng1) * Math.PI / 180;
        var a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
            + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    function formatVnd(n) {
        return Math.round(n).toLocaleString('vi-VN') + 'đ';
    }

    function formatKm(d) {
        if (d === null || d === undefined || isNaN(d)) return '--';
        var rounded = Math.round(d * 10) / 10;
        return (rounded % 1 === 0 ? rounded.toFixed(0) : rounded.toFixed(1)) + ' km';
    }

    function updateDeliveryFeeDisplay(lat, lng) {
        var submitBtn = document.getElementById('checkoutSubmitBtn');
        var submitLabel = document.getElementById('checkoutSubmitBtnLabel');
        var distanceDisplay = document.getElementById('distanceDisplay');
        var feeDisplay = document.getElementById('feeDisplay');
        var grandTotalDisplay = document.getElementById('grandTotalDisplay');
        var sidebarFeeDisplay = document.getElementById('sidebarFeeDisplay');
        var feeNote = document.getElementById('feeNote');
        var sidebarHint = document.getElementById('sidebarFeeHint');

        if (lat === null || lng === null || isNaN(lat) || isNaN(lng)) {
            distanceDisplay.textContent = '--';
            feeDisplay.textContent = '--';
            grandTotalDisplay.textContent = formatVnd(SUBTOTAL);
            sidebarFeeDisplay.value = 'Chưa chọn vị trí giao hàng';
            feeNote.textContent = '* Vui lòng chọn vị trí giao hàng trên bản đồ để xem khoảng cách và phí ship chính xác (5.000đ/km).';
            feeNote.style.color = '';
            sidebarHint.textContent = 'Chọn vị trí giao hàng trên bản đồ ở trên để tính phí ship theo khoảng cách (5.000đ/km).';
            sidebarHint.style.color = '';
            submitBtn.disabled = true;
            submitLabel.textContent = 'Vui lòng chọn vị trí giao hàng';
            return;
        }

        var shopMissingLocation = null;
        var totalFee = 0;
        var maxDistanceKm = 0;
        var overLimit = false;

        SHOP_LOCATIONS.forEach(function (s) {
            if (s.lat === null || s.lng === null || s.lat === undefined || s.lng === undefined) {
                shopMissingLocation = s.name || 'Shop';
                return;
            }
            var d = haversineKm(s.lat, s.lng, lat, lng);
            if (d > maxDistanceKm) maxDistanceKm = d;
            if (d > MAX_DELIVERY_DISTANCE_KM) overLimit = true;
            totalFee += d * FEE_PER_KM;
        });

        if (shopMissingLocation) {
            distanceDisplay.textContent = '--';
            feeDisplay.textContent = '--';
            grandTotalDisplay.textContent = formatVnd(SUBTOTAL);
            sidebarFeeDisplay.value = 'Shop chưa cập nhật vị trí';
            var missingMsg = '⚠️ Cửa hàng "' + shopMissingLocation + '" chưa cập nhật vị trí trên bản đồ. Vui lòng chọn shop khác.';
            feeNote.textContent = missingMsg;
            feeNote.style.color = '#dc2626';
            sidebarHint.textContent = missingMsg;
            sidebarHint.style.color = '#dc2626';
            submitBtn.disabled = true;
            submitLabel.textContent = 'Shop chưa cập nhật vị trí bản đồ';
            return;
        }

        var formattedDist = formatKm(maxDistanceKm);
        distanceDisplay.textContent = formattedDist;

        var feeDetailText = '';
        if (SHOP_LOCATIONS.length === 1) {
            feeDetailText = formatVnd(totalFee) + ' (5.000đ × ' + formattedDist + ')';
        } else {
            feeDetailText = formatVnd(totalFee) + ' (' + SHOP_LOCATIONS.length + ' shop)';
        }

        feeDisplay.textContent = feeDetailText;
        grandTotalDisplay.textContent = formatVnd(SUBTOTAL + totalFee);
        sidebarFeeDisplay.value = feeDetailText;

        if (overLimit) {
            var msg = '⚠️ Vị trí của bạn cách vị trí của Shop ' + formattedDist + ' (vượt quá 20km), hệ thống tự động từ chối nhận đơn.';
            feeNote.textContent = msg;
            feeNote.style.color = '#dc2626';
            sidebarHint.textContent = msg;
            sidebarHint.style.color = '#dc2626';
            submitBtn.disabled = true;
            submitLabel.textContent = 'Tự động từ chối đơn (vị trí cách shop > 20km)';
        } else {
            feeNote.textContent = '* Phí giao hàng tính theo khoảng cách shop → điểm giao (5.000đ/km, ' + formattedDist + ')';
            feeNote.style.color = '';
            sidebarHint.textContent = 'Phí ship tính theo khoảng cách: ' + feeDetailText;
            sidebarHint.style.color = '';
            submitBtn.disabled = false;
            submitLabel.textContent = 'Xác nhận thanh toán';
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        var presetX = document.getElementById('checkoutLocationXInput').value;
        var presetY = document.getElementById('checkoutLocationYInput').value;
        if (presetX && presetY) {
            updateDeliveryFeeDisplay(parseFloat(presetX), parseFloat(presetY));
        } else {
            updateDeliveryFeeDisplay(null, null);
        }
    });

    function initCheckoutLocationMap(presetLat, presetLng) {
        var mapContainer = document.getElementById('checkoutLocationMap');
        if (mapContainer.dataset.initialized === 'true') {
            var existingMap = mapContainer._leafletMap;
            setTimeout(function () { existingMap.invalidateSize(); }, 50);
            return;
        }
        mapContainer.dataset.initialized = 'true';

        var defaultLat = 21.0285, defaultLng = 105.8542;
        var startLat = presetLat ? parseFloat(presetLat) : defaultLat;
        var startLng = presetLng ? parseFloat(presetLng) : defaultLng;

        var map = L.map('checkoutLocationMap').setView([startLat, startLng], 15);
        mapContainer._leafletMap = map;

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; OpenStreetMap contributors',
            maxZoom: 19
        }).addTo(map);

        var marker = null;
        var reverseGeocodeTimer = null;

        function updateCoords(lat, lng) {
            document.getElementById('checkoutLocationXInput').value = lat;
            document.getElementById('checkoutLocationYInput').value = lng;
            updateDeliveryFeeDisplay(lat, lng);
        }

        function reverseGeocode(lat, lng) {
            fetch('https://nominatim.openstreetmap.org/reverse?format=json&lat=' + lat + '&lon=' + lng)
                .then(function (res) { return res.json(); })
                .then(function (data) {
                    if (data && data.display_name) {
                        document.getElementById('shippingAddress').value = data.display_name;
                    }
                })
                .catch(function () {
                    console.warn('Khong the lay dia chi tu toa do');
                });
        }

        function reverseGeocodeDebounced(lat, lng) {
            clearTimeout(reverseGeocodeTimer);
            reverseGeocodeTimer = setTimeout(function () {
                reverseGeocode(lat, lng);
            }, 500);
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

        map.on('click', function (e) {
            placeMarker(e.latlng.lat, e.latlng.lng, true);
        });

        if (presetLat && presetLng) {
            placeMarker(startLat, startLng, false);
        } else if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                function (pos) { map.setView([pos.coords.latitude, pos.coords.longitude], 15); },
                function () { /* denied - keep default center */ },
                { timeout: 5000 }
            );
        }

        document.getElementById('checkoutLocationSearchBtn').addEventListener('click', function () {
            var query = document.getElementById('checkoutLocationSearchInput').value.trim();
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
                .catch(function () {
                    alert('Không tìm được địa chỉ, vui lòng thử lại');
                });
        });

        var currentLocBtn = document.getElementById('checkoutCurrentLocationBtn');
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

    function toggleCheckoutLocationMap() {
        var wrapper = document.getElementById('checkoutLocationMapWrap');
        wrapper.style.display = 'block';
        var btn = document.getElementById('checkoutLocationToggleBtn');
        var presetLat = btn.dataset.presetLat || null;
        var presetLng = btn.dataset.presetLng || null;
        setTimeout(function () {
            initCheckoutLocationMap(presetLat, presetLng);
        }, 50);
    }

    document.addEventListener('DOMContentLoaded', function () {
        var toggleBtn = document.getElementById('checkoutLocationToggleBtn');
        if (toggleBtn) {
            toggleBtn.addEventListener('click', toggleCheckoutLocationMap);
        }
    });
</script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
</body>
</html>
