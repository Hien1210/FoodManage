<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="/app-functions" prefix="app" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty cart || cart.id == 0 ? 'Thêm giỏ hàng' : 'Sửa giỏ hàng'}</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f0f2f5;
            color: #333;
        }

        nav {
            background: #2c3e50;
            padding: 0 32px;
            display: flex;
            align-items: center;
            height: 56px;
            gap: 8px;
        }
        nav a {
            color: #ecf0f1;
            text-decoration: none;
            padding: 8px 14px;
            border-radius: 4px;
            font-size: 14px;
            transition: background .2s;
        }
        nav a:hover { background: #3d5a73; }

        .container {
            max-width: 520px;
            margin: 48px auto;
            padding: 0 16px;
        }

        .card {
            background: #fff;
            border-radius: 10px;
            padding: 32px;
            box-shadow: 0 2px 8px rgba(0,0,0,.10);
        }

        .card h2 {
            font-size: 20px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 24px;
            padding-bottom: 12px;
            border-bottom: 2px solid #e8eaed;
        }

        .form-group {
            margin-bottom: 18px;
        }
        label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #555;
            margin-bottom: 6px;
        }
        input {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-size: 14px;
            color: #333;
            transition: border-color .2s, box-shadow .2s;
        }
        input:focus {
            outline: none;
            border-color: #2980b9;
            box-shadow: 0 0 0 3px rgba(41,128,185,.15);
        }
        input[readonly] {
            background: #f8f9fa;
            color: #888;
            cursor: not-allowed;
        }

        .alert-error {
            padding: 10px 14px;
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            border-radius: 5px;
            font-size: 13px;
            margin-bottom: 16px;
        }

        .form-actions {
            display: flex;
            gap: 12px;
            margin-top: 24px;
        }
        .btn {
            flex: 1;
            padding: 10px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            transition: opacity .2s;
        }
        .btn:hover { opacity: .85; }
        .btn-primary { background: #2980b9; color: #fff; }
        .btn-secondary {
            background: #ecf0f1;
            color: #555;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .hint { font-size: 11px; color: #999; margin-top: 4px; }
    </style>
</head>
<body>

<nav>
    <a href="${pageContext.request.contextPath}/user/home">🏠 Trang chủ</a>
    <a href="${pageContext.request.contextPath}/cart">🛒 Giỏ hàng</a>
</nav>

<div class="container">
    <div class="card">
        <h2>${empty cart || cart.id == 0 ? '➕ Thêm giỏ hàng mới' : '✏️ Chỉnh sửa giỏ hàng'}</h2>

        <c:if test="${not empty error}">
            <div class="alert-error">❌ ${fn:escapeXml(error)}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/cart">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <%-- Hidden fields --%>
            <input type="hidden" name="action" value="${empty cart || cart.id == 0 ? 'create' : 'update'}"/>
            <c:if test="${not empty cart && cart.id > 0}">
                <input type="hidden" name="id" value="${cart.id}"/>
            </c:if>

            <%-- ID (chỉ hiển thị khi edit) --%>
            <c:if test="${not empty cart && cart.id > 0}">
                <div class="form-group">
                    <label>Cart ID</label>
                    <input type="text" value="${cart.id}" readonly/>
                </div>
            </c:if>

            <%-- User ID --%>
            <div class="form-group">
                <label for="userId">User ID <span style="color:#e74c3c">*</span></label>
                <input type="number" id="userId" name="userId" min="1"
                       value="${not empty cart ? cart.userId : ''}"
                       placeholder="Nhập ID người dùng" required/>
            </div>

            <%-- Created At --%>
            <div class="form-group">
                <label for="createdAt">Ngày tạo</label>
                <input type="datetime-local" id="createdAt" name="createdAt"
                       value="${not empty cart ? app:formatForInput(cart.createdAt) : ''}"/>
                <p class="hint">Để trống → tự động lấy thời gian hiện tại</p>
            </div>

            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/cart" class="btn btn-secondary">← Quay lại</a>
                <button type="submit" class="btn btn-primary">
                    ${empty cart || cart.id == 0 ? '💾 Thêm mới' : '💾 Cập nhật'}
                </button>
            </div>
        </form>
    </div>
</div>

</body>
</html>
