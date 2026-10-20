package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.ShopDAO;
import org.example.daos.ShopDAOImpl;
import org.example.daos.ToppingCategoryDAO;
import org.example.daos.ToppingCategoryDAOImpl;
import org.example.daos.ToppingDAO;
import org.example.daos.ToppingDAOImpl;
import org.example.models.Account;
import org.example.models.Shop;
import org.example.models.Topping;
import org.example.models.ToppingCategory;

import java.io.IOException;
import java.util.List;
import java.util.Locale;

/**
 * Servlet quản lý Topping cho Shop Owner.
 * URL: /shop/toppings
 * JSP: /admin/Quanlytopping.jsp
 */
@WebServlet("/shop/toppings")
public class ShopToppingServlet extends HttpServlet {

    private static final String VIEW       = "/shop/Quanlytopping.jsp";
    private static final String VIEW_TRASH = "/shop/ThungRacTopping.jsp";

    private final ToppingDAO toppingDAO = new ToppingDAOImpl();
    private final ToppingCategoryDAO categoryDAO = new ToppingCategoryDAOImpl();
    private final ShopDAO shopDAO = new ShopDAOImpl();

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
            List<Topping> deletedToppings = toppingDAO.findDeletedByShopId(shop.getId());
            req.setAttribute("deletedToppings", deletedToppings);
            req.getRequestDispatcher(VIEW_TRASH).forward(req, resp);
            return;
        }

        if ("edit".equals(action)) {
            Long id = parseId(req);
            if (id == null) {
                req.setAttribute("loi", "ID topping không hợp lệ!");
            } else {
                Topping topping = toppingDAO.findById(id);
                if (topping == null || topping.getShopId() != shop.getId()) {
                    req.setAttribute("loi", "Không tìm thấy topping!");
                } else {
                    req.setAttribute("toppingSua", topping);
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
        boolean success;

        switch (action) {
            case "update":
                success = update(req, resp, shop);
                break;
            case "delete":
                success = delete(req, resp, shop);
                break;
            case "restore":
                restoreTopping(req, resp, shop);
                return;
            default: // create
                success = create(req, resp, shop);
                break;
        }

        if (success) {
            resp.sendRedirect(req.getContextPath() + "/shop/toppings?success=" + action);
        }
    }

    // ── CRUD ─────────────────────────────────────────────────────────────────

    private boolean create(HttpServletRequest req, HttpServletResponse resp, Shop shop)
            throws ServletException, IOException {
        Topping topping = readForm(req, shop.getId(), 0);
        String error = validate(topping, shop.getId());
        if (error != null) {
            req.setAttribute("loi", error);
            req.setAttribute("toppingForm", topping);
            forwardPage(req, resp, shop.getId());
            return false;
        }
        boolean ok = toppingDAO.create(topping);
        if (!ok) {
            req.setAttribute("loi", "Lỗi thêm topping, vui lòng thử lại!");
            req.setAttribute("toppingForm", topping);
            forwardPage(req, resp, shop.getId());
            return false;
        }
        return true;
    }

    private boolean update(HttpServletRequest req, HttpServletResponse resp, Shop shop)
            throws ServletException, IOException {
        Long id = parseId(req);
        if (id == null) {
            req.setAttribute("loi", "ID topping không hợp lệ!");
            forwardPage(req, resp, shop.getId());
            return false;
        }
        Topping existing = toppingDAO.findById(id);
        if (existing == null || existing.getShopId() != shop.getId()) {
            req.setAttribute("loi", "Không tìm thấy topping!");
            forwardPage(req, resp, shop.getId());
            return false;
        }
        Topping topping = readForm(req, shop.getId(), id);
        String error = validate(topping, shop.getId());
        if (error != null) {
            req.setAttribute("loi", error);
            req.setAttribute("toppingSua", topping);
            forwardPage(req, resp, shop.getId());
            return false;
        }
        boolean ok = toppingDAO.update(topping);
        if (!ok) {
            req.setAttribute("loi", "Lỗi cập nhật topping!");
            req.setAttribute("toppingSua", topping);
            forwardPage(req, resp, shop.getId());
            return false;
        }
        return true;
    }

    private boolean delete(HttpServletRequest req, HttpServletResponse resp, Shop shop)
            throws ServletException, IOException {
        Long id = parseId(req);
        if (id == null) {
            req.setAttribute("loi", "ID topping không hợp lệ!");
            forwardPage(req, resp, shop.getId());
            return false;
        }
        Topping existing = toppingDAO.findById(id);
        if (existing == null || existing.getShopId() != shop.getId()) {
            req.setAttribute("loi", "Không tìm thấy topping!");
            forwardPage(req, resp, shop.getId());
            return false;
        }
        boolean ok = toppingDAO.delete(id);
        if (!ok) {
            req.setAttribute("loi", "Lỗi xóa topping!");
            forwardPage(req, resp, shop.getId());
            return false;
        }
        return true;
    }

    private void restoreTopping(HttpServletRequest req, HttpServletResponse resp, Shop shop)
            throws ServletException, IOException {
        Long id = parseId(req);
        if (id == null) {
            req.setAttribute("loi", "ID topping không hợp lệ!");
            req.setAttribute("deletedToppings", toppingDAO.findDeletedByShopId(shop.getId()));
            req.getRequestDispatcher(VIEW_TRASH).forward(req, resp);
            return;
        }
        boolean ok = toppingDAO.restore(id, shop.getId());
        if (!ok) {
            req.setAttribute("loi", "Không thể khôi phục topping!");
            req.setAttribute("deletedToppings", toppingDAO.findDeletedByShopId(shop.getId()));
            req.getRequestDispatcher(VIEW_TRASH).forward(req, resp);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/shop/toppings?action=trash&success=restore");
    }

    // ── HELPERS ──────────────────────────────────────────────────────────────

    private void forwardPage(HttpServletRequest req, HttpServletResponse resp, long shopId)
            throws ServletException, IOException {
        List<Topping> danhsach = toppingDAO.findByShopId(shopId);
        List<ToppingCategory> danhsachLoai = categoryDAO.findByShopId(shopId);

        // Thống kê đơn giản
        long soDangBan = danhsach.stream()
                .filter(t -> "ACTIVE".equalsIgnoreCase(t.getStatus()))
                .count();

        req.setAttribute("danhsach", danhsach);
        req.setAttribute("danhsachLoai", danhsachLoai);
        req.setAttribute("soDangBan", (int) soDangBan);

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    private Topping readForm(HttpServletRequest req, long shopId, long id) {
        Topping t = new Topping(
                id,
                parseLong(req.getParameter("toppingCategoryId")),
                shopId,
                normalize(req.getParameter("toppingName")),
                parseDouble(req.getParameter("price")),
                normalizeStatus(req.getParameter("status")),
                false
        );
        return t;
    }

    private String validate(Topping t, long shopId) {
        if (t.getToppingName().isBlank()) return "Tên topping không được để trống!";
        String toppingNameError = org.example.utils.InputValidationUtil.checkLine("Tên topping", t.getToppingName(), 100);
        if (toppingNameError != null) return toppingNameError;
        if (t.getToppingCategoryId() <= 0) return "Vui lòng chọn loại topping!";
        if (t.getPrice() < 0) return "Giá topping không hợp lệ!";
        // Kiểm tra loại topping thuộc shop này
        ToppingCategory tc = categoryDAO.findById(t.getToppingCategoryId());
        if (tc == null || tc.getShopId() != shopId) return "Loại topping không hợp lệ!";
        return null;
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

    private Long parseId(HttpServletRequest req) {
        try {
            String v = normalize(req.getParameter("id"));
            return v.isEmpty() ? null : Long.parseLong(v);
        } catch (Exception e) {
            return null;
        }
    }

    private long parseLong(String value) {
        try {
            String v = normalize(value);
            return v.isEmpty() ? 0 : Long.parseLong(v);
        } catch (Exception e) {
            return 0;
        }
    }

    private double parseDouble(String value) {
        try {
            String v = normalize(value);
            return v.isEmpty() ? 0 : Double.parseDouble(v);
        } catch (Exception e) {
            return 0;
        }
    }

    private String normalizeStatus(String value) {
        String s = normalize(value).toUpperCase(Locale.ROOT);
        return "OUT_OF_STOCK".equals(s) ? s : "ACTIVE";
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }
}