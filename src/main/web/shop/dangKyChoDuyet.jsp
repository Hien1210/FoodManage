<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký thành công - Chờ duyệt | FOOD MANAGE</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #F7EBDD 0%, #FFEFE6 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        .card {
            background: #fff;
            border-radius: 24px;
            box-shadow: 0 24px 64px rgba(99,44,20,0.12);
            padding: 56px 48px;
            max-width: 520px;
            width: 100%;
            text-align: center;
            animation: fadeInUp 0.5s cubic-bezier(0.16,1,0.3,1);
        }

        .icon-wrap {
            width: 88px; height: 88px;
            border-radius: 50%;
            background: linear-gradient(135deg, #FF3B1F, #E02A10);
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 24px;
            box-shadow: 0 12px 32px rgba(255,59,31,0.35);
        }
        .icon-wrap svg { width: 44px; height: 44px; color: #fff; }

        .badge {
            display: inline-flex; align-items: center; gap: 6px;
            background: #fef3c7; border: 1px solid #fde68a;
            color: #92400e; font-size: 12px; font-weight: 700;
            padding: 5px 14px; border-radius: 20px; margin-bottom: 20px;
            letter-spacing: 0.03em;
        }

        h1, .steps h3 { font-family: 'Quicksand', 'Plus Jakarta Sans', sans-serif; }
        h1 {
            font-size: 26px; font-weight: 800; color: #2D2421;
            letter-spacing: -0.02em; margin-bottom: 10px;
        }
        .subtitle {
            font-size: 15px; color: #635752; line-height: 1.7; margin-bottom: 32px;
        }
        .subtitle strong { color: #FF3B1F; }

        .steps {
            background: #FFF4EC; border-radius: 16px; padding: 24px;
            text-align: left; margin-bottom: 32px;
        }
        .steps h3 {
            font-size: 12px; font-weight: 800; color: #8A7B6C;
            text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 16px;
        }
        .step {
            display: flex; align-items: center; gap: 14px;
            padding: 10px 0;
        }
        .step:not(:last-child) { border-bottom: 1px solid #F1E4D6; }
        .step-dot {
            width: 32px; height: 32px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; flex-shrink: 0;
        }
        .step-dot.done  { background: #dcfce7; color: #16a34a; }
        .step-dot.done::after { content: '✓'; font-weight: 800; }
        .step-dot.wait  { background: #fef3c7; font-weight: 800; }
        .step-dot.later { background: #F7EBDD; color: #8A7B6C; font-weight: 800; }
        .step-info strong { display: block; font-size: 13.5px; font-weight: 700; color: #2D2421; }
        .step-info span   { font-size: 12px; color: #635752; }

        .tip-box {
            background: #FFF2F0; border: 1px solid #FFC7BE; border-radius: 12px;
            padding: 16px 20px; margin-bottom: 28px; text-align: left;
            display: flex; gap: 12px;
        }
        .tip-icon { font-size: 20px; flex-shrink: 0; margin-top: 1px; }
        .tip-text { font-size: 13px; color: #FF3B1F; line-height: 1.6; }
        .tip-text strong { font-weight: 700; }

        .btn-login {
            display: inline-flex; align-items: center; gap: 8px;
            background: linear-gradient(135deg, #FF3B1F, #E02A10);
            color: #fff; font-weight: 700; font-size: 14px;
            padding: 13px 32px; border-radius: 12px; text-decoration: none;
            transition: all 0.2s; box-shadow: 0 4px 16px rgba(255,59,31,0.35);
        }
        .btn-login:hover { transform: translateY(-1.5px); box-shadow: 0 6px 22px rgba(255,59,31,0.45); }

        .footer-note { font-size: 12px; color: #D9C9BA; margin-top: 20px; }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(28px) scale(0.97); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }
        @media (max-width: 560px) {
            .card { padding: 36px 24px; }
            h1 { font-size: 22px; }
        }
    </style>
</head>
<body>

<div class="card">

    <div class="icon-wrap">
        <svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
    </div>

    <div class="badge">⏳ Đang chờ xét duyệt</div>

    <h1>Đăng ký thành công!</h1>
    <p class="subtitle">
        Tài khoản và hồ sơ cửa hàng của bạn đã được ghi nhận.<br>
        <strong>Vui lòng chờ SuperAdmin xét duyệt</strong> trước khi bắt đầu bán hàng.
    </p>

    <div class="steps">
        <h3>Trạng thái hồ sơ</h3>

        <div class="step">
            <div class="step-dot done"></div>
            <div class="step-info">
                <strong>Đã hoàn thành đăng ký</strong>
                <span>Thông tin tài khoản + cửa hàng đã được ghi nhận</span>
            </div>
        </div>

        <div class="step">
            <div class="step-dot wait">⏳</div>
            <div class="step-info">
                <strong>Đang chờ SuperAdmin xét duyệt</strong>
                <span>Thường trong vòng 1–2 ngày làm việc</span>
            </div>
        </div>

        <div class="step">
            <div class="step-dot later">3</div>
            <div class="step-info">
                <strong>Kích hoạt & bắt đầu bán hàng</strong>
                <span>Sau khi được duyệt, đăng sản phẩm và nhận đơn ngay</span>
            </div>
        </div>
    </div>

    <div class="tip-box">
        <div class="tip-icon">💡</div>
        <div class="tip-text">
            Bạn có thể <strong>đăng nhập</strong> ngay bây giờ bằng tài khoản vừa tạo. Sau khi SuperAdmin duyệt, bạn sẽ nhận thông báo và có thể bắt đầu quản lý cửa hàng.
        </div>
    </div>

    <a href="${pageContext.request.contextPath}/dangnhap" class="btn-login">
        <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"/>
        </svg>
        Đăng nhập ngay
    </a>

    <p class="footer-note">© 2026 FOOD MANAGE — Nếu cần hỗ trợ, vui lòng liên hệ quản trị viên</p>

</div>

</body>
</html>
