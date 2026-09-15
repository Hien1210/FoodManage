-- Script kiem tra tong hop (KHONG sua gi ca, chi SELECT) — chay 1 lan tren DB that de biet
-- chinh xac bang/cot nao trong 19 file migration_*.sql o goc repo CHUA duoc apply.
-- Neu cot "TRANG_THAI" hien "THIEU" -> mo dung file migration tuong ung va chay no.
--
-- LUU Y: `migration_topping_category_product_category.sql` (them cot ToppingCategories.category_id,
-- quan he 1-1) KHONG nam trong danh sach kiem tra ben duoi vi day la thiet ke CU, da bi thay the
-- boi `migration_topping_category_multi_product_category.sql` (bang trung gian N-N
-- ToppingCategory_ProductCategories, da kiem tra o duoi). KHONG chay file 1-1 do tren DB da co
-- san bang N-N — se tao lai 1 thiet ke thua/mau thuan voi thiet ke hien tai dang dung.
USE POB;
GO

-- Kiem tra bo chi muc hieu nang toan he thong (migration_database_performance.sql).
SELECT v.index_name,
       CASE WHEN i.index_id IS NULL THEN 'THIEU' ELSE 'OK' END AS trang_thai
FROM (VALUES
    ('IX_Accounts_Role_Status_CreatedAt'), ('IX_Accounts_OnlineActiveShipper'),
    ('IX_Shops_Status_Deleted_CreatedAt'), ('IX_Products_Shop_Deleted_Id'),
    ('IX_Products_PendingReview'), ('IX_Orders_User_UpdatedAt'),
    ('IX_Orders_Shop_Status_CreatedAt'), ('IX_Orders_CreatedAt'),
    ('IX_Orders_Shipper_Status_UpdatedAt'), ('IX_Feedbacks_Target_Reviewer_CreatedAt'),
    ('IX_Feedbacks_PendingReview'), ('IX_Notifications_Account_Read_CreatedAt'),
    ('IX_Complaints_Account_CreatedAt'), ('IX_ShopWalletTx_Shop_CreatedAt'),
    ('IX_AuditLogs_Account_CreatedAt')
) v(index_name)
LEFT JOIN sys.indexes i ON i.name = v.index_name
ORDER BY trang_thai DESC, v.index_name;
GO

SELECT loai, doi_tuong, migration_file,
       CASE
           WHEN loai = 'BANG' AND OBJECT_ID(doi_tuong) IS NOT NULL THEN 'OK'
           WHEN loai = 'COT' AND COL_LENGTH(PARSENAME(doi_tuong, 2), PARSENAME(doi_tuong, 1)) IS NOT NULL THEN 'OK'
           ELSE 'THIEU'
       END AS trang_thai
FROM (
    VALUES
        ('BANG', 'Account_Appeals', 'migration_account_appeals.sql'),
        ('BANG', 'Complaints', 'migration_complaints.sql'),
        ('COT', 'Feedbacks.status', 'migration_feedback_moderation.sql'),
        ('BANG', 'BannedWords', 'migration_feedback_moderation.sql'),
        ('BANG', 'Feedbacks', 'migration_feedbacks.sql'),
        ('COT', 'Accounts.bom_count', 'migration_feedbacks.sql'),
        ('BANG', 'Notifications', 'migration_notifications.sql'),
        ('COT', 'Orders.cancel_reason', 'migration_order_cancel_reason.sql'),
        ('COT', 'Orders.payment_status', 'migration_payment_status.sql'),
        ('COT', 'Orders.payos_order_code', 'migration_payos_order_code.sql'),
        ('COT', 'Accounts.is_online', 'migration_shipper_is_online.sql'),
        ('BANG', 'Shipper_Profiles', 'migration_shipper_profiles.sql'),
        ('COT', 'Shipper_Profiles.cccd', 'migration_shipper_profiles.sql'),
        ('COT', 'Shipper_Profiles.verification_status', 'migration_shipper_verification.sql'),
        ('COT', 'Shipper_Profiles.verified_by', 'migration_shipper_verification.sql'),
        ('COT', 'Shipper_Profiles.id_card_front_url', 'migration_shipper_doc_front_back.sql'),
        ('COT', 'Shipper_Profiles.id_card_back_url', 'migration_shipper_doc_front_back.sql'),
        ('COT', 'Shipper_Profiles.license_front_url', 'migration_shipper_doc_front_back.sql'),
        ('COT', 'Shipper_Profiles.license_back_url', 'migration_shipper_doc_front_back.sql'),
        ('BANG', 'Shipper_Wallets', 'migration_shipper_withdrawals.sql'),
        ('BANG', 'Shipper_Withdrawals', 'migration_shipper_withdrawals.sql'),
        ('BANG', 'Shop_Settlements', 'migration_shop_settlements.sql'),
        ('COT', 'Accounts.suspend_reason', 'migration_suspend_reason.sql'),
        ('BANG', 'ToppingCategory_ProductCategories', 'migration_topping_category_multi_product_category.sql'),
        ('BANG', 'User_Addresses', 'migration_user_addresses.sql'),
        ('COT', 'User_Addresses.locationX', 'migration_user_addresses_location.sql'),
        ('COT', 'User_Addresses.locationY', 'migration_user_addresses_location.sql'),
        ('BANG', 'User_Profiles', 'migration_user_profiles.sql')
) AS checks(loai, doi_tuong, migration_file)
ORDER BY trang_thai DESC, migration_file;
GO

-- Rieng payment_method: kiem tra co dung 1 CHECK constraint hay dang bi trung (xem
-- migration_payment_method_payos.sql ban sua 2026-07-23).
SELECT cc.name AS constraint_name, cc.definition
FROM sys.check_constraints cc
WHERE cc.parent_object_id = OBJECT_ID('Orders')
  AND cc.parent_column_id = COLUMNPROPERTY(OBJECT_ID('Orders'), 'payment_method', 'ColumnId');
-- Ky vong: chi 1 dong, constraint_name = 'CK_Orders_PaymentMethod'.
-- Neu ra 2 dong -> chay lai migration_payment_method_payos.sql (ban da sua) de gop lai con 1.
GO
