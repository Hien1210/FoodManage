<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- BẢO MẬT: KIỂM TRA QUYỀN SHOP (roleId = 2) --%>
<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 2}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán thất bại</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <style>
        body.dash-body { display: flex; align-items: center; justify-content: center; }
        .fail-card { background: var(--white); border-radius: var(--radius-lg); box-shadow: var(--shadow-lg); padding: 40px 36px; max-width: 480px; text-align: center; }
        .fail-icon { font-size: 52px; margin-bottom: 14px; }
        .fail-card h1 { font-size: 22px; color: var(--danger); margin-bottom: 10px; font-weight: 800; }
        .fail-card p.msg { font-size: 14px; color: var(--gray-600); margin-bottom: 16px; line-height: 1.6; }
    </style>
</head>
<body class="dash-body shop-theme">
    <div class="fail-card">
        <div class="fail-icon">❌</div>
        <h1>Thanh toán PayOS thất bại</h1>
        <p class="msg">
            <c:out value="${not empty loi ? loi : 'Giao dich PayOS da bi huy hoac khong thanh cong.'}"/>
        </p>
        <c:if test="${not empty order}">
            <p class="msg">Mã đơn hàng: #${order.id} — Hóa đơn này sẽ <strong>không được lưu</strong> sau khi bạn xác nhận.</p>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/shop/pos">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="discardOrder">
            <input type="hidden" name="id" value="${order.id}">
            <button type="submit" class="btn btn-primary">✅ Xác nhận</button>
        </form>
    </div>
</body>
</html>
