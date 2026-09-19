<%@ page pageEncoding="utf-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - FOOD MANAGE</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #FFF9F2;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }
        .logo-text-main, .page-title, .deco-headline, .appeal-title, .suspend-title, .logo-badge, .deco-brand-badge {
            font-family: 'Quicksand', 'Plus Jakarta Sans', sans-serif;
        }

        .auth-card {
            display: flex;
            width: 100%;
            max-width: 960px;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(26, 32, 53, 0.12);
            animation: fadeInUp 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        }

        /* ===== LEFT PANEL ===== */
        .form-panel {
            flex: 0 0 44%;
            background: #ffffff;
            padding: 48px 44px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .logo-wrap { display: flex; align-items: center; gap: 12px; margin-bottom: 32px; }
        .logo-badge {
            width: 40px; height: 40px; border-radius: 12px;
            background: linear-gradient(135deg, #FF3B1F, #E02A10);
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-weight: 800; font-size: 13px;
            box-shadow: 0 4px 12px rgba(255,59,31,0.32);
        }
        .logo-text-main { font-size: 11px; font-weight: 800; color: #FF3B1F; letter-spacing: 0.12em; text-transform: uppercase; display: block; }
        .logo-text-sub  { font-size: 9px;  font-weight: 600; color: #635752; letter-spacing: 0.1em;  text-transform: uppercase; display: block; margin-top: 2px; }

        .page-title { font-size: 26px; font-weight: 800; color: #2D2421; letter-spacing: -0.02em; margin-bottom: 6px; }
        .page-sub   { font-size: 13px; color: #635752; margin-bottom: 24px; }

        .alert { display: flex; align-items: center; gap: 10px; border-radius: 12px; padding: 12px 16px; font-size: 13px; font-weight: 500; margin-bottom: 20px; }
        .alert-error   { background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; }
        .alert-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803D; }
        .alert svg { flex-shrink: 0; }

        .form-group { margin-bottom: 16px; }
        .field-label { display: block; font-size: 11px; font-weight: 700; color: #4A3934; text-transform: uppercase; letter-spacing: 0.06em; margin-bottom: 6px; }
        .field-wrap  { position: relative; }
        .field-icon-left {
            position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
            color: #A99284; pointer-events: none; transition: color 0.2s;
        }
        .input-field {
            width: 100%; background: #FFF4EC; border: 1.5px solid #F1E4D6;
            border-radius: 12px; padding: 12px 14px 12px 42px;
            font-size: 14px; color: #2D2421; font-weight: 500; font-family: inherit;
            outline: none; transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
        }
        .input-field:focus { border-color: #FF3B1F; background: #fff; box-shadow: 0 0 0 4px rgba(255,59,31,0.12); }
        .input-field::placeholder { color: #A99284; font-weight: 400; font-size: 13px; }
        input:-webkit-autofill { -webkit-box-shadow: 0 0 0 30px #FFF4EC inset !important; }

        .toggle-pw {
            position: absolute; right: 12px; top: 50%; transform: translateY(-50%);
            background: none; border: none; cursor: pointer; color: #A99284;
            padding: 4px; transition: color 0.2s; display: flex; align-items: center;
        }
        .toggle-pw:hover { color: #FF3B1F; }
        .hidden { display: none !important; }
        .error-inline { color: #dc2626; font-size: 11.5px; font-weight: 500; margin-top: 5px; display: block; }

        .forgot-link-wrap { text-align: right; margin-top: 4px; margin-bottom: 4px; }
        .forgot-link { font-size: 12px; font-weight: 700; color: #FF3B1F; text-decoration: none; }
        .forgot-link:hover { color: #E02A10; }

        .btn-primary {
            width: 100%; background: linear-gradient(135deg, #FF3B1F, #E02A10);
            color: #fff; font-weight: 700; font-size: 14px; letter-spacing: 0.02em;
            padding: 14px; border-radius: 12px; border: none; cursor: pointer;
            transition: all 0.2s; box-shadow: 0 4px 16px rgba(255,59,31,0.35);
            font-family: inherit; margin-top: 4px;
        }
        .btn-primary:hover { transform: translateY(-1.5px); box-shadow: 0 6px 22px rgba(255,59,31,0.45); }
        .btn-primary:active { transform: translateY(0); }

        .form-footer { text-align: center; font-size: 13px; color: #635752; margin-top: 16px; }
        .form-footer a { color: #FF3B1F; font-weight: 700; text-decoration: none; }
        .form-footer a:hover { color: #E02A10; }

        /* ===== RIGHT PANEL ===== */
        .deco-panel {
            flex: 1;
            background: linear-gradient(155deg, #3A1206 0%, #1A0A04 100%);
            padding: 48px 44px;
            display: flex; flex-direction: column; justify-content: space-between;
            position: relative; overflow: hidden;
        }
        .deco-panel::before {
            content: ''; position: absolute; top: -80px; right: -80px;
            width: 320px; height: 320px; border-radius: 50%;
            background: radial-gradient(circle, rgba(255,59,31,0.18) 0%, transparent 70%);
            pointer-events: none;
        }
        .deco-panel::after {
            content: ''; position: absolute; bottom: -60px; left: -60px;
            width: 240px; height: 240px; border-radius: 50%;
            background: radial-gradient(circle, rgba(255,179,0,0.08) 0%, transparent 70%);
            pointer-events: none;
        }

        .deco-brand { display: flex; align-items: center; gap: 10px; position: relative; z-index: 1; }
        .deco-brand-badge {
            width: 36px; height: 36px; border-radius: 10px;
            background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.12);
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-weight: 800; font-size: 12px;
        }
        .deco-brand-label { font-size: 12px; color: rgba(255,255,255,0.35); font-weight: 600; letter-spacing: 0.05em; }

        .deco-body { position: relative; z-index: 1; }
        .deco-headline { font-size: 29px; font-weight: 800; color: #fff; line-height: 1.3; letter-spacing: -0.02em; margin-bottom: 14px; }
        .deco-headline span { color: #FFB300; }
        .deco-desc { font-size: 13px; color: rgba(255,255,255,0.42); line-height: 1.7; margin-bottom: 28px; max-width: 320px; }

        .feature-list { display: flex; flex-direction: column; gap: 10px; }
        .feature-item {
            display: flex; align-items: flex-start; gap: 14px;
            padding: 14px 16px; border-radius: 14px;
            background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.06);
            transition: background 0.2s, transform 0.2s;
        }
        .feature-item:hover { background: rgba(255,255,255,0.07); transform: translateX(4px); }
        .feature-icon { width: 38px; height: 38px; border-radius: 10px; background: rgba(255,255,255,0.07); display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
        .feature-title { font-size: 13.5px; font-weight: 700; color: #fff; margin-bottom: 3px; }
        .feature-desc  { font-size: 11.5px; color: rgba(255,255,255,0.38); line-height: 1.5; }
        .deco-footer { font-size: 11px; color: rgba(255,255,255,0.2); position: relative; z-index: 1; }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(24px) scale(0.98); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }

        /* ===== SUSPENDED MODAL ===== */
        .suspend-backdrop {
            position: fixed; inset: 0; background: rgba(15,22,36,0.65);
            backdrop-filter: blur(6px); display: flex;
            align-items: center; justify-content: center; z-index: 999;
        }
        .suspend-box {
            background: #fff; border-radius: 20px; padding: 36px 32px;
            max-width: 460px; width: 92%;
            box-shadow: 0 30px 80px rgba(15,22,36,0.28);
            animation: popIn 0.35s cubic-bezier(0.34,1.56,0.64,1);
        }
        @keyframes popIn { from { transform: scale(0.88); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        .suspend-icon  { font-size: 52px; text-align: center; margin-bottom: 14px; }
        .suspend-title { font-size: 20px; font-weight: 800; color: #dc2626; text-align: center; letter-spacing: -0.02em; margin-bottom: 10px; }
        .suspend-reason-label { font-size: 10.5px; font-weight: 700; color: #635752; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px; }
        .suspend-reason-box { background: #fef2f2; border: 1.5px solid #fecaca; border-radius: 12px; padding: 12px 16px; font-size: 13.5px; color: #c53030; font-weight: 600; line-height: 1.6; margin-bottom: 18px; }
        .suspend-desc  { font-size: 13px; color: #635752; line-height: 1.6; text-align: center; margin-bottom: 18px; }
        .suspend-divider { border: none; border-top: 1px solid #F1E4D6; margin: 18px 0; }
        .appeal-title  { font-size: 14px; font-weight: 800; color: #2D2421; margin-bottom: 10px; }
        .appeal-textarea { width: 100%; border: 1.5px solid #F1E4D6; border-radius: 12px; padding: 12px 14px; font-size: 13px; color: #2D2421; font-family: inherit; resize: vertical; outline: none; min-height: 88px; background: #FFF4EC; transition: border-color 0.2s, box-shadow 0.2s; }
        .appeal-textarea:focus { border-color: #FF3B1F; background: #fff; box-shadow: 0 0 0 4px rgba(255,59,31,0.1); }
        .appeal-hint   { font-size: 11px; color: #635752; margin: 5px 0 14px; }
        .btn-row       { display: flex; gap: 10px; }
        .btn-appeal    { flex: 1; background: linear-gradient(135deg, #FF3B1F, #E02A10); color: #fff; border: none; border-radius: 12px; padding: 12px; font-size: 13.5px; font-weight: 700; cursor: pointer; font-family: inherit; box-shadow: 0 4px 12px rgba(255,59,31,0.3); transition: all 0.2s; }
        .btn-appeal:hover { opacity: 0.92; transform: translateY(-1px); }
        .btn-close     { background: #F1E4D6; color: #4A3934; border: none; border-radius: 12px; padding: 12px 20px; font-size: 13.5px; font-weight: 700; cursor: pointer; font-family: inherit; transition: background 0.2s; }
        .btn-close:hover { background: #F1E4D6; }
        .appeal-success { background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 12px; padding: 12px 16px; color: #15803d; font-size: 13.5px; font-weight: 600; text-align: center; margin-bottom: 14px; }
        .appeal-error   { background: #fef2f2; border: 1px solid #fecaca; border-radius: 12px; padding: 12px 16px; color: #c53030; font-size: 13px; font-weight: 600; margin-bottom: 12px; }

        @media (max-width: 720px) {
            .auth-card { flex-direction: column; }
            .deco-panel { display: none; }
            .form-panel { flex: none; width: 100%; padding: 36px 28px; }
        }
    </style>
</head>
<body>

<div class="auth-card">

    <!-- LEFT: FORM -->
    <div class="form-panel">

        <div class="logo-wrap">
            <div class="logo-badge">FM</div>
            <div>
                <span class="logo-text-main">FOOD MANAGE</span>
                <span class="logo-text-sub">Ordering System</span>
            </div>
        </div>

        <h1 class="page-title">Đăng nhập</h1>
        <p class="page-sub">Chào mừng trở lại! Hãy đăng nhập để tiếp tục đặt hàng.</p>

        <% if (request.getAttribute("loi") != null && !((String)request.getAttribute("loi")).isEmpty()) { %>
        <div class="alert alert-error">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span><%= request.getAttribute("loi") %></span>
        </div>
        <% } %>
        <% if (request.getAttribute("thongbao") != null && !((String)request.getAttribute("thongbao")).isEmpty()) { %>
        <div class="alert alert-success">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span><%= request.getAttribute("thongbao") %></span>
        </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/dangnhap" method="post" onsubmit="return validateLogin()">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

            <div class="form-group">
                <label class="field-label">Tên đăng nhập</label>
                <div class="field-wrap">
                    <input type="text" name="username" required placeholder="Nhập tên đăng nhập" class="input-field" value="<c:out value='${username}'/>">
                    <svg class="field-icon-left" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                </div>
            </div>

            <div class="form-group">
                <label class="field-label">Mật khẩu</label>
                <div class="field-wrap">
                    <input type="password" name="password" id="password" required placeholder="Nhập mật khẩu" class="input-field" style="padding-right:42px;">
                    <svg class="field-icon-left" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                    <button type="button" onclick="togglePassword('password', this)" class="toggle-pw">
                        <svg class="eye-show" width="17" height="17" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                        <svg class="eye-hide hidden" width="17" height="17" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/></svg>
                    </button>
                </div>
                <span id="passwordError" class="error-inline"></span>
            </div>

            <div class="forgot-link-wrap">
                <a href="${pageContext.request.contextPath}/quenmatkhau" class="forgot-link">Quên mật khẩu?</a>
            </div>

            <button type="submit" class="btn-primary">Đăng nhập</button>
        </form>

        <p class="form-footer">
            Chưa có tài khoản?
            <a href="${pageContext.request.contextPath}/dangky">Đăng ký ngay</a>
        </p>
    </div>

    <!-- RIGHT: DECORATIVE -->
    <div class="deco-panel">
        <div class="deco-brand">
            <div class="deco-brand-badge">FM</div>
            <span class="deco-brand-label">Hệ thống đặt hàng trực tuyến</span>
        </div>

        <div class="deco-body">
            <h2 class="deco-headline">Đặt hàng dễ dàng,<br>giao hàng nhanh chóng,<br><span>thưởng thức món ngon.</span></h2>
            <p class="deco-desc">Đăng nhập để khám phá hàng ngàn món ăn ngon và nhận ưu đãi từ các cửa hàng uy tín trên FOOD MANAGE.</p>
            <div class="feature-list">
                <div class="feature-item">
                    <div class="feature-icon">🛒</div>
                    <div>
                        <div class="feature-title">Đặt hàng dễ dàng</div>
                        <div class="feature-desc">Chọn size, toppings và đặt đơn trong nháy mắt</div>
                    </div>
                </div>
                <div class="feature-item">
                    <div class="feature-icon">🚀</div>
                    <div>
                        <div class="feature-title">Giao hàng nhanh</div>
                        <div class="feature-desc">Đội ngũ shipper tận tình giao hàng nóng hổi</div>
                    </div>
                </div>
                <div class="feature-item">
                    <div class="feature-icon">✨</div>
                    <div>
                        <div class="feature-title">Thanh toán linh hoạt</div>
                        <div class="feature-desc">Hỗ trợ COD tiền mặt hoặc chuyển khoản QR PayOS</div>
                    </div>
                </div>
            </div>
        </div>

        <p class="deco-footer">© 2026 FOOD MANAGE — All rights reserved</p>
    </div>

</div>

<script>
    function validateLogin() {
        var password = document.getElementById("password").value.trim();
        var errorMsg = document.getElementById("passwordError");
        if (!password) { errorMsg.textContent = "⚠️ Mật khẩu không được để trống!"; return false; }
        if (password.length < 8 || password.length > 16) { errorMsg.textContent = "⚠️ Mật khẩu phải từ 8 đến 16 ký tự!"; return false; }
        if (password.includes(" ")) { errorMsg.textContent = "⚠️ Mật khẩu không được chứa khoảng trắng!"; return false; }
        errorMsg.textContent = "";
        return true;
    }
    function togglePassword(id, btn) {
        var input = document.getElementById(id);
        var show = btn.querySelector('.eye-show');
        var hide = btn.querySelector('.eye-hide');
        if (input.type === 'password') { input.type = 'text'; show.classList.add('hidden'); hide.classList.remove('hidden'); }
        else { input.type = 'password'; show.classList.remove('hidden'); hide.classList.add('hidden'); }
    }
</script>

<%-- POPUP TÀI KHOẢN BỊ ĐÌNH CHỈ --%>
<% if (Boolean.TRUE.equals(request.getAttribute("suspended"))) {
   String suspendReason = (String) request.getAttribute("suspendReason");
   if (suspendReason == null) suspendReason = "Vi phạm điều khoản sử dụng";
   Object accountIdObj = request.getAttribute("suspendedAccountId");
   long suspendedAccountId = accountIdObj != null ? ((Number) accountIdObj).longValue() : 0;
   boolean appealSent = "1".equals(request.getParameter("appealSent"));
   String appealError = request.getParameter("appealError");
%>
<div class="suspend-backdrop" id="suspendModal">
    <div class="suspend-box">
        <div class="suspend-icon">🚫</div>
        <div class="suspend-title">Tài khoản bị đình chỉ</div>
        <div class="suspend-reason-label">Lý do từ Admin</div>
        <div class="suspend-reason-box"><%= suspendReason %></div>
        <div class="suspend-desc">Rất tiếc, tài khoản của bạn đã bị Admin đình chỉ. Nếu có nhầm lẫn, vui lòng gửi kháng nghị bên dưới.</div>
        <hr class="suspend-divider">
        <div class="appeal-title">📝 Gửi kháng nghị phục hồi</div>
        <% if (appealSent) { %>
        <div class="appeal-success">✅ Đã gửi kháng nghị! Vui lòng đợi Admin duyệt trong 24h tới.</div>
        <button class="btn-close" style="width:100%;" onclick="document.getElementById('suspendModal').style.display='none'">Đóng</button>
        <% } else { %>
        <% if ("duplicate".equals(appealError)) { %>
        <div class="appeal-error">⚠️ Bạn đang có một kháng nghị chờ duyệt. Xin không gửi trùng lặp.</div>
        <% } else if (appealError != null) { %>
        <div class="appeal-error">⚠️ Không thể gửi kháng nghị. Vui lòng kiểm tra lại kết nối.</div>
        <% } %>
        <form method="post" action="<%= request.getContextPath() %>/appeal">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="accountId" value="<%= suspendedAccountId %>"/>
            <textarea class="appeal-textarea" name="message" required placeholder="Mô tả lý do bạn cho rằng tài khoản bị khóa do nhầm lẫn..."></textarea>
            <div class="appeal-hint">Kháng nghị của bạn sẽ được gửi trực tiếp tới Ban Quản Trị để giải quyết.</div>
            <div class="btn-row">
                <button type="button" class="btn-close" onclick="document.getElementById('suspendModal').style.display='none'">Hủy bỏ</button>
                <button type="submit" class="btn-appeal">📨 Gửi kháng nghị</button>
            </div>
        </form>
        <% } %>
    </div>
</div>
<% } %>

<script src="<%= request.getContextPath() %>/assets/js/toast.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
</body>
</html>
