-- Database performance baseline for POB (SQL Server).
-- All statements are idempotent. The indexes match the application's current DAO
-- predicates and sort orders; they intentionally avoid duplicating primary/unique keys.
USE POB;
GO

-- Accounts, shops and catalogue moderation/listing.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Accounts') AND name = N'IX_Accounts_Role_Status_CreatedAt')
    CREATE INDEX IX_Accounts_Role_Status_CreatedAt ON dbo.Accounts (role_id, status, is_deleted, created_at DESC) INCLUDE (is_online, full_name);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Accounts') AND name = N'IX_Accounts_OnlineActiveShipper')
    CREATE INDEX IX_Accounts_OnlineActiveShipper ON dbo.Accounts (full_name) WHERE role_id = 4 AND status = 'ACTIVE' AND is_deleted = 0 AND is_online = 1;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Shops') AND name = N'IX_Shops_Status_Deleted_CreatedAt')
    CREATE INDEX IX_Shops_Status_Deleted_CreatedAt ON dbo.Shops (status, is_deleted, created_at DESC);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Products') AND name = N'IX_Products_Shop_Deleted_Id')
    CREATE INDEX IX_Products_Shop_Deleted_Id ON dbo.Products (shop_id, is_deleted, id DESC) INCLUDE (category_id, status, product_name, stock_quantity, sold_count);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Products') AND name = N'IX_Products_PendingReview')
    CREATE INDEX IX_Products_PendingReview ON dbo.Products (created_at DESC) INCLUDE (shop_id, product_name, category_id) WHERE status = 'PENDING_REVIEW' AND is_deleted = 0;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Categories') AND name = N'IX_Categories_Shop_Deleted_Id')
    CREATE INDEX IX_Categories_Shop_Deleted_Id ON dbo.Categories (shop_id, is_deleted, id DESC) INCLUDE (name);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.ToppingCategories') AND name = N'IX_ToppingCategories_Shop_Deleted_Id')
    CREATE INDEX IX_ToppingCategories_Shop_Deleted_Id ON dbo.ToppingCategories (shop_id, is_deleted, id DESC) INCLUDE (name);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Toppings') AND name = N'IX_Toppings_Shop_Deleted_Id')
    CREATE INDEX IX_Toppings_Shop_Deleted_Id ON dbo.Toppings (shop_id, is_deleted, id DESC) INCLUDE (topping_category_id, topping_name, price, status);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.ToppingCategory_ProductCategories') AND name = N'IX_TCPC_Category')
    CREATE INDEX IX_TCPC_Category ON dbo.ToppingCategory_ProductCategories (category_id, topping_category_id);
GO

-- Cart and order composition. These also speed up FK checks and cascade deletes.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Cart_Items') AND name = N'IX_CartItems_Cart_Product_Size_Combo')
    CREATE INDEX IX_CartItems_Cart_Product_Size_Combo ON dbo.Cart_Items (cart_id, product_id, product_size_id, combo_id) INCLUDE (quantity, combo_unit_price);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Cart_Item_Toppings') AND name = N'IX_CartItemToppings_CartItem')
    CREATE INDEX IX_CartItemToppings_CartItem ON dbo.Cart_Item_Toppings (cart_item_id) INCLUDE (topping_id, quantity);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Order_Detail_Toppings') AND name = N'IX_OrderDetailToppings_OrderDetail')
    CREATE INDEX IX_OrderDetailToppings_OrderDetail ON dbo.Order_Detail_Toppings (order_detail_id, id) INCLUDE (topping_id, quantity, price);
GO

-- Orders: user/shop/shipper dashboards, reports and the shipper review page.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Orders') AND name = N'IX_Orders_User_UpdatedAt')
    CREATE INDEX IX_Orders_User_UpdatedAt ON dbo.Orders (user_id, updated_at DESC) INCLUDE (shop_id, shipper_id, status, total_price, payment_status);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Orders') AND name = N'IX_Orders_Shop_Status_CreatedAt')
    CREATE INDEX IX_Orders_Shop_Status_CreatedAt ON dbo.Orders (shop_id, status, created_at DESC) INCLUDE (total_price, shipper_id, payment_status);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Orders') AND name = N'IX_Orders_CreatedAt')
    CREATE INDEX IX_Orders_CreatedAt ON dbo.Orders (created_at) INCLUDE (status, shop_id, shipper_id, total_price, cancel_reason, locationX, locationY);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Orders') AND name = N'IX_Orders_Shipper_Status_UpdatedAt')
    CREATE INDEX IX_Orders_Shipper_Status_UpdatedAt ON dbo.Orders (shipper_id, status, updated_at DESC) INCLUDE (shop_id, receiver_name, receiver_phone, shipping_address, total_price);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Order_Logs') AND name = N'IX_OrderLogs_Status_Order_CreatedAt')
    CREATE INDEX IX_OrderLogs_Status_Order_CreatedAt ON dbo.Order_Logs (new_status, order_id, created_at);
