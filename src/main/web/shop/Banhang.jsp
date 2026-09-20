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
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bấm Bill - ${not empty currentShop.shopName ? currentShop.shopName : 'Cửa hàng'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-base:      #FFF8F1;
            --bg-sidebar:   #FFFFFF;
            --bg-panel:     #FFFFFF;
            --bg-input:     #FFF3E9;
            --bg-hover:     #FFF1E4;
            --border:       #FBE3CF;

            --text-main:    #3A2A1E;
            --text-muted:   #9C8579;
            --text-dim:     #C2A992;

            --primary:      #FF7A30;
            --primary-dk:   #E8590C;
            --primary-lt:   rgba(255,122,48,.12);

            --accent:       #E63946;
            --accent-lt:    rgba(230,57,70,.10);

            --danger:       #E63946;
            --danger-dark:  #C82C38;
            --danger-light: rgba(230,57,70,.10);

            --success:      #2ECC71;
            --success-lt:   rgba(46,204,113,.12);

            --warning:      #FFB703;
            --warning-lt:   rgba(255,183,3,.15);

            --sh-sm:  0 2px 6px rgba(58,42,30,.06);
            --sh-md:  0 8px 20px rgba(58,42,30,.10);
        }

        *{box-sizing:border-box;margin:0;padding:0;font-family:'Plus Jakarta Sans','Segoe UI',Tahoma,Geneva,Verdana,sans-serif;}
        a{text-decoration:none;color:inherit;}
        ul{list-style:none;}
        body{background:var(--bg-base);color:var(--text-muted);display:flex;height:100vh;overflow:hidden;}

        /* ── MAIN ── */
        .main-content{flex:1;display:flex;flex-direction:column;overflow:hidden;}
        .top-header{height:72px;background:var(--bg-sidebar);border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;padding:0 32px;flex-shrink:0;}
        .top-header h2{color:var(--text-main);font-size:19px;font-weight:800;}
        .header-actions{display:flex;align-items:center;gap:16px;}
        .search-bar{background:var(--bg-input);border:1px solid var(--border);border-radius:10px;padding:9px 16px;color:var(--text-main);width:260px;outline:none;font-size:13px;}
        .search-bar:focus{border-color:var(--primary);}
        .avatar{width:38px;height:38px;background:linear-gradient(135deg,var(--warning),var(--primary));border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fff;font-weight:700;font-size:14px;}
        .btn-logout{display:flex;align-items:center;gap:6px;padding:9px 16px;border-radius:10px;background:var(--accent-lt);color:var(--accent);font-size:13px;font-weight:700;border:1px solid transparent;transition:all .2s;}
        .btn-logout:hover{background:var(--accent);color:#fff;}

        .pos-layout{flex:1;display:flex;overflow:hidden;}

        /* ── PRODUCT AREA ── */
        .product-area{flex:1;overflow-y:auto;padding:24px;}
        .alert{padding:13px 18px;border-radius:10px;margin-bottom:16px;font-size:13px;font-weight:600;}
        .alert-error{background:var(--accent-lt);border:1px solid var(--accent);color:var(--accent);}

        .cat-tabs{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:18px;}
        .cat-tab{padding:8px 16px;border-radius:20px;background:var(--bg-panel);border:1px solid var(--border);color:var(--text-muted);font-size:12.5px;font-weight:700;cursor:pointer;}
        .cat-tab.active{background:var(--primary);color:#fff;border-color:var(--primary);}

        .product-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(190px,1fr));gap:16px;}
        .product-card{background:var(--bg-panel);border:1px solid var(--border);border-radius:14px;overflow:hidden;box-shadow:var(--sh-sm);}
        .product-card.out-of-stock{opacity:.65;}
        .product-img{height:100px;background:var(--bg-input);display:flex;align-items:center;justify-content:center;font-size:34px;overflow:hidden;position:relative;}
        .product-img img{width:100%;height:100%;object-fit:cover;}
        .out-of-stock-badge{position:absolute;top:6px;right:6px;background:var(--accent);color:#fff;font-size:10px;font-weight:700;padding:3px 8px;border-radius:10px;}
        .product-body{padding:12px;}
        .product-name{font-weight:700;color:var(--text-main);font-size:13.5px;margin-bottom:8px;min-height:34px;}
        .size-pills{display:flex;flex-wrap:wrap;gap:6px;}
        .size-pill{padding:6px 10px;border-radius:8px;background:var(--bg-input);border:1px solid var(--border);color:var(--primary-dk);font-size:11.5px;font-weight:700;cursor:pointer;}
        .size-pill:hover{background:var(--primary);color:#fff;border-color:var(--primary);}
        .size-pill-disabled{cursor:not-allowed;opacity:.6;background:var(--bg-input);color:var(--text-dim);}
        .size-pill-disabled:hover{background:var(--bg-input);color:var(--text-dim);border-color:var(--border);}
        .empty-state{text-align:center;padding:56px 20px;color:var(--text-dim);grid-column:1/-1;}

        /* ── CART PANEL ── */
        .cart-panel{width:380px;flex-shrink:0;background:var(--bg-panel);border-left:1px solid var(--border);display:flex;flex-direction:column;}
        .cart-header{padding:18px 20px;border-bottom:1px solid var(--border);font-weight:800;color:var(--primary-dk);font-size:14px;}
        .cart-lines{flex:1;overflow-y:auto;padding:14px 16px;}
        .cart-line{background:var(--bg-input);border-radius:12px;padding:12px;margin-bottom:10px;}
        .cart-line-top{display:flex;justify-content:space-between;align-items:start;gap:8px;}
        .cart-line-name{font-weight:700;font-size:13px;color:var(--text-main);}
        .cart-line-size{font-size:11px;color:var(--text-dim);}
        .cart-line-remove{color:var(--accent);font-size:12px;font-weight:700;cursor:pointer;}
        .qty-stepper{display:flex;align-items:center;gap:8px;margin-top:8px;}
        .qty-btn{width:26px;height:26px;border-radius:8px;border:1px solid var(--border);background:#fff;font-weight:800;cursor:pointer;}
        .qty-val{font-weight:700;color:var(--text-main);min-width:20px;text-align:center;}
        .cart-line-bottom{display:flex;justify-content:space-between;align-items:center;margin-top:8px;}
        .topping-toggle{font-size:11px;color:var(--primary-dk);font-weight:700;cursor:pointer;}
        .cart-line-subtotal{font-weight:800;color:var(--primary-dk);font-size:13px;}
        .cart-line-toppings-summary{font-size:10.5px;color:var(--text-dim);margin-top:4px;}
        .cart-empty{text-align:center;color:var(--text-dim);padding:40px 10px;font-size:13px;}

        .cart-footer{padding:16px 20px;border-top:1px solid var(--border);}
        .cart-total-row{display:flex;justify-content:space-between;font-size:17px;font-weight:800;color:var(--primary-dk);margin-bottom:14px;}
        .pay-methods{display:flex;gap:8px;margin-bottom:14px;}
        .pay-method{flex:1;padding:10px 6px;border-radius:10px;border:1px solid var(--border);background:var(--bg-input);text-align:center;font-size:11.5px;font-weight:700;color:var(--text-muted);cursor:pointer;}
        .pay-method.active{background:var(--primary);color:#fff;border-color:var(--primary);}
        .customer-input{width:100%;padding:9px 12px;border:1px solid var(--border);border-radius:10px;background:var(--bg-input);font-size:12.5px;margin-bottom:12px;outline:none;}
        .btn-confirm{width:100%;padding:13px;border:none;border-radius:12px;background:var(--primary);color:#fff;font-weight:800;font-size:14px;cursor:pointer;}
        .btn-confirm:hover{background:var(--primary-dk);}
        .btn-confirm:disabled{opacity:.5;cursor:not-allowed;}

        /* ── TOPPING PICKER ── */
        .topping-picker-overlay{position:fixed;inset:0;background:rgba(58,42,30,.4);display:none;align-items:center;justify-content:center;z-index:900;}
        .topping-picker-overlay.show{display:flex;}
        .topping-picker{background:var(--bg-panel);border-radius:16px;width:340px;max-height:70vh;overflow-y:auto;padding:18px;}
        .topping-picker h4{color:var(--primary-dk);margin-bottom:12px;font-size:14px;}
        .topping-group-title{font-size:11px;font-weight:700;color:var(--text-dim);text-transform:uppercase;margin:12px 0 6px;}
        .topping-row{display:flex;align-items:center;gap:8px;padding:7px 0;font-size:13px;color:var(--text-main);}
        .topping-row .tname{flex:1;}
        .topping-row .tqty-stepper{display:none;align-items:center;gap:6px;}
        .topping-row.checked .tqty-stepper{display:flex;}
        .topping-row-disabled{opacity:.55;cursor:not-allowed;}
        .topping-row-disabled .tname{color:var(--text-dim);}
        .topping-picker-close{display:block;margin-top:14px;text-align:center;background:var(--bg-input);border-radius:10px;padding:10px;font-weight:700;color:var(--text-muted);cursor:pointer;}

        .btn{display:inline-flex;align-items:center;gap:7px;padding:9px 16px;border:none;border-radius:10px;font-weight:700;font-size:12.5px;cursor:pointer;}
        .btn-primary{background:var(--primary);color:#fff;}
        .btn-secondary{background:var(--bg-input);border:1px solid var(--border);color:var(--text-muted);}
            .avatar-btn { background: linear-gradient(135deg, var(--warning), var(--primary)); color: #fff; width: 38px; height: 38px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px; cursor: pointer; border: 2px solid transparent; transition: all 0.2s; user-select: none; overflow: hidden; }
        .avatar-btn:hover { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(255,122,48,0.2); }
        .avatar-dropdown { display: none; position: fixed; background: var(--bg-panel); border: 1px solid var(--border); border-radius: 12px; box-shadow: 0 12px 32px rgba(58,42,30,0.15); min-width: 220px; z-index: 9999; }
        .avatar-dropdown.open { display: block; }
        .dropdown-header { padding: 14px 16px; border-bottom: 1px solid #e2c9b8; }
        .dropdown-header .d-name { font-size: 14px; font-weight: 700; color: var(--text-main); }
        .dropdown-header .d-email { font-size: 12px; color: var(--text-muted); margin-top: 2px; }
        .dropdown-header .d-role { display: inline-block; margin-top: 6px; font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 4px; background: rgba(255,122,48,0.12); color: var(--primary-dk); border: 1px solid var(--primary); }
        .dropdown-body { padding: 6px 0 8px; }
        .dropdown-link { display: flex; align-items: center; gap: 10px; padding: 10px 16px; font-size: 13px; color: var(--text-muted); cursor: pointer; transition: background 0.15s; text-decoration: none; }
        .dropdown-link:hover { background: var(--bg-hover); color: var(--text-main); }
        .dropdown-divider { height: 1px; background: #e2c9b8; margin: 4px 0; }
        .dropdown-link.danger { color: var(--accent); }
        .dropdown-link.danger:hover { background: rgba(230,57,70,0.10); }</style>
</head>
<body class="shop-theme">

<c:set var="shopActive" value="/shop/pos" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main-content">
    <header class="top-header">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h2><span class="material-symbols-outlined tb-icon">point_of_sale</span> BẤM BILL</h2>
        </div>
        <div class="header-actions">
            <input type="text" class="search-bar" id="searchBox" placeholder="🔍 Tìm món..." oninput="filterProducts(this.value)">
            <div class="avatar-btn" id="avatarBtn"><c:choose><c:when test="${not empty sessionScope.account.avatarUrl}"><img src="${sessionScope.account.avatarUrl}" style="width:100%;height:100%;object-fit:cover;border-radius:50%;"/></c:when><c:otherwise>${fn:toUpperCase(fn:substring(sessionScope.account.userName,0,2))}</c:otherwise></c:choose></div>
        </div>
    </header>

    <div class="pos-layout">
        <section class="product-area">
            <c:if test="${not empty loi}">
                <div class="alert alert-error">⚠️ <c:out value="${loi}"/></div>
            </c:if>
            <c:if test="${empty bill and not empty param.saved}">
                <c:choose>
                    <c:when test="${param.saved == '1'}">
                        <div class="alert" id="posSavedAlert" style="background:var(--success-lt);border:1px solid var(--success);color:var(--success);">✅ Đã lưu trạng thái thanh toán thành công!</div>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-error" id="posSavedAlert">⚠️ Lưu thất bại, vui lòng thử lại!</div>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <div class="cat-tabs" id="catTabs">
                <div class="cat-tab active" data-cat="" onclick="filterByCategory('', this)">Tất cả</div>
                <c:forEach var="cat" items="${danhsachLoai}">
                    <div class="cat-tab" data-cat="${cat.id}" onclick="filterByCategory('${cat.id}', this)">
                        <c:out value="${cat.categoryName}"/>
                    </div>
                </c:forEach>
            </div>

            <div class="product-grid" id="productGrid">
                <c:if test="${empty danhsachSanPham}">
                    <div class="empty-state">🍽️ Cửa hàng chưa có sản phẩm nào.</div>
                </c:if>
                <c:forEach var="p" items="${danhsachSanPham}">
                    <c:if test="${not empty p.sizes}">
                        <c:set var="hetHang" value="${fn:toUpperCase(p.staTus) == 'OUT_OF_STOCK'}"/>
                        <div class="product-card ${hetHang ? 'out-of-stock' : ''}" data-category="${p.categoryId}" data-name="${fn:escapeXml(fn:toLowerCase(p.productName))}">
                            <div class="product-img">
                                <c:choose>
                                    <c:when test="${not empty p.imageUrl}">
                                        <img src="${fn:escapeXml(p.imageUrl)}" alt="">
                                    </c:when>
                                    <c:otherwise>🍔</c:otherwise>
                                </c:choose>
                                <c:if test="${hetHang}">
                                    <div class="out-of-stock-badge">Hết hàng</div>
                                </c:if>
                            </div>
                            <div class="product-body">
                                <div class="product-name"><c:out value="${p.productName}"/></div>
                                <div class="size-pills">
                                    <c:forEach var="s" items="${p.sizes}">
                                        <c:choose>
                                            <c:when test="${hetHang || s.outOfStock}">
                                                <button type="button" class="size-pill size-pill-disabled" disabled>
                                                    <c:choose>
                                                        <c:when test="${p.sizes.size() == 1 and (s.sizeName == 'Mặc định' or s.sizeName == 'Tiêu chuẩn')}">Hết hàng</c:when>
                                                        <c:otherwise><c:out value="${s.sizeName}"/> · Hết hàng</c:otherwise>
                                                    </c:choose>
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" class="size-pill"
                                                        data-product-id="${p.id}"
                                                        data-product-name="${fn:escapeXml(p.productName)}"
                                                        data-size-id="${s.id}"
                                                        data-size-name="${fn:escapeXml(s.sizeName)}"
                                                        data-price="${s.price}"
                                                        data-category-id="${p.categoryId}"
                                                        onclick="addToCart(this)">
                                                    <c:choose>
                                                        <c:when test="${p.sizes.size() == 1 and (s.sizeName == 'Mặc định' or s.sizeName == 'Tiêu chuẩn')}">
                                                            <fmt:formatNumber value="${s.price}" type="number" maxFractionDigits="0"/>đ
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:out value="${s.sizeName}"/> · <fmt:formatNumber value="${s.price}" type="number" maxFractionDigits="0"/>đ
                                                        </c:otherwise>
                                                    </c:choose>
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </section>

        <aside class="cart-panel">
            <div class="cart-header">🧾 Hóa đơn tạm</div>
            <div class="cart-lines" id="cartLines">
                <div class="cart-empty">Chưa chọn món nào.<br>Bấm vào 1 size sản phẩm bên trái để thêm.</div>
            </div>
            <div class="cart-footer">
                <div class="cart-total-row"><span>Tổng tiền</span><span id="cartTotal">0đ</span></div>
                <input type="text" class="customer-input" id="customerName" placeholder="Tên khách (không bắt buộc)">
                <div class="pay-methods">
                    <div class="pay-method active" data-method="CASH" onclick="selectPayMethod('CASH', this)">💵 Tiền mặt</div>
                    <div class="pay-method" data-method="QR" onclick="selectPayMethod('QR', this)">📱 QR</div>
                    <div class="pay-method" data-method="PAYOS" onclick="selectPayMethod('PAYOS', this)">🏦 PayOS</div>
                </div>
                <button type="button" class="btn-confirm" id="btnConfirm" onclick="submitOrder()" disabled>✅ Xác nhận</button>
            </div>
        </aside>
    </div>
</main>

<%-- ── TOPPING PICKER (1 panel dùng chung, mở theo từng dòng cart) ── --%>
<div class="topping-picker-overlay" id="toppingOverlay">
    <div class="topping-picker">
        <h4>🧂 Chọn topping</h4>
        <div id="toppingPickerBody">
            <c:forEach var="tc" items="${danhsachLoaiTopping}">
                <c:set var="hasTopping" value="false"/>
                <c:forEach var="t" items="${danhsachTopping}">
                    <c:if test="${t.toppingCategoryId == tc.id}"><c:set var="hasTopping" value="true"/></c:if>
                </c:forEach>
                <c:if test="${hasTopping}">
                    <div data-topping-group data-category-ids="<c:forEach var="cid" items="${tc.categoryIds}" varStatus="cidVs">${cid}<c:if test="${!cidVs.last}">,</c:if></c:forEach>">
                        <div class="topping-group-title"><c:out value="${tc.name}"/></div>
                        <c:forEach var="t" items="${danhsachTopping}">
                            <c:if test="${t.toppingCategoryId == tc.id}">
                                <c:set var="toppingHetHang" value="${fn:toUpperCase(t.status) == 'OUT_OF_STOCK'}"/>
                                <label class="topping-row ${toppingHetHang ? 'topping-row-disabled' : ''}" data-topping-row data-id="${t.id}">
                                    <input type="checkbox" class="topping-check"
                                           data-id="${t.id}" data-name="${fn:escapeXml(t.toppingName)}" data-price="${t.price}"
                                           onchange="onToppingCheck(this)" ${toppingHetHang ? 'disabled' : ''}>
                                    <span class="tname"><c:out value="${t.toppingName}"/> (+<fmt:formatNumber value="${t.price}" type="number" maxFractionDigits="0"/>đ)<c:if test="${toppingHetHang}"> · Hết hàng</c:if></span>
                                    <span class="tqty-stepper">
                                        <button type="button" class="qty-btn" onclick="onToppingQty(${t.id}, -1)">-</button>
                                        <span class="qty-val" data-qty-for="${t.id}">1</span>
                                        <button type="button" class="qty-btn" onclick="onToppingQty(${t.id}, 1)">+</button>
                                    </span>
                                </label>
                            </c:if>
                        </c:forEach>
                    </div>
                </c:if>
            </c:forEach>
        </div>
        <div class="topping-picker-close" onclick="closeToppingPicker()">Xong</div>
    </div>
</div>

<%@ include file="_invoiceModal.jspf" %>

<script>
    var cart = []; // {productId, sizeId, productName, sizeName, unitPrice, qty, toppings: {id:{name,price,qty}}}
    var payMethod = 'CASH';
    var toppingPickerLineIdx = null;

    function fmtMoney(n) {
        return Math.round(n).toLocaleString('vi-VN') + 'đ';
    }

    function addToCart(btn) {
        var productId = btn.dataset.productId;
        var sizeId = btn.dataset.sizeId;
        var existing = cart.find(function (l) { return l.productId === productId && l.sizeId === sizeId; });
        if (existing) {
            existing.qty++;
        } else {
            cart.push({
                productId: productId,
                sizeId: sizeId,
                productName: btn.dataset.productName,
                sizeName: btn.dataset.sizeName,
                unitPrice: parseFloat(btn.dataset.price),
                categoryId: btn.dataset.categoryId,
                qty: 1,
                toppings: {}
            });
        }
        renderCart();
    }

    function lineToppingTotal(line) {
        var sum = 0;
        for (var id in line.toppings) sum += line.toppings[id].price * line.toppings[id].qty;
        return sum;
    }

    function lineSubtotal(line) {
        return line.unitPrice * line.qty + lineToppingTotal(line);
    }

    function renderCart() {
        var container = document.getElementById('cartLines');
        if (cart.length === 0) {
            container.innerHTML = '<div class="cart-empty">Chưa chọn món nào.<br>Bấm vào 1 size sản phẩm bên trái để thêm.</div>';
        } else {
            var html = '';
            cart.forEach(function (line, idx) {
                var toppingNames = Object.keys(line.toppings).map(function (id) {
                    return '+ ' + line.toppings[id].name + ' x' + line.toppings[id].qty;
                }).join('<br>');

                html += '<div class="cart-line">' +
                    '<div class="cart-line-top">' +
                        '<div><div class="cart-line-name">' + line.productName + '</div>' +
                        '<div class="cart-line-size">' + line.sizeName + '</div></div>' +
                        '<span class="cart-line-remove" onclick="removeLine(' + idx + ')">🗑</span>' +
                    '</div>' +
                    '<div class="qty-stepper">' +
                        '<button type="button" class="qty-btn" onclick="changeQty(' + idx + ',-1)">-</button>' +
                        '<span class="qty-val">' + line.qty + '</span>' +
                        '<button type="button" class="qty-btn" onclick="changeQty(' + idx + ',1)">+</button>' +
                    '</div>' +
                    (toppingNames ? '<div class="cart-line-toppings-summary">' + toppingNames + '</div>' : '') +
                    '<div class="cart-line-bottom">' +
                        '<span class="topping-toggle" onclick="openToppingPicker(' + idx + ')">🧂 Topping</span>' +
                        '<span class="cart-line-subtotal">' + fmtMoney(lineSubtotal(line)) + '</span>' +
                    '</div>' +
                '</div>';
            });
            container.innerHTML = html;
        }

        var total = cart.reduce(function (sum, l) { return sum + lineSubtotal(l); }, 0);
        document.getElementById('cartTotal').textContent = fmtMoney(total);
        document.getElementById('btnConfirm').disabled = cart.length === 0;
    }

    function changeQty(idx, delta) {
        cart[idx].qty += delta;
        if (cart[idx].qty <= 0) cart.splice(idx, 1);
        renderCart();
    }

    function removeLine(idx) {
        cart.splice(idx, 1);
        renderCart();
    }

    function openToppingPicker(idx) {
        toppingPickerLineIdx = idx;
        var line = cart[idx];

        // Chi hien nhom topping ap dung cho MOI loai san pham (khong gan loai nao) hoac co chua
        // dung loai san pham cua mon dang chon - tranh lan topping khong lien quan (vd nuoc mam
        // cho tra sua). 1 nhom topping co the ap dung cho NHIEU loai san pham cung luc.
        document.querySelectorAll('[data-topping-group]').forEach(function (group) {
            var idsRaw = (group.dataset.categoryIds || '').trim();
            var ids = idsRaw ? idsRaw.split(',') : [];
            var visible = ids.length === 0 || ids.indexOf(String(line.categoryId || '')) !== -1;
            group.style.display = visible ? '' : 'none';
        });

        document.querySelectorAll('.topping-check').forEach(function (cb) {
            var id = cb.dataset.id;
            var row = cb.closest('.topping-row');
            if (line.toppings[id]) {
                cb.checked = true;
                row.classList.add('checked');
                row.querySelector('.qty-val').textContent = line.toppings[id].qty;
            } else {
                cb.checked = false;
                row.classList.remove('checked');
                row.querySelector('.qty-val').textContent = '1';
            }
        });
        document.getElementById('toppingOverlay').classList.add('show');
    }

    function closeToppingPicker() {
        toppingPickerLineIdx = null;
        document.getElementById('toppingOverlay').classList.remove('show');
        renderCart();
    }

    function onToppingCheck(cb) {
        if (toppingPickerLineIdx === null) return;
        var line = cart[toppingPickerLineIdx];
        var id = cb.dataset.id;
        var row = cb.closest('.topping-row');
        if (cb.checked) {
            row.classList.add('checked');
            line.toppings[id] = {name: cb.dataset.name, price: parseFloat(cb.dataset.price), qty: 1};
            row.querySelector('.qty-val').textContent = 1;
        } else {
            row.classList.remove('checked');
            delete line.toppings[id];
        }
    }

    function onToppingQty(toppingId, delta) {
        if (toppingPickerLineIdx === null) return;
        var line = cart[toppingPickerLineIdx];
        var entry = line.toppings[toppingId];
        if (!entry) return;
        entry.qty = Math.max(1, entry.qty + delta);
        document.querySelector('.qty-val[data-qty-for="' + toppingId + '"]').textContent = entry.qty;
    }

    function selectPayMethod(method, el) {
        payMethod = method;
        document.querySelectorAll('.pay-method').forEach(function (e) { e.classList.remove('active'); });
        el.classList.add('active');
    }

    function filterProducts(keyword) {
        var kw = keyword.toLowerCase().trim();
        document.querySelectorAll('#productGrid .product-card').forEach(function (card) {
            card.style.display = card.dataset.name.includes(kw) ? '' : 'none';
        });
    }

    function filterByCategory(catId, tabEl) {
        document.querySelectorAll('#catTabs .cat-tab').forEach(function (t) { t.classList.remove('active'); });
        tabEl.classList.add('active');
        document.querySelectorAll('#productGrid .product-card').forEach(function (card) {
            card.style.display = (!catId || card.dataset.category === catId) ? '' : 'none';
        });
    }

    function submitOrder() {
        if (cart.length === 0) return;

        // Chong double-submit (bam 2 lan/double-click) tao trung don + tru kho 2 lan.
        var btn = document.getElementById('btnConfirm');
        if (btn.dataset.submitting === '1') return;
        btn.dataset.submitting = '1';
        btn.disabled = true;
        btn.textContent = '⏳ Đang xử lý...';

        var form = document.createElement('form');
        form.method = 'post';
        form.action = '${pageContext.request.contextPath}/shop/pos';

        function addField(name, value) {
            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = name;
            input.value = value;
            form.appendChild(input);
        }

        addField('csrfToken', '${sessionScope.csrfToken}');
        addField('action', 'create');
        addField('paymentMethod', payMethod);
        addField('customerName', document.getElementById('customerName').value);

        cart.forEach(function (line) {
            addField('lineProductId[]', line.productId);
            addField('lineSizeId[]', line.sizeId);
            addField('lineQty[]', line.qty);
            var toppingStr = Object.keys(line.toppings).map(function (id) {
                return id + ':' + line.toppings[id].qty;
            }).join(',');
            addField('lineToppings[]', toppingStr);
        });

        document.body.appendChild(form);
        form.submit();
    }

    <c:if test="${not empty bill}">
    // Sau khi xác nhận đơn thành công, reset giỏ tạm để sẵn sàng bán đơn tiếp theo.
    cart = [];
    renderCart();
    </c:if>

    var posSavedAlert = document.getElementById('posSavedAlert');
    if (posSavedAlert) {
        setTimeout(function () { posSavedAlert.style.display = 'none'; }, 3000);
    }
</script>


<!-- Avatar Dropdown -->
<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${fn:escapeXml(sessionScope.account.userName)}</div>
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
<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
</body>
</html>



