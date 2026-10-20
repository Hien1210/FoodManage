<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Chi tiết đơn hàng #${order.id} - POB Shipper</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
    <style>
        #routeMap { width:100%; height:320px; border-radius:8px; margin-top:14px; border:1px solid var(--border-color); }
        .route-eta-bar { display:flex; flex-wrap:wrap; gap:12px; margin-top:8px; font-size:12.5px; font-weight:700; color:var(--primary); }
        :root[data-theme="dark"] {
            --bg-base:#0f172a;--bg-card:#1e293b;--bg-input:#0f172a;
            --text-main:#f8fafc;--text-muted:#94a3b8;--border-color:#334155;
            --topbar-bg:rgba(30,41,59,0.8);--shadow:0 4px 6px -1px rgb(0 0 0/.2);
        }
        :root[data-theme="light"] {
            --bg-base:#f4f7f5;--bg-card:#ffffff;--bg-input:#f8fafc;
            --text-main:#1e293b;--text-muted:#64748b;--border-color:#e2e8f0;
            --topbar-bg:rgba(255,255,255,0.85);--shadow:0 4px 12px rgba(0,0,0,.03);
        }
        :root {
            --primary:#4CAF50;--primary-hover:#43a047;--primary-light:rgba(76,175,80,.12);
            --secondary:#FF9800;--secondary-hover:#f57c00;--secondary-light:rgba(255,152,0,.12);
            --danger:#ef4444;--font-family:system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;
        }
        *{box-sizing:border-box;margin:0;padding:0;font-family:var(--font-family);transition:background-color .25s,border-color .25s}
        body{background-color:var(--bg-base);color:var(--text-main);display:flex;height:100vh;overflow:hidden}
        a{text-decoration:none;color:inherit}
        .sidebar{width:260px;background-color:var(--bg-card);border-right:1px solid var(--border-color);display:flex;flex-direction:column;flex-shrink:0;z-index:10}
        .brand{padding:24px;display:flex;align-items:center;gap:12px;border-bottom:1px solid var(--border-color)}
        .logo{background:linear-gradient(135deg,var(--primary),#2e7d32);color:#fff;width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:18px}
        .brand-title{font-weight:700;font-size:16px;letter-spacing:.5px}
        .menu{padding:20px 12px;flex:1}
        .menu-item{padding:14px 16px;display:flex;align-items:center;gap:12px;color:var(--text-muted);font-size:14px;font-weight:600;border-radius:8px;margin-bottom:6px}
        .menu-item:hover{background-color:var(--bg-input);color:var(--text-main);transform:translateX(4px)}
        .menu-item.active{background-color:var(--primary-light);color:var(--primary)}
        .online-toggle-wrap{padding:16px 12px;border-top:1px solid var(--border-color)}
        .online-toggle-btn{width:100%;padding:12px 16px;border-radius:10px;border:none;cursor:pointer;display:flex;align-items:center;gap:10px;font-size:13px;font-weight:700;transition:all .2s}
        .online-toggle-btn.is-online{background:var(--primary-light);color:var(--primary);border:1.5px solid var(--primary)}
        .online-toggle-btn.is-offline{background:rgba(239,68,68,.08);color:#ef4444;border:1.5px solid rgba(239,68,68,.3)}
        .toggle-dot{width:10px;height:10px;border-radius:50%;flex-shrink:0}
        .toggle-dot.online{background:var(--primary);animation:pulse-green 1.5s infinite}
        .toggle-dot.offline{background:#ef4444}
        @keyframes pulse-green{0%,100%{box-shadow:0 0 0 3px rgba(76,175,80,.25)}50%{box-shadow:0 0 0 6px rgba(76,175,80,.1)}}
        .main{flex:1;display:flex;flex-direction:column;overflow:hidden}
        .topbar{background-color:var(--topbar-bg);backdrop-filter:blur(10px);padding:16px 32px;display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid var(--border-color)}
        .topbar h1{font-size:18px;font-weight:700;display:flex;align-items:center;gap:8px}
        .topbar-right{display:flex;align-items:center;gap:16px}
        .theme-toggle{background:var(--bg-input);border:1px solid var(--border-color);width:38px;height:38px;border-radius:8px;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:16px}
        .avatar-circle{background:var(--primary);color:white;width:38px;height:38px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:700}
        .btn-logout{padding:8px 16px;border-radius:8px;background:rgba(239,68,68,.1);color:var(--danger);font-size:13px;font-weight:600}
        .btn-logout:hover{background:var(--danger);color:white}
        .content{padding:24px 32px;overflow-y:auto;flex:1;display:flex;flex-direction:column;gap:20px;animation:fadeIn .3s ease-out}
        @keyframes fadeIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}
        .card{background:var(--bg-card);border:1px solid var(--border-color);border-radius:14px;padding:20px;box-shadow:var(--shadow)}
        .card-title{font-size:14px;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:14px;padding-bottom:10px;border-bottom:1px solid var(--border-color)}
        .info-row{display:flex;justify-content:space-between;align-items:flex-start;padding:8px 0;border-bottom:1px dashed var(--border-color);font-size:14px}
        .info-row:last-child{border-bottom:none}
        .info-label{color:var(--text-muted);font-weight:600;font-size:12px;text-transform:uppercase;min-width:140px}
        .info-value{font-weight:600;text-align:right}
        /* Route timeline */
        .route-timeline{display:flex;flex-direction:column;gap:0}
        .route-point{display:flex;gap:14px;padding:14px 0}
        .route-point:not(:last-child){border-bottom:1px dashed var(--border-color)}
        .route-dot{width:36px;height:36px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:16px;flex-shrink:0}
        .dot-shop{background:var(--secondary-light);color:var(--secondary)}
        .dot-customer{background:var(--primary-light);color:var(--primary)}
        .route-info-label{font-size:11px;font-weight:700;text-transform:uppercase;color:var(--text-muted);margin-bottom:2px}
        .route-info-name{font-weight:700;font-size:14px}
        .route-info-sub{font-size:12px;color:var(--text-muted);margin-top:2px}
        /* Item table */
        .item-list{display:flex;flex-direction:column;gap:10px}
        .item-row{background:var(--bg-input);border-radius:10px;padding:14px}
        .item-name{font-weight:700;font-size:14px}
        .item-size{font-size:12px;color:var(--text-muted);margin-top:2px}
        .item-topping-list{margin-top:6px;padding-left:12px;border-left:2px solid var(--border-color)}
        .item-topping{font-size:12px;color:var(--text-muted);padding:2px 0}
        .item-price-row{display:flex;justify-content:space-between;align-items:center;margin-top:8px}
        .item-qty{font-size:13px;color:var(--text-muted)}
        .item-subtotal{font-weight:700;color:var(--primary)}
        /* Tổng tiền */
        .total-row{display:flex;justify-content:space-between;align-items:center;padding:12px 0;font-size:15px;font-weight:700;border-top:2px solid var(--border-color);margin-top:8px}
        .total-amount{font-size:20px;font-weight:800;color:var(--primary)}
        /* Badge */
        .badge{padding:4px 10px;border-radius:6px;font-size:11px;font-weight:700;text-transform:uppercase}
        .badge-pickup{background:var(--secondary-light);color:var(--secondary)}
        .badge-shipping{background:var(--primary-light);color:var(--primary)}
        .badge-done{background:rgba(34,197,94,.1);color:#16a34a}
        /* Nút hành động */
        .action-bar{display:flex;gap:10px;justify-content:flex-end}
        .btn-back{padding:10px 20px;border-radius:8px;border:1px solid var(--border-color);background:transparent;color:var(--text-main);font-weight:700;font-size:13px;cursor:pointer}
        .btn-back:hover{background:var(--bg-input)}
        .btn-primary{padding:10px 20px;border-radius:8px;border:none;background:var(--primary);color:white;font-weight:700;font-size:13px;cursor:pointer}
        .btn-primary:hover{background:var(--primary-hover)}
        .btn-warning{padding:10px 20px;border-radius:8px;border:none;background:var(--secondary);color:white;font-weight:700;font-size:13px;cursor:pointer}
        .btn-warning:hover{background:var(--secondary-hover)}
        /* Modal huỷ đơn — .pob-modal-box luôn nền trắng cố định (theme.css) bất kể theme
           trang đang sáng/tối, nên nội dung bên trong PHẢI dùng màu cố định, không dùng
           var(--text-main)/var(--border-color)/var(--bg-input) vì các biến này đổi theo
           data-theme của trang và sẽ ra chữ sáng trên nền trắng khi bật dark mode. */
        .pob-modal-box{padding:24px}
        .pob-modal-box h3{margin:0 0 10px;font-size:17px;color:#1e293b}
        .pob-modal-box p{margin:0 0 14px;font-size:13px;color:#64748b}
        .pob-modal-box textarea{width:100%;min-height:90px;padding:10px 12px;border-radius:8px;border:1px solid #e2e8f0;background:#f8fafc;color:#1e293b;font-size:13px;resize:vertical;box-sizing:border-box}
        .pob-modal-box .btn-back{border-color:#e2e8f0;color:#1e293b}
        .pob-modal-box .btn-back:hover{background:#f8fafc}
        .modal-error{display:none;color:var(--danger);font-size:12px;margin-top:6px}
        .modal-actions{display:flex;gap:10px;justify-content:flex-end;margin-top:18px}
        /* Modal hoàn thành giao đơn */
        .complete-modal-box{text-align:center}
        .complete-modal-icon{font-size:46px;line-height:1;margin-bottom:12px}
        .complete-modal-box h3{font-size:18px}
        .complete-modal-box p{font-size:13.5px;line-height:1.5}
        .complete-modal-box .modal-actions{justify-content:center}
        .btn-success-solid{padding:10px 22px;border-radius:8px;border:none;background:var(--success);color:#fff;font-weight:700;font-size:13px;cursor:pointer}
        .btn-success-solid:hover{background:var(--success-dark)}
        .btn-danger{padding:10px 20px;border-radius:8px;border:none;background:var(--danger);color:white;font-weight:700;font-size:13px;cursor:pointer}
        .btn-danger:hover{background:#dc2626}
        @media(max-width:768px){
            body{flex-direction:column}
            .sidebar{width:100%;height:auto;border-right:none;border-bottom:1px solid var(--border-color)}
            .menu{display:flex;overflow-x:auto;padding:10px}
            .menu-item{margin-bottom:0;white-space:nowrap}
            .content{padding:16px}
        }
            .avatar-btn { background: var(--primary); color: #fff; width: 38px; height: 38px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px; cursor: pointer; border: 2px solid transparent; transition: all 0.2s; user-select: none; overflow: hidden; }
        .avatar-btn:hover { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(16,185,129,0.2); }
        .avatar-dropdown { display: none; position: fixed; background: var(--bg-card, #1e293b); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 12px 32px rgba(0,0,0,0.3); min-width: 220px; z-index: 9999; }
        .avatar-dropdown.open { display: block; }
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

        .online-toggle-btn { width: 100%; padding: 12px 16px; border-radius: var(--radius-sm); border: none; cursor: pointer; display: flex; align-items: center; gap: 10px; font-size: 13px; font-weight: 700; }
        .online-toggle-btn.is-online { background: var(--success-light); color: var(--success-dark); border: 1.5px solid var(--success); }
        .online-toggle-btn.is-offline { background: var(--danger-light); color: var(--danger); border: 1.5px solid var(--danger); }
        .toggle-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
        .toggle-dot.online { background: var(--success); animation: pobBlink 1.5s infinite; }
        .toggle-dot.offline { background: var(--danger); }

        /* Route timeline */
        .route-timeline { display: flex; flex-direction: column; gap: 0; }
        .route-point { display: flex; gap: 14px; padding: 14px 0; }
        .route-point:not(:last-child) { border-bottom: 1px dashed var(--border-color); }
        .route-dot { width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 16px; flex-shrink: 0; }
        .dot-shop { background: var(--warning-light); color: var(--warning-dark); }
        .dot-customer { background: var(--primary-light); color: var(--primary); }
        .route-info-label { font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--text-dim); margin-bottom: 2px; }
        .route-info-name { font-weight: 700; font-size: 14px; color: var(--text-main); }
        .route-info-sub { font-size: 12px; color: var(--text-dim); margin-top: 2px; }

        /* Item checklist */
        .item-list { display: flex; flex-direction: column; gap: 10px; }
        .item-row { background: var(--bg-input); border-radius: var(--radius-sm); padding: 14px; cursor: pointer; transition: all .2s; }
        .item-name { font-weight: 700; font-size: 14px; color: var(--text-main); }
        .item-size { font-size: 12px; color: var(--text-dim); margin-top: 2px; }
        .item-topping-list { margin-top: 6px; padding-left: 12px; border-left: 2px solid var(--border-color); }
        .item-topping { font-size: 12px; color: var(--text-dim); padding: 2px 0; }
        .item-price-row { display: flex; justify-content: space-between; align-items: center; margin-top: 8px; }
        .item-qty { font-size: 13px; color: var(--text-dim); }
        .item-subtotal { font-weight: 700; color: var(--primary); }
        .custom-check { width: 22px; height: 22px; border-radius: 6px; border: 2px solid var(--border-color); display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: 2px; transition: all .2s; background: var(--bg-panel); }

        .total-row { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; font-size: 15px; font-weight: 700; border-top: 2px solid var(--border-color); margin-top: 8px; color: var(--text-main); }
        .total-amount { font-size: 20px; font-weight: 800; color: var(--primary); }

        .badge-done { background: var(--success-light); color: var(--success-dark); }

        .action-bar { display: flex; gap: 10px; justify-content: flex-end; flex-wrap: wrap; }
    </style>
</head>
<body class="dash-body">

<div class="sidebar-backdrop" id="sidebarBackdrop"></div>
<aside class="sidebar" id="sidebar">
    <div class="sidebar-brand">
        <div class="logo-mark-dash">🛵</div>
        <div class="brand-text">
            <span class="brand-title">POB SHIPPER</span>
            <c:choose>
                <c:when test="${sessionScope.account.online}">
                    <span class="brand-subtitle" style="color:var(--success);">● Đang hoạt động</span>
                </c:when>
                <c:otherwise>
                    <span class="brand-subtitle" style="color:var(--danger);">● Ngoại tuyến</span>
                </c:otherwise>
            </c:choose>
        </div>
        <button type="button" class="sidebar-toggle-btn" id="sidebarToggleBtn" onclick="pobToggleSidebar()" title="Thu gọn / mở rộng menu">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
        </button>
    </div>
    <div class="menu">
        <div class="menu-title">Công việc</div>
        <a href="${pageContext.request.contextPath}/shipper/donhang" class="menu-item active">
            <span class="mi-left"><span class="mi-icon">📋</span><span class="mi-label"> Đơn hàng nhận</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/nhan-don" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📥</span><span class="mi-label"> Nhận đơn mới</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/dashboard" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📊</span><span class="mi-label"> Dashboard</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/thongbao" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🔔</span><span class="mi-label"> Thông báo</span></span>
        </a>

        <div class="menu-title">Tài khoản</div>
        <a href="${pageContext.request.contextPath}/shipper/profile" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🚙</span><span class="mi-label"> Hồ sơ tài xế</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/danh-gia" class="menu-item">
            <span class="mi-left"><span class="mi-icon">⭐</span><span class="mi-label"> Đánh giá &amp; Báo cáo</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/vi-tien" class="menu-item">
            <span class="mi-left"><span class="mi-icon">💰</span><span class="mi-label"> Ví tiền</span></span>
        </a>
    </div>
    <div class="sidebar-foot">
        <form action="${pageContext.request.contextPath}/shipper/status" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <c:choose>
                <c:when test="${sessionScope.account.online}">
                    <button type="submit" class="online-toggle-btn is-online"
                            onclick="return confirm('Tắt chế độ Online? Bạn sẽ không nhận đơn mới.')">
                        <span class="toggle-dot online"></span><span class="sf-label">Đang Online — Nhấn để Offline
                    </span></button>
                </c:when>
                <c:otherwise>
                    <button type="submit" class="online-toggle-btn is-offline">
                        <span class="toggle-dot offline"></span><span class="sf-label">Đang Offline — Nhấn để Online
                    </span></button>
                </c:otherwise>
            </c:choose>
        </form>
    </div>
</aside>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1>📦 Chi tiết đơn hàng #${order.id}</h1>
        </div>
        <div class="topbar-right">
            <button type="button" class="theme-toggle" id="themeToggleBtn" onclick="pobToggleTheme()" title="Chuyển đổi giao diện"><span data-theme-icon>🌙</span></button>
            <div class="avatar-wrapper" id="avatarWrapper">
                <div class="avatar-circle" id="avatarBtn">
                    <c:choose>
                        <c:when test="${not empty sessionScope.account.avatarUrl}">
                            <img src="${fn:escapeXml(sessionScope.account.avatarUrl)}" alt="avatar"/>
                        </c:when>
                        <c:otherwise>${fn:escapeXml(fn:toUpperCase(fn:substring(sessionScope.account.userName, 0, 2)))}</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </header>

    <div class="content">

        <div class="panel">
            <div class="panel-header" style="display:flex;justify-content:space-between;align-items:center;">
                <div class="panel-title">🗺️ Lộ trình giao hàng</div>
                <c:if test="${not empty shop && not empty shop.locationX && not empty shop.locationY && not empty order.locationX && not empty order.locationY}">
                    <button type="button" id="shipperLocateGpsBtn" class="btn btn-ghost btn-sm" style="border:1px solid var(--primary);color:var(--primary);font-weight:700;padding:6px 12px;border-radius:8px;">
                        📍 Vị trí hiện tại của tôi
                    </button>
                </c:if>
            </div>
            <div class="panel-body">
                <div class="route-timeline">
                    <div class="route-point">
                        <div class="route-dot dot-shop">🏪</div>
                        <div>
                            <div class="route-info-label">Lấy hàng tại cửa hàng</div>
                            <div class="route-info-name">${fn:escapeXml(bill.shopName)}</div>
                            <c:if test="${not empty order.shopId}">
                                <div class="route-info-sub">Shop ID: ${order.shopId}</div>
                            </c:if>
                        </div>
                    </div>
                    <div class="route-point">
                        <div class="route-dot dot-customer">🏠</div>
                        <div>
                            <div class="route-info-label">Giao tới khách hàng</div>
                            <div class="route-info-name">${fn:escapeXml(order.receiverName)}</div>
                            <div class="route-info-sub">📍 ${fn:escapeXml(order.shippingAddress)}</div>
                            <div class="route-info-sub">📞 ${fn:escapeXml(order.receiverPhone)}</div>
                        </div>
                    </div>
                </div>

                <c:if test="${not empty shop && not empty shop.locationX && not empty shop.locationY && not empty order.locationX && not empty order.locationY}">
                    <div id="routeMap"></div>
                    <div class="route-eta-bar" id="routeEtaBar"></div>
                </c:if>
            </div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">✅ Kiểm tra món hàng tại quán</div>
                <div style="display:flex; align-items:center; gap:10px;">
                    <span id="checkProgress" style="font-size:12px; font-weight:700; color:var(--text-dim);">0/0</span>
                    <button onclick="resetChecklist()" title="Đặt lại" class="btn btn-ghost btn-sm">↺ Reset</button>
                </div>
            </div>
            <div class="panel-body">
                <div style="height:6px; background:var(--border-color); border-radius:99px; margin-bottom:16px; overflow:hidden;">
                    <div id="progressBar" style="height:100%; width:0%; background:var(--primary); border-radius:99px; transition:width .3s;"></div>
                </div>

                <div id="allCheckedBanner" class="alert alert-success" style="display:none; margin-bottom:14px; justify-content:center;">
                    🎉 Đã kiểm tra đủ tất cả món — sẵn sàng giao hàng!
                </div>

                <div class="item-list" id="checklistItems">
                    <c:forEach var="line" items="${bill.lines}" varStatus="vs">
                        <div class="item-row checklist-item" id="item-${vs.index}" onclick="toggleCheck(${vs.index})">
                            <div style="display:flex; align-items:flex-start; gap:12px;">
                                <div class="custom-check" id="check-${vs.index}"></div>
                                <div style="flex:1;">
                                    <div class="item-name" id="name-${vs.index}">${fn:escapeXml(line.productName)}</div>
                                    <div class="item-size">Size: ${fn:escapeXml(line.sizeName)}</div>
                                    <c:if test="${not empty line.toppings}">
                                        <div class="item-topping-list">
                                            <c:forEach var="tp" items="${line.toppings}">
                                                <div class="item-topping">
                                                    + ${fn:escapeXml(tp.toppingName)}
                                                    <c:if test="${tp.quantity > 1}"> × ${tp.quantity}</c:if>
                                                    (<fmt:formatNumber value="${tp.price}" type="number" maxFractionDigits="0"/>đ)
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:if>
                                    <div class="item-price-row">
                                        <span class="item-qty">SL: ${line.quantity} × <fmt:formatNumber value="${line.price}" type="number" maxFractionDigits="0"/>đ</span>
                                        <span class="item-subtotal"><fmt:formatNumber value="${line.lineTotal}" type="number" maxFractionDigits="0"/>đ</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>

                    <c:if test="${empty bill.lines}">
                        <div style="text-align:center;padding:20px;color:var(--text-dim);">Không có dữ liệu chi tiết món hàng.</div>
                    </c:if>

                    <div class="total-row">
                        <span>Tổng cộng</span>
                        <span class="total-amount"><fmt:formatNumber value="${order.totalPrice}" type="number" maxFractionDigits="0"/>đ</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="panel">
            <div class="panel-header"><div class="panel-title">💳 Thông tin thanh toán</div></div>
            <div class="panel-body">
                <div class="info-row">
                    <span class="info-label">Trạng thái đơn</span>
                    <span class="info-value">
                        <c:choose>
                            <c:when test="${order.staTus == 'ACCEPTED'}"><span class="badge badge-info">👨‍🍳 Shop đang chuẩn bị món</span></c:when>
                            <c:when test="${order.staTus == 'READY_FOR_PICKUP'}"><span class="badge badge-warning">📦 Chờ lấy hàng</span></c:when>
                            <c:when test="${order.staTus == 'SHIPPING'}">
                                <span class="badge badge-primary">🛵 Đang giao</span>
                                <span id="trackingWsWarning" class="badge badge-danger" style="display:none;margin-left:6px;">⚠️ Mất kết nối định vị</span>
                            </c:when>
                            <c:when test="${order.staTus == 'DONE'}"><span class="badge badge-done">✅ Đã giao</span></c:when>
                            <c:when test="${order.staTus == 'CANCELLED'}"><span class="badge badge-danger">🚫 Đã huỷ (bom hàng)</span></c:when>
                            <c:otherwise><span class="badge badge-neutral">${order.staTus}</span></c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="info-row">
                    <span class="info-label">Hình thức TT</span>
                    <span class="info-value">
                        <c:choose>
                            <c:when test="${order.paymentMethod == 'PAYOS'}">🏦 PayOS</c:when>
                            <c:when test="${order.paymentMethod == 'BANK'}">📱 QR Chuyển khoản</c:when>
                            <c:otherwise>💵 Tiền mặt (COD)</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="info-row">
                    <span class="info-label">Thời gian đặt</span>
                    <span class="info-value">${order.createdAt}</span>
                </div>
            </div>
        </div>

        <div class="action-bar">
            <a href="${pageContext.request.contextPath}/shipper/donhang">
                <button class="btn btn-ghost">← Quay lại danh sách</button>
            </a>

            <c:if test="${order.staTus == 'ACCEPTED' || order.staTus == 'READY_FOR_PICKUP' || order.staTus == 'SHIPPING'}">
                <button type="button" class="btn btn-danger-outline" onclick="openCancelModal()">❌ Huỷ đơn</button>
            </c:if>

            <c:if test="${order.staTus == 'READY_FOR_PICKUP'}">
                <form action="${pageContext.request.contextPath}/shipper/donhang" method="post" style="display:inline;"
                      onsubmit="return pobGuardSubmit(this)">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="orderId" value="${order.id}">
                    <input type="hidden" name="action" value="updateStatusToShipping">
                    <button type="submit" class="btn btn-warning">📦 Xác nhận đã lấy hàng</button>
                </form>
            </c:if>
            <c:if test="${order.staTus == 'SHIPPING'}">
                <form action="${pageContext.request.contextPath}/shipper/bom-hang" method="post" style="display:inline;"
                      onsubmit="return pobGuardSubmit(this)">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="orderId" value="${order.id}">
                    <button type="submit" class="btn btn-danger"
                            onclick="return confirm('Xác nhận user từ chối nhận hàng (bom hàng)? Hành vi này sẽ được ghi nhận.')">
                        🚫 Báo bom hàng
                    </button>
                </form>
                <form id="completeOrderForm" action="${pageContext.request.contextPath}/shipper/donhang" method="post" style="display:inline;"
                      onsubmit="return pobGuardSubmit(this)">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="orderId" value="${order.id}">
                    <input type="hidden" name="action" value="updateStatusToDone">
                    <button type="button" class="btn btn-primary" onclick="openCompleteModal()">
                        🎉 Hoàn thành giao đơn
                    </button>
                </form>
            </c:if>
        </div>

    </div>
</main>

<c:if test="${order.staTus == 'READY_FOR_PICKUP' || order.staTus == 'SHIPPING'}">
<form id="cancelOrderForm" action="${pageContext.request.contextPath}/shipper/donhang" method="post" style="display:none;">
    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
    <input type="hidden" name="orderId" value="${order.id}">
    <input type="hidden" name="action" value="cancelOrder">
    <input type="hidden" name="reason" id="cancelReasonInput" value="">
</form>
<div class="pob-modal-overlay" id="cancelModalOverlay">
    <div class="pob-modal-box">
        <h3>❌ Huỷ đơn hàng #${order.id}</h3>
        <p>Vui lòng nhập lý do huỷ đơn. Lý do này sẽ được lưu lại vào lịch sử đơn hàng.</p>
        <textarea id="cancelReasonTextarea" placeholder="Ví dụ: xe hỏng, không tìm được địa chỉ giao hàng..." maxlength="500"></textarea>
        <div class="modal-error" id="cancelReasonError">Vui lòng nhập lý do huỷ đơn.</div>
        <div class="modal-actions">
            <button type="button" class="btn-back" onclick="closeCancelModal()">Đóng</button>
            <button type="button" class="btn-danger" onclick="confirmCancelOrder()">Xác nhận huỷ đơn</button>
        </div>
    </div>
</div>
</c:if>

<c:if test="${order.staTus == 'SHIPPING'}">
<div class="pob-modal-overlay" id="completeModalOverlay">
    <div class="pob-modal-box complete-modal-box">
        <div class="complete-modal-icon">🎉</div>
        <h3>Xác nhận hoàn thành giao đơn</h3>
        <p>Đơn hàng #${order.id} sẽ được đánh dấu <strong>đã giao thành công</strong>. Hành động này không thể hoàn tác.</p>
        <div class="modal-actions">
            <button type="button" class="btn-back" onclick="closeCompleteModal()">Huỷ</button>
            <button type="button" class="btn-success-solid" onclick="confirmCompleteOrder()">✅ Xác nhận đã giao</button>
        </div>
    </div>
</div>
</c:if>

<script>
    function openCompleteModal() {
        document.getElementById('completeModalOverlay').classList.add('open');
    }

    function closeCompleteModal() {
        document.getElementById('completeModalOverlay').classList.remove('open');
    }

    function confirmCompleteOrder() {
        document.getElementById('completeOrderForm').submit();
    }

    var completeModalOverlayEl = document.getElementById('completeModalOverlay');
    if (completeModalOverlayEl) {
        completeModalOverlayEl.addEventListener('click', function (e) {
            if (e.target === completeModalOverlayEl) {
                closeCompleteModal();
            }
        });
    }

    function openCancelModal() {
        var overlay = document.getElementById('cancelModalOverlay');
        var textarea = document.getElementById('cancelReasonTextarea');
        document.getElementById('cancelReasonError').style.display = 'none';
        textarea.value = '';
        overlay.classList.add('open');
        textarea.focus();
    }

    function closeCancelModal() {
        document.getElementById('cancelModalOverlay').classList.remove('open');
    }

    function confirmCancelOrder() {
        var reason = document.getElementById('cancelReasonTextarea').value.trim();
        var errorEl = document.getElementById('cancelReasonError');
        if (!reason) {
            errorEl.style.display = 'block';
            return;
        }
        errorEl.style.display = 'none';
        document.getElementById('cancelReasonInput').value = reason;
        document.getElementById('cancelOrderForm').submit();
    }

    var cancelModalOverlayEl = document.getElementById('cancelModalOverlay');
    if (cancelModalOverlayEl) {
        cancelModalOverlayEl.addEventListener('click', function (e) {
            if (e.target === cancelModalOverlayEl) {
                closeCancelModal();
            }
        });
    }
</script>

<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${fn:escapeXml(sessionScope.account.userName)}</div>
        <div class="d-email">${fn:escapeXml(sessionScope.account.email)}</div>
        <span class="d-role">🛵 Shipper</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/shipper/ho-so" class="dropdown-link">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/shipper/doi-mat-khau" class="dropdown-link">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/form-guard.js"></script>
<script>
    // --- CHECKLIST ---
    var ORDER_ID    = '${order.id}';
    var STORAGE_KEY = 'checklist_order_' + ORDER_ID;
    var total       = document.querySelectorAll('.checklist-item').length;

    function loadState() {
        try { return JSON.parse(localStorage.getItem(STORAGE_KEY)) || []; }
        catch (e) { return []; }
    }

    function saveState(checked) {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(checked));
    }

    function updateUI(checked) {
        var count = checked.length;
        document.getElementById('checkProgress').textContent = count + '/' + total;
        document.getElementById('progressBar').style.width   = total > 0 ? (count / total * 100) + '%' : '0%';
        document.getElementById('allCheckedBanner').style.display = (count === total && total > 0) ? 'flex' : 'none';

        for (var i = 0; i < total; i++) {
            var isChecked = checked.indexOf(i) !== -1;
            var row  = document.getElementById('item-' + i);
            var box  = document.getElementById('check-' + i);
            var name = document.getElementById('name-' + i);

            if (isChecked) {
                box.style.background = 'var(--primary)';
                box.style.borderColor = 'var(--primary)';
                box.innerHTML = '<span style="color:#fff;font-size:13px;font-weight:900;">✓</span>';
                row.style.opacity = '0.6';
                name.style.textDecoration = 'line-through';
            } else {
                box.style.background = 'var(--bg-panel)';
                box.style.borderColor = 'var(--border-color)';
                box.innerHTML = '';
                row.style.opacity = '1';
                name.style.textDecoration = 'none';
            }
        }
    }

    function toggleCheck(index) {
        var checked = loadState();
        var pos = checked.indexOf(index);
        if (pos === -1) checked.push(index);
        else checked.splice(pos, 1);
        saveState(checked);
        updateUI(checked);
    }

    function resetChecklist() {
        pobConfirm('Đặt lại toàn bộ checklist?').then(function(ok) {
            if (!ok) return;
            localStorage.removeItem(STORAGE_KEY);
            updateUI([]);
        });
    }

    document.addEventListener('DOMContentLoaded', function () { updateUI(loadState()); });

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

<c:if test="${order.staTus == 'SHIPPING'}">
<script>
(function () {
    var orderId = ${order.id};
    var protocol = location.protocol === 'https:' ? 'wss://' : 'ws://';
    var wsUrl = protocol + location.host + '${pageContext.request.contextPath}/ws/tracking?role=shipper&orderId=' + orderId;
    var socket = new WebSocket(wsUrl);
    var watchId = null;
    var lastSentAt = 0;
    var MIN_INTERVAL_MS = 3000;

    function sendPosition(position) {
        var now = Date.now();
        if (now - lastSentAt < MIN_INTERVAL_MS) return;
        lastSentAt = now;
        if (socket.readyState === WebSocket.OPEN) {
            socket.send(JSON.stringify({
                lat: position.coords.latitude,
                lng: position.coords.longitude
            }));
        }
    }

    function handleGeoError(err) {
        console.warn('Không thể lấy vị trí GPS:', err.message);
    }

    function showTrackingWarning() {
        var el = document.getElementById('trackingWsWarning');
        if (el) {
            el.style.display = 'inline-block';
        }
    }

    socket.addEventListener('open', function () {
        if (navigator.geolocation) {
            watchId = navigator.geolocation.watchPosition(sendPosition, handleGeoError, {
                enableHighAccuracy: true,
                maximumAge: 5000
            });
        }
    });

    socket.addEventListener('close', showTrackingWarning);
    socket.addEventListener('error', showTrackingWarning);

    window.addEventListener('beforeunload', function () {
        if (watchId !== null && navigator.geolocation) {
            navigator.geolocation.clearWatch(watchId);
        }
        if (socket.readyState === WebSocket.OPEN) {
            socket.close();
        }
    });
})();
</script>
</c:if>

<c:if test="${not empty shop && not empty shop.locationX && not empty shop.locationY && not empty order.locationX && not empty order.locationY}">
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
(function () {
    var shopLat = ${shop.locationX}, shopLng = ${shop.locationY};
    var destLat = ${order.locationX}, destLng = ${order.locationY};

    var map = L.map('routeMap');
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; OpenStreetMap'
    }).addTo(map);

    var shopIcon = L.divIcon({className: 'shop-marker-icon', html: '🏪', iconSize: [24, 24], iconAnchor: [12, 12]});
    var destIcon = L.divIcon({className: 'shop-marker-icon', html: '🏠', iconSize: [24, 24], iconAnchor: [12, 12]});
    L.marker([shopLat, shopLng], {icon: shopIcon}).addTo(map).bindPopup('🏪 Lấy hàng');
    L.marker([destLat, destLng], {icon: destIcon}).addTo(map).bindPopup('🏠 Giao hàng');

    var bounds = L.latLngBounds([[shopLat, shopLng], [destLat, destLng]]);
    map.fitBounds(bounds, {padding: [60, 60]});
    setTimeout(function () { map.invalidateSize(); }, 0);

    function toRad(deg) { return deg * Math.PI / 180; }
    function haversineKm(lat1, lng1, lat2, lng2) {
        var R = 6371;
        var dLat = toRad(lat2 - lat1), dLng = toRad(lng2 - lng1);
        var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    function showFallbackLine(note) {
        L.polyline([[shopLat, shopLng], [destLat, destLng]], {color: '#f97316', weight: 3, dashArray: '6,8'}).addTo(map);
        var km = haversineKm(shopLat, shopLng, destLat, destLng);
        document.getElementById('routeEtaBar').innerHTML =
            '📏 ~' + km.toFixed(1) + ' km (đường chim bay)' + (note ? ' · ' + note : '');
    }

    // Goi OSRM (dich vu routing mien phi, demo server public) de ve duong di thuc te tren duong xa.
    // Neu loi (mat mang, rate limit cua demo server...) thi fallback ve duong thang + khoang cach
    // uoc tinh, khong de trang trang khong co thong tin gi.
    fetch('https://router.project-osrm.org/route/v1/driving/' + shopLng + ',' + shopLat + ';' + destLng + ',' + destLat + '?overview=full&geometries=geojson')
        .then(function (res) { if (!res.ok) throw new Error('OSRM error'); return res.json(); })
        .then(function (data) {
            if (!data.routes || !data.routes.length) { showFallbackLine(); return; }
            var route = data.routes[0];
            var latlngs = route.geometry.coordinates.map(function (c) { return [c[1], c[0]]; });
            var line = L.polyline(latlngs, {color: '#2563eb', weight: 4}).addTo(map);
            map.fitBounds(line.getBounds(), {padding: [60, 60]});

            var km = (route.distance / 1000).toFixed(1);
            var minutes = Math.max(1, Math.round(route.duration / 60));
            document.getElementById('routeEtaBar').innerHTML =
                '🛣️ ' + km + ' km theo đường đi · ⏱️ ~' + minutes + ' phút';
        })
        .catch(function () { showFallbackLine('không lấy được tuyến đường thực tế'); });

    var locateBtn = document.getElementById('shipperLocateGpsBtn');
    var shipperLocMarker = null;
    if (locateBtn) {
        locateBtn.addEventListener('click', function () {
            if (!navigator.geolocation) {
                alert('Trình duyệt không hỗ trợ GPS.');
                return;
            }
            var originalText = locateBtn.innerHTML;
            locateBtn.disabled = true;
            locateBtn.innerHTML = '⏳ Đang định vị...';
            navigator.geolocation.getCurrentPosition(
                function (pos) {
                    locateBtn.disabled = false;
                    locateBtn.innerHTML = originalText;
                    var lat = pos.coords.latitude;
                    var lng = pos.coords.longitude;
                    if (!shipperLocMarker) {
                        var icon = L.divIcon({className: 'shop-marker-icon', html: '🛵', iconSize: [28, 28], iconAnchor: [14, 14]});
                        shipperLocMarker = L.marker([lat, lng], {icon: icon, zIndexOffset: 2000}).addTo(map).bindPopup('🛵 Vị trí hiện tại của bạn');
                    } else {
                        shipperLocMarker.setLatLng([lat, lng]);
                    }
                    map.setView([lat, lng], 16);
                    shipperLocMarker.openPopup();
                },
                function (err) {
                    locateBtn.disabled = false;
                    locateBtn.innerHTML = originalText;
                    alert('Không thể lấy vị trí hiện tại. Vui lòng kiểm tra quyền GPS.');
                },
                { enableHighAccuracy: true, timeout: 10000 }
            );
        });
    }
})();
</script>
</c:if>
</body>
</html>
