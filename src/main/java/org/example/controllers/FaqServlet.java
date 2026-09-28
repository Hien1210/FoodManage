package org.example.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.daos.FaqDAO;
import org.example.daos.FaqDAOImpl;
import org.example.models.Account;
import org.example.models.Faq;
import org.example.services.AuditLogService;
import org.example.utils.AuditModules;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/faq")
public class FaqServlet extends HttpServlet {

    private static final String VIEW_LIST = "/admin/faqDanhSach.jsp";
    private static final String VIEW_FORM = "/admin/faqThemSua.jsp";

    private final FaqDAO faqDAO = new FaqDAOImpl();
    private final AuditLogService auditLogService = new AuditLogService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!requireAdmin(req, resp)) {
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "new":
                req.getRequestDispatcher(VIEW_FORM).forward(req, resp);
                break;

            case "edit":
                Long id = parseId(req);
                if (id == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/faq");
                    return;
                }
                Faq faq = faqDAO.findById(id);
                if (faq == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/faq");
                    return;
                }
                req.setAttribute("faq", faq);
                req.getRequestDispatcher(VIEW_FORM).forward(req, resp);
                break;

            case "list":
            default:
                List<Faq> danhSach = faqDAO.findAll();
                req.setAttribute("danhSachFaq", danhSach);
                req.getRequestDispatcher(VIEW_LIST).forward(req, resp);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!requireAdmin(req, resp)) {
            return;
        }

        Account admin = getLoggedInAccount(req);
        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/faq");
            return;
        }

        switch (action) {
            case "insert":
                handleInsert(req, resp, admin);
                break;

            case "update":
                handleUpdate(req, resp, admin);
                break;

            case "delete":
                handleDelete(req, resp, admin);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/admin/faq");
        }
    }

    private void handleInsert(HttpServletRequest req, HttpServletResponse resp, Account admin)
            throws ServletException, IOException {
        String question = normalize(req.getParameter("question"));
        String answer = normalize(req.getParameter("answer"));
        String category = normalize(req.getParameter("category"));
        int displayOrder = parseDisplayOrder(req);

        String faqError = (question.isEmpty() || answer.isEmpty()) ? "Câu hỏi và câu trả lời không được để trống"
                : org.example.utils.InputValidationUtil.firstError(
                        org.example.utils.InputValidationUtil.checkMultiline("Câu hỏi", question, 500),
                        org.example.utils.InputValidationUtil.checkMultiline("Câu trả lời", answer, 5000),
                        org.example.utils.InputValidationUtil.checkLine("Danh mục", category, 100));
        if (faqError != null) {
            req.setAttribute("loi", faqError);
            req.getRequestDispatcher(VIEW_FORM).forward(req, resp);
            return;
        }

        Faq faq = new Faq();
        faq.setQuestion(question);
        faq.setAnswer(answer);
        faq.setCategory(category.isEmpty() ? null : category);
        faq.setDisplayOrder(displayOrder);
        faq.setActive(true);
        faq.setCreatedBy(admin.getId());

        long newId = faqDAO.create(faq);
        if (newId > 0) {
            auditLogService.log(req, admin, "Tạo FAQ", AuditModules.FAQ,
                    "Super Admin " + admin.getUserName() + " đã tạo FAQ \"" + question + "\" (ID=" + newId + ")",
                    newId, AuditModules.FAQ);
            resp.sendRedirect(req.getContextPath() + "/admin/faq?success=insert");
        } else {
            req.setAttribute("loi", "Tạo FAQ thất bại, vui lòng thử lại");
            req.getRequestDispatcher(VIEW_FORM).forward(req, resp);
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, Account admin)
            throws ServletException, IOException {
        Long id = parseId(req);
        if (id == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/faq");
            return;
        }

        Faq existing = faqDAO.findById(id);
        if (existing == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/faq");
            return;
        }

        String question = normalize(req.getParameter("question"));
        String answer = normalize(req.getParameter("answer"));
        String category = normalize(req.getParameter("category"));
        int displayOrder = parseDisplayOrder(req);

        String faqError = (question.isEmpty() || answer.isEmpty()) ? "Câu hỏi và câu trả lời không được để trống"
                : org.example.utils.InputValidationUtil.firstError(
                        org.example.utils.InputValidationUtil.checkMultiline("Câu hỏi", question, 500),
                        org.example.utils.InputValidationUtil.checkMultiline("Câu trả lời", answer, 5000),
                        org.example.utils.InputValidationUtil.checkLine("Danh mục", category, 100));
        if (faqError != null) {
            req.setAttribute("loi", faqError);
            req.setAttribute("faq", existing);
            req.getRequestDispatcher(VIEW_FORM).forward(req, resp);
            return;
        }

        existing.setQuestion(question);
        existing.setAnswer(answer);
        existing.setCategory(category.isEmpty() ? null : category);
        existing.setDisplayOrder(displayOrder);
        existing.setUpdatedBy(admin.getId());

        boolean ok = faqDAO.update(existing);
        if (ok) {
            auditLogService.log(req, admin, "Sửa FAQ", AuditModules.FAQ,
                    "Super Admin " + admin.getUserName() + " đã cập nhật FAQ \"" + question + "\" (ID=" + id + ")",
                    id, AuditModules.FAQ);
            resp.sendRedirect(req.getContextPath() + "/admin/faq?success=update");
        } else {
            req.setAttribute("loi", "Cập nhật FAQ thất bại, vui lòng thử lại");
            req.setAttribute("faq", existing);
            req.getRequestDispatcher(VIEW_FORM).forward(req, resp);
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, Account admin) throws IOException {
        Long id = parseId(req);
        if (id == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/faq");
            return;
        }

        Faq existing = faqDAO.findById(id);
        if (existing == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/faq");
            return;
        }

        boolean ok = faqDAO.softDelete(id, admin.getId());
        if (ok) {
            auditLogService.log(req, admin, "Xóa FAQ", AuditModules.FAQ,
                    "Super Admin " + admin.getUserName() + " đã xóa FAQ \"" + existing.getQuestion() + "\" (ID=" + id + ")",
                    id, AuditModules.FAQ);
            resp.sendRedirect(req.getContextPath() + "/admin/faq?success=delete");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/faq?error=delete");
        }
    }

    private boolean requireAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Account account = getLoggedInAccount(req);
        if (account == null || account.getRoleId() != 1) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return false;
        }
        return true;
    }

    private Account getLoggedInAccount(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (Account) session.getAttribute("account");
    }

    private Long parseId(HttpServletRequest req) {
        try {
            return Long.parseLong(req.getParameter("id"));
        } catch (Exception e) {
            return null;
        }
    }

    private int parseDisplayOrder(HttpServletRequest req) {
        try {
            return Integer.parseInt(req.getParameter("displayOrder"));
        } catch (Exception e) {
            return 0;
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }
}
