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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/shop/combo")
public class ShopComboServlet extends HttpServlet {

    private final ComboDAO comboDAO = new ComboDAOImpl();
    private final ProductDAO productDAO = new ProductDAOImpl();
    private final ProductSizeDAO productSizeDAO = new ProductSizeDAOImpl();
    private final ShopDAO shopDAO = new ShopDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Shop shop = getShop(req, resp);
        if (shop == null) return;

        List<Combo> combos = comboDAO.findByShopId(shop.getId());
        for (Combo c : combos) c.setItems(comboDAO.findItemsByComboId(c.getId()));
        req.setAttribute("combos", combos);

        List<Product> products = productDAO.findByShopId(shop.getId());
        req.setAttribute("products", products);

        java.util.Map<Long, String> productNameById = new java.util.LinkedHashMap<>();
        List<ProductSize> allSizes = new ArrayList<>();
        for (Product p : products) {
            productNameById.put(p.getId(), p.getProductName());
            List<ProductSize> sizes = productSizeDAO.findByProductId(p.getId());
            for (ProductSize s : sizes) {
                s.setProductId(p.getId());
                allSizes.add(s);
            }
        }
        req.setAttribute("allSizes", allSizes);
        req.setAttribute("productNameById", productNameById);

        req.setAttribute("shop", shop);
        req.getRequestDispatcher("/shop/Quanlycombo.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Shop shop = getShop(req, resp);
        if (shop == null) return;

        String action = req.getParameter("action");

        if ("delete".equals(action)) {
            long comboId = parseLong(req.getParameter("comboId"));
            Combo existing = comboDAO.findById(comboId);
            if (existing != null && existing.getShopId() == shop.getId()) {
                comboDAO.deleteItems(comboId);
                comboDAO.delete(comboId);
            }
            resp.sendRedirect(req.getContextPath() + "/shop/combo?deleted=1");
            return;
        }

        String name = trim(req.getParameter("name"));
        String description = trim(req.getParameter("description"));
        double price = parseDouble(req.getParameter("comboPrice"));
        String[] productSizeIds = req.getParameterValues("productSizeId[]");
        String[] quantities = req.getParameterValues("quantity[]");

        if (name.isEmpty() || price <= 0 || org.example.utils.InputValidationUtil.firstError(
                org.example.utils.InputValidationUtil.checkLine("Tên combo", name, 200),
                org.example.utils.InputValidationUtil.checkMultiline("Mô tả combo", description, 500)) != null) {
            resp.sendRedirect(req.getContextPath() + "/shop/combo?error=invalid");
            return;
        }

        String comboIdStr = trim(req.getParameter("comboId"));
        if (!comboIdStr.isEmpty()) {
            long comboId = parseLong(comboIdStr);
            Combo existing = comboDAO.findById(comboId);
            if (existing == null || existing.getShopId() != shop.getId()) {
                resp.sendRedirect(req.getContextPath() + "/shop/combo?error=notfound");
                return;
            }
            existing.setName(name);
            existing.setDescription(description);
            existing.setComboPrice(price);
            comboDAO.update(existing);
            comboDAO.deleteItems(comboId);
            addItems(comboId, productSizeIds, quantities, shop.getId());
        } else {
            Combo combo = new Combo();
            combo.setShopId(shop.getId());
            combo.setName(name);
            combo.setDescription(description);
            combo.setComboPrice(price);
            combo.setActive(true);
            long newId = comboDAO.create(combo);
            if (newId > 0) addItems(newId, productSizeIds, quantities, shop.getId());
        }

        resp.sendRedirect(req.getContextPath() + "/shop/combo?saved=1");
    }

    private void addItems(long comboId, String[] sizeIds, String[] quantities, long shopId) {
        if (sizeIds == null) return;
        for (int i = 0; i < sizeIds.length; i++) {
            long sizeId = parseLong(sizeIds[i]);
            int qty = (quantities != null && i < quantities.length) ? (int) parseDouble(quantities[i]) : 1;
            if (sizeId <= 0 || qty <= 0) continue;
            ProductSize size = productSizeDAO.findById(sizeId);
            if (size == null || size.getShopId() != shopId) continue;
            ComboItem item = new ComboItem();
            item.setComboId(comboId);
            item.setProductId(size.getProductId());
            item.setProductSizeId(sizeId);
            item.setQuantity(qty);
            comboDAO.addItem(item);
        }
    }

    private Shop getShop(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Account account = session != null ? (Account) session.getAttribute("account") : null;
        if (account == null || account.getRoleId() != 2) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        Shop shop = shopDAO.selectShopByOwnerId(account.getId());
        if (shop == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        return shop;
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }
    private long parseLong(String s) { try { return Long.parseLong(trim(s)); } catch (Exception e) { return 0; } }
    private double parseDouble(String s) { try { return Double.parseDouble(trim(s)); } catch (Exception e) { return 0; } }
}
