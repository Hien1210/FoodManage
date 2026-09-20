<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="currentShop" value="${sessionScope.currentShop}" scope="request"/>

<%-- BẢO MẬT: KIỂM TRA QUYỀN SHOP (roleId = 2) --%>
<c:if test="${empty sessionScope.account || sessionScope.account.roleId != 2}">
    <c:redirect url="/dangnhap"/>
</c:if>

<!DOCTYPE html>
<html lang="vi" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin cửa hàng - ${not empty currentShop.shopName ? currentShop.shopName : 'Cửa hàng'}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-theme.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        .avatar-wrapper { position: relative; }
        .avatar-dropdown { display: none; position: fixed; background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: var(--dash-shadow-md); min-width: 220px; z-index: 500; }
        .avatar-dropdown.open { display: block; animation: pobFadeUp .18s ease both; }
        .dropdown-header { padding: 14px 16px; border-bottom: 1px solid var(--border-color); }
        .dropdown-header .d-name { font-size: 14px; font-weight: 700; color: var(--text-main); }
        .dropdown-header .d-email { font-size: 12px; color: var(--text-muted); margin-top: 2px; }
        .dropdown-header .d-role { display: inline-block; margin-top: 6px; font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 4px; background: var(--primary-light); color: var(--primary); border: 1px solid var(--primary); }
        .dropdown-body { padding: 6px 0 8px; }
        .dropdown-link { display: flex; align-items: center; gap: 10px; padding: 10px 16px; font-size: 13px; color: var(--text-muted); cursor: pointer; }
        .dropdown-link:hover { background: var(--bg-input); color: var(--text-main); }
        .dropdown-divider { height: 1px; background: var(--border-color); margin: 4px 0; }
        .dropdown-link.danger { color: var(--danger); }
        .dropdown-link.danger:hover { background: var(--danger-light); color: var(--danger); }

        /* Layout 2 cột: form chỉnh sửa + panel tổng quan */
        .page-grid { display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: start; }
        @media (max-width: 960px) { .page-grid { grid-template-columns: 1fr; } }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .form-full { grid-column: 1 / -1; }
        .secret-field { display: flex; gap: 8px; align-items: center; }
        .secret-field .form-control { flex: 1; }
        .btn-toggle-secret { flex-shrink: 0; width: 40px; height: 40px; border: 1px solid var(--border-color); border-radius: var(--radius-sm); background: var(--bg-input); cursor: pointer; font-size: 16px; }
        .btn-toggle-secret:hover { background: var(--border-color); }

        .logo-preview-wrap { display: flex; flex-direction: column; align-items: center; gap: 14px; margin-bottom: 20px; }
        .logo-preview { width: 120px; height: 120px; border-radius: var(--radius-lg); border: 2px dashed var(--border-color); background: var(--bg-input); display: flex; align-items: center; justify-content: center; overflow: hidden; font-size: 40px; color: var(--text-dim); }
        .logo-preview img { width: 100%; height: 100%; object-fit: cover; }

        .profile-info-row { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid var(--border-color); font-size: 13px; gap: 10px; }
        .profile-info-row:last-child { border-bottom: none; }
        .profile-info-row .lbl { color: var(--text-muted); font-weight: 600; }
        .profile-info-row .val { color: var(--text-main); font-weight: 700; text-align: right; }
        .reject-box { background: var(--danger-light); border: 1px solid var(--danger); border-radius: var(--radius-sm); padding: 12px 14px; margin-top: 14px; font-size: 12px; color: var(--danger); line-height: 1.6; }
        .reject-box strong { display: block; margin-bottom: 4px; }

        /* --- Bố cục hồ sơ cửa hàng theo bản Stitch: thẻ tổng quan + các nhóm cài đặt + thanh lưu dính --- */
        .shop-hero { display: flex; align-items: center; gap: 22px; padding: 22px 26px; animation: none; }
        .shop-hero .logo-preview { flex-shrink: 0; width: 104px; height: 104px; border-style: solid; }
        .shop-hero-info { min-width: 0; display: flex; flex-direction: column; gap: 8px; }
        .shop-hero-name { font-family: var(--font-display); font-size: 24px; font-weight: 700; color: var(--text-main); }
        .shop-hero-badges { display: flex; gap: 8px; flex-wrap: wrap; }
        .shop-hero-meta { display: flex; gap: 8px 18px; flex-wrap: wrap; font-size: 13px; color: var(--text-muted); }
        .shop-hero-meta span { display: inline-flex; align-items: center; gap: 5px; }
        .shop-hero-meta .material-symbols-outlined { font-size: 17px; color: var(--text-dim); }
        .profile-cols { display: grid; grid-template-columns: minmax(0, 1.25fr) minmax(0, 1fr); gap: 24px; align-items: start; }
        .profile-col { display: flex; flex-direction: column; gap: 24px; min-width: 0; }
        .profile-section { animation: none; }
        .profile-section .panel-header { flex-wrap: nowrap; }
        .ps-sub { font-size: 12px; color: var(--text-dim); text-align: right; }
        .tb-icon-sm { font-size: 22px; color: var(--primary); }
        .save-bar { position: sticky; bottom: 0; z-index: 5; margin-top: 24px; display: flex; align-items: center; justify-content: space-between; gap: 14px; flex-wrap: wrap; padding: 14px 20px; background: rgba(255, 255, 255, .92); backdrop-filter: blur(12px); border: 1px solid var(--border-color); border-radius: 18px; box-shadow: 0 -8px 28px -10px rgba(99, 44, 20, .18); }
        .save-bar-note { font-size: 12.5px; color: var(--text-muted); }
        .save-bar-actions { display: flex; gap: 10px; }
        @media (max-width: 1100px) { .profile-cols { grid-template-columns: 1fr; } }
        @media (max-width: 560px) { .shop-hero { flex-direction: column; align-items: flex-start; } .form-grid { grid-template-columns: 1fr; } .ps-sub { display: none; } }
    </style>
