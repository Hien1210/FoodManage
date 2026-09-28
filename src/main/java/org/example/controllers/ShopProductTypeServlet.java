package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.CategoryDAO;
import org.example.daos.CategoryDAOImpl;
import org.example.daos.ShopDAO;
import org.example.daos.ShopDAOImpl;
import org.example.models.Account;
import org.example.models.Category;
import org.example.models.Shop;

import java.io.IOException;
import java.util.List;
import java.util.Locale;

/**
 * Servlet quản lý Loại Sản Phẩm (Category) cho Shop Owner.
 * URL  : /shop/product-types
 * JSP  : /admin/Quanlyloaisanpham.jsp
 */
@WebServlet("/shop/product-types")
public class ShopProductTypeServlet extends HttpServlet {

    private static final String VIEW       = "/shop/Quanlyloaisanpham.jsp";
    private static final String VIEW_TRASH = "/shop/ThungRacLoaiSanPham.jsp";

    private final CategoryDAO categoryDAO = new CategoryDAOImpl();
    private final ShopDAO     shopDAO     = new ShopDAOImpl();

    // ── GET ──────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        Account account = requireShopAccount(req, resp);
        if (account == null) return;

        Shop shop = requireApprovedShop(req, resp, account);
        if (shop == null) return;

        String action = normalize(req.getParameter("action"));

        if ("trash".equals(action)) {
            List<Category> deletedCategories = categoryDAO.findDeletedByShopId(shop.getId());
            req.setAttribute("deletedCategories", deletedCategories);
            req.getRequestDispatcher(VIEW_TRASH).forward(req, resp);
            return;
        }

        if ("edit".equals(action)) {
            Long id = parseId(req);
            if (id == null) {
                req.setAttribute("loi", "ID loại sản phẩm không hợp lệ!");
            } else {
                Category cat = categoryDAO.findById(id);
                // Bảo mật: chỉ cho sửa category thuộc shop mình
                if (cat == null || cat.getShopId() != shop.getId()) {
                    req.setAttribute("loi", "Không tìm thấy loại sản phẩm!");
                } else {
                    req.setAttribute("productTypeSua", cat);
                }
            }
        }

