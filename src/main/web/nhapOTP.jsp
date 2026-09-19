<%@ page pageEncoding="utf-8"%>
<%
    String emailGui = null;
    if (session.getAttribute("email") != null) {
        emailGui = (String) session.getAttribute("email");
    } else if (session.getAttribute("forgotPasswordEmail") != null) {
        emailGui = (String) session.getAttribute("forgotPasswordEmail");
    }
    String emailAn = "";
    if (emailGui != null && !emailGui.isEmpty()) {
        int atIndex = emailGui.indexOf("@");
        if (atIndex > 3) {
            emailAn = emailGui.substring(0, 3) + "***" + emailGui.substring(atIndex);
        } else if (atIndex > 0) {
            emailAn = emailGui.substring(0, 1) + "***" + emailGui.substring(atIndex);
        } else {
            emailAn = emailGui;
        }
    }
    String loi  = (String) request.getAttribute("loi");
    boolean coLoi = (loi != null && !loi.isEmpty());
    boolean daGuiLai = "1".equals(request.getParameter("resent"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận OTP - FOOD MANAGE</title>
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

        .logo-wrap { display: flex; align-items: center; gap: 12px; margin-bottom: 28px; }
        .logo-badge { width: 40px; height: 40px; border-radius: 12px; background: linear-gradient(135deg, #FF3B1F, #E02A10); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 13px; box-shadow: 0 4px 12px rgba(99,44,20,0.3); }
        .logo-text-main { font-size: 11px; font-weight: 800; color: #FF3B1F; letter-spacing: 0.12em; text-transform: uppercase; display: block; }
        .logo-text-sub  { font-size: 9px; font-weight: 600; color: #8A7B6C; letter-spacing: 0.1em; text-transform: uppercase; display: block; margin-top: 2px; }

        .page-title { font-size: 26px; font-weight: 800; color: #2D2421; letter-spacing: -0.02em; margin-bottom: 6px; }
        .page-sub   { font-size: 13px; color: #8A7B6C; margin-bottom: 20px; }

        .alert { display: flex; align-items: center; gap: 10px; border-radius: 12px; padding: 12px 16px; font-size: 13px; font-weight: 500; margin-bottom: 16px; }
        .alert-error   { background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; }
        .alert-success { background: #FFF2F0; border: 1px solid #bbf7d0; color: #16a34a; }
        .alert-info    { background: #eff6ff; border: 1px solid #bfdbfe; color: #2563eb; }
        .alert svg { flex-shrink: 0; }

        /* OTP inputs */
        .otp-row { display: flex; justify-content: center; gap: 10px; margin-bottom: 24px; }
        .otp-input {
            width: 50px; height: 60px;
            border: 1.5px solid #F1E4D6; border-radius: 14px;
            font-size: 24px; font-weight: 800; text-align: center;
            color: #2D2421; background: #FFF4EC; font-family: inherit;
            outline: none; transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
            -moz-appearance: textfield;
        }
        .otp-input::-webkit-inner-spin-button,
        .otp-input::-webkit-outer-spin-button { -webkit-appearance: none; margin: 0; }
        .otp-input:focus { border-color: #FF3B1F; background: #fff; box-shadow: 0 0 0 4px rgba(255,59,31,0.12); }
        .otp-input.error { border-color: #ef4444; background: #fef2f2; box-shadow: 0 0 0 3px rgba(239,68,68,0.1); }

        .btn-primary { width: 100%; background: linear-gradient(135deg, #FF3B1F, #E02A10); color: #fff; font-weight: 700; font-size: 14px; padding: 14px; border-radius: 12px; border: none; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 16px rgba(255,59,31,0.35); font-family: inherit; }
        .btn-primary:hover { transform: translateY(-1.5px); box-shadow: 0 6px 22px rgba(255,59,31,0.45); }
        .btn-primary:active { transform: translateY(0); }

        .resend-wrap { text-align: center; margin-top: 16px; }
        .resend-btn { background: none; border: none; font-size: 12.5px; font-weight: 700; color: #2D2421; cursor: pointer; font-family: inherit; transition: color 0.2s; }
        .resend-btn:hover { color: #FF3B1F; text-decoration: underline; }
        .resend-btn:disabled { opacity: 0.4; cursor: not-allowed; text-decoration: none; }

        .back-link-wrap { text-align: center; margin-top: 20px; padding-top: 18px; border-top: 1px solid #F7EBDD; }
        .back-link { font-size: 12px; font-weight: 700; color: #FF3B1F; text-decoration: none; }
        .back-link:hover { color: #E02A10; }

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

        /* RIGHT */
        .deco-panel { flex: 1; background: linear-gradient(155deg, #3A1206 0%, #1A0A04 100%); padding: 48px 44px; display: flex; flex-direction: column; justify-content: space-between; position: relative; overflow: hidden; }
        .deco-panel::before { content: ''; position: absolute; top: -80px; right: -80px; width: 320px; height: 320px; border-radius: 50%; background: radial-gradient(circle, rgba(255,59,31,0.12) 0%, transparent 70%); pointer-events: none; }
        .deco-panel::after  { content: ''; position: absolute; bottom: -60px; left: -60px; width: 240px; height: 240px; border-radius: 50%; background: radial-gradient(circle, rgba(255,179,0,0.08) 0%, transparent 70%); pointer-events: none; }

        .deco-brand { display: flex; align-items: center; gap: 10px; position: relative; z-index: 1; }
        .deco-brand-badge { width: 36px; height: 36px; border-radius: 10px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.12); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 12px; }
        .deco-brand-label { font-size: 12px; color: rgba(255,255,255,0.35); font-weight: 600; letter-spacing: 0.05em; }

        .deco-body { position: relative; z-index: 1; }
        .deco-headline { font-size: 32px; font-weight: 800; color: #fff; line-height: 1.25; letter-spacing: -0.02em; margin-bottom: 14px; }
        .deco-headline span { color: #FFB300; }
        .deco-desc { font-size: 13px; color: rgba(255,255,255,0.42); line-height: 1.7; margin-bottom: 28px; max-width: 320px; }

        .info-list { display: flex; flex-direction: column; }
        .info-item { display: flex; align-items: flex-start; gap: 14px; padding: 16px 0; border-bottom: 1px solid rgba(255,255,255,0.07); }
        .info-item:last-child { border-bottom: none; }
        .info-icon { width: 38px; height: 38px; border-radius: 10px; background: rgba(255,255,255,0.07); display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
        .info-title { font-size: 13.5px; font-weight: 700; color: #fff; margin-bottom: 3px; }
        .info-desc  { font-size: 11.5px; color: rgba(255,255,255,0.38); line-height: 1.5; }
        .deco-footer { font-size: 11px; color: rgba(255,255,255,0.2); position: relative; z-index: 1; }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(24px) scale(0.98); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }
        @keyframes shake {
            0%,100%{transform:translateX(0)} 20%{transform:translateX(-6px)}
            40%{transform:translateX(6px)}   60%{transform:translateX(-4px)}
            80%{transform:translateX(4px)}
        }
        .shake { animation: shake 0.4s ease-out; }

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

        <h1 class="page-title">Xác nhận OTP</h1>
        <p class="page-sub">Nhập mã 6 số đã được gửi đến email của bạn.</p>

        <% if (!emailAn.isEmpty()) { %>
        <div class="alert alert-success">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
            <span>Mã OTP đã gửi đến <strong><%= emailAn %></strong></span>
        </div>
        <% } %>

        <% if (daGuiLai) { %>
        <div class="alert alert-info">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span>Mã OTP mới đã được gửi lại vào email của bạn.</span>
        </div>
        <% } %>

        <% if (coLoi) { %>
        <div class="alert alert-error shake" id="errorBox">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span><%= loi %></span>
        </div>
        <% } %>

        <div class="otp-timer-wrap" id="otpTimerWrap">
            <div class="otp-timer-bar"><div class="otp-timer-bar-fill" id="otpTimerBarFill"></div></div>
            <div class="otp-timer-text">⏳ Mã OTP còn hiệu lực: <span class="timer-digits" id="otpTimerDigits">--:--</span></div>
        </div>
        <div class="otp-expired-msg" id="otpExpiredMsg">⚠️ Mã OTP đã hết hạn! Vui lòng bấm "Gửi lại OTP" để nhận mã mới.</div>

        <form action="${pageContext.request.contextPath}/xacnhanotp" method="post" id="otpForm">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <div class="otp-row">
                <input type="number" name="otp1" min="0" max="9" required class="otp-input <%= coLoi ? "error" : "" %>">
                <input type="number" name="otp2" min="0" max="9" required class="otp-input <%= coLoi ? "error" : "" %>">
                <input type="number" name="otp3" min="0" max="9" required class="otp-input <%= coLoi ? "error" : "" %>">
                <input type="number" name="otp4" min="0" max="9" required class="otp-input <%= coLoi ? "error" : "" %>">
                <input type="number" name="otp5" min="0" max="9" required class="otp-input <%= coLoi ? "error" : "" %>">
                <input type="number" name="otp6" min="0" max="9" required class="otp-input <%= coLoi ? "error" : "" %>">
            </div>
            <button type="submit" class="btn-primary">Xác nhận</button>
        </form>

        <div class="resend-wrap">
            <form action="${pageContext.request.contextPath}/xacnhanotp" method="post" style="display:inline;">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="resend">
                <button type="submit" id="btnResend" class="resend-btn" <%= daGuiLai ? "disabled" : "" %>>
                    🔄 Gửi lại OTP<span id="countdownText"></span>
                </button>
            </form>
        </div>

        <div class="back-link-wrap">
            <a href="${pageContext.request.contextPath}/dangky" class="back-link">← Quay lại đăng ký</a>
        </div>
    </div>

    <!-- RIGHT: DECORATIVE -->
    <div class="deco-panel">
        <div class="deco-brand">
            <div class="deco-brand-badge">FM</div>
            <span class="deco-brand-label">Hệ thống đặt hàng trực tuyến</span>
        </div>

        <div class="deco-body">
            <h2 class="deco-headline">Bảo mật tài khoản<br>bằng xác thực<br><span>hai bước.</span></h2>
            <p class="deco-desc">Mã OTP giúp đảm bảo chỉ bạn mới có thể tạo tài khoản với email này trên FOOD MANAGE.</p>
            <div class="info-list">
                <div class="info-item">
                    <div class="info-icon">📧</div>
                    <div>
                        <div class="info-title">Kiểm tra email</div>
                        <div class="info-desc">Mã OTP 6 số đã được gửi vào hộp thư của bạn</div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon">⏱️</div>
                    <div>
                        <div class="info-title">Có hiệu lực 5 phút</div>
                        <div class="info-desc">Nhập mã trước khi hết thời gian hiệu lực</div>
                    </div>
                </div>
                <div class="info-item">
                    <div class="info-icon">🔒</div>
                    <div>
                        <div class="info-title">Không chia sẻ mã</div>
                        <div class="info-desc">POB sẽ không bao giờ hỏi mã OTP của bạn</div>
                    </div>
                </div>
            </div>
        </div>

        <p class="deco-footer">© 2026 FOOD MANAGE — All rights reserved</p>
    </div>

</div>

<script>
    const inputs = document.querySelectorAll('.otp-input');
    inputs.forEach((input, index) => {
        input.addEventListener('focus', function() { this.classList.remove('error'); this.select(); });
        input.addEventListener('input', function() {
            if (this.value.length > 1) this.value = this.value.slice(0, 1);
            if (this.value !== '' && index < inputs.length - 1) inputs[index + 1].focus();
        });
        input.addEventListener('keydown', function(e) {
            if (e.key === 'Backspace' && this.value === '' && index > 0) inputs[index - 1].focus();
        });
        input.addEventListener('paste', function(e) {
            e.preventDefault();
            var pasted = (e.clipboardData || window.clipboardData).getData('text');
            var digits = pasted.replace(/\D/g, '').slice(0, inputs.length - index);
            if (!digits) return;
            var lastFilled = index;
            digits.split('').forEach(function(digit, i) {
                if (index + i < inputs.length) {
                    inputs[index + i].value = digit;
                    lastFilled = index + i;
                }
            });
            inputs[Math.min(lastFilled + 1, inputs.length - 1)].focus();
        });
    });
    if (inputs.length > 0) inputs[0].focus();

    const btnResend = document.getElementById('btnResend');
    const countdownText = document.getElementById('countdownText');
    const justResent = <%= daGuiLai %>;

    function startCountdown(seconds) {
        btnResend.disabled = true;
        let remaining = seconds;
        countdownText.textContent = ' (' + remaining + 's)';
        const timer = setInterval(() => {
            remaining--;
            if (remaining <= 0) {
                clearInterval(timer);
                btnResend.disabled = false;
                countdownText.textContent = '';
            } else {
                countdownText.textContent = ' (' + remaining + 's)';
            }
        }, 1000);
    }
    if (justResent) startCountdown(60);

    /* ── OTP EXPIRY COUNTDOWN ── */
    (function () {
        var OTP_TOTAL_SECONDS = 5 * 60;
        var expiredAtMs = <%= session.getAttribute("otpExpiredAt") != null ? session.getAttribute("otpExpiredAt") : "0" %>;
        if (!expiredAtMs || expiredAtMs <= 0) return;

        var timerWrap = document.getElementById('otpTimerWrap');
        var barFill = document.getElementById('otpTimerBarFill');
        var digits = document.getElementById('otpTimerDigits');
        var expiredMsg = document.getElementById('otpExpiredMsg');
        var submitBtn = document.querySelector('#otpForm .btn-primary');

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
                if (submitBtn) submitBtn.disabled = true;
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
