<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký Shop - FOOD MANAGE</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <style>
        .logo-text-main, .page-title, .deco-headline, .logo-badge, .step-num { font-family: 'Quicksand', 'Plus Jakarta Sans', sans-serif; }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #F7EBDD;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        .auth-card {
            display: flex;
            width: 100%;
            max-width: 1080px;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(99,44,20,0.12);
            animation: fadeInUp 0.4s cubic-bezier(0.16,1,0.3,1);
        }

        /* LEFT */
        .form-panel {
            flex: 0 0 54%;
            background: #ffffff;
            padding: 36px 44px;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            max-height: 95vh;
        }
        .form-panel::-webkit-scrollbar { width: 5px; }
        .form-panel::-webkit-scrollbar-thumb { background: #D9C9BA; border-radius: 10px; }

        .logo-wrap { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; }
        .logo-badge { width: 40px; height: 40px; border-radius: 12px; background: linear-gradient(135deg, #FF3B1F, #E02A10); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 13px; box-shadow: 0 4px 12px rgba(255,59,31,0.3); }
        .logo-text-main { font-size: 11px; font-weight: 800; color: #FF3B1F; letter-spacing: 0.12em; text-transform: uppercase; display: block; }
        .logo-text-sub  { font-size: 9px; font-weight: 600; color: #8A7B6C; letter-spacing: 0.1em; text-transform: uppercase; display: block; margin-top: 2px; }

        .page-title { font-size: 22px; font-weight: 800; color: #2D2421; letter-spacing: -0.02em; margin-bottom: 4px; }
        .page-sub   { font-size: 13px; color: #8A7B6C; margin-bottom: 18px; }

        .section-label {
            font-size: 11px; font-weight: 800; color: #FF3B1F; text-transform: uppercase;
            letter-spacing: 0.08em; padding: 8px 12px; background: #FFF2F0;
            border-radius: 8px; border-left: 3px solid #FF3B1F; margin: 16px 0 12px;
        }

        .alert { display: flex; align-items: center; gap: 10px; border-radius: 12px; padding: 12px 16px; font-size: 13px; font-weight: 500; margin-bottom: 14px; }
        .alert-error   { background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; }
        .alert-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534; }

        .form-group { margin-bottom: 12px; }
        .form-row   { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 12px; }
        .field-label { display: block; font-size: 11px; font-weight: 700; color: #4A3934; text-transform: uppercase; letter-spacing: 0.06em; margin-bottom: 5px; }
        .field-wrap { position: relative; }
        .field-icon-left { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #C9B8A8; pointer-events: none; transition: color 0.2s; }
        .input-field {
            width: 100%; background: #FFF4EC; border: 1.5px solid #F1E4D6;
            border-radius: 12px; padding: 11px 14px 11px 42px;
            font-size: 13.5px; color: #2D2421; font-weight: 500; font-family: inherit;
            outline: none; transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
        }
        textarea.input-field { padding-top: 11px; padding-bottom: 11px; min-height: 72px; resize: vertical; }
        .input-field:focus { border-color: #FF3B1F; background: #fff; box-shadow: 0 0 0 4px rgba(255,59,31,0.12); }
        .input-field::placeholder { color: #C9B8A8; font-weight: 400; font-size: 12.5px; }
        .field-wrap:focus-within .field-icon-left { color: #FF3B1F; }

        .toggle-pw { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; color: #C9B8A8; padding: 4px; transition: color 0.2s; display: flex; align-items: center; }
        .toggle-pw:hover { color: #FF3B1F; }
        .hidden { display: none !important; }

        .btn-primary { width: 100%; display: flex; align-items: center; justify-content: center; gap: 8px; background: linear-gradient(135deg, #FF3B1F, #E02A10); color: #fff; font-weight: 700; font-size: 14px; padding: 13px; border-radius: 12px; border: none; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 16px rgba(255,59,31,0.35); font-family: inherit; margin-top: 6px; }
        .btn-primary:hover { transform: translateY(-1.5px); box-shadow: 0 6px 22px rgba(255,59,31,0.45); }
        .btn-primary:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }

        .form-footer { text-align: center; font-size: 13px; color: #8A7B6C; margin-top: 12px; }
        .form-footer a { color: #FF3B1F; font-weight: 700; text-decoration: none; }
        .form-footer a:hover { color: #E02A10; }

        .role-divider { text-align: center; font-size: 10.5px; font-weight: 700; color: #D9C9BA; text-transform: uppercase; letter-spacing: 0.08em; margin: 14px 0 10px; }
        .role-btn-row { display: flex; gap: 10px; }
        .role-btn {
            flex: 1; display: flex; align-items: center; justify-content: center; gap: 6px;
            border: 1.5px solid #F1E4D6; border-radius: 12px;
            padding: 10px 8px; font-size: 12.5px; font-weight: 700; color: #4A3934;
            background: #FFF4EC; text-decoration: none; transition: all 0.2s;
        }
        .role-btn:hover { border-color: #FF3B1F; color: #FF3B1F; background: #FFF2F0; transform: translateY(-1px); }

        /* OTP Section */
        #otpSection { display: none; }
        #otpSection.visible { display: block; }

        .otp-header { text-align: center; margin-bottom: 20px; }
        .otp-header h3 { font-size: 18px; font-weight: 800; color: #2D2421; margin-bottom: 6px; }
        .otp-header p { font-size: 13px; color: #635752; line-height: 1.6; }
        .otp-header .email-badge { display: inline-block; background: #FFF2F0; border: 1px solid #6ee7b7; color: #FF3B1F; font-weight: 700; padding: 4px 12px; border-radius: 20px; font-size: 13px; margin-top: 6px; }

        .otp-inputs { display: flex; gap: 10px; justify-content: center; margin: 20px 0; }
        .otp-box {
            width: 48px; height: 56px; text-align: center; font-size: 22px; font-weight: 800;
            border: 2px solid #F1E4D6; border-radius: 12px; background: #FFF4EC;
            color: #2D2421; outline: none; font-family: 'Courier New', monospace;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .otp-box:focus { border-color: #FF3B1F; box-shadow: 0 0 0 4px rgba(255,59,31,0.12); background: #fff; }

        .otp-timer { text-align: center; font-size: 12px; color: #8A7B6C; margin-bottom: 12px; }
        .otp-timer span { font-weight: 700; color: #dc2626; }
        .otp-resend { text-align: center; margin-bottom: 16px; }
        .btn-ghost { background: none; border: none; color: #FF3B1F; font-weight: 700; font-size: 13px; cursor: pointer; padding: 4px 8px; border-radius: 8px; transition: background 0.2s; font-family: inherit; }
        .btn-ghost:hover { background: #FFF2F0; }
        .btn-ghost:disabled { color: #8A7B6C; cursor: not-allowed; }
        .btn-back { background: none; border: 1.5px solid #F1E4D6; color: #635752; font-weight: 600; font-size: 13px; cursor: pointer; padding: 10px 20px; border-radius: 10px; font-family: inherit; transition: all 0.2s; margin-right: 8px; }
        .btn-back:hover { border-color: #8A7B6C; color: #2D2421; }

        .btn-row { display: flex; margin-top: 8px; }
        .btn-row .btn-primary { flex: 1; }

        /* RIGHT */
        .deco-panel {
            flex: 1;
            background: linear-gradient(155deg, #3A1206 0%, #1A0A04 100%);
            background-image: radial-gradient(circle, rgba(255,255,255,0.05) 1px, transparent 1px), linear-gradient(155deg, #3A1206 0%, #1A0A04 100%);
            background-size: 20px 20px, 100% 100%;
            padding: 48px 40px;
            display: flex; flex-direction: column; justify-content: space-between;
            position: relative; overflow: hidden;
        }
        .deco-panel::before { content: ''; position: absolute; top: -80px; right: -80px; width: 320px; height: 320px; border-radius: 50%; background: radial-gradient(circle, rgba(255,59,31,0.26) 0%, transparent 70%); pointer-events: none; }
        .deco-panel::after  { content: ''; position: absolute; bottom: -60px; left: -60px; width: 240px; height: 240px; border-radius: 50%; background: radial-gradient(circle, rgba(255,179,0,0.14) 0%, transparent 70%); pointer-events: none; }

        .stats-row { display: flex; gap: 10px; position: relative; z-index: 1; margin-bottom: 22px; }
        .stat-item { flex: 1; text-align: center; padding: 12px 6px; border-radius: 12px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.08); }
        .stat-value { font-size: 17px; font-weight: 800; color: #FFB300; }
        .stat-label { font-size: 10px; color: rgba(255,255,255,0.4); font-weight: 600; margin-top: 2px; }

        .deco-brand { display: flex; align-items: center; gap: 10px; position: relative; z-index: 1; }
        .deco-brand-badge { width: 36px; height: 36px; border-radius: 10px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.12); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 12px; }
        .deco-brand-label { font-size: 12px; color: rgba(255,255,255,0.35); font-weight: 600; }

        .deco-body { position: relative; z-index: 1; }
        .deco-headline { font-size: 27px; font-weight: 800; color: #fff; line-height: 1.3; letter-spacing: -0.02em; margin-bottom: 12px; }
        .deco-headline span { color: #FFB300; }
        .deco-desc { font-size: 13px; color: rgba(255,255,255,0.42); line-height: 1.7; margin-bottom: 24px; }

        .step-list { display: flex; flex-direction: column; gap: 10px; }
        .step-item { display: flex; align-items: flex-start; gap: 14px; padding: 14px 16px; border-radius: 14px; background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.06); position: relative; }
        .step-item:not(:last-child)::after { content: ''; position: absolute; left: 32px; top: 46px; width: 1px; height: 18px; background: rgba(255,255,255,0.12); }
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
            .form-panel { flex: none; width: 100%; max-height: none; padding: 28px 20px; }
            .form-row { grid-template-columns: 1fr; }
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
                <span class="logo-text-sub">Đối tác Shop</span>
            </div>
        </div>

        <!-- BƯỚC 1: Form đăng ký -->
        <div id="registerSection">
            <h1 class="page-title">Mở tài khoản Shop 🏪</h1>
            <p class="page-sub">Điền đầy đủ thông tin để đăng ký kinh doanh cùng FOOD MANAGE</p>

            <div id="alertBox" class="alert alert-error hidden"></div>

            <!-- Thông tin tài khoản -->
            <div class="section-label">👤 Thông tin tài khoản</div>

            <div class="form-row">
                <div>
                    <label class="field-label">Họ tên chủ shop <span style="color:#dc2626">*</span></label>
                    <div class="field-wrap">
                        <input type="text" id="fullname" placeholder="Nguyễn Văn A" class="input-field" autocomplete="name">
                        <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                    </div>
                </div>
                <div>
                    <label class="field-label">Số điện thoại cá nhân <span style="color:#dc2626">*</span></label>
                    <div class="field-wrap">
                        <input type="tel" id="phone" placeholder="0901234567" class="input-field">
                        <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/></svg>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label class="field-label">Tên đăng nhập <span style="color:#dc2626">*</span></label>
                <div class="field-wrap">
                    <input type="text" id="username" placeholder="vd: my_shop123" pattern="^[a-zA-Z0-9_]{3,30}$" title="Chỉ được dùng chữ không dấu, số và dấu _ , dài 3–30 ký tự" class="input-field" autocomplete="username" oninput="validateUsername(this)">
                    <span id="usernameError" style="color:#dc2626;font-size:11.5px;font-weight:500;margin-top:4px;display:block;"></span>
                    <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2"/></svg>
                </div>
            </div>

            <div class="form-group">
                <label class="field-label">Email <span style="color:#dc2626">*</span></label>
                <div class="field-wrap">
                    <input type="email" id="email" placeholder="email@example.com" class="input-field" autocomplete="email">
                    <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label class="field-label">Mật khẩu <span style="color:#dc2626">*</span></label>
                    <div class="field-wrap">
                        <input type="password" id="password" placeholder="8–16 ký tự" class="input-field" style="padding-right:40px;" autocomplete="new-password">
                        <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                        <button type="button" onclick="togglePw('password', this)" class="toggle-pw">
                            <svg class="eye-show" width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                            <svg class="eye-hide hidden" width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/></svg>
                        </button>
                    </div>
                </div>
                <div>
                    <label class="field-label">Xác nhận mật khẩu <span style="color:#dc2626">*</span></label>
                    <div class="field-wrap">
                        <input type="password" id="confirm_password" placeholder="Nhập lại mật khẩu" class="input-field" style="padding-right:40px;" autocomplete="new-password">
                        <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
                        <button type="button" onclick="togglePw('confirm_password', this)" class="toggle-pw">
                            <svg class="eye-show" width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                            <svg class="eye-hide hidden" width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/></svg>
                        </button>
                    </div>
                </div>
            </div>

            <!-- Thông tin cửa hàng -->
            <div class="section-label">🏪 Thông tin cửa hàng</div>

            <div class="form-group">
                <label class="field-label">Tên shop <span style="color:#dc2626">*</span></label>
                <div class="field-wrap">
                    <input type="text" id="shopName" placeholder="Tên thương hiệu / cửa hàng của bạn" class="input-field">
                    <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label class="field-label">Số điện thoại shop <span style="color:#dc2626">*</span></label>
                    <div class="field-wrap">
                        <input type="tel" id="shopPhone" placeholder="Số liên hệ shop" class="input-field">
                        <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/></svg>
                    </div>
                </div>
                <div>
                    <label class="field-label">Logo URL <span style="color:#8A7B6C;font-weight:400;text-transform:none;">(tùy chọn)</span></label>
                    <div class="field-wrap">
                        <input type="url" id="shopLogo" placeholder="https://..." class="input-field">
                        <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label class="field-label">Địa chỉ shop <span style="color:#dc2626">*</span></label>
                <div class="field-wrap">
                    <input type="text" id="shopAddress" placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành" class="input-field">
                    <svg class="field-icon-left" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                </div>
            </div>

            <div class="form-group">
                <label class="field-label">Mô tả shop <span style="color:#8A7B6C;font-weight:400;text-transform:none;">(tùy chọn)</span></label>
                <div class="field-wrap">
                    <textarea id="shopDescription" placeholder="Mô tả ngắn về cửa hàng, loại đồ ăn, đặc điểm nổi bật..." class="input-field" style="padding-left:42px;"></textarea>
                    <svg class="field-icon-left" width="15" height="15" style="top:16px;transform:none;" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h7"/></svg>
                </div>
            </div>

            <button type="button" id="btnRegister" class="btn-primary" onclick="submitRegister()">
                <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                Xác nhận & Nhận mã OTP
            </button>

            <p class="form-footer">Đã có tài khoản? <a href="${pageContext.request.contextPath}/dangnhap">Đăng nhập ngay</a></p>

            <div class="role-divider">Đăng ký theo vai trò khác</div>
            <div class="role-btn-row">
                <a href="${pageContext.request.contextPath}/dangky" class="role-btn">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                    Khách hàng
                </a>
                <a href="${pageContext.request.contextPath}/dangky-shipper" class="role-btn">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 17a2 2 0 100-4 2 2 0 000 4zm14 0a2 2 0 100-4 2 2 0 000 4zM7 17H5v-2l1.5-5h4L14 7h3l2 5v5h-2m-10 0h6"/></svg>
                    Shipper
                </a>
            </div>
        </div>

        <!-- BƯỚC 2: Nhập OTP (inline, cùng trang) -->
        <div id="otpSection">
            <div class="otp-header">
                <h3>✉️ Xác thực email</h3>
                <p>Mã OTP 6 chữ số vừa được gửi đến email</p>
                <span class="email-badge" id="otpEmailBadge"></span>
            </div>

            <div id="otpAlertBox" class="alert alert-error hidden"></div>

            <div class="otp-inputs">
                <input type="text" maxlength="1" class="otp-box" id="otp1" inputmode="numeric" pattern="[0-9]">
                <input type="text" maxlength="1" class="otp-box" id="otp2" inputmode="numeric" pattern="[0-9]">
                <input type="text" maxlength="1" class="otp-box" id="otp3" inputmode="numeric" pattern="[0-9]">
                <input type="text" maxlength="1" class="otp-box" id="otp4" inputmode="numeric" pattern="[0-9]">
                <input type="text" maxlength="1" class="otp-box" id="otp5" inputmode="numeric" pattern="[0-9]">
                <input type="text" maxlength="1" class="otp-box" id="otp6" inputmode="numeric" pattern="[0-9]">
            </div>

            <div class="otp-timer">Mã hết hạn sau: <span id="timerDisplay">05:00</span></div>

            <div class="otp-resend">
                <button type="button" class="btn-ghost" id="btnResend" onclick="resendOtp()" disabled>
                    Gửi lại mã OTP
                </button>
            </div>

            <div class="btn-row">
                <button type="button" class="btn-back" onclick="backToForm()">← Quay lại</button>
                <button type="button" id="btnVerify" class="btn-primary" onclick="submitOtp()">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                    Xác nhận OTP
                </button>
            </div>
        </div>

    </div><!-- /form-panel -->

    <!-- RIGHT: DECORATIVE -->
    <div class="deco-panel">
        <div class="deco-brand">
            <div class="deco-brand-badge">FM</div>
            <span class="deco-brand-label">Hệ thống đặt hàng trực tuyến</span>
        </div>

        <div class="deco-body">
            <h2 class="deco-headline">Kinh doanh cùng FOOD MANAGE,<br>tiếp cận hàng ngàn<br><span>khách hàng mỗi ngày.</span></h2>
            <p class="deco-desc">Điền đầy đủ thông tin tài khoản và cửa hàng, xác nhận OTP, rồi chờ SuperAdmin duyệt là bắt đầu bán hàng ngay.</p>

            <div class="stats-row">
                <div class="stat-item"><div class="stat-value">5.000+</div><div class="stat-label">Cửa hàng</div></div>
                <div class="stat-item"><div class="stat-value">1M+</div><div class="stat-label">Khách hàng</div></div>
                <div class="stat-item"><div class="stat-value">24/7</div><div class="stat-label">Hỗ trợ</div></div>
            </div>

            <div class="step-list">
                <div class="step-item">
                    <div class="step-num">1</div>
                    <div>
                        <div class="step-title">Điền đầy đủ thông tin</div>
                        <div class="step-desc">Thông tin tài khoản + thông tin cửa hàng trên cùng một trang</div>
                    </div>
                </div>
                <div class="step-item">
                    <div class="step-num">2</div>
                    <div>
                        <div class="step-title">Xác nhận OTP qua email</div>
                        <div class="step-desc">Nhập mã 6 số gửi đến email để xác thực danh tính</div>
                    </div>
                </div>
                <div class="step-item">
                    <div class="step-num">3</div>
                    <div>
                        <div class="step-title">Chờ SuperAdmin duyệt</div>
                        <div class="step-desc">Hồ sơ shop được xét duyệt trước khi kích hoạt bán hàng</div>
                    </div>
                </div>
            </div>
        </div>

        <p class="deco-footer">© 2026 FOOD MANAGE — All rights reserved</p>
    </div>

</div><!-- /auth-card -->

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

    const CTX = '${pageContext.request.contextPath}';
    let timerInterval = null;

    /* ---- Hiển thị/Ẩn alert ---- */
    function showAlert(boxId, msg, isError) {
        const box = document.getElementById(boxId);
        box.textContent = msg;
        box.className = 'alert ' + (isError ? 'alert-error' : 'alert-success');
        box.classList.remove('hidden');
    }
    function hideAlert(boxId) {
        document.getElementById(boxId).classList.add('hidden');
    }

    /* ---- BƯỚC 1: Submit form đăng ký ---- */
    async function submitRegister() {
        hideAlert('alertBox');

        const usernameVal = document.getElementById('username').value.trim();
        if (!usernameVal || !/^[a-zA-Z0-9_]{3,30}$/.test(usernameVal)) {
            document.getElementById('usernameError').textContent =
                "⚠️ Tên đăng nhập chỉ được dùng chữ không dấu, số và dấu _ , dài 3–30 ký tự, không có khoảng trắng!";
            document.getElementById('username').focus();
            return;
        }

        const btn = document.getElementById('btnRegister');
        btn.disabled = true;
        btn.textContent = 'Đang xử lý...';

        const body = new URLSearchParams({
            fullname:        document.getElementById('fullname').value.trim(),
            phone:           document.getElementById('phone').value.trim(),
            username:        document.getElementById('username').value.trim(),
            email:           document.getElementById('email').value.trim(),
            password:        document.getElementById('password').value,
            confirm_password:document.getElementById('confirm_password').value,
            shopName:        document.getElementById('shopName').value.trim(),
            shopPhone:       document.getElementById('shopPhone').value.trim(),
            shopLogo:        document.getElementById('shopLogo').value.trim(),
            shopAddress:     document.getElementById('shopAddress').value.trim(),
            shopDescription: document.getElementById('shopDescription').value.trim()
        });

        try {
            const res  = await fetch(CTX + '/dangky-shop', { method: 'POST', body });
            const data = await res.json();
            if (data.ok) {
                const email = document.getElementById('email').value.trim();
                document.getElementById('otpEmailBadge').textContent = email;
                document.getElementById('registerSection').style.display = 'none';
                document.getElementById('otpSection').classList.add('visible');
                startTimer(300);
                document.getElementById('otp1').focus();
            } else {
                showAlert('alertBox', data.message, true);
            }
        } catch (e) {
            showAlert('alertBox', 'Lỗi kết nối, vui lòng thử lại!', true);
        }

        btn.disabled = false;
        btn.innerHTML = '<svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg> Xác nhận & Nhận mã OTP';
    }

    /* ---- BƯỚC 2: Xác nhận OTP ---- */
    async function submitOtp() {
        hideAlert('otpAlertBox');
        const otp = ['otp1','otp2','otp3','otp4','otp5','otp6'].map(id => document.getElementById(id).value).join('');
        if (otp.length < 6) { showAlert('otpAlertBox', 'Vui lòng nhập đủ 6 chữ số OTP!', true); return; }

        const btn = document.getElementById('btnVerify');
        btn.disabled = true;
        btn.textContent = 'Đang xác nhận...';

        const body = new URLSearchParams({ action: 'verifyOtp', otp1: otp[0], otp2: otp[1], otp3: otp[2], otp4: otp[3], otp5: otp[4], otp6: otp[5] });

        try {
            const res  = await fetch(CTX + '/dangky-shop', { method: 'POST', body });
            const data = await res.json();
            if (data.ok) {
                clearInterval(timerInterval);
                window.location.href = CTX + '/dangky-shop?done=1';
            } else {
                showAlert('otpAlertBox', data.message, true);
                // Nếu hết phiên → về form
                if (data.message.includes('đăng ký lại')) {
                    setTimeout(() => backToForm(), 3000);
                }
            }
        } catch (e) {
            showAlert('otpAlertBox', 'Lỗi kết nối, vui lòng thử lại!', true);
        }

        btn.disabled = false;
        btn.innerHTML = '<svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg> Xác nhận OTP';
    }

    /* ---- Gửi lại OTP ---- */
    async function resendOtp() {
        hideAlert('otpAlertBox');
        const btn = document.getElementById('btnResend');
        btn.disabled = true;
        try {
            const res  = await fetch(CTX + '/dangky-shop', { method: 'POST', body: new URLSearchParams({ action: 'resendOtp' }) });
            const data = await res.json();
            showAlert('otpAlertBox', data.message, !data.ok);
            if (data.ok) {
                clearOtpBoxes();
                startTimer(300);
            }
        } catch (e) {
            showAlert('otpAlertBox', 'Lỗi kết nối, vui lòng thử lại!', true);
            btn.disabled = false;
        }
    }

    /* ---- Quay về form ---- */
    function backToForm() {
        clearInterval(timerInterval);
        clearOtpBoxes();
        document.getElementById('otpSection').classList.remove('visible');
        document.getElementById('registerSection').style.display = '';
        hideAlert('otpAlertBox');
    }

    /* ---- Timer đếm ngược ---- */
    function startTimer(seconds) {
        clearInterval(timerInterval);
        let remaining = seconds;
        const display = document.getElementById('timerDisplay');
        const btnResend = document.getElementById('btnResend');
        btnResend.disabled = true;

        timerInterval = setInterval(() => {
            remaining--;
            const m = String(Math.floor(remaining / 60)).padStart(2,'0');
            const s = String(remaining % 60).padStart(2,'0');
            display.textContent = m + ':' + s;
            if (remaining <= 0) {
                clearInterval(timerInterval);
                display.textContent = '00:00';
                btnResend.disabled = false;
            }
        }, 1000);
    }

    function clearOtpBoxes() {
        ['otp1','otp2','otp3','otp4','otp5','otp6'].forEach(id => document.getElementById(id).value = '');
    }

    /* ---- Auto-advance OTP boxes ---- */
    document.querySelectorAll('.otp-box').forEach((box, i, boxes) => {
        box.addEventListener('input', e => {
            const val = e.target.value.replace(/\D/g,'');
            e.target.value = val.slice(-1);
            if (val && i < boxes.length - 1) boxes[i+1].focus();
        });
        box.addEventListener('keydown', e => {
            if (e.key === 'Backspace' && !box.value && i > 0) boxes[i-1].focus();
            if (e.key === 'Enter') submitOtp();
        });
        box.addEventListener('paste', e => {
            e.preventDefault();
            const digits = (e.clipboardData.getData('text') || '').replace(/\D/g,'').slice(0,6);
            digits.split('').forEach((d, j) => { if (boxes[j]) boxes[j].value = d; });
            if (boxes[Math.min(digits.length, boxes.length-1)]) boxes[Math.min(digits.length, boxes.length-1)].focus();
        });
    });

    /* ---- Toggle password ---- */
    function togglePw(id, btn) {
        const input = document.getElementById(id);
        const show  = btn.querySelector('.eye-show');
        const hide  = btn.querySelector('.eye-hide');
        if (input.type === 'password') { input.type = 'text';     show.classList.add('hidden');    hide.classList.remove('hidden'); }
        else                           { input.type = 'password'; show.classList.remove('hidden'); hide.classList.add('hidden'); }
    }
</script>
</body>
</html>
