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
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
@WebServlet("/shop/products")
public class ShopProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAOImpl();
    private final ProductSizeDAO productSizeDAO = new ProductSizeDAOImpl();
    private final ProductImageDAO productImageDAO = new ProductImageDAOImpl();
    private final CategoryDAO categoryDAO = new CategoryDAOImpl();
    private final ShopDAO shopDAO = new ShopDAOImpl();

    private static final String VIEW_LIST  = "/shop/Quanlysanpham.jsp";
    private static final String VIEW_TRASH = "/shop/ThungRacSanPham.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Account account = (session != null) ? (Account) session.getAttribute("account") : null;

        if (account == null || account.getRoleId() != 2) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        Shop shop = shopDAO.selectShopByOwnerId(account.getId());
        if (shop == null) {
            req.setAttribute("loi", "Bạn chưa có cửa hàng! Vui lòng đăng ký shop.");
            req.getRequestDispatcher(VIEW_LIST).forward(req, resp);
            return;
        }
        req.setAttribute("currentShop", shop);
        session.setAttribute("currentShop", shop);

        String action = req.getParameter("action");

        if ("edit".equals(action)) {
            Long id = parseId(req);
            if (id == null) {
                req.setAttribute("loi", "ID sản phẩm không hợp lệ!");
                forwardProductPage(req, resp, shop.getId());
                return;
            }

            Product product = productDAO.findById(id, shop.getId());
            if (product == null) {
                req.setAttribute("loi", "Không tìm thấy sản phẩm!");
                forwardProductPage(req, resp, shop.getId());
                return;
            }

            List<ProductSize> sizes = productSizeDAO.findByProductId(id);
            product.setSizes(sizes);
            product.setImageUrl(productImageDAO.findPrimaryUrlByProductId(id));

            req.setAttribute("productSua", product);
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        if ("trash".equals(action)) {
            List<Product> deletedProducts = productDAO.findDeletedByShopId(shop.getId());
            req.setAttribute("deletedProducts", deletedProducts);
            req.getRequestDispatcher(VIEW_TRASH).forward(req, resp);
            return;
        }

        if ("sizes".equals(action)) {
            // Quản lý size được thực hiện trực tiếp trong trang sản phẩm (modal sửa)
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        forwardProductPage(req, resp, shop.getId());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        Account account = (session != null) ? (Account) session.getAttribute("account") : null;

        if (account == null || account.getRoleId() != 2) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        Shop shop = shopDAO.selectShopByOwnerId(account.getId());
        if (shop == null) {
            req.setAttribute("loi", "Bạn chưa có cửa hàng!");
            req.getRequestDispatcher(VIEW_LIST).forward(req, resp);
            return;
        }

        String action = normalize(req.getParameter("action"));

        try {
            switch (action) {
                case "create":
                    createProduct(req, resp, shop);
                    break;
                case "update":
                    updateProduct(req, resp, shop);
                    break;
                case "delete":
                    deleteProduct(req, resp, shop);
                    break;
                case "restore":
                    restoreProduct(req, resp, shop);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/shop/products");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("loi", "Có lỗi xảy ra, vui lòng thử lại. Nếu lỗi lặp lại hãy liên hệ quản trị viên.");
            forwardProductPage(req, resp, shop.getId());
        }
    }

    // ─── CREATE PRODUCT ──────────────────────────────────────────────


    private void createProduct(HttpServletRequest req, HttpServletResponse resp, Shop shop)
            throws ServletException, IOException {

        String name = normalize(req.getParameter("productName"));
        Long categoryId = parseLong(req.getParameter("productTypeId"));
        int soldCount = parseInt(req.getParameter("soldCount"), 0);
        Integer stockQuantity = parseStockQuantity(req);
        String status = normalize(req.getParameter("status"));
        String imageUrl = normalize(req.getParameter("imageUrl"));
        String description = normalize(req.getParameter("description"));

        // Validation
        String nameError = name.isEmpty() ? "Tên sản phẩm không được để trống!"
                : org.example.utils.InputValidationUtil.firstError(
                        org.example.utils.InputValidationUtil.checkLine("Tên sản phẩm", name, 255),
                        org.example.utils.InputValidationUtil.checkMultiline("Mô tả sản phẩm", description, 2000));
        if (nameError != null) {
            req.setAttribute("loi", nameError);
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        if (categoryId == null || categoryId <= 0) {
            req.setAttribute("loi", "Vui lòng chọn loại sản phẩm!");
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        if (stockQuantity != null && stockQuantity < 0) {
            req.setAttribute("loi", "Số lượng tồn kho không hợp lệ!");
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        List<ProductSize> sizesToCreate = readSizes(req);
        if (sizesToCreate.isEmpty()) {
            req.setAttribute("loi", "Vui lòng nhập giá cho sản phẩm (giá phải lớn hơn 0)!");
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        // Tạo sản phẩm
        Product product = new Product();
        product.setShopId(shop.getId());
        product.setCategoryId(categoryId);
        product.setProductName(name);
        product.setDescription(description);
        product.setSoldCount(soldCount);
        product.setStockQuantity(stockQuantity);
        // San pham moi luon cho Super Admin duyet, bo qua status tu form (xem CRUD_DA_LAM.md muc 44)
        product.setStaTus("PENDING_REVIEW");
        product.setImageUrl(imageUrl);

        long productId = productDAO.createAndReturnId(product);
        if (productId <= 0) {
            req.setAttribute("loi", "Không thể tạo sản phẩm!");
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        for (ProductSize size : sizesToCreate) {
            size.setProductId(productId);
            size.setShopId(shop.getId());
            productSizeDAO.create(size);
        }

        if (!imageUrl.isEmpty()) {
            productImageDAO.upsertPrimary(productId, imageUrl);
        }

        resp.sendRedirect(req.getContextPath() + "/shop/products?success=create");
    }

    /**
     * Đồng bộ size của 1 sản phẩm với danh sách size mới nhập trong form:
     * - Size trùng tên (không phân biệt hoa/thường) với size đã có: cập nhật giá, giữ nguyên id.
     * - Size chưa có: tạo mới.
     * - Size cũ không còn trong form: xóa; nếu xóa thất bại (vd đã được dùng trong Order_Details,
     *   vướng FK_Detail_Size) thì bỏ qua, không làm hỏng cả request.
     */
    private void syncSizes(long productId, long shopId, List<ProductSize> newSizes) {
        List<ProductSize> existingSizes = productSizeDAO.findByProductId(productId);
        Map<String, ProductSize> existingByName = new HashMap<>();
        for (ProductSize s : existingSizes) {
            existingByName.put(s.getSizeName().trim().toLowerCase(), s);
        }

        java.util.Set<Long> keptIds = new java.util.HashSet<>();
        for (ProductSize size : newSizes) {
            ProductSize match = existingByName.get(size.getSizeName().trim().toLowerCase());
            if (match != null) {
                match.setPrice(size.getPrice());
                match.setOutOfStock(size.isOutOfStock());
                productSizeDAO.update(match);
                keptIds.add(match.getId());
            } else {
                size.setProductId(productId);
                size.setShopId(shopId);
                productSizeDAO.create(size);
            }
        }

        for (ProductSize s : existingSizes) {
            if (!keptIds.contains(s.getId())) {
                productSizeDAO.delete(s.getId());
            }
        }
    }

    /** Đọc danh sách size hợp lệ (giá > 0) từ form. Nếu tên size để trống, tự động gán là "Mặc định". */
    private List<ProductSize> readSizes(HttpServletRequest req) {
        String[] sizeNames = req.getParameterValues("sizeName[]");
        String[] sizePrices = req.getParameterValues("sizePrice[]");
        // Checkbox chi gui gia tri khi duoc tick, nen khong the doc theo vi tri mang song song
        // voi sizeName[]/sizePrice[] duoc (so luong gia tri co the it hon). Dung chinh TEN size
        // (da duoc gan lam value cua checkbox) de doi chieu, khop voi cach syncSizes() ben duoi
        // cung dang so khop size theo ten (khong phan biet hoa/thuong).
        String[] outOfStockNames = req.getParameterValues("sizeOutOfStockNames");
        java.util.Set<String> outOfStockSet = new java.util.HashSet<>();
        if (outOfStockNames != null) {
            for (String n : outOfStockNames) {
                if (n != null) outOfStockSet.add(n.trim().toLowerCase());
            }
        }
        List<ProductSize> sizes = new java.util.ArrayList<>();

        int count = 0;
        if (sizeNames != null) count = sizeNames.length;
        if (sizePrices != null && sizePrices.length > count) count = sizePrices.length;

        for (int i = 0; i < count; i++) {
            String rawName = (sizeNames != null && i < sizeNames.length) ? sizeNames[i] : "";
            String sizeName = normalize(rawName);

            BigDecimal price = parseBigDecimal(
                    sizePrices != null && i < sizePrices.length ? sizePrices[i] : null
            );
            if (price == null || price.doubleValue() <= 0) continue;

            if (sizeName.isEmpty()) {
                sizeName = "Mặc định";
            }

            ProductSize size = new ProductSize();
            size.setSizeName(sizeName);
            size.setPrice(price.doubleValue());
            size.setOutOfStock(outOfStockSet.contains(sizeName.toLowerCase()) || outOfStockSet.contains("mặc định"));
            sizes.add(size);
        }
        return sizes;
    }

    // ─── UPDATE PRODUCT ──────────────────────────────────────────────

    private void updateProduct(HttpServletRequest req, HttpServletResponse resp, Shop shop)
            throws ServletException, IOException {

        Long id = parseLong(req.getParameter("id"));
        if (id == null) {
            req.setAttribute("loi", "ID sản phẩm không hợp lệ!");
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        Product existing = productDAO.findById(id, shop.getId());
        if (existing == null) {
            req.setAttribute("loi", "Không tìm thấy sản phẩm!");
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        String name = normalize(req.getParameter("productName"));
        Long categoryId = parseLong(req.getParameter("productTypeId"));
        int soldCount = parseInt(req.getParameter("soldCount"), 0);
        Integer stockQuantity = parseStockQuantity(req);
        String status = normalize(req.getParameter("status"));
        String imageUrl = normalize(req.getParameter("imageUrl"));
        String description = normalize(req.getParameter("description"));

        // Validation
        String nameError = name.isEmpty() ? "Tên sản phẩm không được để trống!"
                : org.example.utils.InputValidationUtil.firstError(
                        org.example.utils.InputValidationUtil.checkLine("Tên sản phẩm", name, 255),
                        org.example.utils.InputValidationUtil.checkMultiline("Mô tả sản phẩm", description, 2000));
        if (nameError != null) {
            req.setAttribute("loi", nameError);
            req.setAttribute("productSua", existing);
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        if (categoryId == null || categoryId <= 0) {
            req.setAttribute("loi", "Vui lòng chọn loại sản phẩm!");
            req.setAttribute("productSua", existing);
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        if (stockQuantity != null && stockQuantity < 0) {
            req.setAttribute("loi", "Số lượng tồn kho không hợp lệ!");
            req.setAttribute("productSua", existing);
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        List<ProductSize> sizesToCreate = readSizes(req);
        if (sizesToCreate.isEmpty()) {
            req.setAttribute("loi", "Vui lòng nhập giá cho sản phẩm (giá phải lớn hơn 0)!");
            req.setAttribute("productSua", existing);
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        // Cập nhật sản phẩm
        existing.setProductName(name);
        existing.setCategoryId(categoryId);
        existing.setDescription(description);
        existing.setSoldCount(soldCount);
        existing.setStockQuantity(stockQuantity);
        // San pham dang PENDING_REVIEW (cho Super Admin duyet): form sua khong co option nay nen
        // trinh duyet se tu chon option dau tien khi submit - giu nguyen PENDING_REVIEW, khong de
        // Shop vo tinh (hoac co y) lam san pham "len san" ngay khi chi sua cac truong khac.
        if (!"PENDING_REVIEW".equalsIgnoreCase(existing.getStaTus())) {
            existing.setStaTus(status.isEmpty() ? "ACTIVE" : status);
        }
        existing.setImageUrl(imageUrl);

        boolean updated = productDAO.update(existing);
        if (!updated) {
            req.setAttribute("loi", "Không thể cập nhật sản phẩm!");
            req.setAttribute("productSua", existing);
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        // Đồng bộ size: cập nhật size trùng tên (giữ nguyên id, tránh vỡ FK với Order_Details khi
        // size đã từng được đặt hàng), thêm size mới, chỉ xóa size không còn trong form nữa.
        syncSizes(id, shop.getId(), sizesToCreate);

        if (!imageUrl.isEmpty()) {
            productImageDAO.upsertPrimary(id, imageUrl);
        }

        resp.sendRedirect(req.getContextPath() + "/shop/products?success=update");
    }

    // ─── DELETE PRODUCT ──────────────────────────────────────────────

    private void deleteProduct(HttpServletRequest req, HttpServletResponse resp, Shop shop)
            throws IOException, ServletException {

        Long id = parseLong(req.getParameter("id"));
        if (id == null) {
            req.setAttribute("loi", "ID sản phẩm không hợp lệ!");
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        boolean deleted = productDAO.delete(id, shop.getId());
        if (!deleted) {
            req.setAttribute("loi", "Không thể xóa sản phẩm!");
            forwardProductPage(req, resp, shop.getId());
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/shop/products?success=delete");
    }

    // ─── RESTORE PRODUCT ────────────────────────────────────────────────

    private void restoreProduct(HttpServletRequest req, HttpServletResponse resp, Shop shop)
            throws IOException, ServletException {

        Long id = parseLong(req.getParameter("id"));
        if (id == null) {
            req.setAttribute("loi", "ID sản phẩm không hợp lệ!");
            List<Product> deletedProducts = productDAO.findDeletedByShopId(shop.getId());
            req.setAttribute("deletedProducts", deletedProducts);
            req.getRequestDispatcher(VIEW_TRASH).forward(req, resp);
            return;
        }

        boolean ok = productDAO.restore(id, shop.getId());
        if (!ok) {
            req.setAttribute("loi", "Không thể khôi phục sản phẩm!");
            List<Product> deletedProducts = productDAO.findDeletedByShopId(shop.getId());
            req.setAttribute("deletedProducts", deletedProducts);
            req.getRequestDispatcher(VIEW_TRASH).forward(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/shop/products?action=trash&success=restore");
    }

    // ─── FORWARD ──────────────────────────────────────────────────────

    private void forwardProductPage(HttpServletRequest req, HttpServletResponse resp, long shopId)
            throws ServletException, IOException {
        List<Product> products = productDAO.findByShopId(shopId);

        // 2. Lấy danh sách Category
        List<Category> categories = categoryDAO.findByShopId(shopId);
        Map<Long, String> categoryNames = new HashMap<>();
        for (Category c : categories) {
            categoryNames.put(c.getId(), c.getCategoryName());
        }

        // 3. Gán categoryName + size + ảnh đại diện cho từng sản phẩm, đồng thời tính thống kê
        int soDangBan = 0;
        int soHetHang = 0;
        int tongDaBan = 0;
        if (products != null) {
            Map<Long, String> imageUrls = productImageDAO.findPrimaryUrlsByProductIds(
                    products.stream().map(Product::getId).collect(java.util.stream.Collectors.toList()));

            for (Product p : products) {
                String catName = categoryNames.get(p.getCategoryId());
                p.setCategoryName(catName != null ? catName : "Chưa phân loại");

                List<ProductSize> sizes = productSizeDAO.findByProductId(p.getId());
                p.setSizes(sizes);
                p.setImageUrl(imageUrls.get(p.getId()));

                String st = p.getStaTus() == null ? "" : p.getStaTus().toUpperCase();
                if ("ACTIVE".equals(st)) soDangBan++;
                if ("OUT_OF_STOCK".equals(st)) soHetHang++;
                tongDaBan += p.getSoldCount();
            }
        }

        // 4. Gán vào Request
        req.setAttribute("danhsach", products);
        req.setAttribute("danhsachLoai", categories);
        req.setAttribute("soDangBan", soDangBan);
        req.setAttribute("soHetHang", soHetHang);
        req.setAttribute("tongDaBan", tongDaBan);

        req.getRequestDispatcher(VIEW_LIST).forward(req, resp);
    }

    // ─── UTILITY ──────────────────────────────────────────────────────

    private Long parseId(HttpServletRequest req) {
        try {
            return Long.parseLong(req.getParameter("id"));
        } catch (Exception e) {
            return null;
        }
    }

    private Long parseLong(String value) {
        try {
            return Long.parseLong(value);
        } catch (Exception e) {
            return null;
        }
    }

    private int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    /** null = khong xac dinh/khong gioi han ton kho (checkbox "stockUnknown" duoc tick hoac o nhap de trong). */
    private Integer parseStockQuantity(HttpServletRequest req) {
        if ("on".equals(req.getParameter("stockUnknown"))) {
            return null;
        }
        String raw = req.getParameter("stockQuantity");
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            return Integer.parseInt(raw.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private BigDecimal parseBigDecimal(String value) {
        try {
            return new BigDecimal(value);
        } catch (Exception e) {
            return null;
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }
}
