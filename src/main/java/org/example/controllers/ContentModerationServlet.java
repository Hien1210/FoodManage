package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.FeedbackDAO;
import org.example.daos.FeedbackDAOImpl;
import org.example.daos.ProductDAO;
import org.example.daos.ProductDAOImpl;
import org.example.daos.ProductImageDAO;
import org.example.daos.ProductImageDAOImpl;
import org.example.models.Account;
import org.example.models.BannedWord;
import org.example.models.Product;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/kiem-duyet-noi-dung")
public class ContentModerationServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAOImpl();
    private final ProductImageDAO productImageDAO = new ProductImageDAOImpl();
    private final FeedbackDAO feedbackDAO = new FeedbackDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!requireAdmin(req, resp)) return;

        List<Product> pendingProducts = productDAO.findPendingReview();
        Map<Long, String> imageUrls = productImageDAO.findPrimaryUrlsByProductIds(
                pendingProducts.stream().map(Product::getId).collect(java.util.stream.Collectors.toList()));
        for (Product p : pendingProducts) {
            p.setImageUrl(imageUrls.get(p.getId()));
        }
        req.setAttribute("pendingProducts", pendingProducts);

        List<BannedWord> bannedWords = feedbackDAO.findAllBannedWords();
        req.setAttribute("bannedWords", bannedWords);

        req.getRequestDispatcher("/admin/KiemDuyetNoiDung.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!requireAdmin(req, resp)) return;
        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");

        if ("approve".equals(action)) {
            long productId = parseLong(req.getParameter("productId"));
            // Dung CAS atomic (khong phai doc-roi-ghi thuong): chi duyet san pham dang THUC SU con
            // o PENDING_REVIEW tai thoi diem ghi, tranh duyet/tu choi trung khi 2 tab admin thao
            // tac gan nhu dong thoi (doc-roi-ghi thuong khong chan duoc truong hop nay).
            boolean updated = productDAO.updateStatusIfCurrent(productId, "PENDING_REVIEW", "ACTIVE");
            if (updated) {
                resp.sendRedirect(req.getContextPath() + "/admin/kiem-duyet-noi-dung?success=approved");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/kiem-duyet-noi-dung?error=already_processed");
            }
        } else if ("reject".equals(action)) {
            long productId = parseLong(req.getParameter("productId"));
            boolean updated = productDAO.updateStatusIfCurrent(productId, "PENDING_REVIEW", "HIDDEN");
            if (updated) {
                resp.sendRedirect(req.getContextPath() + "/admin/kiem-duyet-noi-dung?success=rejected");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/kiem-duyet-noi-dung?error=already_processed");
            }
        } else if ("addWord".equals(action)) {
            String word = req.getParameter("word");
            if (word != null && !word.isBlank() && org.example.utils.InputValidationUtil.checkLine("Từ khóa", word.trim(), 100) == null) {
                feedbackDAO.addBannedWord(word.trim());
                resp.sendRedirect(req.getContextPath() + "/admin/kiem-duyet-noi-dung?success=wordAdded");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/kiem-duyet-noi-dung");
            }
        } else if ("deleteWord".equals(action)) {
            feedbackDAO.deleteBannedWord(parseLong(req.getParameter("wordId")));
            resp.sendRedirect(req.getContextPath() + "/admin/kiem-duyet-noi-dung?success=wordDeleted");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/kiem-duyet-noi-dung");
        }
    }

    private boolean requireAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Account account = session != null ? (Account) session.getAttribute("account") : null;
        if (account == null || account.getRoleId() != 1) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return false;
        }
        return true;
    }

    private long parseLong(String val) {
        try { return Long.parseLong(val); } catch (Exception e) { return 0; }
    }
}
