<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="/app-functions" prefix="app" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty order || order.id == 0 ? 'Them don hang' : 'Sua don hang'}</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, sans-serif; background: #f3f4f6; color: #1f2937; }
        nav { background: #111827; height: 56px; display: flex; align-items: center; gap: 8px; padding: 0 28px; }
        nav a { color: #e5e7eb; text-decoration: none; padding: 8px 12px; border-radius: 6px; font-size: 14px; }
        nav a:hover, nav a.active { background: #374151; }
        .container { max-width: 760px; margin: 32px auto; padding: 0 16px; }
        .card { background: #fff; border-radius: 10px; padding: 28px; box-shadow: 0 1px 4px rgba(0,0,0,.08); }
        h1 { font-size: 22px; margin-bottom: 22px; padding-bottom: 12px; border-bottom: 1px solid #e5e7eb; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .full { grid-column: span 2; }
        label { font-size: 13px; font-weight: 700; color: #374151; }
        input, select, textarea { width: 100%; border: 1px solid #d1d5db; border-radius: 6px; padding: 10px 12px; font-size: 14px; }
        textarea { min-height: 86px; resize: vertical; }
        input:focus, select:focus, textarea:focus { outline: none; border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37,99,235,.12); }
        .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; padding: 10px 12px; border-radius: 6px; margin-bottom: 16px; }
        .actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 22px; padding-top: 16px; border-top: 1px solid #e5e7eb; }
        .btn { display: inline-block; padding: 10px 16px; border-radius: 6px; text-decoration: none; border: 0; cursor: pointer; font-weight: 700; font-size: 14px; }
        .btn-primary { background: #2563eb; color: #fff; }
        .btn-secondary { background: #e5e7eb; color: #111827; }
    </style>
</head>
<body>
<nav>
    <a href="${pageContext.request.contextPath}/">Trang chu</a>
    <a href="${pageContext.request.contextPath}/cart">Gio hang</a>
    <a href="${pageContext.request.contextPath}/orders" class="active">Don hang</a>
</nav>

<div class="container">
    <div class="card">
        <h1>
            <c:choose>
                <c:when test="${empty order || order.id == 0}">Them don hang moi</c:when>
                <c:otherwise>Sua don hang #${order.id}</c:otherwise>
            </c:choose>
        </h1>

        <c:if test="${not empty error}">
            <div class="alert-error"><c:out value="${error}"/></div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/orders">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="${empty order || order.id == 0 ? 'create' : 'update'}">
            <c:if test="${not empty order && order.id > 0}">
                <input type="hidden" name="id" value="${order.id}">
            </c:if>

            <div class="form-grid">
                <div class="form-group">
                    <label for="userId">User ID *</label>
                    <input type="number" id="userId" name="userId" min="1" value="${order.userId}" required>
                </div>
                <div class="form-group">
                    <label for="shopId">Shop ID *</label>
                    <input type="number" id="shopId" name="shopId" min="1" value="${order.shopId}" required>
                </div>
                <div class="form-group">
                    <label for="shipperId">Shipper ID</label>
                    <input type="number" id="shipperId" name="shipperId" min="0" value="${order.shipperId}">
                </div>
                <div class="form-group">
                    <label for="receiverName">Ten nguoi nhan *</label>
                    <input type="text" id="receiverName" name="receiverName" value="${fn:escapeXml(order.receiverName)}" required>
                </div>
                <div class="form-group">
                    <label for="receiverPhone">So dien thoai *</label>
                    <input type="text" id="receiverPhone" name="receiverPhone" value="${fn:escapeXml(order.receiverPhone)}" required>
                </div>
                <div class="form-group full">
                    <label for="shippingAddress">Dia chi giao hang *</label>
                    <textarea id="shippingAddress" name="shippingAddress" required><c:out value="${order.shippingAddress}"/></textarea>
                </div>
                <div class="form-group">
                    <label for="totalPrice">Tong tien *</label>
                    <input type="number" id="totalPrice" name="totalPrice" min="0" step="0.01" value="${order.totalPrice}" required>
                </div>
                <div class="form-group">
                    <label for="deliveryFee">Phi giao hang</label>
                    <input type="number" id="deliveryFee" name="deliveryFee" min="0" step="0.01" value="${order.deliveryFee}">
                </div>
                <div class="form-group">
                    <label for="paymentMethod">Thanh toan</label>
                    <select id="paymentMethod" name="paymentMethod">
                        <option value="COD" ${order.paymentMethod == 'COD' ? 'selected' : ''}>COD</option>
                        <option value="BANK" ${order.paymentMethod == 'BANK' ? 'selected' : ''}>BANK (QR chuyen khoan)</option>
                        <option value="PAYOS" ${order.paymentMethod == 'PAYOS' ? 'selected' : ''}>PAYOS</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="status">Trang thai</label>
                    <select id="status" name="status">
                        <option value="PENDING" ${order.staTus == 'PENDING' ? 'selected' : ''}>PENDING</option>
                        <option value="CONFIRMED" ${order.staTus == 'CONFIRMED' ? 'selected' : ''}>CONFIRMED</option>
                        <option value="READY_FOR_PICKUP" ${order.staTus == 'READY_FOR_PICKUP' ? 'selected' : ''}>READY_FOR_PICKUP</option>
                        <option value="SHIPPING" ${order.staTus == 'SHIPPING' ? 'selected' : ''}>SHIPPING</option>
                        <option value="DONE" ${order.staTus == 'DONE' ? 'selected' : ''}>DONE</option>
                        <option value="CANCELLED" ${order.staTus == 'CANCELLED' ? 'selected' : ''}>CANCELLED</option>
                    </select>
                </div>
                <div class="form-group full">
                    <label for="estimatedDeliveryTime">Thoi gian giao du kien</label>
                    <input type="datetime-local" id="estimatedDeliveryTime" name="estimatedDeliveryTime" value="${app:formatForInput(order.estimatedDeliveryTime)}">
                </div>
            </div>

            <div class="actions">
                <a href="${pageContext.request.contextPath}/orders" class="btn btn-secondary">Quay lai</a>
                <button type="submit" class="btn btn-primary">${empty order || order.id == 0 ? 'Them moi' : 'Cap nhat'}</button>
            </div>
        </form>
    </div>
</div>
</body>
</html>
