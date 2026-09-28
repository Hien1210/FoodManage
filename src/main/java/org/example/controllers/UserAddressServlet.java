package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.UserAddressDAO;
import org.example.daos.UserAddressDAOImpl;
import org.example.daos.NotificationDAOImpl;
import org.example.models.Account;
import org.example.models.UserAddress;

import java.io.IOException;
import java.util.List;

@WebServlet("/user/dia-chi")
public class UserAddressServlet extends HttpServlet {
    private static final String VIEW = "/user/diaChi.jsp";

    private final UserAddressDAO userAddressDAO = new UserAddressDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Account account = currentAccount(req);
        if (account == null) { resp.sendRedirect(req.getContextPath() + "/dangnhap"); return; }

        List<UserAddress> addresses = userAddressDAO.findByAccountId(account.getId());
        req.setAttribute("addresses", addresses);
        req.setAttribute("unreadNotifCount", new NotificationDAOImpl().countUnread(account.getId()));
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        Account account = currentAccount(req);
        if (account == null) { resp.sendRedirect(req.getContextPath() + "/dangnhap"); return; }

        String action = normalize(req.getParameter("action"));
        switch (action) {
            case "create": createAddress(req, resp, account); break;
            case "update": updateAddress(req, resp, account); break;
            case "delete": deleteAddress(req, resp, account); break;
            case "setDefault": setDefaultAddress(req, resp, account); break;
            default: resp.sendRedirect(req.getContextPath() + "/user/dia-chi");
        }
    }

    private void createAddress(HttpServletRequest req, HttpServletResponse resp, Account account) throws IOException {
        String label = normalize(req.getParameter("label"));
        String fullAddress = normalize(req.getParameter("fullAddress"));
        String receiverName = normalize(req.getParameter("receiverName"));
        String receiverPhone = normalize(req.getParameter("receiverPhone"));
        boolean isDefault = "true".equals(req.getParameter("isDefault"));
        Double locationX = parseDoubleOrNull(req.getParameter("locationX"));
        Double locationY = parseDoubleOrNull(req.getParameter("locationY"));

        if (fullAddress.isEmpty() || receiverName.isEmpty() || receiverPhone.isEmpty() || locationX == null || locationY == null) {
            redirectTo(req, resp, "error=missing");
            return;
        }

        if (org.example.utils.InputValidationUtil.firstError(
                org.example.utils.InputValidationUtil.checkLine("Nhãn", label, org.example.utils.InputValidationUtil.MAX_LABEL),
                org.example.utils.InputValidationUtil.checkLine("Địa chỉ", fullAddress, org.example.utils.InputValidationUtil.MAX_ADDRESS),
                org.example.utils.InputValidationUtil.checkLine("Tên người nhận", receiverName, org.example.utils.InputValidationUtil.MAX_PERSON_NAME),
                org.example.utils.InputValidationUtil.checkPhone("Số điện thoại", receiverPhone)) != null) {
            redirectTo(req, resp, "error=invalid");
            return;
        }

        UserAddress a = new UserAddress();
        a.setAccountId(account.getId());
        a.setLabel(label.isEmpty() ? "Khác" : label);
        a.setFullAddress(fullAddress);
        a.setReceiverName(receiverName);
        a.setReceiverPhone(receiverPhone);
        a.setDefault(isDefault);
        a.setLocationX(locationX);
        a.setLocationY(locationY);

        boolean ok = userAddressDAO.create(a);
        if (ok && isDefault) {
            List<UserAddress> addresses = userAddressDAO.findByAccountId(account.getId());
            UserAddress created = addresses.isEmpty() ? null : addresses.get(addresses.size() - 1);
            if (created != null) {
                userAddressDAO.setDefault(created.getId(), account.getId());
            }
        }

        redirectTo(req, resp, "success=created");
    }

    private void updateAddress(HttpServletRequest req, HttpServletResponse resp, Account account) throws IOException {
        Long id = parseId(req.getParameter("id"));
        String label = normalize(req.getParameter("label"));
        String fullAddress = normalize(req.getParameter("fullAddress"));
        String receiverName = normalize(req.getParameter("receiverName"));
        String receiverPhone = normalize(req.getParameter("receiverPhone"));
        Double locationX = parseDoubleOrNull(req.getParameter("locationX"));
        Double locationY = parseDoubleOrNull(req.getParameter("locationY"));

        if (id == null || fullAddress.isEmpty() || receiverName.isEmpty() || receiverPhone.isEmpty() || locationX == null || locationY == null) {
            redirectTo(req, resp, "error=missing");
            return;
        }

        if (org.example.utils.InputValidationUtil.firstError(
                org.example.utils.InputValidationUtil.checkLine("Nhãn", label, org.example.utils.InputValidationUtil.MAX_LABEL),
                org.example.utils.InputValidationUtil.checkLine("Địa chỉ", fullAddress, org.example.utils.InputValidationUtil.MAX_ADDRESS),
                org.example.utils.InputValidationUtil.checkLine("Tên người nhận", receiverName, org.example.utils.InputValidationUtil.MAX_PERSON_NAME),
                org.example.utils.InputValidationUtil.checkPhone("Số điện thoại", receiverPhone)) != null) {
            redirectTo(req, resp, "error=invalid");
            return;
        }

        UserAddress existing = userAddressDAO.findById(id);
        if (existing == null || existing.getAccountId() != account.getId()) {
            redirectTo(req, resp, "error=missing");
            return;
        }

        existing.setLabel(label.isEmpty() ? "Khác" : label);
        existing.setFullAddress(fullAddress);
        existing.setReceiverName(receiverName);
        existing.setReceiverPhone(receiverPhone);
        existing.setLocationX(locationX);
        existing.setLocationY(locationY);

        userAddressDAO.update(existing);
        redirectTo(req, resp, "success=updated");
    }

    private void deleteAddress(HttpServletRequest req, HttpServletResponse resp, Account account) throws IOException {
        Long id = parseId(req.getParameter("id"));
        UserAddress existing = id == null ? null : userAddressDAO.findById(id);
        if (existing == null || existing.getAccountId() != account.getId() || !userAddressDAO.delete(id)) {
            resp.sendRedirect(req.getContextPath() + "/user/dia-chi?error=notfound");
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/user/dia-chi?success=deleted");
    }

    private void setDefaultAddress(HttpServletRequest req, HttpServletResponse resp, Account account) throws IOException {
        Long id = parseId(req.getParameter("id"));
        UserAddress existing = id == null ? null : userAddressDAO.findById(id);
        if (existing == null || existing.getAccountId() != account.getId() || !userAddressDAO.setDefault(id, account.getId())) {
            resp.sendRedirect(req.getContextPath() + "/user/dia-chi?error=notfound");
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/user/dia-chi?success=default");
    }

    private Account currentAccount(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        Object obj = session.getAttribute("account");
        if (!(obj instanceof Account)) return null;
        Account account = (Account) obj;
        return account.getRoleId() == 3 ? account : null;
    }

    private Long parseId(String value) {
        try {
            String normalized = normalize(value);
            return normalized.isEmpty() ? null : Long.parseLong(normalized);
        } catch (Exception e) { return null; }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private void redirectTo(HttpServletRequest req, HttpServletResponse resp, String queryString) throws IOException {
        String returnTo = normalize(req.getParameter("returnTo"));
        String cartId = normalize(req.getParameter("cartId"));
        if ("checkout".equals(returnTo) && !cartId.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/checkout?cartId=" + cartId);
        } else {
            resp.sendRedirect(req.getContextPath() + "/user/dia-chi?" + queryString);
        }
    }

    private Double parseDoubleOrNull(String value) {
        try {
            String normalized = normalize(value);
            return normalized.isEmpty() ? null : Double.parseDouble(normalized);
        } catch (Exception e) {
            return null;
        }
    }
}
