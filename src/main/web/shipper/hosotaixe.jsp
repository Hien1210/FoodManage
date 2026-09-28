<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="_csrf" content="${sessionScope.csrfToken}">
    <script>!function(){var t=localStorage.getItem("pob-dashboard-theme")||"light";document.documentElement.setAttribute("data-theme",t)}()</script>
    <title>Hồ sơ tài xế - POB Shipper</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
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

        .online-toggle-btn { width: 100%; padding: 12px 16px; border-radius: var(--radius-sm); border: none; cursor: pointer; display: flex; align-items: center; gap: 10px; font-size: 13px; font-weight: 700; }
        .online-toggle-btn.is-online { background: var(--success-light); color: var(--success-dark); border: 1.5px solid var(--success); }
        .online-toggle-btn.is-offline { background: var(--danger-light); color: var(--danger); border: 1.5px solid var(--danger); }
        .toggle-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
        .toggle-dot.online { background: var(--success); animation: pobBlink 1.5s infinite; }
        .toggle-dot.offline { background: var(--danger); }

        /* Avatar hero */
        .profile-hero { background: var(--bg-panel); border: 1px solid var(--border-color); border-radius: var(--radius-lg); padding: 28px; display: flex; align-items: center; gap: 24px; box-shadow: var(--dash-shadow-sm); flex-wrap: wrap; }
        .avatar-hero { width: 88px; height: 88px; border-radius: 50%; object-fit: cover; border: 3px solid var(--primary); background: var(--bg-input); display: flex; align-items: center; justify-content: center; font-size: 36px; font-weight: 800; color: var(--primary); flex-shrink: 0; }
        .avatar-hero img { width: 88px; height: 88px; border-radius: 50%; object-fit: cover; }
        .hero-info h2 { font-size: 20px; font-weight: 800; margin-bottom: 4px; color: var(--text-main); }
        .hero-info .sub { font-size: 13px; color: var(--text-dim); }
        .online-pill { display: inline-flex; align-items: center; gap: 5px; padding: 3px 10px; border-radius: var(--radius-pill); font-size: 11px; font-weight: 700; margin-top: 6px; }
        .online-pill.online { background: var(--success-light); color: var(--success-dark); }
        .online-pill.offline { background: var(--danger-light); color: var(--danger); }

        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .form-grid .form-group.full { grid-column: 1/-1; }
        @media (max-width: 768px) { .form-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body class="dash-body">

<div class="sidebar-backdrop" id="sidebarBackdrop"></div>
<aside class="sidebar" id="sidebar">
    <div class="sidebar-brand">
        <div class="logo-mark-dash">🛵</div>
        <div class="brand-text">
            <span class="brand-title">POB SHIPPER</span>
            <c:choose>
                <c:when test="${sessionScope.account.online}">
                    <span class="brand-subtitle" style="color:var(--success);">● Đang hoạt động</span>
                </c:when>
                <c:otherwise>
                    <span class="brand-subtitle" style="color:var(--danger);">● Ngoại tuyến</span>
                </c:otherwise>
            </c:choose>
        </div>
        <button type="button" class="sidebar-toggle-btn" id="sidebarToggleBtn" onclick="pobToggleSidebar()" title="Thu gọn / mở rộng menu">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
        </button>
    </div>
    <div class="menu">
        <div class="menu-title">Công việc</div>
        <a href="${pageContext.request.contextPath}/shipper/donhang" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📋</span><span class="mi-label"> Đơn hàng nhận</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/nhan-don" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📥</span><span class="mi-label"> Nhận đơn mới</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/dashboard" class="menu-item">
            <span class="mi-left"><span class="mi-icon">📊</span><span class="mi-label"> Dashboard</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/thongbao" class="menu-item">
            <span class="mi-left"><span class="mi-icon">🔔</span><span class="mi-label"> Thông báo</span></span>
        </a>

        <div class="menu-title">Tài khoản</div>
        <a href="${pageContext.request.contextPath}/shipper/profile" class="menu-item active">
            <span class="mi-left"><span class="mi-icon">🚙</span><span class="mi-label"> Hồ sơ tài xế</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/danh-gia" class="menu-item">
            <span class="mi-left"><span class="mi-icon">⭐</span><span class="mi-label"> Đánh giá &amp; Báo cáo</span></span>
        </a>
        <a href="${pageContext.request.contextPath}/shipper/vi-tien" class="menu-item">
            <span class="mi-left"><span class="mi-icon">💰</span><span class="mi-label"> Ví tiền</span></span>
        </a>
    </div>
    <div class="sidebar-foot">
        <form action="${pageContext.request.contextPath}/shipper/status" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <c:choose>
                <c:when test="${sessionScope.account.online}">
                    <button type="submit" class="online-toggle-btn is-online"
                            onclick="return confirm('Tắt chế độ Online? Bạn sẽ không nhận đơn mới.')">
                        <span class="toggle-dot online"></span><span class="sf-label">Đang Online — Nhấn để Offline
                    </span></button>
                </c:when>
                <c:otherwise>
                    <button type="submit" class="online-toggle-btn is-offline">
                        <span class="toggle-dot offline"></span><span class="sf-label">Đang Offline — Nhấn để Online
                    </span></button>
                </c:otherwise>
            </c:choose>
        </form>
    </div>
</aside>

<main class="main">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:10px;">
            <button type="button" class="menu-toggle-btn" onclick="pobToggleSidebar()">☰</button>
            <h1>👤 Hồ sơ tài xế</h1>
        </div>
        <div class="topbar-right">
            <button type="button" class="theme-toggle" id="themeToggleBtn" onclick="pobToggleTheme()" title="Chuyển đổi giao diện"><span data-theme-icon>🌙</span></button>
            <div class="avatar-wrapper" id="avatarWrapper">
                <div class="avatar-circle" id="avatarBtn">
                    <c:choose>
                        <c:when test="${not empty sessionScope.account.avatarUrl}">
                            <img src="${fn:escapeXml(sessionScope.account.avatarUrl)}" alt="avatar"/>
                        </c:when>
                        <c:otherwise>${fn:escapeXml(fn:toUpperCase(fn:substring(sessionScope.account.userName, 0, 2)))}</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </header>

    <div class="content">

        <c:if test="${not empty param.success}">
            <div class="alert alert-success">✅ <c:out value="${param.success}"/></div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger">⚠️ <c:out value="${param.error}"/></div>
        </c:if>

        <div class="profile-hero">
            <div class="avatar-hero">
                <c:choose>
                    <c:when test="${not empty sessionScope.account.avatarUrl}">
                        <img src="${fn:escapeXml(sessionScope.account.avatarUrl)}" alt="Avatar"
                             onerror="this.style.display='none';this.parentNode.innerText='${fn:escapeXml(fn:replace(fn:replace(fn:toUpperCase(fn:substring(sessionScope.account.fullName,0,1)),'\\','\\\\'),"'","\\'"))}'"/>
                    </c:when>
                    <c:otherwise>
                        ${fn:escapeXml(fn:toUpperCase(fn:substring(sessionScope.account.fullName,0,1)))}
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="hero-info">
                <h2>${fn:escapeXml(sessionScope.account.fullName)}</h2>
                <div class="sub">@${fn:escapeXml(sessionScope.account.userName)} · ${fn:escapeXml(sessionScope.account.email)}</div>
                <div class="sub" style="margin-top:2px;">📞 ${fn:escapeXml(sessionScope.account.phone)}</div>
                <c:choose>
                    <c:when test="${sessionScope.account.online}">
                        <span class="online-pill online">● Đang Online</span>
                    </c:when>
                    <c:otherwise>
                        <span class="online-pill offline">● Ngoại tuyến</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="panel">
            <div class="panel-header"><div class="panel-title">📝 Thông tin cá nhân</div></div>
            <div class="panel-body">
                <form action="${pageContext.request.contextPath}/shipper/profile" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="updateInfo"/>
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Họ và tên <span class="required">*</span></label>
                            <input type="text" class="form-control" name="fullName" value="${fn:escapeXml(sessionScope.account.fullName)}" required placeholder="Nguyễn Văn A"/>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Số điện thoại</label>
                            <input type="text" class="form-control" name="phone" value="${fn:escapeXml(sessionScope.account.phone)}" placeholder="0901234567"/>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Email <span class="required">*</span></label>
                            <input type="email" class="form-control" name="email" value="${fn:escapeXml(sessionScope.account.email)}" required placeholder="you@example.com"/>
                        </div>
                        <div class="form-group">
                            <label class="form-label">URL ảnh đại diện</label>
                            <input type="url" class="form-control" name="avatarUrl" value="${fn:escapeXml(sessionScope.account.avatarUrl)}" placeholder="https://..."/>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary" style="margin-top:16px;">💾 Lưu thông tin</button>
                </form>
            </div>
        </div>

        <div class="panel">
            <div class="panel-header">
                <div class="panel-title">🪪 Giấy tờ nghề nghiệp</div>
                <c:choose>
                    <c:when test="${profile.verificationStatus == 'APPROVED'}">
                        <span class="badge badge-success">✅ Đã duyệt</span>
                    </c:when>
                    <c:when test="${profile.verificationStatus == 'REJECTED'}">
                        <span class="badge badge-danger">❌ Bị từ chối</span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge badge-warning">⏳ Chờ duyệt</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="panel-body">
                <c:if test="${profile.verificationStatus == 'REJECTED' and not empty profile.rejectionReason}">
                    <div class="alert alert-danger" style="margin-bottom:16px;">⚠️ Lý do từ chối: <c:out value="${profile.rejectionReason}"/></div>
                </c:if>
                <c:if test="${not sessionScope.account.online}">
                    <div class="alert alert-warning" style="margin-bottom:16px;">⚠️ Bạn đang <strong>Ngoại tuyến</strong>. Vui lòng bật <strong>Online</strong> (góc dưới sidebar) trước khi upload ảnh CCCD/GPLX, để Super Admin biết chính xác thời điểm bạn nộp giấy tờ.</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/shipper/profile" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="updateVehicle"/>
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Số CCCD / CMND</label>
                            <input type="text" class="form-control" name="cccd" value="${fn:escapeXml(profile.cccd)}" placeholder="0123456789" maxlength="20"/>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Số giấy phép lái xe (GPLX)</label>
                            <input type="text" class="form-control" name="licenseNumber" value="${fn:escapeXml(profile.licenseNumber)}" placeholder="010000012345" maxlength="30"/>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Ảnh CCCD / CMND - Mặt trước</label>
                            <div class="doc-upload-box">
                                <img id="idCardFrontPreview" src="${fn:escapeXml(profile.idCardFrontUrl)}"
                                     style="${fn:escapeXml(empty profile.idCardFrontUrl ? 'display:none;' : '')}width:100%;max-width:260px;border-radius:8px;border:1px solid var(--border-color);margin-bottom:8px;"/>
                                <button type="button" id="idCardFrontDeleteBtn" class="btn btn-danger-outline btn-sm"
                                        style="${fn:escapeXml(empty profile.idCardFrontUrl ? 'display:none;' : 'display:block;')}width:fit-content;margin-bottom:10px;"
                                        onclick="deleteDocImage('/shipper/upload-id-card','front','idCardFrontPreview','idCardFrontDeleteBtn','idCardFrontMsg')">🗑️ Xóa ảnh</button>
                                <input type="file" id="idCardFrontFileInput" accept="image/*" ${sessionScope.account.online ? '' : 'disabled'} style="display:block;"/>
                                <div class="upload-progress" id="idCardFrontProgress" style="display:none;height:6px;background:var(--bg-input);border-radius:4px;margin-top:8px;overflow:hidden;">
                                    <div id="idCardFrontBar" style="height:100%;width:0;background:var(--primary);transition:width .2s;"></div>
                                </div>
                                <div id="idCardFrontMsg" style="font-size:12px;margin-top:6px;"></div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Ảnh GPLX - Mặt trước</label>
                            <div class="doc-upload-box">
                                <img id="licenseFrontPreview" src="${fn:escapeXml(profile.licenseFrontUrl)}"
                                     style="${fn:escapeXml(empty profile.licenseFrontUrl ? 'display:none;' : '')}width:100%;max-width:260px;border-radius:8px;border:1px solid var(--border-color);margin-bottom:8px;"/>
                                <button type="button" id="licenseFrontDeleteBtn" class="btn btn-danger-outline btn-sm"
                                        style="${fn:escapeXml(empty profile.licenseFrontUrl ? 'display:none;' : 'display:block;')}width:fit-content;margin-bottom:10px;"
                                        onclick="deleteDocImage('/shipper/upload-license','front','licenseFrontPreview','licenseFrontDeleteBtn','licenseFrontMsg')">🗑️ Xóa ảnh</button>
                                <input type="file" id="licenseFrontFileInput" accept="image/*" ${sessionScope.account.online ? '' : 'disabled'} style="display:block;"/>
                                <div class="upload-progress" id="licenseFrontProgress" style="display:none;height:6px;background:var(--bg-input);border-radius:4px;margin-top:8px;overflow:hidden;">
                                    <div id="licenseFrontBar" style="height:100%;width:0;background:var(--primary);transition:width .2s;"></div>
                                </div>
                                <div id="licenseFrontMsg" style="font-size:12px;margin-top:6px;"></div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Ảnh CCCD / CMND - Mặt sau</label>
                            <div class="doc-upload-box">
                                <img id="idCardBackPreview" src="${fn:escapeXml(profile.idCardBackUrl)}"
                                     style="${fn:escapeXml(empty profile.idCardBackUrl ? 'display:none;' : '')}width:100%;max-width:260px;border-radius:8px;border:1px solid var(--border-color);margin-bottom:8px;"/>
                                <button type="button" id="idCardBackDeleteBtn" class="btn btn-danger-outline btn-sm"
                                        style="${fn:escapeXml(empty profile.idCardBackUrl ? 'display:none;' : 'display:block;')}width:fit-content;margin-bottom:10px;"
                                        onclick="deleteDocImage('/shipper/upload-id-card','back','idCardBackPreview','idCardBackDeleteBtn','idCardBackMsg')">🗑️ Xóa ảnh</button>
                                <input type="file" id="idCardBackFileInput" accept="image/*" ${sessionScope.account.online ? '' : 'disabled'} style="display:block;"/>
                                <div class="upload-progress" id="idCardBackProgress" style="display:none;height:6px;background:var(--bg-input);border-radius:4px;margin-top:8px;overflow:hidden;">
                                    <div id="idCardBackBar" style="height:100%;width:0;background:var(--primary);transition:width .2s;"></div>
                                </div>
                                <div id="idCardBackMsg" style="font-size:12px;margin-top:6px;"></div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Ảnh GPLX - Mặt sau</label>
                            <div class="doc-upload-box">
                                <img id="licenseBackPreview" src="${fn:escapeXml(profile.licenseBackUrl)}"
                                     style="${fn:escapeXml(empty profile.licenseBackUrl ? 'display:none;' : '')}width:100%;max-width:260px;border-radius:8px;border:1px solid var(--border-color);margin-bottom:8px;"/>
                                <button type="button" id="licenseBackDeleteBtn" class="btn btn-danger-outline btn-sm"
                                        style="${fn:escapeXml(empty profile.licenseBackUrl ? 'display:none;' : 'display:block;')}width:fit-content;margin-bottom:10px;"
                                        onclick="deleteDocImage('/shipper/upload-license','back','licenseBackPreview','licenseBackDeleteBtn','licenseBackMsg')">🗑️ Xóa ảnh</button>
                                <input type="file" id="licenseBackFileInput" accept="image/*" ${sessionScope.account.online ? '' : 'disabled'} style="display:block;"/>
                                <div class="upload-progress" id="licenseBackProgress" style="display:none;height:6px;background:var(--bg-input);border-radius:4px;margin-top:8px;overflow:hidden;">
                                    <div id="licenseBackBar" style="height:100%;width:0;background:var(--primary);transition:width .2s;"></div>
                                </div>
                                <div id="licenseBackMsg" style="font-size:12px;margin-top:6px;"></div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Loại phương tiện <span class="required">*</span></label>
                            <select name="vehicleType" class="form-select">
                                <option value="">-- Chọn loại --</option>
                                <c:set var="vt" value="${profile.vehicleType}"/>
                                <option value="Xe máy" ${vt == 'Xe máy' ? 'selected' : ''}>🏍️ Xe máy</option>
                                <option value="Xe đạp điện" ${vt == 'Xe đạp điện' ? 'selected' : ''}>⚡ Xe đạp điện</option>
                                <option value="Xe đạp" ${vt == 'Xe đạp' ? 'selected' : ''}>🚲 Xe đạp</option>
                                <option value="Ô tô" ${vt == 'Ô tô' ? 'selected' : ''}>🚗 Ô tô</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Biển số xe <span class="required">*</span></label>
                            <input type="text" class="form-control" name="vehiclePlate" value="${fn:escapeXml(profile.vehiclePlate)}" placeholder="51F-123.45" style="text-transform:uppercase;" maxlength="20"/>
                        </div>
                        <div class="form-group full">
                            <label class="form-label">Nhãn hiệu / Model xe</label>
                            <input type="text" class="form-control" name="vehicleModel" value="${fn:escapeXml(profile.vehicleModel)}" placeholder="Honda Wave Alpha 2022"/>
                        </div>
                        <div class="form-group" id="bankInfoSection">
                            <label class="form-label">Số tài khoản ngân hàng</label>
                            <input type="text" class="form-control" name="bankAccount" value="${fn:escapeXml(profile.bankAccount)}" placeholder="1234567890" maxlength="30"/>
                            <div class="form-hint">Tài khoản này cũng dùng để nhận tiền khi rút ở Ví tiền.</div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Tên ngân hàng</label>
                            <input type="text" class="form-control" name="bankName" value="${fn:escapeXml(profile.bankName)}" placeholder="Vietcombank, MB Bank, ..."/>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Tên chủ tài khoản</label>
                            <input type="text" class="form-control" name="bankAccountHolder" value="${fn:escapeXml(profile.bankAccountHolder)}" placeholder="VD: NGUYEN VAN A" style="text-transform:uppercase;" maxlength="100"/>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary" style="margin-top:16px;">💾 Lưu thông tin nghề nghiệp</button>
                </form>
            </div>
        </div>

    </div>
</main>

<div class="confirm-modal-overlay" id="confirmDeleteOverlay" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center;">
    <div class="confirm-modal-box" style="background:var(--bg-panel);border-radius:16px;max-width:360px;width:90%;padding:24px;box-shadow:0 20px 50px rgba(0,0,0,.25);text-align:center;">
        <div style="font-size:34px;margin-bottom:10px;">🗑️</div>
        <div style="font-size:15px;font-weight:800;color:var(--text-main);margin-bottom:6px;">Xóa ảnh này?</div>
        <div style="font-size:13px;color:var(--text-muted);margin-bottom:20px;">Ảnh đã xóa sẽ không thể khôi phục, bạn cần upload lại nếu muốn.</div>
        <div style="display:flex;gap:10px;justify-content:center;">
            <button type="button" class="btn btn-ghost" onclick="closeConfirmDeleteModal()">Hủy</button>
            <button type="button" class="btn btn-danger" id="confirmDeleteBtn">🗑️ Xóa ảnh</button>
        </div>
    </div>
</div>

<div class="avatar-dropdown" id="avatarDropdown">
    <div class="dropdown-header">
        <div class="d-name">${fn:escapeXml(sessionScope.account.userName)}</div>
        <div class="d-email">${fn:escapeXml(sessionScope.account.email)}</div>
        <span class="d-role">🛵 Shipper</span>
    </div>
    <div class="dropdown-body">
        <a href="${pageContext.request.contextPath}/shipper/ho-so" class="dropdown-link">👤 Hồ sơ cá nhân</a>
        <a href="${pageContext.request.contextPath}/shipper/doi-mat-khau" class="dropdown-link">🔒 Đổi mật khẩu</a>
        <div class="dropdown-divider"></div>
        <a href="${pageContext.request.contextPath}/logout" class="dropdown-link danger">🚪 Đăng xuất</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/dashboard-theme.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script>
    var alertBox = document.querySelector('.alert');
    if (alertBox) alertBox.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

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
    });

    // Upload ảnh CCCD/GPLX lên Cloudinary (dùng chung 1 cloud/preset với avatar)
    var CLOUD_NAME = 'jcnsb47f';
    var UPLOAD_PRESET = 'avatar_preset';

    function uploadDocImage(file, endpoint, side, previewId, progressId, barId, msgId, deleteBtnId) {
        var preview = document.getElementById(previewId);
        var progressBar = document.getElementById(progressId);
        var bar = document.getElementById(barId);
        var msg = document.getElementById(msgId);
        var deleteBtn = document.getElementById(deleteBtnId);

        progressBar.style.display = 'block';
        bar.style.width = '10%';
        msg.style.color = '';
        msg.textContent = 'Đang tải ảnh lên...';

        var formData = new FormData();
        formData.append('file', file);
        formData.append('upload_preset', UPLOAD_PRESET);
        formData.append('folder', 'shipper-docs');

        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'https://api.cloudinary.com/v1_1/' + CLOUD_NAME + '/image/upload', true);

        xhr.upload.onprogress = function(ev) {
            if (ev.lengthComputable) {
                var pct = Math.round((ev.loaded / ev.total) * 70);
                bar.style.width = (10 + pct) + '%';
            }
        };

        xhr.onload = function() {
            if (xhr.status === 200) {
                var result = JSON.parse(xhr.responseText);
                var imageUrl = result.secure_url;

                bar.style.width = '90%';
                msg.textContent = 'Đang lưu...';

                var saveXhr = new XMLHttpRequest();
                saveXhr.open('POST', '${pageContext.request.contextPath}' + endpoint, true);
                saveXhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                saveXhr.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name="_csrf"]').content);
                saveXhr.onload = function() {
                    bar.style.width = '100%';
                    if (saveXhr.status === 200) {
                        preview.src = imageUrl;
                        preview.style.display = 'block';
                        deleteBtn.style.display = 'block';
                        msg.style.color = 'var(--primary)';
                        msg.textContent = '✅ Tải ảnh lên thành công!';
                        setTimeout(function() {
                            progressBar.style.display = 'none';
                            bar.style.width = '0%';
                            msg.textContent = '';
                        }, 2500);
                    } else if (saveXhr.status === 409) {
                        msg.style.color = 'var(--danger)';
                        msg.textContent = '❌ Bạn đang Ngoại tuyến. Hãy bật Online rồi tải lại trang trước khi upload.';
                    } else {
                        msg.style.color = 'var(--danger)';
                        msg.textContent = '❌ Lưu ảnh thất bại, thử lại.';
                    }
                };
                saveXhr.send('imageUrl=' + encodeURIComponent(imageUrl) + '&side=' + side);
            } else {
                msg.style.color = 'var(--danger)';
                msg.textContent = '❌ Tải ảnh lên thất bại.';
                bar.style.width = '0%';
            }
        };

        xhr.onerror = function() {
            msg.style.color = 'var(--danger)';
            msg.textContent = '❌ Lỗi kết nối Cloudinary.';
            bar.style.width = '0%';
        };

        xhr.send(formData);
    }

    document.getElementById('idCardFrontFileInput').addEventListener('change', function(e) {
        var file = e.target.files[0];
        if (file) uploadDocImage(file, '/shipper/upload-id-card', 'front', 'idCardFrontPreview', 'idCardFrontProgress', 'idCardFrontBar', 'idCardFrontMsg', 'idCardFrontDeleteBtn');
    });

    document.getElementById('idCardBackFileInput').addEventListener('change', function(e) {
        var file = e.target.files[0];
        if (file) uploadDocImage(file, '/shipper/upload-id-card', 'back', 'idCardBackPreview', 'idCardBackProgress', 'idCardBackBar', 'idCardBackMsg', 'idCardBackDeleteBtn');
    });

    document.getElementById('licenseFrontFileInput').addEventListener('change', function(e) {
        var file = e.target.files[0];
        if (file) uploadDocImage(file, '/shipper/upload-license', 'front', 'licenseFrontPreview', 'licenseFrontProgress', 'licenseFrontBar', 'licenseFrontMsg', 'licenseFrontDeleteBtn');
    });

    document.getElementById('licenseBackFileInput').addEventListener('change', function(e) {
        var file = e.target.files[0];
        if (file) uploadDocImage(file, '/shipper/upload-license', 'back', 'licenseBackPreview', 'licenseBackProgress', 'licenseBackBar', 'licenseBackMsg', 'licenseBackDeleteBtn');
    });

    var pendingDelete = null;

    function deleteDocImage(endpoint, side, previewId, deleteBtnId, msgId) {
        pendingDelete = { endpoint: endpoint, side: side, previewId: previewId, deleteBtnId: deleteBtnId, msgId: msgId };
        document.getElementById('confirmDeleteOverlay').style.display = 'flex';
    }

    function closeConfirmDeleteModal() {
        pendingDelete = null;
        document.getElementById('confirmDeleteOverlay').style.display = 'none';
    }

    document.getElementById('confirmDeleteBtn').addEventListener('click', function() {
        if (!pendingDelete) return;
        var endpoint = pendingDelete.endpoint;
        var side = pendingDelete.side;
        var preview = document.getElementById(pendingDelete.previewId);
        var deleteBtn = document.getElementById(pendingDelete.deleteBtnId);
        var msg = document.getElementById(pendingDelete.msgId);
        closeConfirmDeleteModal();

        var xhr = new XMLHttpRequest();
        xhr.open('POST', '${pageContext.request.contextPath}' + endpoint, true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name="_csrf"]').content);
        xhr.onload = function() {
            if (xhr.status === 200) {
                preview.style.display = 'none';
                preview.src = '';
                deleteBtn.style.display = 'none';
                msg.style.color = 'var(--primary)';
                msg.textContent = '✅ Đã xóa ảnh.';
                setTimeout(function() { msg.textContent = ''; }, 2000);
            } else {
                msg.style.color = 'var(--danger)';
                msg.textContent = '❌ Xóa ảnh thất bại, thử lại.';
            }
        };
        xhr.onerror = function() {
            msg.style.color = 'var(--danger)';
            msg.textContent = '❌ Lỗi kết nối.';
        };
        xhr.send('action=delete&side=' + side);
    });

    document.getElementById('confirmDeleteOverlay').addEventListener('click', function(e) {
        if (e.target === this) closeConfirmDeleteModal();
    });
</script>
</body>
</html>
