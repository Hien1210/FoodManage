<%@ page pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khiếu nại đơn hàng - FOOD MANAGE</title>
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
            --font-b: 'Plus Jakarta Sans', sans-serif;
            --tr: all 0.3s ease;
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
        @media (max-width: 860px) { .nav-links { display: none; } }

        .container { max-width: 760px; margin: 0 auto; padding: 40px 20px 80px; }

        .alert { display: flex; align-items: center; gap: 10px; padding: 14px 18px; margin-bottom: 20px; border-radius: 14px; border: 1px solid; font-size: .9rem; font-weight: 600; }
        .alert-success { background: #EAFBF1; border-color: #BBF0CF; color: #15803D; }
        .alert-danger  { background: #FEECEF; border-color: #FBD0D8; color: #E11D48; }

        .card { background: var(--surface); border: 1px solid var(--border); border-radius: 20px; box-shadow: 0 4px 18px rgba(99,44,20,.06); padding: 24px; margin-bottom: 20px; }
        .card-head { display: flex; align-items: center; gap: 12px; margin-bottom: 18px; }
        .card-head .ic { width: 42px; height: 42px; border-radius: 12px; background: #FFF2F0; color: var(--gold); display: flex; align-items: center; justify-content: center; font-size: 1.1rem; flex-shrink: 0; }
        .card-head h3 { margin: 0; font-family: var(--font-h); font-size: 1.05rem; color: var(--text); }
        .card-head p { margin: 2px 0 0; font-size: .78rem; color: var(--muted); font-weight: 500; }
        .card h3 { margin-top: 0; font-size: 16px; color: var(--text); }

        /* MINI STATUS TIMELINE */
        .cx-timeline { display: flex; align-items: center; gap: 4px; margin: 12px 0; }
        .cx-step { display: flex; align-items: center; gap: 4px; flex: 1; }
        .cx-dot { width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 800; flex-shrink: 0; background: var(--border); color: var(--muted); }
        .cx-line { flex: 1; height: 2px; background: var(--border); }
        .cx-step.done .cx-dot { background: #15803D; color: #fff; }
        .cx-step.done .cx-line { background: #15803D; }
        .cx-step.current .cx-dot { background: var(--gold); color: #fff; box-shadow: 0 0 0 3px rgba(255,59,31,.18); }
        .cx-step.rejected .cx-dot { background: #DC2626; color: #fff; }
        .form-group { margin-bottom: 14px; }
        .form-group label { display: block; font-size: 13px; font-weight: 700; color: var(--text); margin-bottom: 6px; }
        .form-group input, .form-group textarea { width: 100%; padding: 11px 14px; border-radius: 10px; border: 1.5px solid var(--border); background: var(--surface-lt); color: var(--text); font-size: 13.5px; font-family: var(--font-b); }
        .form-group input:focus, .form-group textarea:focus { outline: none; border-color: var(--gold); background: var(--surface); }
        .form-group textarea { min-height: 110px; resize: vertical; }
        .btn-submit { padding: 11px 24px; border-radius: 50px; border: none; background: linear-gradient(135deg, var(--gold), #E02A10); color: #fff; font-weight: 700; font-size: 13.5px; cursor: pointer; box-shadow: 0 8px 22px rgba(255,59,31,.32); }
        .btn-submit:hover { filter: brightness(1.05); }

        .complaint-item { padding: 16px; border: 1px solid var(--border); border-radius: 14px; margin-bottom: 12px; background: var(--surface-lt); }
        .complaint-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; flex-wrap: wrap; gap: 6px; }
        .complaint-subject { font-weight: 700; color: var(--text); }
        .complaint-content { font-size: 13px; color: var(--muted); margin-bottom: 8px; white-space: pre-wrap; }
        .complaint-reply { font-size: 13px; background: var(--surface); border: 1px solid var(--border); border-radius: 10px; padding: 10px 12px; color: var(--text); }

        .badge { display: inline-flex; align-items: center; gap: 4px; font-size: 11px; font-weight: 700; padding: 3px 10px; border-radius: 50px; white-space: nowrap; }
        .badge-pending { background: #FEF3C7; color: #B45309; }
        .badge-processing { background: #DBEAFE; color: #1D4ED8; }
        .badge-resolved { background: #DCFCE7; color: #15803D; }
        .badge-rejected { background: #FEE2E2; color: #DC2626; }
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
        <div class="alert alert-success">✅ Đã gửi khiếu nại! Admin sẽ xem xét và phản hồi sớm nhất.</div>
    </c:if>
    <c:if test="${param.error eq 'empty'}">
        <div class="alert alert-danger">❌ Vui lòng nhập đủ tiêu đề và nội dung khiếu nại.</div>
    </c:if>
    <c:if test="${param.error eq 'not_found'}">
        <div class="alert alert-danger">❌ Không tìm thấy đơn hàng hoặc đơn không thuộc về bạn.</div>
    </c:if>
    <c:if test="${param.error eq 'fail'}">
        <div class="alert alert-danger">❌ Gửi khiếu nại thất bại, vui lòng thử lại.</div>
    </c:if>

    <c:if test="${not empty order}">
        <div class="card">
            <div class="card-head">
                <span class="ic"><i class="fa-solid fa-triangle-exclamation"></i></span>
                <div><h3>Gửi khiếu nại cho đơn #${order.id}</h3><p>Admin sẽ xem xét và phản hồi trực tiếp trong mục này</p></div>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/khieu-nai">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="orderId" value="${order.id}"/>
                <div class="form-group">
                    <label>Tiêu đề</label>
                    <input type="text" name="subject" maxlength="255" placeholder="VD: Giao thiếu món, món không đúng mô tả..." required/>
                </div>
                <div class="form-group">
                    <label>Nội dung chi tiết</label>
                    <textarea name="content" placeholder="Mô tả cụ thể vấn đề bạn gặp phải với đơn hàng này..." required></textarea>
                </div>
                <button type="submit" class="btn-submit">Gửi khiếu nại</button>
            </form>
        </div>
    </c:if>

    <div class="card">
        <div class="card-head">
            <span class="ic"><i class="fa-solid fa-comments"></i></span>
            <div><h3>Khiếu nại của tôi</h3><p><c:out value="${fn:length(complaints)}"/> khiếu nại đã gửi</p></div>
        </div>
        <c:choose>
            <c:when test="${empty complaints}">
                <p style="color:var(--muted);font-size:13.5px;">Bạn chưa gửi khiếu nại nào. Vào <a href="${pageContext.request.contextPath}/user/donhang" style="color:var(--gold);font-weight:700;">Đơn hàng của tôi</a> để chọn đơn cần khiếu nại.</p>
            </c:when>
            <c:otherwise>
                <c:forEach var="c" items="${complaints}">
                    <div class="complaint-item">
                        <div class="complaint-top">
                            <span class="complaint-subject">#${c.orderId} — <c:out value="${c.subject}"/></span>
                            <span class="badge
                                ${c.status == 'PENDING' ? 'badge-pending' :
                                  c.status == 'PROCESSING' ? 'badge-processing' :
                                  c.status == 'RESOLVED' ? 'badge-resolved' : 'badge-rejected'}">
                                <c:choose>
                                    <c:when test="${c.status eq 'PENDING'}">⏳ Chờ xử lý</c:when>
                                    <c:when test="${c.status eq 'PROCESSING'}">🔄 Đang xử lý</c:when>
                                    <c:when test="${c.status eq 'RESOLVED'}">✅ Đã giải quyết</c:when>
                                    <c:otherwise>❌ Từ chối</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="cx-timeline">
                            <div class="cx-step done"><div class="cx-dot">1</div><div class="cx-line"></div></div>
                            <div class="cx-step ${c.status eq 'PENDING' ? 'current' : 'done'}"><div class="cx-dot">2</div><div class="cx-line"></div></div>
                            <div class="cx-step ${c.status eq 'RESOLVED' ? 'done' : c.status eq 'REJECTED' ? 'rejected' : c.status eq 'PROCESSING' ? 'current' : ''}"><div class="cx-dot">3</div></div>
                        </div>
                        <div class="complaint-content"><c:out value="${c.content}"/></div>
                        <c:if test="${not empty c.adminReply}">
                            <div class="complaint-reply">💬 <strong>Phản hồi từ Admin:</strong> <c:out value="${c.adminReply}"/></div>
                        </c:if>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
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
