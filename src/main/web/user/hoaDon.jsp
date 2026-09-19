<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="/app-functions" prefix="app" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hóa đơn - FOOD MANAGE</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Plus Jakarta Sans', 'Inter', -apple-system, sans-serif; background: #FFF9F2; min-height: 100vh; }
        .nav-title, .bill-title, .total-row.grand, h1, h2, h3 { font-family: 'Quicksand', 'Plus Jakarta Sans', sans-serif; }

        /* NAVBAR */
        .navbar { background: #fff; border-bottom: 1px solid #F1E4D6; box-shadow: 0 1px 6px rgba(99,44,20,0.06); padding: 0 24px; height: 60px; display: flex; align-items: center; gap: 14px; }
        .nav-logo { display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .nav-logo-badge { width: 36px; height: 36px; border-radius: 10px; background: linear-gradient(135deg,#FF3B1F,#E02A10); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 800; font-size: 12px; }
        .nav-title { font-size: 16px; font-weight: 800; color: #2D2421; }
        .nav-right { margin-left: auto; display: flex; align-items: center; gap: 16px; }
        .nav-link { font-size: 13px; font-weight: 500; color: #635752; text-decoration: none; transition: color 0.2s; }
        .nav-link:hover { color: #FF3B1F; }

        /* PAGE */
        .page-wrap { max-width: 680px; margin: 0 auto; padding: 32px 20px 48px; }

        /* ALERT */
        .alert-success { display: flex; align-items: center; gap: 10px; border-radius: 14px; padding: 14px 18px; background: #EAFBF1; border: 1px solid #BBF0CF; color: #15803D; font-size: 14px; font-weight: 600; margin-bottom: 24px; }

        /* BILL CARD */
        .bill-card {
            background: #fff; border-radius: 20px; border: 1px solid #F1E4D6;
            box-shadow: 0 4px 20px rgba(99,44,20,0.08);
            overflow: hidden; margin-bottom: 20px;
            animation: fadeIn 0.35s cubic-bezier(0.16,1,0.3,1);
        }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }

        /* BILL HEADER */
        .bill-header {
            background: linear-gradient(140deg, #2B1A10 0%, #14100C 100%);
            padding: 24px 28px; text-align: center; position: relative; overflow: hidden;
        }
        .bill-header::before { content: ''; position: absolute; top: -40px; right: -40px; width: 160px; height: 160px; border-radius: 50%; background: radial-gradient(circle, rgba(255,59,31,0.15) 0%, transparent 70%); }
        .bill-brand { font-size: 13px; font-weight: 700; color: rgba(255,255,255,0.45); letter-spacing: 0.1em; text-transform: uppercase; margin-bottom: 4px; }
        .bill-title { font-size: 22px; font-weight: 800; color: #fff; margin-bottom: 6px; }
        .bill-order-id { font-size: 13px; color: rgba(255,255,255,0.5); }

        /* STATUS BADGE */
        .status-badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 5px 14px; border-radius: 99px;
            font-size: 12px; font-weight: 700; margin-top: 10px;
            background: rgba(255,59,31,0.2); color: #FF3B1F;
        }
        .status-badge.st-done { background: rgba(21,128,61,0.2); color: #4ADE80; }
        .status-badge.st-cancelled { background: rgba(225,29,72,0.25); color: #FCA5A5; }
        .status-badge.st-progress { background: rgba(29,78,216,0.22); color: #93C5FD; }

        /* BILL BODY */
        .bill-body { padding: 24px 28px; }

        .info-section { margin-bottom: 20px; }
        .info-title { font-size: 11px; font-weight: 700; color: #8A7B6C; text-transform: uppercase; letter-spacing: 0.06em; margin-bottom: 10px; }
        .info-row { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; font-size: 13.5px; margin-bottom: 7px; }
        .info-row .lbl { color: #8A7B6C; font-weight: 500; flex-shrink: 0; }
        .info-row .val { color: #2D2421; font-weight: 600; text-align: right; }

        /* DIVIDER */
        .divider { height: 1px; background: repeating-linear-gradient(90deg, #F1E4D6 0, #F1E4D6 6px, transparent 6px, transparent 12px); margin: 18px 0; }

        /* PRODUCT TABLE */
        .prod-table { width: 100%; border-collapse: collapse; }
        .prod-table th { font-size: 11px; font-weight: 700; color: #8A7B6C; text-transform: uppercase; letter-spacing: 0.05em; padding: 0 0 10px; text-align: left; border-bottom: 1px solid #F1E4D6; }
        .prod-table th.r, .prod-table td.r { text-align: right; }
        .prod-table td { padding: 10px 0; font-size: 13.5px; color: #4A3934; border-bottom: 1px solid #FFF9F2; }
        .prod-name { font-weight: 600; color: #2D2421; }
        .prod-size { font-size: 11.5px; color: #8A7B6C; }
        .topping-tag { font-size: 11px; color: #FF3B1F; background: #FFF2F0; border-radius: 6px; padding: 1px 6px; margin-top: 2px; display: inline-block; }

        /* TOTALS */
        .total-block { margin-top: 16px; }
        .total-row { display: flex; justify-content: space-between; font-size: 13.5px; color: #635752; margin-bottom: 6px; }
        .total-row.grand { font-size: 17px; font-weight: 800; color: #2D2421; margin-top: 10px; padding-top: 10px; border-top: 2px solid #FFF4EC; }
        .total-row.grand .amt { color: #FF3B1F; }

        /* ACTIONS */
        .bill-actions { padding: 0 28px 24px; display: flex; gap: 10px; }
        .btn-print {
            flex: 1; padding: 13px; border-radius: 14px; border: none;
            background: linear-gradient(135deg, #FF3B1F, #E02A10);
            color: #fff; font-size: 14px; font-weight: 700;
            cursor: pointer; font-family: inherit; transition: opacity 0.2s;
        }
        .btn-print:hover { opacity: 0.88; }
        .btn-orders {
            padding: 13px 20px; border-radius: 14px;
            border: 1.5px solid #F1E4D6; font-size: 13.5px; font-weight: 600;
            color: #4A3934; background: transparent; text-decoration: none;
            display: flex; align-items: center; justify-content: center;
            font-family: inherit; transition: background 0.15s;
        }
        .btn-orders:hover { background: #F1E4D6; }

        /* PRINT: nhiều máy in hóa đơn dùng khổ giấy nhiệt hẹp (58mm/80mm) - layout desktop bình
           thường (flex 2 cột, bảng 4 cột) bị bóp méo ở khổ này (chữ vỡ từng dòng, cột giá đè lên
           nhau). Định nghĩa lại layout dạng receipt 1 cột, xếp chồng, cho khổ giấy hẹp. */
        @page { margin: 4mm; }
        @media print {
            .navbar, .bill-actions, .alert-success { display: none; }

            body { background: #fff; }
            .page-wrap { max-width: 100%; padding: 0; margin: 0; }

            .bill-card { border: none; box-shadow: none; border-radius: 0; margin: 0; animation: none; }
            .bill-header { padding: 10px 6px; }
            .bill-header::before { display: none; }
            .bill-title { font-size: 15px; }
            .bill-brand { font-size: 10px; }
            .bill-order-id { font-size: 11px; }
            .status-badge { font-size: 10px; padding: 3px 10px; }

            .bill-body { padding: 8px 6px; }
            .info-title { font-size: 10px; }

            /* Mỗi info-row: nhãn trên, giá trị dưới - full chiều rộng, tránh bị bóp thành 1 chữ/dòng */
            .info-row { display: block; font-size: 12px; margin-bottom: 6px; }
            .info-row .lbl { display: block; font-size: 10px; }
            .info-row .val { display: block; text-align: left; font-weight: 700; }

            /* Bảng sản phẩm: bỏ layout bảng ngang (quá chật ở khổ hẹp), chuyển mỗi dòng thành
               khối xếp chồng, thêm nhãn "SL/Đơn giá/Thành tiền" bằng CSS content thay cho header. */
            .prod-table, .prod-table thead, .prod-table tbody, .prod-table tr, .prod-table th, .prod-table td {
                display: block; width: 100%;
            }
            .prod-table thead { display: none; }
            .prod-table tr { padding: 6px 0; border-bottom: 1px dashed #E8D7C3; }
            .prod-table td { padding: 1px 0; border: none; font-size: 12px; }
            .prod-table td.r { text-align: left; }
            .prod-table td.r:nth-of-type(2)::before { content: "SL: "; color: #8A7B6C; }
            .prod-table td.r:nth-of-type(3)::before { content: "Đơn giá: "; color: #8A7B6C; }
            .prod-table td.r:nth-of-type(4)::before { content: "Thành tiền: "; color: #8A7B6C; }
            .prod-table td.r:nth-of-type(4) { font-weight: 700; }

            .total-row { font-size: 12px; }
            .total-row.grand { font-size: 14px; }
        }
    </style>
</head>
<body>

<nav class="navbar">
    <a href="${pageContext.request.contextPath}/user/home" class="nav-logo">
        <div class="nav-logo-badge">FM</div>
    </a>
    <span class="nav-title">Hóa đơn</span>
    <div class="nav-right">
        <a href="${pageContext.request.contextPath}/user/donhang" class="nav-link" style="display:inline-flex;align-items:center;gap:5px;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
            Đơn hàng
        </a>
        <a href="${pageContext.request.contextPath}/user/home" class="nav-link">← Trang chủ</a>
    </div>
</nav>

<div class="page-wrap">

    <c:if test="${not empty bills}">
        <div class="alert-success"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg> Đặt hàng thành công! Dưới đây là hóa đơn của bạn.</div>
    </c:if>

    <c:forEach items="${bills}" var="bill">
        <div class="bill-card">

            <div class="bill-header">
                <div class="bill-brand">FOOD MANAGE</div>
                <div class="bill-title" style="display:flex;align-items:center;justify-content:center;gap:8px;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 2h16a1 1 0 0 1 1 1v18l-3-2-3 2-3-2-3 2-3-2-3 2V3a1 1 0 0 1 1-1z"/><line x1="8" y1="7" x2="16" y2="7"/><line x1="8" y1="11" x2="16" y2="11"/><line x1="8" y1="15" x2="12" y2="15"/></svg>
                    Hóa đơn thanh toán</div>
                <div class="bill-order-id">Mã đơn #${bill.order.id} &nbsp;·&nbsp; <c:out value="${bill.shopName}"/></div>
                <div class="status-badge ${bill.order.staTus eq 'DONE' ? 'st-done' : bill.order.staTus eq 'CANCELLED' ? 'st-cancelled' : 'st-progress'}">
                    ●
                    <c:choose>
                        <c:when test="${bill.order.staTus eq 'PENDING'}">Chờ xác nhận</c:when>
                        <c:when test="${bill.order.staTus eq 'WAITING_FOR_SHIPPER'}">Đang chuẩn bị</c:when>
                        <c:when test="${bill.order.staTus eq 'ACCEPTED'}">Tài xế đã nhận</c:when>
                        <c:when test="${bill.order.staTus eq 'READY_FOR_PICKUP'}">Chờ shipper lấy hàng</c:when>
                        <c:when test="${bill.order.staTus eq 'SHIPPING'}">Đang giao</c:when>
                        <c:when test="${bill.order.staTus eq 'DONE'}">Đã giao thành công</c:when>
                        <c:when test="${bill.order.staTus eq 'CANCELLED'}">Đã hủy</c:when>
                        <c:otherwise>${bill.order.staTus}</c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="bill-body">

                <div class="info-section">
                    <div class="info-title">Thông tin nhận hàng</div>
                    <div class="info-row"><span class="lbl">Người nhận</span><span class="val"><c:out value="${bill.order.receiverName}"/></span></div>
                    <div class="info-row"><span class="lbl">Số điện thoại</span><span class="val"><c:out value="${bill.order.receiverPhone}"/></span></div>
                    <div class="info-row"><span class="lbl">Địa chỉ</span><span class="val"><c:out value="${bill.order.shippingAddress}"/></span></div>
                    <div class="info-row"><span class="lbl">Thanh toán</span><span class="val"><c:out value="${bill.order.paymentMethod}"/></span></div>
                    <div class="info-row">
                        <span class="lbl">Thời gian</span>
                        <span class="val">
                            ${app:formatDateTime(bill.order.createdAt)}
                        </span>
                    </div>
                </div>

                <div class="divider"></div>

                <table class="prod-table">
                    <thead>
                        <tr>
                            <th>Sản phẩm</th>
                            <th class="r">SL</th>
                            <th class="r">Đơn giá</th>
                            <th class="r">Thành tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${bill.lines}" var="line">
                            <tr>
                                <td>
                                    <div class="prod-name"><c:out value="${line.productName}"/></div>
                                    <div class="prod-size"><c:out value="${line.sizeName}"/></div>
                                    <c:forEach items="${line.toppings}" var="tp">
                                        <span class="topping-tag">+ <c:out value="${tp.toppingName}"/> x${tp.quantity} (<fmt:formatNumber value="${tp.price}" type="number" maxFractionDigits="0"/>đ)</span><br>
                                    </c:forEach>
                                </td>
                                <td class="r">${line.quantity}</td>
                                <td class="r"><fmt:formatNumber value="${line.price}" type="number" maxFractionDigits="0"/>đ</td>
                                <td class="r"><fmt:formatNumber value="${line.lineTotal}" type="number" maxFractionDigits="0"/>đ</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <div class="total-block">
                    <div class="total-row"><span>Tạm tính</span><span><fmt:formatNumber value="${bill.subtotal}" type="number" maxFractionDigits="0"/>đ</span></div>
                    <div class="total-row"><span>Phí giao hàng</span><span><fmt:formatNumber value="${bill.order.deliveryFee}" type="number" maxFractionDigits="0"/>đ</span></div>
                    <div class="total-row grand"><span>Tổng thanh toán</span><span class="amt"><fmt:formatNumber value="${bill.order.totalPrice}" type="number" maxFractionDigits="0"/>đ</span></div>
                </div>

            </div>

            <div class="bill-actions">
                <a href="${pageContext.request.contextPath}/user/donhang" class="btn-orders" style="gap:6px;">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                    Đơn hàng</a>
            </div>

        </div>
    </c:forEach>

    <c:if test="${empty bills}">
        <div style="text-align:center;padding:64px 24px;background:#fff;border-radius:20px;border:1px solid #F1E4D6;">
            <div style="margin-bottom:14px;"><svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#E8D7C3" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="margin:0 auto;"><path d="M4 2h16a1 1 0 0 1 1 1v18l-3-2-3 2-3-2-3 2-3-2-3 2V3a1 1 0 0 1 1-1z"/><line x1="8" y1="7" x2="16" y2="7"/><line x1="8" y1="11" x2="16" y2="11"/><line x1="8" y1="15" x2="12" y2="15"/></svg></div>
            <div style="font-size:16px;font-weight:600;color:#635752;">Không tìm thấy hóa đơn.</div>
            <a href="${pageContext.request.contextPath}/user/donhang" style="display:inline-block;margin-top:12px;font-size:13.5px;font-weight:700;color:#FF3B1F;text-decoration:none;">Xem đơn hàng →</a>
        </div>
    </c:if>

</div>
</body>
</html>
