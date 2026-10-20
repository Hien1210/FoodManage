<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="/app-functions" prefix="app" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Thông Tin Cửa Hàng</title>
    <style>
        .form-container { width: 50%; margin: 20px auto; font-family: Arial, sans-serif; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group textarea, .form-group select { width: 100%; padding: 8px; box-sizing: border-box; }
        .btn-submit { background-color: #007bff; color: white; padding: 10px 15px; border: none; cursor: pointer; border-radius: 4px;}
        .btn-cancel { background-color: #6c757d; color: white; padding: 10px 15px; text-decoration: none; border-radius: 4px; display:inline-block; }
    </style>
</head>
<body>

    <jsp:include page="quanLyCuaHang.jsp" />

    <div class="form-container">
        <c:if test="${not empty loi}">
            <div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div>
        </c:if>
        <h2>
            <c:if test="${shop != null}">Cập Nhật Cửa Hàng (ID: ${shop.id})</c:if>
            <c:if test="${shop == null}">Đăng Ký Cửa Hàng Mới</c:if>
        </h2>

        <form action="${pageContext.request.contextPath}/shops" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <c:if test="${shop != null}">
                <input type="hidden" name="action" value="update" />
                <input type="hidden" name="id" value="${shop.id}" />
            </c:if>
            <c:if test="${shop == null}">
                <input type="hidden" name="action" value="insert" />
            </c:if>

            <div class="form-group">
                <label>Mã Chủ Sở Hữu (Owner ID):</label>
                <input type="number" name="ownerId" value="${shop.ownerId}" required />
            </div>

            <div class="form-group">
                <label>Tên Cửa Hàng:</label>
                <input type="text" name="shopName" value="${fn:escapeXml(shop.shopName)}" required />
            </div>

            <div class="form-group">
                <label>Mô Tả:</label>
                <textarea name="shopDescription" rows="3">${fn:escapeXml(shop.shopDescription)}</textarea>
            </div>

            <div class="form-group">
                <label>Địa Chỉ:</label>
                <input type="text" name="shopAddress" value="${fn:escapeXml(shop.shopAddress)}" required />
            </div>

            <div class="form-group">
                <label>Số Điện Thoại:</label>
                <input type="text" name="shopPhone" value="${fn:escapeXml(shop.shopPhone)}" required />
            </div>

            <div class="form-group">
                <label>Đường Dẫn Logo:</label>
                <input type="text" name="shopLogo" value="${fn:escapeXml(shop.shopLogo)}" />
            </div>

            <div class="form-group">
                <label>Trạng Thái Hệ Thống:</label>
                <select name="status" disabled>
                    <option value="PENDING" ${shop.status == 'PENDING' ? 'selected' : ''}>Chờ duyệt</option>
                    <option value="ACTIVE" ${shop.status == 'ACTIVE' ? 'selected' : ''}>Đã duyệt</option>
                    <option value="REJECTED" ${shop.status == 'REJECTED' ? 'selected' : ''}>Từ chối</option>
                    <option value="BLOCKED" ${shop.status == 'BLOCKED' ? 'selected' : ''}>Bị khoá</option>
                </select>
                <input type="hidden" name="status" value="${shop.status}" />
            </div>

            <div class="form-group">
                <label>Lý Do Từ Chối (Nếu có):</label>
                <input type="text" name="rejectionReason" value="${fn:escapeXml(shop.rejectionReason)}" />
            </div>

            <div class="form-group">
                <label>ID Người Duyệt (Approved By):</label>
                <input type="number" name="approvedBy" value="${shop.approvedBy}" />
            </div>

            <div class="form-group">
                <label>Thời Gian Duyệt:</label>
                <input type="datetime-local" name="approveDate" value="${app:formatForInput(shop.approveDate)}" />
            </div>

            <button type="submit" class="btn-submit">Lưu Lại</button>
            <a href="shops" class="btn-cancel">Hủy Bỏ</a>
        </form>
    </div>
</body>
</html>