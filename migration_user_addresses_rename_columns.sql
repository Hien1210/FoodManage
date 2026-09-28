-- =============================================================
-- Migration: Dong bo ten cot bang User_Addresses voi database.md
--   user_id -> account_id      (khoa ngoai toi Accounts.id)
--   address -> full_address    (dia chi day du)
--   IDX_UserAddress_User -> IDX_UserAddress_Account
--   Them chi muc IX_UserAddresses_Account_Deleted_Default neu chua co
--
-- Boi canh: mot so DB cu duoc tao truoc khi database.md doi ten cot nen van dung user_id/address.
-- UserAddressDAOImpl da tu do ten cot nen chay duoc voi ca 2 dang; migration nay dua DB ve dang chuan.
-- Chay nhieu lan van an toan (chi doi ten khi cot cu con ton tai va cot moi chua co).
-- LUU Y: sau khi chay, khoi dong lai Tomcat (DAO cache ten cot sau lan dung dau tien).
-- =============================================================

IF OBJECT_ID(N'dbo.User_Addresses', N'U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.User_Addresses') AND name = N'user_id')
       AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.User_Addresses') AND name = N'account_id')
    BEGIN
        EXEC sp_rename N'dbo.User_Addresses.user_id', N'account_id', N'COLUMN';
    END

    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.User_Addresses') AND name = N'address')
       AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.User_Addresses') AND name = N'full_address')
    BEGIN
        EXEC sp_rename N'dbo.User_Addresses.address', N'full_address', N'COLUMN';
    END

    IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.User_Addresses') AND name = N'IDX_UserAddress_User')
       AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.User_Addresses') AND name = N'IDX_UserAddress_Account')
    BEGIN
        EXEC sp_rename N'dbo.User_Addresses.IDX_UserAddress_User', N'IDX_UserAddress_Account', N'INDEX';
    END
END
GO

IF OBJECT_ID(N'dbo.User_Addresses', N'U') IS NOT NULL
   AND EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.User_Addresses') AND name = N'account_id')
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.User_Addresses') AND name = N'IX_UserAddresses_Account_Deleted_Default')
BEGIN
    CREATE INDEX IX_UserAddresses_Account_Deleted_Default
        ON dbo.User_Addresses (account_id, is_deleted, is_default DESC, id);
END
GO
