<%@ page pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Điểm thưởng - FOOD MANAGE</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user-theme.css">
    <style>
        :root {
            --bg:      #FFF9F2;
            --surface: #FFFFFF;
            --surface-lt: #FFF4EC;
            --gold:    #FF3B1F;
            --gold-hover: #E02A10;
            --text:    #2D2421;
            --muted:   #635752;
            --border:  #F1E4D6;
            --font-h: 'Quicksand', 'Plus Jakarta Sans', sans-serif;
            --font-b:  'Plus Jakarta Sans', sans-serif;
            --tr: all .25s ease;
            --shadow: 0 14px 34px rgba(99,44,20,.14);
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

        .container { max-width: 640px; margin: 0 auto; padding: 40px 20px 80px; }

        .alert { display: flex; align-items: center; gap: 10px; padding: 14px 18px; margin-bottom: 20px; border-radius: 14px; border: 1px solid; font-size: .9rem; font-weight: 600; }
        .alert-danger { background: #FEECEF; border-color: #FBD0D8; color: #E11D48; }

        .card { background: var(--surface); border: 1px solid var(--border); border-radius: 20px; box-shadow: 0 4px 18px rgba(99,44,20,.06); padding: 24px; margin-bottom: 20px; }
        .points-hero { text-align: center; padding: 32px 20px; }
        .points-value { font-size: 46px; font-weight: 900; color: var(--gold); }
        .points-label { font-size: 13px; color: var(--muted); margin-top: 4px; }
        .points-hint { font-size: 12.5px; color: var(--muted); margin-top: 14px; line-height: 1.6; }
        .btn-redeem { display: block; width: 100%; padding: 13px; margin-top: 18px; border-radius: 50px; border: none; background: linear-gradient(135deg, var(--gold), #E02A10); color: #fff; font-weight: 700; font-size: 14px; cursor: pointer; box-shadow: 0 8px 22px rgba(255,59,31,.32); }
        .btn-redeem:hover { filter: brightness(1.05); }
        .btn-redeem:disabled { opacity: .4; cursor: not-allowed; box-shadow: none; }
        .voucher-result { background: var(--surface-lt); border: 1px dashed var(--gold); border-radius: 12px; padding: 14px; text-align: center; font-size: 13.5px; color: var(--text); margin-bottom: 20px; }
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
            <a href="${pageContext.request.contextPath}/user/dia-chi">Địa chỉ</a>
            <a href="${pageContext.request.contextPath}/user/diem-thuong" class="active">Điểm thưởng</a>
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
    <c:if test="${not empty thanhCong}">
        <div class="voucher-result">${thanhCong}</div>
    </c:if>
    <c:if test="${not empty loi}">
        <div class="alert alert-danger">❌ <c:out value="${loi}"/></div>
    </c:if>

    <div class="card points-hero">
        <div class="points-value">${diem}</div>
        <div class="points-label">điểm thưởng hiện có</div>
        <div class="points-hint">Tích điểm: mỗi 10.000đ giá trị đơn hàng thành công = 1 điểm.<br>
            Đổi <strong>${pointsPerVoucher}</strong> điểm lấy 1 voucher giảm
            <fmt:formatNumber value="${voucherValue}" type="number" maxFractionDigits="0"/>đ (dùng 1 lần).</div>

        <form method="post" action="${pageContext.request.contextPath}/user/diem-thuong">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="redeem">
            <button type="submit" class="btn-redeem" ${diem < pointsPerVoucher ? 'disabled' : ''}>
                🎁 Đổi ${pointsPerVoucher} điểm lấy voucher
            </button>
        </form>
    </div>
</div>
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
