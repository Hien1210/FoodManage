package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.*;
import org.example.models.*;
import org.example.models.CartItemTopping;
import org.example.models.OrderDetailTopping;
import org.example.models.Topping;
import org.example.utils.CsrfUtil;
import org.example.utils.PayOSUtil;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
	private static final String REVIEW_VIEW = "/user/checkoutThanhToan.jsp";
	private static final double FIXED_DELIVERY_FEE = 15000;
	// Fallback neu doc SystemConfig loi; gia tri thuc te dung khi tinh phi lay tu
	// SystemConfig.shippingFeePerKm (xem ThamSoVanHanhServlet) qua systemConfigDAO.get().
	private static final double DEFAULT_FEE_PER_KM = 5000;
	private static final double MAX_DELIVERY_DISTANCE_KM = 20;

    private final CartDAO cartDAO = new CartDAOImpl();
    private final CartItemDAO cartItemDAO = new CartItemDAOImpl();
    private final CartItemToppingDAO cartItemToppingDAO = new CartItemToppingDAOImpl();
    private final ProductDAO productDAO = new ProductDAOImpl();
    private final ProductSizeDAO productSizeDAO = new ProductSizeDAOImpl();
    private final ShopDAO shopDAO = new ShopDAOImpl();
    private final ToppingDAO toppingDAO = new ToppingDAOImpl();
    private final OrderDAO orderDAO = new OrderDAOImpl();
    private final OrderDetailDAO orderDetailDAO = new OrderDetailDAOImpl();
    private final OrderDetailToppingDAO orderDetailToppingDAO = new OrderDetailToppingDAOImpl();
    private final UserAddressDAO userAddressDAO = new UserAddressDAOImpl();
    private final VoucherDAO voucherDAO = new VoucherDAOImpl();

	private final FlashSaleDAO flashSaleDAO = new FlashSaleDAOImpl();
	private final SystemConfigDAO systemConfigDAO = new SystemConfigDAOImpl();

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setCharacterEncoding("UTF-8");

		HttpSession session = req.getSession(false);
		Account account = (session != null) ? (Account) session.getAttribute("account") : null;
		if (account == null) { resp.sendRedirect(req.getContextPath() + "/dangnhap"); return; }

		Long cartId = parseId(req.getParameter("cartId"));
		if (cartId == null) { resp.sendRedirect(req.getContextPath() + "/user/home"); return; }

		Cart cart = cartDAO.findById(cartId);
		if (cart == null || cart.getUserId() != account.getId()) { resp.sendRedirect(req.getContextPath() + "/user/home"); return; }

		List<CheckoutLine> lines = buildLines(cart);
		if (lines.isEmpty()) { resp.sendRedirect(req.getContextPath() + "/user/home"); return; }

		{
			req.setAttribute("account", account);
			List<UserAddress> addresses = userAddressDAO.findByAccountId(account.getId());
			UserAddress defaultAddr = findDefault(addresses);
			if (defaultAddr == null && !addresses.isEmpty()) {
				defaultAddr = addresses.get(0);
			}
			req.setAttribute("defaultAddress", defaultAddr);
			boolean hasLocation = defaultAddr != null && defaultAddr.getLocationX() != null && defaultAddr.getLocationY() != null;
			req.setAttribute("hasLocation", hasLocation);
		}

		showReview(req, resp, cart, lines, null);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setCharacterEncoding("UTF-8");

		HttpSession session = req.getSession(false);
		Account account = (session != null) ? (Account) session.getAttribute("account") : null;
		if (account == null) { resp.sendRedirect(req.getContextPath() + "/dangnhap"); return; }

		Long cartId = parseId(req.getParameter("cartId"));
		Cart cart = cartId == null ? null : cartDAO.findById(cartId);
		if (cart == null || cart.getUserId() != account.getId()) { resp.sendRedirect(req.getContextPath() + "/user/cart?error=not_found"); return; }

		List<CheckoutLine> lines = buildLines(cart);
		if (lines.isEmpty()) { resp.sendRedirect(req.getContextPath() + "/user/cart?error=empty_cart"); return; }

		// Idempotency token: moi lan hien form checkout (showReview) sinh 1 token dung 1 lan, luu
		// theo session + cartId. CSRF token (csrfToken) dung chung cho ca session nen KHONG chan duoc
		// double-submit/retry mang; token nay bi xoa ngay khi kiem tra (du hop le hay khong) de dam
		// bao 1 submit chi duoc xu ly toi da 1 lan.
		String checkoutTokenKey = checkoutTokenSessionKey(cart.getId());
		String expectedCheckoutToken = (String) session.getAttribute(checkoutTokenKey);
		session.removeAttribute(checkoutTokenKey);
		String submittedCheckoutToken = normalize(req.getParameter("checkoutToken"));
		if (expectedCheckoutToken == null || submittedCheckoutToken.isEmpty()
				|| !MessageDigest.isEqual(expectedCheckoutToken.getBytes(StandardCharsets.UTF_8), submittedCheckoutToken.getBytes(StandardCharsets.UTF_8))) {
			showReview(req, resp, cart, lines, "Phien thanh toan da het han hoac don da duoc gui truoc do, vui long kiem tra lai don hang va thu lai");
			return;
		}

        String receiverName = normalize(req.getParameter("receiverName"));
        String receiverPhone = normalize(req.getParameter("receiverPhone"));
        String shippingAddress = normalize(req.getParameter("shippingAddress"));
        String paymentMethod = normalize(req.getParameter("paymentMethod"));
        Double orderLocationX = parseDoubleOrNull(req.getParameter("locationX"));
        Double orderLocationY = parseDoubleOrNull(req.getParameter("locationY"));
        LocalDateTime scheduledAt = parseScheduledAt(req.getParameter("scheduledAt"));

		String error = validate(receiverName, receiverPhone, shippingAddress, paymentMethod, FIXED_DELIVERY_FEE);
		if (error != null) {
			showReview(req, resp, cart, lines, error);
			return;
		}

		Map<Long, List<CheckoutLine>> byShop = new LinkedHashMap<>();
		for (CheckoutLine line : lines) {
			byShop.computeIfAbsent(line.getShopId(), k -> new ArrayList<>()).add(line);
		}

		SystemConfig sysConfig = systemConfigDAO.get();
		double feePerKm = sysConfig != null ? sysConfig.getShippingFeePerKm() : DEFAULT_FEE_PER_KM;

		Map<Long, Shop> shopsById = new LinkedHashMap<>();
		Map<Long, Double> deliveryFeeByShop = new LinkedHashMap<>();
		for (Long shopId : byShop.keySet()) {
			Shop shop = shopDAO.selectShopById(shopId);
			shopsById.put(shopId, shop);

			String shopName = (shop != null && shop.getShopName() != null) ? shop.getShopName() : ("Shop #" + shopId);

			if (shop != null && !shop.isOpenNow()) {
				showReview(req, resp, cart, lines,
						"Shop \"" + shopName + "\" hien dang ngoai gio hoat dong (" + shop.getOpenTime()
								+ " - " + shop.getCloseTime() + "), vui long quay lai sau.");
				return;
			}

			if (shop == null || shop.getLocationX() == null || shop.getLocationY() == null) {
				showReview(req, resp, cart, lines,
						"Shop \"" + shopName + "\" chua cap nhat vi tri tren ban do, khong the tinh phi giao hang. Vui long chon shop khac.");
				return;
			}

			if (orderLocationX == null || orderLocationY == null) {
				showReview(req, resp, cart, lines, "Vui long chon vi tri giao hang tren ban do");
				return;
			}

			double distanceKm = haversineKm(shop.getLocationX(), shop.getLocationY(), orderLocationX, orderLocationY);
			if (distanceKm > MAX_DELIVERY_DISTANCE_KM) {
				double distRounded = Math.round(distanceKm * 10.0) / 10.0;
				showReview(req, resp, cart, lines,
						"Vị trí của bạn cách vị trí của Shop \"" + shopName + "\" " + distRounded + "km (vượt quá giới hạn 20km), hệ thống tự động từ chối đặt đơn.");
				return;
			}
			double fee = distanceKm * feePerKm;
			deliveryFeeByShop.put(shopId, fee);
		}

		// Voucher: gio hang co the tach thanh nhieu Order (1 don/shop, xem vong lap tren), nhung
		// 1 ma giam gia chi nhap 1 lan tren form nen chi ap dung cho don cua SHOP DAU TIEN trong
		// gio hang (theo dung gia dinh da thong nhat, giong cach lam voi phi giao hang tach theo
		// shop). Neu khach muon dung voucher cho shop khac, phai tach don rieng tung shop.
		Long voucherShopId = byShop.keySet().iterator().next();
		String voucherCodeInput = normalize(req.getParameter("voucherCode"));
		Voucher appliedVoucher = null;
		if (!voucherCodeInput.isEmpty()) {
			appliedVoucher = voucherDAO.findByCode(voucherCodeInput);
			if (appliedVoucher == null) {
				showReview(req, resp, cart, lines, "Ma giam gia \"" + voucherCodeInput + "\" khong ton tai");
				return;
			}
			double voucherShopSubtotal = 0;
			for (CheckoutLine line : byShop.get(voucherShopId)) {
				voucherShopSubtotal += line.getLineTotal();
			}
			String voucherError = appliedVoucher.validateBasic(voucherShopSubtotal);
			if (voucherError != null) {
				showReview(req, resp, cart, lines, voucherError);
				return;
			}

			// Giu cho (reserve) luot dung voucher NGAY TAI DAY bang guard atomic o tang SQL
			// (used_count < usage_limit), truoc khi tao bat ky Order nao. Neu that bai (vd 2 request
			// dua nhau dung voucher cung luc va da het luot), huy toan bo checkout thay vi tao don
			// voi discount ma voucher chua thuc su duoc giu cho.
			if (!voucherDAO.incrementUsedCount(appliedVoucher.getId())) {
				showReview(req, resp, cart, lines, "Ma giam gia \"" + voucherCodeInput + "\" da het luot su dung, vui long thu lai");
				return;
			}
		}

		boolean isPayOS = "PAYOS".equals(paymentMethod);
		if (isPayOS && byShop.size() > 1) {
			showReview(req, resp, cart, lines, "Gio hang co nhieu shop, vui long thanh toan PayOS rieng cho tung shop (xoa bot san pham hoac chon COD)");
			return;
		}

		if (isPayOS) {
			if (sysConfig == null || isBlank(sysConfig.getPayosClientId()) || isBlank(sysConfig.getPayosApiKey()) || isBlank(sysConfig.getPayosChecksumKey())) {
				showReview(req, resp, cart, lines, "He thong chua cau hinh PayOS, vui long chon phuong thuc khac hoac lien he ho tro");
				return;
			}
		}

		List<Long> createdOrderIds = new ArrayList<>();
		for (Map.Entry<Long, List<CheckoutLine>> entry : byShop.entrySet()) {
			double subtotal = 0;
			for (CheckoutLine line : entry.getValue()) {
				subtotal += line.getLineTotal();
			}

			double deliveryFee = deliveryFeeByShop.get(entry.getKey());

			double discount = 0;
			boolean isVoucherOrder = appliedVoucher != null && entry.getKey().equals(voucherShopId);
			if (isVoucherOrder) {
				discount = appliedVoucher.computeDiscount(subtotal, deliveryFee);
			}

			Order order = new Order();
			order.setUserId(cart.getUserId());
			order.setShopId(entry.getKey());
			order.setReceiverName(receiverName);
			order.setReceiverPhone(receiverPhone);
			order.setShippingAddress(shippingAddress);
			order.setPaymentMethod(paymentMethod);
			order.setStaTus("PENDING");
			order.setDeliveryFee(deliveryFee);
			order.setTotalPrice(Math.max(0, subtotal + deliveryFee - discount));
			order.setLocationX(orderLocationX);
			order.setLocationY(orderLocationY);

			long orderId = orderDAO.createAndReturnId(order);
			if (orderId <= 0) {
				// Shop truoc do trong vong lap co the da tao Order thanh cong - xoa het de tranh
				// checkout that bai nua chung ma van con don "mo coi" trong DB, va hoan lai voucher
				// neu da giu cho truoc do.
				for (Long alreadyCreatedId : createdOrderIds) {
					orderDAO.delete(alreadyCreatedId);
				}
				if (appliedVoucher != null) {
					voucherDAO.decrementUsedCount(appliedVoucher.getId());
				}
				showReview(req, resp, cart, lines, "Loi tao don hang, vui long thu lai");
				return;
			}

			if (isVoucherOrder) {
				orderDAO.setVoucherInfo(orderId, appliedVoucher.getCode(), discount);
			}

			if (scheduledAt != null) {
				orderDAO.setScheduledAt(orderId, scheduledAt);
			}

            for (CheckoutLine line : entry.getValue()) {
                OrderDetail detail = new OrderDetail();
                detail.setOrderId(orderId);
                detail.setProductId(line.getProductId());
                detail.setProductSizeId(line.getSizeId());
                detail.setQuantity(line.getQuantity());
                detail.setPrice(line.getUnitPrice());
                long detailId = orderDetailDAO.createAndReturnId(detail);
                if (detailId > 0) {
                    for (ToppingLine tl : line.getToppings()) {
                        OrderDetailTopping odt = new OrderDetailTopping();
                        odt.setOrderDetailId(detailId);
                        odt.setToppingId(tl.getToppingId());
                        odt.setQuantity(tl.getQty());
                        odt.setPrice(tl.getPrice());
                        orderDetailToppingDAO.create(odt);
                    }
                } else {
                    // Tao chi tiet don that bai giua chung: khong the de Order dung nguyen voi thieu
                    // mon ma khach van bi tinh du tien. Xoa TOAN BO cac Order da tao trong request nay
                    // (FK CASCADE tu don Order_Details/Order_Detail_Toppings) va hoan lai voucher neu
                    // da giu cho, thay vi chi xoa rieng Order dang loi.
                    orderDAO.delete(orderId);
                    for (Long alreadyCreatedId : createdOrderIds) {
                        orderDAO.delete(alreadyCreatedId);
                    }
                    if (appliedVoucher != null) {
                        voucherDAO.decrementUsedCount(appliedVoucher.getId());
                    }
                    showReview(req, resp, cart, lines, "Loi tao chi tiet don hang, vui long thu lai");
                    return;
                }
            }

			createdOrderIds.add(orderId);
		}

		if (isPayOS) {
			long orderId = createdOrderIds.get(0);
			Order createdOrder = orderDAO.findById(orderId);
			long amount = Math.round(createdOrder.getTotalPrice());
			String baseUrl = baseUrl(req);
			String returnUrl = baseUrl + req.getContextPath() + "/payos/return?source=cart";
			String cancelUrl = returnUrl;
			String description = "Thanh toan DH" + orderId;
			if (description.length() > 25) {
				description = description.substring(0, 25);
			}

			PayOSUtil.PaymentLinkResult result = PayOSUtil.createPaymentLink(
				sysConfig.getPayosClientId(), sysConfig.getPayosApiKey(), sysConfig.getPayosChecksumKey(),
				orderId, amount, description, returnUrl, cancelUrl);

			if (!result.success) {
				showReview(req, resp, cart, lines, "Khong tao duoc link thanh toan PayOS: " + result.errorMessage);
				return;
			}

			orderDAO.setPayosOrderCode(orderId, orderId);

			for (CartItem item : cartItemDAO.findByCartId(cart.getId())) {
				cartItemDAO.delete(item.getId());
			}

			resp.sendRedirect(result.checkoutUrl);
			return;
		}

		for (CartItem item : cartItemDAO.findByCartId(cart.getId())) {
			cartItemDAO.delete(item.getId());
		}

		StringBuilder ids = new StringBuilder();
		for (int i = 0; i < createdOrderIds.size(); i++) {
			if (i > 0) ids.append(',');
			ids.append(createdOrderIds.get(i));
		}
		resp.sendRedirect(req.getContextPath() + "/bill?orderIds=" + ids);
	}

	private boolean isBlank(String value) {
		return value == null || value.trim().isEmpty();
	}

	private String checkoutTokenSessionKey(long cartId) {
		return "checkoutToken:" + cartId;
	}

	/** JSON [{"lat":.., "lng":..}, ...] cho JS tinh phi ship (5.000d/km) truoc khi khach bam dat hang -
	 * moi phan tu tuong ung 1 shop khac nhau trong gio hang, lat/lng la null neu shop chua cau hinh toa do. */
	private String buildShopLocationsJson(List<CheckoutLine> lines) {
		Set<Long> seen = new LinkedHashSet<>();
		StringBuilder json = new StringBuilder("[");
		boolean first = true;
		for (CheckoutLine line : lines) {
			long shopId = line.getShopId();
			if (!seen.add(shopId)) continue;
			Shop shop = shopDAO.selectShopById(shopId);
			Double lat = shop != null ? shop.getLocationX() : null;
			Double lng = shop != null ? shop.getLocationY() : null;
			String name = shop != null && shop.getShopName() != null ? shop.getShopName() : ("Shop #" + shopId);
			if (!first) json.append(",");
			first = false;
			json.append("{\"lat\":").append(lat != null ? lat : "null")
					.append(",\"lng\":").append(lng != null ? lng : "null")
					.append(",\"name\":\"").append(name.replace("\"", "\\\"")).append("\"}");
		}
		json.append("]");
		return json.toString();
	}

	private static double haversineKm(double lat1, double lng1, double lat2, double lng2) {
		double earthRadiusKm = 6371;
		double dLat = Math.toRadians(lat2 - lat1);
		double dLng = Math.toRadians(lng2 - lng1);
		double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
				+ Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
				* Math.sin(dLng / 2) * Math.sin(dLng / 2);
		double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
		return earthRadiusKm * c;
	}

	private String baseUrl(HttpServletRequest req) {
		StringBuilder sb = new StringBuilder();
		sb.append(req.getScheme()).append("://").append(req.getServerName());
		boolean isDefaultPort = ("http".equals(req.getScheme()) && req.getServerPort() == 80)
			|| ("https".equals(req.getScheme()) && req.getServerPort() == 443);
		if (!isDefaultPort) {
			sb.append(":").append(req.getServerPort());
		}
		return sb.toString();
	}

	private void showReview(HttpServletRequest req, HttpServletResponse resp, Cart cart, List<CheckoutLine> lines, String error)
	throws ServletException, IOException {
		double subtotal = 0;
		for (CheckoutLine line : lines) {
			subtotal += line.getLineTotal();
		}

		String checkoutToken = CsrfUtil.generateToken();
		req.getSession().setAttribute(checkoutTokenSessionKey(cart.getId()), checkoutToken);
		req.setAttribute("checkoutToken", checkoutToken);

		req.setAttribute("cart", cart);
		req.setAttribute("lines", lines);
		req.setAttribute("subtotal", subtotal);
		SystemConfig sysConfigForDisplay = systemConfigDAO.get();
		double feePerKmForDisplay = sysConfigForDisplay != null ? sysConfigForDisplay.getShippingFeePerKm() : DEFAULT_FEE_PER_KM;
		req.setAttribute("deliveryFee", FIXED_DELIVERY_FEE);
		req.setAttribute("feePerKm", feePerKmForDisplay);
		req.setAttribute("fixedDeliveryFee", FIXED_DELIVERY_FEE);
		req.setAttribute("maxDeliveryDistanceKm", MAX_DELIVERY_DISTANCE_KM);
		req.setAttribute("shopLocationsJson", buildShopLocationsJson(lines));
		if (error != null) {
			req.setAttribute("error", error);
		}

		// Goi y "Best Voucher": voucher chi ap dung cho don cua shop DAU TIEN trong gio hang
		// (dung gia dinh nhu luc tao don o doPost, xem mục 77), nen chi tinh subtotal cua shop do.
		if (!lines.isEmpty()) {
			long firstShopId = lines.get(0).getShopId();
			double firstShopSubtotal = 0;
			for (CheckoutLine line : lines) {
				if (line.getShopId() == firstShopId) firstShopSubtotal += line.getLineTotal();
			}
			Voucher best = findBestVoucher(firstShopSubtotal);
			if (best != null) {
				req.setAttribute("bestVoucher", best);
				req.setAttribute("bestVoucherDiscount", best.computeDiscount(firstShopSubtotal, FIXED_DELIVERY_FEE));
			}
		}

		req.getRequestDispatcher(REVIEW_VIEW).forward(req, resp);
	}

	/** Trong cac voucher dang du dieu kien, chon voucher giam duoc NHIEU TIEN NHAT (khong chi dua vao value tho,
	 * vi PERCENT/FIXED/FREESHIP khong the so sanh truc tiep) cho subtotal hien tai. */
	private Voucher findBestVoucher(double subtotal) {
		List<Voucher> candidates = voucherDAO.findApplicable(subtotal);
		Voucher best = null;
		double bestDiscount = -1;
		for (Voucher v : candidates) {
			double discount = v.computeDiscount(subtotal, FIXED_DELIVERY_FEE);
			if (discount > bestDiscount) {
				bestDiscount = discount;
				best = v;
			}
		}
		return best;
	}

	private List<CheckoutLine> buildLines(Cart cart) {
		List<CheckoutLine> lines = new ArrayList<>();

		for (CartItem item : cartItemDAO.findByCartId(cart.getId())) {
			Product product = productDAO.findById(item.getProductId());
			if (product == null) { continue; }

			ProductSize size = productSizeDAO.findById(item.getProductSizeId());
			// San pham size da het hang (Shop danh dau OUT_OF_STOCK sau khi khach da them vao gio
			// hang) khong duoc tinh vao don - tranh dat duoc mon da het hang.
			if (size == null || size.isOutOfStock()) { continue; }

			Double activeSale = flashSaleDAO.getActiveSalePrice(size.getId());
			if (activeSale != null && activeSale > 0) {
				size.setSalePrice(activeSale);
			}
			// Mon thuoc combo da "khoa" gia luc them vao gio (xem UserAddComboServlet) - uu tien gia
			// nay hon ca flash sale, tai su dung co che salePrice cua ProductSize (size.getPrice()
			// tra ve salePrice neu co) de moi noi tinh tien deu tu dong dung dung gia combo.
			if (item.getComboUnitPrice() != null) {
				size.setSalePrice(item.getComboUnitPrice());
			}

			Shop shop = shopDAO.selectShopById(product.getShopId());
			String shopName = shop == null ? ("Shop #" + product.getShopId()) : shop.getShopName();

			List<ToppingLine> toppingLines = new ArrayList<>();
			for (CartItemTopping ct : cartItemToppingDAO.findByCartItemId(item.getId())) {
				Topping t = toppingDAO.findById(ct.getToppingId());
				if (t != null) {
					toppingLines.add(new ToppingLine(t.getId(), t.getToppingName(), t.getPrice(), ct.getQuantity()));
				}
			}

            lines.add(new CheckoutLine(
                    item.getId(), product.getId(), product.getProductName(),
                    size.getId(), size.getSizeName(), size.getPrice(),
                    size.getOriginalPrice(), size.isHasSale(),
                    item.getQuantity(), product.getShopId(), shopName, toppingLines
            ));
        }

		return lines;
	}

    private String validate(String receiverName, String receiverPhone, String shippingAddress, String paymentMethod, double deliveryFee) {
        if (receiverName.isEmpty()) {
            return "Vui long nhap ten nguoi nhan";
        }
        if (receiverPhone.isEmpty()) {
            return "Vui long nhap so dien thoai nguoi nhan";
        }
        if (shippingAddress.isEmpty()) {
            return "Vui long nhap dia chi giao hang";
        }
        if (paymentMethod.isEmpty()) {
            return "Vui long chon phuong thuc thanh toan";
        }
        if (deliveryFee < 0) {
            return "Phi giao hang khong hop le";
        }
        return null;
    }

	private Long parseId(String value) {
		try {
			String normalized = normalize(value);
			return normalized.isEmpty() ? null : Long.parseLong(normalized);
		} catch (Exception e) { return null; }
	}

	private double parseDouble(String value) {
		try {
			String normalized = normalize(value);
			return normalized.isEmpty() ? 0 : Double.parseDouble(normalized);
		} catch (Exception e) { return -1; }
	}

	private Double parseDoubleOrNull(String value) {
		try {
			String normalized = normalize(value);
			return normalized.isEmpty() ? null : Double.parseDouble(normalized);
		} catch (Exception e) { return null; }
	}

	private String normalize(String value) {
		return value == null ? "" : value.trim();
	}

	private LocalDateTime parseScheduledAt(String value) {
		if (value == null || value.trim().isEmpty()) return null;
		try {
			return LocalDateTime.parse(value.trim());
		} catch (DateTimeParseException e) {
			return null;
		}
	}

	private UserAddress findDefault(List<UserAddress> addresses) {
		if (addresses == null) return null;
		for (UserAddress a : addresses) {
			if (a.isDefault()) return a;
		}
		return null;
	}

    public static final class ToppingLine {
        private final long toppingId;
        private final String toppingName;
        private final double price;
        private final int qty;

        public ToppingLine(long toppingId, String toppingName, double price, int qty) {
            this.toppingId = toppingId;
            this.toppingName = toppingName;
            this.price = price;
            this.qty = qty;
        }

        public long getToppingId() { return toppingId; }
        public String getToppingName() { return toppingName; }
        public double getPrice() { return price; }
        public int getQty() { return qty; }
    }

    public static final class CheckoutLine {
        private final long itemId;
        private final long productId;
        private final String productName;
        private final long sizeId;
        private final String sizeName;
        private final double unitPrice;
        private final double originalPrice;
        private final boolean hasSale;
        private final int quantity;
        private final long shopId;
        private final String shopName;
        private final List<ToppingLine> toppings;

        public CheckoutLine(long itemId, long productId, String productName, long sizeId, String sizeName, double unitPrice,
                             double originalPrice, boolean hasSale,
                             int quantity, long shopId, String shopName, List<ToppingLine> toppings) {
            this.itemId = itemId;
            this.productId = productId;
            this.productName = productName;
            this.sizeId = sizeId;
            this.sizeName = sizeName;
            this.unitPrice = unitPrice;
            this.originalPrice = originalPrice;
            this.hasSale = hasSale;
            this.quantity = quantity;
            this.shopId = shopId;
            this.shopName = shopName;
            this.toppings = toppings != null ? toppings : new ArrayList<>();
        }

        public long getItemId() { return itemId; }
        public long getProductId() { return productId; }
        public String getProductName() { return productName; }
        public long getSizeId() { return sizeId; }
        public String getSizeName() { return sizeName; }
        public double getUnitPrice() { return unitPrice; }
        public double getOriginalPrice() { return originalPrice; }
        public boolean isHasSale() { return hasSale; }
        public int getQuantity() { return quantity; }
        public long getShopId() { return shopId; }
        public String getShopName() { return shopName; }
        public List<ToppingLine> getToppings() { return toppings; }
        public double getLineTotal() {
            double total = unitPrice * quantity;
            for (ToppingLine t : toppings) {
                total += t.price * t.qty;
            }
            return total;
        }
    }
}
