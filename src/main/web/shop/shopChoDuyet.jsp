<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Shop đang chờ duyệt</title>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary:#FF3B1F; --primary-dark:#E02A10; --bg:#FFF9F2; --text:#2D2421; --muted:#635752; --line:#F1E4D6; }
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Plus Jakarta Sans', Arial, sans-serif; background: var(--bg); color: var(--text); }
        h1 { font-family: 'Quicksand', 'Plus Jakarta Sans', sans-serif; font-weight: 700; margin-top: 0; }
        a { color: var(--primary-dark); font-weight: 700; }
        body { min-height: 100vh; display: grid; place-items: center; }
        .card { width: min(620px, calc(100% - 32px)); padding: 40px 36px; border-radius: 24px; background: #fff; border: 1px solid var(--line); box-shadow: 0 12px 28px -4px rgba(99,44,20,.12); text-align: center; }
        p { line-height: 1.7; color: var(--muted); }
        a { display: inline-block; margin-top: 12px; }
        .steps { list-style: none; margin: 22px 0 6px; padding: 0; display: flex; justify-content: center; gap: 10px; flex-wrap: wrap; text-align: left; }
        .steps li { display: flex; align-items: center; gap: 8px; padding: 8px 14px; border-radius: 999px; background: #F9F3EC; color: var(--muted); font-size: 13px; font-weight: 700; }
        .steps li b { width: 22px; height: 22px; border-radius: 50%; background: #E7E2DB; display: inline-flex; align-items: center; justify-content: center; font-size: 12px; }
        .steps li.done { background: #E8F8EE; color: #15803D; }
        .steps li.done b { background: #22C55E; color: #fff; }
        .steps li.now { background: #FFE9E5; color: #B71500; }
        .steps li.now b { background: var(--primary); color: #fff; }
    </style>
</head>
<body>
<main class="card">
    <h1>⏳ Đang chờ duyệt thông tin</h1>
    <p>Shop <strong><c:out value="${shop.shopName}"/></strong> đã được gửi lên hệ thống. Vui lòng chờ SuperAdmin kiểm tra và duyệt.</p>
    <ol class="steps">
        <li class="done"><b>✓</b> Đã gửi hồ sơ</li>
        <li class="now"><b>2</b> SuperAdmin đang duyệt</li>
        <li><b>3</b> Kích hoạt cửa hàng</li>
    </ol>
    <a href="${pageContext.request.contextPath}/dangnhap">Quay lại đăng nhập</a>
</main>
</body>
</html>
