package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.daos.*;
import org.example.models.FeaturedProduct;
import org.example.models.Product;
import org.example.models.ProductSize;
import org.example.models.Shop;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Trang chu cong khai (khong can dang nhap). Duoc anh xa dung vao "/index.jsp" de
 * "shadow" JSP tinh: khi trinh duyet vao "/", Tomcat tu forward toi welcome-file
 * "/index.jsp", va servlet mapping nay se duoc uu tien xu ly truoc thay vi de
 * Jasper render truc tiep file JSP. Xem AppFilter (whitelist ".../index.jsp").
 */
@WebServlet("/index.jsp")
public class IndexServlet extends HttpServlet {

    private final ShopDAO shopDAO = new ShopDAOImpl();
    private final ProductDAO productDAO = new ProductDAOImpl();
    private final ProductSizeDAO productSizeDAO = new ProductSizeDAOImpl();
    private final ProductImageDAO productImageDAO = new ProductImageDAOImpl();
    private final FeedbackDAO feedbackDAO = new FeedbackDAOImpl();

    private static final int FEATURED_LIMIT = 6;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("featuredProducts", buildFeaturedProducts());
        req.getRequestDispatcher("/TrangChu.jsp").forward(req, resp);
    }

    // Chon top mon "noi bat": uu tien shop co rating trung binh cao nhat, hoa
    // (hoac chua co rating) thi lay theo so luong da ban (soldCount) nhieu hon.
    private List<FeaturedProduct> buildFeaturedProducts() {
        List<Shop> activeShops = shopDAO.selectAllShops().stream()
                .filter(s -> !s.isDeleted())
                .filter(s -> {
                    String st = s.getStatus() == null ? "" : s.getStatus().trim().toLowerCase();
                    return st.equals("accept") || st.equals("accepted")
                            || st.equals("approved") || st.equals("active");
                })
                .collect(Collectors.toList());

        List<FeaturedProduct> candidates = new ArrayList<>();
        for (Shop shop : activeShops) {
            double shopRating = feedbackDAO.avgRating("SHOP", shop.getId());
            List<Product> products = productDAO.findByShopId(shop.getId());
            if (products == null) continue;

            for (Product p : products) {
                String st = p.getStaTus() == null ? "" : p.getStaTus().trim().toUpperCase();
                if (st.equals("HIDDEN") || st.equals("PENDING_REVIEW") || st.equals("OUT_OF_STOCK")) continue;

                List<ProductSize> sizes = productSizeDAO.findByProductId(p.getId());
                if (sizes == null || sizes.isEmpty()) continue;

                candidates.add(new FeaturedProduct(
                        p.getId(), p.getProductName(), p.getDescription(),
                        sizes.get(0).getPrice(), null, shop.getShopName(),
                        shopRating, p.getSoldCount()));
            }
        }

        candidates.sort((a, b) -> {
            int cmp = Double.compare(b.getShopRating(), a.getShopRating());
            if (cmp != 0) return cmp;
            return Integer.compare(b.getSoldCount(), a.getSoldCount());
        });

        List<FeaturedProduct> top = candidates.stream().limit(FEATURED_LIMIT).collect(Collectors.toList());
        if (top.isEmpty()) return top;

        List<Long> ids = top.stream().map(FeaturedProduct::getProductId).collect(Collectors.toList());
        Map<Long, String> imgMap = productImageDAO.findPrimaryUrlsByProductIds(ids);

        List<FeaturedProduct> result = new ArrayList<>();
        for (FeaturedProduct f : top) {
            result.add(new FeaturedProduct(
                    f.getProductId(), f.getProductName(), f.getDescription(), f.getPrice(),
                    imgMap.get(f.getProductId()), f.getShopName(), f.getShopRating(), f.getSoldCount()));
        }
        return result;
    }
}
