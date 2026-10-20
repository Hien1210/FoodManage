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
import org.example.daos.ToppingCategoryDAO;
import org.example.daos.ToppingCategoryDAOImpl;
import org.example.models.Account;
import org.example.models.Category;
import org.example.models.Shop;
import org.example.models.ToppingCategory;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Servlet quản lý Loại Topping cho Shop Owner.
 * URL : /shop/topping-categories
 * JSP : /admin/Quanlyloaitopping.jsp
 */
@WebServlet("/shop/topping-categories")
public class QuanLyLoaiToppingServlet extends HttpServlet {




        private static final String VIEW       = "/shop/Quanlyloaitopping.jsp";
        private static final String VIEW_TRASH = "/shop/ThungRacLoaiTopping.jsp";

        private final ToppingCategoryDAO categoryDAO = new ToppingCategoryDAOImpl();
        private final ShopDAO            shopDAO     = new ShopDAOImpl();
        private final CategoryDAO        productCategoryDAO = new CategoryDAOImpl();

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
                List<ToppingCategory> deletedCats = categoryDAO.findDeletedByShopId(shop.getId());
                req.setAttribute("deletedCategories", deletedCats);
                req.getRequestDispatcher(VIEW_TRASH).forward(req, resp);
                return;
            }

            if ("edit".equals(action)) {
                Long id = parseId(req);
                if (id == null) {
                    req.setAttribute("loi", "ID loại topping không hợp lệ!");
                } else {
                    ToppingCategory cat = categoryDAO.findById(id);
                    // Bảo mật: chỉ cho sửa loại topping thuộc shop mình
                    if (cat == null || cat.getShopId() != shop.getId()) {
                        req.setAttribute("loi", "Không tìm thấy loại topping!");
                    } else {
                        req.setAttribute("categorySua", cat);
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
                    restoreToppingCategory(req, resp, shop);
                    return;
                default: // create
                    success = create(req, resp, shop);
                    break;
            }

            if (success) {
                resp.sendRedirect(req.getContextPath() + "/shop/topping-categories?success=" + action);
            }
        }

        // ── CRUD ─────────────────────────────────────────────────────────────────

        /** Thêm loại topping mới */
        private boolean create(HttpServletRequest req, HttpServletResponse resp, Shop shop)
                throws ServletException, IOException {

            ToppingCategory cat = readForm(req, shop.getId(), 0);
            String error = validate(cat, shop.getId());
            if (error != null) {
                req.setAttribute("loi", error);
                req.setAttribute("categoryForm", cat);
                forwardPage(req, resp, shop.getId());
                return false;
            }

            boolean ok = categoryDAO.create(cat);
            if (!ok) {
                req.setAttribute("loi", "Lỗi tạo loại topping, vui lòng thử lại!");
                req.setAttribute("categoryForm", cat);
                forwardPage(req, resp, shop.getId());
                return false;
            }
            return true;
        }

        /** Cập nhật loại topping */
        private boolean update(HttpServletRequest req, HttpServletResponse resp, Shop shop)
                throws ServletException, IOException {

            Long id = parseId(req);
            if (id == null) {
                req.setAttribute("loi", "ID loại topping không hợp lệ!");
                forwardPage(req, resp, shop.getId());
                return false;
            }

            ToppingCategory existing = categoryDAO.findById(id);
            // Bảo mật: chỉ cho sửa loại topping thuộc shop mình
            if (existing == null || existing.getShopId() != shop.getId()) {
                req.setAttribute("loi", "Không tìm thấy loại topping!");
                forwardPage(req, resp, shop.getId());
                return false;
            }

            ToppingCategory cat = readForm(req, shop.getId(), id);
            String error = validate(cat, shop.getId());
            if (error != null) {
                req.setAttribute("loi", error);
                req.setAttribute("categorySua", cat);
                forwardPage(req, resp, shop.getId());
                return false;
            }

            boolean ok = categoryDAO.update(cat);
            if (!ok) {
                req.setAttribute("loi", "Lỗi cập nhật loại topping!");
                req.setAttribute("categorySua", cat);
                forwardPage(req, resp, shop.getId());
                return false;
            }
            return true;
        }

        /** Xóa loại topping (soft delete) */
        private boolean delete(HttpServletRequest req, HttpServletResponse resp, Shop shop)
                throws ServletException, IOException {

            Long id = parseId(req);
            if (id == null) {
                req.setAttribute("loi", "ID loại topping không hợp lệ!");
                forwardPage(req, resp, shop.getId());
                return false;
            }

            ToppingCategory existing = categoryDAO.findById(id);
            // Bảo mật: chỉ cho xóa loại topping thuộc shop mình
            if (existing == null || existing.getShopId() != shop.getId()) {
                req.setAttribute("loi", "Không tìm thấy loại topping!");
                forwardPage(req, resp, shop.getId());
                return false;
            }

            boolean ok = categoryDAO.delete(id);
            if (!ok) {
                req.setAttribute("loi", "Lỗi xóa loại topping!");
                forwardPage(req, resp, shop.getId());
                return false;
            }
            return true;
        }

        private void restoreToppingCategory(HttpServletRequest req, HttpServletResponse resp, Shop shop)
                throws ServletException, IOException {
            Long id = parseId(req);
            if (id == null) {
                req.setAttribute("loi", "ID loại topping không hợp lệ!");
                req.setAttribute("deletedCategories", categoryDAO.findDeletedByShopId(shop.getId()));
                req.getRequestDispatcher(VIEW_TRASH).forward(req, resp);
                return;
            }
            Boolean ok = categoryDAO.restore(id, shop.getId());
            if (ok == null || !ok) {
                req.setAttribute("loi", "Không thể khôi phục loại topping!");
                req.setAttribute("deletedCategories", categoryDAO.findDeletedByShopId(shop.getId()));
                req.getRequestDispatcher(VIEW_TRASH).forward(req, resp);
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/shop/topping-categories?action=trash&success=restore");
        }

        // ── HELPERS ──────────────────────────────────────────────────────────────

        /** Forward đến JSP kèm danh sách và thống kê */
        private void forwardPage(HttpServletRequest req, HttpServletResponse resp, long shopId)
                throws ServletException, IOException {

            List<ToppingCategory> danhsach = categoryDAO.findByShopId(shopId);
            List<Category> danhSachLoaiSanPham = productCategoryDAO.findByShopId(shopId);

            req.setAttribute("danhsach", danhsach);
            req.setAttribute("danhSachLoaiSanPham", danhSachLoaiSanPham);

            req.getRequestDispatcher(VIEW).forward(req, resp);
        }

        /**
         * Đọc dữ liệu từ form.
         * JSP dùng field "categoryName" → ánh xạ vào categoryName của ToppingCategory.
         * "productCategoryId" (co the co NHIEU gia tri, checkbox) = cac loai san pham ma loai
         * topping nay ap dung (khong chon gi = ap dung cho moi loai).
         */
        private ToppingCategory readForm(HttpServletRequest req, long shopId, long id) {
            ToppingCategory cat = new ToppingCategory();
            cat.setId(id);
            cat.setShopId(shopId);
            cat.setName(normalize(req.getParameter("categoryName")));
            cat.setDescription(normalize(req.getParameter("description")));

            String[] productCategoryIdsRaw = req.getParameterValues("productCategoryId");
            List<Long> categoryIds = new ArrayList<>();
            if (productCategoryIdsRaw != null) {
                for (String raw : productCategoryIdsRaw) {
                    String v = normalize(raw);
                    if (v.isEmpty()) continue;
                    try {
                        categoryIds.add(Long.parseLong(v));
                    } catch (NumberFormatException ignored) {
                        // gia tri khong hop le -> bo qua
                    }
                }
            }
            cat.setCategoryIds(categoryIds);
            return cat;
        }

        /** Validate dữ liệu */
        private String validate(ToppingCategory cat, long shopId) {
            if (cat.getName().isBlank()) {
                return "Tên loại topping không được để trống!";
            }
            if (cat.getName().length() > 100) {
                return "Tên loại topping không được vượt quá 100 ký tự!";
            }
            String textError = org.example.utils.InputValidationUtil.firstError(
                    org.example.utils.InputValidationUtil.checkLine("Tên loại topping", cat.getName(), 100),
                    org.example.utils.InputValidationUtil.checkMultiline("Mô tả", cat.getDescription(), 2000));
            if (textError != null) {
                return textError;
            }
            if (!cat.getCategoryIds().isEmpty()) {
                // Chong IDOR: khong cho gan loai topping vao loai san pham cua SHOP KHAC.
                List<Long> shopCategoryIds = productCategoryDAO.findByShopId(shopId).stream()
                        .map(c -> c.getId()).collect(java.util.stream.Collectors.toList());
                for (Long categoryId : cat.getCategoryIds()) {
                    if (!shopCategoryIds.contains(categoryId)) {
                        return "Loại sản phẩm không hợp lệ!";
                    }
                }
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

        private String normalize(String value) {
            return value == null ? "" : value.trim();
        }
    }

