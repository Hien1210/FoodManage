package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.*;
import org.example.models.*;

import java.io.IOException;

@WebServlet("/user/add-to-cart")
public class UserCartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAOImpl();
    private final CartItemDAO cartItemDAO = new CartItemDAOImpl();
    private final CartItemToppingDAO cartItemToppingDAO = new CartItemToppingDAOImpl();
    private final ProductSizeDAO productSizeDAO = new ProductSizeDAOImpl();
    private final ProductDAO productDAO = new ProductDAOImpl();
    private final ShopDAO shopDAO = new ShopDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Account account = session == null ? null : (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 3) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        long productId = parseLong(req.getParameter("productId"));
        long sizeId    = parseLong(req.getParameter("sizeId"));
        String rawQuantity = req.getParameter("quantity");
        int  quantity  = parseInt(rawQuantity, 1);
        // Có gửi số lượng nhưng <= 0 hoặc không phải số thì báo lỗi, không tự đổi thành 1 (tránh khách tưởng đã đặt đúng số lượng).
        boolean invalidQuantity = rawQuantity != null && !rawQuantity.trim().isEmpty() && !isPositiveInt(rawQuantity);
        long shopId    = parseLong(req.getParameter("shopId"));
        String[] toppingIds  = req.getParameterValues("toppingId");
        String[] toppingQtys = req.getParameterValues("toppingQty");

        if (productId <= 0 || sizeId <= 0 || invalidQuantity) {
            resp.sendRedirect(req.getContextPath() + "/user/shop?id=" + shopId + "&error=invalid");
            return;
        }

        Shop shop = shopDAO.selectShopById(shopId);
        if (shop == null) {
            resp.sendRedirect(req.getContextPath() + "/user/shop?id=" + shopId + "&error=invalid");
            return;
        }
        if (!shop.isOpenNow()) {
            resp.sendRedirect(req.getContextPath() + "/user/shop?id=" + shopId + "&error=shop_closed");
            return;
        }

        ProductSize size = productSizeDAO.findById(sizeId);
        if (size == null) {
            resp.sendRedirect(req.getContextPath() + "/user/shop?id=" + shopId + "&error=invalid_size");
            return;
        }
        // Size phải thuộc đúng sản phẩm và đúng shop đang đặt; nếu không, client có thể ghép món này với giá size của món/shop khác.
        if (size.getProductId() != productId || size.getShopId() != shopId) {
            resp.sendRedirect(req.getContextPath() + "/user/shop?id=" + shopId + "&error=invalid_size");
            return;
        }
        if (size.isOutOfStock()) {
            resp.sendRedirect(req.getContextPath() + "/user/shop?id=" + shopId + "&error=out_of_stock");
            return;
        }

        Cart cart = cartDAO.findByUserId(account.getId());
        long cartId;
        if (cart == null) {
            Cart newCart = new Cart();
            newCart.setUserId(account.getId());
            cartId = cartDAO.createAndReturnId(newCart);
            if (cartId <= 0) {
                resp.sendRedirect(req.getContextPath() + "/user/shop?id=" + shopId + "&error=cart_fail");
                return;
            }
        } else {
            cartId = cart.getId();
        }

        // Giỏ hàng chỉ được chứa sản phẩm của 1 Shop tại 1 thời điểm. Neu gio hien co mon cua
        // Shop khac, chi cho phep them khi da duoc xac nhan (confirmSwitchShop=1, JS da hoi truoc
        // khi submit - xem menuShop.jsp). Da xac nhan thi xoa toan bo CartItem cu roi moi them moi;
        // FK Cart_Item_Toppings ON DELETE CASCADE tu don dep topping cua tung item bi xoa.
        java.util.List<CartItem> existingItems = cartItemDAO.findByCartId(cartId);
        if (!existingItems.isEmpty()) {
            long existingShopId = -1;
            Product existingProduct = productDAO.findById(existingItems.get(0).getProductId());
            if (existingProduct != null) existingShopId = existingProduct.getShopId();

            if (existingShopId != shopId) {
                boolean confirmSwitch = "1".equals(req.getParameter("confirmSwitchShop"));
                if (!confirmSwitch) {
                    resp.sendRedirect(req.getContextPath() + "/user/shop?id=" + shopId + "&error=shop_conflict");
                    return;
                }
                for (CartItem oldItem : existingItems) {
                    cartItemDAO.delete(oldItem.getId());
                }
            }
        }

        CartItem existing = cartItemDAO.findByCartIdProductSize(cartId, productId, sizeId);
        if (existing != null) {
            cartItemDAO.incrementQuantity(existing.getId(), quantity);
        } else {
            CartItem item = new CartItem();
            item.setCartId(cartId);
            item.setProductId(productId);
            item.setProductSizeId(sizeId);
            item.setQuantity(quantity);
            long cartItemId = cartItemDAO.createAndReturnId(item);
            if (cartItemId > 0 && toppingIds != null) {
                for (int i = 0; i < toppingIds.length; i++) {
                    long toppingId = parseLong(toppingIds[i]);
                    int toppingQty = (toppingQtys != null && i < toppingQtys.length)
                            ? parseInt(toppingQtys[i], 1) : 1;
                    if (toppingId > 0 && toppingQty > 0) {
                        cartItemToppingDAO.create(cartItemId, toppingId, toppingQty);
                    }
                }
            }
        }

        resp.sendRedirect(req.getContextPath() + "/user/shop?id=" + shopId + "&added=1&cartId=" + cartId + "&addedProductId=" + productId);
    }

    private long parseLong(String s) {
        try { return Long.parseLong(s); } catch (Exception e) { return 0; }
    }

    private boolean isPositiveInt(String s) {
        try { return Integer.parseInt(s) > 0; } catch (Exception e) { return false; }
    }

    private int parseInt(String s, int def) {
        try { int v = Integer.parseInt(s); return v > 0 ? v : def; } catch (Exception e) { return def; }
    }
}