GO

-- Reviews, notifications and operational workflows.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Feedbacks') AND name = N'IX_Feedbacks_Target_Reviewer_CreatedAt')
    CREATE INDEX IX_Feedbacks_Target_Reviewer_CreatedAt ON dbo.Feedbacks (target_type, target_id, reviewer_type, created_at DESC) INCLUDE (reviewer_id, rating, comment, is_anonymous, status);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Feedbacks') AND name = N'IX_Feedbacks_PendingReview')
    CREATE INDEX IX_Feedbacks_PendingReview ON dbo.Feedbacks (created_at DESC) INCLUDE (order_id, reviewer_id, target_type, target_id, rating, comment, is_anonymous) WHERE status = 'PENDING_REVIEW';
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Feedbacks') AND name = N'IX_Feedbacks_ReviewedAt')
    CREATE INDEX IX_Feedbacks_ReviewedAt ON dbo.Feedbacks (reviewed_at DESC) INCLUDE (order_id, reviewer_id, target_type, target_id, rating, comment, is_anonymous, status) WHERE reviewed_at IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Feedbacks') AND name = N'IX_Feedbacks_Reviewer')
    CREATE INDEX IX_Feedbacks_Reviewer ON dbo.Feedbacks (reviewer_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Notifications') AND name = N'IX_Notifications_Account_Read_CreatedAt')
    CREATE INDEX IX_Notifications_Account_Read_CreatedAt ON dbo.Notifications (account_id, is_read, created_at DESC);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Account_Appeals') AND name = N'IX_AccountAppeals_Status_CreatedAt')
    CREATE INDEX IX_AccountAppeals_Status_CreatedAt ON dbo.Account_Appeals (status, created_at DESC) INCLUDE (account_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Account_Appeals') AND name = N'IX_AccountAppeals_Account_Status')
    CREATE INDEX IX_AccountAppeals_Account_Status ON dbo.Account_Appeals (account_id, status);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Complaints') AND name = N'IX_Complaints_Account_CreatedAt')
    CREATE INDEX IX_Complaints_Account_CreatedAt ON dbo.Complaints (account_id, created_at DESC);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Complaints') AND name = N'IX_Complaints_Status_CreatedAt')
    CREATE INDEX IX_Complaints_Status_CreatedAt ON dbo.Complaints (status, created_at DESC);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Shipper_Profiles') AND name = N'IX_ShipperProfiles_Verification_CreatedAt')
    CREATE INDEX IX_ShipperProfiles_Verification_CreatedAt ON dbo.Shipper_Profiles (verification_status, created_at DESC);
GO

-- Wallet, withdrawal and audit history screens.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Shop_Wallet_Transactions') AND name = N'IX_ShopWalletTx_Shop_CreatedAt')
    CREATE INDEX IX_ShopWalletTx_Shop_CreatedAt ON dbo.Shop_Wallet_Transactions (shop_id, created_at DESC);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Shop_Withdrawals') AND name = N'IX_ShopWithdrawals_Shop_Status_RequestedAt')
    CREATE INDEX IX_ShopWithdrawals_Shop_Status_RequestedAt ON dbo.Shop_Withdrawals (shop_id, status, requested_at DESC) INCLUDE (amount, processed_by);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Shop_Withdrawals') AND name = N'IX_ShopWithdrawals_Status_RequestedAt')
    CREATE INDEX IX_ShopWithdrawals_Status_RequestedAt ON dbo.Shop_Withdrawals (status, requested_at DESC) INCLUDE (shop_id, amount, processed_by);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Shipper_Withdrawals') AND name = N'IX_ShipperWithdrawals_Shipper_Status_RequestedAt')
    CREATE INDEX IX_ShipperWithdrawals_Shipper_Status_RequestedAt ON dbo.Shipper_Withdrawals (shipper_account_id, status, requested_at DESC) INCLUDE (amount, processed_by);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.AuditLogs') AND name = N'IX_AuditLogs_Account_CreatedAt')
    CREATE INDEX IX_AuditLogs_Account_CreatedAt ON dbo.AuditLogs (account_id, created_at DESC) INCLUDE (role_id, module, action);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.AuditLogs') AND name = N'IX_AuditLogs_Module_CreatedAt')
    CREATE INDEX IX_AuditLogs_Module_CreatedAt ON dbo.AuditLogs (module, created_at DESC) INCLUDE (account_id, role_id, action);
GO

-- Active vouchers are searched by validity window and minimum basket value.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Vouchers') AND name = N'IX_Vouchers_Active_Validity')
    CREATE INDEX IX_Vouchers_Active_Validity ON dbo.Vouchers (is_active, start_date, end_date) INCLUDE (min_order_value, value, max_discount, usage_limit, used_count);
GO