        forwardPage(req, resp, shop.getId());
    }

    // ── POST ─────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        Account account = requireShopAccount(req, resp);
        if (account == null) return;

        Shop shop = requireApprovedShop(req, resp, account);
        if (shop == null) return;

        String action = normalize(req.getParameter("action"));
        boolean success = false;

        switch (action) {
            case "update":
                success = update(req, resp, shop);
                break;
            case "delete":
                success = delete(req, resp, shop);
                break;
            case "restore":
                restoreCategory(req, resp, shop);
                return;
            default: // create
                success = create(req, resp, shop);
                break;
        }

        if (success) {
            resp.sendRedirect(req.getContextPath() + "/shop/product-types?success=" + action);
        }
    }

    // ── CRUD ─────────────────────────────────────────────────────────────────

    /** Thêm loại sản phẩm mới */
    private boolean create(HttpServletRequest req, HttpServletResponse resp, Shop shop)
            throws ServletException, IOException {

        Category cat = readForm(req, shop.getId(), 0);
        String error = validate(cat);
        if (error != null) {
            req.setAttribute("loi", error);
            req.setAttribute("productTypeForm", cat);
            forwardPage(req, resp, shop.getId());
            return false;
        }

        boolean ok = categoryDAO.create(cat);
        if (!ok) {
            req.setAttribute("loi", "Lỗi tạo loại sản phẩm, vui lòng thử lại!");
            req.setAttribute("productTypeForm", cat);
            forwardPage(req, resp, shop.getId());
            return false;
        }
        return true;
    }

    /** Cập nhật loại sản phẩm */
    private boolean update(HttpServletRequest req, HttpServletResponse resp, Shop shop)
            throws ServletException, IOException {

        Long id = parseId(req);
        if (id == null) {
            req.setAttribute("loi", "ID loại sản phẩm không hợp lệ!");
            forwardPage(req, resp, shop.getId());
            return false;
        }

        Category existing = categoryDAO.findById(id);
        // Bảo mật: chỉ cho sửa category thuộc shop mình
        if (existing == null || existing.getShopId() != shop.getId()) {
            req.setAttribute("loi", "Không tìm thấy loại sản phẩm!");
            forwardPage(req, resp, shop.getId());
            return false;
        }

        Category cat = readForm(req, shop.getId(), id);
        String error = validate(cat);
        if (error != null) {
            req.setAttribute("loi", error);
            req.setAttribute("productTypeSua", cat);
            forwardPage(req, resp, shop.getId());
            return false;
        }

        boolean ok = categoryDAO.update(cat);
        if (!ok) {
            req.setAttribute("loi", "Lỗi cập nhật loại sản phẩm!");
            req.setAttribute("productTypeSua", cat);
            forwardPage(req, resp, shop.getId());
            return false;
        }
        return true;
    }

    /** Xóa loại sản phẩm */
    private boolean delete(HttpServletRequest req, HttpServletResponse resp, Shop shop)
            throws ServletException, IOException {

        Long id = parseId(req);
        if (id == null) {
            req.setAttribute("loi", "ID loại sản phẩm không hợp lệ!");
            forwardPage(req, resp, shop.getId());
            return false;
        }

        Category existing = categoryDAO.findById(id);
        // Bảo mật: chỉ cho xóa category thuộc shop mình
        if (existing == null || existing.getShopId() != shop.getId()) {
            req.setAttribute("loi", "Không tìm thấy loại sản phẩm!");
            forwardPage(req, resp, shop.getId());
            return false;
        }

        boolean ok = categoryDAO.delete(id);
        if (!ok) {
            req.setAttribute("loi", "Lỗi xóa loại sản phẩm!");
            forwardPage(req, resp, shop.getId());
            return false;
        }
        return true;
    }

    private void restoreCategory(HttpServletRequest req, HttpServletResponse resp, Shop shop)
            throws ServletException, IOException {
        Long id = parseId(req);
        if (id == null) {
            req.setAttribute("loi", "ID loại sản phẩm không hợp lệ!");
            req.setAttribute("deletedCategories", categoryDAO.findDeletedByShopId(shop.getId()));
            req.getRequestDispatcher(VIEW_TRASH).forward(req, resp);
            return;
        }
        Boolean ok = categoryDAO.restore(id, shop.getId());
        if (ok == null || !ok) {
            req.setAttribute("loi", "Không thể khôi phục loại sản phẩm!");
            req.setAttribute("deletedCategories", categoryDAO.findDeletedByShopId(shop.getId()));
            req.getRequestDispatcher(VIEW_TRASH).forward(req, resp);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/shop/product-types?action=trash&success=restore");
    }

    // ── HELPERS ──────────────────────────────────────────────────────────────

    /** Forward đến trang JSP, kèm danh sách và thống kê */
    private void forwardPage(HttpServletRequest req, HttpServletResponse resp, long shopId)
            throws ServletException, IOException {

        List<Category> danhsach = categoryDAO.findByShopId(shopId);

        // Thống kê: số loại đang hiển thị (ACTIVE hoặc rỗng/mặc định)
        long soLoaiDangHoatDong = danhsach.stream()
                .filter(c -> c.getStatus() == null || c.getStatus().isBlank() || "ACTIVE".equalsIgnoreCase(c.getStatus()))
                .count();

        req.setAttribute("danhsach", danhsach);
        req.setAttribute("soLoaiDangHoatDong", (int) soLoaiDangHoatDong);

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    /**
     * Đọc dữ liệu từ form.
     * JSP dùng field "typeName" → ánh xạ vào categoryName của model Category.
     */
    private Category readForm(HttpServletRequest req, long shopId, long id) {
        Category cat = new Category();
        cat.setId(id);
        cat.setShopId(shopId);
        // Field "typeName" trong JSP → categoryName trong model
        cat.setCategoryName(normalize(req.getParameter("typeName")));
        cat.setStatus(normalizeStatus(req.getParameter("status")));
        return cat;
    }

    /** Validate dữ liệu cơ bản */
    private String validate(Category cat) {
        String charError = org.example.utils.InputValidationUtil.checkLine("Tên loại sản phẩm", cat.getCategoryName(), 100);
        if (charError != null) {
            return charError;
        }
        if (cat.getCategoryName().isBlank()) {
            return "Tên loại sản phẩm không được để trống!";
        }
        if (cat.getCategoryName().length() > 100) {
            return "Tên loại sản phẩm không được vượt quá 100 ký tự!";
        }
        return null;
    }

    // ── AUTH ─────────────────────────────────────────────────────────────────

    /** Kiểm tra đăng nhập và role shop (roleId = 2) */
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

    /** Kiểm tra shop đã được duyệt chưa */
    private Shop requireApprovedShop(HttpServletRequest req, HttpServletResponse resp, Account account)
            throws ServletException, IOException {
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
        String v = normalize(status).toLowerCase(Locale.ROOT);
        return "accept".equals(v) || "accepted".equals(v) || "approved".equals(v) || "active".equals(v);
    }

    // ── UTILS ────────────────────────────────────────────────────────────────

    private Long parseId(HttpServletRequest req) {
        try {
            String v = normalize(req.getParameter("id"));
            return v.isEmpty() ? null : Long.parseLong(v);
        } catch (Exception e) {
            return null;
        }
    }

    private String normalizeStatus(String value) {
        String s = normalize(value);
        return s.isBlank() ? "ACTIVE" : s.toUpperCase(Locale.ROOT);
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }
}