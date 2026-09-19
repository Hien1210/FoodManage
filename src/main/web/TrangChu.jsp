<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FOOD MANAGE | Giao đồ ăn thần tốc</title>
    <meta name="description" content="Đặt đồ ăn nhanh chóng, tươi ngon giao tận cửa. Hàng ngàn món ăn hấp dẫn đang chờ bạn khám phá trên FOOD MANAGE.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Quicksand:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=swap" rel="stylesheet">
    <style>
        :root {
            /* Nền 60% — kem nhạt, giúp ảnh món ăn nổi bật */
            --cream: #FFF9F2;
            --paper: #FFFFFF;
            --ink: #2D2421;
            --muted: #635752;
            --outline: #8A7B6C;
            --line: #F0E2D3;

            /* Thương hiệu 30% — dải cam-nâu cho Header/Footer/banner ưu đãi */
            --brand-700: #A83900;
            --brand-500: #FE6A2B;

            /* CTA 10% — đỏ tươi nổi bật */
            --primary: #FF3B1F;
            --primary-dark: #E02A10;
            --gold: #FFB300;

            --font-display: 'Quicksand', sans-serif;
            --font-b: 'Plus Jakarta Sans', sans-serif;
            --r-sm: 12px; --r-md: 16px; --r-lg: 24px; --r-xl: 32px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }
        html { scroll-behavior: smooth; max-width: 100%; overflow-x: hidden; }
        body { font-family: var(--font-b); background: var(--cream); color: var(--ink); line-height: 1.6; overflow-x: hidden; max-width: 100%; }
        a { text-decoration: none; color: inherit; }
        ul { list-style: none; }
        img { max-width: 100%; display: block; }
        button { font-family: inherit; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; vertical-align: middle; line-height: 1; }
        .material-symbols-outlined.fill { font-variation-settings: 'FILL' 1, 'wght' 500, 'GRAD' 0, 'opsz' 24; }
        .container { width: 100%; max-width: 1280px; margin: 0 auto; padding: 0 24px; }
        .eyebrow-sm { display: inline-block; color: var(--brand-700); font-family: var(--font-b); font-weight: 800; letter-spacing: .08em; text-transform: uppercase; font-size: .78rem; margin-bottom: .5rem; }

        /* ============ HEADER — khối thương hiệu (30%) ============ */
        header.site { position: sticky; top: 0; z-index: 100; background: linear-gradient(100deg, var(--brand-700), var(--brand-500)); box-shadow: 0 4px 20px rgba(168,57,0,.2); }
        .nav-inner { display: flex; align-items: center; gap: 20px; height: 80px; }
        .logo { display: flex; align-items: center; gap: 10px; font-family: var(--font-display); font-weight: 700; font-size: 1.4rem; color: #fff; flex-shrink: 0; }
        .logo svg { width: 34px; height: 34px; flex-shrink: 0; }
        .nav-links { display: flex; gap: 4px; margin-left: 12px; flex: 1; }
        .nav-links a { padding: 8px 16px; border-radius: 50px; color: rgba(255,255,255,.88); font-weight: 600; font-size: .92rem; transition: all .2s; }
        .nav-links a:hover { color: #fff; }
        .nav-links a.active { background: rgba(255,255,255,.18); color: #fff; }
        .nav-actions { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
        .loc-pill { display: flex; align-items: center; gap: 6px; background: rgba(255,255,255,.14); padding: 7px 14px; border-radius: 50px; color: #fff; cursor: pointer; }
        .loc-pill .lbl { display: flex; flex-direction: column; line-height: 1.2; }
        .loc-pill .lbl small { font-size: .65rem; color: rgba(255,255,255,.75); }
        .loc-pill .lbl strong { font-size: .8rem; font-weight: 700; max-width: 130px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .icon-btn { width: 40px; height: 40px; border-radius: 50%; background: rgba(255,255,255,.14); display: flex; align-items: center; justify-content: center; color: #fff; position: relative; flex-shrink: 0; border: none; cursor: pointer; }
        .icon-btn:hover { background: rgba(255,255,255,.24); }
        .icon-btn .badge { position: absolute; top: -3px; right: -3px; background: var(--primary); color: #fff; font-size: .62rem; font-weight: 800; min-width: 17px; height: 17px; padding: 0 3px; border-radius: 50%; display: flex; align-items: center; justify-content: center; }

        /* ============ BUTTONS ============ */
        .btn { display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: .85rem 1.7rem; border-radius: 50px; font-weight: 700; font-size: .95rem; cursor: pointer; border: none; transition: all .2s; white-space: nowrap; }
        .btn-cta { background: var(--primary); color: #fff; box-shadow: 0 8px 20px rgba(255,59,31,.35); }
        .btn-cta:hover { background: var(--primary-dark); transform: translateY(-2px); }
        .btn-outline { background: var(--paper); color: var(--brand-700); box-shadow: 0 4px 16px -2px rgba(99,44,20,.08); }
        .btn-outline:hover { background: var(--cream); }
        .btn-white { background: #fff; color: var(--brand-700); }
        .btn-white:hover { transform: translateY(-2px); box-shadow: 0 10px 24px rgba(0,0,0,.18); }
        .btn-onbrand { background: rgba(255,255,255,.16); color: #fff; border: 1.5px solid rgba(255,255,255,.4); }
        .btn-onbrand:hover { background: rgba(255,255,255,.28); }
        .btn-lg { padding: 1rem 2.1rem; }

        /* ============ HERO ============ */
        .hero { padding: 2.5rem 0 3.5rem; position: relative; overflow: hidden; }
        .hero::before { content:''; position:absolute; top:-140px; left:50%; transform:translateX(-50%); width:900px; height:400px; background: radial-gradient(ellipse, rgba(254,106,43,.10), transparent 70%); pointer-events:none; }
        .hero-grid { display: grid; grid-template-columns: 1.4fr 1fr; gap: 3rem; align-items: center; position: relative; }
        .hero-grid > * { min-width: 0; }
        .eyebrow { display: inline-flex; align-items: center; gap: 8px; padding: .5rem 1.1rem; background: var(--paper); border-radius: 50px; font-weight: 700; font-size: .85rem; color: var(--brand-700); box-shadow: 0 4px 16px -2px rgba(99,44,20,.08); margin-bottom: 1.2rem; }
        .eyebrow .ic { width: 22px; height: 22px; border-radius: 50%; background: rgba(255,59,31,.1); color: var(--primary); display:flex; align-items:center; justify-content:center; }
        .eyebrow .ic .material-symbols-outlined { font-size: 15px; }
        .hero h1 { font-size: 3rem; font-weight: 800; line-height: 1.15; letter-spacing: -1px; margin-bottom: 1rem; }
        .hero h1 .accent { background: linear-gradient(100deg, var(--brand-700), var(--brand-500)); -webkit-background-clip: text; background-clip: text; color: transparent; text-decoration: underline; text-decoration-color: var(--primary); text-decoration-style: wavy; }
        .hero p.sub { color: var(--muted); font-size: 1.08rem; max-width: 600px; margin-bottom: 1.5rem; }
        .search-bar { display: flex; align-items: center; gap: 8px; background: var(--paper); padding: 8px; border-radius: 50px; box-shadow: 0 8px 28px -4px rgba(99,44,20,.12); margin-bottom: 1rem; }
        .search-bar .search-ic { color: var(--brand-700); padding-left: 10px; display: flex; }
        .search-bar input { flex: 1; border: none; background: transparent; padding: .7rem .5rem; font-family: var(--font-b); font-size: .95rem; outline: none; color: var(--ink); min-width: 0; }
        .search-bar .loc-chip { display: none; align-items: center; gap: 6px; padding: 8px 14px; background: var(--cream); border-radius: 50px; color: var(--muted); font-weight: 700; font-size: .8rem; flex-shrink: 0; }
        .search-bar .loc-chip .material-symbols-outlined { color: var(--primary); font-size: 18px; }
        .search-bar button { flex-shrink: 0; }
        .trending { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; margin-bottom: 1.5rem; }
        .trending .lbl { font-size: .75rem; font-weight: 700; color: var(--outline); text-transform: uppercase; letter-spacing: .04em; display: flex; align-items: center; gap: 4px; }
        .trending .lbl .material-symbols-outlined { font-size: 15px; color: var(--brand-700); }
        .trending-tag { font-size: .8rem; font-weight: 600; padding: 6px 14px; background: var(--paper); color: var(--muted); border-radius: 50px; box-shadow: 0 2px 8px rgba(99,44,20,.06); border: none; cursor: pointer; transition: color .2s; }
        .trending-tag:hover { color: var(--primary); }
        .hero-ctas { display: flex; gap: 14px; margin-bottom: 1.8rem; flex-wrap: wrap; }
        .stats-ribbon { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; }
        .stat-card { background: var(--paper); padding: 14px 16px; border-radius: var(--r-md); box-shadow: 0 4px 16px -2px rgba(99,44,20,.06); }
        .stat-card strong { display: block; font-family: var(--font-display); font-size: 1.35rem; font-weight: 700; color: var(--brand-700); }
        .stat-card strong .material-symbols-outlined { font-size: 16px; color: var(--gold); }
        .stat-card span { font-size: .78rem; color: var(--muted); }

        .hero-dish { position: relative; max-width: 440px; margin: 0 auto; background: var(--paper); border-radius: var(--r-xl); padding: 14px; box-shadow: 0 16px 40px -6px rgba(99,44,20,.18); }
        .hero-dish .fast-badge { position: absolute; top: -12px; right: -10px; z-index: 2; background: var(--primary); color: #fff; padding: 7px 14px; border-radius: 50px; font-size: .78rem; font-weight: 800; box-shadow: 0 6px 16px rgba(255,59,31,.4); display: flex; align-items: center; gap: 5px; }
        .hero-dish .fast-badge .material-symbols-outlined { font-size: 16px; }
        .hero-dish .img-wrap { position: relative; height: 300px; border-radius: var(--r-lg); overflow: hidden; background: linear-gradient(135deg,#FFE1CC,#FFC8A8); }
        .hero-dish .img-wrap img { width: 100%; height: 100%; object-fit: cover; }
        .hero-dish .best-tag { position: absolute; top: 12px; left: 12px; background: linear-gradient(100deg, var(--brand-700), var(--brand-500)); color: #fff; padding: 5px 12px; border-radius: 50px; font-size: .74rem; font-weight: 800; display: flex; align-items: center; gap: 4px; }
        .hero-dish .best-tag .material-symbols-outlined { font-size: 13px; }
        .hero-dish-body { padding-top: 14px; }
        .hero-dish-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 6px; }
        .hero-dish-rating { display: flex; align-items: center; gap: 4px; }
        .hero-dish-rating .material-symbols-outlined { color: var(--gold); font-size: 17px; }
        .hero-dish-rating strong { font-weight: 800; font-size: .9rem; }
        .hero-dish-rating span { font-size: .78rem; color: var(--outline); }
        .hero-dish-save { font-size: .78rem; font-weight: 700; color: var(--primary); background: #FFEEE9; padding: 2px 10px; border-radius: 50px; }
        .hero-dish h3 { font-family: var(--font-display); font-weight: 700; font-size: 1.15rem; margin-bottom: 6px; }
        .hero-dish p { color: var(--muted); font-size: .85rem; margin-bottom: 12px; }
        .hero-dish-foot { display: flex; align-items: center; justify-content: space-between; }
        .hero-dish-price { display: flex; align-items: baseline; gap: 8px; }
        .hero-dish-price strong { font-family: var(--font-display); font-size: 1.3rem; font-weight: 700; color: var(--primary); }
        .hero-dish-price s { color: var(--outline); font-size: .82rem; }

        /* ============ SECTIONS chung ============ */
        .section { padding: 3.5rem 0; }
        .section-head { max-width: 680px; margin: 0 auto 2.5rem; text-align: center; }
        .section-head h2 { font-family: var(--font-display); font-size: 2rem; font-weight: 700; letter-spacing: -.5px; }
        .section-head p { color: var(--muted); margin-top: .5rem; }
        .section-alt { background: rgba(249,243,236,.6); }

        /* ============ TẠI SAO CHỌN ============ */
        .why-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.6rem; }
        .why-card { background: var(--paper); padding: 2rem; border-radius: var(--r-lg); box-shadow: 0 4px 16px -2px rgba(99,44,20,.06); transition: transform .3s; }
        .why-card:hover { transform: translateY(-6px); }
        .why-ic { width: 56px; height: 56px; border-radius: var(--r-md); background: #FFEBDD; color: var(--brand-700); display: flex; align-items: center; justify-content: center; margin-bottom: 1rem; }
        .why-ic .material-symbols-outlined { font-size: 26px; }
        .why-card h3 { font-family: var(--font-display); font-size: 1.1rem; font-weight: 700; margin-bottom: .5rem; }
        .why-card p { color: var(--muted); font-size: .9rem; margin-bottom: 1rem; }
        .why-link { display: flex; align-items: center; gap: 5px; color: var(--brand-700); font-weight: 700; font-size: .85rem; }
        .why-link .material-symbols-outlined { font-size: 16px; }

        /* ============ DANH MỤC ============ */
        .cat-head-row { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: flex-end; gap: 1.2rem; margin-bottom: 1.8rem; }
        .cat-badge { display: inline-flex; align-items: center; gap: 6px; background: linear-gradient(100deg, var(--brand-700), var(--brand-500)); color: #fff; padding: 5px 14px; border-radius: 50px; font-size: .72rem; font-weight: 800; text-transform: uppercase; letter-spacing: .05em; margin-bottom: .6rem; }
        .cat-badge .material-symbols-outlined { font-size: 15px; }
        .cat-head-row h2 { font-family: var(--font-display); font-size: 1.9rem; font-weight: 700; letter-spacing: -.5px; }
        .cat-head-row .desc { color: var(--muted); margin-top: .3rem; font-size: .92rem; }
        .filter-tabs { display: flex; gap: 4px; background: var(--paper); padding: 6px; border-radius: 50px; overflow-x: auto; flex-shrink: 0; }
        .filter-tab { padding: 8px 16px; border-radius: 50px; font-size: .82rem; font-weight: 700; color: var(--muted); background: none; border: none; cursor: pointer; white-space: nowrap; transition: all .2s; }
        .filter-tab.active { background: linear-gradient(100deg, var(--brand-700), var(--brand-500)); color: #fff; }
        .cat-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 1rem; }
        .cat-card { background: var(--paper); border-radius: var(--r-lg); padding: 1.3rem 1rem; text-align: center; box-shadow: 0 4px 16px -2px rgba(99,44,20,.06); transition: all .25s; }
        .cat-card:hover { transform: translateY(-4px); box-shadow: 0 8px 24px -2px rgba(99,44,20,.12); }
        .cat-card .ic-wrap { width: 60px; height: 60px; border-radius: 50%; background: #FFEBDD; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; margin: 0 auto .6rem; transition: transform .25s; }
        .cat-card:hover .ic-wrap { transform: scale(1.1); }
        .cat-card strong { display: block; font-family: var(--font-display); font-size: .85rem; font-weight: 700; line-height: 1.25; }
        .cat-card span { display: block; font-size: .74rem; font-weight: 700; color: var(--brand-700); margin-top: 3px; }

        /* ============ MENU NỔI BẬT ============ */
        .menu-head-row { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: flex-end; gap: 1.2rem; margin-bottom: 2rem; }
        .menu-head-row h2 { font-family: var(--font-display); font-size: 1.9rem; font-weight: 700; letter-spacing: -.5px; }
        .menu-head-row .desc { color: var(--muted); margin-top: .3rem; font-size: .92rem; }
        .menu-all-link { display: flex; align-items: center; gap: 6px; color: var(--brand-700); font-weight: 700; font-size: .9rem; flex-shrink: 0; }
        .menu-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.8rem; }
        .dish-card { background: var(--paper); border-radius: var(--r-lg); overflow: hidden; box-shadow: 0 4px 16px -2px rgba(99,44,20,.06); transition: all .3s; display: flex; flex-direction: column; }
        .dish-card:hover { transform: translateY(-6px); box-shadow: 0 12px 28px -4px rgba(99,44,20,.14); }
        .dish-img { position: relative; height: 210px; background: linear-gradient(135deg,#FFE8D6,#FFD3B4); display: flex; align-items: center; justify-content: center; font-size: 4rem; overflow: hidden; }
        .dish-img img { width: 100%; height: 100%; object-fit: cover; }
        .dish-tag { position: absolute; top: 12px; left: 12px; background: linear-gradient(100deg, var(--brand-700), var(--brand-500)); color: #fff; font-size: .72rem; font-weight: 800; padding: 5px 12px; border-radius: 50px; z-index: 2; }
        .dish-fav { position: absolute; top: 12px; right: 12px; width: 34px; height: 34px; border-radius: 50%; background: rgba(255,255,255,.85); display: flex; align-items: center; justify-content: center; color: var(--outline); border: none; cursor: pointer; z-index: 2; }
        .dish-fav .material-symbols-outlined { font-size: 19px; }
        .dish-body { padding: 1.3rem 1.4rem 1.5rem; display: flex; flex-direction: column; flex: 1; }
        .dish-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
        .dish-rating { display: flex; align-items: center; gap: 4px; }
        .dish-rating .material-symbols-outlined { color: var(--gold); font-size: 16px; }
        .dish-rating strong { font-weight: 800; font-size: .85rem; }
        .dish-rating span { color: var(--outline); font-size: .76rem; }
        .dish-shop { font-size: .76rem; color: var(--brand-700); font-weight: 700; max-width: 42%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .dish-body h3 { font-family: var(--font-display); font-size: 1.05rem; font-weight: 700; margin-bottom: 6px; }
        .dish-body p { color: var(--muted); font-size: .85rem; margin-bottom: 1.1rem; overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; flex: 1; }
        .dish-foot { display: flex; justify-content: space-between; align-items: center; }
        .dish-price { font-family: var(--font-display); font-weight: 700; font-size: 1.2rem; color: var(--primary); }
        .dish-add { display: flex; align-items: center; gap: 5px; background: var(--primary); color: #fff; border: none; padding: 8px 16px; border-radius: 50px; font-weight: 700; font-size: .82rem; cursor: pointer; transition: all .2s; }
        .dish-add:hover { background: var(--primary-dark); }
        .dish-add .material-symbols-outlined { font-size: 17px; }

        /* ============ PROMO BANNER ============ */
        .promo-card { position: relative; background: linear-gradient(100deg, var(--brand-700), var(--brand-500)); border-radius: var(--r-xl); padding: 3rem; overflow: hidden; display: grid; grid-template-columns: 1.7fr 1fr; gap: 2rem; align-items: center; }
        .promo-card::after { content:''; position:absolute; right:-60px; bottom:-60px; width:260px; height:260px; border-radius:50%; background: rgba(255,59,31,.18); filter: blur(10px); pointer-events:none; }
        .promo-badge { display: inline-flex; align-items: center; gap: 6px; background: rgba(255,255,255,.18); color: #fff; padding: 5px 14px; border-radius: 50px; font-size: .74rem; font-weight: 800; text-transform: uppercase; letter-spacing: .05em; margin-bottom: 1rem; }
        .promo-badge .material-symbols-outlined { font-size: 15px; }
        .promo-text { position: relative; z-index: 1; }
        .promo-text h2 { color: #fff; font-family: var(--font-display); font-size: 2rem; font-weight: 700; letter-spacing: -.5px; margin-bottom: .7rem; }
        .promo-text p { color: rgba(255,255,255,.88); max-width: 560px; margin-bottom: 1.4rem; }
        .promo-actions { display: flex; flex-wrap: wrap; gap: 14px; align-items: center; }
        .coupon-pill { display: flex; align-items: center; gap: 8px; background: rgba(255,255,255,.14); border: 1.5px dashed rgba(255,255,255,.5); padding: 10px 18px; border-radius: 50px; }
        .coupon-pill span.lbl { font-size: .74rem; color: rgba(255,255,255,.8); text-transform: uppercase; }
        .coupon-pill strong { font-family: var(--font-display); color: #fff; font-weight: 700; letter-spacing: .1em; }
        .coupon-pill button { background: none; border: none; color: #fff; cursor: pointer; display: flex; }
        .promo-visual { position: relative; z-index: 1; }
        .promo-visual .img-wrap { position: relative; border-radius: var(--r-lg); overflow: hidden; box-shadow: 0 20px 45px rgba(0,0,0,.25); transform: rotate(2deg); transition: transform .3s; aspect-ratio: 1/1; }
        .promo-visual .img-wrap:hover { transform: rotate(0deg); }
        .promo-visual .img-wrap img { width: 100%; height: 100%; object-fit: cover; }
        .promo-visual .overlay { position: absolute; inset: 0; background: linear-gradient(to top, rgba(168,57,0,.85), transparent 60%); display: flex; flex-direction: column; align-items: center; justify-content: flex-end; padding: 16px; text-align: center; }
        .promo-visual .overlay small { color: var(--gold); font-weight: 800; text-transform: uppercase; letter-spacing: .08em; font-size: .7rem; }
        .promo-visual .overlay strong { color: #fff; font-family: var(--font-display); font-weight: 700; }

        /* ============ ĐÁNH GIÁ ============ */
        .review-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.6rem; }
        .review-card { background: var(--paper); border-radius: var(--r-lg); padding: 2rem; box-shadow: 0 4px 16px -2px rgba(99,44,20,.06); display: flex; flex-direction: column; justify-content: space-between; }
        .review-stars { display: flex; gap: 2px; color: var(--gold); margin-bottom: .8rem; }
        .review-stars .material-symbols-outlined { font-size: 19px; }
        .review-card p.quote { font-style: italic; color: var(--ink); line-height: 1.7; font-size: .95rem; }
        .review-who { display: flex; align-items: center; gap: 12px; margin-top: 1.5rem; }
        .review-avatar { width: 46px; height: 46px; border-radius: 50%; background: linear-gradient(135deg, var(--brand-700), var(--brand-500)); color: #fff; display: flex; align-items: center; justify-content: center; font-family: var(--font-display); font-weight: 700; flex-shrink: 0; }
        .review-who strong { display: block; font-size: .92rem; }
        .review-who span { font-size: .78rem; color: var(--outline); }

        /* ============ FLOATING CTA ============ */
        .floating-cta { position: fixed; bottom: 22px; right: 22px; z-index: 90; display: flex; align-items: center; gap: 10px; background: linear-gradient(100deg, var(--brand-700), var(--brand-500)); color: #fff; padding: 10px 20px 10px 14px; border-radius: 50px; box-shadow: 0 16px 36px -6px rgba(99,44,20,.38); font-weight: 700; font-size: .88rem; transition: transform .25s; }
        .floating-cta:hover { transform: scale(1.05); }
        .floating-cta .ic { width: 32px; height: 32px; border-radius: 50%; background: rgba(255,255,255,.2); display: flex; align-items: center; justify-content: center; }
        .floating-cta .ic .material-symbols-outlined { font-size: 18px; }

        /* ============ FOOTER ============ */
        .footer { background: linear-gradient(100deg, var(--brand-700), var(--brand-500)); color: #fff; padding: 4rem 0 1.6rem; margin-top: 1rem; }
        .footer-grid { display: grid; grid-template-columns: 1.6fr 1fr 1fr 1.2fr; gap: 2.5rem; margin-bottom: 2.5rem; }
        .footer-brand .logo { color: #fff; margin-bottom: .9rem; }
        .footer-brand p { color: rgba(255,255,255,.85); font-size: .88rem; line-height: 1.7; margin-bottom: 1rem; }
        .footer-hotline small { display: block; text-transform: uppercase; letter-spacing: .06em; font-size: .72rem; color: rgba(255,255,255,.75); }
        .footer-hotline strong { font-family: var(--font-display); font-size: 1.2rem; font-weight: 700; }
        .footer h4 { font-family: var(--font-display); font-size: 1.05rem; font-weight: 700; margin-bottom: 1rem; }
        .footer a.flink { display: block; color: rgba(255,255,255,.85); font-size: .88rem; margin-bottom: .7rem; transition: color .2s; }
        .footer a.flink:hover { color: #fff; }
        .footer-app p { color: rgba(255,255,255,.85); font-size: .85rem; margin-bottom: 1rem; }
        .app-row { display: flex; gap: 12px; align-items: center; }
        .qr-box { width: 68px; height: 68px; background: rgba(255,255,255,.14); border-radius: 14px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .qr-box .material-symbols-outlined { font-size: 34px; }
        .store-btns { display: flex; flex-direction: column; gap: 8px; }
        .store-btn { display: flex; align-items: center; gap: 8px; background: rgba(255,255,255,.14); padding: 7px 14px; border-radius: 10px; }
        .store-btn:hover { background: rgba(255,255,255,.22); }
        .store-btn .material-symbols-outlined { font-size: 18px; }
        .store-btn .txt { display: flex; flex-direction: column; line-height: 1.15; }
        .store-btn .txt small { font-size: .62rem; color: rgba(255,255,255,.75); }
        .store-btn .txt strong { font-size: .8rem; font-weight: 700; }
        .footer-bottom { text-align: center; padding-top: 1.6rem; border-top: 1px solid rgba(255,255,255,.15); color: rgba(255,255,255,.75); font-size: .82rem; }

        /* ============ REVEAL ============ */
        .reveal { opacity: 0; transform: translateY(36px); transition: all .7s cubic-bezier(.175,.885,.32,1.275); }
        .reveal.active { opacity: 1; transform: translateY(0); }
        .delay-1 { transition-delay: .08s; }
        .delay-2 { transition-delay: .16s; }
        .delay-3 { transition-delay: .24s; }

        /* ============ RESPONSIVE ============ */
        @media (max-width: 1100px) {
            .hero-grid { grid-template-columns: 1fr; }
            .hero-dish { max-width: 480px; }
            .cat-grid { grid-template-columns: repeat(4, 1fr); }
            .footer-grid { grid-template-columns: 1fr 1fr; }
        }
        @media (max-width: 900px) {
            .why-grid, .menu-grid, .review-grid { grid-template-columns: 1fr 1fr; }
            .promo-card { grid-template-columns: 1fr; }
            .promo-visual { display: flex; justify-content: center; }
            .promo-visual .img-wrap { width: 220px; }
            .stats-ribbon { grid-template-columns: 1fr 1fr; }
        }
        @media (max-width: 720px) {
            .nav-links, .loc-pill { display: none; }
            .search-bar .loc-chip { display: none !important; }
            .nav-actions { gap: 6px; }
            .btn-cta .cta-label { display: none; }
            header.site .btn-cta { padding: .7rem .8rem; }
        }
        @media (max-width: 640px) {
            .hero h1 { font-size: 2.2rem; }
            .why-grid, .menu-grid, .review-grid, .cat-grid { grid-template-columns: 1fr; }
            .cat-head-row, .menu-head-row { flex-direction: column; align-items: flex-start; }
            .filter-tabs { width: 100%; max-width: 100%; min-width: 0; }
            .cat-head-row, .menu-head-row { min-width: 0; }
            .cat-head-row > * { min-width: 0; max-width: 100%; }
            .footer-grid { grid-template-columns: 1fr; gap: 2rem; }
            .floating-cta span.lbl-full { display: none; }
            .eyebrow, .hero-dish .fast-badge { white-space: normal; max-width: 100%; }
            .stats-ribbon { grid-template-columns: 1fr 1fr; }
            .container { padding: 0 16px; }
        }
    </style>
</head>
<body>

    <header id="header" class="site">
        <div class="container nav-inner">
            <a class="logo" href="${pageContext.request.contextPath}/">
                <svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M24 6C15 6 8 13 8 22c0 1.2.9 2 2 2h28c1.1 0 2-.8 2-2 0-9-7-16-16-16Z" fill="#fff"/>
                    <rect x="6" y="27" width="36" height="6" rx="3" fill="#fff"/>
                    <path d="M20 40c1 3 3 4 4 4s3-1 4-4" style="stroke:var(--primary)" stroke-width="3" stroke-linecap="round" fill="none"/>
                </svg>
                FoodManage
            </a>
            <nav class="nav-links">
                <a href="#home" class="active">Trang chủ</a>
                <a href="#featured-menu">Thực đơn</a>
                <a href="#categories-section">Danh mục</a>
                <a href="#about">Về chúng tôi</a>
                <a href="#footer">Liên hệ</a>
            </nav>
            <div class="nav-actions">
                <div class="loc-pill">
                    <span class="material-symbols-outlined">location_on</span>
                    <span class="lbl"><small>Giao tới</small><strong>Hà Nội</strong></span>
                </div>
                <button type="button" class="icon-btn" title="Tìm kiếm"><span class="material-symbols-outlined">search</span></button>
                <div class="icon-btn" title="Giỏ hàng">
                    <span class="material-symbols-outlined">shopping_bag</span>
                </div>
                <a href="${pageContext.request.contextPath}/dangnhap" class="btn btn-cta">
                    <span class="material-symbols-outlined fill">restaurant_menu</span>
                    <span class="cta-label">Đăng nhập / Đặt món</span>
                </a>
            </div>
        </div>
    </header>

    <main>
        <!-- Hero Section -->
        <section id="home" class="hero">
            <div class="container hero-grid">
                <div class="hero-content reveal">
                    <div class="eyebrow">
                        <span class="ic"><span class="material-symbols-outlined fill">local_fire_department</span></span>
                        Ưu đãi 50% cho đơn đầu tiên • Giao nhanh 20 phút
                    </div>
                    <h1>Đói bụng? Đã có <span class="accent">FoodManage!</span></h1>
                    <p class="sub">Khám phá hàng ngàn món ăn nóng hổi từ các quán ăn tuyển chọn hàng đầu. Đặt nhanh trong 3 bước, thưởng thức trọn vẹn hương vị yêu thích ngay tại nhà bạn.</p>

                    <form class="search-bar" action="${pageContext.request.contextPath}/dangnhap" method="get">
                        <span class="search-ic"><span class="material-symbols-outlined">search</span></span>
                        <input type="text" name="q" id="heroSearchInput" placeholder="Tìm món ăn, quán ăn, burger, trà sữa...">
                        <span class="loc-chip"><span class="material-symbols-outlined">location_on</span>Hà Nội</span>
                        <button type="submit" class="btn btn-cta">Tìm kiếm <span class="material-symbols-outlined" style="font-size:18px;">arrow_forward</span></button>
                    </form>

                    <div class="trending">
                        <span class="lbl"><span class="material-symbols-outlined">trending_up</span> Xu hướng:</span>
                        <button type="button" class="trending-tag" data-fill="Burger bò phô mai">Burger bò phô mai</button>
                        <button type="button" class="trending-tag" data-fill="Trà sữa nướng">Trà sữa nướng</button>
                        <button type="button" class="trending-tag" data-fill="Pizza hải sản">Pizza hải sản</button>
                        <button type="button" class="trending-tag" data-fill="Cơm tấm sườn bì">Cơm tấm sườn bì</button>
                    </div>

                    <div class="hero-ctas">
                        <a href="${pageContext.request.contextPath}/dangnhap" class="btn btn-cta btn-lg">
                            <span class="material-symbols-outlined fill">shopping_bag</span> Đặt món ngay
                        </a>
                        <a href="#featured-menu" class="btn btn-outline btn-lg">
                            <span class="material-symbols-outlined">restaurant_menu</span> Xem thực đơn
                        </a>
                    </div>

                    <div class="stats-ribbon">
                        <div class="stat-card"><strong>500K+</strong><span>Bữa ăn đã giao</span></div>
                        <div class="stat-card"><strong>4.9/5 <span class="material-symbols-outlined fill">star</span></strong><span>120K+ đánh giá</span></div>
                        <div class="stat-card"><strong>20-30p</strong><span>Thời gian giao TB</span></div>
                        <div class="stat-card"><strong>1.200+</strong><span>Quán chuẩn ATTP</span></div>
                    </div>
                </div>

                <div class="reveal delay-1">
                    <div class="hero-dish">
                        <div class="fast-badge"><span class="material-symbols-outlined">timer</span>Giao nóng 15 phút</div>
                        <div class="img-wrap">
                            <img src="${pageContext.request.contextPath}/assets/img/burger_hero.png" alt="Burger phô mai bò nướng">
                            <div class="best-tag"><span class="material-symbols-outlined fill">local_fire_department</span>Best Seller</div>
                        </div>
                        <div class="hero-dish-body">
                            <div class="hero-dish-top">
                                <div class="hero-dish-rating"><span class="material-symbols-outlined fill">star</span><strong>4.9</strong><span>(1.840 đơn)</span></div>
                                <span class="hero-dish-save">Tiết kiệm 30%</span>
                            </div>
                            <h3>Burger Bò Nướng Phô Mai Tan Chảy</h3>
                            <p>Bò Úc thượng hạng nướng than hoa, sốt BBQ nấm truffle và lớp phô mai Cheddar kép vàng ươm kéo sợi béo ngậy.</p>
                            <div class="hero-dish-foot">
                                <div class="hero-dish-price"><strong>69.000đ</strong><s>99.000đ</s></div>
                                <a href="${pageContext.request.contextPath}/dangnhap" class="btn btn-cta">
                                    <span class="material-symbols-outlined" style="font-size:17px;">add_shopping_cart</span> Chọn món
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Tại sao chọn FoodManage -->
        <section id="about" class="section section-alt">
            <div class="container">
                <div class="section-head reveal">
                    <span class="eyebrow-sm">Tại sao chọn FoodManage?</span>
                    <h2>Trải nghiệm ẩm thực trọn vẹn từng khoảnh khắc</h2>
                    <p>FoodManage kết nối bạn với những hương vị tinh túy nhất bằng hệ thống quản lý &amp; giao nhận thức ăn hiện đại chuẩn 2026.</p>
                </div>
                <div class="why-grid">
                    <div class="why-card reveal delay-1">
                        <div class="why-ic"><span class="material-symbols-outlined fill">eco</span></div>
                        <h3>Chất lượng tươi ngon 100%</h3>
                        <p>Nguồn nguyên liệu tươi sống được kiểm duyệt vệ sinh an toàn thực phẩm nghiêm ngặt hàng ngày từ chuỗi quán bếp chuẩn sao.</p>
                        <div class="why-link">Tiêu chuẩn 5 bước <span class="material-symbols-outlined">verified</span></div>
                    </div>
                    <div class="why-card reveal delay-2">
                        <div class="why-ic"><span class="material-symbols-outlined fill">electric_moped</span></div>
                        <h3>Giao siêu tốc 20 phút</h3>
                        <p>Hệ thống điều phối tài xế thông minh, thùng giữ nhiệt chuyên dụng giữ món ăn luôn nóng hổi giòn rụm, đá trà sữa không tan.</p>
                        <div class="why-link">Đúng giờ hoặc hoàn tiền <span class="material-symbols-outlined">bolt</span></div>
                    </div>
                    <div class="why-card reveal delay-3">
                        <div class="why-ic"><span class="material-symbols-outlined fill">storefront</span></div>
                        <h3>Đối tác tin cậy &amp; Giá minh bạch</h3>
                        <p>Hàng trăm quán ăn tuyển chọn danh tiếng, bảng giá cam kết đồng nhất với tại quán, không chi phí ẩn, hỗ trợ hoàn tiền khi có sự cố.</p>
                        <div class="why-link">Bảo vệ quyền lợi khách hàng <span class="material-symbols-outlined">shield</span></div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Danh mục nổi bật -->
        <section id="categories-section" class="section">
            <div class="container">
                <div class="cat-head-row reveal">
                    <div>
                        <div class="cat-badge"><span class="material-symbols-outlined">local_dining</span>Khám phá mỹ vị</div>
                        <h2>Danh Mục Ẩm Thực Nổi Bật</h2>
                        <p class="desc">Lựa chọn bữa ăn hoàn hảo đúng gu với hàng loạt chủ đề món ăn phong phú</p>
                    </div>
                    <div class="filter-tabs">
                        <button type="button" class="filter-tab active">Tất cả</button>
                        <button type="button" class="filter-tab">Bán chạy nhất</button>
                        <button type="button" class="filter-tab">Gần bạn nhất</button>
                        <button type="button" class="filter-tab">Ưu đãi sốc hôm nay</button>
                    </div>
                </div>
                <div class="cat-grid">
                    <a href="#featured-menu" class="cat-card reveal delay-1"><div class="ic-wrap">🍔</div><strong>Burger &amp; Fastfood</strong><span>420+ món</span></a>
                    <a href="#featured-menu" class="cat-card reveal delay-1"><div class="ic-wrap">🍕</div><strong>Pizza &amp; Pasta</strong><span>310+ món</span></a>
                    <a href="#featured-menu" class="cat-card reveal delay-2"><div class="ic-wrap">🍚</div><strong>Cơm &amp; Bún Phở</strong><span>580+ món</span></a>
                    <a href="#featured-menu" class="cat-card reveal delay-2"><div class="ic-wrap">🧋</div><strong>Trà sữa &amp; Cà phê</strong><span>650+ món</span></a>
                    <a href="#featured-menu" class="cat-card reveal delay-3"><div class="ic-wrap">🍗</div><strong>Gà rán &amp; Ăn vặt</strong><span>290+ món</span></a>
                    <a href="#featured-menu" class="cat-card reveal delay-3"><div class="ic-wrap">🍰</div><strong>Tráng miệng &amp; Bánh</strong><span>180+ món</span></a>
                    <a href="#featured-menu" class="cat-card reveal delay-3"><div class="ic-wrap">🥗</div><strong>Healthy &amp; Salad</strong><span>150+ món</span></a>
                </div>
            </div>
        </section>

        <!-- Món ngon nổi bật -->
        <section id="featured-menu" class="section section-alt">
            <div class="container">
                <div class="menu-head-row reveal">
                    <div>
                        <span class="eyebrow-sm">Thực đơn thịnh hành</span>
                        <h2>Món Ăn Được Yêu Thích Nhất</h2>
                        <p class="desc">Được đánh giá cao nhất bởi hàng trăm nghìn tín đồ sành ăn trên toàn quốc</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/dangnhap" class="menu-all-link">Xem toàn bộ thực đơn <span class="material-symbols-outlined">arrow_forward</span></a>
                </div>

                <div class="menu-grid">
                    <c:choose>
                        <c:when test="${not empty featuredProducts}">
                            <c:forEach items="${featuredProducts}" var="fp" varStatus="fpSt">
                                <div class="dish-card reveal delay-${(fpSt.index mod 3) + 1}">
                                    <div class="dish-img">
                                        <c:if test="${fp.soldCount > 0}"><span class="dish-tag">Bán chạy</span></c:if>
                                        <button type="button" class="dish-fav"><span class="material-symbols-outlined">favorite</span></button>
                                        <c:choose>
                                            <c:when test="${not empty fp.imageUrl}">
                                                <img src="${fp.imageUrl}" alt="${fn:escapeXml(fp.productName)}">
                                            </c:when>
                                            <c:otherwise>🍽️</c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="dish-body">
                                        <div class="dish-top">
                                            <c:choose>
                                                <c:when test="${fp.shopRating > 0}">
                                                    <div class="dish-rating"><span class="material-symbols-outlined fill">star</span><strong><fmt:formatNumber value="${fp.shopRating}" pattern="0.0"/></strong><span>(${fp.soldCount} đã bán)</span></div>
                                                </c:when>
                                                <c:otherwise><div class="dish-rating"><span class="material-symbols-outlined fill">star</span><strong>Mới</strong></div></c:otherwise>
                                            </c:choose>
                                            <span class="dish-shop">${fn:escapeXml(fp.shopName)}</span>
                                        </div>
                                        <h3>${fn:escapeXml(fp.productName)}</h3>
                                        <p>${fn:escapeXml(fp.description)}</p>
                                        <div class="dish-foot">
                                            <span class="dish-price"><fmt:formatNumber value="${fp.price}" pattern="#,##0"/>đ</span>
                                            <button type="button" class="dish-add" onclick="window.location.href='${pageContext.request.contextPath}/dangnhap'">
                                                <span class="material-symbols-outlined">add</span> Đặt món
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <p style="text-align:center;grid-column:1/-1;color:var(--muted);">Chưa có món ăn nổi bật, quay lại sau nhé!</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </section>

        <!-- Banner khuyến mãi -->
        <section class="section">
            <div class="container">
                <div class="promo-card reveal">
                    <div class="promo-text">
                        <div class="promo-badge"><span class="material-symbols-outlined">celebration</span>Đại tiệc ẩm thực cuối tuần</div>
                        <h2>Giảm Ngay 50.000đ Cho Đơn Từ 150K</h2>
                        <p>Áp dụng cho toàn bộ danh mục đồ ăn và thức uống khi thanh toán trực tuyến. Nhập mã voucher và tận hưởng bữa ngon ngay hôm nay!</p>
                        <div class="promo-actions">
                            <div class="coupon-pill">
                                <span class="lbl">Mã ưu đãi:</span>
                                <strong>GIAM50K</strong>
                                <button type="button" id="copyCouponBtn" title="Sao chép mã"><span class="material-symbols-outlined">content_copy</span></button>
                            </div>
                            <a href="${pageContext.request.contextPath}/dangnhap" class="btn btn-cta btn-lg">Lấy mã &amp; Đặt món ngay <span class="material-symbols-outlined">bolt</span></a>
                        </div>
                    </div>
                    <div class="promo-visual">
                        <div class="img-wrap">
                            <img src="${pageContext.request.contextPath}/assets/img/pizza_dish.png" alt="Bữa tiệc ẩm thực cuối tuần">
                            <div class="overlay">
                                <small>Hạn chót hôm nay</small>
                                <strong>Chỉ còn 128 lượt</strong>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Đánh giá -->
        <section class="section section-alt">
            <div class="container">
                <div class="section-head reveal">
                    <span class="eyebrow-sm">Khách hàng nói gì về chúng tôi?</span>
                    <h2>Đánh Giá Thật Từ Những Tín Đồ Sành Ăn</h2>
                    <p>Hơn 98% khách hàng hài lòng tuyệt đối về nhiệt độ món ăn và sự niềm nở từ đội ngũ FoodManage.</p>
                </div>
                <div class="review-grid">
                    <div class="review-card reveal delay-1">
                        <div>
                            <div class="review-stars">
                                <span class="material-symbols-outlined fill">star</span><span class="material-symbols-outlined fill">star</span><span class="material-symbols-outlined fill">star</span><span class="material-symbols-outlined fill">star</span><span class="material-symbols-outlined fill">star</span>
                            </div>
                            <p class="quote">"Burger giao tới nhà trong 18 phút mà phô mai vẫn còn chảy sợi nóng hổi, vỏ bánh thơm lừng không hề bị hấp hơi hay ỉu. Đây là app giao thức ăn chuẩn chỉ nhất mình từng dùng!"</p>
                        </div>
                        <div class="review-who">
                            <div class="review-avatar">PL</div>
                            <div><strong>Nguyễn Phương Linh</strong><span>Nhân viên văn phòng • Cầu Giấy</span></div>
                        </div>
                    </div>
                    <div class="review-card reveal delay-2">
                        <div>
                            <div class="review-stars">
                                <span class="material-symbols-outlined fill">star</span><span class="material-symbols-outlined fill">star</span><span class="material-symbols-outlined fill">star</span><span class="material-symbols-outlined fill">star</span><span class="material-symbols-outlined fill">star</span>
                            </div>
                            <p class="quote">"Quán pizza của tôi đã tăng 40% doanh số từ khi hợp tác độc quyền với FoodManage. Đội ngũ tài xế rất chuyên nghiệp, cẩn thận bảo quản từng khay bánh của khách."</p>
                        </div>
                        <div class="review-who">
                            <div class="review-avatar">HL</div>
                            <div><strong>Trần Hoàng Long</strong><span>Bếp trưởng chuỗi Bella Pizza • Hoàn Kiếm</span></div>
                        </div>
                    </div>
                    <div class="review-card reveal delay-3">
                        <div>
                            <div class="review-stars">
                                <span class="material-symbols-outlined fill">star</span><span class="material-symbols-outlined fill">star</span><span class="material-symbols-outlined fill">star</span><span class="material-symbols-outlined fill">star</span><span class="material-symbols-outlined fill">star</span>
                            </div>
                            <p class="quote">"Trà sữa đặt 12 ly cho cả phòng ban công ty mà đá không hề tan loãng, trân châu mềm dẻo. Khâu đóng gói cực kỳ sạch sẽ và lịch sự. Sẽ ủng hộ lâu dài!"</p>
                        </div>
                        <div class="review-who">
                            <div class="review-avatar">MT</div>
                            <div><strong>Lê Minh Tuấn</strong><span>Product Lead • Đống Đa</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <a href="${pageContext.request.contextPath}/dangnhap" class="floating-cta">
        <span class="ic"><span class="material-symbols-outlined fill">shopping_bag</span></span>
        <span class="lbl-full">Đặt món ngay</span>
        <span class="material-symbols-outlined" style="font-size:16px;">chevron_right</span>
    </a>

    <footer id="footer" class="footer">
        <div class="container">
            <div class="footer-grid">
                <div class="footer-brand">
                    <a class="logo" href="${pageContext.request.contextPath}/">
                        <svg viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" width="30" height="30">
                            <path d="M24 6C15 6 8 13 8 22c0 1.2.9 2 2 2h28c1.1 0 2-.8 2-2 0-9-7-16-16-16Z" fill="#fff"/>
                            <rect x="6" y="27" width="36" height="6" rx="3" fill="#fff"/>
                        </svg>
                        FoodManage
                    </a>
                    <p>Nền tảng đặt món tiện lợi, giao đồ ăn nóng hổi thần tốc và gắn kết các quán ăn danh tiếng hàng đầu Việt Nam.</p>
                    <div class="footer-hotline"><small>Tổng đài CSKH 24/7</small><strong>1900-8899</strong></div>
                </div>
                <div>
                    <h4>Về chúng tôi</h4>
                    <a class="flink" href="#">Câu chuyện thương hiệu</a>
                    <a class="flink" href="#">Tuyển dụng tài năng</a>
                    <a class="flink" href="${pageContext.request.contextPath}/dangky-shop">Hợp tác quán ăn</a>
                    <a class="flink" href="${pageContext.request.contextPath}/dangky-shipper">Trở thành shipper</a>
                </div>
                <div>
                    <h4>Hỗ trợ khách hàng</h4>
                    <a class="flink" href="#">Trung tâm trợ giúp</a>
                    <a class="flink" href="#">Chính sách hoàn tiền</a>
                    <a class="flink" href="#">Tiêu chuẩn an toàn thực phẩm</a>
                    <a class="flink" href="#">Điều khoản dịch vụ</a>
                </div>
                <div class="footer-app">
                    <h4>Tải ứng dụng FoodManage</h4>
                    <p>Trải nghiệm đặt món nhanh hơn cùng ưu đãi độc quyền hàng ngày trên ứng dụng.</p>
                    <div class="app-row">
                        <div class="qr-box"><span class="material-symbols-outlined">qr_code_2</span></div>
                        <div class="store-btns">
                            <div class="store-btn"><span class="material-symbols-outlined">shop</span><span class="txt"><small>Tải trên</small><strong>Google Play</strong></span></div>
                            <div class="store-btn"><span class="material-symbols-outlined">install_mobile</span><span class="txt"><small>Tải trên</small><strong>App Store</strong></span></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2026 FoodManage Platform. Đã đăng ký bản quyền. Tận tâm vì từng bữa ăn ngon.</p>
            </div>
        </div>
    </footer>

    <script>
        /* Scroll reveal animation */
        var revealEls = document.querySelectorAll('.reveal');
        var observer = new IntersectionObserver(function(entries) {
            entries.forEach(function(entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.add('active');
                    observer.unobserve(entry.target);
                }
            });
        }, { threshold: 0.12 });
        revealEls.forEach(function(el) { observer.observe(el); });

        /* Active nav link on scroll */
        var sections = document.querySelectorAll('main section[id]');
        var navLinks = document.querySelectorAll('.nav-links a');
        window.addEventListener('scroll', function() {
            var current = '';
            sections.forEach(function(sec) {
                var top = sec.offsetTop - 120;
                if (window.scrollY >= top) current = sec.getAttribute('id');
            });
            navLinks.forEach(function(link) {
                link.classList.remove('active');
                if (link.getAttribute('href') === '#' + current) link.classList.add('active');
            });
        });

        /* Trending tags autofill vào ô tìm kiếm */
        document.querySelectorAll('.trending-tag').forEach(function(tag) {
            tag.addEventListener('click', function() {
                var input = document.getElementById('heroSearchInput');
                if (input) { input.value = this.getAttribute('data-fill') || this.textContent.trim(); input.focus(); }
            });
        });

        /* Danh mục: chuyển tab active (thuần hiển thị) */
        document.querySelectorAll('.filter-tab').forEach(function(btn) {
            btn.addEventListener('click', function() {
                document.querySelectorAll('.filter-tab').forEach(function(b) { b.classList.remove('active'); });
                this.classList.add('active');
            });
        });

        /* Sao chép mã giảm giá */
        var copyBtn = document.getElementById('copyCouponBtn');
        if (copyBtn) {
            copyBtn.addEventListener('click', function() {
                if (navigator.clipboard) { navigator.clipboard.writeText('GIAM50K'); }
            });
        }
    </script>
</body>
</html>
