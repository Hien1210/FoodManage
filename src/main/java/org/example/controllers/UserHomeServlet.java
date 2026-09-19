package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.*;
import org.example.models.*;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/user/home")
public class UserHomeServlet extends HttpServlet {

    private final ShopDAO shopDAO = new ShopDAOImpl();
    private final NotificationDAO notificationDAO = new NotificationDAOImpl();
    private final ProductDAO productDAO = new ProductDAOImpl();
    private final ProductImageDAO productImageDAO = new ProductImageDAOImpl();
    private final AccountDAO accountDAO = new AccountDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Account account = session == null ? null : (Account) session.getAttribute("account");
        if (account == null || account.getRoleId() != 3) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        List<Shop> allShops = shopDAO.selectAllShops();
        List<Shop> activeShops = allShops.stream()
                .filter(s -> {
                    String st = s.getStatus() == null ? "" : s.getStatus().trim().toLowerCase();
                    return st.equals("accept") || st.equals("accepted")
                            || st.equals("approved") || st.equals("active");
                })
                .collect(Collectors.toList());

        // Chỉ mục tìm kiếm: shopId -> danh sách tên món
        JSONObject shopProductsIndex = new JSONObject();
        for (Shop shop : activeShops) {
            List<Product> products = productDAO.findByShopId(shop.getId());

            // Tự động kiểm tra tính hợp lệ của URL logo, nếu là chuỗi văn bản hỏng thì tự chọn ảnh sản phẩm hoặc banner đẹp
            if (!isValidUrl(shop.getShopLogo())) {
                shop.setShopLogo(null);
            }
            if (shop.getShopLogo() == null) {
                if (products != null && !products.isEmpty()) {
                    List<Long> pIds = products.stream().map(Product::getId).collect(Collectors.toList());
                    java.util.Map<Long, String> imgMap = productImageDAO.findPrimaryUrlsByProductIds(pIds);
                    for (Product p : products) {
                        String img = imgMap.get(p.getId());
                        if (img != null && isValidUrl(img)) {
                            shop.setShopLogo(img);
                            break;
                        }
                    }
                }
            }
            if (shop.getShopLogo() == null) {
                shop.setShopLogo(getDefaultShopLogo(shop.getShopName()));
            }

            JSONArray names = new JSONArray();
            for (Product p : products) {
                if ("HIDDEN".equalsIgnoreCase(p.getStaTus())) continue;
                if (p.getProductName() != null) names.put(p.getProductName());
            }
            if (names.length() > 0) {
                shopProductsIndex.put(String.valueOf(shop.getId()), names);
            }
        }

        req.setAttribute("shops", activeShops);
        req.setAttribute("account", account);
        req.setAttribute("loyaltyPoints", accountDAO.getLoyaltyPoints(account.getId()));
        req.setAttribute("unreadNotifCount", notificationDAO.countUnread(account.getId()));
        req.setAttribute("shopProductsJson", shopProductsIndex.toString());
        req.getRequestDispatcher("/user/trangnguoidung.jsp").forward(req, resp);
    }

    private boolean isValidUrl(String url) {
        if (url == null || url.trim().isEmpty()) return false;
        String u = url.trim().toLowerCase();
        return u.startsWith("http://") || u.startsWith("https://") || u.startsWith("/") || u.startsWith("assets/");
    }

    private String getDefaultShopLogo(String shopName) {
        if (shopName == null) return "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80";
        String lower = shopName.toLowerCase();
        if (lower.contains("trà sữa") || lower.contains("boba") || lower.contains("wishe")) {
            return "https://images.unsplash.com/photo-1558857563-b371033873b8?auto=format&fit=crop&w=600&q=80";
        }
        if (lower.contains("caffe") || lower.contains("ca phê") || lower.contains("coffee")) {
            return "https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=600&q=80";
        }
        if (lower.contains("dê") || lower.contains("thịt")) {
            return "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80";
        }
        return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80";
    }
}