</head>
<body class="dash-body shop-theme">

<c:set var="shopActive" value="/shop/profile" scope="request"/>
<%@ include file="_shopSidebar.jspf" %>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1><span class="material-symbols-outlined tb-icon">storefront</span> Thông tin cửa hàng của tôi</h1>
        </div>
        <div class="topbar-right">
            <div class="avatar-wrapper" id="avatarWrapper">
                <div class="avatar-circle" id="avatarBtn">
                    <c:choose>
                        <c:when test="${not empty sessionScope.account.avatarUrl}">
                            <img src="${sessionScope.account.avatarUrl}" alt="avatar"/>
                        </c:when>
                        <c:otherwise>${fn:toUpperCase(fn:substring(sessionScope.account.userName, 0, 2))}</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </header>

    <div class="content">
        <c:if test="${param.success eq 'update'}">
            <div class="alert alert-success">✅ Cập nhật thông tin cửa hàng thành công!</div>
        </c:if>
        <c:if test="${not empty loi}">
            <div class="alert alert-danger">⚠️ <c:out value="${loi}"/></div>
        </c:if>

        <c:set var="formShop" value="${not empty shopForm ? shopForm : currentShop}"/>

        <%-- Thẻ tổng quan cửa hàng (thay cho panel "Tổng quan" bên phải trước đây) --%>
        <div class="panel shop-hero">
            <div class="logo-preview" id="logoPreview">
                <c:choose>
                    <c:when test="${not empty currentShop.shopLogo}">
                        <img src="<c:out value='${currentShop.shopLogo}'/>" alt="Logo" onerror="this.parentNode.innerHTML='🏪'">
                    </c:when>
                    <c:otherwise>🏪</c:otherwise>
                </c:choose>
            </div>
            <div class="shop-hero-info">
                <div class="shop-hero-name"><c:out value="${currentShop.shopName}"/></div>
                <div class="shop-hero-badges">
                    <c:choose>
                        <c:when test="${fn:toUpperCase(currentShop.status) == 'APPROVED' || fn:toUpperCase(currentShop.status) == 'ACCEPT' || fn:toUpperCase(currentShop.status) == 'ACTIVE'}">
                            <span class="badge badge-success">✅ Đã duyệt - Đang hoạt động</span>
                        </c:when>
                        <c:when test="${fn:toUpperCase(currentShop.status) == 'REJECT' || fn:toUpperCase(currentShop.status) == 'REJECTED'}">
                            <span class="badge badge-danger">✕ Bị từ chối</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge badge-warning">⏳ Chờ duyệt</span>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${currentShop.openNow}"><span class="badge badge-success"><span class="badge-dot"></span>Đang mở cửa</span></c:when>
                        <c:otherwise><span class="badge badge-neutral">Đang đóng cửa</span></c:otherwise>
                    </c:choose>
                </div>
                <div class="shop-hero-meta">
                    <span><span class="material-symbols-outlined">tag</span> Mã cửa hàng #${currentShop.id}</span>
                    <span><span class="material-symbols-outlined">call</span> <c:out value="${currentShop.shopPhone}" default="—"/></span>
                    <span><span class="material-symbols-outlined">person</span> <c:out value="${sessionScope.account.userName}"/></span>
                    <span><span class="material-symbols-outlined">schedule</span>
                        <c:choose>
                            <c:when test="${not empty currentShop.openTime && not empty currentShop.closeTime}">${currentShop.openTime} - ${currentShop.closeTime}</c:when>
                            <c:otherwise>Mở cả ngày</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <c:if test="${(fn:toUpperCase(currentShop.status) == 'REJECT' || fn:toUpperCase(currentShop.status) == 'REJECTED') && not empty currentShop.rejectionReason}">
                    <div class="reject-box">
                        <strong>⚠️ Lý do từ chối lần trước:</strong>
                        <c:out value="${currentShop.rejectionReason}"/>
                    </div>
                </c:if>
            </div>
        </div>

        <div class="profile-form-wrap">
            <form action="${pageContext.request.contextPath}/shop/profile" method="post" id="shopProfileForm">
    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="${currentShop.id}">

                <div class="profile-cols">
                    <div class="profile-col">
                <section class="panel profile-section">
                    <div class="panel-header"><div class="panel-title"><span class="material-symbols-outlined tb-icon-sm">storefront</span> Hồ sơ thương hiệu</div><span class="ps-sub">Hiển thị cho khách trên ứng dụng</span></div>
                    <div class="panel-body">
                        <div class="form-grid">
                            <div class="form-group form-full">
                                <label class="form-label" for="shopName">Tên cửa hàng <span class="required">*</span></label>
                                <input type="text" id="shopName" name="shopName" class="form-control"
                                       value="${fn:escapeXml(formShop.shopName)}"
                                       placeholder="Ví dụ: Quán Cơm Tấm Cô Ba..."
                                       required autofocus>
                            </div>
                            <div class="form-group form-full">
                                <label class="form-label" for="shopDescription">Mô tả cửa hàng</label>
                                <textarea id="shopDescription" name="shopDescription" class="form-control form-textarea"
                                          placeholder="Giới thiệu ngắn về cửa hàng của bạn..."><c:out value="${formShop.shopDescription}"/></textarea>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="shopPhone">Số điện thoại <span class="required">*</span></label>
                                <input type="text" id="shopPhone" name="shopPhone" class="form-control"
                                       value="${fn:escapeXml(formShop.shopPhone)}"
                                       placeholder="09xx xxx xxx"
                                       required>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="shopLogo">Ảnh Logo</label>
                                <input type="text" id="shopLogo" name="shopLogo" class="form-control"
                                       value="${fn:escapeXml(formShop.shopLogo)}"
                                       placeholder="https://..."
                                       oninput="previewLogo(this.value)">
                                <div style="margin-top:8px;display:flex;align-items:center;gap:10px;">
                                    <input type="file" id="shopLogoFileInput" accept="image/*" style="display:none;">
                                    <button type="button" class="btn btn-ghost" onclick="document.getElementById('shopLogoFileInput').click();">📤 Tải ảnh lên</button>
                                    <span id="shopLogoUploadStatus" style="font-size:12px;color:var(--text-muted);"></span>
                                </div>
                                <div class="form-hint">Tải ảnh lên (lưu trên Cloudinary) hoặc dán trực tiếp đường dẫn ảnh logo.</div>
                            </div>
                        </div>
                    </div>
                </section>
                <section class="panel profile-section">
                    <div class="panel-header"><div class="panel-title"><span class="material-symbols-outlined tb-icon-sm">location_on</span> Địa chỉ &amp; vị trí</div><span class="ps-sub">Dùng để tính khoảng cách và phí ship</span></div>
                    <div class="panel-body">
                        <div class="form-grid">
                            <div class="form-group form-full">
                                <label class="form-label" for="shopAddress">Địa chỉ cửa hàng <span class="required">*</span></label>
                                <input type="text" id="shopAddress" name="shopAddress" class="form-control"
                                       value="${fn:escapeXml(formShop.shopAddress)}"
                                       placeholder="Số nhà, đường, quận/huyện, tỉnh/thành..."
                                       required>
                            </div>
                            <div class="form-group form-full">
                                <label class="form-label">Vị trí cửa hàng trên bản đồ <span class="required">*</span></label>
                                <button type="button" class="btn btn-ghost" id="shopLocationToggleBtn"
                                        style="display:inline-flex;align-items:center;gap:6px;width:100%;justify-content:center;padding:11px;border:1.5px dashed var(--border-color);border-radius:10px;color:var(--primary);font-weight:700;margin-bottom:8px;cursor:pointer;"
                                        data-preset-lat="${not empty formShop.locationX ? formShop.locationX : ''}"
                                        data-preset-lng="${not empty formShop.locationY ? formShop.locationY : ''}">
                                    📍 ${not empty formShop.locationX ? 'Đã ghim vị trí (Bấm để mở bản đồ)' : 'Chọn vị trí cửa hàng trên bản đồ'}
                                </button>
                                <div id="shopLocationMapWrap" style="display:${not empty formShop.locationX ? 'block' : 'none'};margin-bottom:10px;">
                                    <div style="display:flex;gap:8px;margin-bottom:8px;">
                                        <input type="text" id="shopLocationSearchInput" class="form-control" placeholder="Tìm địa chỉ trên bản đồ..." style="flex:1;">
                                        <button type="button" id="shopLocationSearchBtn" class="btn btn-ghost" style="border:1px solid var(--border-color);">Tìm kiếm</button>
                                        <button type="button" id="shopCurrentLocationBtn" class="btn btn-ghost" style="border:1px solid var(--primary);color:var(--primary);font-weight:700;white-space:nowrap;">📍 Vị trí hiện tại</button>
                                    </div>
                                    <div id="shopLocationMap" style="height:250px;border-radius:10px;border:1.5px solid var(--border-color);overflow:hidden;"></div>
                                </div>
                                <input type="hidden" name="shopLocationX" id="shopLocationXInput" value="${formShop.locationX}">
                                <input type="hidden" name="shopLocationY" id="shopLocationYInput" value="${formShop.locationY}">
                                <div class="form-hint" id="shopLocationHint">
                                    <c:choose>
                                        <c:when test="${not empty formShop.locationX}">
                                            ✅ Tọa độ cửa hàng: <strong>${formShop.locationX}, ${formShop.locationY}</strong>. Vị trí này dùng để tính khoảng cách &amp; phí ship cho khách hàng (5.000đ/km).
                                        </c:when>
                                        <c:otherwise>
                                            ⚠️ Cửa hàng chưa ghim vị trí trên bản đồ. Vui lòng chọn vị trí để khách hàng có thể tính khoảng cách và phí ship khi đặt món.
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                    </div>
                    <div class="profile-col">
                <section class="panel profile-section">
                    <div class="panel-header"><div class="panel-title"><span class="material-symbols-outlined tb-icon-sm">schedule</span> Giờ hoạt động</div><span class="ps-sub">Ngoài khung giờ này khách không đặt được món</span></div>
                    <div class="panel-body">
                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label" for="openTime">Giờ mở cửa</label>
                                <input type="time" id="openTime" name="openTime" class="form-control"
                                       value="${formShop.openTime}">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="closeTime">Giờ đóng cửa</label>
                                <input type="time" id="closeTime" name="closeTime" class="form-control"
                                       value="${formShop.closeTime}">
                                <div class="form-hint">Để trống cả 2 ô nếu cửa hàng mở cửa cả ngày. Hệ thống sẽ tự động chặn khách đặt hàng ngoài khung giờ này.</div>
                            </div>
                        </div>
                    </div>
                </section>
                <section class="panel profile-section">
                    <div class="panel-header"><div class="panel-title"><span class="material-symbols-outlined tb-icon-sm">account_balance</span> Ngân hàng nhận tiền</div><span class="ps-sub">Tạo QR thanh toán &amp; nhận tiền rút từ ví</span></div>
                    <div class="panel-body">
                        <div class="form-grid">
                            <div class="form-group form-full" id="bankInfoSection">
                                <label class="form-label" for="bankCode">Ngân hàng nhận tiền (QR)</label>
                                <select id="bankCode" name="bankCode" class="form-control">
                                    <option value="">-- Chọn ngân hàng --</option>
                                    <option value="970436" ${formShop.bankCode == '970436' ? 'selected' : ''}>Vietcombank</option>
                                    <option value="970422" ${formShop.bankCode == '970422' ? 'selected' : ''}>MB Bank</option>
                                    <option value="970432" ${formShop.bankCode == '970432' ? 'selected' : ''}>VPBank</option>
                                    <option value="970407" ${formShop.bankCode == '970407' ? 'selected' : ''}>Techcombank</option>
                                    <option value="970416" ${formShop.bankCode == '970416' ? 'selected' : ''}>ACB</option>
                                    <option value="970418" ${formShop.bankCode == '970418' ? 'selected' : ''}>BIDV</option>
                                    <option value="970415" ${formShop.bankCode == '970415' ? 'selected' : ''}>VietinBank</option>
                                    <option value="970405" ${formShop.bankCode == '970405' ? 'selected' : ''}>Agribank</option>
                                </select>
                                <div class="form-hint">Dùng để tạo mã QR chuyển khoản khi khách chọn thanh toán QR ở Bấm Bill, và cũng là tài khoản nhận tiền khi rút tiền ở Ví tiền Shop.</div>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="bankAccountNumber">Số tài khoản</label>
                                <input type="text" id="bankAccountNumber" name="bankAccountNumber" class="form-control"
                                       value="${fn:escapeXml(formShop.bankAccountNumber)}"
                                       placeholder="Số tài khoản ngân hàng...">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="bankAccountName">Tên chủ tài khoản</label>
                                <input type="text" id="bankAccountName" name="bankAccountName" class="form-control"
                                       value="${fn:escapeXml(formShop.bankAccountName)}"
                                       placeholder="VD: NGUYEN VAN A (không dấu, in hoa)...">
                            </div>
                        </div>
                    </div>
                </section>
                <section class="panel profile-section">
                    <div class="panel-header"><div class="panel-title"><span class="material-symbols-outlined tb-icon-sm">key</span> Cổng thanh toán PayOS</div><span class="ps-sub">Khóa API — không chia sẻ cho người khác</span></div>
                    <div class="panel-body">
                        <div class="form-grid">
                            <div class="form-group form-full">
                                <label class="form-label" for="clientKey">Client ID</label>
                                <div class="secret-field">
                                    <input type="password" id="clientKey" name="clientKey" class="form-control"
                                           value="${fn:escapeXml(formShop.clientKey)}"
                                           placeholder="Client ID dùng cho cổng thanh toán..." autocomplete="off">
                                    <button type="button" class="btn-toggle-secret" onclick="toggleSecret('clientKey', this)">👁</button>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="apiKey">API Key</label>
                                <div class="secret-field">
                                    <input type="password" id="apiKey" name="apiKey" class="form-control"
                                           value="${fn:escapeXml(formShop.apiKey)}"
                                           placeholder="API Key..." autocomplete="off">
                                    <button type="button" class="btn-toggle-secret" onclick="toggleSecret('apiKey', this)">👁</button>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="checkSumKey">Checksum Key</label>
                                <div class="secret-field">
                                    <input type="password" id="checkSumKey" name="checkSumKey" class="form-control"
                                           value="${fn:escapeXml(formShop.checkSumKey)}"
                                           placeholder="Checksum Key..." autocomplete="off">
                                    <button type="button" class="btn-toggle-secret" onclick="toggleSecret('checkSumKey', this)">👁</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                    </div>
                </div>

                <div class="save-bar">
                    <span class="save-bar-note">Thay đổi chỉ được áp dụng sau khi bạn bấm lưu.</span>
                    <div class="save-bar-actions">
                        <a href="${pageContext.request.contextPath}/shop" class="btn btn-ghost">Hủy</a>
                        <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</main>

