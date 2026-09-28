package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.ShopDAO;
import org.example.daos.ShopDAOImpl;
import org.example.models.Account;
import org.example.models.Shop;
import org.example.utils.SensitiveInfoOtpUtil;

import javax.mail.MessagingException;
import java.io.IOException;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet quản lý thông tin hồ sơ Shop (chỉnh sửa tên, mô tả, địa chỉ, SĐT, logo).
 * URL : /shop/profile
 * JSP : /admin/Shopprofile.jsp
 */
@WebServlet("/shop/profile")
public class ShopProfileServlet extends HttpServlet {

    private static final String VIEW = "/shop/Shopprofile.jsp";

    private final ShopDAO shopDAO = new ShopDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        Account account = requireShopAccount(req, resp);
        if (account == null) return;

        Shop shop = requireApprovedShop(req, resp, account);
        if (shop == null) return;

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        Account account = requireShopAccount(req, resp);
        if (account == null) return;

        Shop shop = requireApprovedShop(req, resp, account);
        if (shop == null) return;

        String shopName = normalize(req.getParameter("shopName"));
        String shopDescription = normalize(req.getParameter("shopDescription"));
        String shopAddress = normalize(req.getParameter("shopAddress"));
        String shopPhone = normalize(req.getParameter("shopPhone"));
        String shopLogo = normalize(req.getParameter("shopLogo"));
        String clientKey = normalize(req.getParameter("clientKey"));
        String apiKey = normalize(req.getParameter("apiKey"));
        String checkSumKey = normalize(req.getParameter("checkSumKey"));
        String bankCode = normalize(req.getParameter("bankCode"));
        String bankAccountNumber = normalize(req.getParameter("bankAccountNumber"));
        String bankAccountName = normalize(req.getParameter("bankAccountName"));
        Double shopLocationX = parseDoubleOrNull(req.getParameter("shopLocationX"));
        Double shopLocationY = parseDoubleOrNull(req.getParameter("shopLocationY"));
        LocalTime openTime = parseTimeOrNull(req.getParameter("openTime"));
        LocalTime closeTime = parseTimeOrNull(req.getParameter("closeTime"));

        String inputError = shopName.isEmpty() || shopAddress.isEmpty() || shopPhone.isEmpty()
                ? "Tên cửa hàng, địa chỉ và số điện thoại không được để trống!"
                : org.example.utils.InputValidationUtil.firstError(
                        org.example.utils.InputValidationUtil.checkLine("Tên cửa hàng", shopName, org.example.utils.InputValidationUtil.MAX_SHOP_NAME),
                        org.example.utils.InputValidationUtil.checkMultiline("Mô tả cửa hàng", shopDescription, org.example.utils.InputValidationUtil.MAX_DESCRIPTION),
                        org.example.utils.InputValidationUtil.checkLine("Địa chỉ", shopAddress, org.example.utils.InputValidationUtil.MAX_ADDRESS),
                        org.example.utils.InputValidationUtil.checkPhone("Số điện thoại", shopPhone));
        if (inputError != null) {
            req.setAttribute("loi", inputError);
            Shop formShop = new Shop();
            formShop.setShopName(shopName);
            formShop.setShopDescription(shopDescription);
            formShop.setShopAddress(shopAddress);
            formShop.setShopPhone(shopPhone);
            formShop.setShopLogo(shopLogo);
            formShop.setClientKey(clientKey);
            formShop.setApiKey(apiKey);
            formShop.setCheckSumKey(checkSumKey);
            formShop.setBankCode(bankCode);
            formShop.setBankAccountNumber(bankAccountNumber);
            formShop.setBankAccountName(bankAccountName);
            formShop.setLocationX(shopLocationX);
            formShop.setLocationY(shopLocationY);
            formShop.setOpenTime(openTime);
            formShop.setCloseTime(closeTime);
            req.setAttribute("shopForm", formShop);
            req.getRequestDispatcher(VIEW).forward(req, resp);
            return;
        }

        if ((openTime == null) != (closeTime == null)) {
            req.setAttribute("loi", "Vui lòng nhập đủ cả giờ mở cửa và giờ đóng cửa, hoặc để trống cả hai nếu mở cửa cả ngày!");
            Shop formShop = new Shop();
            formShop.setShopName(shopName);
            formShop.setShopDescription(shopDescription);
            formShop.setShopAddress(shopAddress);
            formShop.setShopPhone(shopPhone);
            formShop.setShopLogo(shopLogo);
            formShop.setClientKey(clientKey);
            formShop.setApiKey(apiKey);
            formShop.setCheckSumKey(checkSumKey);
            formShop.setBankCode(bankCode);
            formShop.setBankAccountNumber(bankAccountNumber);
            formShop.setBankAccountName(bankAccountName);
            formShop.setLocationX(shopLocationX);
            formShop.setLocationY(shopLocationY);
            formShop.setOpenTime(openTime);
            formShop.setCloseTime(closeTime);
            req.setAttribute("shopForm", formShop);
            req.getRequestDispatcher(VIEW).forward(req, resp);
            return;
        }

