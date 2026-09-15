-- Restores and enforces relationships that are used by the application but were
-- previously not enforced by SQL Server. This script never deletes or rewrites data.
USE POB;
GO

-- Bring User_Addresses to the canonical schema used by database.md and the DAO.
IF COL_LENGTH(N'dbo.User_Addresses', N'is_deleted') IS NULL
    ALTER TABLE dbo.User_Addresses ADD is_deleted BIT NOT NULL CONSTRAINT DF_UserAddresses_IsDeleted DEFAULT 0;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.User_Addresses') AND name = N'IX_UserAddresses_Account_Deleted_Default')
    CREATE INDEX IX_UserAddresses_Account_Deleted_Default
        ON dbo.User_Addresses (account_id, is_deleted, is_default DESC, id);
GO

-- Abort before adding constraints if legacy data already violates a new relationship.
IF EXISTS (SELECT 1 FROM dbo.Feedbacks f LEFT JOIN dbo.Orders o ON o.id = f.order_id WHERE o.id IS NULL)
    THROW 51000, N'Khong the them FK Feedbacks.order_id: ton tai feedback khong co don hang.', 1;
IF EXISTS (SELECT 1 FROM dbo.Feedbacks f LEFT JOIN dbo.Accounts a ON a.id = f.reviewer_id WHERE a.id IS NULL)
    THROW 51001, N'Khong the them FK Feedbacks.reviewer_id: ton tai feedback khong co nguoi danh gia.', 1;
IF EXISTS (SELECT 1 FROM dbo.Complaints c WHERE c.resolved_by IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Accounts a WHERE a.id = c.resolved_by))
    THROW 51002, N'Khong the them FK Complaints.resolved_by: ton tai tai khoan xu ly khong hop le.', 1;
IF EXISTS (SELECT 1 FROM dbo.Product_Sizes ps LEFT JOIN dbo.Products p ON p.id = ps.product_id AND p.shop_id = ps.shop_id WHERE p.id IS NULL)
    THROW 51003, N'Khong the lien ket Product_Sizes voi Products: product va shop khong khop.', 1;
IF EXISTS (SELECT 1 FROM dbo.Cart_Items ci LEFT JOIN dbo.Product_Sizes ps ON ps.id = ci.product_size_id AND ps.product_id = ci.product_id WHERE ps.id IS NULL)
    THROW 51004, N'Khong the lien ket Cart_Items: product_size khong thuoc product.', 1;
IF EXISTS (SELECT 1 FROM dbo.Order_Details od LEFT JOIN dbo.Product_Sizes ps ON ps.id = od.product_size_id AND ps.product_id = od.product_id WHERE ps.id IS NULL)
    THROW 51005, N'Khong the lien ket Order_Details: product_size khong thuoc product.', 1;
IF EXISTS (SELECT 1 FROM dbo.Combo_Items ci LEFT JOIN dbo.Product_Sizes ps ON ps.id = ci.product_size_id AND ps.product_id = ci.product_id WHERE ps.id IS NULL)
    THROW 51006, N'Khong the lien ket Combo_Items: product_size khong thuoc product.', 1;
IF EXISTS (SELECT 1 FROM dbo.Flash_Sales fs LEFT JOIN dbo.Product_Sizes ps ON ps.id = fs.product_size_id AND ps.shop_id = fs.shop_id WHERE ps.id IS NULL)
    THROW 51007, N'Khong the lien ket Flash_Sales: product_size khong thuoc shop.', 1;
IF EXISTS (SELECT 1 FROM dbo.Toppings t LEFT JOIN dbo.ToppingCategories tc ON tc.id = t.topping_category_id AND tc.shop_id = t.shop_id WHERE tc.id IS NULL)
    THROW 51008, N'Khong the lien ket Toppings: topping category khong thuoc shop.', 1;
IF EXISTS (SELECT 1 FROM dbo.User_Profiles up JOIN dbo.User_Addresses ua ON ua.id = up.default_address_id WHERE ua.account_id <> up.account_id)
    THROW 51009, N'Khong the lien ket User_Profiles: dia chi mac dinh khong thuoc tai khoan.', 1;
IF EXISTS (
    SELECT 1 FROM dbo.Feedbacks f JOIN dbo.Orders o ON o.id = f.order_id
    WHERE (f.reviewer_type = N'USER' AND f.reviewer_id <> o.user_id)
       OR (f.reviewer_type = N'SHIPPER' AND (o.shipper_id IS NULL OR f.reviewer_id <> o.shipper_id))
       OR (f.target_type = N'SHOP' AND f.target_id <> o.shop_id)
       OR (f.target_type = N'SHIPPER' AND (o.shipper_id IS NULL OR f.target_id <> o.shipper_id))
)
    THROW 51010, N'Khong the kiem tra Feedbacks: reviewer/target khong dung voi don hang.', 1;
