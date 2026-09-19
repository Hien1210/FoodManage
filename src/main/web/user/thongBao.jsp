<%@ page pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông báo - FOOD MANAGE</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user-theme.css">
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
            --font-b:  'Plus Jakarta Sans', sans-serif;
            --tr: all .25s ease;
            --shadow: 0 14px 36px rgba(99,44,20,.14);
            --glow:   0 8px 22px rgba(255,59,31,.3);
        }
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: var(--font-b); background: var(--bg); color: var(--text); min-height: 100vh; }
        a { text-decoration: none; color: inherit; transition: var(--tr); }

        /* NAVBAR (dong bo voi trang chu) */
        .navbar {
            position: fixed; top: 0; left: 0; width: 100%; z-index: 1000;
            background: rgba(255,249,242,.92); backdrop-filter: blur(14px);
            border-bottom: 1px solid var(--border);
        }
        .nav-content { max-width: 1180px; margin: 0 auto; padding: 0 20px; display: flex; justify-content: space-between; align-items: center; height: 76px; gap: 16px; }
        .logo { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
        .logo h1 { font-family: var(--font-h); white-space: nowrap; font-size: 1.55rem; font-weight: 800; letter-spacing: -.5px; }
        .logo span { color: var(--gold); }
        .nav-links { display: flex; gap: 20px; align-items: center; }
        .nav-links a { font-size: .85rem; font-weight: 600; color: var(--muted); white-space: nowrap; }
        .nav-links a:hover, .nav-links a.active { color: var(--gold); }
        .nav-actions { display: flex; align-items: center; gap: 14px; }

        .avatar-wrap { position: relative; }
        .avatar-btn {
            width: 40px; height: 40px; border-radius: 50%;
            background: linear-gradient(135deg, var(--gold), var(--gold-hover));
            color: #FFF; font-size: 15px; font-weight: 800;
            border: none; cursor: pointer; font-family: var(--font-b);
            display: flex; align-items: center; justify-content: center; box-shadow: var(--glow);
        }
        .avatar-dropdown {
            position: absolute; top: calc(100% + 12px); right: 0;
            background: var(--surface); border: 1px solid var(--border); border-radius: 16px;
            min-width: 220px; z-index: 200; display: none; box-shadow: var(--shadow); overflow: hidden;
        }
        .avatar-dropdown.open { display: block; }
        .dd-head { padding: 16px 18px; border-bottom: 1px solid var(--border); background: var(--surface-lt); }
        .dd-name { font-size: 14px; font-weight: 700; color: var(--text); }
        .dd-email { font-size: 11.5px; color: var(--muted); margin-top: 3px; }
        .dd-link, .dd-btn {
            display: flex; align-items: center; gap: 10px; width: 100%; padding: 12px 18px;
            font-size: 13px; font-weight: 600; color: var(--muted); background: none; border: none;
            cursor: pointer; font-family: var(--font-b); transition: var(--tr); text-align: left;
        }
        .dd-link i, .dd-btn i { color: var(--gold); width: 14px; }
        .dd-link:hover, .dd-btn:hover { color: var(--gold); background: var(--surface-lt); }
        .dd-divider { height: 1px; background: var(--border); margin: 4px 0; }

        .cart-btn {
            background: var(--surface-lt); border: 1.5px solid var(--border); border-radius: 50%;
            width: 42px; height: 42px; color: var(--text); font-size: 1.05rem; cursor: pointer;
            position: relative; transition: var(--tr); display: flex; align-items: center; justify-content: center;
        }
        .cart-btn:hover { color: var(--gold); border-color: var(--gold); }

        .container { max-width: 760px; margin: 0 auto; padding: 110px 20px 80px; }
        .page-header { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 22px; }
        .page-title { font-family: var(--font-h); font-size: 22px; font-weight: 800; color: var(--text); display: flex; align-items: center; gap: 10px; }
        .unread-badge { background: var(--gold); color: #fff; font-size: 12px; font-weight: 700; padding: 3px 12px; border-radius: 50px; }
        .btn-mark-all { padding: 9px 18px; border-radius: 50px; border: 1.5px solid var(--border); background: var(--surface); color: var(--text); font-size: 12.5px; font-weight: 700; cursor: pointer; }
        .btn-mark-all:hover { color: var(--gold); border-color: var(--gold); background: var(--surface-lt); }

        .notif-list { display: flex; flex-direction: column; gap: 12px; }
        .notif-card { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 18px 20px; display: flex; gap: 14px; align-items: flex-start; box-shadow: 0 2px 10px rgba(99,44,20,.05); }
        .notif-card.unread { border-left: 4px solid var(--gold); background: var(--surface-lt); }
        .notif-icon { font-size: 22px; flex-shrink: 0; margin-top: 2px; }
        .notif-body { flex: 1; }
        .notif-title { font-size: 14.5px; font-weight: 700; margin-bottom: 4px; color: var(--muted); }
        .notif-card.unread .notif-title { color: var(--text); }
        .notif-message { font-size: 13px; color: var(--muted); line-height: 1.6; }
        .notif-time { font-size: 11px; color: var(--muted); margin-top: 6px; opacity: .8; }
        .notif-read-btn { background: none; border: 1px solid var(--border); border-radius: 6px; padding: 4px 10px; font-size: 11px; cursor: pointer; color: var(--muted); flex-shrink: 0; }
        .notif-read-btn:hover { color: var(--gold); border-color: var(--gold); }

        .empty-state { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 60px 20px; text-align: center; }
        .empty-state .e-icon { font-size: 42px; margin-bottom: 12px; }
        .empty-state .e-title { font-size: 14px; font-weight: 700; color: var(--muted); }
    </style>
</head>
<body>

<header class="navbar">
    <div class="nav-content">
        <a class="logo" href="${pageContext.request.contextPath}/user/home" style="text-decoration:none;color:inherit;">
            <img class="logo-emoji" src="https://cdn.jsdelivr.net/gh/microsoft/fluentui-emoji@main/assets/Steaming%20bowl/3D/steaming_bowl_3d.png" alt="" style="width:30px;height:30px;">
            <h1>FOOD MANAGE<span>.</span></h1>
        </a>
        <nav class="nav-links">
            <a href="${pageContext.request.contextPath}/user/home">Trang chủ</a>
            <a href="${pageContext.request.contextPath}/user/donhang">Đơn hàng</a>
            <a href="${pageContext.request.contextPath}/user/dia-chi">Địa chỉ</a>
            <a href="${pageContext.request.contextPath}/user/diem-thuong">Điểm thưởng</a>
        </nav>
        <div class="nav-actions">
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
                    <a href="${pageContext.request.contextPath}/user/thong-tin-ca-nhan" class="dd-link"><i class="fa-solid fa-user"></i> Thông tin cá nhân</a>
                    <a href="${pageContext.request.contextPath}/user/donhang" class="dd-link"><i class="fa-solid fa-box"></i> Đơn hàng của tôi</a>
                    <a href="${pageContext.request.contextPath}/user/dia-chi" class="dd-link"><i class="fa-solid fa-location-dot"></i> Địa chỉ giao hàng</a>
                    <a href="${pageContext.request.contextPath}/user/diem-thuong" class="dd-link"><i class="fa-solid fa-star"></i> Điểm thưởng & Voucher</a>
                    <a href="${pageContext.request.contextPath}/user/thong-bao" class="dd-link"><i class="fa-solid fa-bell"></i> Thông báo</a>
                    <a href="${pageContext.request.contextPath}/user/cart" class="dd-link"><i class="fa-solid fa-cart-shopping"></i> Giỏ hàng</a>
                    <a href="${pageContext.request.contextPath}/user/doi-mat-khau" class="dd-link"><i class="fa-solid fa-lock"></i> Đổi mật khẩu</a>
                    <div class="dd-divider"></div>
                    <form action="${pageContext.request.contextPath}/logout" method="post">
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <button type="submit" class="dd-btn"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</button>
                    </form>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/user/cart" class="cart-btn" aria-label="Giỏ hàng">
                <i class="fa-solid fa-bag-shopping"></i>
            </a>
        </div>
    </div>
</header>

<div class="container">
    <div class="page-header">
        <div class="page-title">
            🔔 Thông báo
            <c:if test="${unreadCount > 0}"><span class="unread-badge">${unreadCount} chưa đọc</span></c:if>
        </div>
        <c:if test="${unreadCount > 0}">
            <form action="${pageContext.request.contextPath}/user/thong-bao" method="post" style="margin:0">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="markAll"/>
                <button type="submit" class="btn-mark-all">✅ Đánh dấu tất cả đã đọc</button>
            </form>
        </c:if>
    </div>

    <c:choose>
        <c:when test="${empty notifications}">
            <div class="empty-state">
                <div class="e-icon">🔕</div>
                <div class="e-title">Bạn chưa có thông báo nào</div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="notif-list">
                <c:forEach var="n" items="${notifications}">
                    <div class="notif-card ${n.read ? '' : 'unread'}">
                        <div class="notif-icon">🔔</div>
                        <div class="notif-body">
                            <div class="notif-title">${fn:escapeXml(n.title)}</div>
                            <div class="notif-message">${fn:escapeXml(n.message)}</div>
                            <div class="notif-time">
                                <c:if test="${n.createdAt != null}">
                                    ${n.createdAt.hour}:<c:set var="m" value="${n.createdAt.minute}"/><c:if test="${m < 10}">0</c:if>${m}
                                    &nbsp;·&nbsp;${n.createdAt.dayOfMonth}/${n.createdAt.monthValue}/${n.createdAt.year}
                                </c:if>
                            </div>
                        </div>
                        <c:if test="${!n.read}">
                            <form action="${pageContext.request.contextPath}/user/thong-bao" method="post" style="margin:0">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="id" value="${n.id}"/>
                                <button type="submit" class="notif-read-btn">Đã đọc</button>
                            </form>
                        </c:if>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>
<script>window.POB_CONTEXT_PATH = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/notifications-ws.js"></script>
<script>
    function toggleDropdown() {
        document.getElementById('accountDropdown').classList.toggle('open');
    }
    document.addEventListener('click', function(e) {
        var w = document.getElementById('avatarWrap');
        if (w && !w.contains(e.target)) document.getElementById('accountDropdown').classList.remove('open');
    });

    // Dang xem trang thong bao khi co thong bao moi day toi -> tai lai de hien ngay trong danh sach.
    document.addEventListener('pob-notification', function () {
        setTimeout(function () { window.location.reload(); }, 1200);
    });
</script>
</body>
</html>