        // Doi thong tin ngan hang/PayOS key la thao tac lien quan truc tiep den dong tien nhan
        // COD/chuyen khoan cua shop - bat buoc xac thuc OTP gui toi email cua chu shop truoc khi
        // luu, tranh session bi chiem dung roi doi tai khoan nhan tien.
        boolean bankInfoChanged = !safeEquals(bankCode, shop.getBankCode())
                || !safeEquals(bankAccountNumber, shop.getBankAccountNumber())
                || !safeEquals(bankAccountName, shop.getBankAccountName())
                || !safeEquals(clientKey, shop.getClientKey())
                || !safeEquals(apiKey, shop.getApiKey())
                || !safeEquals(checkSumKey, shop.getCheckSumKey());

        if (bankInfoChanged) {
            Map<String, String> pending = new HashMap<>();
            pending.put("shopName", shopName);
            pending.put("shopDescription", shopDescription);
            pending.put("shopAddress", shopAddress);
            pending.put("shopPhone", shopPhone);
            pending.put("shopLogo", shopLogo);
            pending.put("clientKey", clientKey);
            pending.put("apiKey", apiKey);
            pending.put("checkSumKey", checkSumKey);
            pending.put("bankCode", bankCode);
            pending.put("bankAccountNumber", bankAccountNumber);
            pending.put("bankAccountName", bankAccountName);
            pending.put("shopLocationX", shopLocationX != null ? String.valueOf(shopLocationX) : "");
            pending.put("shopLocationY", shopLocationY != null ? String.valueOf(shopLocationY) : "");
            pending.put("openTime", openTime != null ? openTime.toString() : "");
            pending.put("closeTime", closeTime != null ? closeTime.toString() : "");
            try {
                SensitiveInfoOtpUtil.generateAndSend(req.getSession(), "shop_bank", account.getEmail(), pending);
            } catch (MessagingException e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/shop/profile?error=otp_send_failed");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/xac-thuc-thay-doi?purpose=shop_bank");
            return;
        }

        // Chỉ cập nhật các trường hồ sơ (không đổi ngân hàng/PayOS key), giữ nguyên trạng thái duyệt / owner.
        shop.setShopName(shopName);
        shop.setShopDescription(shopDescription);
        shop.setShopAddress(shopAddress);
        shop.setShopPhone(shopPhone);
        shop.setShopLogo(shopLogo);
        shop.setLocationX(shopLocationX);
        shop.setLocationY(shopLocationY);
        shop.setOpenTime(openTime);
        shop.setCloseTime(closeTime);

        shopDAO.updateShop(shop);

        resp.sendRedirect(req.getContextPath() + "/shop/profile?success=update");
    }

    private boolean safeEquals(String a, String b) {
        if (a == null || a.isEmpty()) a = null;
        if (b == null || b.isEmpty()) b = null;
        if (a == null) return b == null;
        return a.equals(b);
    }

    private Account requireShopAccount(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        Account account = (session == null) ? null : (Account) session.getAttribute("account");
        if (account == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        if (account.getRoleId() != 2) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ tài khoản shop mới được truy cập!");
            return null;
        }
        return account;
    }

    private Shop requireApprovedShop(HttpServletRequest req, HttpServletResponse resp, Account account)
            throws IOException {
        Shop shop = shopDAO.selectShopByOwnerId(account.getId());
        if (shop == null || !isAccepted(shop.getStatus())) {
            resp.sendRedirect(req.getContextPath() + "/shop");
            return null;
        }
        req.setAttribute("currentShop", shop);
        req.getSession().setAttribute("currentShop", shop);
        return shop;
    }

    private boolean isAccepted(String status) {
        String v = normalize(status).toLowerCase();
        return "accept".equals(v) || "accepted".equals(v) || "approved".equals(v) || "active".equals(v);
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private Double parseDoubleOrNull(String value) {
        try {
            String normalized = normalize(value);
            return normalized.isEmpty() ? null : Double.parseDouble(normalized);
        } catch (Exception e) {
            return null;
        }
    }

    private LocalTime parseTimeOrNull(String value) {
        try {
            String normalized = normalize(value);
            return normalized.isEmpty() ? null : LocalTime.parse(normalized, DateTimeFormatter.ofPattern("HH:mm"));
        } catch (Exception e) {
            return null;
        }
    }
}
