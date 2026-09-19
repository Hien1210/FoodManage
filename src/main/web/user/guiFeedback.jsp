<%@ page pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đánh giá - FOOD MANAGE</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user-theme.css">
    <style>
        :root {
            --bg:       #FFF9F2;
            --surface:  #FFFFFF;
            --surface-lt: #FFF4EC;
            --gold:     #FF3B1F;
            --gold-hover: #E02A10;
            --text:     #2D2421;
            --muted:    #635752;
            --border:   #F1E4D6;
            --font-h: 'Quicksand', 'Plus Jakarta Sans', sans-serif;
            --font-b:   'Plus Jakarta Sans', sans-serif;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0; font-family: var(--font-b); background: var(--bg); color: var(--text);
            min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px;
        }
        .fb-card {
            max-width: 480px; width: 100%; padding: 34px;
            background: var(--surface); border: 1px solid var(--border); border-radius: 22px;
            box-shadow: 0 14px 34px rgba(99,44,20,.12);
        }
        .fb-head { display: flex; align-items: center; gap: 14px; margin-bottom: 24px; }
        .fb-logo { width: 46px; height: 46px; border-radius: 14px; background: linear-gradient(135deg, var(--gold), var(--gold-hover)); display: flex; align-items: center; justify-content: center; box-shadow: 0 8px 20px rgba(255,59,31,.32); }
        .fb-logo img { width: 28px; height: 28px; }
        .fb-title { font-family: var(--font-h); font-size: 18px; font-weight: 800; color: var(--text); }
        .fb-sub { font-size: 12.5px; color: var(--muted); margin-top: 2px; font-weight: 500; }

        .form-group { margin-bottom: 18px; }
        .form-label { display: block; font-size: .78rem; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; color: var(--muted); margin-bottom: 10px; }
        .form-textarea {
            width: 100%; padding: 12px 14px; background: var(--surface-lt); border: 1.5px solid var(--border);
            border-radius: 12px; color: var(--text); font-family: var(--font-b); font-size: .92rem;
            resize: vertical; min-height: 100px; outline: none; transition: all .2s ease;
        }
        .form-textarea:focus { border-color: var(--gold); background: var(--surface); box-shadow: 0 0 0 4px #FFF2F0; }
        .form-textarea::placeholder { color: var(--muted); }

        .star-row { display: flex; gap: 10px; justify-content: center; }
        .star-btn { cursor: pointer; transition: transform .1s; font-size: 38px; color: var(--border); line-height: 1; }
        .star-btn:hover, .star-btn.active { color: #FFB020; transform: scale(1.15); filter: drop-shadow(0 4px 8px rgba(255,176,32,.4)); }
        .rating-label { text-align: center; font-size: 13.5px; font-weight: 700; color: #C2660A; margin-top: 10px; }

        .fb-anon { display: flex; align-items: center; gap: 8px; margin-bottom: 20px; cursor: pointer; user-select: none; font-size: 13px; color: var(--muted); font-weight: 500; }
        .fb-anon input { width: 16px; height: 16px; accent-color: var(--gold); }

        .btn { display: inline-flex; align-items: center; justify-content: center; gap: 6px; padding: 12px 22px; border-radius: 50px; font-family: var(--font-b); font-size: .9rem; font-weight: 700; cursor: pointer; border: 1.5px solid; transition: all .2s ease; text-decoration: none; }
        .btn-ghost { background: transparent; color: var(--muted); border-color: var(--border); }
        .btn-ghost:hover { color: var(--text); border-color: var(--text); }
        .btn-primary { background: linear-gradient(135deg, var(--gold), var(--gold-hover)); color: #fff; border-color: var(--gold); box-shadow: 0 8px 20px rgba(255,59,31,.3); }
        .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 12px 26px rgba(255,59,31,.4); }
        .fb-actions { display: flex; gap: 12px; margin-top: 26px; }
        .fb-actions .btn { flex: 1; }

        .img-upload-area { border: 2px dashed var(--border); border-radius: 14px; padding: 16px; cursor: pointer; text-align: center; color: var(--muted); font-size: 13px; transition: border-color .2s; }
        .img-upload-area:hover { border-color: var(--gold); color: var(--gold); }
        .img-preview-grid { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; }
        .img-preview-item { position: relative; width: 72px; height: 72px; border-radius: 10px; overflow: hidden; }
        .img-preview-item img { width: 100%; height: 100%; object-fit: cover; }
        .img-preview-remove { position: absolute; top: 2px; right: 2px; width: 18px; height: 18px; border-radius: 50%; background: rgba(0,0,0,.55); color: #fff; font-size: 10px; display: flex; align-items: center; justify-content: center; cursor: pointer; border: none; }
        .img-upload-hint { font-size: 11.5px; color: var(--muted); margin-top: 6px; }
    </style>
</head>
<body>

<div class="fb-card">

    <div class="fb-head">
        <div class="fb-logo"><img src="https://cdn.jsdelivr.net/gh/microsoft/fluentui-emoji@main/assets/Star/3D/star_3d.png" alt=""></div>
        <div>
            <h1 class="fb-title">Đánh giá ${targetType eq 'SHOP' ? 'Cửa hàng' : 'Shipper'}</h1>
            <p class="fb-sub">Đơn hàng #${orderId}</p>
        </div>
    </div>

    <form action="${pageContext.request.contextPath}/feedback" method="post">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
        <input type="hidden" name="orderId"    value="${orderId}">
        <input type="hidden" name="targetType" value="${targetType}">
        <input type="hidden" name="rating"     id="ratingInput" value="5">

        <!-- Sao -->
        <div class="form-group">
            <label class="form-label">Mức độ hài lòng</label>
            <div class="star-row" id="starRow">
                <span class="star-btn active" data-val="1">★</span>
                <span class="star-btn active" data-val="2">★</span>
                <span class="star-btn active" data-val="3">★</span>
                <span class="star-btn active" data-val="4">★</span>
                <span class="star-btn active" data-val="5">★</span>
            </div>
            <p class="rating-label" id="ratingLabel">Rất hài lòng</p>
        </div>

        <!-- Bình luận -->
        <div class="form-group">
            <label class="form-label">Nhận xét của bạn</label>
            <textarea class="form-textarea" name="comment" rows="4" placeholder="Chia sẻ trải nghiệm của bạn..."></textarea>
        </div>

        <!-- Ảnh đánh giá -->
        <div class="form-group">
            <label class="form-label">Ảnh đính kèm (tùy chọn, tối đa 5 ảnh)</label>
            <div class="img-upload-area" id="imgDropArea" onclick="document.getElementById('imgFileInput').click()">
                📷 Nhấn để chọn ảnh
            </div>
            <input type="file" id="imgFileInput" accept="image/*" multiple style="display:none" onchange="handleImgSelect(this.files)">
            <div class="img-preview-grid" id="imgPreviewGrid"></div>
            <div id="imgUploadStatus" class="img-upload-hint"></div>
            <div id="imgHiddenInputs"></div>
        </div>

        <!-- Ẩn danh (chỉ User → Shop) -->
        <c:if test="${targetType eq 'SHOP'}">
        <label class="fb-anon">
            <input type="checkbox" name="is_anonymous" value="true">
            Đăng đánh giá ẩn danh
        </label>
        </c:if>

        <!-- Buttons -->
        <div class="fb-actions">
            <a href="${pageContext.request.contextPath}/user/donhang" class="btn btn-ghost">Hủy</a>
            <button type="submit" class="btn btn-primary">Gửi đánh giá</button>
        </div>
    </form>
</div>

<script>
    var labels = ['', 'Rất tệ', 'Không hài lòng', 'Bình thường', 'Hài lòng', 'Rất hài lòng'];
    var stars  = document.querySelectorAll('.star-btn');
    var input  = document.getElementById('ratingInput');
    var label  = document.getElementById('ratingLabel');

    function setRating(val) {
        input.value = val;
        label.textContent = labels[val];
        stars.forEach(function (s) { s.classList.toggle('active', parseInt(s.dataset.val) <= val); });
    }

    stars.forEach(function (s) {
        s.addEventListener('click', function () { setRating(parseInt(s.dataset.val)); });
        s.addEventListener('mouseover', function () {
            stars.forEach(function (x) { x.classList.toggle('active', parseInt(x.dataset.val) <= parseInt(s.dataset.val)); });
        });
        s.addEventListener('mouseout', function () { setRating(parseInt(input.value)); });
    });

    setRating(5);

    var CLOUD_NAME = 'jcnsb47f';
    var UPLOAD_PRESET = 'avatar_preset';
    var MAX_IMAGES = 5;
    var uploadedUrls = [];

    function handleImgSelect(files) {
        var remaining = MAX_IMAGES - uploadedUrls.length;
        var toUpload = Math.min(files.length, remaining);
        if (toUpload <= 0) {
            document.getElementById('imgUploadStatus').textContent = 'Đã đạt giới hạn 5 ảnh.';
            return;
        }
        document.getElementById('imgUploadStatus').textContent = 'Đang tải ảnh lên...';
        var done = 0;
        for (var i = 0; i < toUpload; i++) {
            uploadToCloudinary(files[i], function(url) {
                done++;
                if (url) {
                    uploadedUrls.push(url);
                    addPreview(url);
                    addHiddenInput(url);
                }
                if (done === toUpload) {
                    document.getElementById('imgUploadStatus').textContent =
                        uploadedUrls.length > 0 ? (uploadedUrls.length + ' ảnh đã tải lên.') : 'Tải ảnh thất bại.';
                }
            });
        }
    }

    function uploadToCloudinary(file, callback) {
        var fd = new FormData();
        fd.append('file', file);
        fd.append('upload_preset', UPLOAD_PRESET);
        fd.append('folder', 'feedback');
        fetch('https://api.cloudinary.com/v1_1/' + CLOUD_NAME + '/image/upload', { method: 'POST', body: fd })
            .then(function(r) { return r.json(); })
            .then(function(data) { callback(data.secure_url || null); })
            .catch(function() { callback(null); });
    }

    function addPreview(url) {
        var grid = document.getElementById('imgPreviewGrid');
        var item = document.createElement('div');
        item.className = 'img-preview-item';
        item.dataset.url = url;
        item.innerHTML = '<img src="' + url + '" alt="">'
            + '<button type="button" class="img-preview-remove" onclick="removeImg(this)">✕</button>';
        grid.appendChild(item);
    }

    function addHiddenInput(url) {
        var container = document.getElementById('imgHiddenInputs');
        var inp = document.createElement('input');
        inp.type = 'hidden';
        inp.name = 'imageUrls[]';
        inp.value = url;
        inp.dataset.url = url;
        container.appendChild(inp);
    }

    function removeImg(btn) {
        var item = btn.parentElement;
        var url = item.dataset.url;
        uploadedUrls = uploadedUrls.filter(function(u) { return u !== url; });
        item.remove();
        var inputs = document.getElementById('imgHiddenInputs').querySelectorAll('input');
        inputs.forEach(function(inp) { if (inp.dataset.url === url) inp.remove(); });
        document.getElementById('imgUploadStatus').textContent = uploadedUrls.length + ' ảnh.';
    }
</script>
</body>
</html>
