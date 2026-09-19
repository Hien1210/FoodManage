<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${shop.shopName} – FOOD MANAGE</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user-theme.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        h1, h2, h3, .m-section-title, .shop-hero h1, .shop-hero h2 { font-family: 'Quicksand', 'Plus Jakarta Sans', sans-serif; font-weight: 700; }
        body {
            font-family: 'Plus Jakarta Sans', 'Inter', system-ui, -apple-system, sans-serif;
            background: #FFF9F2;
            color: #2D2421;
            min-height: 100vh;
            padding-bottom: 80px;
        }
        a { text-decoration: none; color: inherit; }

        :root {
            --primary: #FF3B1F;
            --primary-hover: #FF7A47;
            --primary-light: #FFF2F0;
            --primary-light-border: #FFC7BE;
            --primary-dark-text: #B23D0E;
            --secondary: #FFB300;
            --accent-pink: #FF3B1F;
            --white: #ffffff;
            --bg-page: #FFF9F2;
            --bg-panel: #FFFFFF;
            --bg-panel-solid: #FFFFFF;
            --bg-input: #FFF4EC;
            --border-color: #F1E4D6;
            --text-main: #2D2421;
            --text-muted: #6B5B4C;
            --text-dim: #635752;
            --success: #15803D;
            --radius-sm: 10px;
            --radius-md: 16px;
            --radius-lg: 20px;
            --shadow-sm: 0 2px 10px rgba(99,44,20,.06);
            --shadow-md: 0 10px 28px rgba(99,44,20,.10);
            --shadow-lg: 0 20px 55px rgba(99,44,20,.16);
            --glow-primary: 0 6px 18px rgba(255,59,31,.32);
        }

        .starfield { display: none; }
        .shop-hero, .products-section, .notif-wrap { position: relative; }

        /* ══════════ NAVBAR ══════════ */
        .navbar {
            background: #FFFFFF;
            border-bottom: 1px solid var(--border-color);
            position: sticky; top: 0; z-index: 100;
        }
        .navbar-inner {
            max-width: 1100px; margin: 0 auto;
            padding: 0 20px; height: 60px;
            display: flex; align-items: center; gap: 14px;
        }
        .btn-back {
            display: flex; align-items: center; gap: 6px;
            padding: 7px 14px; border-radius: 50px;
            font-size: 13.5px; font-weight: 500; color: #444;
            border: 1px solid var(--border-color);
            background: #FFFFFF;
            cursor: pointer; transition: border-color .15s, color .15s;
        }
        .btn-back:hover { border-color: var(--primary); color: var(--primary); }
        .navbar-title {
            font-size: 16px; font-weight: 500; color: var(--text-main);
            flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }
        .nav-order-link {
            display: flex; align-items: center; gap: 6px;
            padding: 7px 14px; border-radius: 50px;
            font-size: 13px; font-weight: 500; color: #444;
            transition: background .15s, color .15s;
        }
        .nav-order-link:hover { background: var(--primary-light); color: var(--primary); }

        /* ══════════ SHOP HERO ══════════ */
        .shop-hero {
            background: linear-gradient(135deg, #FFF0EB 0%, #FFE4D6 100%);
            overflow: hidden;
            border-bottom: 1px solid var(--border-color);
        }
        .shop-hero::before {
            content: '';
            position: absolute; inset: 0;
            background: radial-gradient(circle at 80% 20%, rgba(255,140,90,.15) 0%, transparent 50%);
            pointer-events: none;
        }
        .shop-hero-inner {
            max-width: 1100px; margin: 0 auto;
            padding: 32px 20px 28px;
            display: flex; align-items: center; gap: 20px;
            position: relative; z-index: 1;
        }
        .shop-logo {
            width: 88px; height: 88px; border-radius: var(--radius-md);
            background: #FFFFFF;
            display: flex; align-items: center; justify-content: center;
            font-size: 42px; flex-shrink: 0;
            overflow: hidden;
            box-shadow: var(--shadow-md);
            border: 3px solid #FFFFFF;
        }
        .shop-logo img { width: 100%; height: 100%; object-fit: cover; }
        .shop-info { flex: 1; min-width: 0; }
        .shop-info h1 {
            font-size: clamp(1.4rem, 3vw, 1.9rem);
            font-weight: 500; color: #1A1A1A; line-height: 1.2;
        }
        .shop-info .desc {
            color: #7A5548; font-size: 13.5px; margin-top: 5px;
            display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
        }
        .shop-meta-row {
            display: flex; flex-wrap: wrap; gap: 14px; margin-top: 10px;
        }
        .shop-meta-item {
            display: flex; align-items: center; gap: 5px;
            font-size: 12.5px; color: #8A6A5D;
        }
        .hero-stats {
            display: flex; gap: 12px; flex-shrink: 0;
        }
        .hero-stat-box {
            background: #FFFFFF;
            border: 1px solid var(--primary-light-border);
            border-radius: var(--radius-sm);
            padding: 10px 16px; text-align: center;
        }
        .hero-stat-box .val { font-size: 18px; font-weight: 700; color: var(--primary); }
        .hero-stat-box .lbl { font-size: 10px; color: var(--text-dim); margin-top: 1px; }

        /* ══════════ NOTIFICATION ══════════ */
        .notif-wrap { max-width: 1100px; margin: 0 auto; padding: 0 20px; }
        .notif-success {
            display: flex; align-items: center; justify-content: space-between; gap: 10px;
            background: #EAF8EF; border: 1px solid #BCE8CB; border-radius: var(--radius-md);
            padding: 12px 16px; margin-top: 16px;
            font-size: 13.5px; font-weight: 500; color: var(--success);
        }
        .notif-success a {
            background: var(--success); color: #ffffff;
            padding: 6px 14px; border-radius: var(--radius-sm);
            font-size: 12.5px; font-weight: 600;
            transition: opacity .15s;
        }
        .notif-success a:hover { opacity: .85; }

        /* ══════════ CATEGORY TABS ══════════ */
        .cat-section {
            background: #FFFFFF;
            border-bottom: 1px solid var(--border-color);
            position: sticky; top: 60px; z-index: 50;
        }
        .cat-inner {
            max-width: 1100px; margin: 0 auto; padding: 0 20px;
        }
        .cat-scroll {
            display: flex; gap: 8px;
            overflow-x: auto; padding: 14px 0;
            scrollbar-width: none;
        }
        .cat-scroll::-webkit-scrollbar { display: none; }
        .cat-pill {
            padding: 7px 18px; border-radius: 20px;
            font-size: 13px; font-weight: 500;
            border: 1px solid var(--border-color);
            background: #FFFFFF; color: #444;
            cursor: pointer; white-space: nowrap; flex-shrink: 0;
            transition: all .15s;
        }
        .cat-pill:hover { border-color: var(--primary); color: var(--primary); }
        .cat-pill.active {
            background: var(--primary); color: var(--white);
            border-color: var(--primary);
        }

        /* ══════════ PRODUCTS SECTION ══════════ */
        .products-section { max-width: 1100px; margin: 0 auto; padding: 24px 20px; }
        .sec-head {
            display: flex; align-items: center; gap: 10px; margin-bottom: 18px;
        }
        .sec-title { font-size: 18px; font-weight: 500; color: var(--text-main); }
        .sec-count {
            background: var(--primary-light); color: var(--primary);
            font-size: 12px; font-weight: 600;
            padding: 2px 10px; border-radius: 50px;
        }

        /* ══════════ FLASH SALE SECTION ══════════ */
        .flash-sale-section {
            max-width: 1100px; margin: 24px auto 0; padding: 20px 24px;
            background: linear-gradient(135deg, rgba(239,68,68,0.06) 0%, rgba(249,115,22,0.09) 100%);
            border: 1.5px solid #fecaca;
            border-radius: var(--radius-lg);
        }
        .fs-countdown-tag {
            display: inline-flex; align-items: center; gap: 4px;
            font-size: 11px; font-weight: 700; color: #dc2626;
            background: #fef2f2; border: 1px solid #fecaca;
            padding: 2px 8px; border-radius: 20px; margin-top: 4px;
        }
        .fs-time-val { font-family: 'Plus Jakarta Sans', monospace; font-size: 11.5px; font-weight: 800; }

        /* ══════════ COMBOS SECTION ══════════ */
        .combo-section {
            max-width: 1100px; margin: 0 auto 28px; padding: 22px 24px;
            background: linear-gradient(135deg, rgba(255,87,34,.05) 0%, rgba(255,152,0,.08) 100%);
            border: 1px solid rgba(255,87,34,.18);
            border-radius: var(--radius-lg);
        }
        .combo-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 16px;
            margin-top: 14px;
        }
        .user-combo-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 18px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-shadow: 0 4px 12px rgba(0,0,0,.04);
            transition: transform .2s, box-shadow .2s, border-color .2s;
        }
        .user-combo-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(255,87,34,.12);
            border-color: var(--primary);
        }
        .combo-card-header {
            border-bottom: 1px dashed var(--border-color);
            padding-bottom: 10px;
            margin-bottom: 10px;
        }
        .combo-title { font-size: 16px; font-weight: 700; color: var(--text-main); }
        .combo-desc { font-size: 12.5px; color: var(--text-dim); margin-top: 3px; line-height: 1.4; }
        .combo-items-list { flex: 1; margin-bottom: 14px; }
        .combo-items-label { font-size: 11px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; margin-bottom: 6px; }
        .combo-item-row { display: flex; align-items: center; gap: 6px; font-size: 13px; margin-bottom: 5px; color: var(--text-main); }
        .ci-icon { font-size: 10px; color: var(--primary); }
        .ci-name { flex: 1; }
        .ci-qty { font-weight: 700; color: var(--primary); background: var(--primary-light); padding: 1px 6px; border-radius: 8px; font-size: 11.5px; }
        .combo-card-footer {
            display: flex; align-items: center; justify-content: space-between;
            padding-top: 10px; border-top: 1px solid var(--border-color);
        }
        .combo-price-wrap { display: flex; flex-direction: column; }
        .combo-final-price { font-size: 17px; font-weight: 800; color: var(--primary); }
        .combo-orig-price { font-size: 12px; color: var(--text-dim); text-decoration: line-through; }
        .btn-add-combo {
            background: var(--primary); color: #ffffff;
            border: none; border-radius: 12px;
            padding: 8px 16px; font-weight: 700; font-size: 13px;
            cursor: pointer; transition: background .15s, transform .15s;
        }
        .btn-add-combo:hover { background: var(--primary-dark); transform: scale(1.03); }
        .btn-add-combo:disabled { background: #cbd5e1; cursor: not-allowed; transform: none; }

        /* ══════════ PRODUCT CARD ══════════ */
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
            gap: 16px;
        }
        .product-card {
            background: #FFFFFF;
            border-radius: var(--radius-lg);
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            display: flex; flex-direction: column;
            cursor: pointer;
            transition: transform .22s cubic-bezier(.34,1.56,.64,1), box-shadow .22s, border-color .22s;
        }
        .product-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-md);
            border-color: var(--primary-light-border);
        }
        .product-card.hidden-card { display: none; }

        /* Thumb */
        .p-thumb {
            height: 140px; position: relative; overflow: hidden; flex-shrink: 0;
            background: var(--bg-input);
            display: flex; align-items: center; justify-content: center;
        }
        .p-thumb img {
            width: 100%; height: 100%; object-fit: cover; object-position: center;
            transition: transform .35s;
        }
        .product-card:hover .p-thumb img { transform: scale(1.08); }
        .p-thumb .fallback { font-size: 56px; opacity: .35; }
        .p-overlay {
            position: absolute; inset: 0;
            background: linear-gradient(to bottom, transparent 60%, rgba(0,0,0,.25) 100%);
        }

        /* Status badges */
        .badge-new {
            position: absolute; top: 10px; left: 10px;
            background: #2E9E5B; color: #fff;
            font-size: 10px; font-weight: 600;
            padding: 3px 9px; border-radius: 50px;
            letter-spacing: .3px;
        }
        .badge-hot {
            position: absolute; top: 10px; left: 10px;
            background: var(--primary); color: #fff;
            font-size: 10px; font-weight: 600;
            padding: 3px 9px; border-radius: 50px;
        }
        .badge-oos {
            position: absolute; top: 10px; left: 10px;
            background: rgba(0,0,0,.55); color: #fff;
            font-size: 10px; font-weight: 600;
            padding: 3px 9px; border-radius: 50px;
        }

        /* Price on thumb */
        .p-price-thumb {
            position: absolute; bottom: 10px; left: 10px;
            background: rgba(255,255,255,.92);
            color: var(--primary); font-size: 12.5px; font-weight: 700;
            padding: 3px 10px; border-radius: 50px;
            box-shadow: 0 2px 6px rgba(0,0,0,.12);
        }

        /* Body */
        .p-body {
            padding: 13px 14px 6px; flex: 1; display: flex; flex-direction: column; gap: 4px;
        }
        .p-name {
            font-size: 14.5px; font-weight: 500; color: var(--text-main);
            line-height: 1.3;
            display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
        }
        .p-desc {
            font-size: 12px; color: var(--text-dim); line-height: 1.5;
            display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
        }
        .p-rating {
            display: flex; align-items: center; gap: 4px;
            font-size: 12px; color: var(--text-dim); margin-top: 2px;
        }
        .p-stars { color: #FFB100; letter-spacing: -1px; }

        /* Card footer */
        .p-footer {
            display: flex; align-items: center; justify-content: space-between;
            padding: 8px 14px 14px;
        }
        .p-price {
            font-size: 15px; font-weight: 500; color: var(--primary);
        }
        .p-price small { font-size: 11px; font-weight: 400; color: var(--text-dim); display: block; line-height: 1.2; }
        .btn-add {
            display: flex; align-items: center; justify-content: center;
            width: 36px; height: 36px; border-radius: 50%;
            background: var(--primary); color: var(--white);
            border: none; font-size: 22px; font-weight: 300;
            cursor: pointer; flex-shrink: 0;
            box-shadow: var(--glow-primary);
            transition: background .15s, transform .1s;
            line-height: 1;
        }
        .btn-add:hover { background: var(--primary-hover); transform: scale(1.1); }
        .btn-add:disabled {
            background: #EEEEEE; color: var(--text-dim);
            cursor: not-allowed; box-shadow: none; transform: none;
        }

        /* ══════════ EMPTY STATE ══════════ */
        .empty-state {
            text-align: center; padding: 80px 24px; color: var(--text-dim);
        }
        .empty-state .e-icon { font-size: 72px; margin-bottom: 16px; line-height: 1; opacity: .5; }
        .empty-state .e-title { font-size: 17px; font-weight: 500; color: var(--text-muted); }
        .empty-state .e-sub { font-size: 13px; margin-top: 6px; }

        /* ══════════ MODAL ══════════ */
        /* position: fixed !important vì rule "body > *:not(.starfield)" ở trên có độ đặc hiệu
           cao hơn .modal-overlay và từng ghi đè thành position:relative, khiến modal bị đẩy
           vào giữa trang thay vì phủ toàn màn hình. */
        .modal-overlay {
            position: fixed !important; inset: 0;
            background: rgba(26,26,26,.45);
            display: flex; align-items: flex-end; justify-content: center;
            z-index: 300; opacity: 0; pointer-events: none;
            transition: opacity .22s;
        }
        .modal-overlay.open { opacity: 1; pointer-events: all; }
        .modal-box {
            background: #FFFFFF;
            border: 1px solid var(--border-color); border-bottom: none;
            border-radius: 20px 20px 0 0;
            padding: 0;
            width: 100%; max-width: 520px;
            transform: translateY(50px);
            transition: transform .25s cubic-bezier(.4,0,.2,1);
            max-height: 92vh; overflow-y: auto;
            box-shadow: var(--shadow-lg);
        }
        .modal-overlay.open .modal-box { transform: translateY(0); }

        /* Modal header */
        .modal-header {
            position: sticky; top: 0; z-index: 10;
            background: #FFFFFF;
            padding: 20px 20px 16px;
            border-bottom: 1px solid var(--border-color);
            display: flex; align-items: flex-start; justify-content: space-between; gap: 12px;
        }
        .modal-title-wrap .m-name {
            font-size: 17px; font-weight: 500; color: var(--text-main); line-height: 1.3;
        }
        .modal-title-wrap .m-sub { font-size: 12.5px; color: var(--text-dim); margin-top: 2px; }
        .modal-close {
            width: 32px; height: 32px; border-radius: 50%;
            background: var(--bg-input); border: none;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; cursor: pointer; flex-shrink: 0;
            color: var(--text-muted); transition: background .15s;
        }
        .modal-close:hover { background: var(--primary-light); color: var(--primary); }

        .modal-body { padding: 20px; }

        /* Size selector */
        .m-section-title {
            font-size: 13px; font-weight: 600; color: var(--text-main);
            margin-bottom: 10px; display: flex; align-items: center; gap: 4px;
        }
        .m-required { color: var(--primary); }
        .size-radio { display: none; }
        .size-label {
            display: inline-flex; flex-direction: column; align-items: center;
            padding: 9px 16px; border-radius: var(--radius-sm);
            border: 2px solid var(--border-color); font-size: 13px; font-weight: 600;
            cursor: pointer; transition: all .12s; text-align: center;
            background: #FFFFFF;
        }
        .size-label .s-name { color: var(--text-main); }
        .size-label .s-price { font-size: 11.5px; color: var(--text-dim); font-weight: 500; margin-top: 1px; }
        .size-radio:checked + .size-label {
            background: var(--primary-light);
            border-color: var(--primary);
        }
        .size-radio:checked + .size-label .s-name { color: var(--primary); }
        .size-radio:checked + .size-label .s-price { color: var(--primary); }
        .size-label-disabled { opacity: .5; cursor: not-allowed; }
        .size-radio:disabled + .size-label { cursor: not-allowed; }

        /* Topping */
        .topping-item {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 12px; border-radius: var(--radius-sm);
            border: 1.5px solid var(--border-color); margin-bottom: 6px;
            font-size: 13px; color: var(--text-muted);
            background: #FAFAFA; cursor: pointer; transition: border-color .15s, background .15s;
        }
        .topping-item:has(.topping-check:checked),
        .topping-item.checked {
            border-color: var(--primary); background: var(--primary-light);
        }
        .topping-item .topping-check {
            width: 18px; height: 18px; flex-shrink: 0; accent-color: var(--primary); cursor: pointer;
        }
        .topping-item .t-name { flex: 1; color: var(--text-main); }
        .topping-item-disabled { opacity: .55; cursor: not-allowed; background: var(--border-color); }
        .topping-item-disabled .topping-check { cursor: not-allowed; }
        .topping-item .t-price { font-weight: 600; color: var(--primary); flex-shrink: 0; }
        .t-qty-row { display: inline-flex; align-items: center; gap: 6px; margin-left: 4px; flex-shrink: 0; }
        .t-qty-btn {
            width: 22px; height: 22px; border-radius: 50%; border: 1.5px solid var(--border-color);
            background: #FFFFFF; font-size: 13px; font-weight: 600; cursor: pointer; line-height: 1;
            display: flex; align-items: center; justify-content: center; color: var(--text-main);
            transition: border-color .15s, background .15s;
        }
        .t-qty-btn:hover { border-color: var(--primary); background: var(--primary-light); }
        .t-qty-val { font-size: 12.5px; font-weight: 700; min-width: 14px; text-align: center; color: var(--text-main); }

        /* Quantity */
        .qty-row {
            display: flex; align-items: center; gap: 14px;
        }
        .qty-btn {
            width: 36px; height: 36px; border-radius: 50%;
            border: 2px solid var(--border-color); background: #FFFFFF;
            font-size: 20px; font-weight: 300; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            color: var(--text-main); transition: border-color .15s, background .15s;
            line-height: 1;
        }
        .qty-btn:hover { border-color: var(--primary); background: var(--primary-light); }
        .qty-val { font-size: 18px; font-weight: 700; min-width: 28px; text-align: center; color: var(--text-main); }

        /* Summary */
        .m-summary {
            background: var(--primary-light); border: 1px solid var(--primary-light-border);
            border-radius: var(--radius-md); padding: 14px 16px;
            display: flex; align-items: center; justify-content: space-between;
            margin-top: 18px;
        }
        .m-summary .s-label { font-size: 13px; color: var(--text-muted); font-weight: 600; }
        .m-summary .s-total { font-size: 18px; font-weight: 700; color: var(--primary); }

        .btn-submit {
            width: 100%; margin-top: 14px; padding: 14px;
            border-radius: var(--radius-md); border: none;
            background: var(--primary); color: var(--white);
            font-size: 15px; font-weight: 600; cursor: pointer;
            box-shadow: var(--glow-primary);
            transition: background .15s, transform .1s;
        }
        .btn-submit:hover { background: var(--primary-hover); transform: scale(.99); }

        /* ══════════ CART BAR ══════════ */
        .cart-bar {
            position: fixed !important; bottom: 0; left: 0; right: 0;
            background: var(--primary);
            padding: 14px 24px;
            display: flex; align-items: center; justify-content: space-between; gap: 16px;
            z-index: 200; transform: translateY(100%);
            transition: transform .28s cubic-bezier(.4,0,.2,1);
            box-shadow: 0 -4px 24px rgba(255,107,53,.3);
        }
        .cart-bar.visible { transform: translateY(0); }
        .cart-bar-label { font-size: 14px; font-weight: 600; color: #fff; }
        .cart-bar-label small { display: block; font-size: 11px; font-weight: 400; opacity: .9; }
        .cart-bar-btn {
            background: #fff; color: var(--primary);
            font-size: 13.5px; font-weight: 600;
            padding: 9px 20px; border-radius: 50px;
            white-space: nowrap;
            box-shadow: 0 2px 8px rgba(0,0,0,.15);
            transition: opacity .15s;
        }
        .cart-bar-btn:hover { opacity: .9; }

        /* ══════════ RESPONSIVE ══════════ */
        @media (max-width: 640px) {
            .hero-stats { display: none; }
            .shop-hero-inner { padding: 24px 16px; gap: 14px; }
            .shop-logo { width: 72px; height: 72px; font-size: 34px; }
            .product-grid { grid-template-columns: repeat(2, 1fr); gap: 12px; }
        }
        @media (max-width: 400px) {
            .product-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<div class="starfield"></div>

<!-- ═══════════════════ NAVBAR ═══════════════════ -->
<header class="navbar" style="position:sticky;top:0;left:0;width:100%;background:rgba(255,251,248,.92);backdrop-filter:blur(14px);-webkit-backdrop-filter:blur(14px);z-index:1000;border-bottom:1px solid var(--border-color,#F1E4D6);">
    <div style="max-width:1180px;margin:0 auto;padding:0 20px;display:flex;justify-content:space-between;align-items:center;height:76px;gap:16px;">
        <a href="${pageContext.request.contextPath}/user/home" style="display:flex;align-items:center;gap:8px;text-decoration:none;color:inherit;">
            <img style="width:30px;height:30px;filter:drop-shadow(0 4px 8px rgba(255,59,31,.4));" src="https://cdn.jsdelivr.net/gh/microsoft/fluentui-emoji@main/assets/Steaming%20bowl/3D/steaming_bowl_3d.png" alt="FOOD MANAGE">
            <h1 style="font-size:1.55rem;letter-spacing:-.5px;font-weight:800;font-family:'Plus Jakarta Sans',sans-serif;">FOOD MANAGE<span style="color:#FF3B1F;">.</span></h1>
        </a>

        <nav style="display:flex;gap:20px;align-items:center;">
            <a href="${pageContext.request.contextPath}/user/home" style="font-size:.86rem;font-weight:600;color:#635752;text-decoration:none;">Trang chủ</a>
            <a href="${pageContext.request.contextPath}/user/home#restaurants" style="font-size:.86rem;font-weight:700;color:#FF3B1F;text-decoration:none;">Nhà hàng</a>
            <a href="${pageContext.request.contextPath}/user/donhang" style="font-size:.86rem;font-weight:600;color:#635752;text-decoration:none;">Đơn hàng</a>
            <a href="${pageContext.request.contextPath}/user/dia-chi" style="font-size:.86rem;font-weight:600;color:#635752;text-decoration:none;">Địa chỉ</a>
            <a href="${pageContext.request.contextPath}/user/diem-thuong" style="font-size:.86rem;font-weight:600;color:#635752;text-decoration:none;">Điểm thưởng</a>
        </nav>

        <div style="display:flex;align-items:center;gap:14px;">
            <a href="${pageContext.request.contextPath}/user/thong-bao" aria-label="Thông báo" style="position:relative;width:40px;height:40px;border-radius:50%;background:#FFF4EC;border:1.5px solid #F1E4D6;display:flex;align-items:center;justify-content:center;color:#635752;text-decoration:none;">
                <i class="fa-solid fa-bell"></i>
                <span data-notif-badge style="display:${unreadNotifCount > 0 ? 'inline-block' : 'none'};position:absolute;top:2px;right:2px;background:#ef4444;color:#fff;border-radius:999px;font-size:10px;min-width:16px;height:16px;line-height:16px;text-align:center;padding:0 3px;font-weight:700;">${unreadNotifCount}</span>
            </a>

            <a href="${pageContext.request.contextPath}/user/cart" aria-label="Giỏ hàng" style="width:40px;height:40px;border-radius:50%;background:#FFF4EC;border:1.5px solid #F1E4D6;display:flex;align-items:center;justify-content:center;color:#635752;text-decoration:none;">
                <i class="fa-solid fa-bag-shopping"></i>
            </a>
        </div>
    </div>
</header>

<!-- ═══════════════════ SHOP HERO ═══════════════════ -->
<div class="shop-hero">
    <div class="shop-hero-inner">
        <div class="shop-logo">
            <c:set var="isValidHeroLogoUrl" value="${not empty shop.shopLogo && (fn:startsWith(shop.shopLogo, 'http://') || fn:startsWith(shop.shopLogo, 'https://') || fn:startsWith(shop.shopLogo, '/') || fn:startsWith(shop.shopLogo, 'assets/'))}"/>
            <c:choose>
                <c:when test="${isValidHeroLogoUrl}">
                    <img src="${shop.shopLogo}" alt="${shop.shopName}"
                         onerror="this.src='https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80'">
                </c:when>
                <c:otherwise>
                    <img src="https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80" alt="${shop.shopName}">
                </c:otherwise>
            </c:choose>
        </div>

        <div class="shop-info">
            <h1>${shop.shopName}</h1>
            <c:if test="${not empty shop.shopDescription}">
                <div class="desc">${shop.shopDescription}</div>
            </c:if>
            <div class="shop-meta-row">
                <c:if test="${not empty shop.shopAddress}">
                    <span class="shop-meta-item">📍 ${shop.shopAddress}</span>
                </c:if>
                <c:if test="${not empty shop.shopPhone}">
                    <span class="shop-meta-item">📞 ${shop.shopPhone}</span>
                </c:if>
                <c:choose>
                    <c:when test="${empty shop.openTime || empty shop.closeTime}">
                        <span class="shop-meta-item">
                            <span style="color:#34d399;font-size:8px;">●</span> &nbsp;Mở cửa cả ngày
                        </span>
                    </c:when>
                    <c:when test="${shopOpenNow}">
                        <span class="shop-meta-item">
                            <span style="color:#34d399;font-size:8px;">●</span> &nbsp;Đang mở cửa (${shop.openTime} - ${shop.closeTime})
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span class="shop-meta-item">
                            <span style="color:#ef4444;font-size:8px;">●</span> &nbsp;Đang đóng cửa (mở lại lúc ${shop.openTime})
                        </span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="hero-stats">
            <div class="hero-stat-box">
                <div class="val">
                    <c:choose>
                        <c:when test="${totalFeedback > 0}"><fmt:formatNumber value="${avgRating}" maxFractionDigits="1" minFractionDigits="1"/> ⭐</c:when>
                        <c:otherwise>Chưa có ⭐</c:otherwise>
                    </c:choose>
                </div>
                <div class="lbl">Đánh giá</div>
            </div>
            <div class="hero-stat-box">
                <div class="val">30'</div>
                <div class="lbl">Giao hàng</div>
            </div>
            <div class="hero-stat-box">
                <div class="val">
                    <c:choose>
                        <c:when test="${not empty products}">${fn:length(products)}</c:when>
                        <c:otherwise>0</c:otherwise>
                    </c:choose>
                </div>
                <div class="lbl">Món ăn</div>
            </div>
        </div>
    </div>
</div>

<!-- Thông báo thành công -->
<div class="notif-wrap">
    <c:if test="${param.added eq '1'}">
        <div class="notif-success">
            <span>✅ Đã thêm vào giỏ hàng thành công!</span>
            <a href="${pageContext.request.contextPath}/checkout?cartId=${param.cartId}">
                Thanh toán ngay →
            </a>
        </div>
    </c:if>
    <c:if test="${param.error eq 'shop_closed'}">
        <div class="notif-success" style="background:#fef2f2;border-color:#fecaca;color:#b91c1c;">
            <span>⚠️ Cửa hàng hiện đang đóng cửa, không thể thêm món vào giỏ hàng lúc này.</span>
        </div>
    </c:if>
    <c:if test="${param.error eq 'shop_conflict'}">
        <div class="notif-success" style="background:#fef2f2;border-color:#fecaca;color:#b91c1c;">
            <span>⚠️ Giỏ hàng của bạn đang có món từ shop khác. Vui lòng xác nhận lại để đổi shop.</span>
        </div>
    </c:if>
</div>

<!-- ═══════════════════ CATEGORY TABS ═══════════════════ -->
<c:if test="${not empty categories or not empty combos}">
    <div class="cat-section">
        <div class="cat-inner">
            <div class="cat-scroll">
                <button class="cat-pill active" onclick="filterCategory('all', this)">🍽️ Tất cả</button>
                <c:if test="${not empty activeFlashSales}">
                    <button class="cat-pill" onclick="filterCategory('flash', this)" style="border-color:#fecaca;color:#ef4444;">⚡ Flash Sale (${fn:length(activeFlashSales)})</button>
                </c:if>
                <c:if test="${not empty combos}">
                    <button class="cat-pill" onclick="filterCategory('combo', this)">🎁 Combo (${fn:length(combos)})</button>
                </c:if>
                <c:forEach var="cat" items="${categories}">
                    <button class="cat-pill" onclick="filterCategory('${cat.id}', this)">
                        ${cat.categoryName}
                    </button>
                </c:forEach>
            </div>
        </div>
    </div>
</c:if>

<!-- ═══════════════════ FLASH SALE SECTION ═══════════════════ -->
<c:if test="${not empty activeFlashSales}">
    <div style="max-width:1100px;margin:24px auto 0;padding:0 20px;" id="flashSaleSection">
        <div class="flash-sale-section">
            <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;margin-bottom:12px;">
                <div style="display:flex;align-items:center;gap:10px;">
                    <h2 style="margin:0;font-size:19px;font-weight:800;color:#dc2626;display:flex;align-items:center;gap:6px;">⚡ Flash Sale Đang Diễn Ra</h2>
                    <span style="font-size:11.5px;font-weight:700;padding:2px 10px;background:#ef4444;color:#fff;border-radius:20px;">Giảm cực sốc</span>
                </div>
                <c:if test="${not empty activeFlashSales[0].endTime}">
                    <div class="fs-countdown-tag" data-endtime="${activeFlashSales[0].endTime}" style="font-size:12.5px;padding:4px 12px;">
                        ⏰ Kết thúc sau: <span class="fs-time-val" style="font-size:13px;color:#b91c1c;">--:--:--</span>
                    </div>
                </c:if>
            </div>
            <div style="font-size:13px;color:var(--text-muted);">Sưu tầm ngay các món đang được ưu đãi Flash Sale với giá cực sốc hôm nay!</div>
        </div>
    </div>
</c:if>

<!-- ═══════════════════ COMBOS SECTION ═══════════════════ -->
<c:if test="${not empty combos}">
    <div style="max-width:1100px;margin:24px auto 0;padding:0 20px;">
        <div class="combo-section" id="comboSection">
            <div style="display:flex;align-items:center;gap:10px;margin-bottom:4px;">
                <h2 style="margin:0;font-size:19px;font-weight:700;color:var(--text-main);">🎁 Combo Khuyến Mãi</h2>
                <span style="font-size:11.5px;font-weight:700;padding:2px 10px;background:var(--primary);color:#fff;border-radius:20px;">Tiết kiệm hơn</span>
            </div>
            <div class="combo-grid">
                <c:forEach var="cb" items="${combos}">
                    <c:set var="origPrice" value="0"/>
                    <c:forEach var="ci" items="${cb.items}">
                        <c:set var="origPrice" value="${origPrice + (ci.sizePrice * ci.quantity)}"/>
                    </c:forEach>

                    <div class="user-combo-card">
                        <div class="combo-card-header">
                            <div class="combo-title">🎁 <c:out value="${cb.name}"/></div>
                            <c:if test="${not empty cb.description}">
                                <div class="combo-desc"><c:out value="${cb.description}"/></div>
                            </c:if>
                        </div>

                        <div class="combo-items-list">
                            <div class="combo-items-label">Gồm các món trong combo:</div>
                            <c:forEach var="ci" items="${cb.items}">
                                <div class="combo-item-row">
                                    <span class="ci-icon">🔸</span>
                                    <span class="ci-name"><strong><c:out value="${ci.productName}"/></strong> — <c:out value="${ci.sizeName}"/></span>
                                    <span class="ci-qty">x${ci.quantity}</span>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="combo-card-footer">
                            <div class="combo-price-wrap">
                                <div class="combo-final-price">
                                    <fmt:formatNumber value="${cb.comboPrice}" type="number" groupingUsed="true"/>đ
                                </div>
                                <c:if test="${origPrice > cb.comboPrice}">
                                    <div class="combo-orig-price">
                                        <fmt:formatNumber value="${origPrice}" type="number" groupingUsed="true"/>đ
                                    </div>
                                </c:if>
                            </div>

                            <form action="${pageContext.request.contextPath}/user/add-combo-to-cart" method="post" style="margin:0">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="comboId" value="${cb.id}">
                                <input type="hidden" name="shopId" value="${shop.id}">
                                <input type="hidden" name="confirmSwitchShop" class="combo-confirm-switch" value="">
                                <button type="submit" class="btn-add-combo"
                                        <c:if test="${not shopOpenNow}">disabled title="Cửa hàng đang đóng cửa"</c:if>
                                        onclick="return submitAddCombo(this.form)">
                                    🛒 Thêm Combo
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
</c:if>

<!-- ═══════════════════ PRODUCTS ═══════════════════ -->
<div class="products-section">
    <div class="sec-head">
        <h2 class="sec-title">🛒 Thực đơn</h2>
        <span class="sec-count" id="productCount">
            <c:choose>
                <c:when test="${not empty products}">${fn:length(products)}</c:when>
                <c:otherwise>0</c:otherwise>
            </c:choose> món
        </span>
    </div>

    <c:choose>
        <c:when test="${empty products}">
            <div class="empty-state">
                <div class="e-icon"><img src="https://cdn.jsdelivr.net/gh/microsoft/fluentui-emoji@main/assets/Fork%20and%20knife%20with%20plate/3D/fork_and_knife_with_plate_3d.png" alt="" style="width:80px;height:80px;filter:drop-shadow(0 12px 18px rgba(99,44,20,.2));"></div>
                <div class="e-title">Quán chưa có món nào</div>
                <div class="e-sub">Vui lòng quay lại sau!</div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="product-grid" id="productGrid">
                <c:forEach var="p" items="${products}" varStatus="vs">
                    <c:set var="isPOnSale" value="${not empty p.sizes and not empty p.sizes[0].salePrice and p.sizes[0].salePrice > 0}"/>
                    <div class="product-card" data-cat="${p.categoryId}" data-has-sale="${isPOnSale}" id="pcard-${p.id}">

                        <!-- Ảnh -->
                        <div class="p-thumb">
                            <c:choose>
                                <c:when test="${not empty p.imageUrl}">
                                    <img src="${p.imageUrl}" alt="${p.productName}"
                                         onerror="this.style.display='none';this.nextSibling.style.display='flex'">
                                    <div class="fallback" style="display:none;width:100%;height:100%;align-items:center;justify-content:center;">🍜</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="fallback">🍜</div>
                                </c:otherwise>
                            </c:choose>
                            <div class="p-overlay"></div>

                            <%-- Badge trạng thái --%>
                            <c:choose>
                                <c:when test="${p.staTus eq 'OUT_OF_STOCK'}">
                                    <div class="badge-oos">Hết hàng</div>
                                </c:when>
                                <c:when test="${isPOnSale}">
                                    <div class="badge-hot" style="background:linear-gradient(135deg,#ff4444,#ff6b35);box-shadow:0 3px 10px rgba(255,68,68,0.4);color:#fff;font-weight:800;">⚡ Flash Sale</div>
                                </c:when>
                                <c:when test="${vs.index < 3}">
                                    <div class="badge-hot">🔥 Hot</div>
                                </c:when>
                                <c:when test="${vs.index >= 3 and vs.index < 6}">
                                    <div class="badge-new">Mới</div>
                                </c:when>
                            </c:choose>

                            <%-- Giá trên ảnh --%>
                            <c:if test="${not empty p.sizes}">
                                <c:choose>
                                    <c:when test="${isPOnSale}">
                                        <div class="p-price-thumb" style="background:linear-gradient(135deg,#ff4444,#ff6b35);box-shadow:0 3px 10px rgba(255,68,68,0.4);color:#fff;font-weight:800;">
                                            ⚡ Giá Sale <fmt:formatNumber value="${p.sizes[0].price}" type="number" groupingUsed="true"/>đ
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="p-price-thumb">
                                            từ <fmt:formatNumber value="${p.sizes[0].price}" type="number" groupingUsed="true"/>đ
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </div>

                        <!-- Nội dung -->
                        <div class="p-body">
                            <div class="p-name">${p.productName}</div>
                            <c:if test="${not empty p.description}">
                                <div class="p-desc">${p.description}</div>
                            </c:if>
                            <div class="p-rating">
                                <c:choose>
                                    <c:when test="${totalFeedback > 0}">
                                        <span class="p-stars">⭐</span>
                                        <span><fmt:formatNumber value="${avgRating}" maxFractionDigits="1" minFractionDigits="1"/> (${totalFeedback} đánh giá quán)</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color: var(--text-dim); font-size: 11px;">Món mới • Chưa có đánh giá</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Footer card -->
                        <div class="p-footer">
                            <div class="p-price">
                                <c:choose>
                                    <c:when test="${isPOnSale}">
                                        <div style="display:flex;flex-direction:column;gap:2px;">
                                            <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
                                                <span style="color:#ef4444;font-weight:800;font-size:16.5px;"><fmt:formatNumber value="${p.sizes[0].price}" type="number" groupingUsed="true"/>đ</span>
                                                <c:if test="${p.sizes[0].originalPrice > 0 and p.sizes[0].originalPrice ne p.sizes[0].price}">
                                                    <del style="color:var(--text-dim);font-size:12px;font-weight:500;"><fmt:formatNumber value="${p.sizes[0].originalPrice}" type="number" groupingUsed="true"/>đ</del>
                                                </c:if>
                                                <span style="font-size:10px;font-weight:800;background:#fef2f2;color:#ef4444;border:1px solid #fecaca;padding:1px 6px;border-radius:4px;">⚡ Sale</span>
                                            </div>
                                            <c:if test="${not empty p.sizes[0].saleEndTime}">
                                                <div class="fs-countdown-tag" data-endtime="${p.sizes[0].saleEndTime}">
                                                    ⏱️ Kết thúc: <span class="fs-time-val">--:--:--</span>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:when>
                                    <c:when test="${not empty p.sizes}">
                                        <fmt:formatNumber value="${p.sizes[0].price}" type="number" groupingUsed="true"/>đ
                                        <small>Từ size nhỏ nhất</small>
                                    </c:when>
                                    <c:otherwise>
                                        Liên hệ
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <button class="btn-add"
                                    <c:if test="${p.staTus eq 'OUT_OF_STOCK'}">disabled title="Hết hàng"</c:if>
                                    <c:if test="${not shopOpenNow}">disabled title="Cửa hàng đang đóng cửa"</c:if>
                                    onclick="openModal(${p.id}, '${fn:escapeXml(p.productName)}', '${fn:escapeXml(p.description)}', ${shop.id}, ${p.categoryId},
                                        [<c:forEach var="s" items="${p.sizes}" varStatus="st">{id:${s.id},name:'${fn:escapeXml(s.sizeName)}',price:${s.price},originalPrice:${s.originalPrice},hasSale:${not empty s.salePrice and s.salePrice > 0},outOfStock:${s.outOfStock}}<c:if test="${!st.last}">,</c:if></c:forEach>])">
                                +
                            </button>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div id="noResults" class="empty-state" style="display:none;">
                <div class="e-icon">🔍</div>
                <div class="e-title">Không có món nào trong danh mục này</div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- ═══════════════════ MODAL THÊM VÀO GIỎ ═══════════════════ -->
<div class="modal-overlay" id="modalOverlay" onclick="closeModalOnBg(event)">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title-wrap">
                <div class="m-name" id="modalTitle">Chọn tùy chọn</div>
                <div class="m-sub" id="modalDesc"></div>
            </div>
            <button class="modal-close" onclick="closeModal()">×</button>
        </div>

        <div class="modal-body">
            <form action="${pageContext.request.contextPath}/user/add-to-cart" method="post" id="addToCartForm">
<input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="productId" id="modalProductId">
                <input type="hidden" name="shopId" value="${shop.id}">
                <input type="hidden" name="confirmSwitchShop" id="confirmSwitchShop" value="">

                <!-- Size -->
                <div id="sizeSection">
                    <div class="m-section-title">
                        Chọn size <span class="m-required">*</span>
                    </div>
                    <div class="flex gap-2 flex-wrap" id="sizeOptions" style="display:flex;flex-wrap:wrap;gap:8px;"></div>
                </div>

                <!-- Topping -->
                <c:if test="${not empty toppings}">
                    <div style="margin-top:18px;">
                        <div class="m-section-title">Topping (tuỳ chọn)</div>
                        <c:forEach var="tc" items="${toppingCategories}">
                            <c:set var="hasTopping" value="false"/>
                            <c:forEach var="t" items="${toppings}">
                                <c:if test="${t.toppingCategoryId == tc.id}"><c:set var="hasTopping" value="true"/></c:if>
                            </c:forEach>
                            <c:if test="${hasTopping}">
                                <div data-topping-group data-category-ids="<c:forEach var="cid" items="${tc.categoryIds}" varStatus="cidVs">${cid}<c:if test="${!cidVs.last}">,</c:if></c:forEach>">
                                    <c:forEach var="t" items="${toppings}">
                                        <c:if test="${t.toppingCategoryId == tc.id}">
                                            <c:set var="toppingHetHang" value="${fn:toUpperCase(t.status) == 'OUT_OF_STOCK'}"/>
                                            <label class="topping-item ${toppingHetHang ? 'topping-item-disabled' : ''}" for="topping_${t.id}">
                                                <input type="checkbox" class="topping-check" id="topping_${t.id}"
                                                       name="toppingId" value="${t.id}" data-price="${t.price}"
                                                       onchange="toggleTopping(this, ${t.id})" ${toppingHetHang ? 'disabled' : ''}>
                                                <span class="t-name">${t.toppingName}<c:if test="${toppingHetHang}"> (Hết hàng)</c:if></span>
                                                <span class="t-price">+<fmt:formatNumber value="${t.price}" type="number" groupingUsed="true"/>đ</span>
                                                <span class="t-qty-row" id="toppingQtyRow_${t.id}" style="display:none;">
                                                    <button type="button" class="t-qty-btn" onclick="event.preventDefault();event.stopPropagation();changeToppingQty(${t.id},-1)">−</button>
                                                    <span class="t-qty-val" id="toppingQtyVal_${t.id}">1</span>
                                                    <button type="button" class="t-qty-btn" onclick="event.preventDefault();event.stopPropagation();changeToppingQty(${t.id},1)">+</button>
                                                </span>
                                                <input type="hidden" name="toppingQty" id="toppingQtyInput_${t.id}" value="1" disabled>
                                            </label>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </c:if>

                <!-- Số lượng -->
                <div style="margin-top:18px;">
                    <div class="m-section-title">Số lượng</div>
                    <div class="qty-row">
                        <button type="button" class="qty-btn" onclick="changeQty(-1)">−</button>
                        <span class="qty-val" id="qtyDisplay">1</span>
                        <button type="button" class="qty-btn" onclick="changeQty(1)">+</button>
                        <input type="hidden" name="quantity" id="qtyInput" value="1">
                    </div>
                </div>

                <!-- Tổng tiền -->
                <div class="m-summary">
                    <span class="s-label">🧾 Tạm tính</span>
                    <span class="s-total" id="totalPrice">—</span>
                </div>

                <button type="submit" class="btn-submit" id="submitBtn">
                    🛒 Thêm vào giỏ hàng
                </button>
            </form>
        </div>
    </div>
</div>

<!-- ═══════════════════ CART BAR ═══════════════════ -->
<div class="cart-bar" id="cartBar">
    <div class="cart-bar-label">
        🛒 Đã thêm vào giỏ hàng!
        <small>Tiếp tục chọn thêm hoặc thanh toán</small>
    </div>
    <a href="${pageContext.request.contextPath}/checkout?cartId=${param.cartId}" class="cart-bar-btn">
        Thanh toán →
    </a>
</div>

<!-- ═══════════════════ COMBO SUGGESTION POPUP ═══════════════════ -->
<c:if test="${param.added eq '1' and not empty comboSuggestions}">
<div id="comboPopupOverlay" class="combo-popup-overlay" onclick="closeComboPopup()"></div>
<div id="comboPopup" class="combo-popup" role="dialog" aria-modal="true" aria-label="Gợi ý mua kèm">
    <div class="combo-popup-header">
        <div>
            <div class="combo-popup-title">🍽️ Mua kèm thêm?</div>
            <c:if test="${not empty addedProductName}">
                <div class="combo-popup-sub">Khách hàng thường order cùng <strong>${fn:escapeXml(addedProductName)}</strong></div>
            </c:if>
        </div>
        <button class="combo-popup-close" onclick="closeComboPopup()" aria-label="Đóng">×</button>
    </div>
    <div class="combo-popup-body">
        <c:forEach var="sg" items="${comboSuggestions}">
            <div class="combo-card">
                <div class="combo-card-img">
                    <c:choose>
                        <c:when test="${not empty sg.productImageUrl}">
                            <img src="${fn:escapeXml(sg.productImageUrl)}" alt="${fn:escapeXml(sg.productName)}" loading="lazy">
                        </c:when>
                        <c:otherwise>
                            <div class="combo-card-img-placeholder">🍴</div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="combo-card-info">
                    <div class="combo-card-name">${fn:escapeXml(sg.productName)}</div>
                    <div class="combo-card-size">${fn:escapeXml(sg.sizeName)}</div>
                    <div class="combo-card-price"><fmt:formatNumber value="${sg.sizePrice}" type="number" groupingUsed="true"/>đ</div>
                </div>
                <button class="combo-card-btn"
                        onclick="openSuggestionModal(${sg.productId}); return false;"
                        title="Thêm ${fn:escapeXml(sg.productName)}">
                    +
                </button>
            </div>
        </c:forEach>
    </div>
    <div class="combo-popup-footer">
        <button class="combo-btn-dismiss" onclick="closeComboPopup()">Bỏ qua</button>
        <a href="${pageContext.request.contextPath}/checkout?cartId=${param.cartId}" class="combo-btn-checkout">
            Thanh toán ngay →
        </a>
    </div>
</div>
</c:if>

<style>
/* ── Combo Suggestion Popup ── */
.combo-popup-overlay {
    display: none;
    position: fixed; inset: 0;
    background: rgba(0,0,0,.35);
    z-index: 499;
    backdrop-filter: blur(2px);
}
.combo-popup {
    display: none;
    position: fixed;
    bottom: 24px; right: 24px;
    width: 340px;
    max-width: calc(100vw - 32px);
    background: #fff;
    border-radius: 20px;
    box-shadow: 0 20px 60px rgba(99,44,20,.22);
    z-index: 500;
    overflow: hidden;
    border: 1px solid var(--border-color);
    animation: comboSlideIn .32s cubic-bezier(.16,1,.3,1);
}
@keyframes comboSlideIn {
    from { opacity: 0; transform: translateY(28px) scale(.97); }
    to   { opacity: 1; transform: translateY(0) scale(1); }
}
.combo-popup-header {
    display: flex; align-items: flex-start; justify-content: space-between;
    gap: 12px;
    padding: 16px 16px 12px;
    border-bottom: 1px solid var(--border-color);
    background: var(--primary-light);
}
.combo-popup-title {
    font-size: 15px; font-weight: 800; color: var(--primary);
    letter-spacing: -.02em;
}
.combo-popup-sub {
    font-size: 12px; color: var(--text-muted); margin-top: 3px; line-height: 1.4;
}
.combo-popup-close {
    background: none; border: none; cursor: pointer;
    font-size: 22px; line-height: 1; color: var(--text-dim);
    padding: 0 4px; flex-shrink: 0; margin-top: -2px;
    transition: color .15s;
}
.combo-popup-close:hover { color: var(--primary); }
.combo-popup-body {
    max-height: 320px; overflow-y: auto; padding: 10px 12px;
    display: flex; flex-direction: column; gap: 8px;
}
.combo-card {
    display: flex; align-items: center; gap: 10px;
    background: var(--bg-page); border-radius: 12px;
    border: 1px solid var(--border-color);
    padding: 8px 10px;
    transition: border-color .15s, background .15s;
}
.combo-card:hover { border-color: var(--primary); background: var(--primary-light); }
.combo-card-img {
    width: 52px; height: 52px; border-radius: 10px; overflow: hidden; flex-shrink: 0;
    background: #F1E4D6; display: flex; align-items: center; justify-content: center;
}
.combo-card-img img { width: 100%; height: 100%; object-fit: cover; }
.combo-card-img-placeholder { font-size: 22px; }
.combo-card-info { flex: 1; min-width: 0; }
.combo-card-name {
    font-size: 13px; font-weight: 700; color: var(--text-main);
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.combo-card-size { font-size: 11px; color: var(--text-dim); margin-top: 1px; }
.combo-card-price { font-size: 13px; font-weight: 700; color: var(--primary); margin-top: 3px; }
.combo-card-btn {
    width: 34px; height: 34px; border-radius: 50%;
    background: var(--primary); color: #fff; border: none;
    font-size: 20px; line-height: 1; cursor: pointer; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center;
    box-shadow: 0 4px 12px rgba(255,59,31,.32);
    transition: background .15s, transform .1s;
}
.combo-card-btn:hover { background: var(--primary-hover); transform: scale(1.1); }
.combo-popup-footer {
    display: flex; align-items: center; justify-content: space-between; gap: 8px;
    padding: 10px 12px 14px;
    border-top: 1px solid var(--border-color);
}
.combo-btn-dismiss {
    background: none; border: 1px solid var(--border-color);
    color: var(--text-muted); font-size: 13px; padding: 7px 14px;
    border-radius: 50px; cursor: pointer; font-family: inherit;
    transition: border-color .15s, color .15s;
}
.combo-btn-dismiss:hover { border-color: var(--primary); color: var(--primary); }
.combo-btn-checkout {
    background: var(--primary); color: #fff;
    font-size: 13px; font-weight: 700; padding: 7px 18px;
    border-radius: 50px; text-decoration: none;
    box-shadow: var(--glow-primary);
    transition: background .15s;
}
.combo-btn-checkout:hover { background: var(--primary-hover); }

/* Countdown ring */
.combo-popup-close::after {
    content: '';
    position: absolute;
    inset: 0;
}

/* Mobile: bottom sheet */
@media (max-width: 600px) {
    .combo-popup {
        bottom: 0; right: 0; left: 0;
        width: 100%; max-width: 100%;
        border-radius: 20px 20px 0 0;
        animation: comboSlideUp .32s cubic-bezier(.16,1,.3,1);
    }
    @keyframes comboSlideUp {
        from { opacity: 0; transform: translateY(100%); }
        to   { opacity: 1; transform: translateY(0); }
    }
}
</style>

<script>
    var currentSizes = [];
    var selectedSizePrice = 0;
    var qty = 1;
    var selectedToppings = {}; // { toppingId: { price, qty } }

    /* ── Open modal ── */
    function openModal(productId, productName, productDesc, shopId, categoryId, sizes) {
        // Chi hien nhom topping ap dung cho MOI loai san pham (khong gan loai nao) hoac co chua
        // dung loai san pham cua mon dang chon - giong logic da dung o Banhang.jsp (Shop POS).
        document.querySelectorAll('[data-topping-group]').forEach(function (group) {
            var idsRaw = (group.dataset.categoryIds || '').trim();
            var ids = idsRaw ? idsRaw.split(',') : [];
            var visible = ids.length === 0 || ids.indexOf(String(categoryId || '')) !== -1;
            group.style.display = visible ? '' : 'none';
        });

        document.getElementById('modalProductId').value = productId;
        document.getElementById('modalTitle').textContent = productName;
        document.getElementById('modalDesc').textContent = productDesc || '';

        currentSizes = sizes;
        qty = 1;
        document.getElementById('qtyDisplay').textContent = 1;
        document.getElementById('qtyInput').value = 1;

        var sizeSection = document.getElementById('sizeSection');
        var sizeOptions = document.getElementById('sizeOptions');
        sizeOptions.innerHTML = '';

        if (sizes && sizes.length > 0) {
            var isSingleDefault = (sizes.length === 1 && (sizes[0].name === 'Mặc định' || sizes[0].name === 'Tiêu chuẩn' || !sizes[0].name || sizes[0].name.trim() === ''));
            sizeSection.style.display = isSingleDefault ? 'none' : 'block';

            var firstAvailableIndex = sizes.findIndex(function(s) { return !s.outOfStock; });
            if (firstAvailableIndex === -1) firstAvailableIndex = 0; // het hang het thi van cho chon (khong con lua chon nao khac)
            sizes.forEach(function(s, i) {
                var uid = 'sz_' + s.id;
                var inp = document.createElement('input');
                inp.type = 'radio'; inp.name = 'sizeId'; inp.value = s.id;
                inp.id = uid; inp.className = 'size-radio';
                if (s.outOfStock) inp.disabled = true;
                if (i === firstAvailableIndex) { inp.checked = true; selectedSizePrice = s.price; }
                inp.addEventListener('change', function() {
                    selectedSizePrice = s.price;
                    updateTotal();
                });

                var lbl = document.createElement('label');
                lbl.htmlFor = uid; lbl.className = 'size-label' + (s.outOfStock ? ' size-label-disabled' : '');

                var priceHtml;
                if (s.hasSale) {
                    priceHtml = '<span class="s-price" style="color:var(--primary);font-weight:800;">' + s.price.toLocaleString('vi-VN') + 'đ</span>'
                              + '<span class="s-price-orig" style="font-size:11px;text-decoration:line-through;color:var(--text-dim);margin-left:6px;">' + s.originalPrice.toLocaleString('vi-VN') + 'đ</span>';
                } else {
                    priceHtml = '<span class="s-price">' + s.price.toLocaleString('vi-VN') + 'đ</span>';
                }
                lbl.innerHTML = '<span class="s-name">' + s.name + (s.outOfStock ? ' (Hết hàng)' : '') + '</span>' + priceHtml;

                sizeOptions.appendChild(inp);
                sizeOptions.appendChild(lbl);
            });
        } else {
            sizeSection.style.display = 'none';
            selectedSizePrice = 0;
        }

        /* Reset topping (checkbox dung chung giua cac san pham, phai reset moi lan mo modal) */
        selectedToppings = {};
        document.querySelectorAll('.topping-check').forEach(function(cb) {
            cb.checked = false;
            var tId = cb.value;
            var qtyRow = document.getElementById('toppingQtyRow_' + tId);
            var qtyVal = document.getElementById('toppingQtyVal_' + tId);
            var qtyInput = document.getElementById('toppingQtyInput_' + tId);
            var row = cb.closest('.topping-item');
            if (qtyRow) qtyRow.style.display = 'none';
            if (qtyVal) qtyVal.textContent = 1;
            if (qtyInput) { qtyInput.value = 1; qtyInput.disabled = true; }
            if (row) row.classList.remove('checked');
        });

        updateTotal();
        document.getElementById('modalOverlay').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeModal() {
        document.getElementById('modalOverlay').classList.remove('open');
        document.body.style.overflow = '';
    }
    function closeModalOnBg(e) {
        if (e.target === document.getElementById('modalOverlay')) closeModal();
    }

    /* ── Quantity ── */
    function changeQty(delta) {
        qty = Math.max(1, Math.min(99, qty + delta));
        document.getElementById('qtyDisplay').textContent = qty;
        document.getElementById('qtyInput').value = qty;
        updateTotal();
    }

    function updateTotal() {
        var total = selectedSizePrice * qty;
        for (var tId in selectedToppings) {
            total += selectedToppings[tId].price * selectedToppings[tId].qty;
        }
        document.getElementById('totalPrice').textContent =
            total > 0 ? total.toLocaleString('vi-VN') + 'đ' : '—';
    }

    /* ── Topping ── */
    function toggleTopping(checkbox, toppingId) {
        var qtyRow = document.getElementById('toppingQtyRow_' + toppingId);
        var qtyInput = document.getElementById('toppingQtyInput_' + toppingId);
        var row = checkbox.closest('.topping-item');
        if (checkbox.checked) {
            var price = parseFloat(checkbox.dataset.price) || 0;
            selectedToppings[toppingId] = { price: price, qty: 1 };
            document.getElementById('toppingQtyVal_' + toppingId).textContent = 1;
            qtyInput.value = 1;
            qtyInput.disabled = false;
            qtyRow.style.display = 'inline-flex';
            if (row) row.classList.add('checked');
        } else {
            delete selectedToppings[toppingId];
            qtyInput.disabled = true;
            qtyRow.style.display = 'none';
            if (row) row.classList.remove('checked');
        }
        updateTotal();
    }

    function changeToppingQty(toppingId, delta) {
        var t = selectedToppings[toppingId];
        if (!t) return;
        t.qty = Math.max(1, Math.min(99, t.qty + delta));
        document.getElementById('toppingQtyVal_' + toppingId).textContent = t.qty;
        document.getElementById('toppingQtyInput_' + toppingId).value = t.qty;
        updateTotal();
    }

    /* ── Category filter ── */
    function filterCategory(catId, btn) {
        document.querySelectorAll('.cat-pill').forEach(function(p) { p.classList.remove('active'); });
        btn.classList.add('active');

        if (catId === 'combo') {
            var comboSec = document.getElementById('comboSection');
            if (comboSec) comboSec.scrollIntoView({ behavior: 'smooth' });
            return;
        }

        var cards = document.querySelectorAll('#productGrid .product-card');
        var visible = 0;
        cards.forEach(function(card) {
            var show = false;
            if (catId === 'all') {
                show = true;
            } else if (catId === 'flash') {
                show = card.dataset.hasSale === 'true';
            } else {
                show = card.dataset.cat == catId;
            }
            card.style.display = show ? '' : 'none';
            if (show) visible++;
        });

        var noR = document.getElementById('noResults');
        if (noR) noR.style.display = (visible === 0) ? 'block' : 'none';
        var cnt = document.getElementById('productCount');
        if (cnt) cnt.textContent = visible + ' món';
    }

    /* ── Form validation ── */
    var cartHasOtherShop = ${cartHasOtherShop};
    var cartOtherShopName = '<c:out value="${cartOtherShopName}"/>';

    function submitAddCombo(form) {
        if (cartHasOtherShop) {
            pobConfirm('Giỏ hàng của bạn đang có món từ "' + cartOtherShopName + '".\nThêm combo từ shop này sẽ XOÁ toàn bộ giỏ hàng cũ. Bạn có muốn tiếp tục?').then(function(ok) {
                if (!ok) return;
                var inp = form.querySelector('.combo-confirm-switch');
                if (inp) inp.value = '1';
                form.submit();
            });
            return false;
        }
        return true;
    }

    document.getElementById('addToCartForm').addEventListener('submit', function(e) {
        var form = this;
        var ss = document.getElementById('sizeSection');
        if (ss && ss.style.display !== 'none') {
            if (!document.querySelector('input[name="sizeId"]:checked')) {
                e.preventDefault();
                alert('Vui lòng chọn size trước khi thêm vào giỏ!');
                return;
            }
        }

        // Giỏ hàng chỉ chứa món của 1 Shop tại 1 thời điểm - nếu giỏ đang có món của Shop khác,
        // hỏi xác nhận trước khi cho đổi Shop (giống luồng GrabFood/ShopeeFood).
        if (cartHasOtherShop) {
            e.preventDefault();
            pobConfirm('Giỏ hàng của bạn đang có món từ "' + cartOtherShopName + '".\nThêm món từ shop này sẽ XOÁ toàn bộ giỏ hàng cũ. Bạn có muốn tiếp tục?').then(function(ok) {
                if (!ok) return;
                document.getElementById('confirmSwitchShop').value = '1';
                form.submit();
            });
        }
    });

    /* ── Cart bar ── */
    (function() {
        var bar = document.getElementById('cartBar');
        var added = '${param.added}';
        if (added === '1') {
            bar.classList.add('visible');
        }
    })();

    /* ── Keyboard: ESC to close ── */
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') { closeModal(); closeComboPopup(); }
    });

    /* ── Combo Suggestion Popup ── */
    var comboPopupTimer = null;
    function closeComboPopup() {
        var popup = document.getElementById('comboPopup');
        var overlay = document.getElementById('comboPopupOverlay');
        if (!popup) return;
        popup.style.animation = 'none';
        popup.style.opacity = '0';
        popup.style.transform = 'translateY(20px)';
        popup.style.transition = 'opacity .2s, transform .2s';
        if (overlay) { overlay.style.opacity = '0'; overlay.style.transition = 'opacity .2s'; }
        setTimeout(function() {
            popup.style.display = 'none';
            if (overlay) overlay.style.display = 'none';
        }, 200);
        if (comboPopupTimer) clearTimeout(comboPopupTimer);
    }

    function openSuggestionModal(productId) {
        // Đóng popup combo trước
        closeComboPopup();
        // Tìm sản phẩm trong danh sách hiện có và mở modal thêm giỏ hàng
        var card = document.getElementById('pcard-' + productId);
        if (card) {
            var btn = card.querySelector('.btn-add');
            if (btn && !btn.disabled) btn.click();
        }
    }

    (function initComboPopup() {
        var popup = document.getElementById('comboPopup');
        var overlay = document.getElementById('comboPopupOverlay');
        if (!popup) return;
        popup.style.display = 'block';
        if (overlay) overlay.style.display = 'block';
        // Auto-dismiss sau 10 giây
        comboPopupTimer = setTimeout(closeComboPopup, 10000);
    })();

    /* ── Flash Sale Realtime Countdown ── */
    function initFlashSaleCountdowns() {
        function updateAllTimers() {
            var tags = document.querySelectorAll('.fs-countdown-tag');
            var now = new Date().getTime();

            tags.forEach(function(tag) {
                var endTimeStr = tag.getAttribute('data-endtime');
                if (!endTimeStr) return;

                var cleanStr = String(endTimeStr).trim().replace(' ', 'T');
                var endTime = new Date(cleanStr).getTime();
                if (isNaN(endTime)) {
                    var parts = cleanStr.split(/[-T:\s]/);
                    if (parts.length >= 5) {
                        endTime = new Date(parseInt(parts[0]), parseInt(parts[1])-1, parseInt(parts[2]), parseInt(parts[3]), parseInt(parts[4])).getTime();
                    }
                }

                var valSpan = tag.querySelector('.fs-time-val');
                if (!valSpan) return;

                if (isNaN(endTime) || !endTime) return;

                var diff = endTime - now;
                if (diff <= 0) {
                    valSpan.textContent = 'Đã hết hạn';
                    return;
                }

                var days = Math.floor(diff / (1000 * 60 * 60 * 24));
                var hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                var minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                var seconds = Math.floor((diff % (1000 * 60)) / 1000);

                var pad = function(n) { return n < 10 ? '0' + n : n; };
                var text = (days > 0 ? days + 'd ' : '') + pad(hours) + ':' + pad(minutes) + ':' + pad(seconds);
                valSpan.textContent = text;
            });
        }

        updateAllTimers();
        setInterval(updateAllTimers, 1000);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initFlashSaleCountdowns);
    } else {
        initFlashSaleCountdowns();
    }
</script>
<script>window.POB_CONTEXT_PATH = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pob-dialog.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/notifications-ws.js"></script>
</body>
</html>