IF EXISTS (SELECT 1 FROM dbo.Complaints c JOIN dbo.Orders o ON o.id = c.order_id WHERE c.account_id <> o.user_id)
    THROW 51011, N'Khong the kiem tra Complaints: nguoi gui khong dung chu don.', 1;
GO

-- Direct relationships that can be represented by ordinary foreign keys.
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Feedback_Order')
    ALTER TABLE dbo.Feedbacks ADD CONSTRAINT FK_Feedback_Order FOREIGN KEY (order_id) REFERENCES dbo.Orders(id) ON DELETE CASCADE;
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Feedback_Reviewer')
    ALTER TABLE dbo.Feedbacks ADD CONSTRAINT FK_Feedback_Reviewer FOREIGN KEY (reviewer_id) REFERENCES dbo.Accounts(id);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Complaint_ResolvedBy')
    ALTER TABLE dbo.Complaints ADD CONSTRAINT FK_Complaint_ResolvedBy FOREIGN KEY (resolved_by) REFERENCES dbo.Accounts(id) ON DELETE SET NULL;
GO

-- Composite FKs ensure child records cannot combine IDs from different products/shops.
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_Products_Id_Shop')
    ALTER TABLE dbo.Products ADD CONSTRAINT UQ_Products_Id_Shop UNIQUE (id, shop_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_ProductSizes_Id_Product')
    ALTER TABLE dbo.Product_Sizes ADD CONSTRAINT UQ_ProductSizes_Id_Product UNIQUE (id, product_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_ProductSizes_Id_Shop')
    ALTER TABLE dbo.Product_Sizes ADD CONSTRAINT UQ_ProductSizes_Id_Shop UNIQUE (id, shop_id);
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_ToppingCategories_Id_Shop')
    ALTER TABLE dbo.ToppingCategories ADD CONSTRAINT UQ_ToppingCategories_Id_Shop UNIQUE (id, shop_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ProductSize_ProductShop')
    ALTER TABLE dbo.Product_Sizes ADD CONSTRAINT FK_ProductSize_ProductShop FOREIGN KEY (product_id, shop_id) REFERENCES dbo.Products(id, shop_id);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_CartItem_ProductSizeProduct')
    ALTER TABLE dbo.Cart_Items ADD CONSTRAINT FK_CartItem_ProductSizeProduct FOREIGN KEY (product_size_id, product_id) REFERENCES dbo.Product_Sizes(id, product_id);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_OrderDetail_ProductSizeProduct')
    ALTER TABLE dbo.Order_Details ADD CONSTRAINT FK_OrderDetail_ProductSizeProduct FOREIGN KEY (product_size_id, product_id) REFERENCES dbo.Product_Sizes(id, product_id);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_ComboItem_ProductSizeProduct')
    ALTER TABLE dbo.Combo_Items ADD CONSTRAINT FK_ComboItem_ProductSizeProduct FOREIGN KEY (product_size_id, product_id) REFERENCES dbo.Product_Sizes(id, product_id);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_FlashSale_ProductSizeShop')
    ALTER TABLE dbo.Flash_Sales ADD CONSTRAINT FK_FlashSale_ProductSizeShop FOREIGN KEY (product_size_id, shop_id) REFERENCES dbo.Product_Sizes(id, shop_id);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Topping_CategoryShop')
    ALTER TABLE dbo.Toppings ADD CONSTRAINT FK_Topping_CategoryShop FOREIGN KEY (topping_category_id, shop_id) REFERENCES dbo.ToppingCategories(id, shop_id);
GO

-- Business relationships use multiple possible target tables, so a normal FK cannot express them.
CREATE OR ALTER TRIGGER dbo.TR_Feedbacks_ValidateOrderParties ON dbo.Feedbacks
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted f JOIN dbo.Orders o ON o.id = f.order_id
        WHERE (f.reviewer_type = N'USER' AND f.reviewer_id <> o.user_id)
           OR (f.reviewer_type = N'SHIPPER' AND (o.shipper_id IS NULL OR f.reviewer_id <> o.shipper_id))
           OR (f.target_type = N'SHOP' AND f.target_id <> o.shop_id)
           OR (f.target_type = N'SHIPPER' AND (o.shipper_id IS NULL OR f.target_id <> o.shipper_id))
    )
        THROW 51012, N'Feedback phai dung reviewer, target va don hang lien quan.', 1;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_Complaints_ValidateOrderOwner ON dbo.Complaints
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted c JOIN dbo.Orders o ON o.id = c.order_id WHERE c.account_id <> o.user_id)
        THROW 51013, N'Chi chu don hang moi duoc tao khieu nai cho don do.', 1;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_UserProfiles_ValidateDefaultAddress ON dbo.User_Profiles
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted up JOIN dbo.User_Addresses ua ON ua.id = up.default_address_id
        WHERE ua.account_id <> up.account_id
    )
        THROW 51014, N'Dia chi mac dinh phai thuoc cung tai khoan voi ho so nguoi dung.', 1;
END;
GO
