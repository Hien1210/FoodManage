<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 3}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu cầu hoàn tiền - Đơn #${order.id}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <style>
        /* Token cục bộ theo bộ thiết kế Stitch (trước đây các biến --bg-main/--text-main... không được định nghĩa ở trang này nên nền/chữ/viền rơi về mặc định trình duyệt) */
        :root {
            --primary: #FF3B1F;
            --primary-dark: #E02A10;
            --bg-main: #FFF9F2;
            --bg-panel: #FFFFFF;
            --bg-input: #FFF4EC;
            --text-main: #2D2421;
            --text-muted: #635752;
            --border-color: #F1E4D6;
            --font-sans: 'Plus Jakarta Sans', -apple-system, 'Segoe UI', sans-serif;
            --font-h: 'Quicksand', 'Plus Jakarta Sans', sans-serif;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { background: var(--bg-main); color: var(--text-main); font-family: var(--font-sans); min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 24px; }
        .card { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 20px; padding: 36px; width: 100%; max-width: 520px; box-shadow: 0 14px 34px rgba(99,44,20,.12); }
        .card-title { font-family: var(--font-h); font-size: 22px; font-weight: 800; color: var(--text-main); margin-bottom: 6px; }
        .card-sub { font-size: 13px; color: var(--text-muted); margin-bottom: 24px; }
        .order-info { background: var(--bg-input); border-radius: 12px; padding: 14px 16px; margin-bottom: 22px; display: flex; justify-content: space-between; align-items: center; }
        .order-info .label { font-size: 12px; color: var(--text-muted); }
        .order-info .value { font-family: var(--font-h); font-size: 18px; font-weight: 800; color: #E11D48; }
        .info-box { background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px; padding: 12px 14px; font-size: 13px; color: #1d4ed8; margin-bottom: 20px; line-height: 1.5; }
        .info-box.success { background: #f0fdf4; border-color: #bbf7d0; color: #15803d; }
        .info-box.warning { background: #fffbeb; border-color: #fde68a; color: #92400e; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-size: 12px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: .04em; margin-bottom: 6px; }
        .form-group input, .form-group textarea { width: 100%; padding: 11px 13px; border-radius: 10px; border: 1.5px solid var(--border-color); background: var(--bg-input); color: var(--text-main); font-size: 14px; font-family: inherit; }
        .form-group input:focus, .form-group textarea:focus { outline: none; border-color: var(--primary); }
        .form-group textarea { resize: vertical; min-height: 70px; }
        .btn-submit { width: 100%; padding: 13px; border-radius: 12px; background: var(--primary); color: #fff; font-size: 15px; font-weight: 700; border: none; cursor: pointer; transition: .18s; margin-top: 4px; }
        .btn-submit:hover { background: var(--primary-dark); }
        .btn-back { display: block; text-align: center; margin-top: 14px; font-size: 13px; color: var(--text-muted); }
        .alert-danger { background: #fee2e2; border: 1px solid #fecaca; color: #b91c1c; border-radius: 10px; padding: 12px 14px; margin-bottom: 16px; font-size: 14px; font-weight: 600; }
        .done-icon { font-size: 48px; text-align: center; margin-bottom: 12px; }
        .status-row { display: flex; justify-content: space-between; font-size: 13px; padding: 6px 0; border-bottom: 1px solid var(--border-color); }
        .status-row:last-child { border-bottom: none; }
        .status-row .k { color: var(--text-muted); }
        .status-row .v { font-weight: 600; }
        .badge { display: inline-block; padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 700; }
        .badge.PENDING { background: #fef3c7; color: #92400e; }
        .badge.COMPLETED { background: #dcfce7; color: #15803d; }
        .badge.REJECTED { background: #fee2e2; color: #b91c1c; }
    </style>
</head>
<body>
<div class="card">

    <c:choose>
        <%-- Đã gửi yêu cầu trước đó --%>
        <c:when test="${not empty existing}">
            <div class="done-icon">
                <c:choose>
                    <c:when test="${existing.status eq 'COMPLETED'}">✅</c:when>
                    <c:when test="${existing.status eq 'REJECTED'}">❌</c:when>
                    <c:otherwise>⏳</c:otherwise>
                </c:choose>
            </div>
            <div class="card-title" style="text-align:center">Yêu cầu hoàn tiền đơn #${order.id}</div>
            <div class="card-sub" style="text-align:center;margin-bottom:20px">Trạng thái yêu cầu của bạn</div>

            <c:if test="${existing.status eq 'PENDING'}">
                <div class="info-box">⏳ Yêu cầu của bạn đang được admin xem xét. Tiền sẽ được chuyển khoản trong <strong>1-3 ngày làm việc</strong>.</div>
            </c:if>
            <c:if test="${existing.status eq 'COMPLETED'}">
                <div class="info-box success">✅ Hoàn tiền thành công! Tiền đã được chuyển vào tài khoản của bạn.</div>
            </c:if>
            <c:if test="${existing.status eq 'REJECTED'}">
                <div class="info-box warning">❌ Yêu cầu bị từ chối. Lý do: <strong>${existing.rejectReason}</strong></div>
            </c:if>

            <div style="background:var(--bg-input);border-radius:12px;padding:14px 16px;margin-bottom:20px">
                <div class="status-row"><span class="k">Trạng thái</span><span class="v"><span class="badge ${existing.status}">${existing.status eq 'PENDING' ? '⏳ Đang chờ' : existing.status eq 'COMPLETED' ? '✅ Đã hoàn' : '❌ Từ chối'}</span></span></div>
                <div class="status-row"><span class="k">Số tiền hoàn</span><span class="v" style="color:#dc2626">₫<fmt:formatNumber value="${existing.amount}" pattern="#,##0"/></span></div>
                <div class="status-row"><span class="k">Ngân hàng</span><span class="v">${existing.bankName}</span></div>
                <div class="status-row"><span class="k">Số tài khoản</span><span class="v" style="font-family:monospace">${existing.bankAccountNumber}</span></div>
                <div class="status-row"><span class="k">Chủ tài khoản</span><span class="v">${existing.bankAccountHolder}</span></div>
                <div class="status-row"><span class="k">Ngày gửi</span><span class="v"><fmt:formatDate value="${existing.requestedAt}" pattern="dd/MM/yyyy HH:mm" type="both"/></span></div>
            </div>
            <a href="${pageContext.request.contextPath}/user/donhang" class="btn-back">← Quay lại đơn hàng</a>
        </c:when>

        <%-- Vừa gửi thành công --%>
        <c:when test="${param.success eq '1'}">
            <div class="done-icon">🎉</div>
            <div class="card-title" style="text-align:center">Gửi yêu cầu thành công!</div>
            <div class="card-sub" style="text-align:center;margin-bottom:20px">Admin sẽ xử lý và chuyển khoản trong 1-3 ngày làm việc</div>
            <div class="info-box success">✅ Yêu cầu hoàn tiền đơn <strong>#${order.id}</strong> đã được ghi nhận. Hãy kiểm tra tài khoản ngân hàng sau 1-3 ngày làm việc.</div>
            <a href="${pageContext.request.contextPath}/user/donhang" class="btn-back" style="display:block;text-align:center;margin-top:20px;font-size:14px;color:var(--primary);font-weight:700">← Quay lại đơn hàng</a>
        </c:when>

        <%-- Form nhập thông tin --%>
        <c:otherwise>
            <div class="card-title">↩️ Yêu cầu hoàn tiền</div>
            <div class="card-sub">Đơn #${order.id} đã bị hủy sau khi thanh toán</div>

            <div class="order-info">
                <div>
                    <div class="label">Số tiền sẽ được hoàn</div>
                    <div class="value">₫<fmt:formatNumber value="${order.totalPrice}" pattern="#,##0"/></div>
                </div>
                <div style="font-size:24px">💸</div>
            </div>

            <div class="info-box">
                💡 Điền đúng thông tin ngân hàng bên dưới. Admin sẽ chuyển khoản thủ công trong <strong>1-3 ngày làm việc</strong> sau khi xác nhận.
            </div>

            <c:if test="${not empty error}">
                <div class="alert-danger">⚠️ ${error}</div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/user/yeu-cau-hoan-tien">
                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="orderId" value="${order.id}"/>

                <div class="form-group">
                    <label>Ngân hàng *</label>
                    <input type="text" name="bankName" placeholder="VD: Vietcombank, BIDV, MB Bank..." required/>
                </div>
                <div class="form-group">
                    <label>Số tài khoản *</label>
                    <input type="text" name="bankAccountNumber" placeholder="Số tài khoản ngân hàng" required/>
                </div>
                <div class="form-group">
                    <label>Tên chủ tài khoản *</label>
                    <input type="text" name="bankAccountHolder" placeholder="VD: NGUYEN VAN A (viết hoa)" required/>
                </div>
                <div class="form-group">
                    <label>Ghi chú (không bắt buộc)</label>
                    <textarea name="note" placeholder="Thêm ghi chú nếu cần..."></textarea>
                </div>
                <button type="submit" class="btn-submit">📨 Gửi yêu cầu hoàn tiền</button>
            </form>
            <a href="${pageContext.request.contextPath}/user/donhang" class="btn-back">← Quay lại đơn hàng</a>
        </c:otherwise>
    </c:choose>

</div>
</body>
</html>