<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${sessionScope.account.userName}</div>
        <div class="d-email">${sessionScope.account.email}</div>
        <span class="d-role">🏪 Shop Owner</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/shop/ho-so" class="dropdown-link">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/shop/doi-mat-khau" class="dropdown-link">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script>
    function previewLogo(url) {
        const wrap = document.getElementById('logoPreview');
        if (!url) { wrap.innerHTML = '🏪'; return; }
        wrap.innerHTML = '<img src="' + url + '" alt="Logo" onerror="this.parentNode.innerHTML=\'🏪\'">';
    }

    // Cloudinary unsigned upload cho logo cửa hàng
    (function() {
        var CLOUD_NAME = 'jcnsb47f';
        var UPLOAD_PRESET = 'avatar_preset';
        var fileInput = document.getElementById('shopLogoFileInput');
        var status = document.getElementById('shopLogoUploadStatus');
        var urlInput = document.getElementById('shopLogo');
        if (!fileInput) return;

        fileInput.addEventListener('change', function(e) {
            var file = e.target.files[0];
            if (!file) return;
            if (file.size > 2 * 1024 * 1024) {
                status.textContent = '❌ Ảnh tối đa 2MB.';
                return;
            }
            status.textContent = '⏳ Đang tải lên...';

            var formData = new FormData();
            formData.append('file', file);
            formData.append('upload_preset', UPLOAD_PRESET);
            formData.append('folder', 'shop-logos');

            fetch('https://api.cloudinary.com/v1_1/' + CLOUD_NAME + '/image/upload', {
                method: 'POST',
                body: formData
            })
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (!data.secure_url) { status.textContent = '❌ Upload thất bại.'; return; }
                    urlInput.value = data.secure_url;
                    previewLogo(data.secure_url);
                    status.textContent = '✅ Tải lên thành công! Nhấn "Lưu thay đổi" để áp dụng.';
                })
                .catch(function() { status.textContent = '❌ Lỗi kết nối.'; });
        });
    })();

    function toggleSecret(inputId, btn) {
        const input = document.getElementById(inputId);
        const hidden = input.type === 'password';
        input.type = hidden ? 'text' : 'password';
        btn.textContent = hidden ? '🙈' : '👁';
    }

    document.querySelectorAll('.alert').forEach(el => {
        setTimeout(() => {
            el.style.transition = 'opacity .5s';
            el.style.opacity = '0';
            setTimeout(() => el.remove(), 500);
        }, 4000);
    });

    document.addEventListener('DOMContentLoaded', function() {
        var avatarBtn = document.getElementById('avatarBtn');
        var avatarDropdown = document.getElementById('avatarDropdown');
        if (avatarBtn && avatarDropdown) {
            avatarBtn.addEventListener('click', function(e) {
                e.stopPropagation();
                var rect = avatarBtn.getBoundingClientRect();
                avatarDropdown.style.top = (rect.bottom + 10) + 'px';
                avatarDropdown.style.right = (window.innerWidth - rect.right) + 'px';
                avatarDropdown.classList.toggle('open');
            });
            avatarDropdown.addEventListener('click', function(e) { e.stopPropagation(); });
            document.addEventListener('click', function() { avatarDropdown.classList.remove('open'); });
        }

        /* ── LEAFLET MAP PICKER CHO SHOP PROFILE ── */
        function initShopLocationMap(presetLat, presetLng) {
            var mapContainer = document.getElementById('shopLocationMap');
            if (!mapContainer) return;
            if (mapContainer.dataset.initialized === 'true') {
                var existingMap = mapContainer._leafletMap;
                if (existingMap) setTimeout(function () { existingMap.invalidateSize(); }, 50);
                return;
            }
            mapContainer.dataset.initialized = 'true';

            var defaultLat = 21.0285, defaultLng = 105.8542;
            var startLat = (presetLat && !isNaN(presetLat)) ? parseFloat(presetLat) : defaultLat;
            var startLng = (presetLng && !isNaN(presetLng)) ? parseFloat(presetLng) : defaultLng;

            var map = L.map('shopLocationMap').setView([startLat, startLng], 15);
            mapContainer._leafletMap = map;

            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; OpenStreetMap contributors',
                maxZoom: 19
            }).addTo(map);

            var marker = null;
            var reverseGeocodeTimer = null;

            function updateCoords(lat, lng) {
                document.getElementById('shopLocationXInput').value = lat;
                document.getElementById('shopLocationYInput').value = lng;
                var hint = document.getElementById('shopLocationHint');
                if (hint) {
                    hint.innerHTML = '✅ Tọa độ cửa hàng: <strong>' + (Math.round(lat * 100000) / 100000) + ', ' + (Math.round(lng * 100000) / 100000) + '</strong>. Vị trí này dùng để tính khoảng cách & phí ship (5.000đ/km).';
                }
            }

            function reverseGeocode(lat, lng) {
                fetch('https://nominatim.openstreetmap.org/reverse?format=json&lat=' + lat + '&lon=' + lng)
                    .then(function (res) { return res.json(); })
                    .then(function (data) {
                        if (data && data.display_name) {
                            var addrInput = document.getElementById('shopAddress');
                            if (addrInput && !addrInput.value.trim()) {
                                addrInput.value = data.display_name;
                            }
                        }
                    })
                    .catch(function () { console.warn('Không thể lấy địa chỉ tự động'); });
            }

            delete L.Icon.Default.prototype._getIconUrl;
            L.Icon.Default.mergeOptions({
                iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
                iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
                shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png'
            });

            var shopPinIcon = L.divIcon({
                className: 'custom-shop-pin',
                html: '<div style="font-size:32px;line-height:32px;text-align:center;filter:drop-shadow(0 3px 6px rgba(0,0,0,0.3));cursor:grab;">🏪</div>',
                iconSize: [32, 32],
                iconAnchor: [16, 30]
            });

            function placeMarker(lat, lng, doReverseGeocode) {
                if (marker) {
                    marker.setLatLng([lat, lng]);
                } else {
                    marker = L.marker([lat, lng], { icon: shopPinIcon, draggable: true }).addTo(map);
                    marker.on('dragend', function () {
                        var pos = marker.getLatLng();
                        updateCoords(pos.lat, pos.lng);
                        clearTimeout(reverseGeocodeTimer);
                        reverseGeocodeTimer = setTimeout(function () { reverseGeocode(pos.lat, pos.lng); }, 500);
                    });
                }
                updateCoords(lat, lng);
                if (doReverseGeocode) reverseGeocode(lat, lng);
            }

            map.on('click', function (e) {
                placeMarker(e.latlng.lat, e.latlng.lng, true);
            });

            if (presetLat && presetLng) {
                placeMarker(startLat, startLng, false);
            } else if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(
                    function (pos) {
                        map.setView([pos.coords.latitude, pos.coords.longitude], 15);
                        placeMarker(pos.coords.latitude, pos.coords.longitude, true);
                    },
                    function () { /* denied - keep default */ },
                    { timeout: 5000 }
                );
            }

            var searchBtn = document.getElementById('shopLocationSearchBtn');
            if (searchBtn) {
                searchBtn.addEventListener('click', function () {
                    var query = document.getElementById('shopLocationSearchInput').value.trim();
                    if (!query) return;
                    fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(query) + '&limit=1')
                        .then(function (res) { return res.json(); })
                        .then(function (results) {
                            if (results && results.length > 0) {
                                var lat = parseFloat(results[0].lat);
                                var lng = parseFloat(results[0].lon);
                                map.setView([lat, lng], 16);
                                placeMarker(lat, lng, true);
                            } else {
                                alert('Không tìm thấy địa chỉ, vui lòng thử lại');
                            }
                        })
                        .catch(function () { alert('Không tìm được địa chỉ, vui lòng thử lại'); });
                });
            }

            var currentLocBtn = document.getElementById('shopCurrentLocationBtn');
            if (currentLocBtn) {
                currentLocBtn.addEventListener('click', function () {
                    if (!navigator.geolocation) {
                        alert('Trình duyệt của bạn không hỗ trợ lấy vị trí GPS.');
                        return;
                    }
                    var originalText = currentLocBtn.innerHTML;
                    currentLocBtn.disabled = true;
                    currentLocBtn.innerHTML = '⏳ Đang định vị...';
                    navigator.geolocation.getCurrentPosition(
                        function (pos) {
                            currentLocBtn.disabled = false;
                            currentLocBtn.innerHTML = originalText;
                            var lat = pos.coords.latitude;
                            var lng = pos.coords.longitude;
                            map.setView([lat, lng], 16);
                            placeMarker(lat, lng, true);
                        },
                        function (err) {
                            currentLocBtn.disabled = false;
                            currentLocBtn.innerHTML = originalText;
                            alert('Không thể lấy vị trí hiện tại. Vui lòng bật GPS và cho phép quyền vị trí trên trình duyệt.');
                        },
                        { enableHighAccuracy: true, timeout: 10000 }
                    );
                });
            }
        }

        var toggleBtn = document.getElementById('shopLocationToggleBtn');
        var wrap = document.getElementById('shopLocationMapWrap');
        if (toggleBtn && wrap) {
            var presetLat = toggleBtn.dataset.presetLat;
            var presetLng = toggleBtn.dataset.presetLng;
            if (presetLat && presetLng) {
                initShopLocationMap(presetLat, presetLng);
            }
            toggleBtn.addEventListener('click', function() {
                wrap.style.display = 'block';
                initShopLocationMap(toggleBtn.dataset.presetLat, toggleBtn.dataset.presetLng);
            });
        }

        var form = document.getElementById('shopProfileForm');
        if (form) {
            form.addEventListener('submit', function(e) {
                var x = document.getElementById('shopLocationXInput').value;
                var y = document.getElementById('shopLocationYInput').value;
                if (!x || !y) {
                    e.preventDefault();
                    pobConfirm('⚠️ Bạn chưa chọn vị trí cửa hàng trên bản đồ. Khách hàng sẽ không thể đặt hàng từ cửa hàng của bạn. Bạn có chắc chắn muốn lưu mà chưa ghim vị trí không?').then(function(ok) {
                        if (!ok) {
                            if (toggleBtn) toggleBtn.click();
                        } else {
                            form.submit();
                        }
                    });
                }
            });
        }
    });
</script>
</body>
</html>
