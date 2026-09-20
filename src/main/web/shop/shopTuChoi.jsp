<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Shop bị từ chối</title>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary:#FF3B1F; --primary-dark:#E02A10; --bg:#FFF9F2; --text:#2D2421; --muted:#635752; --line:#F1E4D6; }
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Plus Jakarta Sans', Arial, sans-serif; background: var(--bg); color: var(--text); }
        h1 { font-family: 'Quicksand', 'Plus Jakarta Sans', sans-serif; font-weight: 700; margin-top: 0; }
        a { color: var(--primary-dark); font-weight: 700; }
        label { display: block; margin-top: 16px; font-weight: 700; font-size: 13px; }
        input, textarea { width: 100%; margin-top: 7px; padding: 12px 14px; border: 1px solid #E7D3C9; border-radius: 12px; background: #FFFCF9; font-family: inherit; font-size: 14px; color: var(--text); outline: none; }
        input:focus, textarea:focus { border-color: #FF6B2C; box-shadow: 0 0 0 3px rgba(255,107,44,.2); }
        textarea { min-height: 100px; resize: vertical; }
        button { margin-top: 22px; padding: 12px 22px; border: 0; border-radius: 999px; background: var(--primary); color: #fff; font-weight: 800; font-family: inherit; cursor: pointer; box-shadow: 0 8px 20px rgba(255,59,31,.3); }
        button:hover { background: var(--primary-dark); }
        .wrap { max-width: 760px; margin: 44px auto; padding: 0 18px; }
        .card { background: #fff; border: 1px solid var(--line); border-radius: 24px; padding: 32px; box-shadow: 0 12px 28px -4px rgba(99,44,20,.12); }
        .hint { color: var(--muted); line-height: 1.6; }
        .reason { padding: 14px 16px; border-radius: 14px; background: #FFE9E5; border: 1px solid #FFC7BE; color: #93000A; }
    </style>
</head>
<body>
<main class="wrap">
    <section class="card">
        <h1>Thông tin shop bị từ chối</h1>
        <p class="reason"><strong>Lý do:</strong> ${fn:escapeXml(shop.rejectionReason)}</p>
        <p>Chỉnh lại thông tin bên dưới và gửi lại yêu cầu duyệt.</p>

        <form action="${pageContext.request.contextPath}/shop" method="post" accept-charset="UTF-8">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <label for="shopName">Tên shop</label>
            <input id="shopName" type="text" name="shopName" value="${fn:escapeXml(shop.shopName)}" required>

            <label for="shopDescription">Mô tả shop</label>
            <textarea id="shopDescription" name="shopDescription">${fn:escapeXml(shop.shopDescription)}</textarea>

            <label for="shopAddress">Địa chỉ</label>
            <input id="shopAddress" type="text" name="shopAddress" value="${fn:escapeXml(shop.shopAddress)}" required>

            <label for="shopPhone">Số điện thoại shop</label>
            <input id="shopPhone" type="text" name="shopPhone" value="${shop.shopPhone}" required>

            <label for="shopLogo">Logo URL</label>
            <input id="shopLogo" type="text" name="shopLogo" value="${shop.shopLogo}">

            <button type="submit">Gửi lại yêu cầu</button>
        </form>
    </section>
</main>
</body>
</html>
