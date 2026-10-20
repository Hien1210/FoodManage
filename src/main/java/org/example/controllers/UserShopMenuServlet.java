package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.*;
import org.example.models.*;
import java.util.Collections;

import java.io.IOException;
import java.util.List;

@WebServlet("/user/shop")
public class UserShopMenuServlet extends HttpServlet {

    private final ShopDAO shopDAO = new ShopDAOImpl();
    private final ProductDAO productDAO = new ProductDAOImpl();
    private final ProductSizeDAO productSizeDAO = new ProductSizeDAOImpl();
    private final ProductImageDAO productImageDAO = new ProductImageDAOImpl();
    private final ToppingDAO toppingDAO = new ToppingDAOImpl();
    private final ToppingCategoryDAO toppingCategoryDAO = new ToppingCategoryDAOImpl();
    private final CategoryDAO categoryDAO = new CategoryDAOImpl();
    private final CartDAO cartDAO = new CartDAOImpl();
    private final CartItemDAO cartItemDAO = new CartItemDAOImpl();
    private final FeedbackDAO feedbackDAO = new FeedbackDAOImpl();
    private final ComboDAO comboDAO = new ComboDAOImpl();

    private final FlashSaleDAO flashSaleDAO = new FlashSaleDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Account account = session == null ? null : (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 3) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        long shopId = 0;
        try { shopId = Long.parseLong(req.getParameter("id")); } catch (Exception ignored) {}

        Shop shop = shopId > 0 ? shopDAO.selectShopById(shopId) : null;
        if (shop == null) {
            resp.sendRedirect(req.getContextPath() + "/user/home");
            return;
        }

        List<FlashSale> activeFlashSales = flashSaleDAO.findActiveByShopId(shopId);
        java.util.Map<Long, FlashSale> flashSaleMap = new java.util.HashMap<>();
        if (activeFlashSales != null) {
            for (FlashSale fs : activeFlashSales) {
                flashSaleMap.put(fs.getProductSizeId(), fs);
            }
        }

        List<Product> products = productDAO.findByShopId(shopId);
        products.removeIf(p -> "HIDDEN".equalsIgnoreCase(p.getStaTus()));
        java.util.Map<Long, String> imageUrls = productImageDAO.findPrimaryUrlsByProductIds(
                products.stream().map(Product::getId).collect(java.util.stream.Collectors.toList()));
        for (Product p : products) {
            List<ProductSize> sizes = productSizeDAO.findByProductId(p.getId());
            if (sizes != null) {
                for (ProductSize s : sizes) {
                    if (flashSaleMap.containsKey(s.getId())) {
                        FlashSale fs = flashSaleMap.get(s.getId());
                        s.setSalePrice(fs.getSalePrice());
                        s.setSaleEndTime(fs.getEndTime());
                    }
                }
            }
            p.setSizes(sizes);
            p.setImageUrl(imageUrls.get(p.getId()));
        }

        if (!isValidUrl(shop.getShopLogo())) {
            shop.setShopLogo(null);
        }
        if (shop.getShopLogo() == null) {
            for (Product p : products) {
                if (p.getImageUrl() != null && isValidUrl(p.getImageUrl())) {
                    shop.setShopLogo(p.getImageUrl());
                    break;
                }
            }
            if (shop.getShopLogo() == null) {
                shop.setShopLogo(getDefaultShopLogo());
            }
        }

        List<Category> categories = categoryDAO.findByShopId(shopId);
        List<Topping> toppings = toppingDAO.findByShopId(shopId);
        List<ToppingCategory> toppingCategories = toppingCategoryDAO.findByShopId(shopId);

        List<Combo> combos = comboDAO.findByShopId(shopId);
        if (combos != null) {
            combos.removeIf(c -> !c.isActive());
            for (Combo c : combos) {
                c.setItems(comboDAO.findItemsByComboId(c.getId()));
            }
        }

        Cart cart = cartDAO.findByUserId(account.getId());

        // Giỏ hàng chỉ được chứa sản phẩm của 1 Shop tại 1 thời điểm: nếu giỏ hiện có món của
        // Shop khác (khác Shop đang xem), báo cho JS biết để hỏi xác nhận trước khi cho thêm món mới.
        boolean cartHasOtherShop = false;
        String cartOtherShopName = "";
        if (cart != null) {
            List<CartItem> existingItems = cartItemDAO.findByCartId(cart.getId());
            if (!existingItems.isEmpty()) {
                Product firstProduct = productDAO.findById(existingItems.get(0).getProductId());
                if (firstProduct != null && firstProduct.getShopId() != shopId) {
                    cartHasOtherShop = true;
                    Shop otherShop = shopDAO.selectShopById(firstProduct.getShopId());
                    cartOtherShopName = otherShop != null ? otherShop.getShopName() : ("Shop #" + firstProduct.getShopId());
                }
            }
        }
        req.setAttribute("cartHasOtherShop", cartHasOtherShop);
        req.setAttribute("cartOtherShopName", cartOtherShopName);

        double avgRating = feedbackDAO.avgRating("SHOP", shopId);
        int totalFeedback = feedbackDAO.countByTarget("SHOP", shopId);

        req.setAttribute("shop", shop);
        req.setAttribute("shopOpenNow", shop.isOpenNow());
        req.setAttribute("products", products);
        req.setAttribute("categories", categories);
        req.setAttribute("toppings", toppings);
        req.setAttribute("toppingCategories", toppingCategories);
        req.setAttribute("combos", combos);
        req.setAttribute("activeFlashSales", activeFlashSales);
        req.setAttribute("cart", cart);
        req.setAttribute("avgRating", avgRating);
        req.setAttribute("totalFeedback", totalFeedback);
        req.setAttribute("account", account);
        req.setAttribute("unreadNotifCount", new NotificationDAOImpl().countUnread(account.getId()));

        // Combo Suggestion: chỉ tải khi user vừa thêm món (added=1)
        String addedParam = req.getParameter("added");
        String addedProductIdParam = req.getParameter("addedProductId");
        if ("1".equals(addedParam) && addedProductIdParam != null) {
            try {
                long addedProductId = Long.parseLong(addedProductIdParam);
                List<ComboItem> suggestions = comboDAO.findSuggestionsByProductId(addedProductId, shopId);
                // Loại trừ duplicate theo productId (giữ suggestion đầu tiên mỗi product)
                java.util.Set<Long> seen = new java.util.LinkedHashSet<>();
                java.util.List<ComboItem> deduped = new java.util.ArrayList<>();
                for (ComboItem ci : suggestions) {
                    if (seen.add(ci.getProductId())) deduped.add(ci);
                    if (deduped.size() >= 5) break;
                }
                req.setAttribute("comboSuggestions", deduped);
                // Lấy tên sản phẩm vừa thêm để hiển thị trong popup
                for (Product p : products) {
                    if (p.getId() == addedProductId) {
                        req.setAttribute("addedProductName", p.getProductName());
                        break;
                    }
                }
            } catch (NumberFormatException ignored) {}
        }

        req.getRequestDispatcher("/user/menuShop.jsp").forward(req, resp);
    }

    private boolean isValidUrl(String url) {
        if (url == null || url.trim().isEmpty()) return false;
        String u = url.trim().toLowerCase();
        return u.startsWith("http://") || u.startsWith("https://") || u.startsWith("/") || u.startsWith("assets/");
    }

    private String getDefaultShopLogo() {
        return "/assets/img/shop-placeholder.svg";
    }
}
