<%@ page pageEncoding="utf-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký - FOOD MANAGE</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        .logo-text-main, .page-title, .deco-headline, .logo-badge, .step-num { font-family: 'Quicksand', 'Plus Jakarta Sans', sans-serif; }
        body {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #FFF9F2;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        .auth-card {
            display: flex;
            width: 100%;
            max-width: 1020px;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(99,44,20,0.12);
            animation: fadeInUp 0.4s cubic-bezier(0.16,1,0.3,1);
        }

        /* LEFT */
        .form-panel {
            flex: 0 0 44%;
            background: #ffffff;
            padding: 40px 44px;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            max-height: 92vh;
        }
        .form-panel::-webkit-scrollbar { width: 5px; }
        .form-panel::-webkit-scrollbar-thumb { background: #D9C9BA; border-radius: 10px; }

        .logo-wrap { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
        .logo-badge { width: 40px; height: 40px; border-radius: 12px; background: linear-gradient(135deg, #FF3B1F, #E02A10); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 13px; box-shadow: 0 4px 12px rgba(99,44,20,0.3); }
        .logo-text-main { font-size: 11px; font-weight: 800; color: #FF3B1F; letter-spacing: 0.12em; text-transform: uppercase; display: block; }
        .logo-text-sub  { font-size: 9px; font-weight: 600; color: #8A7B6C; letter-spacing: 0.1em; text-transform: uppercase; display: block; margin-top: 2px; }

        .page-title { font-size: 24px; font-weight: 800; color: #2D2421; letter-spacing: -0.02em; margin-bottom: 4px; }
        .page-sub   { font-size: 13px; color: #8A7B6C; margin-bottom: 20px; }

        .alert { display: flex; align-items: center; gap: 10px; border-radius: 12px; padding: 12px 16px; font-size: 13px; font-weight: 500; margin-bottom: 16px; }
        .alert-error { background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; }
        .alert svg { flex-shrink: 0; }

        .form-group { margin-bottom: 14px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px; }
        .field-label { display: block; font-size: 11px; font-weight: 700; color: #4A3934; text-transform: uppercase; letter-spacing: 0.06em; margin-bottom: 5px; }
        .field-wrap { position: relative; }
        .field-icon-left { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #C9B8A8; pointer-events: none; transition: color 0.2s; }
        .input-field {
            width: 100%; background: #FFF4EC; border: 1.5px solid #F1E4D6;
            border-radius: 12px; padding: 11px 14px 11px 42px;
            font-size: 13.5px; color: #2D2421; font-weight: 500; font-family: inherit;
            outline: none; transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
        }
        .input-field:focus { border-color: #FF3B1F; background: #fff; box-shadow: 0 0 0 4px rgba(255,59,31,0.12); }
        .input-field::placeholder { color: #C9B8A8; font-weight: 400; font-size: 12.5px; }
        input:-webkit-autofill { -webkit-box-shadow: 0 0 0 30px #FFF4EC inset !important; }

        .toggle-pw { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; color: #C9B8A8; padding: 4px; transition: color 0.2s; display: flex; align-items: center; }
        .toggle-pw:hover { color: #FF3B1F; }
        .hidden { display: none !important; }
        .error-inline { color: #dc2626; font-size: 11.5px; font-weight: 500; margin-top: 4px; display: block; }

        .btn-primary { width: 100%; background: linear-gradient(135deg, #FF3B1F, #E02A10); color: #fff; font-weight: 700; font-size: 14px; padding: 13px; border-radius: 12px; border: none; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 16px rgba(255,59,31,0.35); font-family: inherit; margin-top: 6px; }
        .btn-primary:hover { transform: translateY(-1.5px); box-shadow: 0 6px 22px rgba(255,59,31,0.45); }
        .btn-primary:active { transform: translateY(0); }

        .form-footer { text-align: center; font-size: 13px; color: #8A7B6C; margin-top: 14px; }
        .form-footer a { color: #FF3B1F; font-weight: 700; text-decoration: none; }
        .form-footer a:hover { color: #E02A10; }

        .role-divider { text-align: center; font-size: 10.5px; font-weight: 700; color: #D9C9BA; text-transform: uppercase; letter-spacing: 0.08em; margin: 18px 0 12px; }
        .role-btn-row { display: flex; gap: 10px; }
        .role-btn {
            flex: 1; text-align: center; border: 1.5px solid #F1E4D6; border-radius: 12px;
            padding: 11px 8px; font-size: 12.5px; font-weight: 700; color: #4A3934;
            background: #FFF4EC; text-decoration: none; transition: all 0.2s; display: block;
        }
        .role-btn:hover { border-color: #FF3B1F; color: #FF3B1F; background: #FFF2F0; transform: translateY(-1px); }

        /* RIGHT */
        .deco-panel {
            flex: 1;
            background: linear-gradient(155deg, #3A1206 0%, #1A0A04 100%);
            padding: 48px 44px;
            display: flex; flex-direction: column; justify-content: space-between;
            position: relative; overflow: hidden;
        }
        .deco-panel::before { content: ''; position: absolute; top: -80px; right: -80px; width: 320px; height: 320px; border-radius: 50%; background: radial-gradient(circle, rgba(255,59,31,0.12) 0%, transparent 70%); pointer-events: none; }
        .deco-panel::after  { content: ''; position: absolute; bottom: -60px; left: -60px; width: 240px; height: 240px; border-radius: 50%; background: radial-gradient(circle, rgba(255,179,0,0.08) 0%, transparent 70%); pointer-events: none; }

        .deco-brand { display: flex; align-items: center; gap: 10px; position: relative; z-index: 1; }
        .deco-brand-badge { width: 36px; height: 36px; border-radius: 10px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.12); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 12px; }
        .deco-brand-label { font-size: 12px; color: rgba(255,255,255,0.35); font-weight: 600; letter-spacing: 0.05em; }

        .deco-body { position: relative; z-index: 1; }
        .deco-headline { font-size: 29px; font-weight: 800; color: #fff; line-height: 1.3; letter-spacing: -0.02em; margin-bottom: 14px; }
        .deco-headline span { color: #FFB300; }
        .deco-desc { font-size: 13px; color: rgba(255,255,255,0.42); line-height: 1.7; margin-bottom: 28px; max-width: 320px; }

        .step-list { display: flex; flex-direction: column; gap: 10px; }
        .step-item { display: flex; align-items: flex-start; gap: 14px; padding: 14px 16px; border-radius: 14px; background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.06); transition: background 0.2s, transform 0.2s; }
        .step-item:hover { background: rgba(255,255,255,0.07); transform: translateX(4px); }
        .step-num { width: 32px; height: 32px; border-radius: 10px; background: rgba(255,255,255,0.07); display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: 800; color: #FFB300; flex-shrink: 0; border: 1px solid rgba(255,255,255,0.05); }
        .step-title { font-size: 13.5px; font-weight: 700; color: #fff; margin-bottom: 3px; }
        .step-desc  { font-size: 11.5px; color: rgba(255,255,255,0.38); line-height: 1.5; }
        .deco-footer { font-size: 11px; color: rgba(255,255,255,0.2); position: relative; z-index: 1; }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(24px) scale(0.98); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }
        @media (max-width: 720px) {
            .auth-card { flex-direction: column; }
            .deco-panel { display: none; }
            .form-panel { flex: none; width: 100%; max-height: none; padding: 32px 24px; }
        }
    </style>
</head>
<body>

<div class="auth-card">

    <!-- LEFT: FORM -->
    <div class="form-panel">

        <a href="${pageContext.request.contextPath}/index.jsp" class="logo-wrap" style="text-decoration:none;cursor:pointer;">
            <div class="logo-badge">FM</div>
            <div>
                <span class="logo-text-main">FOOD MANAGE</span>
                <span class="logo-text-sub">Ordering System</span>
            </div>
        </a>

        <h1 class="page-title">Tạo tài khoản 🎉</h1>
        <p class="page-sub">Đăng ký để bắt đầu trải nghiệm FOOD MANAGE</p>

        <% if (request.getAttribute("loi") != null && !((String)request.getAttribute("loi")).isEmpty()) { %>
        <div class="alert alert-error">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span><%= request.getAttribute("loi") %></span>
        </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/dangky" method="post" onsubmit="return validatePassword()">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="role_id" value="3">

            <div class="form-row">
                <div>
                    <label class="field-label">Họ và tên</label>
                    <div class="field-wrap">
                        <input type="text" name="fullname" value="${not empty fullname ? fullname : param.fullname}" required placeholder="Nguyễn Văn A" class="input-field">
                        <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                    </div>
                </div>
                <div>
                    <label class="field-label">Số điện thoại</label>
                    <div class="field-wrap">
                        <input type="tel" name="phone" value="${not empty phone ? phone : param.phone}" required placeholder="0901234567" class="input-field">
                        <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/></svg>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label class="field-label">Tên đăng nhập</label>
                <div class="field-wrap">
                    <input type="text" name="username" id="username" value="${not empty username ? username : param.username}" required placeholder="vd: nguyen_van_a123" pattern="^[a-zA-Z0-9_]{3,30}$" title="Chỉ được dùng chữ không dấu, số và dấu _ , dài 3–30 ký tự" class="input-field" oninput="validateUsername(this)">
                    <span id="usernameError" class="error-inline"></span>
                    <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2"/></svg>
                </div>
            </div>

            <div class="form-group">
                <label class="field-label">Email</label>
                <div class="field-wrap">
                    <input type="email" name="email" value="${not empty email ? email : param.email}" required placeholder="email@example.com" class="input-field">
                    <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label class="field-label">Mật khẩu</label>
                    <div class="field-wrap">
                        <input type="password" name="password" id="password" required placeholder="8–16 ký tự" class="input-field" style="padding-right:40px;">
                        <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                        <button type="button" onclick="togglePassword('password', this)" class="toggle-pw">
                            <svg class="eye-show" width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                            <svg class="eye-hide hidden" width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/></svg>
                        </button>
                    </div>
                </div>
                <div>
                    <label class="field-label">Xác nhận</label>
                    <div class="field-wrap">
                        <input type="password" name="confirm_password" id="confirm_password" required placeholder="Nhập lại mật khẩu" class="input-field" style="padding-right:40px;">
                        <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
                        <button type="button" onclick="togglePassword('confirm_password', this)" class="toggle-pw">
                            <svg class="eye-show" width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                            <svg class="eye-hide hidden" width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/></svg>
                        </button>
                    </div>
                </div>
            </div>

            <span id="passwordError" class="error-inline"></span>

            <button type="submit" class="btn-primary">Đăng ký khách hàng</button>
        </form>

        <p class="form-footer">Đã có tài khoản? <a href="${pageContext.request.contextPath}/dangnhap">Đăng nhập ngay</a></p>

        <div class="role-divider">Đăng ký theo vai trò khác</div>
        <div class="role-btn-row">
            <a href="${pageContext.request.contextPath}/dangky-shop" class="role-btn">🏪 Chuỗi Shop</a>
            <a href="${pageContext.request.contextPath}/dangky-shipper" class="role-btn">🛵 Shipper</a>
        </div>
    </div>

    <!-- RIGHT: DECORATIVE -->
    <div class="deco-panel">
        <div class="deco-brand">
            <div class="deco-brand-badge">FM</div>
            <span class="deco-brand-label">Hệ thống đặt hàng trực tuyến</span>
        </div>

        <div class="deco-body">
            <h2 class="deco-headline">Tham gia FOOD MANAGE<br>ngay hôm nay,<br><span>hoàn toàn miễn phí.</span></h2>
            <p class="deco-desc">Chỉ mất 1 phút để tạo tài khoản, xác thực OTP và bắt đầu cuộc hành trình thưởng thức ẩm thực cùng POB.</p>
            <div class="step-list">
                <div class="step-item">
                    <div class="step-num">1</div>
                    <div>
                        <div class="step-title">Điền thông tin đăng ký</div>
                        <div class="step-desc">Nhập họ tên, SĐT, email chính xác để kích hoạt tài khoản</div>
                    </div>
                </div>
                <div class="step-item">
                    <div class="step-num">2</div>
                    <div>
                        <div class="step-title">Xác nhận email OTP</div>
                        <div class="step-desc">Mã xác minh 6 số bảo mật gửi về hòm thư của bạn</div>
                    </div>
                </div>
                <div class="step-item">
                    <div class="step-num">3</div>
                    <div>
                        <div class="step-title">Trải nghiệm dịch vụ</div>
                        <div class="step-desc">Đặt món trực tuyến và theo dõi shipper thực tế</div>
                    </div>
                </div>
            </div>
        </div>

        <p class="deco-footer">© 2026 FOOD MANAGE — All rights reserved</p>
    </div>

</div>

<script>
    function validateUsername(input) {
        var val = input.value;
        var err = document.getElementById("usernameError");
        if (!val) { err.textContent = ""; return; }
        if (/\s/.test(val)) {
            err.textContent = "⚠️ Tên đăng nhập không được chứa khoảng trắng!";
        } else if (/[^\x00-\x7F]/.test(val)) {
            err.textContent = "⚠️ Tên đăng nhập không được chứa ký tự có dấu!";
        } else if (!/^[a-zA-Z0-9_]+$/.test(val)) {
            err.textContent = "⚠️ Chỉ được dùng chữ không dấu, số và dấu gạch dưới (_)!";
        } else if (val.length < 3 || val.length > 30) {
            err.textContent = "⚠️ Tên đăng nhập phải dài 3–30 ký tự!";
        } else {
            err.textContent = "";
        }
    }

    function validatePassword() {
        var username = document.getElementById("username").value;
        var unErr    = document.getElementById("usernameError");
        if (!username || !/^[a-zA-Z0-9_]{3,30}$/.test(username)) {
            unErr.textContent = "⚠️ Tên đăng nhập chỉ được dùng chữ không dấu, số và dấu _ , dài 3–30 ký tự, không có khoảng trắng!";
            return false;
        }
        var password = document.getElementById("password").value.trim();
        var confirm  = document.getElementById("confirm_password").value.trim();
        var errorMsg = document.getElementById("passwordError");
        if (!password) { errorMsg.textContent = "⚠️ Mật khẩu không được để trống!"; return false; }
        if (password.length < 8 || password.length > 16) { errorMsg.textContent = "⚠️ Mật khẩu phải từ 8 đến 16 ký tự!"; return false; }
        if (password.includes(" ")) { errorMsg.textContent = "⚠️ Mật khẩu không được chứa khoảng trắng!"; return false; }
        if (password !== confirm) { errorMsg.textContent = "⚠️ Mật khẩu xác nhận không khớp!"; return false; }
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
</body>
</html>
