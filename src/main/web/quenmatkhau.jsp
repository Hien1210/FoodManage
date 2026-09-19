<%@ page pageEncoding="utf-8"%>
<%
    boolean resetStep = "reset".equals(request.getAttribute("step"));
    String loi      = (String) request.getAttribute("loi");
    String thongbao = (String) request.getAttribute("thongbao");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= resetStep ? "Đặt lại mật khẩu" : "Quên mật khẩu" %> - FOOD MANAGE</title>
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
            max-width: 940px;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(99,44,20,0.12);
            animation: fadeInUp 0.4s cubic-bezier(0.16,1,0.3,1);
        }

        /* LEFT */
        .form-panel { flex: 0 0 44%; background: #ffffff; padding: 48px 44px; display: flex; flex-direction: column; justify-content: center; }

        .logo-wrap { display: flex; align-items: center; gap: 12px; margin-bottom: 32px; }
        .logo-badge { width: 40px; height: 40px; border-radius: 12px; background: linear-gradient(135deg, #FF3B1F, #E02A10); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 13px; box-shadow: 0 4px 12px rgba(99,44,20,0.3); }
        .logo-text-main { font-size: 11px; font-weight: 800; color: #FF3B1F; letter-spacing: 0.12em; text-transform: uppercase; display: block; }
        .logo-text-sub  { font-size: 9px; font-weight: 600; color: #8A7B6C; letter-spacing: 0.1em; text-transform: uppercase; display: block; margin-top: 2px; }

        .page-title { font-size: 26px; font-weight: 800; color: #2D2421; letter-spacing: -0.02em; margin-bottom: 6px; }
        .page-sub   { font-size: 13px; color: #8A7B6C; margin-bottom: 24px; }

        .alert { display: flex; align-items: center; gap: 10px; border-radius: 12px; padding: 12px 16px; font-size: 13px; font-weight: 500; margin-bottom: 18px; }
        .alert-error   { background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; }
        .alert-success { background: #FFF2F0; border: 1px solid #bbf7d0; color: #16a34a; }
        .alert svg { flex-shrink: 0; }

        .form-group { margin-bottom: 16px; }
        .field-label { display: block; font-size: 11px; font-weight: 700; color: #4A3934; text-transform: uppercase; letter-spacing: 0.06em; margin-bottom: 6px; }
        .field-wrap  { position: relative; }
        .field-icon-left { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #C9B8A8; pointer-events: none; }
        .input-field {
            width: 100%; background: #FFF4EC; border: 1.5px solid #F1E4D6;
            border-radius: 12px; padding: 12px 14px 12px 42px;
            font-size: 14px; color: #2D2421; font-weight: 500; font-family: inherit;
            outline: none; transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
        }
        .input-field:focus { border-color: #FF3B1F; background: #fff; box-shadow: 0 0 0 4px rgba(255,59,31,0.12); }
        .input-field::placeholder { color: #C9B8A8; font-weight: 400; font-size: 13px; }
        input:-webkit-autofill { -webkit-box-shadow: 0 0 0 30px #FFF4EC inset !important; }

        .otp-single {
            width: 100%; background: #FFF4EC; border: 1.5px solid #F1E4D6;
            border-radius: 12px; padding: 14px; font-size: 26px; font-weight: 800;
            letter-spacing: 14px; text-align: center; color: #2D2421; font-family: inherit;
            outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        }
        .otp-single:focus { border-color: #FF3B1F; background: #fff; box-shadow: 0 0 0 4px rgba(255,59,31,0.12); }

        .toggle-pw { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; color: #C9B8A8; padding: 4px; transition: color 0.2s; display: flex; align-items: center; }
        .toggle-pw:hover { color: #FF3B1F; }
        .hidden { display: none !important; }
        .error-inline { color: #dc2626; font-size: 11.5px; font-weight: 500; margin-top: 4px; display: block; }

        .btn-primary { width: 100%; background: linear-gradient(135deg, #FF3B1F, #E02A10); color: #fff; font-weight: 700; font-size: 14px; padding: 14px; border-radius: 12px; border: none; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 16px rgba(255,59,31,0.35); font-family: inherit; margin-top: 4px; }
        .btn-primary:hover { transform: translateY(-1.5px); box-shadow: 0 6px 22px rgba(255,59,31,0.45); }
        .btn-primary:active { transform: translateY(0); }

        .back-link-wrap { text-align: center; margin-top: 24px; padding-top: 20px; border-top: 1px solid #F7EBDD; }
        .back-link { font-size: 12px; font-weight: 700; color: #FF3B1F; text-decoration: none; }
        .back-link:hover { color: #E02A10; }

        /* RIGHT */
        .deco-panel { flex: 1; background: linear-gradient(155deg, #3A1206 0%, #1A0A04 100%); padding: 48px 44px; display: flex; flex-direction: column; justify-content: space-between; position: relative; overflow: hidden; }
        .deco-panel::before { content: ''; position: absolute; top: -80px; right: -80px; width: 320px; height: 320px; border-radius: 50%; background: radial-gradient(circle, rgba(255,59,31,0.12) 0%, transparent 70%); pointer-events: none; }
        .deco-panel::after  { content: ''; position: absolute; bottom: -60px; left: -60px; width: 240px; height: 240px; border-radius: 50%; background: radial-gradient(circle, rgba(255,179,0,0.08) 0%, transparent 70%); pointer-events: none; }

        .deco-brand { display: flex; align-items: center; gap: 10px; position: relative; z-index: 1; }
        .deco-brand-badge { width: 36px; height: 36px; border-radius: 10px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.12); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 12px; }
        .deco-brand-label { font-size: 12px; color: rgba(255,255,255,0.35); font-weight: 600; letter-spacing: 0.05em; }

        .deco-body { position: relative; z-index: 1; }
        .deco-headline { font-size: 29px; font-weight: 800; color: #fff; line-height: 1.3; letter-spacing: -0.02em; margin-bottom: 14px; }
        .deco-headline span { color: #FFB300; }
        .deco-desc { font-size: 13px; color: rgba(255,255,255,0.42); line-height: 1.7; margin-bottom: 28px; max-width: 320px; }

        .info-list { display: flex; flex-direction: column; gap: 10px; }
        .info-item { display: flex; align-items: flex-start; gap: 14px; padding: 14px 16px; border-radius: 14px; background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.06); transition: background 0.2s, transform 0.2s; }
        .info-item:hover { background: rgba(255,255,255,0.07); transform: translateX(4px); }
        .info-icon { width: 38px; height: 38px; border-radius: 10px; background: rgba(255,255,255,0.07); display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
        .info-title { font-size: 13.5px; font-weight: 700; color: #fff; margin-bottom: 3px; }
        .info-desc  { font-size: 11.5px; color: rgba(255,255,255,0.38); line-height: 1.5; }
        .deco-footer { font-size: 11px; color: rgba(255,255,255,0.2); position: relative; z-index: 1; }

        /* OTP Countdown Timer */
        .otp-timer-wrap { margin-bottom: 20px; text-align: center; }
        .otp-timer-bar { height: 5px; background: #F1E4D6; border-radius: 99px; overflow: hidden; margin-bottom: 10px; }
        .otp-timer-bar-fill { height: 100%; background: linear-gradient(90deg, #FF3B1F, #E02A10); border-radius: 99px; transition: width 1s linear; }
        .otp-timer-bar-fill.danger { background: linear-gradient(90deg, #ef4444, #dc2626); }
        .otp-timer-text { font-size: 13px; font-weight: 700; color: #635752; display: flex; align-items: center; justify-content: center; gap: 6px; }
        .otp-timer-text .timer-digits { font-size: 18px; font-weight: 800; color: #2D2421; font-family: 'Courier New', monospace; letter-spacing: 1px; }
        .otp-timer-text .timer-digits.danger { color: #ef4444; animation: blink-red 1s ease-in-out infinite; }
        @keyframes blink-red { 0%,100%{opacity:1} 50%{opacity:0.5} }
        .otp-expired-msg { display: none; background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; border-radius: 12px; padding: 14px 16px; font-size: 13px; font-weight: 600; text-align: center; margin-bottom: 16px; }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(24px) scale(0.98); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }
        @media (max-width: 720px) {
            .auth-card { flex-direction: column; }
            .deco-panel { display: none; }
            .form-panel { flex: none; width: 100%; padding: 36px 24px; }
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

        <% if (!resetStep) { %>
        <h1 class="page-title">Quên mật khẩu</h1>
        <p class="page-sub">Nhập email để nhận mã OTP đặt lại mật khẩu.</p>
        <% } else { %>
        <h1 class="page-title">Đặt lại mật khẩu</h1>
        <p class="page-sub">Nhập mã OTP và mật khẩu mới của bạn.</p>
        <% } %>

        <% if (loi != null && !loi.trim().isEmpty()) { %>
        <div class="alert alert-error">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span><%= loi %></span>
        </div>
        <% } %>
        <% if (thongbao != null && !thongbao.trim().isEmpty()) { %>
        <div class="alert alert-success">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span><%= thongbao %></span>
        </div>
        <% } %>

        <% if (!resetStep) { %>
        <form action="${pageContext.request.contextPath}/quenmatkhau" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="sendOtp">
            <div class="form-group">
                <label class="field-label">Email đã đăng ký</label>
                <div class="field-wrap">
                    <input type="email" name="email" required placeholder="email@example.com" class="input-field">
                    <svg class="field-icon-left" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
                </div>
            </div>
            <button type="submit" class="btn-primary">Gửi mã OTP</button>
        </form>

        <% } else { %>

        <div class="otp-timer-wrap" id="otpTimerWrap">
            <div class="otp-timer-bar"><div class="otp-timer-bar-fill" id="otpTimerBarFill"></div></div>
            <div class="otp-timer-text">⏳ Mã OTP còn hiệu lực: <span class="timer-digits" id="otpTimerDigits">--:--</span></div>
        </div>
        <div class="otp-expired-msg" id="otpExpiredMsg">⚠️ Mã OTP đã hết hạn! Vui lòng quay lại và gửi OTP mới.</div>

        <form action="${pageContext.request.contextPath}/quenmatkhau" method="post" onsubmit="return validateResetPassword()" id="otpResetForm">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="reset">

            <div class="form-group">
                <label class="field-label">Mã OTP (6 chữ số)</label>
                <input type="text" name="otp" maxlength="6" pattern="[0-9]{6}" inputmode="numeric" required placeholder="••••••" class="otp-single">
            </div>

            <div class="form-group">
                <label class="field-label">Mật khẩu mới</label>
                <div class="field-wrap">
                    <input type="password" id="newPassword" name="password" placeholder="8–16 ký tự" required class="input-field" style="padding-right:42px;">
                    <svg class="field-icon-left" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                    <button type="button" onclick="togglePassword('newPassword', this)" class="toggle-pw">
                        <svg class="eye-show" width="17" height="17" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                        <svg class="eye-hide hidden" width="17" height="17" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/></svg>
                    </button>
                </div>
            </div>

            <div class="form-group">
                <label class="field-label">Xác nhận mật khẩu mới</label>
                <div class="field-wrap">
                    <input type="password" id="confirmPassword" name="confirm_password" placeholder="Nhập lại mật khẩu" required class="input-field" style="padding-right:42px;">
                    <svg class="field-icon-left" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
                    <button type="button" onclick="togglePassword('confirmPassword', this)" class="toggle-pw">
                        <svg class="eye-show" width="17" height="17" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                        <svg class="eye-hide hidden" width="17" height="17" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/></svg>
                    </button>
                </div>
            </div>

            <span id="resetPasswordError" class="error-inline"></span>
            <button type="submit" class="btn-primary">Đặt lại mật khẩu</button>
        </form>
        <% } %>

        <div class="back-link-wrap">
            <a href="${pageContext.request.contextPath}/dangnhap" class="back-link">← Quay lại đăng nhập</a>
        </div>
    </div>

    <!-- RIGHT: DECORATIVE -->
    <div class="deco-panel">
        <div class="deco-brand">
            <div class="deco-brand-badge">FM</div>
            <span class="deco-brand-label">Hệ thống đặt hàng trực tuyến</span>
        </div>

        <div class="deco-body">
            <% if (!resetStep) { %>
            <h2 class="deco-headline">Quên mật khẩu?<br>Đừng lo lắng,<br><span>chúng tôi giúp bạn.</span></h2>
            <p class="deco-desc">Chỉ cần cung cấp email đã tạo tài khoản, chúng tôi sẽ gửi ngay mã OTP 6 số để xác thực danh tính.</p>
            <% } else { %>
            <h2 class="deco-headline">Tạo mật khẩu<br>mới an toàn<br><span>cho tài khoản.</span></h2>
            <p class="deco-desc">Nhập mã OTP đã nhận qua email và mật khẩu mới có độ bảo mật cao để kích hoạt lại tài khoản.</p>
            <% } %>
            <div class="info-list">
                <div class="info-item">
                    <div class="info-icon">📧</div>
                    <div>
                        <div class="info-title">Kiểm tra hòm thư</div>
                        <div class="info-desc">Kiểm tra hộp thư đến hoặc thư rác để lấy mã OTP 6 số</div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon">🔐</div>
                    <div>
                        <div class="info-title">Xác minh bảo mật</div>
                        <div class="info-desc">Nhập mã OTP để xác nhận bạn là chủ sở hữu hợp pháp</div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon">✨</div>
                    <div>
                        <div class="info-title">Phục hồi thành công</div>
                        <div class="info-desc">Đặt mật khẩu mới và tiếp tục đặt món ngon trên FOOD MANAGE</div>
                    </div>
                </div>
            </div>
        </div>

        <p class="deco-footer">© 2026 FOOD MANAGE — All rights reserved</p>
    </div>

</div>

<script>
    function validateResetPassword() {
        var password = document.getElementById("newPassword").value.trim();
        var confirm  = document.getElementById("confirmPassword").value.trim();
        var errorMsg = document.getElementById("resetPasswordError");
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

    /* ── OTP EXPIRY COUNTDOWN (Quên mật khẩu) ── */
    (function () {
        var OTP_TOTAL_SECONDS = 5 * 60;
        var expiredAtMs = <%= session.getAttribute("forgotPasswordOtpExpiredAt") != null ? session.getAttribute("forgotPasswordOtpExpiredAt") : "0" %>;
        if (!expiredAtMs || expiredAtMs <= 0) return;

        var timerWrap  = document.getElementById('otpTimerWrap');
        var barFill    = document.getElementById('otpTimerBarFill');
        var digits     = document.getElementById('otpTimerDigits');
        var expiredMsg = document.getElementById('otpExpiredMsg');
        var resetForm  = document.getElementById('otpResetForm');
        if (!timerWrap) return;

        function tick() {
            var now = Date.now();
            var remainMs = expiredAtMs - now;
            if (remainMs <= 0) {
                barFill.style.width = '0%';
                digits.textContent = '00:00';
                digits.classList.add('danger');
                barFill.classList.add('danger');
                timerWrap.style.display = 'none';
                expiredMsg.style.display = 'block';
                if (resetForm) {
                    var submitBtns = resetForm.querySelectorAll('button[type="submit"]');
                    submitBtns.forEach(function(btn) { btn.disabled = true; });
                }
                return;
            }
            var totalSec = Math.ceil(remainMs / 1000);
            var mins = Math.floor(totalSec / 60);
            var secs = totalSec % 60;
            digits.textContent = (mins < 10 ? '0' : '') + mins + ':' + (secs < 10 ? '0' : '') + secs;
            var pct = Math.max(0, (totalSec / OTP_TOTAL_SECONDS) * 100);
            barFill.style.width = pct + '%';
            if (totalSec <= 60) {
                digits.classList.add('danger');
                barFill.classList.add('danger');
            } else {
                digits.classList.remove('danger');
                barFill.classList.remove('danger');
            }
            setTimeout(tick, 1000);
        }
        tick();
    })();
</script>
</body>
</html>
